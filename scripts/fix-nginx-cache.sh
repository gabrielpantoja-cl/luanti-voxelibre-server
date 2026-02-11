#!/bin/bash

##############################################################################
# SCRIPT: Actualizar Configuración de Nginx para Landing Page
# DESCRIPCIÓN: Cambia caché agresivo de JS/CSS/JSON a caché moderado
# REQUIERE: sudo (ejecutar en VPS)
##############################################################################

set -e

echo "🔧 Actualizando configuración de nginx para luanti.gabrielpantoja.cl"
echo ""

# Variables
NGINX_CONFIG="/etc/nginx/sites-available/luanti.gabrielpantoja.cl"
BACKUP_FILE="/etc/nginx/sites-available/luanti.gabrielpantoja.cl.backup-$(date +%Y%m%d-%H%M%S)"

# Verificar que se ejecuta como root o con sudo
if [[ $EUID -ne 0 ]]; then
   echo "❌ Este script debe ejecutarse como root o con sudo"
   echo "   Ejecuta: sudo $0"
   exit 1
fi

echo "📦 Creando backup de configuración actual..."
cp "$NGINX_CONFIG" "$BACKUP_FILE"
echo "✅ Backup creado: $BACKUP_FILE"
echo ""

echo "📝 Actualizando configuración nginx..."

cat > "$NGINX_CONFIG" << 'NGINXEOF'
# Luanti Game Server Landing Page
server {
    server_name luanti.gabrielpantoja.cl;

    # Root directory for static files
    root /home/gabriel/luanti-voxelibre-server/server/landing-page;
    index index.html;

    # Main location
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache JS/CSS files - SHORT cache for frequent updates
    location ~* \.(js|css)$ {
        expires 1h;
        add_header Cache-Control "public, must-revalidate";
        access_log off;
    }

    # Cache JSON data files - VERY SHORT cache
    location ~* \.json$ {
        expires 5m;
        add_header Cache-Control "public, must-revalidate";
        access_log off;
    }

    # Cache static images/fonts - LONG cache (immutable)
    location ~* \.(png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Logs
    access_log /var/log/nginx/luanti_access.log;
    error_log /var/log/nginx/luanti_error.log;

    listen 443 ssl; # managed by Certbot
    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/luanti.gabrielpantoja.cl/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/luanti.gabrielpantoja.cl/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
    if ($host = luanti.gabrielpantoja.cl) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80;
    listen [::]:80;
    server_name luanti.gabrielpantoja.cl;
    return 404; # managed by Certbot
}
NGINXEOF

echo "✅ Configuración actualizada"
echo ""

echo "🔍 Verificando sintaxis de nginx..."
if nginx -t 2>&1 | grep -q "successful"; then
    echo "✅ Sintaxis correcta"
    echo ""

    echo "🔄 Recargando nginx..."
    systemctl reload nginx
    echo "✅ Nginx recargado exitosamente"
    echo ""

    echo "📊 Verificando estado del servicio..."
    systemctl status nginx --no-pager | head -10
    echo ""

    echo "✅ CONFIGURACIÓN APLICADA EXITOSAMENTE"
    echo ""
    echo "🎯 Cambios aplicados:"
    echo "   - JS/CSS: Caché de 1 hora (antes: 1 año)"
    echo "   - JSON: Caché de 5 minutos (antes: 1 año)"
    echo "   - Imágenes: Caché de 1 año (sin cambios)"
    echo ""
    echo "📝 Próximos pasos:"
    echo "   1. Limpiar caché del navegador (Ctrl + Shift + R)"
    echo "   2. Verificar https://luanti.gabrielpantoja.cl/galeria.html"
    echo "   3. Verificar consola del navegador (F12) - debería mostrar: '🖼️ Gallery data loaded: 9 images'"
    echo ""
    echo "🔙 Backup disponible en: $BACKUP_FILE"

else
    echo "❌ ERROR: Sintaxis de nginx incorrecta"
    echo ""
    echo "🔙 Restaurando backup..."
    cp "$BACKUP_FILE" "$NGINX_CONFIG"
    echo "✅ Backup restaurado"
    echo ""
    echo "Por favor, revisa el error y contacta al administrador"
    exit 1
fi