#!/bin/sh
# ============================================
# SCRIPT DE ROTACIÓN DE BACKUPS - VEGAN WETLANDS 🌱
# ============================================
# Ejecutado DENTRO del contenedor backup-cron
# Elimina backups más antiguos que RETENTION_DAYS

set -e

# Configuración (rutas del contenedor)
BACKUP_DIR="/backups"
RETENTION_DAYS=7

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🌱 Iniciando rotación de backups de Vegan Wetlands..."

# Verificar que el directorio existe
if [ ! -d "$BACKUP_DIR" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ ERROR: Directorio $BACKUP_DIR no existe"
    exit 1
fi

# Contar backups antes de limpiar
TOTAL_BEFORE=$(find "$BACKUP_DIR" -name "vegan_wetlands_backup_*.tar.gz" | wc -l)
SIZE_BEFORE=$(du -sh "$BACKUP_DIR" | cut -f1)

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 📊 Estado actual: $TOTAL_BEFORE backups ($SIZE_BEFORE)"

# Eliminar backups más antiguos que RETENTION_DAYS
DELETED=0
find "$BACKUP_DIR" -name "vegan_wetlands_backup_*.tar.gz" -type f -mtime +$RETENTION_DAYS | while read -r backup; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🗑️  Eliminando: $(basename "$backup")"
    rm -f "$backup"
    DELETED=$((DELETED + 1))
done

# Contar backups después de limpiar
TOTAL_AFTER=$(find "$BACKUP_DIR" -name "vegan_wetlands_backup_*.tar.gz" | wc -l)
SIZE_AFTER=$(du -sh "$BACKUP_DIR" | cut -f1)

echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ Rotación completada:"
echo "[$(date '+%Y-%m-%d %H:%M:%S')]    - Backups antes: $TOTAL_BEFORE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')]    - Backups después: $TOTAL_AFTER"
echo "[$(date '+%Y-%m-%d %H:%M:%S')]    - Espacio antes: $SIZE_BEFORE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')]    - Espacio después: $SIZE_AFTER"

# Listar los 5 backups más recientes
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 📋 Backups más recientes:"
find "$BACKUP_DIR" -name "vegan_wetlands_backup_*.tar.gz" -type f -exec ls -lh {} \; | \
    sort -k6,7 -r | head -5 | awk '{print $NF}' | while read -r filename; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')]    ✓ $(basename "$filename")"
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🌱 Rotación finalizada exitosamente"
