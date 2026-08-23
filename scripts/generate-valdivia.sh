#!/bin/bash
# =============================================
# GENERAR MUNDO VALDIVIA desde OpenStreetMap
# =============================================
# Usa Arnis para generar el mundo y lo copia al directorio del servidor

set -e

ARNIS_DIR="$HOME/arnis"
ARNIS_BIN="$ARNIS_DIR/target/release/arnis"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
VALDIVIA_WORLD="$PROJECT_DIR/server/worlds/valdivia"

# El bbox se suministra explicitamente para no versionar ubicaciones sensibles.
# Formato Arnis: min_lat,min_lng,max_lat,max_lng
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Uso: $0 <OSM_BBOX> [nombre-area]"
    echo "Ejemplo: $0 '<min_lat>,<min_lng>,<max_lat>,<max_lng>' valdivia"
    exit 1
fi

BBOX="$1"
AREA_NAME="${2:-sector de Valdivia}"

if ! [[ "$BBOX" =~ ^-?[0-9]+([.][0-9]+)?,-?[0-9]+([.][0-9]+)?,-?[0-9]+([.][0-9]+)?,-?[0-9]+([.][0-9]+)?$ ]]; then
    echo "ERROR: bbox invalido. Usa min_lat,min_lng,max_lat,max_lng sin espacios."
    exit 1
fi

echo "=== Generando mundo Valdivia ==="
echo "Area: $AREA_NAME"
echo "Bbox: $BBOX"
echo ""

# Verificar que Arnis esta compilado
if [ ! -f "$ARNIS_BIN" ]; then
    echo "ERROR: Arnis no esta compilado. Ejecuta primero:"
    echo "  ./scripts/setup-arnis.sh"
    exit 1
fi

# Crear directorio de salida temporal
TEMP_OUTPUT="/tmp/valdivia-arnis-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEMP_OUTPUT"

# Intentar generacion directa Luanti (PR #808)
echo "Intentando generacion directa Luanti..."
if "$ARNIS_BIN" --help 2>&1 | grep -q "luanti"; then
    echo "Soporte Luanti detectado! Generando directamente..."
    "$ARNIS_BIN" \
        --luanti \
        --luanti-game mineclonia \
        --terrain \
        --bbox="$BBOX"

    # Arnis genera en ~/.minetest/worlds/arnis/
    ARNIS_OUTPUT="$HOME/.minetest/worlds/arnis"
    if [ -d "$ARNIS_OUTPUT" ] && [ -f "$ARNIS_OUTPUT/map.sqlite" ]; then
        echo "Mundo generado exitosamente!"
        echo "Copiando a $VALDIVIA_WORLD ..."

        # Backup si ya existe
        if [ -f "$VALDIVIA_WORLD/map.sqlite" ]; then
            BACKUP="$VALDIVIA_WORLD.backup.$(date +%Y%m%d_%H%M%S)"
            echo "Mundo existente detectado, backup en $BACKUP"
            cp -r "$VALDIVIA_WORLD" "$BACKUP"
        fi

        cp "$ARNIS_OUTPUT/map.sqlite" "$VALDIVIA_WORLD/"
        cp "$ARNIS_OUTPUT/map_meta.txt" "$VALDIVIA_WORLD/" 2>/dev/null || true
        cp "$ARNIS_OUTPUT/env_meta.txt" "$VALDIVIA_WORLD/" 2>/dev/null || true

        echo "Mundo Luanti copiado a $VALDIVIA_WORLD"
    else
        echo "ERROR: No se encontro el mundo generado en $ARNIS_OUTPUT"
        exit 1
    fi
else
    echo "Soporte Luanti NO disponible. Generando formato Minecraft..."
    echo "Necesitaras convertir con MC2MT despues."

    MC_OUTPUT="$TEMP_OUTPUT/saves/valdivia"
    mkdir -p "$MC_OUTPUT"

    "$ARNIS_BIN" \
        --terrain \
        --path="$MC_OUTPUT" \
        --bbox="$BBOX"

    echo ""
    echo "Mundo Minecraft generado en: $MC_OUTPUT"
    echo ""
    echo "Proximo paso: convertir con MC2MT (ROllerozxa):"
    echo "  git clone https://github.com/ROllerozxa/MC2MT /tmp/MC2MT"
    echo "  cd /tmp/MC2MT && make"
    echo "  ./MC2MT $MC_OUTPUT $VALDIVIA_WORLD"
fi

echo ""
echo "=== Generacion completada ==="
echo "Mundo destino: $VALDIVIA_WORLD"
echo ""
echo "Para verificar:"
echo "  minetestmapper -i $VALDIVIA_WORLD -o /tmp/valdivia-map.png"
echo ""
echo "Para probar localmente:"
echo "  docker-compose up -d luanti-valdivia"
echo "  Conectar a localhost:30001"
