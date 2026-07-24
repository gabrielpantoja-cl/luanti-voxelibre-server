#!/usr/bin/env python3
"""
remap_schematics.py - Remap Minetest Game node names to VoxeLibre in .mts schematics

Schematics from the Sokomine/mg_villages era (or any other minetest_game-based
mod) use node names like `default:wood`, `stairs:slab_cobble`, `doors:door_wood_a`.
The Wetlands server runs VoxeLibre, which uses `mcl_core:wood`, `mcl_stairs:*`,
`mcl_doors:*`, etc. This script rewrites the name lookup table in the .mts file
so schematics paste correctly in Wetlands.

The .mts file format (v3+):

    [0-3]   magic "MTSM"
    [4-5]   version (u16 BE)
    [6-7]   X size (u16)
    [8-9]   Y size (u16)
    [10-11] Z size (u16)
    [12-?]  v4 metadata (variable, usually 8-30 bytes of padding)
    [?-?]   num_names (u16)
    [?-?]   for each name: name_len (u16) + name bytes
    [?-?]   content_size (u16) + zlib-compressed node data

The compressed data references names by index, so we just rewrite the names
table and keep the data block intact.

Usage:
    python scripts/remap_schematics.py file.mts [file2.mts ...]
    python scripts/remap_schematics.py --dry-run file.mts
    python scripts/remap_schematics.py --backup file.mts
    python scripts/remap_schematics.py --quiet file.mts
"""
import argparse
import re
import shutil
import struct
import sys
from pathlib import Path

# air is a builtin name that doesn't need remapping
AIR = "air"

# Remap table: Minetest Game / common mods -> VoxeLibre
# - default:* -> mcl_core:*
# - stairs:* -> mcl_stairs:*
# - doors:*  -> mcl_doors:*
# - beds:*   -> mcl_beds:*
# - cottages:* / vessels:* / mg_villages:* -> closest mcl_core / air
REMAP = {
    # default: -> mcl_core:  (most are direct, some are voxelibre-specific names)
    "default:wood":               "mcl_core:wood",
    "default:stone":              "mcl_core:stone",
    "default:cobble":             "mcl_core:cobble",
    "default:dirt":               "mcl_core:dirt",
    "default:dirt_with_grass":    "mcl_core:dirt_with_grass",
    "default:gravel":             "mcl_core:gravel",
    "default:sandstone":          "mcl_core:sandstone",
    "default:glass":              "mcl_core:glass",
    "default:furnace":            "mcl_core:furnace",
    "default:chest":              "mcl_core:chest",
    "default:bookshelf":          "mcl_core:bookshelf",
    "default:torch_wall":         "mcl_core:torch",
    "default:tree":               "mcl_core:tree",
    "default:leaves":             "mcl_core:leaves",
    "default:fence_wood":         "mcl_core:fence_wood",
    "default:ladder_steel":       "mcl_core:ladder_iron",   # no steel in VoxeLibre
    "default:ladder_wood":        "mcl_core:ladder_wood",
    "default:brick":              "mcl_core:brick",
    "default:stonebrick":         "mcl_core:stonebrick",
    "default:river_water_source": "mcl_core:water_source",
    "default:river_water_flowing":"mcl_core:water_flowing",
    "default:mossycobble":        "mcl_core:mossycobble",
    "default:ice":                "mcl_core:ice",
    # typos / variants found in mg_villages schems (the 'x' suffix is noise
    # in the original file; both with and without the trailing x appear depending
    # on which schematic you're parsing)
    "default:applex":             "mcl_core:dirt",          # 'x' trailing typo from mg_villages
    "default:apple":              "mcl_core:dirt",          # shorter variant (typo without x)
    "default:bookshelfx":         "mcl_core:bookshelf",     # x suffix = typo
    "default:bookshelf":          "mcl_core:bookshelf",     # without x (canonical name)
    "default:furnacex":           "mcl_core:furnace",       # x suffix = typo
    "default:furnace":            "mcl_core:furnace",       # canonical

    # stairs: -> mcl_stairs:
    "stairs:slab_cobble":         "mcl_stairs:slab_cobble",
    "stairs:stair_cobble":        "mcl_stairs:stair_cobble",
    "stairs:slab_stone":          "mcl_stairs:slab_stone",
    "stairs:stair_wood":          "mcl_stairs:stair_wood",
    "stairs:slab_junglewood":     "mcl_stairs:slab_junglewood",
    "stairs:slab_wood":           "mcl_stairs:slab_wood",
    "stairs:stair_mossycobble":   "mcl_stairs:stair_cobble",  # no mossycobble stairs
    "stairs:slab_mossycobble":    "mcl_stairs:slab_cobble",
    "stairs:stair_stonebrick":    "mcl_stairs:stair_stonebrick",
    "stairs:stair_brick":         "mcl_stairs:stair_brick",

    # doors: -> mcl_doors:
    "doors:door_wood_b":          "mcl_doors:door_wood_b",
    "doors:hidden":               "mcl_doors:hidden",
    "doors:trapdoor":             "mcl_doors:trapdoor",
    "doors:door_wood_a":          "mcl_doors:door_wood_a",

    # beds: -> mcl_beds:
    "beds:bed_bottom":            "mcl_beds:bed_bottom",
    "beds:bed_top":               "mcl_beds:bed_top",

    # cottages: (mod NOT loaded in Wetlands) -> best-effort mcl_core approximations
    "cottages:shelf":             "mcl_core:bookshelf",
    "cottages:glass_pane":        "mcl_core:glass",
    "cottages:roof_connector_straw": "mcl_stairs:slab_wood",
    "cottages:bench":             AIR,                       # no bench in VoxeLibre
    "cottages:table":             AIR,                       # no table
    "cottages:bed_head":          "mcl_beds:bed_top",
    "cottages:bed_foot":          "mcl_beds:bed_bottom",
    "cottages:roof_straw":        "mcl_stairs:slab_wood",
    "cottages:roof_flat_straw":   "mcl_stairs:slab_wood",
    "cottages:hatch_wood":        "mcl_doors:trapdoor",
    "cottages:fence_small":       "mcl_core:fence_wood",
    "cottages:fence_corner":      "mcl_core:fence_wood",
    "cottages:hatch_steel":       "mcl_doors:trapdoor_iron",  # approximation
    "cottages:wood_flat":         "mcl_core:wood",
    "cottages:barrel_lying":      AIR,                       # no barrel
    "cottages:barrel":            AIR,

    # vessels: (mod NOT loaded) -> air
    "vessels:glass_bottle":       AIR,
    "vessels:drinking_glass":     AIR,
    "vessels:shelf":              AIR,

    # mg_villages: (mod NOT loaded) -> air
    "mg_villages:mob_workplace_marker": AIR,
}


def find_header_end(data):
    """Find offset where num_names starts. v4 has 9-30 bytes of metadata between
    the 12-byte fixed header and num_names. Metadata length can be odd or even,
    so we step by 1, not 2. Detect by trial: walk forward looking for a u16
    (num_names) followed by a u16 (name_len) followed by printable ASCII that
    looks like a node name (contains ':' or is 'air')."""
    for off in range(12, 80):
        if off + 4 > len(data):
            return None
        nn = struct.unpack('>H', data[off:off + 2])[0]
        if 1 < nn < 200:
            nl = struct.unpack('>H', data[off + 2:off + 4])[0]
            if 1 < nl < 50:
                end = off + 4 + nl
                if end > len(data):
                    continue
                candidate = data[off + 4:end]
                if all(0x20 <= b < 0x7f for b in candidate):
                    if candidate == b'air' or b':' in candidate:
                        return off
    return None


def parse_schematic(data):
    """Parse a .mts v3/v4 file. Returns dict with header pieces, names list, and
    the compressed content block."""
    if data[0:4] != b'MTSM':
        raise ValueError("not a .mts file (bad magic)")
    ver = struct.unpack('>H', data[4:6])[0]
    if ver < 3:
        raise ValueError(f"unsupported .mts version {ver} (need >=3)")
    sx, sy, sz = struct.unpack('>HHH', data[6:12])

    num_names_off = find_header_end(data)
    if num_names_off is None:
        raise ValueError("could not locate num_names in header (corrupt or unknown layout)")

    num_names = struct.unpack('>H', data[num_names_off:num_names_off + 2])[0]

    # v4 metadata between sizes and num_names (preserved as-is)
    header_pre_names = data[12:num_names_off]

    # Walk the names list forward from the first name length prefix
    pos = num_names_off + 2
    names = []
    for i in range(num_names):
        if pos + 2 > len(data):
            raise ValueError(f"unexpected end of file at name {i}")
        name_len = struct.unpack('>H', data[pos:pos + 2])[0]
        pos += 2
        if pos + name_len > len(data):
            raise ValueError(f"unexpected end of file in name {i}")
        name = data[pos:pos + name_len].decode('latin-1')
        pos += name_len
        names.append(name)

    # NOTE: .mts v3/v4 has NO content_size field between names and zlib data.
    # The zlib-compressed content runs to EOF.
    content = data[pos:]

    return {
        'magic': data[0:4],
        'ver': ver,
        'sx': sx, 'sy': sy, 'sz': sz,
        'header_pre_names': header_pre_names,
        'names': names,
        'content': content,
    }


def build_schematic(parsed):
    """Rebuild .mts binary from parsed components."""
    out = bytearray()
    out.extend(parsed['magic'])
    out.extend(struct.pack('>H', parsed['ver']))
    out.extend(struct.pack('>HHH', parsed['sx'], parsed['sy'], parsed['sz']))
    out.extend(parsed['header_pre_names'])
    out.extend(struct.pack('>H', len(parsed['names'])))
    for name in parsed['names']:
        nb = name.encode('latin-1')
        out.extend(struct.pack('>H', len(nb)))
        out.extend(nb)
    out.extend(parsed['content'])
    return bytes(out)


def remap_file(filepath, dry_run=False, backup=False, quiet=False):
    """Remap node names in a .mts file. Returns list of (old, new) tuples."""
    data = Path(filepath).read_bytes()
    parsed = parse_schematic(data)

    new_names = []
    changes = []
    for old in parsed['names']:
        new = REMAP.get(old, old)
        new_names.append(new)
        if new != old:
            changes.append((old, new))

    if not quiet:
        print(f"\n=== {filepath} ===")
        print(f"  size: {parsed['sx']}x{parsed['sy']}x{parsed['sz']}, "
              f"{len(parsed['names'])} unique nodes")
        if changes:
            for old, new in changes:
                print(f"  {old:40s} -> {new}")
        else:
            print("  no remaps needed")

    if dry_run:
        return changes

    if backup:
        shutil.copy2(filepath, str(filepath) + ".bak")

    parsed['names'] = new_names
    new_data = build_schematic(parsed)
    Path(filepath).write_bytes(new_data)
    return changes


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('files', nargs='+', help=".mts files to remap")
    ap.add_argument('--dry-run', action='store_true',
                    help="show changes without modifying files")
    ap.add_argument('--backup', action='store_true',
                    help="save a .bak copy before overwriting")
    ap.add_argument('--quiet', action='store_true',
                    help="suppress per-file header (only print errors)")
    args = ap.parse_args()

    total_changes = 0
    for f in args.files:
        try:
            changes = remap_file(f, dry_run=args.dry_run,
                                 backup=args.backup, quiet=args.quiet)
            total_changes += len(changes)
        except Exception as e:
            print(f"ERROR processing {f}: {e}", file=sys.stderr)
            sys.exit(1)

    if not args.quiet:
        print(f"\n=== Total: {total_changes} node(s) remapped across "
              f"{len(args.files)} file(s) ===")


if __name__ == '__main__':
    main()
