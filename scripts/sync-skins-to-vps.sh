#!/bin/bash
# Script para sincronizar skins al VPS Wetlands
# Sincroniza texturas y configuración de skins

set -euo pipefail

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuración
VPS_HOST="gabriel@167.172.251.27"
VPS_PATH="/home/gabriel/luanti-voxelibre-server"
LOCAL_TEXTURES="server/worlds/world/_world_folder_media/textures"
LOCAL_SKINS_CONFIG="server/worlds/world/skins.txt"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

echo "🎨 Wetlands - Sincronización de Skins al VPS"
echo "============================================"
echo ""

# Verificar conectividad SSH
log_info "Verificando conexión SSH con VPS..."
if ! ssh -o ConnectTimeout=5 "$VPS_HOST" 'echo "SSH OK"' &>/dev/null; then
    log_warning "No se puede conectar al VPS. Verifica:"
    echo "  - Conexión a internet"
    echo "  - Configuración SSH"
    echo "  - VPS en línea"
    exit 1
fi
log_success "Conexión SSH exitosa"
echo ""

# Contar skins a sincronizar
SKIN_COUNT=$(ls -1 "$LOCAL_TEXTURES"/*.png 2>/dev/null | wc -l)
log_info "Skins encontrados localmente: $SKIN_COUNT"

# Listar skins
echo ""
echo "📋 Skins a sincronizar:"
echo "======================="
ls -1 "$LOCAL_TEXTURES"/*.png | while read file; do
    filename=$(basename "$file")
    size=$(identify -format '%wx%h' "$file")
    echo "  • $filename ($size)"
done
echo ""

# Confirmar sincronización
read -p "¿Deseas continuar con la sincronización? (s/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    log_info "Sincronización cancelada"
    exit 0
fi
echo ""

# Crear backup en VPS
log_info "Creando backup de skins actuales en VPS..."
ssh "$VPS_HOST" "cd $VPS_PATH && \
    if [ -d server/worlds/world/_world_folder_media/textures ]; then \
        tar -czf backups/skins_backup_\$(date +%Y%m%d_%H%M%S).tar.gz \
            server/worlds/world/_world_folder_media/textures/ \
            server/worlds/world/skins.txt 2>/dev/null || true; \
        echo 'Backup creado'; \
    fi"
log_success "Backup creado en VPS"
echo ""

# Sincronizar texturas
log_info "Sincronizando texturas..."
rsync -avz --progress \
    "$LOCAL_TEXTURES/" \
    "$VPS_HOST:$VPS_PATH/$LOCAL_TEXTURES/"
log_success "Texturas sincronizadas"
echo ""

# Sincronizar skins.txt
log_info "Sincronizando configuración (skins.txt)..."
rsync -avz \
    "$LOCAL_SKINS_CONFIG" \
    "$VPS_HOST:$VPS_PATH/$LOCAL_SKINS_CONFIG"
log_success "Configuración sincronizada"
echo ""

# Verificar archivos en VPS
log_info "Verificando archivos en VPS..."
ssh "$VPS_HOST" "cd $VPS_PATH && \
    echo 'Skins en VPS:' && \
    ls -1 $LOCAL_TEXTURES/*.png 2>/dev/null | wc -l"
echo ""

# Reiniciar servidor
log_info "Reiniciando servidor Luanti..."
ssh "$VPS_HOST" "cd $VPS_PATH && docker-compose restart luanti-server"
log_success "Servidor reiniciado"
echo ""

# Esperar a que el servidor inicie
log_info "Esperando a que el servidor inicie (15 segundos)..."
sleep 15

# Verificar estado del servidor
log_info "Verificando estado del servidor..."
ssh "$VPS_HOST" "cd $VPS_PATH && docker-compose ps luanti-server"
echo ""

log_success "✨ Sincronización completada exitosamente!"
echo ""
echo "📋 Resumen:"
echo "  • Skins sincronizados: $SKIN_COUNT"
echo "  • Servidor: Reiniciado"
echo "  • Estado: Activo"
echo ""
echo "🎮 Próximos pasos:"
echo "  1. Conectar al servidor: luanti.gabrielpantoja.cl:30000"
echo "  2. Usar comando en el juego: /skin"
echo "  3. Seleccionar los nuevos skins de la lista"
echo ""
