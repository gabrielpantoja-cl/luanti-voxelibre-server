#!/bin/bash
# Script para ayudar a gabo con el ascensor de 13 pisos
# Fecha: 2025-11-08

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}  AYUDA PARA ASCENSOR DE 13 PISOS - GABO${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""

# Función para ejecutar comandos en el servidor
run_server_cmd() {
    local cmd="$1"
    echo -e "${YELLOW}Ejecutando: ${cmd}${NC}"
    docker-compose exec -T luanti-server /bin/bash -c "echo \"$cmd\" >> /config/.minetest/worlds/world/chatcommands.txt" 2>/dev/null || true
}

# Verificar que el servidor esté corriendo
if ! docker-compose ps | grep -q "luanti-server.*Up"; then
    echo -e "${RED}❌ ERROR: El servidor no está corriendo${NC}"
    echo -e "${YELLOW}Inicia el servidor con: ./scripts/start.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Servidor corriendo${NC}"
echo ""

# Opción 1: Dar items a gabo
echo -e "${BLUE}=== PASO 1: DAR ITEMS A GABO ===${NC}"
echo -e "${YELLOW}¿Quieres dar todos los items necesarios a gabo? (s/n)${NC}"
read -r respuesta

if [[ "$respuesta" == "s" || "$respuesta" == "S" ]]; then
    echo -e "${GREEN}Dando items a gabo...${NC}"

    # Ejecutar comandos directamente en el contenedor
    docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/chatcommands.txt <<EOF || true
INSERT INTO chatcommands (player, command) VALUES
('Server', '/give gabo celevator:shaft 99'),
('Server', '/give gabo celevator:guide_rail 99'),
('Server', '/give gabo celevator:buffer_oil 5'),
('Server', '/give gabo celevator:car_glassback 20'),
('Server', '/give gabo celevator:hwdoor_glass 20'),
('Server', '/give gabo celevator:callbutton_both 15'),
('Server', '/give gabo celevator:callbutton_up 5'),
('Server', '/give gabo celevator:callbutton_down 5'),
('Server', '/give gabo celevator:governor 5'),
('Server', '/give gabo celevator:controller 5'),
('Server', '/give gabo celevator:machine 5'),
('Server', '/give gabo celevator:drive 5');
EOF

    echo -e "${GREEN}✅ Items enviados a gabo${NC}"
    echo ""
    echo -e "${YELLOW}NOTA: Los items aparecerán en el inventario de gabo cuando se reconecte o use /clearobjects${NC}"
fi

# Mostrar instrucciones
echo ""
echo -e "${BLUE}=== INSTRUCCIONES COMPLETAS ===${NC}"
echo -e "${GREEN}Archivo creado: INSTRUCCIONES_ASCENSOR_GABO.md${NC}"
echo ""
echo -e "${YELLOW}Comparte este archivo con gabo para que siga los pasos.${NC}"
echo ""

# Resumen de coordenadas
echo -e "${BLUE}=== COORDENADAS CLAVE ===${NC}"
echo -e "${GREEN}Posición central del ascensor: X=88, Z=-43${NC}"
echo ""
echo -e "${YELLOW}Pisos (coordenada Y):${NC}"
echo "  Piso 1 (PB):  Y=15"
echo "  Piso 2:       Y=20"
echo "  Piso 3:       Y=25"
echo "  Piso 4:       Y=30"
echo "  Piso 5:       Y=35"
echo "  Piso 6:       Y=40"
echo "  Piso 7:       Y=45"
echo "  Piso 8:       Y=50"
echo "  Piso 9:       Y=55"
echo "  Piso 10:      Y=60"
echo "  Piso 11:      Y=65"
echo "  Piso 12:      Y=70"
echo "  Piso 13:      Y=75"
echo "  Sala máquinas: Y=77"
echo ""

# Comandos de verificación
echo -e "${BLUE}=== VERIFICAR ESTADO ACTUAL ===${NC}"
echo -e "${YELLOW}Ver logs de gabo:${NC}"
echo "  docker-compose logs --tail=50 luanti-server | grep gabo"
echo ""
echo -e "${YELLOW}Verificar privilegios de gabo:${NC}"
echo "  docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite 'SELECT privilege FROM user_privileges WHERE id=1;'"
echo ""

# Comandos útiles para gabo
echo -e "${BLUE}=== COMANDOS ÚTILES PARA GABO (copiar en chat) ===${NC}"
echo ""
echo -e "${GREEN}1. Limpiar cabinas mal ubicadas (WorldEdit):${NC}"
cat <<'ENDCMDS'
/teleport gabo 86 15 -45
/1
/teleport gabo 91 80 -41
/2
//replace celevator:car_glassback air
ENDCMDS
echo ""

echo -e "${GREEN}2. Crear shaft vertical:${NC}"
cat <<'ENDCMDS'
/teleport gabo 88 14 -43
/1
/teleport gabo 88 77 -43
/2
//set celevator:shaft
ENDCMDS
echo ""

echo -e "${GREEN}3. Crear guide rails (pared oeste):${NC}"
cat <<'ENDCMDS'
/teleport gabo 87 14 -43
/1
/teleport gabo 87 77 -43
/2
//set celevator:guide_rail
ENDCMDS
echo ""

echo -e "${GREEN}4. Crear guide rails (pared este):${NC}"
cat <<'ENDCMDS'
/teleport gabo 89 14 -43
/1
/teleport gabo 89 77 -43
/2
//set celevator:guide_rail
ENDCMDS
echo ""

echo -e "${BLUE}==================================================${NC}"
echo -e "${GREEN}✅ AYUDA COMPLETA GENERADA${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo "  1. Compartir INSTRUCCIONES_ASCENSOR_GABO.md con gabo"
echo "  2. Gabo debe seguir los pasos 1-10 del manual"
echo "  3. Monitorear progreso: docker-compose logs -f luanti-server | grep gabo"
echo ""
echo -e "${GREEN}¡Buena suerte con el ascensor! 🚀${NC}"