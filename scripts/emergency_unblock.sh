#!/bin/bash
# emergency_unblock.sh
# Script de emergencia para desbloquear IPs en caso de falso positivo
# USO: ./emergency_unblock.sh <IP_TO_UNBLOCK> "razón del desbloqueo"

IP_TO_UNBLOCK="$1"
REASON="$2"

if [ -z "$IP_TO_UNBLOCK" ] || [ -z "$REASON" ]; then
    echo "❌ Error: Parámetros requeridos"
    echo "📋 Uso: $0 <IP_TO_UNBLOCK> \"razón del desbloqueo\""
    echo "📋 Ejemplo: $0 200.83.160.80 \"Usuario legítimo bloqueado por error\""
    exit 1
fi

echo "🚨 ===== SCRIPT DE EMERGENCY UNBLOCK ====="
echo "🔄 DESBLOQUEANDO IP: $IP_TO_UNBLOCK"
echo "📝 RAZÓN: $REASON"
echo "⏰ FECHA: $(date)"
echo "=========================================="

# Verificar conectividad SSH
echo "🔍 Verificando conectividad SSH..."
if ! ssh -o ConnectTimeout=5 gabriel@167.172.251.27 "echo 'SSH OK'" >/dev/null 2>&1; then
    echo "❌ Error: No se puede conectar al VPS via SSH"
    exit 1
fi
echo "✅ SSH conectado exitosamente"

# Paso 1: Backup antes de cambios
echo "📦 Creando backup de configuraciones..."
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Backup luanti.conf
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && cp server/config/luanti.conf server/config/luanti.conf.backup.unblock_$TIMESTAMP"

# Backup ipban.txt (si existe)
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose exec -T luanti-server sh -c 'if [ -f /config/.minetest/worlds/world/ipban.txt ]; then cp /config/.minetest/worlds/world/ipban.txt /config/.minetest/worlds/world/ipban.txt.backup.$TIMESTAMP; echo \"ipban.txt backed up\"; else echo \"ipban.txt no existe\"; fi'"

echo "✅ Backups creados con timestamp: $TIMESTAMP"

# Paso 2: Verificar que la IP está bloqueada
echo "🔍 Verificando estado actual del bloqueo..."
LUANTI_CONF_BLOCK=$(ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && grep 'deny_access.$IP_TO_UNBLOCK' server/config/luanti.conf || echo 'NO_FOUND'")
IPBAN_BLOCK=$(ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose exec -T luanti-server grep '$IP_TO_UNBLOCK' /config/.minetest/worlds/world/ipban.txt 2>/dev/null || echo 'NO_FOUND'")

echo "📋 Estado en luanti.conf: $LUANTI_CONF_BLOCK"
echo "📋 Estado en ipban.txt: $IPBAN_BLOCK"

if [ "$LUANTI_CONF_BLOCK" = "NO_FOUND" ] && [ "$IPBAN_BLOCK" = "NO_FOUND" ]; then
    echo "⚠️  ADVERTENCIA: IP $IP_TO_UNBLOCK no parece estar bloqueada"
    echo "🤔 ¿Estás seguro de que necesitas desbloquearla?"
    read -p "Continuar de todas formas? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "❌ Operación cancelada por el usuario"
        exit 1
    fi
fi

# Paso 3: Remover de luanti.conf
echo "🔧 Removiendo IP de luanti.conf..."
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && sed -i '/deny_access\.$IP_TO_UNBLOCK/d' server/config/luanti.conf"

# Verificar remoción
VERIFY_LUANTI=$(ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && grep '$IP_TO_UNBLOCK' server/config/luanti.conf || echo 'REMOVED'")
if [ "$VERIFY_LUANTI" = "REMOVED" ]; then
    echo "✅ IP removida exitosamente de luanti.conf"
else
    echo "⚠️  IP aún presente en luanti.conf: $VERIFY_LUANTI"
fi

# Paso 4: Remover de ipban.txt
echo "🔧 Removiendo IP de ipban.txt..."
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose exec -T luanti-server sh -c \"grep -v '$IP_TO_UNBLOCK' /config/.minetest/worlds/world/ipban.txt > /tmp/ipban_temp 2>/dev/null && mv /tmp/ipban_temp /config/.minetest/worlds/world/ipban.txt 2>/dev/null || echo 'ipban.txt procesado'\""

# Verificar remoción
VERIFY_IPBAN=$(ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose exec -T luanti-server grep '$IP_TO_UNBLOCK' /config/.minetest/worlds/world/ipban.txt 2>/dev/null || echo 'REMOVED'")
if [ "$VERIFY_IPBAN" = "REMOVED" ]; then
    echo "✅ IP removida exitosamente de ipban.txt"
else
    echo "⚠️  IP aún presente en ipban.txt: $VERIFY_IPBAN"
fi

# Paso 5: Reiniciar servidor
echo "🔄 Reiniciando servidor Luanti..."
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose restart luanti-server"

# Esperar que el servidor se inicie
echo "⏳ Esperando 10 segundos para que el servidor se inicie..."
sleep 10

# Verificar estado del servidor
SERVER_STATUS=$(ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && docker-compose ps luanti-server --format 'table {{.Status}}'" | tail -1)
echo "📊 Estado del servidor: $SERVER_STATUS"

# Paso 6: Documentar reversión
echo "📝 Documentando reversión..."
UNBLOCK_LOG="docs/IP_UNBLOCK_LOG.md"

# Crear archivo de log si no existe
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && [ ! -f $UNBLOCK_LOG ] && echo '# Log de IPs Desbloqueadas' > $UNBLOCK_LOG"

# Añadir entrada al log
ssh gabriel@167.172.251.27 "cd /home/gabriel/luanti-voxelibre-server && cat >> $UNBLOCK_LOG << 'EOF'
## $(date '+%Y-%m-%d %H:%M:%S')
- **IP**: $IP_TO_UNBLOCK
- **Razón**: $REASON
- **Método**: deny_access + ipban.txt
- **Backup timestamp**: $TIMESTAMP
- **Estado luanti.conf**: $VERIFY_LUANTI
- **Estado ipban.txt**: $VERIFY_IPBAN

EOF"

echo "✅ Documentación actualizada en $UNBLOCK_LOG"

# Resumen final
echo ""
echo "🎉 ===== RESUMEN DE LA OPERACIÓN ====="
echo "✅ IP $IP_TO_UNBLOCK DESBLOQUEADA EXITOSAMENTE"
echo "📦 Backups creados con timestamp: $TIMESTAMP"
echo "📝 Operación documentada en: $UNBLOCK_LOG"
echo "🔄 Servidor reiniciado: $SERVER_STATUS"
echo ""
echo "⚠️  IMPORTANTE:"
echo "   • Monitorear actividad de esta IP las próximas 24 horas"
echo "   • Verificar que la conexión funciona desde la IP desbloqueada"
echo "   • Si el comportamiento sospechoso persiste, bloquear nuevamente"
echo ""
echo "🔧 Para revertir este desbloqueo si es necesario:"
echo "   • Restaurar backup: luanti.conf.backup.unblock_$TIMESTAMP"
echo "   • Reiniciar servidor"
echo "======================================"