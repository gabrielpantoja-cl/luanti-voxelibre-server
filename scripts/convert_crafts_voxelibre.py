#!/usr/bin/env python3
"""
Convert automobiles_pck crafting recipes to VoxeLibre compatibility
Wetlands Luanti Server - VoxeLibre Adaptation Script
"""

import os
import re
from pathlib import Path

MODPACK_PATH = Path("/home/gabriel/Documentos/luanti-voxelibre-server/server/mods/automobiles_pck")

# Item name conversions from Minetest vanilla to VoxeLibre
ITEM_CONVERSIONS = {
    'default:steel_ingot': 'mcl_core:iron_ingot',
    'default:steelblock': 'mcl_core:ironblock',
    'default:tin_ingot': 'mcl_core:iron_ingot',
    'default:glass': 'mcl_core:glass',
    'default:mese_block': 'mcl_core:diamondblock',
    'default:diamond': 'mcl_core:diamond',
    'default:goldblock': 'mcl_core:goldblock',
    'default:gold_ingot': 'mcl_core:gold_ingot',
    'default:obsidian': 'mcl_core:obsidian',
    'wool:white': 'mcl_wool:white',
    'wool:black': 'mcl_wool:black',
    'wool:red': 'mcl_wool:red',
    'wool:blue': 'mcl_wool:blue',
}

def convert_recipe_line(line):
    """Convert a recipe line from default to VoxeLibre items"""
    converted = line
    for old_item, new_item in ITEM_CONVERSIONS.items():
        converted = converted.replace(f'"{old_item}"', f'"{new_item}"')
        converted = converted.replace(f"'{old_item}'", f"'{new_item}'")
    return converted

def add_voxelibre_recipes(file_path):
    """Add VoxeLibre recipes to a craft file"""

    # Check if already converted
    with open(file_path, 'r') as f:
        content = f.read()

    if 'VoxeLibre/MineClone2 recipes' in content:
        print(f"✅ Already converted: {file_path.name}")
        return False

    # Backup original
    backup_path = file_path.with_suffix('.lua.backup')
    with open(backup_path, 'w') as f:
        f.write(content)

    # Extract the default crafting block
    pattern = r'(if minetest\.get_modpath\("default"\) then\s*\n)(.*?)(^end\s*$)'
    match = re.search(pattern, content, re.MULTILINE | re.DOTALL)

    if not match:
        print(f"⚠️  No default recipes found in: {file_path.name}")
        return False

    default_recipes = match.group(2)

    # Convert recipes
    voxelibre_recipes = convert_recipe_line(default_recipes)

    # Create VoxeLibre block
    voxelibre_block = f"""
-- VoxeLibre/MineClone2 recipes (Wetlands Server)
if automobiles_lib.is_mcl then
{voxelibre_recipes}end
"""

    # Replace in content
    new_content = content.replace(
        match.group(1),
        "-- Minetest vanilla recipes\n" + match.group(1)
    )
    new_content = new_content.replace(
        match.group(0),
        match.group(0) + voxelibre_block
    )

    # Write back
    with open(file_path, 'w') as f:
        f.write(new_content)

    print(f"✅ Converted: {file_path.name}")
    return True

def main():
    print("🔧 Converting automobiles_pck recipes to VoxeLibre...\n")

    # Find all craft files
    craft_files = list(MODPACK_PATH.glob("**/*craft*.lua"))

    converted_count = 0
    for file_path in craft_files:
        if add_voxelibre_recipes(file_path):
            converted_count += 1

    print(f"\n✅ Conversion complete! Converted {converted_count} files.")
    print("📋 Backups created with .backup extension")
    print("\n🧪 Next steps:")
    print("   1. Review changes: git diff")
    print("   2. Test locally: docker-compose restart luanti-server")
    print("   3. Verify in-game crafting recipes work")

if __name__ == "__main__":
    main()
