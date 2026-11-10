#!/usr/bin/env bash
# Trae los world.mt reales del VPS a server/config/world-mt/<mundo>.world.mt.
#
# Los world.mt son el gate autoritativo de mods y viven SOLO en el VPS
# (server/worlds/<mundo>/world.mt, owner 1000:1000, gitignored). Este espejo es
# de solo lectura: sirve para ver/diffear el estado real desde el repo. Nunca se
# despliega de vuelta — para cambiar un world.mt se edita en el VPS (sudo) y
# luego se corre este script para actualizar el espejo.
#
# Uso:  set -a; source .env; set +a; ./scripts/sync-world-mt.sh [mundo ...]
set -euo pipefail

: "${VPS_USER:?falta VPS_USER (source .env)}"
: "${VPS_HOST:?falta VPS_HOST (source .env)}"

WORLDS=("$@")
[ ${#WORLDS[@]} -eq 0 ] && WORLDS=(original valdivia gaelsin plano mineclonia)

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/server/config/world-mt"
mkdir -p "$DEST"

for w in "${WORLDS[@]}"; do
    out="$DEST/$w.world.mt"
    if ssh "$VPS_USER@$VPS_HOST" "sudo cat /home/$VPS_USER/luanti-voxelibre-server/server/worlds/$w/world.mt" > "$out.tmp"; then
        mv "$out.tmp" "$out"
        echo "ok  $w ($(grep -c '^load_mod_' "$out") load_mod_*)"
    else
        rm -f "$out.tmp"
        echo "ERR $w: no se pudo leer world.mt" >&2
    fi
done

git -C "$ROOT" status --short -- server/config/world-mt
