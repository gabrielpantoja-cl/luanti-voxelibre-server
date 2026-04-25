#!/bin/bash
# =============================================
# RESET INFIERNO WORLD - Wipe & restore desde Wetlands
# =============================================
# Cuando el caos en Infierno llega muy lejos y los jugadores quieren empezar
# de nuevo: este script
#   1) Detiene el container luanti-infierno (con su Discord notifier)
#   2) Mueve la carpeta actual a infierno_DESTROYED_<timestamp> como backup
#   3) Re-clona desde el mundo principal (puerto 30000) usando setup-infierno
#   4) Re-arranca los containers
#
# Tiempo aproximado: 10-30 segundos (segun tamano de map.sqlite, ~880 MB).
#
# Uso (en VPS, como gabriel con sudo):
#   sudo ./scripts/reset-infierno.sh

set -euo pipefail

REPO_ROOT="/home/gabriel/luanti-voxelibre-server"
DST_WORLD="${REPO_ROOT}/server/worlds/infierno"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_DIR="${REPO_ROOT}/server/worlds/infierno_DESTROYED_${TIMESTAMP}"

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Este script requiere sudo."
    exit 1
fi

cd "${REPO_ROOT}"

echo ">>> Detiene containers de infierno"
docker compose stop luanti-infierno discord-notifier-infierno 2>&1 | tail -5 || true

if [ -d "${DST_WORLD}" ]; then
    echo ">>> Mueve mundo actual a backup: ${ARCHIVE_DIR}"
    mv "${DST_WORLD}" "${ARCHIVE_DIR}"
    echo "   (Para borrar definitivamente: sudo rm -rf ${ARCHIVE_DIR})"
else
    echo ">>> ${DST_WORLD} no existe (primera vez?), saltando archive."
fi

echo ">>> Re-clonando mundo desde Wetlands (puerto 30000)..."
"${REPO_ROOT}/scripts/setup-infierno-world.sh"

echo ">>> Re-arrancando containers"
docker compose up -d luanti-infierno discord-notifier-infierno 2>&1 | tail -5

echo ""
echo "=============================================="
echo "INFIERNO RESETADO. Container reiniciado."
echo "=============================================="
echo "Backup del mundo destruido: ${ARCHIVE_DIR}"
echo ""
echo "Verificar logs:"
echo "  docker logs --since=2m luanti-infierno-server 2>&1 | grep -iE 'error|listening'"
echo ""
echo "Limpieza de backups antiguos (mas de 7 dias):"
echo "  sudo find ${REPO_ROOT}/server/worlds -maxdepth 1 -type d -name 'infierno_DESTROYED_*' -mtime +7 -exec rm -rf {} +"
