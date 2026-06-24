#!/bin/bash
# =============================================
# RESET GAELSIN WORLD - Wipe & regenera desde seed
# =============================================
# Para empezar GAELSIN de cero: este script
#   1) Detiene el container luanti-gaelsin (con su Discord notifier)
#   2) Mueve la carpeta actual a gaelsin_DESTROYED_<timestamp> como backup
#   3) Recrea el mundo fresco con setup-gaelsin-world.sh (mapa nuevo desde seed)
#   4) Re-arranca los containers
#
# Uso (en VPS, como gabriel con sudo):
#   sudo ./scripts/reset-gaelsin.sh

set -euo pipefail

REPO_ROOT="/home/gabriel/luanti-voxelibre-server"
DST_WORLD="${REPO_ROOT}/server/worlds/gaelsin"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_DIR="${REPO_ROOT}/server/worlds/gaelsin_DESTROYED_${TIMESTAMP}"

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Este script requiere sudo."
    exit 1
fi

cd "${REPO_ROOT}"

echo ">>> Detiene containers de GAELSIN"
docker compose stop luanti-gaelsin discord-notifier-gaelsin 2>&1 | tail -5 || true

if [ -d "${DST_WORLD}" ]; then
    echo ">>> Mueve mundo actual a backup: ${ARCHIVE_DIR}"
    mv "${DST_WORLD}" "${ARCHIVE_DIR}"
    echo "   (Para borrar definitivamente: sudo rm -rf ${ARCHIVE_DIR})"
else
    echo ">>> ${DST_WORLD} no existe (primera vez?), saltando archive."
fi

echo ">>> Regenerando mundo fresco desde seed GAELSIN..."
"${REPO_ROOT}/scripts/setup-gaelsin-world.sh"

echo ">>> Re-arrancando containers"
docker compose up -d luanti-gaelsin discord-notifier-gaelsin 2>&1 | tail -5

echo ""
echo "=============================================="
echo "GAELSIN RESETADO. Container reiniciado."
echo "=============================================="
echo "Backup del mundo anterior: ${ARCHIVE_DIR}"
echo ""
echo "Verificar logs:"
echo "  docker logs --since=2m luanti-gaelsin-server 2>&1 | grep -iE 'error|listening'"
echo ""
echo "Limpieza de backups antiguos (mas de 7 dias):"
echo "  sudo find ${REPO_ROOT}/server/worlds -maxdepth 1 -type d -name 'gaelsin_DESTROYED_*' -mtime +7 -exec rm -rf {} +"
