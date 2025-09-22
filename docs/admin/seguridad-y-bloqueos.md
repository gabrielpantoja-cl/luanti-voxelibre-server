# 🛡️ Seguridad y Bloqueos

Consolidación de procedimientos de seguridad, bloqueo de IPs y manejo de incidentes de seguridad.

## 🚨 Procedimientos de Emergencia

### Bloqueo Inmediato de IP
```bash
# Bloquear IP específica con iptables
sudo iptables -A INPUT -s [IP_MALICIOSA] -j DROP

# Verificar bloqueo
sudo iptables -L INPUT -n | grep [IP_MALICIOSA]

# Guardar reglas (persistente)
sudo iptables-save > /etc/iptables/rules.v4
```

### Eliminación de Usuario Problemático
```bash
# Acceder al contenedor
docker compose exec luanti-server /bin/bash

# Eliminar de base de datos SQLite
sqlite3 /config/.minetest/worlds/world/auth.sqlite "DELETE FROM auth WHERE name='USUARIO_PROBLEMATICO';"
sqlite3 /config/.minetest/worlds/world/auth.sqlite "DELETE FROM user_privileges WHERE id IN (SELECT id FROM auth WHERE name='USUARIO_PROBLEMATICO');"

# Reiniciar servidor
docker compose restart luanti-server
```

## 📋 Incidentes de Seguridad Documentados

### Incidente del 20 de Septiembre, 2025
- **Problema**: Usuario problemático causando disrupciones
- **Acciones**: Bloqueo de IP y eliminación de cuenta
- **Resultado**: Servidor restaurado a funcionamiento normal
- **Documentación**: Procedimientos consolidados y automatizados

### Medidas Preventivas Implementadas
1. **Monitoreo de logs** en tiempo real
2. **Backup automático** cada 6 horas antes de cambios
3. **Scripts de bloqueo** automatizados
4. **Documentación** de todos los procedimientos

## ⚙️ Herramientas de Seguridad

### Scripts Disponibles
- `scripts/block-ip.sh` - Bloqueo automatizado de IPs
- `scripts/remove-user.sh` - Eliminación segura de usuarios
- `scripts/security-audit.sh` - Auditoría de seguridad

### Monitoreo
```bash
# Ver conexiones activas
ss -tulpn | grep :30000

# Logs del servidor en tiempo real
docker compose logs -f luanti-server

# Revisar intentos de conexión
journalctl -f | grep luanti
```

## 🔍 Identificación de Amenazas

### Señales de Alerta
- Múltiples conexiones desde la misma IP
- Comportamiento disruptivo en chat
- Intentos de exploits o comandos maliciosos
- Lag excesivo o problemas de rendimiento

### Respuesta Graduada
1. **Advertencia**: Comando `/warn` in-game
2. **Kick temporal**: Comando `/kick`
3. **Ban temporal**: Comando `/ban`
4. **Bloqueo IP**: iptables + eliminación de cuenta
5. **Investigación**: Análisis de logs y patrones

## 📞 Escalación de Incidentes

### Nivel 1 - Moderación Básica
- Advertencias y kicks temporales
- Manejo por moderadores del servidor

### Nivel 2 - Administración Avanzada
- Bans permanentes
- Bloqueo de IPs
- Requiere acceso SSH al VPS

### Nivel 3 - Seguridad Crítica
- Ataques DDoS o exploits serios
- Compromiso potencial del servidor
- Escalación a administrador del sistema