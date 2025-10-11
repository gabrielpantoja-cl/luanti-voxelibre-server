#!/bin/bash
# ============================================
# SYNC WORLD TO REPOSITORY - VEGAN WETLANDS 🌱
# ============================================
# Sincroniza el mundo del VPS al repositorio local
# para backup distribuido via GitHub

set -e

# Configuración
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORLD_BACKUP_DIR="$REPO_DIR/world-snapshots"
VPS_HOST="gabriel@167.172.251.27"
VPS_WORLD_PATH="/home/gabriel/luanti-voxelibre-server/server/worlds"
DATE=$(date +%Y%m%d-%H%M%S)
SNAPSHOT_NAME="world-snapshot-${DATE}"

echo "🌍 [$(date)] Iniciando sincronización de mundo desde VPS..."

# Crear directorio de snapshots si no existe
mkdir -p "$WORLD_BACKUP_DIR"

# 1. Crear snapshot comprimido desde VPS
echo "📦 Creando snapshot del mundo en VPS..."
ssh "$VPS_HOST" "cd /home/gabriel/luanti-voxelibre-server && tar -czf /tmp/${SNAPSHOT_NAME}.tar.gz -C server/worlds ."

# 2. Descargar snapshot al repositorio
echo "⬇️  Descargando snapshot al repositorio..."
scp "$VPS_HOST:/tmp/${SNAPSHOT_NAME}.tar.gz" "$WORLD_BACKUP_DIR/"

# 3. Limpiar archivo temporal en VPS
ssh "$VPS_HOST" "rm /tmp/${SNAPSHOT_NAME}.tar.gz"

# 4. Mantener solo los 5 snapshots más recientes
echo "🧹 Limpiando snapshots antiguos..."
cd "$WORLD_BACKUP_DIR"
ls -t world-snapshot-*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm

# 5. Generar reporte de sync
SNAPSHOT_SIZE=$(du -h "$WORLD_BACKUP_DIR/${SNAPSHOT_NAME}.tar.gz" | cut -f1)
TOTAL_SNAPSHOTS=$(ls -1 world-snapshot-*.tar.gz 2>/dev/null | wc -l)

echo "✅ Sincronización completada:"
echo "   📁 Archivo: ${SNAPSHOT_NAME}.tar.gz"
echo "   📊 Tamaño: $SNAPSHOT_SIZE"
echo "   🗂️  Total snapshots: $TOTAL_SNAPSHOTS"

# 6. Opcional: Auto-commit al repositorio
if [ "$1" = "--commit" ]; then
    echo "📝 Commiteando snapshot al repositorio..."
    cd "$REPO_DIR"
    git add world-snapshots/
    git commit -m "📦 World snapshot: ${SNAPSHOT_NAME}

🌍 Backup automático del mundo luanti-voxelibre-server
📊 Tamaño: $SNAPSHOT_SIZE | Total: $TOTAL_SNAPSHOTS snapshots
📅 $(date '+%Y-%m-%d %H:%M:%S %Z')

🤖 Generated with Claude Code" || echo "⚠️  No hay cambios para commitear"
fi

echo "🌱 [$(date)] Sincronización completada exitosamente"