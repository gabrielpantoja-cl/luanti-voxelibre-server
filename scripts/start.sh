#!/bin/bash
# =============================================
# SCRIPT DE INICIO - VEGAN WETLANDS 🌱
# =============================================

echo "🌱 Iniciando Vegan Wetlands Server..."

# Verificar que Docker esté corriendo
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker no está corriendo. Por favor, inicia Docker primero."
    exit 1
fi

# Verificar que docker-compose.yml existe
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ No se encuentra docker-compose.yml en el directorio actual"
    exit 1
fi

# Crear directorios necesarios si no existen
echo "📁 Verificando directorios..."
mkdir -p server/{config,mods,worlds,backups}

# Verificar configuración
if [ ! -f "server/config/luanti.conf" ]; then
    echo "⚠️  Advertencia: No se encuentra luanti.conf"
fi

# Levantar servicios
echo "🚀 Levantando servicios con Docker Compose..."
docker-compose up -d

# Verificar estado
echo "⏳ Esperando que el servidor inicie..."
sleep 15

echo "📊 Estado de los servicios:"
docker-compose ps

echo "📋 Logs recientes del servidor:"
docker-compose logs --tail=20 luanti-server

echo ""
echo "🌱 ========================================"
echo "🌱 ¡VEGAN WETLANDS ESTÁ LISTO!"
echo "🌱 ========================================"
echo "🌍 Servidor: luanti.gabrielpantoja.cl:30000"
echo "🎮 Modo: Creativo, sin violencia animal"
echo "👥 Máximo jugadores: 20"
echo "🔧 Gestión: docker-compose {up,down,logs,restart}"
echo "💾 Backups: scripts/backup.sh"
echo "🌱 ========================================"