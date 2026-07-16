# Notificaciones Discord — conexiones de jugadores

## Resumen

Cada vez que un jugador se conecta o desconecta de cualquier mundo Luanti del
servidor Wetlands (puertos 30000/30001/30002/30003), llega un mensaje al canal
de Discord configurado. El sistema se implementa con un **sidecar de Docker**
por mundo, no es un mod del juego.

## Arquitectura

```
┌─────────────────────────────────────────────────────────────────────┐
│ docker compose                                                       │
│                                                                      │
│  luanti-voxelibre-server ──┐                                         │
│  luanti-valdivia-server ───┤ cada uno tiene su sidecar gemelo:      │
│  luanti-gaelsin-server ────┤   discord-notifier                     │
│  luanti-ctf-server ───────┘   discord-notifier-valdivia             │
│                                discord-notifier-gaelsin              │
│                                discord-notifier-ctf                  │
└─────────────────────────────────────────────────────────────────────┘
```

Cada sidecar (`alpine + curl + docker-cli + bash`) ejecuta
`scripts/discord-notifier.sh`, que usa `docker logs -f` contra el contenedor
del juego correspondiente. Cuando detecta un `ACTION[Server]: NOMBRE joins/leaves game`
extrae el nombre y publica un `POST` al webhook.

## Sidecars (`docker-compose.yml`)

| Sidecar | Contenedor que monitorea | Label que aparece en el mensaje |
|---|---|---|
| `discord-notifier` | `luanti-voxelibre-server` | `Wetlands 🌱` |
| `discord-notifier-valdivia` | `luanti-valdivia-server` | `Valdivia 🏙️` |
| `discord-notifier-gaelsin` | `luanti-gaelsin-server` | `GAELSIN ⚔️` |
| `discord-notifier-ctf` | `luanti-ctf-server` | `CTF ⚔️` |

Los 4 sidecars comparten la **misma variable de entorno `DISCORD_WEBHOOK_URL`**
(la URL del webhook se lee desde `.env` en la raíz). Eso significa: **un único
canal de Discord para los 4 mundos**, diferenciados solo por el `SERVER_LABEL`
dentro del texto. Si quieres un canal por mundo, hay que crear 4 webhooks
distintos y 4 variables (`DISCORD_WEBHOOK_URL_WETLANDS`, `_VALDIVIA`, etc.) y
asignarlas en el bloque `environment` de cada sidecar.

## Formato del mensaje

El webhook se publica como JSON plano:

```json
{"content": "🟢 **Jugador Conectado:** pepelomo se ha conectado al servidor 🎮 | **Servidor:** Wetlands 🌱"}
```

Eventos:

| Evento | Emoji | Cuerpo |
|---|---|---|
| Jugador conecta | `🟢` | `**Jugador Conectado:** <nombre> se ha conectado al servidor 🎮` |
| Jugador desconecta | `🔴` | `**Jugador Desconectado:** <nombre> se ha desconectado del servidor 👋` |
| Inicio del notifier | `🤖` | `**Monitor Iniciado:** Sistema de notificaciones activado correctamente ✅` |

Todos terminan en `| **Servidor:** <LABEL>` para identificar el mundo.

**No** se envía avatar personalizado, ni embed, ni ping `@everyone`/`@here`. Es
el webhook plano por defecto de Discord.

## Configuración

### Webhook URL

Definida en `.env` (gitignored, vive en la raíz del repo y en el VPS):

```
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
```

Para crear/regenerar el webhook:

1. Discord → `Server settings` → `Integrations` → `Webhooks` → `New webhook`
2. Elegir el canal destino
3. Copiar URL al `.env`

### Variables del sidecar

En `docker-compose.yml`, cada sidecar toma:

```yaml
environment:
  - CONTAINER_NAME=luanti-<mundo>-server
  - SERVER_LABEL=<Label mostrado>
  - DISCORD_WEBHOOK_URL=${DISCORD_WEBHOOK_URL}
```

`CONTAINER_NAME` y `SERVER_LABEL` se pueden sobreescribir localmente sin
tocar el compose (definir antes de `docker compose up -d`).

## Pruebas

Hay dos scripts auxiliares:

```bash
# Mensaje fijo de prueba (lee .env)
./scripts/test-discord-notification.sh

# Mensaje custom pasado como argumento
./scripts/send-discord-test.sh "Hola desde Wetlands"
```

Ambos hacen `curl -X POST` al mismo webhook y devuelven el código HTTP.

## Cambiar el nombre del mundo en el mensaje

El label se controla con `SERVER_LABEL` en `docker-compose.yml`. Para cambiarlo:

1. Editar la línea `- SERVER_LABEL=...` del sidecar correspondiente
2. `docker compose up -d <sidecar>` para recargar

## Limitaciones y notas

- **Una IP por jugador**: el log trae `ACTION[Server]: NOMBRE [IP] joins game`.
  El `sed` actual (líneas 91 y 107 de `scripts/discord-notifier.sh`) descarta
  la IP. Para incluirla en el mensaje, ajustar el regex.
- **Sin rate limiting**: un reconnect inmediato genera dos mensajes. Si el
  spam es problema, habría que meter un debounce (no implementado).
- **Si el sidecar muere**: tiene `restart: unless-stopped` pero no hay alerta
  externa. Logs internos van a `/tmp/luanti-notifier.log` dentro del contenedor.
- **No distingue bots /mods**: cualquier entrada al juego genera notificación,
  incluida reconexión rápida del mismo jugador.
- **No funciona el `core.open_url()` desde el lado servidor** (limitación de
  Luanti): si quieres linkear al perfil de un jugador, tienes que poner el
  nombre en el mensaje y dejar que el usuario lo copie.

## Archivos relevantes

| Archivo | Rol |
|---|---|
| `scripts/discord-notifier.sh` | Script bash del sidecar |
| `scripts/test-discord-notification.sh` | Test con mensaje fijo |
| `scripts/send-discord-test.sh` | Test con mensaje custom |
| `docker-compose.yml` | 4 servicios `discord-notifier*` |
| `.env` | `DISCORD_WEBHOOK_URL` (gitignored) |
| `docs/02-VALDIVIA-30001/operaciones/VALDIVIA_REMAP_Y_VEHICULOS_2026-03-22.md` | Historial (anotó el alta del sidecar de Valdivia) |
