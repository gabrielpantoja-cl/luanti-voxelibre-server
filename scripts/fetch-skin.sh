#!/usr/bin/env bash
# Descarga un skin de Minecraft y lo deja listo en 64x32 para Luanti.
#
# Uso:
#   ./scripts/fetch-skin.sh <fuente> <salida_64x32.png> [original_64x64.png]
#
# Fuentes (ver docs/00-SHARED/mods/SKIN_SOURCES.md):
#   msn:<slug>        www.minecraftskins.net/<slug>/download
#   mcs:<slug>        mc-skins.net/texture/<slug>.png
#   player:<nombre>   mc-heads.net/skin/<nombre>   (skin real de esa cuenta)
#   uuid:<uuid>       crafatar.com/skins/<uuid>
#   https://...       URL directa a un PNG
#
# Ejemplos:
#   ./scripts/fetch-skin.sh msn:trendyguy \
#       server/mods/valdivia_transeuntes/textures/valdivia_transeunte_vecino_3.png \
#       server/mods/valdivia_transeuntes/raw_skins/vecino_3_64x64.png
#
# El tercer argumento es opcional pero RECOMENDADO: guarda el 64x64 original
# para poder re-convertir sin volver a descargar (y sin depender de que el
# sitio siga en linea).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

if [ $# -lt 2 ]; then
    sed -n '2,21p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
    exit 1
fi

fuente="$1"
salida="$2"
original="${3:-}"

case "$fuente" in
    msn:*)    url="https://www.minecraftskins.net/${fuente#msn:}/download" ;;
    mcs:*)    url="https://mc-skins.net/texture/${fuente#mcs:}.png" ;;
    player:*) url="https://mc-heads.net/skin/${fuente#player:}" ;;
    uuid:*)   url="https://crafatar.com/skins/${fuente#uuid:}" ;;
    http*)    url="$fuente" ;;
    *) echo "fuente no reconocida: $fuente (usa msn: / mcs: / player: / uuid: / https://)" >&2; exit 1 ;;
esac

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
crudo="$tmp/raw.png"

echo "-> $url"
code="$(curl -sL -m 30 -A "$UA" -w '%{http_code}' -o "$crudo" "$url")"
if [ "$code" != "200" ]; then
    echo "HTTP $code — el sitio rechazo la descarga." >&2
    echo "Si es 403 es el muro de bots de Cloudflare: bajalo a mano desde el navegador" >&2
    echo "y pasa el PNG a scripts/convert-skin.py directamente." >&2
    exit 1
fi
if ! head -c 8 "$crudo" | grep -q 'PNG'; then
    echo "lo que llego no es un PNG (pagina de error / HTML)." >&2
    exit 1
fi

mkdir -p "$(dirname "$salida")"
if [ -n "$original" ]; then
    mkdir -p "$(dirname "$original")"
    cp "$crudo" "$original"
    echo "original 64x64 -> $original"
fi

# Python en Windows no entiende las rutas POSIX de Git Bash: traducir con cygpath.
topath() { if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else echo "$1"; fi; }

# Sin `python -I`: PIL vive en el site-packages del usuario y -I lo ignora.
python "$(topath "$REPO/scripts/convert-skin.py")" "$(topath "$crudo")" "$(topath "$salida")"
echo "listo -> $salida"
