#!/usr/bin/env python3
"""
Incremental remap for Valdivia: only the stair/plank patterns added in v2.
"""
import sqlite3, struct, sys, os, shutil, zstandard as zstd

NEW_REMAP = [
    # Planks (Mineclonia mcl_core:planks_* -> VoxeLibre mcl_core:*wood)
    (b"mcl_core:planks_oak", b"mcl_core:wood"),
    (b"mcl_core:planks_birch", b"mcl_core:birchwood"),
    (b"mcl_core:planks_spruce", b"mcl_core:sprucewood"),
    (b"mcl_core:planks_jungle", b"mcl_core:junglewood"),
    (b"mcl_core:planks_acacia", b"mcl_core:acaciawood"),
    (b"mcl_core:planks_dark_oak", b"mcl_core:darkwood"),
    # Arnis mcl_core:planks_* with arnis prefix
    (b"mcl_core:wood_planks_oak", b"mcl_core:wood"),
    (b"mcl_core:wood_planks_birch", b"mcl_core:birchwood"),
    (b"mcl_core:wood_planks_spruce", b"mcl_core:sprucewood"),
    (b"mcl_core:wood_planks_jungle", b"mcl_core:junglewood"),
    (b"mcl_core:wood_planks_acacia", b"mcl_core:acaciawood"),
    (b"mcl_core:wood_planks_dark_oak", b"mcl_core:darkwood"),
    # Wood stairs (Mineclonia naming: stair_oak -> stair_wood)
    (b"mcl_stairs:stair_oak", b"mcl_stairs:stair_wood"),
    (b"mcl_stairs:stair_oak_inner", b"mcl_stairs:stair_wood_inner"),
    (b"mcl_stairs:stair_oak_outer", b"mcl_stairs:stair_wood_outer"),
    (b"mcl_stairs:slab_oak", b"mcl_stairs:slab_wood"),
    (b"mcl_stairs:slab_oak_top", b"mcl_stairs:slab_wood_top"),
    (b"mcl_stairs:slab_oak_double", b"mcl_stairs:slab_wood_double"),
    (b"mcl_stairs:stair_birch", b"mcl_stairs:stair_birchwood"),
    (b"mcl_stairs:stair_birch_inner", b"mcl_stairs:stair_birchwood_inner"),
    (b"mcl_stairs:stair_birch_outer", b"mcl_stairs:stair_birchwood_outer"),
    (b"mcl_stairs:slab_birch", b"mcl_stairs:slab_birchwood"),
    (b"mcl_stairs:slab_birch_top", b"mcl_stairs:slab_birchwood_top"),
    (b"mcl_stairs:slab_birch_double", b"mcl_stairs:slab_birchwood_double"),
    (b"mcl_stairs:stair_spruce", b"mcl_stairs:stair_sprucewood"),
    (b"mcl_stairs:stair_spruce_inner", b"mcl_stairs:stair_sprucewood_inner"),
    (b"mcl_stairs:stair_spruce_outer", b"mcl_stairs:stair_sprucewood_outer"),
    (b"mcl_stairs:slab_spruce", b"mcl_stairs:slab_sprucewood"),
    (b"mcl_stairs:slab_spruce_top", b"mcl_stairs:slab_sprucewood_top"),
    (b"mcl_stairs:slab_spruce_double", b"mcl_stairs:slab_sprucewood_double"),
    (b"mcl_stairs:stair_jungle", b"mcl_stairs:stair_junglewood"),
    (b"mcl_stairs:stair_jungle_inner", b"mcl_stairs:stair_junglewood_inner"),
    (b"mcl_stairs:stair_jungle_outer", b"mcl_stairs:stair_junglewood_outer"),
    (b"mcl_stairs:slab_jungle", b"mcl_stairs:slab_junglewood"),
    (b"mcl_stairs:slab_jungle_top", b"mcl_stairs:slab_junglewood_top"),
    (b"mcl_stairs:slab_jungle_double", b"mcl_stairs:slab_junglewood_double"),
    (b"mcl_stairs:stair_acacia", b"mcl_stairs:stair_acaciawood"),
    (b"mcl_stairs:stair_acacia_inner", b"mcl_stairs:stair_acaciawood_inner"),
    (b"mcl_stairs:stair_acacia_outer", b"mcl_stairs:stair_acaciawood_outer"),
    (b"mcl_stairs:slab_acacia", b"mcl_stairs:slab_acaciawood"),
    (b"mcl_stairs:slab_acacia_top", b"mcl_stairs:slab_acaciawood_top"),
    (b"mcl_stairs:slab_acacia_double", b"mcl_stairs:slab_acaciawood_double"),
    (b"mcl_stairs:stair_dark_oak", b"mcl_stairs:stair_darkwood"),
    (b"mcl_stairs:stair_dark_oak_inner", b"mcl_stairs:stair_darkwood_inner"),
    (b"mcl_stairs:stair_dark_oak_outer", b"mcl_stairs:stair_darkwood_outer"),
    (b"mcl_stairs:slab_dark_oak", b"mcl_stairs:slab_darkwood"),
    (b"mcl_stairs:slab_dark_oak_top", b"mcl_stairs:slab_darkwood_top"),
    (b"mcl_stairs:slab_dark_oak_double", b"mcl_stairs:slab_darkwood_double"),
    # Cobblestone stairs (Mineclonia uses stair_cobblestone, VoxeLibre uses stair_cobble)
    (b"mcl_stairs:stair_cobblestone", b"mcl_stairs:stair_cobble"),
    (b"mcl_stairs:stair_cobblestone_inner", b"mcl_stairs:stair_cobble_inner"),
    (b"mcl_stairs:stair_cobblestone_outer", b"mcl_stairs:stair_cobble_outer"),
    (b"mcl_stairs:slab_cobblestone", b"mcl_stairs:slab_cobble"),
    (b"mcl_stairs:slab_cobblestone_top", b"mcl_stairs:slab_cobble_top"),
    (b"mcl_stairs:slab_cobblestone_double", b"mcl_stairs:slab_cobble_double"),
    # Stone brick stairs (Mineclonia uses stair_stone_brick)
    (b"mcl_stairs:stair_stone_brick", b"mcl_stairs:stair_stonebrick"),
    (b"mcl_stairs:stair_stone_brick_inner", b"mcl_stairs:stair_stonebrick_inner"),
    (b"mcl_stairs:stair_stone_brick_outer", b"mcl_stairs:stair_stonebrick_outer"),
    (b"mcl_stairs:slab_stone_brick", b"mcl_stairs:slab_stonebrick"),
    (b"mcl_stairs:slab_stone_brick_top", b"mcl_stairs:slab_stonebrick_top"),
    (b"mcl_stairs:slab_stone_brick_double", b"mcl_stairs:slab_stonebrick_double"),
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
    for old_name, new_name in NEW_REMAP:
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
        print("Usage: python3 remap-incremental-valdivia.py <path-to-map.sqlite>")
        sys.exit(1)
    db_path = sys.argv[1]
    if not os.path.exists(db_path):
        print(f"Error: {db_path} not found")
        sys.exit(1)
    backup_path = db_path + ".backup-before-v2"
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
        if (i + 1) % 100000 == 0:
            print(f"  Progreso: {i+1}/{total} ({remapped} remapeados)", flush=True)
    conn.commit()
    conn.close()
    print(f"Remapeo incremental completo: {remapped}/{total} mapblocks modificados")

if __name__ == "__main__":
    main()
