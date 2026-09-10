#!/usr/bin/env python3
"""Telegram reply relay for wetlands_contact.

One process owns getUpdates, persists every accepted reply in SQLite, and
offers a private Docker-network HTTP API to the Luanti worlds.
"""

from __future__ import annotations

import hashlib
import hmac
import json
import os
import re
import signal
import sqlite3
import threading
import time
import urllib.error
import urllib.parse
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


HOST = "0.0.0.0"
PORT = 8788
DB_PATH = "/data/relay.sqlite3"
ALLOWED_WORLDS = frozenset({"original", "valdivia"})
POLL_TIMEOUT = 25
HTTP_TIMEOUT = POLL_TIMEOUT + 10
HEALTH_STARTUP_GRACE = HTTP_TIMEOUT + 60
HEALTH_POLL_STALE = HTTP_TIMEOUT + 90
QUEUE_TTL = 7 * 24 * 60 * 60
UPDATE_MAX_AGE = 24 * 60 * 60
MAX_REPLY_CHARS = 500
MAX_TELEGRAM_BODY = 1_000_000
MAX_API_BODY = 4096
MAX_PLAYER_BYTES = 64
API_LIMIT = 20
KEY_CONTEXT = "wetlands-contact-relay-v1"
MARKER_RE = re.compile(
    r"(?m)^\[\[wetlands_contact:v1;world=(original|valdivia);"
    r"player_hex=([0-9a-f]{2,128});request=([0-9a-f]{64})\]\]$"
)


def require_environment() -> tuple[str, int, int]:
    token = os.environ.get("WETLANDS_TELEGRAM_BOT_TOKEN", "").strip()
    chat_raw = os.environ.get("WETLANDS_TELEGRAM_CHAT_ID", "").strip()
    if not re.fullmatch(r"[0-9]+:[A-Za-z0-9_-]{30,}", token):
        raise SystemExit("WETLANDS_TELEGRAM_BOT_TOKEN is missing or invalid")
    if not re.fullmatch(r"[1-9][0-9]*", chat_raw):
        raise SystemExit("WETLANDS_TELEGRAM_CHAT_ID must be a positive private-chat ID")
    return token, int(chat_raw), int(token.split(":", 1)[0])


TOKEN, ADMIN_CHAT_ID, BOT_ID = require_environment()
TELEGRAM_BASE = f"https://api.telegram.org/bot{TOKEN}"
last_loop_heartbeat = time.monotonic()
started_at = time.monotonic()
last_successful_poll: float | None = None
stopping = threading.Event()


def database() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH, timeout=10)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA busy_timeout = 10000")
    return conn


def initialize_database() -> None:
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    with database() as conn:
        conn.execute("PRAGMA journal_mode = WAL")
        conn.execute("PRAGMA synchronous = FULL")
        conn.executescript(
            """
            CREATE TABLE IF NOT EXISTS metadata (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS processed_updates (
                update_id INTEGER PRIMARY KEY,
                processed_at INTEGER NOT NULL,
                outcome TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS reply_queue (
                update_id INTEGER PRIMARY KEY,
                world_id TEXT NOT NULL CHECK (world_id IN ('original', 'valdivia')),
                player TEXT NOT NULL,
                request_id TEXT NOT NULL,
                text TEXT NOT NULL,
                created_at INTEGER NOT NULL,
                expires_at INTEGER NOT NULL
            );
            CREATE INDEX IF NOT EXISTS reply_queue_target
                ON reply_queue(world_id, player, created_at);
            """
        )


def validate_bot_identity() -> None:
    """Bind the durable offset/dedup state to one Telegram bot."""
    with database() as conn:
        conn.execute("BEGIN IMMEDIATE")
        row = conn.execute(
            "SELECT value FROM metadata WHERE key = 'telegram_bot_id'"
        ).fetchone()
        if row and row[0] != str(BOT_ID):
            raise SystemExit(
                "Telegram bot identity changed; refusing to reuse the existing relay "
                "database. Existing queued replies were preserved."
            )
        conn.execute(
            """INSERT INTO metadata(key, value) VALUES ('telegram_bot_id', ?)
               ON CONFLICT(key) DO UPDATE SET value = excluded.value""",
            (str(BOT_ID),),
        )


def relay_key(world_id: str) -> str:
    material = f"{KEY_CONTEXT}:{TOKEN}:{world_id}".encode("utf-8")
    return hashlib.sha256(material).hexdigest()


def telegram_call(method: str, data: dict[str, str] | None = None, timeout: int = 10):
    encoded = urllib.parse.urlencode(data or {}).encode("ascii")
    request = urllib.request.Request(
        f"{TELEGRAM_BASE}/{method}",
        data=encoded,
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            body = response.read(MAX_TELEGRAM_BODY + 1)
    except (urllib.error.URLError, TimeoutError, OSError):
        return None
    if len(body) > MAX_TELEGRAM_BODY:
        return None
    try:
        parsed = json.loads(body.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError):
        return None
    return parsed if isinstance(parsed, dict) and parsed.get("ok") is True else None


def notify_admin(text: str) -> None:
    telegram_call(
        "sendMessage",
        {"chat_id": str(ADMIN_CHAT_ID), "text": text[:1000]},
        timeout=10,
    )


def validate_telegram() -> None:
    me = telegram_call("getMe", timeout=10)
    user = me.get("result") if me else None
    if (
        not isinstance(user, dict)
        or user.get("id") != BOT_ID
        or user.get("is_bot") is not True
    ):
        raise SystemExit("Telegram getMe validation failed; check the relay credentials")
    webhook = telegram_call("getWebhookInfo", timeout=10)
    info = webhook.get("result") if webhook else None
    if not isinstance(info, dict):
        raise SystemExit("Telegram getWebhookInfo validation failed")
    if info.get("url"):
        raise SystemExit("Telegram bot has an active webhook; getUpdates is unavailable")


def normalize_reply(text: str) -> str:
    text = " ".join(text.replace("\x00", " ").split())
    return text.strip()


def parse_update(update: dict, now: int):
    message = update.get("message")
    if not isinstance(message, dict):
        return None, "ignored", None
    chat = message.get("chat")
    sender = message.get("from")
    if not isinstance(chat, dict) or not isinstance(sender, dict):
        return None, "unauthorized", None
    if (
        chat.get("type") != "private"
        or chat.get("id") != ADMIN_CHAT_ID
        or sender.get("id") != ADMIN_CHAT_ID
    ):
        return None, "unauthorized", None

    text = message.get("text")
    if not isinstance(text, str):
        return None, "invalid", "⚠ Responde con un mensaje de texto."
    if now - int(message.get("date") or 0) > UPDATE_MAX_AGE:
        return None, "expired", "⚠ Esa respuesta llegó demasiado tarde y no fue guardada."

    reply_to = message.get("reply_to_message")
    if not isinstance(reply_to, dict) or not isinstance(reply_to.get("text"), str):
        return None, "invalid", "⚠ Usa Responder sobre un aviso enviado por /gabo."
    reply_sender = reply_to.get("from")
    reply_chat = reply_to.get("chat")
    if (
        not isinstance(reply_sender, dict)
        or reply_sender.get("id") != BOT_ID
        or reply_sender.get("is_bot") is not True
        or not isinstance(reply_chat, dict)
        or reply_chat.get("id") != ADMIN_CHAT_ID
    ):
        return None, "invalid", "⚠ Ese mensaje no es un aviso válido de /gabo."

    original = reply_to["text"]
    if len(original.encode("utf-8")) > 4096:
        return None, "invalid", "⚠ El aviso original no es válido."
    markers = list(MARKER_RE.finditer(original))
    if len(markers) != 1:
        return None, "invalid", "⚠ No encontré una ruta válida. Responde sobre un aviso nuevo de /gabo."
    world_id, player_hex, request_id = markers[0].groups()
    try:
        player_bytes = bytes.fromhex(player_hex)
        player = player_bytes.decode("utf-8")
    except (ValueError, UnicodeDecodeError):
        return None, "invalid", "⚠ El destinatario del aviso no es válido."
    if not (1 <= len(player_bytes) <= MAX_PLAYER_BYTES) or any(ord(c) < 32 for c in player):
        return None, "invalid", "⚠ El destinatario del aviso no es válido."

    clean = normalize_reply(text)
    if not clean or len(clean) > MAX_REPLY_CHARS:
        return None, "invalid", f"⚠ La respuesta debe tener entre 1 y {MAX_REPLY_CHARS} caracteres."
    return {
        "world_id": world_id,
        "player": player,
        "request_id": request_id,
        "text": clean,
        "created_at": now,
        "expires_at": now + QUEUE_TTL,
    }, "queued", None


def process_update(update: object) -> str | None:
    if not isinstance(update, dict) or not isinstance(update.get("update_id"), int):
        return None
    update_id = update["update_id"]
    now = int(time.time())
    queued, outcome, warning = parse_update(update, now)
    with database() as conn:
        conn.execute("BEGIN IMMEDIATE")
        already = conn.execute(
            "SELECT 1 FROM processed_updates WHERE update_id = ?", (update_id,)
        ).fetchone()
        if not already:
            if queued:
                conn.execute(
                    """INSERT OR IGNORE INTO reply_queue
                       (update_id, world_id, player, request_id, text, created_at, expires_at)
                       VALUES (?, ?, ?, ?, ?, ?, ?)""",
                    (
                        update_id,
                        queued["world_id"],
                        queued["player"],
                        queued["request_id"],
                        queued["text"],
                        queued["created_at"],
                        queued["expires_at"],
                    ),
                )
            conn.execute(
                "INSERT INTO processed_updates(update_id, processed_at, outcome) VALUES (?, ?, ?)",
                (update_id, now, outcome),
            )
        # The offset advances in the same durable transaction as queue/dedup.
        current = conn.execute(
            "SELECT value FROM metadata WHERE key = 'telegram_offset'"
        ).fetchone()
        next_offset = max(int(current[0]) if current else 0, update_id + 1)
        conn.execute(
            """INSERT INTO metadata(key, value) VALUES ('telegram_offset', ?)
               ON CONFLICT(key) DO UPDATE SET value = excluded.value""",
            (str(next_offset),),
        )
    return warning if not already else None


def current_offset() -> int:
    with database() as conn:
        row = conn.execute(
            "SELECT value FROM metadata WHERE key = 'telegram_offset'"
        ).fetchone()
    return int(row[0]) if row else 0


def cleanup() -> None:
    now = int(time.time())
    with database() as conn:
        conn.execute("DELETE FROM reply_queue WHERE expires_at <= ?", (now,))
        conn.execute(
            "DELETE FROM processed_updates WHERE processed_at < ?",
            (now - 30 * 24 * 60 * 60,),
        )


def wait_with_heartbeat(seconds: int) -> None:
    global last_loop_heartbeat
    deadline = time.monotonic() + seconds
    while not stopping.is_set() and time.monotonic() < deadline:
        last_loop_heartbeat = time.monotonic()
        stopping.wait(min(20, max(0, deadline - time.monotonic())))


class RelayHandler(BaseHTTPRequestHandler):
    server_version = "wetlands-contact-relay/1"

    def log_message(self, _format: str, *_args) -> None:
        return

    def send_json(self, status: int, value: dict) -> None:
        body = json.dumps(value, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def target(self):
        parsed = urllib.parse.urlparse(self.path)
        query = urllib.parse.parse_qs(parsed.query, keep_blank_values=True)
        world_id = query.get("world_id", [""])[0]
        player = query.get("player", [""])[0]
        if world_id not in ALLOWED_WORLDS:
            return parsed.path, None, None
        supplied = self.headers.get("X-Wetlands-Relay-Key", "")
        if not hmac.compare_digest(supplied, relay_key(world_id)):
            return parsed.path, None, None
        encoded = player.encode("utf-8")
        if not (1 <= len(encoded) <= MAX_PLAYER_BYTES) or any(ord(c) < 32 for c in player):
            return parsed.path, None, None
        return parsed.path, world_id, player

    def do_GET(self) -> None:
        global last_loop_heartbeat
        if self.path == "/health":
            try:
                with database() as conn:
                    conn.execute("SELECT 1").fetchone()
                now = time.monotonic()
                loop_alive = now - last_loop_heartbeat < HEALTH_POLL_STALE
                polling_ok = (
                    last_successful_poll is not None
                    and now - last_successful_poll < HEALTH_POLL_STALE
                )
                startup_ok = (
                    last_successful_poll is None
                    and now - started_at < HEALTH_STARTUP_GRACE
                )
                alive = loop_alive and (polling_ok or startup_ok)
            except sqlite3.Error:
                alive = False
                polling_ok = False
            self.send_json(
                200 if alive else 503,
                {"ok": alive, "telegram_polling_ok": polling_ok},
            )
            return
        path, world_id, player = self.target()
        if path != "/v1/messages" or world_id is None:
            self.send_json(403, {"ok": False})
            return
        now = int(time.time())
        with database() as conn:
            rows = conn.execute(
                """SELECT update_id, world_id, player, request_id, text, created_at
                   FROM reply_queue
                   WHERE world_id = ? AND player = ? AND expires_at > ?
                   ORDER BY created_at, update_id LIMIT ?""",
                (world_id, player, now, API_LIMIT),
            ).fetchall()
        self.send_json(200, {"ok": True, "messages": [dict(row) for row in rows]})

    def do_POST(self) -> None:
        path, world_id, player = self.target()
        if path != "/v1/ack" or world_id is None:
            self.send_json(403, {"ok": False})
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            length = 0
        if not (1 <= length <= MAX_API_BODY):
            self.send_json(400, {"ok": False})
            return
        try:
            payload = json.loads(self.rfile.read(length).decode("utf-8"))
            raw_update_id = payload["update_id"]
            if not isinstance(raw_update_id, (str, int)) or isinstance(raw_update_id, bool):
                raise ValueError
            if not re.fullmatch(r"[0-9]+", str(raw_update_id)):
                raise ValueError
            update_id = int(raw_update_id)
        except (KeyError, TypeError, ValueError, UnicodeDecodeError, json.JSONDecodeError):
            self.send_json(400, {"ok": False})
            return
        with database() as conn:
            conn.execute(
                "DELETE FROM reply_queue WHERE update_id = ? AND world_id = ? AND player = ?",
                (update_id, world_id, player),
            )
        self.send_json(200, {"ok": True})


def poll_forever() -> None:
    global last_loop_heartbeat, last_successful_poll
    failures = 0
    last_cleanup = 0.0
    while not stopping.is_set():
        last_loop_heartbeat = time.monotonic()
        result = telegram_call(
            "getUpdates",
            {
                "timeout": str(POLL_TIMEOUT),
                "offset": str(current_offset()),
                "allowed_updates": '["message"]',
            },
            timeout=HTTP_TIMEOUT,
        )
        last_loop_heartbeat = time.monotonic()
        if result is None or not isinstance(result.get("result"), list):
            failures += 1
            wait = min(10 * (2 ** min(failures - 1, 5)), 300)
            if failures == 1 or wait == 300:
                print(
                    f"Telegram polling failed; retrying in {wait}s "
                    f"(consecutive failures: {failures})",
                    flush=True,
                )
            wait_with_heartbeat(wait)
            continue
        if failures:
            print("Telegram polling recovered", flush=True)
        failures = 0
        last_successful_poll = time.monotonic()
        for update in result["result"]:
            warning = process_update(update)
            if warning:
                notify_admin(warning)
        if time.monotonic() - last_cleanup > 3600:
            cleanup()
            last_cleanup = time.monotonic()
        wait_with_heartbeat(1)


def stop(_signum, _frame) -> None:
    stopping.set()


def main() -> None:
    initialize_database()
    validate_telegram()
    validate_bot_identity()
    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    server = ThreadingHTTPServer((HOST, PORT), RelayHandler)
    server.daemon_threads = True
    thread = threading.Thread(target=server.serve_forever, name="relay-http", daemon=True)
    thread.start()
    print("wetlands-contact-relay ready on :8788", flush=True)
    try:
        poll_forever()
    finally:
        server.shutdown()
        server.server_close()


if __name__ == "__main__":
    main()
