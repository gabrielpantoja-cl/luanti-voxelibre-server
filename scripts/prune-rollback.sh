#!/usr/bin/env bash
# ============================================
# PODA DE rollback.sqlite - Luanti / Wetlands
# ============================================
# Luanti NUNCA limpia rollback.sqlite por si solo (builtin/settingtypes.txt:
# "Luanti will not automatically clean old entries from the rollback database").
# El archivo crece indefinidamente. Este script borra las acciones mas antiguas
# que RETENTION_DAYS y compacta el archivo.
#
# SEGURIDAD DE CONCURRENCIA
# RollbackManager::flush() usa BEGIN/INSERT sin manejo de SQLITE_BUSY: ante un
# lock ajeno lanza FileNotGoodException y tumba el servidor (src/server/
# rollback.cpp, macro SQLRES). Por eso el modo por defecto DETIENE el
# contenedor antes de tocar la base y lo vuelve a levantar al terminar.
# Detener el contenedor ademas dispara el destructor ~RollbackManager, que
# vuelca a disco lo que quede en el buffer: no se pierde nada.
#
# USO
#   ./scripts/prune-rollback.sh <mundo> [dias] [--dry-run]
#   ./scripts/prune-rollback.sh gaelsin            # poda a 90 dias
#   ./scripts/prune-rollback.sh gaelsin 30
#   ./scripts/prune-rollback.sh gaelsin 90 --dry-run
#
# CRON MENSUAL EN EL VPS (host, no el sidecar: necesita el socket de docker)
#   0 5 1 * * /home/gabriel/luanti-voxelibre-server/scripts/prune-rollback.sh \
#     gaelsin 90 >> /home/gabriel/rollback-prune.log 2>&1

set -euo pipefail

WORLD="${1:-}"
RETENTION_DAYS="${2:-90}"
DRY_RUN="${3:-}"

# Umbral de alerta: por encima de esto conviene bajar RETENTION_DAYS.
ALERT_MB=200

if [ -z "$WORLD" ]; then
    echo "ERROR: falta el nombre del mundo. Uso: $0 <mundo> [dias] [--dry-run]" >&2
    exit 1
fi

case "$RETENTION_DAYS" in
    ''|*[!0-9]*) echo "ERROR: los dias deben ser un entero, no '$RETENTION_DAYS'" >&2; exit 1 ;;
esac

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB="$REPO_DIR/server/worlds/$WORLD/rollback.sqlite"

# Nombre del contenedor por mundo (mismo mapeo que docker-compose.yml).
case "$WORLD" in
    original)   CONTAINER="luanti-voxelibre-server" ;;
    valdivia)   CONTAINER="luanti-valdivia-server" ;;
    gaelsin)    CONTAINER="luanti-gaelsin-server" ;;
    ctf)        CONTAINER="luanti-ctf-server" ;;
    mineclonia) CONTAINER="luanti-mineclonia-server" ;;
    *) echo "ERROR: mundo desconocido '$WORLD'" >&2; exit 1 ;;
esac

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

if ! sudo test -f "$DB"; then
    log "No existe $DB - nada que podar (rollback desactivado en este mundo?)"
    exit 0
fi

SIZE_BEFORE=$(sudo stat -c %s "$DB")
SIZE_BEFORE_MB=$(( SIZE_BEFORE / 1024 / 1024 ))
CUTOFF=$(date -d "$RETENTION_DAYS days ago" +%s)

log "Mundo: $WORLD | contenedor: $CONTAINER"
log "Base:  $DB (${SIZE_BEFORE_MB} MB)"
log "Corte: $(date -d "@$CUTOFF" '+%Y-%m-%d %H:%M:%S') (retencion ${RETENTION_DAYS} dias)"

TO_DELETE=$(sudo sqlite3 "$DB" "SELECT COUNT(*) FROM action WHERE timestamp < $CUTOFF;")
TOTAL=$(sudo sqlite3 "$DB" "SELECT COUNT(*) FROM action;")
log "Acciones: $TOTAL totales, $TO_DELETE mas antiguas que el corte"

if [ "$SIZE_BEFORE_MB" -ge "$ALERT_MB" ]; then
    log "AVISO: rollback.sqlite supera ${ALERT_MB} MB. Considera bajar RETENTION_DAYS."
fi

if [ "$DRY_RUN" = "--dry-run" ]; then
    log "--dry-run: no se modifica nada."
    exit 0
fi

if [ "$TO_DELETE" -eq 0 ]; then
    log "Nada que borrar. Fin."
    exit 0
fi

WAS_RUNNING=no
if [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null)" = "true" ]; then
    WAS_RUNNING=yes
    log "Deteniendo $CONTAINER (apagado limpio: vuelca el buffer de rollback)..."
    docker stop -t 60 "$CONTAINER" >/dev/null
fi

# Se levanta el contenedor pase lo que pase con la poda.
restore_container() {
    if [ "$WAS_RUNNING" = "yes" ]; then
        log "Levantando $CONTAINER..."
        docker start "$CONTAINER" >/dev/null
    fi
}
trap restore_container EXIT

log "Respaldo previo -> ${DB}.bak-$(date +%Y%m%d_%H%M%S)"
sudo cp -p "$DB" "${DB}.bak-$(date +%Y%m%d_%H%M%S)"

log "Borrando $TO_DELETE acciones y compactando..."
sudo sqlite3 "$DB" <<SQL
PRAGMA busy_timeout = 30000;
DELETE FROM action WHERE timestamp < $CUTOFF;
DELETE FROM actor WHERE id NOT IN (SELECT DISTINCT actor FROM action);
VACUUM;
SQL

# El contenedor corre con PUID/PGID 1000: hay que devolver el owner.
sudo chown 1000:1000 "$DB"

SIZE_AFTER=$(sudo stat -c %s "$DB")
REMAINING=$(sudo sqlite3 "$DB" "SELECT COUNT(*) FROM action;")
log "Listo: $REMAINING acciones, $(( SIZE_AFTER / 1024 / 1024 )) MB (antes ${SIZE_BEFORE_MB} MB)"
