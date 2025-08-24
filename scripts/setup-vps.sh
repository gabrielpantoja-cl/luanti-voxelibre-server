#!/bin/bash
# =============================================
# SCRIPT DE CONFIGURACIÓN VPS - VEGAN WETLANDS
# =============================================

echo "🌱 Configurando VPS para Vegan Wetlands..."

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Este script debe ejecutarse desde el directorio raíz del proyecto"
    exit 1
fi

# Instalar dependencias si no están disponibles
echo "📦 Verificando dependencias..."

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "🐳 Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker $USER
    systemctl enable docker
    systemctl start docker
fi

# Verificar Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "🔧 Instalando Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Configurar firewall para puerto 30000/UDP
echo "🔥 Configurando firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 30000/udp comment "Luanti Vegan Wetlands"
    ufw reload
    echo "✅ Firewall configurado para puerto 30000/UDP"
fi

# Crear estructura de directorios con permisos correctos
echo "📁 Configurando directorios..."
mkdir -p server/{config,mods,worlds,backups}
chmod +x scripts/*.sh

# Configurar cron para backups automáticos  
echo "⏰ Configurando backups automáticos..."
CRON_JOB="0 */6 * * * cd $(pwd) && ./scripts/backup.sh >> /var/log/vegan-wetlands-backup.log 2>&1"
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo ""
echo "🌱 ========================================"
echo "🌱 VPS CONFIGURADO PARA VEGAN WETLANDS"
echo "🌱 ========================================"
echo "✅ Docker y Docker Compose instalados"
echo "✅ Firewall configurado (puerto 30000/UDP)"
echo "✅ Directorios creados"
echo "✅ Backups automáticos configurados (cada 6 horas)"
echo ""
echo "🚀 Para iniciar el servidor:"
echo "   ./scripts/start.sh"
echo ""
echo "📊 Para monitorear:"
echo "   docker-compose logs -f luanti-server"
echo "🌱 ========================================"