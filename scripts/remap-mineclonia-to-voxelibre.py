#!/usr/bin/env python3
"""
Remap Mineclonia node names to VoxeLibre node names in map.sqlite.

Luanti mapblock format v29: first byte is version (0x1d=29),
then zstd-compressed data containing node IDs and a name-id mapping table.
"""

import sqlite3
import struct
import sys
import os
import shutil
import zstandard as zstd

# Mineclonia -> VoxeLibre node name mapping
REMAP = {
    b"mcl_trees:tree_oak": b"mcl_core:tree",
    b"mcl_trees:tree_birch": b"mcl_core:birchtree",
    b"mcl_trees:tree_spruce": b"mcl_core:sprucetree",
    b"mcl_trees:tree_jungle": b"mcl_core:jungletree",
    b"mcl_trees:tree_acacia": b"mcl_core:acaciatree",
    b"mcl_trees:tree_dark_oak": b"mcl_core:darktree",
    b"mcl_trees:leaves_oak": b"mcl_core:leaves",
    b"mcl_trees:leaves_birch": b"mcl_core:birchleaves",
    b"mcl_trees:leaves_spruce": b"mcl_core:spruceleaves",
    b"mcl_trees:leaves_jungle": b"mcl_core:jungleleaves",
    b"mcl_trees:leaves_acacia": b"mcl_core:acacialeaves",
    b"mcl_trees:leaves_dark_oak": b"mcl_core:darkleaves",
    b"mcl_trees:wood_oak": b"mcl_core:wood",
    b"mcl_trees:wood_birch": b"mcl_core:birchwood",
    b"mcl_trees:wood_spruce": b"mcl_core:sprucewood",
    b"mcl_trees:wood_jungle": b"mcl_core:junglewood",
    b"mcl_trees:wood_acacia": b"mcl_core:acaciawood",
    b"mcl_trees:wood_dark_oak": b"mcl_core:darkwood",
    # Bamboo scaffolding -> oak planks (no equivalent in VoxeLibre)
    b"mcl_bamboo:scaffolding": b"mcl_core:wood",
    # Chain (Arnis uses mcl_core:chain, VoxeLibre uses mcl_lanterns:chain)
    b"mcl_core:chain": b"mcl_lanterns:chain",
    # Redstone block (Arnis uses mcl_core:redstone_block, VoxeLibre uses mesecons_torch:redstoneblock)
    b"mcl_core:redstone_block": b"mesecons_torch:redstoneblock",
}


def remap_mapblock(data):
    """Remap node names inside a v29 mapblock."""
    if len(data) < 2:
        return data, False

    version = data[0]  # 0x1d = 29
    compressed = data[1:]

    try:
        dctx = zstd.ZstdDecompressor()
        decompressed = bytearray(dctx.decompress(compressed, max_output_size=2_000_000))
    except Exception:
        return data, False

    changed = False
    for old_name, new_name in REMAP.items():
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
        print("Usage: python3 remap-mineclonia-to-voxelibre.py <path-to-map.sqlite>")
        sys.exit(1)

    db_path = sys.argv[1]
    if not os.path.exists(db_path):
        print(f"Error: {db_path} not found")
        sys.exit(1)

    backup_path = db_path + ".backup-before-remap"
    if not os.path.exists(backup_path):
        shutil.copy2(db_path, backup_path)
        print(f"Backup: {backup_path}")

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT pos, data FROM blocks")
    rows = cursor.fetchall()
    print(f"Total mapblocks: {len(rows)}")

    remapped = 0
    for pos, data in rows:
        new_data, changed = remap_mapblock(data)
        if changed:
            cursor.execute("UPDATE blocks SET data = ? WHERE pos = ?", (new_data, pos))
            remapped += 1

    conn.commit()
    conn.close()
    print(f"Remapped: {remapped}/{len(rows)} mapblocks")


if __name__ == "__main__":
    main()
