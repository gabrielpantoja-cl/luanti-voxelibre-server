#!/usr/bin/env python3
"""Simulador de Telegram y Discord para probar wetlands_contact en local.

Imita las dos APIs a las que /gabo envia mensajes, sin salir a internet:
  - Telegram: POST /bot<token>/sendMessage  {"chat_id", "text", ...} -> 200 {"ok": true}
  - Discord:  POST /api/webhooks/<id>/<token> {"content", "allowed_mentions", ...} -> 204

Uso:
    python scripts/mock-contact-bridge.py --token prueba-local
    python scripts/mock-contact-bridge.py --token prueba-local --fail 403   # bot bloqueado
    python scripts/mock-contact-bridge.py --token prueba-local --delay 15   # fuerza timeout

server/worlds/original/wetlands_contact.conf para Telegram simulado:
    telegram_api = http://host.docker.internal:8787
    telegram_token = prueba-local
    telegram_chat_id = 12345

...o para Discord simulado:
    destination = discord
    discord_webhook = http://host.docker.internal:8787/api/webhooks/1/prueba-local
"""
import argparse
import json
import re
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

TELEGRAM = re.compile(r"^/bot(?P<token>[^/]+)/sendMessage$")
DISCORD = re.compile(r"^/api/webhooks/\d+/(?P<token>[^/]+)$")
DISCORD_MAX = 2000
TELEGRAM_MAX = 4096


def make_handler(args):
    class Handler(BaseHTTPRequestHandler):
        def reply(self, code, body=None):
            data = json.dumps(body).encode() if body is not None else b""
            self.send_response(code)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

        def do_POST(self):
            tg, dc = TELEGRAM.match(self.path), DISCORD.match(self.path)
            match = tg or dc
            if not match:
                return self.reply(404, {"ok": False, "description": "Not Found"})
            if match["token"] != args.token:
                return self.reply(401, {"ok": False, "description": "Unauthorized"})
            length = int(self.headers.get("Content-Length") or 0)
            try:
                payload = json.loads(self.rfile.read(length))
            except (ValueError, UnicodeDecodeError):
                return self.reply(400, {"ok": False, "description": "invalid JSON"})

            if tg:
                text = payload.get("text")
                if not payload.get("chat_id") or not isinstance(text, str) \
                        or not 0 < len(text) <= TELEGRAM_MAX:
                    return self.reply(400, {"ok": False, "description": "Bad Request"})
                if "parse_mode" in payload:
                    return self.reply(400, {"ok": False, "description": "parse_mode no esperado"})
            else:
                text = payload.get("content")
                if not isinstance(text, str) or not 0 < len(text) <= DISCORD_MAX:
                    return self.reply(400, {"message": "Invalid Form Body"})
                if payload.get("allowed_mentions") != {"parse": []}:
                    return self.reply(400, {"message": "allowed_mentions debe ser {parse: []}"})

            if args.delay:
                time.sleep(args.delay)
            if args.fail:
                print(f"-> simulando fallo {args.fail}")
                return self.reply(args.fail, {"ok": False, "description": "simulated"})

            print(f"\n[{'Telegram' if tg else 'Discord'}]\n{text}")
            if tg:
                return self.reply(200, {"ok": True, "result": {"message_id": 1}})
            return self.reply(204)

        def log_message(self, fmt, *a):
            # La ruta lleva el token: no se imprime, igual que en produccion.
            print("[mock] " + (fmt % a).replace(args.token, "<token>"))

    return Handler


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--token", required=True, help="token esperado en la URL")
    p.add_argument("--host", default="0.0.0.0")
    p.add_argument("--port", type=int, default=8787)
    p.add_argument("--fail", type=int, default=0, help="responder siempre con este codigo HTTP")
    p.add_argument("--delay", type=float, default=0, help="segundos de espera antes de responder")
    args = p.parse_args()
    print(f"Simulador Telegram/Discord en http://{args.host}:{args.port}")
    ThreadingHTTPServer((args.host, args.port), make_handler(args)).serve_forever()


if __name__ == "__main__":
    main()
