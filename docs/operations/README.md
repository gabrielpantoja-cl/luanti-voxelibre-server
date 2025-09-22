# 🔧 Operaciones y Mantenimiento

Documentación sobre operaciones diarias, mantenimiento y resolución de problemas del servidor.

## 📋 Contenido

- **[Backups](backups.md)** - Sistema completo de respaldos y recuperación
- **[Deploy](deploy.md)** - Procedimientos de despliegue y CI/CD
- **[Troubleshooting](troubleshooting.md)** - Solución de problemas comunes
- **[Texture Recovery](texture-recovery.md)** - Recuperación de corrupción de texturas

## 🚨 Procedimientos de Emergencia

### Orden de Prioridad
1. **Texture Recovery** - Para corrupción visual del juego
2. **Backups** - Para pérdida de datos del mundo
3. **Troubleshooting** - Para problemas generales de conectividad

### Comandos de Emergencia Rápida
```bash
# Verificar estado del servidor
docker-compose ps

# Logs del servidor
docker-compose logs -f luanti-server

# Backup de emergencia
./scripts/backup.sh

# Reinicio completo
docker-compose restart luanti-server
```

## 📊 Métricas de Operación

- **Backup Automático**: Cada 6 horas
- **Retención**: 10 backups más recientes
- **Tiempo de Recuperación**: ~3 minutos (texturas), ~15 minutos (mundo completo)
- **Uptime Objetivo**: 99.5%