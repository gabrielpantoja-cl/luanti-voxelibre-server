#!/usr/bin/env bash
# Configura el destino Telegram de /gabo (mod wetlands_contact) en el VPS.
#
# Lee WETLANDS_TELEGRAM_BOT_TOKEN y WETLANDS_TELEGRAM_CHAT_ID del .env local
# (gitignored), escribe server/worlds/original/wetlands_contact.conf en el VPS
# (dueño 1000:1000, modo 600) y envia un mensaje de prueba al chat.
#
# El token viaja por el stdin de ssh: no queda en la linea de comandos local
# ni en el historial del VPS. No hace falta reiniciar el servidor: el mod lee
# el archivo en cada envio.
#
# Uso: bash scripts/set-gabo-telegram.sh
set -euo pipefail

cd "$(dirname "$0")/.."
set -a
# shellcheck disable=SC1091
source .env
set +a

: "${VPS_USER:?falta VPS_USER en .env}"
: "${VPS_HOST:?falta VPS_HOST en .env}"
: "${WETLANDS_TELEGRAM_BOT_TOKEN:?falta WETLANDS_TELEGRAM_BOT_TOKEN en .env}"
: "${WETLANDS_TELEGRAM_CHAT_ID:?falta WETLANDS_TELEGRAM_CHAT_ID en .env}"

if ! [[ "$WETLANDS_TELEGRAM_BOT_TOKEN" =~ ^[0-9]+:[A-Za-z0-9_-]{30,}$ ]]; then
    echo "WETLANDS_TELEGRAM_BOT_TOKEN no parece un token de @BotFather (123456789:AAxxxx...)." >&2
    exit 1
fi
if ! [[ "$WETLANDS_TELEGRAM_CHAT_ID" =~ ^-?[0-9]+$ ]]; then
    echo "WETLANDS_TELEGRAM_CHAT_ID debe ser numerico." >&2
    exit 1
fi

printf 'telegram_token = %s\ntelegram_chat_id = %s\n' \
    "$WETLANDS_TELEGRAM_BOT_TOKEN" "$WETLANDS_TELEGRAM_CHAT_ID" |
ssh "$VPS_USER@$VPS_HOST" '
    set -e
    F=~/luanti-voxelibre-server/server/worlds/original/wetlands_contact.conf
    sudo tee "$F" >/dev/null
    sudo chown 1000:1000 "$F"
    sudo chmod 600 "$F"
    echo "Escrito $F ($(sudo stat -c "%U:%G %a" "$F"))"

    # Prueba desde el VPS: confirma token, /start y salida a internet.
    T=$(sudo sed -n "s/^telegram_token = //p" "$F")
    C=$(sudo sed -n "s/^telegram_chat_id = //p" "$F")
    body=$(curl -s -X POST "https://api.telegram.org/bot$T/sendMessage" \
        --data-urlencode "chat_id=$C" \
        --data-urlencode "text=🌿 Wetlands conectado: /gabo listo")
    case "$body" in
        *\"ok\":true*) echo "OK: revisa tu Telegram, deberia llegar \"Wetlands conectado\"." ;;
        *"chat not found"*|*"blocked by the user"*)
            echo "El bot no puede escribirte: abre el bot en Telegram, toca Iniciar (/start) y repite." ; exit 1 ;;
        *Unauthorized*|*"Not Found"*)
            echo "Token invalido: revisa WETLANDS_TELEGRAM_BOT_TOKEN." ; exit 1 ;;
        *) echo "Telegram respondio: $(printf "%s" "$body" | grep -o "\"description\":\"[^\"]*\"")" ; exit 1 ;;
    esac
'
