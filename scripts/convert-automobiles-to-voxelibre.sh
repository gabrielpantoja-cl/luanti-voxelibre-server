#!/bin/bash

# Script to convert automobiles_pck crafting recipes to VoxeLibre compatibility
# Created for Wetlands Luanti Server - VoxeLibre adaptation

MODPACK_PATH="/home/gabriel/Documentos/luanti-voxelibre-server/server/mods/automobiles_pck"

echo "🔧 Converting automobiles_pck recipes to VoxeLibre..."
echo ""

# Function to add VoxeLibre recipes to a craft file
add_voxelibre_recipes() {
    local file="$1"

    # Check if already converted
    if grep -q "VoxeLibre/MineClone2 recipes" "$file"; then
        echo "✅ Already converted: $(basename $file)"
        return
    fi

    # Backup original
    cp "$file" "${file}.backup"

    # Create temp file with VoxeLibre recipes
    awk '
    /^if minetest\.get_modpath\("default"\) then/ {
        print "-- Minetest vanilla recipes"
        print
        next
    }
    /^end$/ && in_default_block {
        print
        print ""
        print "-- VoxeLibre/MineClone2 recipes (Wetlands Server)"
        print "if automobiles_lib.is_mcl then"
        # Print converted recipes
        for (i in recipes) {
            line = recipes[i]
            # Convert default: to mcl_core:
            gsub(/default:steel_ingot/, "mcl_core:iron_ingot", line)
            gsub(/default:steelblock/, "mcl_core:ironblock", line)
            gsub(/default:tin_ingot/, "mcl_core:iron_ingot", line)
            gsub(/default:glass/, "mcl_core:glass", line)
            gsub(/default:mese_block/, "mcl_core:diamondblock", line)
            gsub(/wool:/, "mcl_wool:", line)
            gsub(/default:diamond/, "mcl_core:diamond", line)
            gsub(/default:goldblock/, "mcl_core:goldblock", line)
            print line
        }
        print "end"
        delete recipes
        in_default_block = 0
        next
    }
    in_default_block {
        recipes[length(recipes)] = $0
        print
        next
    }
    /^if minetest\.get_modpath\("default"\) then/ { in_default_block = 1 }
    { print }
    ' "$file" > "${file}.tmp"

    mv "${file}.tmp" "$file"
    echo "✅ Converted: $(basename $file)"
}

# Convert all craft files
echo "📦 Processing craft files..."
find "$MODPACK_PATH" -name "*craft*.lua" -type f | while read -r file; do
    add_voxelibre_recipes "$file"
done

echo ""
echo "✅ Conversion complete!"
echo "📋 Backups created with .backup extension"
echo ""
echo "🧪 Next steps:"
echo "   1. Review changes: git diff"
echo "   2. Test locally: docker-compose restart luanti-server"
echo "   3. Verify in-game crafting recipes work"
