#!/bin/bash
set -e

echo "🔧 Script de Recuperación: Botes Corruptos"
echo "========================================"

# Variables
VPS="gabriel@${VPS_HOST}"
PROJECT_DIR="/home/gabriel/luanti-voxelibre-server"
BACKUP_DIR="$PROJECT_DIR/server/worlds/world_BACKUP_$(date +%Y%m%d_%H%M%S)"

echo ""
echo "📊 Paso 1: Verificando estado del servidor..."
ssh $VPS "cd $PROJECT_DIR && docker-compose ps | grep luanti-voxelibre-server"

echo ""
echo "💾 Paso 2: Creando backup del mundo..."
ssh $VPS "cd $PROJECT_DIR && cp -r server/worlds/world $BACKUP_DIR && echo '✅ Backup creado en: $BACKUP_DIR'"

echo ""
echo "🧹 Paso 3: Deteniendo el servidor..."
ssh $VPS "cd $PROJECT_DIR && docker-compose stop luanti-server"

echo ""
echo "🗑️  Paso 4: Eliminando entidades corruptas del mundo..."
# Eliminar archivos de entidades activas (Active Block Modifiers)
ssh $VPS "cd $PROJECT_DIR && find server/worlds/world -name 'entities' -type f -delete && echo '✅ Archivos de entidades eliminados'"

echo ""
echo "🔄 Paso 5: Reiniciando el servidor..."
ssh $VPS "cd $PROJECT_DIR && docker-compose up -d luanti-server"

echo ""
echo "⏳ Esperando 10 segundos para que el servidor inicie..."
sleep 10

echo ""
echo "📋 Paso 6: Verificando logs del servidor..."
ssh $VPS "cd $PROJECT_DIR && docker-compose logs --tail=30 luanti-server | grep -E '(ERROR|WARNING|Started serving)'"

echo ""
echo "✅ Recuperación completada!"
echo ""
echo "📂 Backup guardado en: $BACKUP_DIR"
echo "🔍 Verifica que no haya errores en los logs arriba"
echo ""
echo "Si el problema persiste, ejecuta:"
echo "  docker-compose logs -f luanti-server"
