#!/usr/bin/env python3
"""
Targeted fix for Valdivia: remap the single mis-named cherry leaves node.

Arnis wrote cherry foliage as `mcl_cherry_blossom:leaves`, which is NOT a
registered VoxeLibre node (the correct name is `mcl_cherry_blossom:cherryleaves`),
so it renders with the "unknown/no texture" placeholder. This rewrites only that
one node name inside each v29 mapblock's name-id mapping table.

Same in-place, length-prefixed byte-replacement technique as
remap-mineclonia-to-voxelibre.py — scoped to this one entry only.

Stop the Valdivia container before running (sqlite must not be live).
"""
import sqlite3, struct, sys, os, shutil
import zstandard as zstd

REMAP = [
    (b"mcl_cherry_blossom:leaves", b"mcl_cherry_blossom:cherryleaves"),
]


def remap_mapblock(data):
    if len(data) < 2:
        return data, False
    version = data[0]
    compressed = data[1:]
    try:
        dctx = zstd.ZstdDecompressor()
        decompressed = bytearray(dctx.decompress(compressed, max_output_size=2_000_000))
    except Exception:
        return data, False
    changed = False
    for old_name, new_name in REMAP:
        old_prefixed = struct.pack(">H", len(old_name)) + old_name
        new_prefixed = struct.pack(">H", len(new_name)) + new_name
        pos = 0
        while True:
            idx = decompressed.find(old_prefixed, pos)
            if idx == -1:
                break
            decompressed[idx:idx + len(old_prefixed)] = new_prefixed
            pos = idx + len(new_prefixed)
            changed = True
    if not changed:
        return data, False
    cctx = zstd.ZstdCompressor()
    recompressed = cctx.compress(bytes(decompressed))
    return bytes([version]) + recompressed, True


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 fix-valdivia-cherry-leaves.py <path-to-map.sqlite>")
        sys.exit(1)
    db_path = sys.argv[1]
    if not os.path.exists(db_path):
        print(f"Error: {db_path} not found")
        sys.exit(1)

    backup_path = db_path + ".backup-before-cherry-fix"
    if not os.path.exists(backup_path):
        print(f"Backing up to {backup_path}...", flush=True)
        shutil.copy2(db_path, backup_path)
        print("Backup done.", flush=True)

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT pos, data FROM blocks")
    rows = cursor.fetchall()
    total = len(rows)
    print(f"Total mapblocks: {total}", flush=True)

    remapped = 0
    for i, (pos, data) in enumerate(rows):
        new_data, changed = remap_mapblock(data)
        if changed:
            cursor.execute("UPDATE blocks SET data = ? WHERE pos = ?", (new_data, pos))
            remapped += 1
        if (i + 1) % 200000 == 0:
            print(f"  Progreso: {i+1}/{total} ({remapped} remapeados)", flush=True)

    conn.commit()
    conn.close()
    print(f"Fix cherry leaves completo: {remapped}/{total} mapblocks modificados")


if __name__ == "__main__":
    main()
