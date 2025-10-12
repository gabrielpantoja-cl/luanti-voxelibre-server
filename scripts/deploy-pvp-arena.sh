#!/bin/bash
# Script de deployment para PVP Arena Mod
# Autor: gabo (Gabriel Pantoja)
# NO reinicia el servidor automáticamente - requiere confirmación del admin

set -e

echo "======================================"
echo "🏟️  PVP Arena Mod - Deployment Script"
echo "======================================"
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ Error: Este script debe ejecutarse desde el directorio raíz del proyecto${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 PASO 1: Verificando archivos del mod${NC}"
if [ ! -f "server/mods/pvp_arena/init.lua" ]; then
    echo -e "${RED}❌ Error: No se encuentra server/mods/pvp_arena/init.lua${NC}"
    exit 1
fi

if [ ! -f "server/mods/pvp_arena/commands.lua" ]; then
    echo -e "${RED}❌ Error: No se encuentra server/mods/pvp_arena/commands.lua${NC}"
    exit 1
fi

if [ ! -f "server/mods/pvp_arena/mod.conf" ]; then
    echo -e "${RED}❌ Error: No se encuentra server/mods/pvp_arena/mod.conf${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Todos los archivos del mod presentes${NC}"
echo ""

echo -e "${YELLOW}📋 PASO 2: Verificando configuración${NC}"
if grep -q "load_mod_pvp_arena = true" server/config/luanti.conf; then
    echo -e "${GREEN}✅ Mod ya está habilitado en luanti.conf${NC}"
else
    echo -e "${YELLOW}⚠️  Agregando configuración a luanti.conf${NC}"

    # Backup de configuración
    cp server/config/luanti.conf server/config/luanti.conf.backup.$(date +%Y%m%d_%H%M%S)
    echo -e "${GREEN}✅ Backup de configuración creado${NC}"

    # Agregar configuración del mod al final del archivo
    cat >> server/config/luanti.conf << 'EOF'

# ===========================================
# CONFIGURACIÓN MOD PVP ARENA 🏟️⚔️
# ===========================================

# Habilitar mod de zonas PVP
load_mod_pvp_arena = true

# Arena por defecto:
# Centro: (41, 23, 232) - Construcción existente
# Radio: 25 bloques (área 51x51)
# Altura: ±50 bloques desde centro

# Comandos para jugadores:
# /arena_lista - Ver arenas disponibles
# /arena_info - Info de arena actual
# /arena_donde - Distancia a arena más cercana
# /salir_arena - Teleport al spawn

# Comandos admin (requiere privilegio arena_admin):
# /crear_arena <nombre> <radio>
# /eliminar_arena <nombre>
# /arena_tp <nombre>
# /arena_toggle <nombre>
# /arena_stats
EOF
    echo -e "${GREEN}✅ Configuración agregada a luanti.conf${NC}"
fi
echo ""

echo -e "${YELLOW}📋 PASO 3: Verificando privilegios de admin${NC}"
echo -e "${GREEN}ℹ️  Después del deployment, otorga privilegios con:${NC}"
echo -e "   ${GREEN}/grant gabo arena_admin${NC}"
echo -e "   ${GREEN}/grant pepelomo arena_admin${NC}"
echo ""

echo -e "${YELLOW}📋 PASO 4: Resumen de configuración${NC}"
echo -e "${GREEN}Arena configurada:${NC}"
echo "   • Nombre: Arena Principal"
echo "   • Centro: (41, 23, 232)"
echo "   • Radio: 25 bloques (51x51 área)"
echo "   • Altura: ±50 bloques"
echo ""

echo -e "${YELLOW}📋 PASO 5: Estado del servidor${NC}"
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✅ Servidor está corriendo${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANTE: El servidor necesita reiniciarse para cargar el mod${NC}"
    echo -e "${RED}⚠️  Hay jugadores conectados - NO reinicies automáticamente${NC}"
    echo ""
    echo -e "${YELLOW}Cuando estés listo para activar el mod:${NC}"
    echo -e "   1. Avisa a los jugadores"
    echo -e "   2. Ejecuta: ${GREEN}docker-compose restart luanti-server${NC}"
    echo -e "   3. Verifica con: ${GREEN}docker-compose logs -f luanti-server${NC}"
    echo -e "   4. En el juego: ${GREEN}/grant gabo arena_admin${NC}"
    echo ""
else
    echo -e "${RED}❌ Servidor no está corriendo${NC}"
    echo -e "${YELLOW}Puedes iniciar el servidor con: docker-compose up -d${NC}"
    echo ""
fi

echo -e "${GREEN}======================================"
echo "✅ Deployment preparado exitosamente"
echo "======================================${NC}"
echo ""
echo -e "${YELLOW}Comandos útiles después del reinicio:${NC}"
echo -e "   ${GREEN}/arena_lista${NC} - Ver arenas disponibles"
echo -e "   ${GREEN}/arena_donde${NC} - Ver distancia a arena más cercana"
echo -e "   ${GREEN}/crear_arena NombreArena <radio>${NC} - Crear nueva arena (admin)"
echo ""
echo -e "${YELLOW}Verificar logs del mod:${NC}"
echo -e "   ${GREEN}docker-compose logs luanti-server | grep 'PVP Arena'${NC}"
echo ""
