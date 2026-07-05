#!/bin/bash
# Backup de los 3 mundos Luanti: original (Wetlands, ex "world"), valdivia, gaelsin.
# Hace snapshot consistente de SQLite con `sqlite3 .backup`, copia el resto
# con rsync excluyendo basura, y comprime el staging a tar.gz.
# Corre dentro del contenedor luanti-voxelibre-backup (Alpine + dcron).
set -u

BACKUP_DIR="/backups"
WORLD_DIR="/worlds"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_NAME="luanti_worlds_backup_${DATE}"
WORLDS="original valdivia gaelsin"
MAX_BACKUPS=8

mkdir -p "$BACKUP_DIR"

STAGING=$(mktemp -d)
trap 'rm -rf "$STAGING"' EXIT

echo "[$(date)] Snapshot consistente de mundos..."
for w in $WORLDS; do
  if [ ! -d "$WORLD_DIR/$w" ]; then
    echo "  WARN: $w no existe en $WORLD_DIR, se omite"
    continue
  fi
  mkdir -p "$STAGING/$w"

  # Snapshot consistente de cada SQLite del mundo.
  # Los servers Luanti mantienen lock continuo; usamos .timeout 60s y
  # caemos a copia directa si el lock no se libera (degrada al mismo
  # comportamiento del tar legacy: snapshot puede quedar levemente
  # inconsistente pero SQLite suele recuperarse al reabrir).
  for db in "$WORLD_DIR/$w"/*.sqlite; do
    [ -f "$db" ] || continue
    dest="$STAGING/$w/$(basename "$db")"
    if sqlite3 -cmd ".timeout 60000" "$db" ".backup '$dest'" 2>/dev/null; then
      echo "  OK snapshot: $(basename "$db")"
    else
      echo "  WARN: $(basename "$db") locked tras 60s, fallback a cp"
      cp "$db" "$dest"
      sync
    fi
  done

  # Resto de archivos. Excluye:
  #  - los .sqlite limpios (ya snapshoteados arriba con sqlite3 .backup)
  #  - artefactos de SQLite en caliente (-journal/-wal/-shm) via *.sqlite-*
  #  - CUALQUIER copia/version vieja de un .sqlite via *.sqlite.* — cubre
  #    map.sqlite.backup-before-remap, map.sqlite.v4, auth.sqlite.backup.YYYYMMDD,
  #    etc. (antes se colaban ~2 GB de estas copias en cada tarball porque el
  #    patron viejo *.sqlite.backup.* solo matcheaba la variante con punto).
  rsync -a \
    --exclude='*.sqlite' \
    --exclude='*.sqlite-*' \
    --exclude='*.sqlite.*' \
    --exclude='*.bak' \
    --exclude='*.bak.*' \
    "$WORLD_DIR/$w/" "$STAGING/$w/"
done

echo "[$(date)] Comprimiendo a $BACKUP_NAME.tar.gz..."
tar -czf "$BACKUP_DIR/${BACKUP_NAME}.tar.gz" -C "$STAGING" .

SIZE=$(du -sh "$BACKUP_DIR/${BACKUP_NAME}.tar.gz" | cut -f1)
echo "[$(date)] Backup OK: ${BACKUP_NAME}.tar.gz ($SIZE)"

# Rotación inline: matchea ambos prefijos (legacy vegan_wetlands_* y nuevo luanti_worlds_*)
cd "$BACKUP_DIR"
ls -t luanti_worlds_backup_*.tar.gz vegan_wetlands_backup_*.tar.gz 2>/dev/null \
  | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm -f

echo "[$(date)] Backups actuales en disco:"
ls -lh luanti_worlds_backup_*.tar.gz vegan_wetlands_backup_*.tar.gz 2>/dev/null || true
