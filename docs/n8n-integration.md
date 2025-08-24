# 🤖 Integración con n8n - Vegan Wetlands

Esta guía explica cómo integrar el servidor Vegan Wetlands con n8n para automatización avanzada.

## 🎯 Casos de Uso

### 1. Notificaciones de Backup
- **Trigger**: Backup completado exitosamente
- **Acción**: Enviar mensaje a Discord/Telegram
- **Webhook**: `POST /webhook/backup-completed`

### 2. Monitoreo de Servidor
- **Trigger**: Cada 5 minutos
- **Verificación**: Estado del contenedor Docker
- **Acción**: Alerta si el servidor está caído

### 3. Moderación Automática
- **Trigger**: Chat del servidor (via logs)
- **Filtros**: Palabras no apropiadas
- **Acción**: Notificar moderadores

### 4. Estadísticas Diarias
- **Trigger**: Todos los días a las 22:00
- **Recolección**: Jugadores conectados, tiempo de actividad
- **Acción**: Enviar reporte a administradores

## 🔗 Webhooks Sugeridos

### Backup Completado
```json
{
  "method": "POST",
  "url": "http://n8n:5678/webhook/vegan-wetlands/backup",
  "payload": {
    "server": "vegan-wetlands",
    "backup_file": "{{filename}}",
    "timestamp": "{{timestamp}}",
    "size": "{{file_size}}"
  }
}
```

### Estado del Servidor
```json
{
  "method": "POST", 
  "url": "http://n8n:5678/webhook/vegan-wetlands/status",
  "payload": {
    "server": "vegan-wetlands",
    "status": "{{status}}",
    "players_online": "{{player_count}}",
    "uptime": "{{uptime}}"
  }
}
```

## 📋 Workflows de n8n Recomendados

### Workflow 1: Backup Monitor
1. **Webhook Node**: Escuchar POST de backups
2. **Discord Node**: Enviar notificación de backup exitoso
3. **Conditional Node**: Si hay error, enviar alerta urgente

### Workflow 2: Server Health Check  
1. **Cron Node**: Cada 5 minutos
2. **HTTP Request Node**: Verificar puerto 30000
3. **Discord Node**: Alerta si servidor no responde
4. **Docker Node**: Intentar reiniciar automáticamente

### Workflow 3: Daily Stats
1. **Cron Node**: Diario a las 22:00
2. **HTTP Request Node**: Obtener logs del servidor
3. **Code Node**: Parsear estadísticas de jugadores
4. **Discord Node**: Enviar reporte diario

## 🔧 Configuración

### Variables de Entorno para n8n
```bash
# En el archivo .env de n8n
VEGAN_WETLANDS_WEBHOOK_TOKEN=tu_token_secreto
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
VPS_HOST=tu-vps-ip
VPS_USER=tu-usuario
```

### Script de Integración (opcional)
```bash
# scripts/n8n-notify.sh
#!/bin/bash
curl -X POST "$N8N_WEBHOOK_URL" \
     -H "Content-Type: application/json" \
     -d "$1"
```

## 📊 Ejemplos de Notificaciones

### Discord - Backup Exitoso
```
🌱 **Vegan Wetlands Backup**
✅ Backup completado exitosamente
📁 Archivo: vegan_wetlands_backup_20240824-143022.tar.gz
💾 Tamaño: 245 MB
⏰ Fecha: 24/08/2024 14:30:22
```

### Discord - Nuevo Jugador
```
🌱 **Nuevo Explorador Vegano**
👋 ¡Bienvenid@ @nuevo_jugador a Vegan Wetlands!
🎮 Jugadores online: 5/20
🕐 Hora de conexión: 14:35
```

### Discord - Servidor Caído
```
🚨 **ALERTA - Vegan Wetlands**
❌ Servidor no está respondiendo
🔧 Intentando reinicio automático...
⏰ Detectado: 24/08/2024 14:40:15
```