#!/bin/bash

# Script para generar texturas placeholder de colores sólidos
# Requiere: ImageMagick (convert command)
# Uso: bash generate_placeholders.sh

echo "🎨 Generando texturas placeholder para Custom Villagers..."

# Verificar si ImageMagick está instalado
if ! command -v convert &> /dev/null; then
    echo "❌ ERROR: ImageMagick no está instalado"
    echo "Instalar con: sudo apt install imagemagick"
    exit 1
fi

# Definir colores por tipo de aldeano
FARMER_COLOR="#4CAF50"      # Verde
LIBRARIAN_COLOR="#2196F3"   # Azul
TEACHER_COLOR="#9C27B0"     # Morado
EXPLORER_COLOR="#795548"    # Marrón

SIZE="16x16"

# Array de caras
FACES=("top" "bottom" "side" "front" "back")

# Función para generar texturas de un tipo
generate_villager_textures() {
    local type=$1
    local color=$2

    echo "  Generando texturas para: $type (color: $color)"

    for face in "${FACES[@]}"; do
        filename="custom_villagers_${type}_${face}.png"
        convert -size $SIZE "xc:${color}" "$filename"
        echo "    ✓ $filename"
    done
}

# Generar texturas para cada tipo
generate_villager_textures "farmer" "$FARMER_COLOR"
generate_villager_textures "librarian" "$LIBRARIAN_COLOR"
generate_villager_textures "teacher" "$TEACHER_COLOR"
generate_villager_textures "explorer" "$EXPLORER_COLOR"

echo ""
echo "✅ ¡Texturas placeholder generadas exitosamente!"
echo ""
echo "📋 Total de archivos creados: $(ls -1 custom_villagers_*.png 2>/dev/null | wc -l)"
echo ""
echo "🎮 Prueba en el juego con: /spawn_villager farmer"
echo ""
echo "💡 TIP: Estas son texturas simples de colores. Puedes mejorarlas con GIMP/Krita."
