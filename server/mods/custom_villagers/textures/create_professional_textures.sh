#!/bin/bash

# Script para generar texturas PROFESIONALES pixel art para Custom Villagers
# Inspirado en el estilo de VoxeLibre/Minecraft
# Versión 2.0 - Detalles avanzados con ImageMagick

set -e

echo "🎨 Generando texturas PROFESIONALES para Custom Villagers..."
echo ""

cd "$(dirname "$0")"

# ==============================================================================
# FARMER (AGRICULTOR) - Estilo VoxeLibre Farmer
# ==============================================================================
echo "🌾 Generando: Farmer (Agricultor) - Estilo profesional"

# Front: Cara detallada con sombrero de paja
convert -size 16x16 canvas:none \
    -fill '#C2A068' -draw 'rectangle 5,2,10,10' \
    -fill '#8B6F47' -draw 'rectangle 4,1,11,2' \
    -fill black -draw 'point 6,4' -draw 'point 9,4' \
    -fill '#654321' -draw 'point 6,5' -draw 'point 9,5' \
    -fill black -draw 'line 6,7,9,7' \
    -fill '#FF9999' -draw 'point 5,6' -draw 'point 10,6' \
    -fill '#8B6F47' -draw 'rectangle 3,10,12,11' \
    -fill '#6B5535' -draw 'rectangle 4,10,11,10' \
    -fill '#C19A6B' -draw 'rectangle 5,11,10,13' \
    -fill '#8B7355' -draw 'rectangle 6,11,9,11' \
    -fill '#654321' -draw 'rectangle 5,13,10,15' \
    -fill '#4A3728' -draw 'line 7,13,7,15' -draw 'line 8,13,8,15' \
    custom_villagers_farmer_front.png

# Top: Sombrero de paja con detalles
convert -size 16x16 canvas:none \
    -fill '#DEB887' -draw 'circle 8,8 8,14' \
    -fill '#D2B48C' -draw 'circle 8,8 8,12' \
    -fill '#CD853F' -draw 'ellipse 8,8 5,5 0,360' \
    -fill '#8B7355' -draw 'line 4,8,11,8' -draw 'line 8,4,8,11' \
    custom_villagers_farmer_top.png

# Bottom: Botas de trabajo marrones
convert -size 16x16 canvas:none \
    -fill '#654321' -draw 'rectangle 5,11,7,15' -draw 'rectangle 8,11,10,15' \
    -fill '#4A3728' -draw 'rectangle 5,14,7,15' -draw 'rectangle 8,14,10,15' \
    -fill '#8B7355' -draw 'line 6,12,6,13' -draw 'line 9,12,9,13' \
    custom_villagers_farmer_bottom.png

# Side: Brazos con camisa
convert -size 16x16 canvas:none \
    -fill '#DEB887' -draw 'rectangle 3,6,4,9' -draw 'rectangle 11,6,12,9' \
    -fill '#C19A6B' -draw 'rectangle 3,9,12,13' \
    -fill '#8B7355' -draw 'line 7,10,7,12' -draw 'line 8,10,8,12' \
    custom_villagers_farmer_side.png

# Back: Espalda con detalles
convert -size 16x16 canvas:none \
    -fill '#DEB887' -draw 'rectangle 5,2,10,10' \
    -fill '#C19A6B' -draw 'rectangle 4,10,11,13' \
    -fill '#8B7355' -draw 'line 6,10,6,13' -draw 'line 9,10,9,13' \
    -fill '#654321' -draw 'rectangle 5,13,10,15' \
    custom_villagers_farmer_back.png

# ==============================================================================
# LIBRARIAN (BIBLIOTECARIO) - Estilo VoxeLibre Librarian
# ==============================================================================
echo "📚 Generando: Librarian (Bibliotecario) - Estilo profesional"

# Front: Cara con gafas redondas y detalles
convert -size 16x16 canvas:none \
    -fill '#FFE0BD' -draw 'rectangle 5,2,10,10' \
    -fill black -draw 'point 6,4' -draw 'point 9,4' \
    -fill '#333333' -draw 'circle 6,4 6,5' -draw 'circle 9,4 9,5' \
    -fill '#4A4A4A' -draw 'line 7,4,8,4' \
    -fill black -draw 'arc 6,6,9,8 0,180' \
    -fill '#8B4513' -draw 'rectangle 5,1,10,2' \
    -fill '#5D4037' -draw 'line 6,1,6,2' -draw 'line 9,1,9,2' \
    -fill '#FFFFFF' -draw 'rectangle 4,10,11,15' \
    -fill '#E0E0E0' -draw 'line 7,11,7,14' -draw 'line 8,11,8,14' \
    -fill '#8B4513' -draw 'rectangle 6,12,9,14' \
    custom_villagers_librarian_front.png

# Top: Cabello ordenado
convert -size 16x16 canvas:none \
    -fill '#5D4037' -draw 'circle 8,8 8,14' \
    -fill '#4E342E' -draw 'ellipse 8,8 5,5 0,360' \
    -fill '#3E2723' -draw 'line 5,8,10,8' -draw 'line 8,5,8,10' \
    custom_villagers_librarian_top.png

# Bottom: Zapatos formales negros
convert -size 16x16 canvas:none \
    -fill '#1A1A1A' -draw 'rectangle 5,11,7,15' -draw 'rectangle 8,11,10,15' \
    -fill black -draw 'rectangle 5,14,7,15' -draw 'rectangle 8,14,10,15' \
    custom_villagers_librarian_bottom.png

# Side: Túnica blanca con libro
convert -size 16x16 canvas:none \
    -fill '#FFE0BD' -draw 'rectangle 3,6,4,9' -draw 'rectangle 11,6,12,9' \
    -fill '#FFFFFF' -draw 'rectangle 3,9,12,13' \
    -fill '#8B4513' -draw 'rectangle 9,10,11,12' \
    -fill '#654321' -draw 'line 9,10,11,10' -draw 'line 10,10,10,12' \
    custom_villagers_librarian_side.png

# Back
convert -size 16x16 canvas:none \
    -fill '#5D4037' -draw 'rectangle 5,2,10,10' \
    -fill '#FFFFFF' -draw 'rectangle 4,10,11,15' \
    custom_villagers_librarian_back.png

# ==============================================================================
# TEACHER (MAESTRO) - Estilo VoxeLibre Priest/Cleric
# ==============================================================================
echo "🎓 Generando: Teacher (Maestro) - Estilo profesional"

# Front: Cara amigable con corbata
convert -size 16x16 canvas:none \
    -fill '#FFCC99' -draw 'rectangle 5,2,10,10' \
    -fill black -draw 'point 6,4' -draw 'point 9,4' \
    -fill '#654321' -draw 'point 6,5' -draw 'point 9,5' \
    -fill '#FF6666' -draw 'arc 6,6,9,8 0,180' \
    -fill '#6A1B9A' -draw 'rectangle 4,10,11,15' \
    -fill '#4A148C' -draw 'line 6,10,6,15' -draw 'line 9,10,9,15' \
    -fill '#D32F2F' -draw 'rectangle 7,10,8,13' \
    -fill '#B71C1C' -draw 'line 7,11,7,12' \
    custom_villagers_teacher_front.png

# Top: Cabello con gorra
convert -size 16x16 canvas:none \
    -fill '#5D4037' -draw 'circle 8,8 8,14' \
    -fill '#4E342E' -draw 'ellipse 8,8 5,5 0,360' \
    -fill '#3E2723' -draw 'rectangle 5,5,10,7' \
    custom_villagers_teacher_top.png

# Bottom: Zapatos formales
convert -size 16x16 canvas:none \
    -fill '#212121' -draw 'rectangle 5,11,7,15' -draw 'rectangle 8,11,10,15' \
    -fill black -draw 'rectangle 5,14,7,15' -draw 'rectangle 8,14,10,15' \
    custom_villagers_teacher_bottom.png

# Side
convert -size 16x16 canvas:none \
    -fill '#FFCC99' -draw 'rectangle 3,6,4,9' -draw 'rectangle 11,6,12,9' \
    -fill '#6A1B9A' -draw 'rectangle 3,9,12,13' \
    -fill '#4A148C' -draw 'line 7,9,7,13' \
    custom_villagers_teacher_side.png

# Back
convert -size 16x16 canvas:none \
    -fill '#5D4037' -draw 'rectangle 5,2,10,10' \
    -fill '#6A1B9A' -draw 'rectangle 4,10,11,15' \
    -fill '#4A148C' -draw 'line 7,10,7,15' \
    custom_villagers_teacher_back.png

# ==============================================================================
# EXPLORER (EXPLORADOR) - Estilo aventurero
# ==============================================================================
echo "🗺️  Generando: Explorer (Explorador) - Estilo profesional"

# Front: Cara bronceada con barba
convert -size 16x16 canvas:none \
    -fill '#D2691E' -draw 'rectangle 5,2,10,10' \
    -fill black -draw 'point 6,4' -draw 'point 9,4' \
    -fill '#8B4513' -draw 'point 6,5' -draw 'point 9,5' \
    -fill '#654321' -draw 'rectangle 5,8,10,10' \
    -fill '#4A3728' -draw 'point 6,8' -draw 'point 7,9' -draw 'point 8,9' -draw 'point 9,8' \
    -fill '#795548' -draw 'rectangle 4,10,11,15' \
    -fill '#5D4037' -draw 'line 6,10,6,15' -draw 'line 9,10,9,15' \
    -fill '#3E2723' -draw 'rectangle 6,11,9,13' \
    custom_villagers_explorer_front.png

# Top: Sombrero de aventurero
convert -size 16x16 canvas:none \
    -fill '#8B7355' -draw 'circle 8,8 8,14' \
    -fill '#654321' -draw 'ellipse 8,8 5,5 0,360' \
    -fill '#4A3728' -draw 'rectangle 6,6,9,8' \
    -fill '#CD853F' -draw 'line 4,9,11,9' \
    custom_villagers_explorer_top.png

# Bottom: Botas de explorador
convert -size 16x16 canvas:none \
    -fill '#654321' -draw 'rectangle 5,11,7,15' -draw 'rectangle 8,11,10,15' \
    -fill '#4A3728' -draw 'rectangle 5,14,7,15' -draw 'rectangle 8,14,10,15' \
    -fill '#8B7355' -draw 'line 6,11,6,14' -draw 'line 9,11,9,14' \
    custom_villagers_explorer_bottom.png

# Side: Chaqueta con detalles
convert -size 16x16 canvas:none \
    -fill '#D2691E' -draw 'rectangle 3,6,4,9' -draw 'rectangle 11,6,12,9' \
    -fill '#795548' -draw 'rectangle 3,9,12,13' \
    -fill '#5D4037' -draw 'line 5,9,5,13' -draw 'line 10,9,10,13' \
    -fill '#3E2723' -draw 'rectangle 7,10,8,12' \
    custom_villagers_explorer_side.png

# Back: Mochila detallada
convert -size 16x16 canvas:none \
    -fill '#8B7355' -draw 'rectangle 5,2,10,10' \
    -fill '#795548' -draw 'rectangle 4,10,11,15' \
    -fill '#4E342E' -draw 'rectangle 6,11,9,14' \
    -fill '#654321' -draw 'line 5,11,5,14' -draw 'line 10,11,10,14' \
    -fill '#8B7355' -draw 'line 6,12,9,12' -draw 'line 7,11,7,14' -draw 'line 8,11,8,14' \
    custom_villagers_explorer_back.png

# ==============================================================================
# VALIDACIÓN
# ==============================================================================
echo ""
echo "✅ Texturas profesionales generadas exitosamente!"
echo ""
echo "📋 Validación:"

total_files=$(ls -1 custom_villagers_*.png 2>/dev/null | wc -l)
echo "  • Total de archivos: $total_files/20"

echo "  • Verificando dimensiones y calidad..."
invalid=0
for file in custom_villagers_*.png; do
    if [ -f "$file" ]; then
        size=$(identify -format "%wx%h" "$file" 2>/dev/null)
        if [ "$size" != "16x16" ]; then
            echo "    ⚠️  $file: tamaño incorrecto ($size)"
            ((invalid++))
        fi
    fi
done

if [ $invalid -eq 0 ]; then
    echo "  • ✅ Todas las texturas son 16x16 píxeles"
else
    echo "  • ⚠️  $invalid texturas con tamaño incorrecto"
fi

echo ""
echo "🎮 Próximos pasos:"
echo "  1. Revisar texturas visualmente"
echo "  2. Deploy a VPS (ya están en el servidor)"
echo "  3. Testing in-game: /spawn_villager farmer"
echo ""
echo "💡 Estas texturas tienen detalles profesionales inspirados en VoxeLibre/Minecraft"
echo ""
