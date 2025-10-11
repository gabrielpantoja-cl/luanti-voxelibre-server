#!/bin/bash
# ============================================
# RESTORE WORLD FROM REPOSITORY - luanti-voxelibre-server 🌱
# ============================================
# Restaura un snapshot del mundo desde el repositorio al VPS

set -e

# Configuración
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORLD_BACKUP_DIR="$REPO_DIR/world-snapshots"
VPS_HOST="gabriel@167.172.251.27"
VPS_WORLD_PATH="/home/gabriel/luanti-voxelibre-server/server/worlds"

# Función de ayuda
show_help() {
    echo "🌍 Restaurar mundo desde repositorio al VPS"
    echo ""
    echo "Uso:"
    echo "  $0 <snapshot-file>     Restaurar snapshot específico"
    echo "  $0 --latest           Restaurar el snapshot más reciente"
    echo "  $0 --list             Listar snapshots disponibles"
    echo ""
    echo "Ejemplos:"
    echo "  $0 world-snapshot-20250925-120000.tar.gz"
    echo "  $0 --latest"
}

# Verificar argumentos
if [ $# -eq 0 ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# Listar snapshots disponibles
if [ "$1" = "--list" ]; then
    echo "📂 Snapshots disponibles en el repositorio:"
    if [ -d "$WORLD_BACKUP_DIR" ] && [ "$(ls -A $WORLD_BACKUP_DIR/*.tar.gz 2>/dev/null)" ]; then
        cd "$WORLD_BACKUP_DIR"
        ls -lht world-snapshot-*.tar.gz | while read -r line; do
            echo "   $line"
        done
    else
        echo "   ⚠️  No hay snapshots disponibles"
        echo "   💡 Ejecuta ./scripts/sync-world-to-repo.sh primero"
    fi
    exit 0
fi

# Determinar archivo de snapshot
if [ "$1" = "--latest" ]; then
    if [ ! -d "$WORLD_BACKUP_DIR" ]; then
        echo "❌ Error: Directorio de snapshots no existe"
        exit 1
    fi

    SNAPSHOT_FILE=$(ls -t "$WORLD_BACKUP_DIR"/world-snapshot-*.tar.gz 2>/dev/null | head -1)
    if [ -z "$SNAPSHOT_FILE" ]; then
        echo "❌ Error: No hay snapshots disponibles"
        exit 1
    fi
    SNAPSHOT_NAME=$(basename "$SNAPSHOT_FILE")
else
    SNAPSHOT_NAME="$1"
    SNAPSHOT_FILE="$WORLD_BACKUP_DIR/$SNAPSHOT_NAME"

    if [ ! -f "$SNAPSHOT_FILE" ]; then
        echo "❌ Error: Snapshot no encontrado: $SNAPSHOT_NAME"
        echo "💡 Usa '$0 --list' para ver snapshots disponibles"
        exit 1
    fi
fi

# Confirmación de seguridad
echo "⚠️  ADVERTENCIA: Esta operación sobrescribirá el mundo actual en el VPS"
echo "📁 Snapshot a restaurar: $SNAPSHOT_NAME"
echo "🗂️  Tamaño: $(du -h "$SNAPSHOT_FILE" | cut -f1)"
echo ""
read -p "¿Estás seguro? (yes/no): " -r
if [[ ! $REPLY =~ ^(yes|YES|y|Y)$ ]]; then
    echo "❌ Operación cancelada"
    exit 1
fi

echo "🌍 [$(date)] Iniciando restauración desde snapshot..."

# 1. Crear backup de emergencia del mundo actual en VPS
echo "🛡️  Creando backup de emergencia del mundo actual..."
EMERGENCY_BACKUP="emergency_backup_$(date +%Y%m%d_%H%M%S)"
ssh "$VPS_HOST" "cd /home/gabriel/luanti-voxelibre-server && cp -r server/worlds server/worlds_${EMERGENCY_BACKUP}"

# 2. Detener servidor Luanti
echo "⏸️  Deteniendo servidor Luanti..."
ssh "$VPS_HOST" "cd /home/gabriel/luanti-voxelibre-server && docker-compose stop luanti-server"

# 3. Subir snapshot al VPS
echo "⬆️  Subiendo snapshot al VPS..."
scp "$SNAPSHOT_FILE" "$VPS_HOST:/tmp/$SNAPSHOT_NAME"

# 4. Restaurar mundo
echo "🔄 Restaurando mundo..."
ssh "$VPS_HOST" "
    cd /home/gabriel/luanti-voxelibre-server &&
    rm -rf server/worlds/* &&
    tar -xzf /tmp/$SNAPSHOT_NAME -C server/worlds/ &&
    rm /tmp/$SNAPSHOT_NAME &&
    chown -R 1000:1000 server/worlds
"

# 5. Reiniciar servidor
echo "🚀 Reiniciando servidor Luanti..."
ssh "$VPS_HOST" "cd /home/gabriel/luanti-voxelibre-server && docker-compose start luanti-server"

# 6. Verificar restauración
echo "🔍 Verificando restauración..."
sleep 10
if ssh "$VPS_HOST" "cd /home/gabriel/luanti-voxelibre-server && docker-compose ps luanti-server | grep -q 'Up'"; then
    echo "✅ Restauración completada exitosamente"
    echo "🌱 Servidor funcionando correctamente"
    echo "🛡️  Backup de emergencia disponible en: worlds_${EMERGENCY_BACKUP}"
else
    echo "❌ Error: Servidor no está funcionando después de la restauración"
    echo "🔧 Revisa los logs: ssh gabriel@167.172.251.27 'cd /home/gabriel/luanti-voxelibre-server && docker-compose logs luanti-server'"
    exit 1
fi

echo "🌍 [$(date)] Restauración completada"