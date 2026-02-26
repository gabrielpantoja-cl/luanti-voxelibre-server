#!/bin/bash
# ============================================
# SCRIPT DE BACKUP - VEGAN WETLANDS 🌱
# ============================================

# Configuración
BACKUP_DIR="/backups"
WORLD_DIR="/worlds"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_NAME="vegan_wetlands_backup_${DATE}"
MAX_BACKUPS=8

echo "🌱 [$(date)] Iniciando backup de Vegan Wetlands..."

# Crear directorio de backup si no existe
mkdir -p "$BACKUP_DIR"

# Crear backup comprimido del mundo
echo "📦 Creando backup del mundo..."
tar -czf "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" -C "$WORLD_DIR" . 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Backup creado exitosamente: ${BACKUP_NAME}.tar.gz"
    
    # Limpiar backups antiguos (mantener solo los últimos MAX_BACKUPS)
    echo "🧹 Limpiando backups antiguos..."
    cd "$BACKUP_DIR"
    ls -t vegan_wetlands_backup_*.tar.gz | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm
    
    echo "📊 Backups actuales:"
    ls -lh vegan_wetlands_backup_*.tar.gz 2>/dev/null || echo "No hay backups anteriores"
    
    # Opcional: notificar a webhook de n8n o Discord
    if [ ! -z "$WEBHOOK_URL" ]; then
        curl -X POST "$WEBHOOK_URL" \
             -H "Content-Type: application/json" \
             -d "{\"content\": \"🌱 Backup de Vegan Wetlands completado: ${BACKUP_NAME}.tar.gz\"}" \
             2>/dev/null || echo "⚠️  No se pudo enviar notificación"
    fi
    
else
    echo "❌ Error al crear backup"
    exit 1
fi

echo "🌱 [$(date)] Backup completado"