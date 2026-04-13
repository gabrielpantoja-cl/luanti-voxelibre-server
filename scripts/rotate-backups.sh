#!/bin/bash
# ============================================
# SCRIPT DE ROTACIÓN DE BACKUPS - luanti-voxelibre-server 🌱
# ============================================
# Elimina backups más antiguos que RETENTION_DAYS
# Se ejecuta automáticamente vía cron

set -e

# Configuración
BACKUP_DIR="$PROJECT_PATH/server/backups"
RETENTION_DAYS=10
LOG_DIR="$PROJECT_PATH/logs"
LOG_FILE="$LOG_DIR/backup-rotation.log"

# Crear directorio de logs si no existe
mkdir -p "$LOG_DIR"

# Función de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "🌱 Iniciando rotación de backups de luanti-voxelibre-server..."

# Verificar que el directorio existe
if [ ! -d "$BACKUP_DIR" ]; then
    log "❌ ERROR: Directorio $BACKUP_DIR no existe"
    exit 1
fi

# Contar backups antes de limpiar
TOTAL_BEFORE=$(find "$BACKUP_DIR" -name "luanti_voxelibre_backup_*.tar.gz" | wc -l)
SIZE_BEFORE=$(du -sh "$BACKUP_DIR" | cut -f1)

log "📊 Estado actual: $TOTAL_BEFORE backups ($SIZE_BEFORE)"

# Eliminar backups más antiguos que RETENTION_DAYS
DELETED=0
while IFS= read -r backup; do
    log "🗑️  Eliminando: $(basename "$backup")"
    rm -f "$backup"
    ((DELETED++))
done < <(find "$BACKUP_DIR" -name "luanti_voxelibre_backup_*.tar.gz" -type f -mtime +$RETENTION_DAYS)

# Contar backups después de limpiar
TOTAL_AFTER=$(find "$BACKUP_DIR" -name "luanti_voxelibre_backup_*.tar.gz" | wc -l)
SIZE_AFTER=$(du -sh "$BACKUP_DIR" | cut -f1)

log "✅ Rotación completada:"
log "   - Backups eliminados: $DELETED"
log "   - Backups restantes: $TOTAL_AFTER"
log "   - Espacio antes: $SIZE_BEFORE"
log "   - Espacio después: $SIZE_AFTER"

# Listar los 5 backups más recientes
log "📋 Backups más recientes:"
find "$BACKUP_DIR" -name "luanti_voxelibre_backup_*.tar.gz" -type f -printf "%T@ %f\n" | \
    sort -rn | head -5 | cut -d' ' -f2 | while read -r filename; do
    log "   ✓ $filename"
done

log "🌱 Rotación finalizada exitosamente"
