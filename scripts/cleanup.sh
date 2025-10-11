#!/bin/bash
# ============================================
# SCRIPT DE LIMPIEZA DEL SISTEMA - luanti-voxelibre-server 🌱
# ============================================
# Realiza limpieza de Docker y archivos temporales para liberar espacio.
# Se ejecuta automáticamente vía cron.

set -e

# Configuración
LOG_DIR="/home/gabriel/luanti-voxelibre-server/logs"
LOG_FILE="$LOG_DIR/cleanup.log"
TEMP_DIR="/tmp"
TEMP_RETENTION_DAYS=7

# Crear directorio de logs si no existe
mkdir -p "$LOG_DIR"

# Función de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "🧹 Iniciando limpieza del sistema luanti-voxelibre-server..."

# 1. Limpieza de Docker
log "🐳 Ejecutando docker system prune -f --volumes..."
# Elimina todos los contenedores detenidos, redes no utilizadas, imágenes colgantes y el caché de compilación.
# --volumes también elimina volúmenes no utilizados.
docker system prune -f --volumes >> "$LOG_FILE" 2>&1
log "✅ Limpieza de Docker completada."

# 2. Limpieza de archivos temporales en /tmp
log "🗑️  Eliminando archivos temporales antiguos en $TEMP_DIR..."
# Elimina archivos en /tmp más antiguos que TEMP_RETENTION_DAYS
find "$TEMP_DIR" -type f -atime +$TEMP_RETENTION_DAYS -delete >> "$LOG_FILE" 2>&1
log "✅ Limpieza de archivos temporales completada."

log "✅ Limpieza del sistema finalizada."
