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

# UTF-8 para que ${#texto} cuente caracteres y no bytes al truncar
# ("São Paulo" en el locale C de Alpine se cortaría a mitad de letra).
export LC_ALL=C.UTF-8

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

# --- Formato del mensaje (pensado para celular) ----------------------------
# Tres filas cortas, una por categoría, con el emoji como viñeta:
#   🟢 **henry** entró
#   -# 📍 Barcelona, Spain · `83.51.*.*`
#   -# 🌱 Wetlands · :30000
# `-# ` es el "subtext" de Discord: letra más chica y gris, así la fila del
# jugador destaca y las otras dos ocupan menos ancho. Discord no permite
# truncar por CSS, así que los textos largos se acortan aquí.

# Emoji y nombre del mundo a partir de SERVER_LABEL ("Wetlands 🌱"):
# el emoji pasa a ser la viñeta de la fila del mundo.
WORLD_EMOJI="${SERVER_LABEL##* }"
WORLD_NAME="${SERVER_LABEL% *}"
if [ "$WORLD_EMOJI" = "$SERVER_LABEL" ]; then
    WORLD_EMOJI="🌍"
    WORLD_NAME="$SERVER_LABEL"
fi
WORLD_ROW="-# ${WORLD_EMOJI} ${WORLD_NAME}"
if [ -n "$SERVER_PORT" ]; then
    WORLD_ROW="${WORLD_ROW} · :${SERVER_PORT}"
fi

# Corta un texto a N caracteres agregando "…".
truncate_text() {
    local text="$1" max="$2"
    if [ "${#text}" -gt "$max" ]; then
        echo "${text:0:$((max - 1))}…"
    else
        echo "$text"
    fi
}

# Escapa el markdown de Discord en un nombre ("mr_cool_guy" saldría en cursiva).
md_escape() {
    printf '%s' "$1" | sed 's/[][\\*_~`|>]/\\&/g'
}

# Escapa un texto (puede tener varias líneas) para un string JSON.
json_escape() {
    printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/ /g' \
        | awk 'NR > 1 { printf "\\n" } { printf "%s", $0 }'
}

# 3725 -> "1 h 2 min" · 125 -> "2 min" · 40 -> "menos de 1 min"
format_duration() {
    local secs="$1"
    local h=$((secs / 3600)) m=$(((secs % 3600) / 60))
    if [ "$h" -gt 0 ]; then
        echo "${h} h ${m} min"
    elif [ "$m" -gt 0 ]; then
        echo "${m} min"
    else
        echo "menos de 1 min"
    fi
}

# Función para enviar notificación a Discord.
# $1 = filas del mensaje; la fila del mundo se agrega siempre al final.
send_discord_notification() {
    local content
    content=$(json_escape "$1
${WORLD_ROW}")

    # allowed_mentions vacío: un nombre como "everyone" no notifica a nadie.
    local response=$(curl -s -w "%{http_code}" -o /dev/null \
        -H "Content-Type: application/json" \
        -d "{\"content\":\"${content}\",\"allowed_mentions\":{\"parse\":[]}}" \
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
    local ip
    ip=$(normalize_ip "$1")
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

# Luanti escucha en IPv6 y loguea las IPv4 como "::ffff:83.51.10.20".
# Sin quitar ese prefijo, mask_ip la trataba como IPv6 y publicaba "::*:*",
# que Discord mostraba como ":::" (leía "*:*" como cursiva).
normalize_ip() {
    case "$1" in
        ::ffff:*.*) echo "${1#::ffff:}" ;;
        *) echo "$1" ;;
    esac
}

# ¿Es una IP pública consultable? Rangos privados/reservados no se consultan
# (la API los rechaza igual, así que evitamos la llamada).
is_public_ip() {
    local ip
    ip=$(normalize_ip "$1")
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

# Hora de entrada de cada jugador, para mostrar la duración al salir.
declare -A JOINED_AT=()

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
                # Se acorta la ciudad, nunca el país.
                local room=$(( 26 - ${#country} - 2 ))
                [ "$room" -lt 8 ] && room=8
                where="$(truncate_text "$city" "$room"), ${country}"
            elif [ -n "$country" ]; then
                where="${country}"
            fi
        fi

        # Fila de ubicación con lo disponible, acortada para celular.
        # La IP va en `código` para que Discord no se coma los "*".
        local place_row="-# 📍 "
        if [ -n "$where" ]; then
            place_row+=$(truncate_text "$where" 26)
        else
            place_row+="Ubicación desconocida"
        fi
        if [ -n "$masked" ]; then
            place_row+=" · \`${masked}\`"
        fi

        JOINED_AT["$player_name"]=$(date +%s)
        log "Jugador conectado: ${player_name} (${player_ip:-sin IP})"
        send_discord_notification "🟢 **$(md_escape "$player_name")** entró
${place_row}"
    fi

    # Detectar desconexión de jugador
    # Formato: "ACTION[Server]: NOMBRE leaves game. List of players: ..."
    if echo "$line" | grep -q "leaves game"; then
        # Extraer nombre del jugador usando sed
        local player_name=$(echo "$line" | sed -n 's/.*ACTION\[Server\]: \([^ ]*\) leaves game.*/\1/p')

        if [ -z "$player_name" ]; then
            player_name="Jugador desconocido"
        fi

        # Fila de sesión: cuánto jugó, si este monitor vio su entrada.
        local session_row="-# ⏱️ Duración desconocida"
        local joined="${JOINED_AT[$player_name]:-}"
        if [ -n "$joined" ]; then
            session_row="-# ⏱️ $(format_duration $(( $(date +%s) - joined ))) jugando"
            unset 'JOINED_AT[$player_name]'
        fi

        log "Jugador desconectado: $player_name"
        send_discord_notification "🔴 **$(md_escape "$player_name")** salió
${session_row}"
    fi
}

# Enviar notificación de inicio
log "Iniciando monitor de conexiones de Luanti..."
send_discord_notification "🤖 **Monitor activo**
-# ✅ Aviso cada entrada y salida"

# Monitorear logs en tiempo real
log "Monitoreando logs de $CONTAINER_NAME..."
log "Presiona Ctrl+C para detener"

# Seguir logs del contenedor
docker logs -f --tail 0 "$CONTAINER_NAME" 2>&1 | while IFS= read -r line; do
    process_log_line "$line"
done