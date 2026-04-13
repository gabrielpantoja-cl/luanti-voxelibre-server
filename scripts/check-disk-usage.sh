#!/bin/bash
# ============================================
# SCRIPT DE MONITOREO DE ESPACIO EN DISCO - luanti-voxelibre-server 🌱
# ============================================
# Verifica el uso de espacio en disco y registra alertas si excede los umbrales.
# Se ejecuta automáticamente vía cron.

set -e

# Configuración
DISK_PATH="$PROJECT_PATH"
WARNING_THRESHOLD=80
CRITICAL_THRESHOLD=90
LOG_DIR="$PROJECT_PATH/logs"
LOG_FILE="$LOG_DIR/disk-monitor.log"

# Crear directorio de logs si no existe
mkdir -p "$LOG_DIR"

# Función de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "🔍 Iniciando monitoreo de espacio en disco para $DISK_PATH..."

# Obtener uso de disco en porcentaje
DISK_USAGE=$(df "$DISK_PATH" | tail -1 | awk '{print $5}' | sed 's/%//')

log "📊 Uso actual del disco en $DISK_PATH: $DISK_USAGE%"

if (( DISK_USAGE >= CRITICAL_THRESHOLD )); then
    log "🔴 ALERTA CRÍTICA: El uso del disco ($DISK_USAGE%) ha alcanzado o superado el umbral crítico de $CRITICAL_THRESHOLD%."
    # Aquí se podría añadir una llamada a un webhook o sistema de notificación externo
elif (( DISK_USAGE >= WARNING_THRESHOLD )); then
    log "🟠 ADVERTENCIA: El uso del disco ($DISK_USAGE%) ha alcanzado o superado el umbral de advertencia de $WARNING_THRESHOLD%."
    # Aquí se podría añadir una llamada a un webhook o sistema de notificación externo
else
    log "✅ Uso del disco dentro de los límites normales."
fi

log "✅ Monitoreo de espacio en disco finalizado."
