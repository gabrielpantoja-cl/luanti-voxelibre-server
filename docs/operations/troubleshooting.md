# 🔧 Solución de Problemas

Guía completa para diagnosticar y resolver problemas comunes del servidor Santuario Compasivo.

## 🚨 Problemas Críticos

### 1. Servidor No Responde
```bash
# Verificar estado del contenedor
docker-compose ps

# Revisar logs para errores
docker-compose logs --tail=50 luanti-server

# Reiniciar servidor
docker-compose restart luanti-server

# Si persiste, reiniciar completamente
docker-compose down && docker-compose up -d
```

### 2. Corrupción de Texturas
**Síntomas**: Bloques muestran texturas incorrectas, texturas faltantes
**Solución**: Ver [Texture Recovery](texture-recovery.md) para procedimiento completo

### 3. Base de Datos Corrupta
```bash
# Backup inmediato
cp server/worlds/world/auth.sqlite server/worlds/world/auth.sqlite.backup

# Verificar integridad
sqlite3 server/worlds/world/auth.sqlite "PRAGMA integrity_check;"

# Si está corrupta, restaurar desde backup
cp server/backups/latest/world/auth.sqlite server/worlds/world/
```

## ⚠️ Problemas Comunes

### Conectividad
**Problema**: Jugadores no pueden conectarse
```bash
# Verificar puerto 30000
ss -tulpn | grep :30000

# Probar conexión local
telnet localhost 30000

# Verificar firewall
sudo ufw status | grep 30000
```

### Performance
**Problema**: Lag excesivo o alta latencia
```bash
# Verificar uso de recursos
docker stats luanti-server

# Revisar logs por errores de performance
docker-compose logs luanti-server | grep -i "lag\|slow\|timeout"

# Optimizar contenedor
docker-compose restart luanti-server
```

### Mods No Funcionan
**Problema**: Comandos de mods no responden
```bash
# Verificar carga de mods
docker-compose logs luanti-server | grep -i "mod\|error"

# Revisar estructura de archivos
ls -la server/mods/

# Verificar configuración
cat server/config/luanti.conf | grep load_mod
```

## 🔍 Diagnóstico Paso a Paso

### 1. Verificación Básica
```bash
# Estado general del sistema
docker-compose ps
docker system df
df -h

# Logs recientes
docker-compose logs --tail=20 luanti-server
```

### 2. Conectividad
```bash
# Puerto del servidor
netstat -tulpn | grep :30000

# Conectividad externa
curl -I https://luanti.gabrielpantoja.cl

# DNS resolution
nslookup luanti.gabrielpantoja.cl
```

### 3. Recursos del Sistema
```bash
# Uso de memoria y CPU
htop

# Espacio en disco
du -sh server/worlds/
du -sh server/backups/

# Logs del sistema
journalctl -f | grep luanti
```

## 🛠️ Herramientas de Diagnóstico

### Scripts de Diagnóstico
```bash
# Health check completo
./scripts/health-check.sh

# Verificar configuración
./scripts/validate-config.sh

# Test de conectividad
./scripts/connectivity-test.sh
```

### Comandos In-Game Útiles
```
# Como administrador en el servidor
/status                  # Estado general del servidor
/shutdown 10            # Reinicio programado
/time 12000             # Ajustar hora del día
/teleport player x y z  # Teleportar jugador
```

## 📊 Métricas de Referencia

### Performance Normal
- **CPU**: <50% de uso promedio
- **RAM**: <2GB de uso del contenedor
- **Disk I/O**: <100MB/s en operaciones normales
- **Network**: <10Mbps de tráfico

### Tiempos de Respuesta
- **Startup**: <30 segundos
- **Player Connection**: <5 segundos
- **World Save**: <10 segundos
- **Backup**: <2 minutos

## 🚨 Procedimientos de Emergencia

### Pérdida Total de Conectividad
1. Verificar VPS está funcionando: `ping <VPS_HOST_IP>`
2. SSH al servidor: `ssh gabriel@<VPS_HOST_IP>`
3. Verificar Docker: `docker-compose ps`
4. Revisar logs: `docker-compose logs luanti-server`
5. Reiniciar servicios: `docker-compose restart`

### Corrupción de Mundo
1. **STOP** inmediatamente: `docker-compose stop luanti-server`
2. Backup de emergencia: `cp -r server/worlds server/worlds_emergency`
3. Restaurar último backup: Ver [Backups](backups.md)
4. Validar integridad antes de reiniciar

### Ataque o Sobrecarga
1. Identificar fuente: `docker-compose logs | grep -i "error\|attack"`
2. Bloquear IPs problemáticas: Ver [Seguridad](../admin/seguridad-y-bloqueos.md)
3. Reducir max_users temporalmente
4. Monitorear recursos con `htop`

## 📞 Escalación

### Nivel 1 - Auto-resolución
- Reinicio de servicios
- Verificación de logs básica
- Aplicación de scripts automatizados

### Nivel 2 - Investigación Manual
- Análisis detallado de logs
- Verificación de integridad de datos
- Restauración desde backups

### Nivel 3 - Intervención Crítica
- Contacto con proveedor de VPS
- Restauración completa del sistema
- Análisis forense de incidentes