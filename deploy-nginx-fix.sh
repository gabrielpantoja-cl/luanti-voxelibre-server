#!/bin/bash

##############################################################################
# SCRIPT: Deployar Fix de Nginx Cache al VPS
# DESCRIPCIÓN: Copia y ejecuta el script de fix en el VPS
##############################################################################

set -e

VPS_HOST="gabriel@167.172.251.27"
LOCAL_SCRIPT="./fix-nginx-cache.sh"
REMOTE_SCRIPT="/home/gabriel/fix-nginx-cache.sh"

echo "🚀 Deployando fix de nginx cache al VPS..."
echo ""

# Verificar que el script local existe
if [[ ! -f "$LOCAL_SCRIPT" ]]; then
    echo "❌ ERROR: Script $LOCAL_SCRIPT no encontrado"
    exit 1
fi

echo "📤 Copiando script al VPS..."
scp "$LOCAL_SCRIPT" "$VPS_HOST:$REMOTE_SCRIPT"
echo "✅ Script copiado a $VPS_HOST:$REMOTE_SCRIPT"
echo ""

echo "🔧 Ejecutando script en VPS con sudo..."
echo ""
echo "──────────────────────────────────────────────────────────────"

ssh -t "$VPS_HOST" "sudo bash $REMOTE_SCRIPT"

echo "──────────────────────────────────────────────────────────────"
echo ""
echo "✅ Fix aplicado exitosamente!"
echo ""
echo "📝 Próximos pasos:"
echo "   1. Limpiar caché del navegador (Ctrl + Shift + R)"
echo "   2. Verificar https://luanti.gabrielpantoja.cl/galeria.html"
echo "   3. Deberías ver las 9 imágenes, con AUTO-AMARILLO primero"
echo ""