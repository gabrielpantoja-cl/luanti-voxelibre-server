#!/usr/bin/env bash
# Configura el mismo bot de /gabo para Original y Valdivia en el VPS.
# Los secretos viajan por stdin de SSH y quedan en los worldpaths y .env del VPS.
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

TOKEN="$WETLANDS_TELEGRAM_BOT_TOKEN"
CHAT_ID="$WETLANDS_TELEGRAM_CHAT_ID"

if ! [[ "$TOKEN" =~ ^[0-9]+:[A-Za-z0-9_-]{30,}$ ]]; then
    echo "WETLANDS_TELEGRAM_BOT_TOKEN no parece un token de @BotFather." >&2
    exit 1
fi
if ! [[ "$CHAT_ID" =~ ^[1-9][0-9]*$ ]]; then
    echo "WETLANDS_TELEGRAM_CHAT_ID debe ser el ID positivo del chat privado del administrador." >&2
    exit 1
fi

# No interpolar secretos en la línea remota: se transportan como dos líneas por stdin.
# El cuerpo se pasa como argumento de bash (sin secretos); stdin queda reservado para
# token y chat ID. printf %q evita que el shell de login reinterprete el cuerpo.
REMOTE_SCRIPT=$(cat <<'REMOTE_SCRIPT_EOF'
    set -euo pipefail
    umask 077
    IFS= read -r T
    IFS= read -r C
    ROOT="$HOME/luanti-voxelibre-server"
    OF="$ROOT/server/worlds/original/wetlands_contact.conf"
    VF="$ROOT/server/worlds/valdivia/wetlands_contact.conf"
    EF="$ROOT/.env"
    OT="$OF.tmp.$$"
    VT="$VF.tmp.$$"
    ET="$EF.tmp.$$"
    OB="$OF.bak.$$"
    VB="$VF.bak.$$"
    EB="$EF.bak.$$"
    OP="$OF.preserved.$$"
    NP="$OF.rebuilt.$$"
    ROLLBACK_READY=0
    COMMITTED=0
    rollback() {
        if [ "$ROLLBACK_READY" -eq 1 ] && [ "$COMMITTED" -eq 0 ]; then
            if [ -f "$OB" ]; then sudo mv "$OB" "$OF"; else sudo rm -f "$OF"; fi
            if [ -f "$VB" ]; then sudo mv "$VB" "$VF"; else sudo rm -f "$VF"; fi
            if [ -f "$EB" ]; then sudo mv "$EB" "$EF"; else sudo rm -f "$EF"; fi
        fi
        sudo rm -f "$OT" "$VT" "$ET" "$OB" "$VB" "$EB" "$OP" "$NP"
    }
    trap rollback EXIT

    # Validar Telegram antes de tocar configuraciones que ya funcionan.
    me=$(curl -fsS -X POST "https://api.telegram.org/bot$T/getMe") || {
        echo "No se pudo validar el token con getMe." >&2; exit 1;
    }
    case "$me" in *'"ok":true'*) ;; *) echo "Token inválido." >&2; exit 1 ;; esac

    webhook=$(curl -fsS -X POST "https://api.telegram.org/bot$T/getWebhookInfo") || {
        echo "No se pudo consultar getWebhookInfo." >&2; exit 1;
    }
    case "$webhook" in
        *'"ok":true'*'"url":""'*) ;;
        *'"ok":true'*) echo "El bot tiene un webhook activo; getUpdates no puede usarse." >&2; exit 1 ;;
        *) echo "Respuesta inválida de getWebhookInfo." >&2; exit 1 ;;
    esac

    chat=$(curl -fsS -X POST "https://api.telegram.org/bot$T/getChat" \
        --data-urlencode "chat_id=$C") || {
        echo "El bot no puede consultar el chat. Abre el bot y usa /start." >&2; exit 1;
    }
    case "$chat" in *'"ok":true'*'"type":"private"'*) ;; *)
        echo "TELEGRAM_CHAT_ID no corresponde a un chat privado accesible." >&2; exit 1 ;;
    esac
    compact=$(printf "%s" "$chat" | tr -d "[:space:]")
    case "$compact" in *"\"id\":$C,"*|*"\"id\":$C}"*) ;; *)
        echo "getChat devolvió un ID distinto." >&2; exit 1 ;;
    esac

    # Crear todos los temporales que pueden contener secretos antes de escribir.
    # install fija 0600 desde su creación, sin una ventana temporal 0644.
    sudo install -m 600 /dev/null "$OT"
    sudo install -m 600 /dev/null "$VT"
    sudo install -m 600 /dev/null "$ET"
    sudo install -m 600 /dev/null "$OP"
    sudo install -m 600 /dev/null "$NP"

    printf "%s\n" \
        "world_name = Wetlands" \
        "world_id = original" \
        "destination = telegram" \
        "telegram_token = $T" \
        "telegram_chat_id = $C" \
        "relay_url = http://wetlands-contact-relay:8788" | sudo tee "$OT" >/dev/null
    printf "%s\n" \
        "world_name = Valdivia" \
        "world_id = valdivia" \
        "destination = telegram" \
        "telegram_token = $T" \
        "telegram_chat_id = $C" \
        "relay_url = http://wetlands-contact-relay:8788" | sudo tee "$VT" >/dev/null

    # Mantener el resto del .env del VPS y reemplazar solo las dos variables del relay.
    filter_env() {
        sudo bash -c '\''set -euo pipefail
        umask 077
        src=$1
        dst=$2
        : > "$dst"
        if [ -f "$src" ]; then
          while IFS= read -r line || [ -n "$line" ]; do
            case "$line" in
                WETLANDS_TELEGRAM_BOT_TOKEN=*|WETLANDS_TELEGRAM_CHAT_ID=*) ;;
                *) printf "%s\n" "$line" >> "$dst" ;;
            esac
          done < "$src"
        fi'\'' bash "$1" "$2"
    }
    filter_env "$EF" "$OP"
    sudo cp "$OP" "$ET"
    printf "WETLANDS_TELEGRAM_BOT_TOKEN=%s\nWETLANDS_TELEGRAM_CHAT_ID=%s\n" "$T" "$C" |
        sudo tee -a "$ET" >/dev/null
    filter_env "$ET" "$NP"
    if ! sudo cmp -s "$OP" "$NP"; then
        echo "La reconstrucción de .env no preservó todas las líneas no objetivo." >&2
        exit 1
    fi
    sudo chown 1000:1000 "$OT" "$VT"
    sudo chmod 600 "$OT" "$VT"
    if sudo test -f "$EF"; then
        OWNER=$(sudo stat -c "%u:%g" "$EF")
    else
        OWNER="$(id -u):$(id -g)"
    fi
    sudo chown "$OWNER" "$ET"
    sudo chmod 600 "$ET"

    # Cada reemplazo es atómico. Los backups permiten revertir el grupo si un
    # rename excepcional falla a mitad de la operación.
    backup_file() {
        sudo bash -c '\''set -euo pipefail
        umask 077
        cp -p -- "$1" "$2"
        chmod 600 "$2"'\'' bash "$1" "$2"
    }
    if sudo test -f "$OF"; then backup_file "$OF" "$OB"; fi
    if sudo test -f "$VF"; then backup_file "$VF" "$VB"; fi
    if sudo test -f "$EF"; then backup_file "$EF" "$EB"; fi
    ROLLBACK_READY=1
    sudo mv "$OT" "$OF"
    sudo mv "$VT" "$VF"
    sudo mv "$ET" "$EF"

    # No confirmar el grupo hasta que Telegram acepte el mensaje de prueba. Si
    # falla, el trap restaura los tres archivos desde sus backups.
    body=$(curl -fsS -X POST "https://api.telegram.org/bot$T/sendMessage" \
        --data-urlencode "chat_id=$C" \
        --data-urlencode "text=🌿 Bot compartido conectado: Wetlands y Valdivia listos") || {
        echo "Falló el mensaje de prueba; se restaurará la configuración anterior." >&2
        exit 1
    }
    case "$body" in *'"ok":true'*) ;; *)
        echo "Telegram rechazó el mensaje de prueba; se restaurará la configuración anterior." >&2
        exit 1 ;;
    esac
    COMMITTED=1
    sudo rm -f "$OB" "$VB" "$EB" "$OP" "$NP"
    echo "OK: bot compartido configurado."
    echo "Original: $(sudo stat -c '\''%U:%G %a'\'' "$OF")"
    echo "Valdivia: $(sudo stat -c '\''%U:%G %a'\'' "$VF")"
    echo "Relay env: $(sudo stat -c '\''%U:%G %a'\'' "$EF")"
REMOTE_SCRIPT_EOF
)

# shellcheck disable=SC2029 # Expansión local intencional; el cuerpo no contiene secretos.
printf '%s\n%s\n' "$TOKEN" "$CHAT_ID" |
    ssh "$VPS_USER@$VPS_HOST" "bash -c $(printf '%q' "$REMOTE_SCRIPT")"
