#!/bin/bash

# ============================================================================
# Discord Notifier - Monitor de Conexiones de Jugadores
# ============================================================================
# Este script monitorea los logs del servidor Luanti en tiempo real
# y envía notificaciones a Discord cuando un jugador se conecta o desconecta
#
# Uso: ./discord-notifier.sh
# ============================================================================

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
CONTAINER_NAME="${CONTAINER_NAME:-luanti-voxelibre-server}"
# Leer webhook del .env si no está como variable de entorno
if [ -z "$DISCORD_WEBHOOK_URL" ]; then
    DISCORD_WEBHOOK_URL=$(grep "DISCORD_WEBHOOK_URL=" .env 2>/dev/null | cut -d'=' -f2)
fi
LOG_FILE="/tmp/luanti-notifier.log"

# Función para logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Verificar que existe el webhook
if [ -z "$DISCORD_WEBHOOK_URL" ]; then
    error "DISCORD_WEBHOOK_URL no está configurada"
    error "Configura la variable en el archivo .env"
    exit 1
fi

# Verificar que el contenedor existe
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    error "Contenedor $CONTAINER_NAME no existe"
    exit 1
fi

# Función para enviar notificación a Discord
send_discord_notification() {
    local message="$1"
    local emoji="$2"  # Emoji para el mensaje (🟢, 🔴, 🤖)

    # Crear mensaje simple (sin saltos de línea complicados)
    local full_message="${emoji} ${message} | **Servidor:** Vegan Wetlands 🌱"

    # Enviar a Discord
    local response=$(curl -s -w "%{http_code}" -o /dev/null \
        -H "Content-Type: application/json" \
        -d "{\"content\":\"${full_message}\"}" \
        "$DISCORD_WEBHOOK_URL")

    if [ "$response" = "204" ] || [ "$response" = "200" ]; then
        success "Notificación enviada a Discord"
        return 0
    else
        error "Error al enviar notificación a Discord (HTTP $response)"
        return 1
    fi
}

# Función para procesar líneas de log
process_log_line() {
    local line="$1"

    # Detectar conexión de jugador
    # Formato: "ACTION[Server]: NOMBRE [IP] joins game. List of players: ..."
    if echo "$line" | grep -q "joins game"; then
        # Extraer nombre del jugador usando sed
        local player_name=$(echo "$line" | sed -n 's/.*ACTION\[Server\]: \([^ ]*\) .* joins game.*/\1/p')

        if [ -z "$player_name" ]; then
            player_name="Jugador desconocido"
        fi

        log "Jugador conectado: $player_name"
        send_discord_notification \
            "**Jugador Conectado:** $player_name se ha conectado al servidor 🎮" \
            "🟢"
    fi

    # Detectar desconexión de jugador
    # Formato: "ACTION[Server]: NOMBRE leaves game. List of players: ..."
    if echo "$line" | grep -q "leaves game"; then
        # Extraer nombre del jugador usando sed
        local player_name=$(echo "$line" | sed -n 's/.*ACTION\[Server\]: \([^ ]*\) leaves game.*/\1/p')

        if [ -z "$player_name" ]; then
            player_name="Jugador desconocido"
        fi

        log "Jugador desconectado: $player_name"
        send_discord_notification \
            "**Jugador Desconectado:** $player_name se ha desconectado del servidor 👋" \
            "🔴"
    fi
}

# Enviar notificación de inicio
log "Iniciando monitor de conexiones de Luanti..."
send_discord_notification \
    "**Monitor Iniciado:** Sistema de notificaciones activado correctamente ✅" \
    "🤖"

# Monitorear logs en tiempo real
log "Monitoreando logs de $CONTAINER_NAME..."
log "Presiona Ctrl+C para detener"

# Seguir logs del contenedor
docker logs -f --tail 0 "$CONTAINER_NAME" 2>&1 | while IFS= read -r line; do
    process_log_line "$line"
done