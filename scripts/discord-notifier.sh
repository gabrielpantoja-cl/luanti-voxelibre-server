#!/bin/bash

# ============================================================================
# Discord Notifier - Monitor de Conexiones de Jugadores
# ============================================================================
# Este script monitorea los logs del servidor Luanti en tiempo real
# y envía notificaciones a Discord cuando un jugador se conecta o desconecta.
#
# Al conectar, geolocaliza la IP del jugador (país/ciudad) y la publica
# ENMASCARADA: la IP completa jamás sale hacia Discord (solo se conserva la
# primera mitad, ej. 104.28.154.250 -> 104.28.*.*).
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
SERVER_LABEL="${SERVER_LABEL:-Wetlands 🌱}"
SERVER_PORT="${SERVER_PORT:-}"
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

    local server_display="$SERVER_LABEL"
    if [ -n "$SERVER_PORT" ]; then
        server_display="${server_display} [${SERVER_PORT}]"
    fi

    local full_message="${emoji} ${message} | **Servidor:** ${server_display}"

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

# --- Geolocalización y enmascaramiento de IP (privacidad) -------------------
# Proveedor: ip-api.com (API gratuita, sin clave, máx. 45 consultas/min,
# solo HTTP en su plan free). La IP completa NUNCA se publica en Discord:
# solo se conserva la primera mitad de la dirección.

# Enmascara la segunda mitad de la IP.
#   IPv4: 104.28.154.250 -> 104.28.*.*
#   IPv6: 2001:db8::11aa -> 2001:db8:*:*
# Sin IP -> "?" (nunca sale vacío ni completo).
mask_ip() {
    local ip="$1"
    if [ -z "$ip" ]; then
        echo "?"
        return 0
    fi
    case "$ip" in
        *:*)
            # IPv6: conserva los 2 primeros grupos
            local g1 g2
            g1=$(echo "$ip" | cut -d: -f1)
            g2=$(echo "$ip" | cut -d: -f2)
            echo "${g1}:${g2}:*:*"
            ;;
        *)
            # IPv4: conserva los 2 primeros octetos
            local o1 o2
            o1=$(echo "$ip" | cut -d. -f1)
            o2=$(echo "$ip" | cut -d. -f2)
            echo "${o1}.${o2}.*.*"
            ;;
    esac
    return 0
}

# ¿Es una IP pública consultable? Rangos privados/reservados no se consultan
# (la API los rechaza igual, así que evitamos la llamada).
is_public_ip() {
    local ip="$1"
    if [ -z "$ip" ]; then
        return 1
    fi
    case "$ip" in
        *:*)
            case "$ip" in
                ::1|fc*|fd*|fe80:*) return 1 ;;  # IPv6 loopback/ULA/link-local
                *) return 0 ;;
            esac
            ;;
        *)
            case "$ip" in
                10.*|127.*|192.168.*|169.254.*|0.*) return 1 ;;
                172.1[6-9].*|172.2[0-9].*|172.3[01].*) return 1 ;;
                *) return 0 ;;
            esac
            ;;
    esac
}

# Consulta ip-api.com y emite "ciudad|pais" (cualquiera puede venir vacío)
# o nada si la API falla. Siempre exit 0.
# IMPORTANTE: la salida por stdout es SOLO el dato — no usar log() aquí
# dentro, porque $(...) capturaría también el texto del log.
geo_lookup() {
    local ip="$1"
    local resp=""
    resp=$(curl -s -m 5 \
        "http://ip-api.com/json/${ip}?fields=status,country,city" 2>/dev/null) || resp=""
    if [ -z "$resp" ] || ! echo "$resp" | grep -q '"status":"success"'; then
        return 0
    fi
    local country="" city=""
    country=$(echo "$resp" | sed -n 's/.*"country":"\([^"]*\)".*/\1/p')
    city=$(echo "$resp" | sed -n 's/.*"city":"\([^"]*\)".*/\1/p')
    echo "${city}|${country}"
    return 0
}

# Función para procesar líneas de log
process_log_line() {
    local line="$1"

    # Detectar conexión de jugador
    # Formato real: "2026-09-20 14:07:22: ACTION[Server]: NOMBRE [IP] joins game. ..."
    if echo "$line" | grep -q "joins game"; then
        local player_name player_ip=""
        # Extraer nombre del jugador usando sed
        player_name=$(echo "$line" | sed -n 's/.*ACTION\[Server\]: \([^ ]*\) .* joins game.*/\1/p')
        # Extraer la IP entre corchetes (si el log la incluye)
        player_ip=$(echo "$line" | sed -n 's/.*ACTION\[Server\]: [^ ]* \[\([^]]*\)\] joins game.*/\1/p')

        if [ -z "$player_name" ]; then
            player_name="Jugador desconocido"
        fi

        # Geolocalización + IP enmascarada (la IP completa NUNCA sale a Discord)
        local masked="" geo="" where=""
        if [ -n "$player_ip" ]; then
            masked=$(mask_ip "$player_ip")
            if is_public_ip "$player_ip"; then
                geo=$(geo_lookup "$player_ip")
                if [ -z "$geo" ]; then
                    log "Geo sin resultado para ${player_ip}"
                fi
            fi
        fi
        if [ -n "$geo" ]; then
            local city="${geo%%|*}"
            local country="${geo##*|}"
            if [ -n "$city" ] && [ -n "$country" ]; then
                where="**${city}, ${country}**"
            elif [ -n "$country" ]; then
                where="**${country}**"
            fi
        fi

        # Cuerpo del mensaje según lo disponible
        local body
        if [ -n "$where" ]; then
            body="🎮 **${player_name}** se ha conectado desde ${where} (IP: ${masked})"
        elif [ -n "$masked" ]; then
            body="🎮 **${player_name}** se ha conectado (IP: ${masked})"
        else
            body="🎮 **${player_name}** se ha conectado al servidor"
        fi

        log "Jugador conectado: ${player_name} (${player_ip:-sin IP})"
        send_discord_notification "$body" "🟢"
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