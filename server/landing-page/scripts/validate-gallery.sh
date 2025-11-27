#!/bin/bash
# Script de validacion para gallery-data.json
# Verifica que el JSON sea valido y que todas las imagenes existan

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANDING_DIR="$(dirname "$SCRIPT_DIR")"
JSON_FILE="$LANDING_DIR/assets/data/gallery-data.json"
IMAGES_DIR="$LANDING_DIR/assets/images"

echo "🔍 Validando galeria de Wetlands..."
echo ""

# Verificar que JSON existe
if [ ! -f "$JSON_FILE" ]; then
    echo -e "${RED}❌ Error: gallery-data.json no encontrado${NC}"
    echo "Ruta esperada: $JSON_FILE"
    exit 1
fi

# Validar sintaxis JSON
echo "📝 Validando sintaxis JSON..."
if ! python3 -m json.tool "$JSON_FILE" > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: JSON mal formado${NC}"
    echo "Usa https://jsonlint.com/ para validar el JSON"
    exit 1
fi
echo -e "${GREEN}✅ Sintaxis JSON correcta${NC}"
echo ""

# Extraer informacion del JSON
TOTAL_IMAGES=$(jq '.images | length' "$JSON_FILE")
echo "📊 Total de imagenes en JSON: $TOTAL_IMAGES"
echo ""

# Verificar que todas las imagenes existen
echo "🖼️  Verificando existencia de imagenes..."
MISSING_IMAGES=0

while IFS= read -r filename; do
    IMAGE_PATH="$IMAGES_DIR/$filename"
    if [ ! -f "$IMAGE_PATH" ]; then
        echo -e "${RED}❌ Imagen no encontrada: $filename${NC}"
        MISSING_IMAGES=$((MISSING_IMAGES + 1))
    else
        # Verificar tamaño de imagen
        SIZE=$(du -h "$IMAGE_PATH" | cut -f1)
        SIZE_BYTES=$(stat -c%s "$IMAGE_PATH" 2>/dev/null || stat -f%z "$IMAGE_PATH" 2>/dev/null)
        SIZE_MB=$(echo "scale=2; $SIZE_BYTES / 1048576" | bc)

        if (( $(echo "$SIZE_MB > 2" | bc -l) )); then
            echo -e "${YELLOW}⚠️  Advertencia: $filename es grande ($SIZE) - considera optimizar${NC}"
        else
            echo -e "${GREEN}✅ $filename ($SIZE)${NC}"
        fi
    fi
done < <(jq -r '.images[].filename' "$JSON_FILE")

echo ""

if [ $MISSING_IMAGES -gt 0 ]; then
    echo -e "${RED}❌ Error: $MISSING_IMAGES imagenes no encontradas${NC}"
    exit 1
fi

# Verificar duplicados de IDs
echo "🔍 Verificando IDs duplicados..."
DUPLICATE_IDS=$(jq -r '.images[].id' "$JSON_FILE" | sort | uniq -d)
if [ ! -z "$DUPLICATE_IDS" ]; then
    echo -e "${RED}❌ Error: IDs duplicados encontrados:${NC}"
    echo "$DUPLICATE_IDS"
    exit 1
fi
echo -e "${GREEN}✅ No hay IDs duplicados${NC}"
echo ""

# Verificar prioridades
echo "🔢 Verificando prioridades..."
PRIORITIES=$(jq -r '.images[].priority' "$JSON_FILE" | sort -n | tr '\n' ' ')
echo "Prioridades actuales: $PRIORITIES"

# Verificar si hay duplicados de prioridad
DUPLICATE_PRIORITIES=$(echo "$PRIORITIES" | tr ' ' '\n' | sort | uniq -d)
if [ ! -z "$DUPLICATE_PRIORITIES" ]; then
    echo -e "${YELLOW}⚠️  Advertencia: Prioridades duplicadas encontradas: $DUPLICATE_PRIORITIES${NC}"
    echo "Esto puede causar orden inesperado"
fi

# Verificar que primera imagen tenga featured: true
FIRST_IMAGE_FEATURED=$(jq -r '.images | sort_by(.priority) | .[0].featured' "$JSON_FILE")
if [ "$FIRST_IMAGE_FEATURED" != "true" ]; then
    echo -e "${YELLOW}⚠️  Advertencia: La imagen con priority 1 no tiene featured: true${NC}"
fi

echo ""

# Verificar categorias validas
echo "📂 Verificando categorias..."
VALID_CATEGORIES=("updates" "gameplay" "community")
INVALID_CATEGORIES=0

while IFS= read -r category; do
    if [[ ! " ${VALID_CATEGORIES[@]} " =~ " ${category} " ]]; then
        echo -e "${RED}❌ Categoria invalida: $category${NC}"
        INVALID_CATEGORIES=$((INVALID_CATEGORIES + 1))
    fi
done < <(jq -r '.images[].category' "$JSON_FILE")

if [ $INVALID_CATEGORIES -eq 0 ]; then
    echo -e "${GREEN}✅ Todas las categorias son validas${NC}"
else
    echo -e "${RED}❌ Error: $INVALID_CATEGORIES categorias invalidas${NC}"
    echo "Categorias validas: ${VALID_CATEGORIES[@]}"
    exit 1
fi

echo ""

# Estadisticas finales
echo "📊 Estadisticas de la galeria:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

UPDATES_COUNT=$(jq '[.images[] | select(.category == "updates")] | length' "$JSON_FILE")
GAMEPLAY_COUNT=$(jq '[.images[] | select(.category == "gameplay")] | length' "$JSON_FILE")
COMMUNITY_COUNT=$(jq '[.images[] | select(.category == "community")] | length' "$JSON_FILE")
FEATURED_COUNT=$(jq '[.images[] | select(.featured == true)] | length' "$JSON_FILE")
WITH_BADGE=$(jq '[.images[] | select(.badge != null)] | length' "$JSON_FILE")

echo "Total imagenes: $TOTAL_IMAGES"
echo "  - Updates: $UPDATES_COUNT"
echo "  - Gameplay: $GAMEPLAY_COUNT"
echo "  - Community: $COMMUNITY_COUNT"
echo "Destacadas: $FEATURED_COUNT"
echo "Con badge: $WITH_BADGE"

LAST_UPDATED=$(jq -r '.lastUpdated' "$JSON_FILE")
VERSION=$(jq -r '.version' "$JSON_FILE")
echo "Version: $VERSION"
echo "Ultima actualizacion: $LAST_UPDATED"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}✅ Validacion completada exitosamente!${NC}"
echo ""
echo "La galeria esta lista para deployment."
echo "Ejecuta: ./scripts/deploy-landing.sh"
