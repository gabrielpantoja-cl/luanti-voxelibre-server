#!/bin/bash

# Script para generar texturas pixel art detalladas para Custom Villagers
# Requiere: ImageMagick (convert command)
# Diseñado para Wetlands - estilo child-friendly

set -e

echo "🎨 Generando texturas pixel art pulidas para Custom Villagers..."
echo ""

# Verificar ImageMagick
if ! command -v convert &> /dev/null; then
    echo "❌ ERROR: ImageMagick no está instalado"
    exit 1
fi

cd "$(dirname "$0")"

# ==============================================================================
# FARMER (AGRICULTOR) - Verde con sombrero de paja
# ==============================================================================
echo "🌾 Generando: Farmer (Agricultor)"

# Front: Cara con overol
convert -size 16x16 xc:none \
    -fill '#8B4513' -draw 'rectangle 5,3,10,9' \
    -fill black -draw 'point 6,5' -draw 'point 9,5' \
    -fill black -draw 'line 6,7,9,7' \
    -fill '#4CAF50' -draw 'rectangle 4,9,11,15' \
    -fill '#2E7D32' -draw 'rectangle 7,9,8,15' \
    custom_villagers_farmer_front.png

# Top: Sombrero de paja
convert -size 16x16 xc:none \
    -fill '#F4A460' -draw 'rectangle 4,4,11,11' \
    -fill '#DAA520' -draw 'circle 8,8 8,11' \
    custom_villagers_farmer_top.png

# Bottom: Botas marrones
convert -size 16x16 xc:none \
    -fill '#654321' -draw 'rectangle 5,10,10,15' \
    -fill '#3E2723' -draw 'rectangle 5,14,10,15' \
    custom_villagers_farmer_bottom.png

# Side: Brazos con camisa
convert -size 16x16 xc:none \
    -fill '#FFE4B5' -draw 'rectangle 3,7,12,11' \
    -fill '#4CAF50' -draw 'rectangle 3,11,12,15' \
    custom_villagers_farmer_side.png

# Back: Espalda overol
convert -size 16x16 xc:none \
    -fill '#F4A460' -draw 'rectangle 5,3,10,9' \
    -fill '#4CAF50' -draw 'rectangle 4,9,11,15' \
    -fill '#2E7D32' -draw 'line 6,9,6,15' -draw 'line 9,9,9,15' \
    custom_villagers_farmer_back.png

# ==============================================================================
# LIBRARIAN (BIBLIOTECARIO) - Azul con gafas
# ==============================================================================
echo "📚 Generando: Librarian (Bibliotecario)"

# Front: Cara con gafas
convert -size 16x16 xc:none \
    -fill '#FFD9B3' -draw 'rectangle 5,3,10,9' \
    -fill black -draw 'point 6,5' -draw 'point 9,5' \
    -fill '#555555' -draw 'rectangle 5,5,6,6' -draw 'rectangle 9,5,10,6' -draw 'line 6,5,9,5' \
    -fill black -draw 'line 6,7,9,7' \
    -fill '#2196F3' -draw 'rectangle 4,9,11,15' \
    -fill '#1565C0' -draw 'rectangle 7,12,8,15' \
    custom_villagers_librarian_front.png

# Top: Cabello oscuro
convert -size 16x16 xc:none \
    -fill '#4A4A4A' -draw 'rectangle 4,4,11,11' \
    -fill '#2C2C2C' -draw 'rectangle 5,5,10,9' \
    custom_villagers_librarian_top.png

# Bottom: Zapatos negros
convert -size 16x16 xc:none \
    -fill '#1A1A1A' -draw 'rectangle 5,11,10,15' \
    -fill black -draw 'rectangle 5,14,10,15' \
    custom_villagers_librarian_bottom.png

# Side: Túnica azul
convert -size 16x16 xc:none \
    -fill '#FFD9B3' -draw 'rectangle 3,7,12,10' \
    -fill '#2196F3' -draw 'rectangle 3,10,12,15' \
    -fill '#1565C0' -draw 'line 7,10,7,15' \
    custom_villagers_librarian_side.png

# Back: Espalda túnica
convert -size 16x16 xc:none \
    -fill '#4A4A4A' -draw 'rectangle 5,3,10,9' \
    -fill '#2196F3' -draw 'rectangle 4,9,11,15' \
    -fill '#1565C0' -draw 'rectangle 7,9,8,15' \
    custom_villagers_librarian_back.png

# ==============================================================================
# TEACHER (MAESTRO) - Morado con corbata
# ==============================================================================
echo "🎓 Generando: Teacher (Maestro)"

# Front: Cara amigable con corbata
convert -size 16x16 xc:none \
    -fill '#FFCC99' -draw 'rectangle 5,3,10,9' \
    -fill black -draw 'point 6,5' -draw 'point 9,5' \
    -fill '#FF6666' -draw 'arc 6,6,9,8 0,180' \
    -fill '#9C27B0' -draw 'rectangle 4,9,11,15' \
    -fill '#6A1B9A' -draw 'rectangle 7,9,8,15' \
    -fill '#D32F2F' -draw 'rectangle 7,9,8,12' \
    custom_villagers_teacher_front.png

# Top: Cabello ordenado
convert -size 16x16 xc:none \
    -fill '#5D4037' -draw 'rectangle 4,4,11,11' \
    -fill '#4E342E' -draw 'rectangle 5,5,10,9' \
    custom_villagers_teacher_top.png

# Bottom: Zapatos formales
convert -size 16x16 xc:none \
    -fill '#212121' -draw 'rectangle 5,11,10,15' \
    -fill black -draw 'rectangle 5,14,10,15' \
    custom_villagers_teacher_bottom.png

# Side: Camisa morada
convert -size 16x16 xc:none \
    -fill '#FFCC99' -draw 'rectangle 3,7,12,10' \
    -fill '#9C27B0' -draw 'rectangle 3,10,12,15' \
    -fill '#6A1B9A' -draw 'line 7,10,7,15' \
    custom_villagers_teacher_side.png

# Back: Espalda de camisa
convert -size 16x16 xc:none \
    -fill '#5D4037' -draw 'rectangle 5,3,10,9' \
    -fill '#9C27B0' -draw 'rectangle 4,9,11,15' \
    -fill '#6A1B9A' -draw 'rectangle 7,9,8,15' \
    custom_villagers_teacher_back.png

# ==============================================================================
# EXPLORER (EXPLORADOR) - Marrón con mochila
# ==============================================================================
echo "🗺️  Generando: Explorer (Explorador)"

# Front: Cara bronceada
convert -size 16x16 xc:none \
    -fill '#D2691E' -draw 'rectangle 5,3,10,9' \
    -fill black -draw 'point 6,5' -draw 'point 9,5' \
    -fill black -draw 'line 6,7,9,7' \
    -fill '#795548' -draw 'rectangle 4,9,11,15' \
    -fill '#5D4037' -draw 'rectangle 6,11,9,13' \
    custom_villagers_explorer_front.png

# Top: Sombrero de aventurero
convert -size 16x16 xc:none \
    -fill '#8B7355' -draw 'rectangle 4,4,11,11' \
    -fill '#654321' -draw 'circle 8,8 8,11' \
    -fill '#A0522D' -draw 'rectangle 6,6,9,7' \
    custom_villagers_explorer_top.png

# Bottom: Botas de explorador
convert -size 16x16 xc:none \
    -fill '#654321' -draw 'rectangle 5,10,10,15' \
    -fill '#4A3728' -draw 'rectangle 5,14,10,15' \
    -fill '#8B7355' -draw 'line 7,11,7,13' \
    custom_villagers_explorer_bottom.png

# Side: Chaqueta marrón
convert -size 16x16 xc:none \
    -fill '#D2691E' -draw 'rectangle 3,7,12,10' \
    -fill '#795548' -draw 'rectangle 3,10,12,15' \
    -fill '#5D4037' -draw 'line 7,10,7,15' \
    custom_villagers_explorer_side.png

# Back: Mochila
convert -size 16x16 xc:none \
    -fill '#8B7355' -draw 'rectangle 5,3,10,9' \
    -fill '#795548' -draw 'rectangle 4,9,11,15' \
    -fill '#4E342E' -draw 'rectangle 6,10,9,14' \
    -fill '#6D4C41' -draw 'line 5,10,5,14' -draw 'line 10,10,10,14' \
    custom_villagers_explorer_back.png

# ==============================================================================
# VALIDACIÓN
# ==============================================================================
echo ""
echo "✅ Texturas generadas exitosamente!"
echo ""
echo "📋 Validación:"

# Contar archivos
total_files=$(ls -1 custom_villagers_*.png 2>/dev/null | wc -l)
echo "  • Total de archivos: $total_files/20"

# Verificar tamaños
echo "  • Verificando dimensiones..."
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
echo "🎮 Testing:"
echo "  1. Commit y push al repositorio"
echo "  2. Deploy a VPS"
echo "  3. In-game: /spawn_villager farmer"
echo ""
echo "💡 TIP: Estas texturas son pixel art funcional. Puedes mejorarlas con GIMP/Krita si deseas."
echo ""
