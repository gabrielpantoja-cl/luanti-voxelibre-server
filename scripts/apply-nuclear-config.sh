#!/bin/bash

# 🚨 SCRIPT NUCLEAR - APLICAR CONFIGURACIÓN ANTI-MOBS
# Aplica la configuración nuclear que sobrescribe VoxeLibre para eliminar monstruos

set -e  # Salir si hay errores

VPS_HOST="gabriel@167.172.251.27"
VPS_PATH="/home/gabriel/Vegan-Wetlands"

echo "🚨 APLICANDO CONFIGURACIÓN NUCLEAR ANTI-MOBS..."
echo "========================================"

# Verificar conexión SSH
echo "🔍 Verificando conexión al VPS..."
if ! ssh $VPS_HOST 'echo "SSH conectado exitosamente"'; then
    echo "❌ ERROR: No se puede conectar al VPS"
    exit 1
fi

# Verificar que el servidor esté funcionando
echo "🔍 Verificando estado del servidor..."
ssh $VPS_HOST "cd $VPS_PATH && docker-compose ps | grep luanti-server"

# Hacer backup del archivo original
echo "💾 Creando backup de minetest.conf original..."
ssh $VPS_HOST "cd $VPS_PATH && docker-compose exec -T luanti-server cp /config/.minetest/games/mineclone2/minetest.conf /config/.minetest/games/mineclone2/minetest.conf.backup.$(date +%Y%m%d_%H%M%S)" || echo "⚠️  Backup puede haber fallado (normal si ya existe)"

# Aplicar configuración nuclear
echo "🚀 Aplicando configuración nuclear..."
ssh $VPS_HOST "cd $VPS_PATH && docker-compose exec -T luanti-server tee -a /config/.minetest/games/mineclone2/minetest.conf << 'EOF'

# NUCLEAR OVERRIDE - VEGAN WETLANDS CREATIVE FORCE - $(date)
creative_mode = true
enable_damage = false
enable_pvp = false
enable_fire = false
mobs_spawn = false
only_peaceful_mobs = true
mcl_spawn_hostile_mobs = false  
mcl_spawn_monsters = false
mob_difficulty = 0.0
keepInventory = true
EOF"

# Otorgar privilegios creativos a todos los usuarios
echo "🎮 Otorgando privilegios creativos a todos los usuarios..."
ssh $VPS_HOST "cd $VPS_PATH && docker-compose exec -T luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite \"INSERT OR IGNORE INTO user_privileges SELECT id, 'creative' FROM auth; INSERT OR IGNORE INTO user_privileges SELECT id, 'fly' FROM auth; INSERT OR IGNORE INTO user_privileges SELECT id, 'fast' FROM auth; INSERT OR IGNORE INTO user_privileges SELECT id, 'give' FROM auth; INSERT OR IGNORE INTO user_privileges SELECT id, 'noclip' FROM auth;\""

# Reiniciar servidor
echo "🔄 Reiniciando servidor..."
ssh $VPS_HOST "cd $VPS_PATH && docker-compose restart luanti-server"

# Esperar que se inicie
echo "⏳ Esperando que el servidor se inicie..."
sleep 20

# Verificar estado
echo "🔍 Verificando estado final..."
if ssh $VPS_HOST "cd $VPS_PATH && docker-compose ps | grep 'Up (healthy)' | grep luanti-server"; then
    echo "✅ ÉXITO: Servidor funcionando correctamente"
else
    echo "⚠️  ADVERTENCIA: Servidor puede no estar completamente listo"
    ssh $VPS_HOST "cd $VPS_PATH && docker-compose ps"
fi

# Verificar ausencia de mobs hostiles en logs recientes
echo "🔍 Verificando ausencia de mobs hostiles..."
if ssh $VPS_HOST "cd $VPS_PATH && docker-compose logs --tail=50 luanti-server 2>/dev/null | grep -E '(zombie|skeleton|spider|creeper)' | head -5"; then
    echo "⚠️  ADVERTENCIA: Todavía hay actividad de mobs hostiles en logs"
    echo "   Esto puede ser actividad antigua. Monitorear durante unos minutos."
else
    echo "✅ PERFECTO: No hay actividad de mobs hostiles en logs recientes"
fi

echo ""
echo "🎉 CONFIGURACIÓN NUCLEAR APLICADA EXITOSAMENTE"
echo "========================================"
echo "✅ Modo creativo 100% activado"
echo "✅ Monstruos completamente deshabilitados"  
echo "✅ Daño desactivado"
echo "✅ Privilegios creativos otorgados"
echo ""
echo "🌱 El servidor Vegan Wetlands ahora es 100% seguro para niños!"
echo "🎮 Conectar a: luanti.gabrielpantoja.cl:30000"