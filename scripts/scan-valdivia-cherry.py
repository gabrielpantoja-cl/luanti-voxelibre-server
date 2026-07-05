#!/usr/bin/env python3
"""
Scan Valdivia map.sqlite for any node name containing "cherry".
Read-only: does NOT modify the database. Used to confirm the exact
(mis)mapped cherry node name before applying a targeted remap.
"""
import sqlite3, sys, re
import zstandard as zstd


def names_in_block(data):
    if len(data) < 2:
        return []
    try:
        dctx = zstd.ZstdDecompressor()
        decompressed = dctx.decompress(data[1:], max_output_size=2_000_000)
    except Exception:
        return []
    if b"cherry" not in decompressed:
        return []
    # Node names look like "modname:itemname" — pull ascii runs that contain cherry
    found = []
    for m in re.finditer(rb"[a-zA-Z0-9_]+:[a-zA-Z0-9_]+", decompressed):
        if b"cherry" in m.group(0):
            found.append(m.group(0))
    return found


def main():
    db_path = sys.argv[1] if len(sys.argv) > 1 else "map.sqlite"
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute("SELECT data FROM blocks")
    counts = {}
    n = 0
    for (data,) in cur:
        n += 1
        for name in names_in_block(data):
            counts[name] = counts.get(name, 0) + 1
        if n % 200000 == 0:
            print(f"  scanned {n} blocks...", flush=True)
    conn.close()
    print(f"Scanned {n} mapblocks. Cherry node names found:")
    for name, c in sorted(counts.items(), key=lambda kv: -kv[1]):
        print(f"  {name.decode()}  (in {c} mapblocks)")


if __name__ == "__main__":
    main()
