# 🔔 Sistema de Notificaciones Discord - Luanti Wetlands

## Descripción

Sistema automático de notificaciones que envía alertas a Discord cuando:
- 🟢 Un jugador se conecta al servidor
- 🔴 Un jugador se desconecta del servidor
- 🤖 El monitor se inicia o se detiene

## Arquitectura

```
┌─────────────────────┐
│  Luanti Server      │
│  (Docker Container) │
└──────────┬──────────┘
           │ logs
           ▼
┌─────────────────────┐
│  Discord Notifier   │
│  (Docker Container) │
│  - Monitorea logs   │
│  - Detecta eventos  │
└──────────┬──────────┘
           │ HTTP POST
           ▼
┌─────────────────────┐
│  Discord Webhook    │
│  (API)              │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Canal Discord      │
│  (Tu celular)       │
└─────────────────────┘
```

## Configuración Inicial

### 1. Webhook de Discord (Ya Configurado ✅)

El webhook ya está configurado en el archivo `.env`:
```bash
DISCORD_WEBHOOK_URL=https://discordapp.com/api/webhooks/[ID]/[TOKEN]
```

**⚠️ SEGURIDAD:** Este archivo está en `.gitignore` y nunca se sube al repositorio.

### 2. Configuración de Discord Móvil

Para recibir notificaciones en tu celular:

1. **Configuración Global:**
   - Abre Discord → Tu perfil → Notificaciones
   - Activa: ✅ "Notificaciones push"
   - Activa: ✅ "Mensajes"

2. **Configuración del Servidor:**
   - Mantén presionado el servidor "Luanti Wetlands"
   - Notificaciones → "Todos los mensajes"
   - Asegúrate que NO esté silenciado

3. **Configuración del Canal:**
   - Mantén presionado el canal "conexiones-servidor"
   - Notificaciones → "Todos los mensajes"

## Uso

### Iniciar el Sistema

El sistema se inicia automáticamente con Docker Compose:

```bash
docker-compose up -d
```

El contenedor `luanti-discord-notifier` empezará a monitorear automáticamente.

### Verificar Estado

```bash
# Ver logs del notificador
docker-compose logs -f discord-notifier

# Ver si está corriendo
docker-compose ps discord-notifier
```

### Enviar Notificación de Prueba

```bash
# Desde tu computadora local
cd /ruta/a/luanti-voxelibre-server
bash scripts/send-discord-test.sh "Tu mensaje de prueba"

# Desde el VPS
ssh gabriel@167.172.251.27
cd /home/gabriel/luanti-voxelibre-server
bash scripts/send-discord-test.sh "Prueba desde VPS"
```

### Detener el Sistema

```bash
# Detener solo el notificador
docker-compose stop discord-notifier

# Detener todo
docker-compose down
```

## Ejemplos de Notificaciones

### Conexión de Jugador
```
🟢 Jugador Conectado: gabrielpantoja se ha conectado al servidor 🎮 | Servidor: Wetlands 🌱
```

### Desconexión de Jugador
```
🔴 Jugador Desconectado: gabrielpantoja se ha desconectado del servidor 👋 | Servidor: Wetlands 🌱
```

### Monitor Iniciado
```
🤖 Monitor Iniciado: Sistema de notificaciones activado correctamente ✅ | Servidor: Wetlands 🌱
```

## Scripts Disponibles

### 1. `discord-notifier.sh`
Script principal que monitorea logs en tiempo real.

**Ubicación:** `scripts/discord-notifier.sh`

**Ejecutado por:** Contenedor Docker `discord-notifier`

**Funciones:**
- Monitorea logs del servidor Luanti
- Detecta patrones de conexión/desconexión
- Envía notificaciones a Discord automáticamente

### 2. `send-discord-test.sh`
Script para enviar notificaciones de prueba.

**Uso:**
```bash
bash scripts/send-discord-test.sh "Mensaje personalizado"
```

**Ideal para:**
- Probar que el webhook funciona
- Verificar configuración de Discord
- Enviar notificaciones manuales

### 3. `test-discord-notification.sh`
Script de diagnóstico completo.

**Uso:**
```bash
bash scripts/test-discord-notification.sh
```

**Verifica:**
- Archivo `.env` existe
- Variable `DISCORD_WEBHOOK_URL` está configurada
- Conexión HTTP funciona
- Discord recibe el mensaje

## Troubleshooting

### Problema: No llegan notificaciones

**Solución:**

1. **Verificar configuración de Discord:**
   ```bash
   # Revisa que Discord esté configurado para notificaciones
   # Ver "Configuración de Discord Móvil" arriba
   ```

2. **Verificar el contenedor:**
   ```bash
   docker-compose ps discord-notifier
   # Debe mostrar: "Up"
   ```

3. **Ver logs del contenedor:**
   ```bash
   docker-compose logs discord-notifier
   # Buscar errores
   ```

4. **Probar webhook manualmente:**
   ```bash
   bash scripts/send-discord-test.sh "Prueba manual"
   ```

### Problema: Contenedor se reinicia constantemente

**Solución:**

1. **Ver logs detallados:**
   ```bash
   docker-compose logs --tail=50 discord-notifier
   ```

2. **Verificar que el servidor Luanti está corriendo:**
   ```bash
   docker-compose ps luanti-server
   ```

3. **Verificar variable de entorno:**
   ```bash
   grep "DISCORD_WEBHOOK_URL" .env
   # Debe mostrar la URL completa
   ```

### Problema: Notificaciones llegan pero con nombre "Jugador desconocido"

**Causa:** El patrón de detección de nombres no coincide con el formato de log.

**Solución:**

1. **Ver logs reales del servidor:**
   ```bash
   docker-compose logs luanti-server | grep -i "join\|leave\|connect"
   ```

2. **Ajustar patrón en `discord-notifier.sh`:**
   - Líneas 90 y 102
   - Modificar expresiones regulares según formato de log

## Patrones de Log Detectados

El script detecta las siguientes frases en los logs:

### Conexiones:
- `[username] joins game`
- `[username] connected from [IP]`

### Desconexiones:
- `[username] leaves game`
- `[username] disconnected`

## Seguridad

### Webhook URL

- ✅ **Protegido:** URL guardada en `.env` (ignorado por Git)
- ❌ **NO compartir:** Nunca subas esta URL a GitHub
- 🔄 **Renovar:** Si se filtra, crear nuevo webhook en Discord

### Permisos del Webhook

El webhook solo puede:
- ✅ Enviar mensajes al canal configurado
- ❌ NO puede leer mensajes
- ❌ NO puede ver otros canales
- ❌ NO puede administrar el servidor

## Integración con CI/CD

El sistema se despliega automáticamente al hacer push:

```bash
# 1. Hacer cambios localmente
git add .
git commit -m "feat: mejoras al sistema de notificaciones"
git push origin main

# 2. GitHub Actions se encarga del resto:
#    - Backup de mundo
#    - Deploy a VPS
#    - Reinicio de contenedores
#    - Verificación de salud

# 3. El notificador se reinicia automáticamente
#    y envía una notificación de "Monitor Iniciado"
```

## Costos

- **Discord Webhook:** ✅ Gratis, sin límites
- **Notificaciones:** ✅ Sin cargo adicional
- **Impacto en VPS:** Mínimo (~5 MB RAM)

## Próximas Mejoras (Opcional)

- [ ] Notificaciones de backup completado
- [ ] Alertas de errores del servidor
- [ ] Estadísticas diarias (jugadores únicos, tiempo de conexión)
- [ ] Comandos desde Discord para controlar el servidor
- [ ] Integración con n8n para notificaciones multi-canal

## Referencias

- [Discord Webhooks Documentation](https://discord.com/developers/docs/resources/webhook)
- [Docker Compose Networking](https://docs.docker.com/compose/networking/)
- [Luanti Server Documentation](https://wiki.luanti.org/Server)

---

**Creado:** 2025-10-25
**Última actualización:** 2025-10-25
**Mantenedor:** Gabriel Pantoja