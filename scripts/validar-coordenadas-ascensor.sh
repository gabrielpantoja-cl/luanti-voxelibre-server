#!/bin/bash

# Script de Validación de Coordenadas del Ascensor
# Propósito: Verificar que las puertas y botones estén en las alturas correctas
# Uso: ./scripts/validar-coordenadas-ascensor.sh

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuración del ascensor (SISTEMA ACTUAL - Basado en diagnóstico real)
# NOTA: El sistema usa coordenadas base diferentes al estándar documentado
# Piso 1 está en Y=16.5/17 (no en Y=17 como el estándar)
BOTTOM_FLOOR_Y=17  # Coordenada Y del piso 1 (ajustar según donde realmente llega la cabina)
FLOOR_HEIGHT=5
NUMBER_OF_FLOORS=13
CAR_ID=73  # ID del controller (debe coincidir en machine, controller y todos los botones)

echo "⚠️  IMPORTANTE: Este script muestra coordenadas TEÓRICAS."
echo "    Tu sistema actual tiene un offset. Usa estos valores como GUÍA"
echo "    y ajusta según donde REALMENTE llega la cabina en tu servidor."
echo ""

echo "🏢 Validador de Coordenadas del Ascensor - Oficinas Wetlands"
echo "=============================================================="
echo ""
echo "Parámetros de configuración:"
echo "  • Bottom Floor Y: $BOTTOM_FLOOR_Y"
echo "  • Floor Height: $FLOOR_HEIGHT"
echo "  • Number of Floors: $NUMBER_OF_FLOORS"
echo "  • Car ID: $CAR_ID"
echo ""

# Función para calcular la coordenada Y de un piso
calcular_y() {
    local piso=$1
    echo $((BOTTOM_FLOOR_Y + (piso - 1) * FLOOR_HEIGHT))
}

# Tabla de validación
echo "📋 Tabla de Coordenadas Esperadas:"
echo ""
printf "%-6s %-8s %-15s %-20s\n" "Piso" "Y" "Tipo Botón" "Cálculo"
printf "%-6s %-8s %-15s %-20s\n" "------" "--------" "---------------" "--------------------"

for ((i=1; i<=NUMBER_OF_FLOORS; i++)); do
    y=$(calcular_y $i)

    # Determinar tipo de botón
    if [ $i -eq 1 ]; then
        boton="UP"
    elif [ $i -eq $NUMBER_OF_FLOORS ]; then
        boton="DOWN"
    else
        boton="BOTH"
    fi

    # Calcular expresión
    calculo="$BOTTOM_FLOOR_Y + $(( (i-1) * FLOOR_HEIGHT ))"

    printf "%-6d %-8d %-15s %-20s\n" "$i" "$y" "$boton" "$calculo = $y"
done

echo ""
echo "📐 Fórmula utilizada: Y_piso = Bottom_floor_Y + (piso - 1) × floor_height"
echo ""

# Comandos de teleportación
echo "🎮 Comandos de Teleportación para Validación:"
echo ""
echo "Testeo (3 pisos):"
for ((i=1; i<=3; i++)); do
    y=$(calcular_y $i)
    echo "  Piso $i: /teleport gabo 88 $y -43"
done

echo ""
echo "Production (13 pisos):"
echo "  Piso 1:  /teleport gabo 88 17 -43"
echo "  Piso 7:  /teleport gabo 88 47 -43  (mitad del edificio)"
echo "  Piso 13: /teleport gabo 88 77 -43  (último piso)"

echo ""
echo "🔧 Sala de Máquinas:"
y_machine=$(($(calcular_y $NUMBER_OF_FLOORS) + FLOOR_HEIGHT + 1))
echo "  Machine/Controller/Drive: Y=68 (sobre techo de piso 13 en Y=78)"
echo "  Acceso: /teleport gabo 88 69 -43  (aire libre para colocar)"

echo ""
echo "✅ Verificación Manual:"
echo ""
echo "1. Conectarse al servidor: luanti.gabrielpantoja.cl:30000"
echo "2. Para cada piso, ejecutar el comando de teleportación correspondiente"
echo "3. Verificar que exista:"
echo "   • Puerta (hwdoor_glass) en la coordenada Y esperada"
echo "   • Botón de llamada con tipo correcto (UP/BOTH/DOWN)"
echo "   • Car ID configurado = $CAR_ID en el botón"
echo ""
echo "🚨 Errores Comunes:"
echo ""
echo "• Desfase de +1 bloque: Piso 11 en Y=66 en vez de Y=67"
echo "  → Solución: Reconfigurar puertas/botones en coordenadas correctas"
echo ""
echo "• Error 'target position out of bounds':"
echo "  → Causa: Controller tiene configuración incorrecta de floors o height"
echo "  → Solución: Reconfigurar controller con valores de esta tabla"
echo ""
echo "• Cabina llega 1 bloque arriba de la puerta:"
echo "  → Causa: Puerta instalada en Y incorrecto"
echo "  → Solución: Mover puerta a Y correcto usando esta tabla"
echo ""

# Generar comandos de instalación rápida
echo "⚡ Comandos de Instalación Rápida (Copiar y Pegar):"
echo ""
echo "# Puertas y botones para los 13 pisos:"
for ((i=1; i<=NUMBER_OF_FLOORS; i++)); do
    y=$(calcular_y $i)

    if [ $i -eq 1 ]; then
        boton="callbutton_up"
    elif [ $i -eq $NUMBER_OF_FLOORS ]; then
        boton="callbutton_down"
    else
        boton="callbutton_both"
    fi

    echo "/teleport gabo 88 $y -43  # Piso $i"
    echo "# Instalar: hwdoor_glass + $boton (Car ID = $CAR_ID)"
    echo ""
done

echo "✅ Validación completa. Utiliza esta información para corregir el ascensor."