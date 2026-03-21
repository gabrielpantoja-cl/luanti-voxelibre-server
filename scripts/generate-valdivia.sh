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

# Bounding boxes predefinidos
# Colegio: Colegio Planeta Azul y alrededores (~600 x 600 m)
BBOX_COLEGIO="-39.8387,-73.2600,-39.8332,-73.2540"
# MVP: Centro + Costanera + Mercado Fluvial (~1.5 x 2 km)
BBOX_MVP="-39.825,-73.255,-39.810,-73.235"
# Expansion 1: + Isla Teja + Puentes (~3.5 x 4 km)
BBOX_EXP1="-39.840,-73.265,-39.805,-73.225"
# Expansion 2: + Barrios Las Animas, Jardin (~6.5 x 7.5 km)
BBOX_EXP2="-39.855,-73.275,-39.795,-73.200"
# Completa: Ciudad + Humedal Rio Cruces (~10 x 10 km)
BBOX_FULL="-39.870,-73.280,-39.780,-73.180"

# Default: colegio
BBOX="$BBOX_COLEGIO"
AREA_NAME="colegio"

# Parsear argumentos
case "${1:-colegio}" in
    colegio)
        BBOX="$BBOX_COLEGIO"
        AREA_NAME="Colegio Planeta Azul (~600x600 m)"
        ;;
    mvp)
        BBOX="$BBOX_MVP"
        AREA_NAME="mvp (centro + costanera)"
        ;;
    exp1)
        BBOX="$BBOX_EXP1"
        AREA_NAME="expansion 1 (+ Isla Teja)"
        ;;
    exp2)
        BBOX="$BBOX_EXP2"
        AREA_NAME="expansion 2 (+ barrios)"
        ;;
    full)
        BBOX="$BBOX_FULL"
        AREA_NAME="ciudad completa"
        ;;
    *)
        echo "Uso: $0 [colegio|mvp|exp1|exp2|full]"
        echo "  colegio - Colegio Planeta Azul (~600x600 m) [default]"
        echo "  mvp     - Centro + Costanera (~1.5x2 km)"
        echo "  exp1    - + Isla Teja + Puentes (~3.5x4 km)"
        echo "  exp2    - + Barrios Las Animas, Jardin (~6.5x7.5 km)"
        echo "  full    - Ciudad completa + Humedal (~10x10 km)"
        exit 1
        ;;
esac

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
