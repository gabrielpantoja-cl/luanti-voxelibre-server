#!/bin/bash

# ============================================================================
# Test Discord Notification
# ============================================================================
# Script para probar que las notificaciones de Discord funcionan correctamente
#
# Uso: ./test-discord-notification.sh
# ============================================================================

set -euo pipefail

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Test de Notificaciones Discord ===${NC}\n"

# Cargar variables de entorno
if [ -f .env ]; then
    source .env
    echo -e "${GREEN}✓${NC} Archivo .env cargado"
else
    echo -e "${RED}✗${NC} No se encontró archivo .env"
    exit 1
fi

# Verificar webhook
if [ -z "$DISCORD_WEBHOOK_URL" ]; then
    echo -e "${RED}✗${NC} DISCORD_WEBHOOK_URL no está configurada"
    exit 1
fi

echo -e "${GREEN}✓${NC} DISCORD_WEBHOOK_URL configurada\n"

# Enviar notificación de prueba
echo -e "${BLUE}Enviando notificación de prueba...${NC}"

RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/discord_response.txt \
    -H "Content-Type: application/json" \
    -d '{"content":"🧪 **Test de Notificaciones** - Esta es una notificación de prueba del sistema de monitoreo de Luanti. ✅ El sistema está funcionando correctamente. **Servidor:** Vegan Wetlands 🌱"}' \
    "$DISCORD_WEBHOOK_URL")

if [ "$RESPONSE" = "204" ] || [ "$RESPONSE" = "200" ]; then
    echo -e "${GREEN}✓${NC} Notificación enviada exitosamente (HTTP $RESPONSE)"
    echo -e "\n${GREEN}🎉 ¡El sistema de notificaciones funciona correctamente!${NC}"
    echo -e "${BLUE}Revisa tu Discord para ver la notificación de prueba.${NC}"
    exit 0
else
    echo -e "${RED}✗${NC} Error al enviar notificación (HTTP $RESPONSE)"
    echo -e "${RED}Respuesta del servidor:${NC}"
    cat /tmp/discord_response.txt
    exit 1
fi