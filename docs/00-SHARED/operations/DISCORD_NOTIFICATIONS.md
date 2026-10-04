# Notificaciones Discord — conexiones de jugadores

## Resumen

Cada vez que un jugador se conecta o desconecta de cualquier mundo Luanti del
servidor Wetlands (puertos 30000/30001/30002/30003/30004), llega un mensaje al canal
de Discord configurado. El sistema se implementa con un **sidecar de Docker**
por mundo, no es un mod del juego.

## Arquitectura

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ docker compose                                                               │
│                                                                               │
│  luanti-voxelibre-server ──┐                                                  │
│  luanti-valdivia-server ───┤ cada uno tiene su sidecar gemelo:               │
│  luanti-gaelsin-server ────┤   discord-notifier                               │
│  luanti-plano-server ──────┤   discord-notifier-valdivia                      │
│  luanti-mineclonia-server ─┘   discord-notifier-gaelsin                       │
│                                   discord-notifier-plano                      │
│                                   discord-notifier-mineclonia                 │
└──────────────────────────────────────────────────────────────────────────────┘
```

Cada sidecar (`alpine + curl + docker-cli + bash`) ejecuta
`scripts/discord-notifier.sh`, que usa `docker logs -f` contra el contenedor
del juego correspondiente. Cuando detecta un `ACTION[Server]: NOMBRE joins/leaves game`
extrae el nombre y publica un `POST` al webhook.

## Sidecars (`docker-compose.yml`)

| Sidecar | Contenedor que monitorea | Identificación en el mensaje |
|---|---|---|
| `discord-notifier` | `luanti-voxelibre-server` | `Wetlands 🌱 [30000]` |
| `discord-notifier-valdivia` | `luanti-valdivia-server` | `Valdivia 🏙️ [30001]` |
| `discord-notifier-gaelsin` | `luanti-gaelsin-server` | `GAELSIN ⚔️ [30002]` |
| `discord-notifier-plano` | `luanti-plano-server` | `Plano 🟩 [30003]` |
| `discord-notifier-mineclonia` | `luanti-mineclonia-server` | `Mineclonia 🎮 [30004]` |

Los 5 sidecars comparten la **misma variable de entorno `DISCORD_WEBHOOK_URL`**
(la URL del webhook se lee desde `.env` en la raíz). Eso significa: **un único
canal de Discord para los 5 mundos**, diferenciados solo por el `SERVER_LABEL`
dentro del texto. Si quieres un canal por mundo, hay que crear 5 webhooks
distintos y 5 variables (`DISCORD_WEBHOOK_URL_WETLANDS`, `_VALDIVIA`, etc.) y
asignarlas en el bloque `environment` de cada sidecar.

## Formato del mensaje

Pensado para leerse en el celular (rediseño 2026-10-04): **tres filas cortas**,
una por categoría, con un emoji como viñeta. Las filas 2 y 3 usan el *subtext*
de Discord (`-# `): letra más chica y gris, así el jugador destaca y el resto
ocupa menos ancho.

```
🟢 **henry** entró
-# 📍 Barcelona, Spain · `83.51.*.*`
-# 🌱 Wetlands · :30000
```

| Evento | Fila 1 | Fila 2 | Fila 3 |
|---|---|---|---|
| Jugador conecta | `🟢 **<nombre>** entró` | `📍 <ciudad>, <país> · <ip-enmascarada>` | `<emoji> <mundo> · :<puerto>` |
| Jugador desconecta | `🔴 **<nombre>** salió` | `⏱️ <duración> jugando` | igual |
| Inicio del notifier | `🤖 **Monitor activo**` | `✅ Aviso cada entrada y salida` | igual |

- **Fila del mundo**: sale de `SERVER_LABEL`; el último token (el emoji) pasa a
  ser la viñeta (`Wetlands 🌱` → `🌱 Wetlands`). Sin emoji, usa `🌍`.
- **Truncado**: Discord no permite truncar por CSS, así que el notifier acorta
  la ubicación a ~26 caracteres, recortando la ciudad y nunca el país
  (`Falkenstein an d…, Germany`).
- **Duración de la sesión**: el notifier guarda en memoria la hora de entrada de
  cada jugador. Si el monitor se reinició mientras el jugador estaba conectado,
  la fila dice `Duración desconocida`.
- **Escapes**: el nombre se escapa para markdown (`mr_cool_guy` no sale en
  cursiva), la IP va en `código` (antes Discord se comía los `*` y mostraba
  `83.51..`), y el JSON se arma escapando comillas y saltos de línea.
- **Sin pings**: se envía `allowed_mentions: {parse: []}`, así un nombre como
  `everyone` no notifica a nadie. Sin avatar personalizado ni embed (el embed
  agrega relleno y en el celular ocupa más alto que tres líneas de texto).

## Geolocalización y privacidad de la IP

Al conectar, el notifier extrae la IP del evento de log
(`ACTION[Server]: NOMBRE [IP] joins game`), la geolocaliza y la publica
**enmascarada**:

- **Proveedor**: [ip-api.com](http://ip-api.com) — API gratuita, sin clave,
  plan free en HTTP con **45 consultas/min** por IP de origen. No hay caché:
  cada conexión nueva hace una consulta (una reconexión inmediata repite la
  consulta, dentro del límite del proveedor).
- **Enmascaramiento**: se conserva solo la **primera mitad** de la dirección.
  Ejemplo: `104.28.154.250` → `104.28.*.*` (IPv6: primeros 2 grupos, ej.
  `2001:db8:*:*`). **La IP completa jamás viaja hacia Discord** — el JSON que
  sale del sidecar solo contiene la versión enmascarada.
- **IPs privadas** (`10.*`, `192.168.*`, `172.16-31.*`, `127.*`, IPv6 ULA/
  link-local): no se consultan; el mensaje va sin ubicación y con la IP
  enmascarada de todas formas.
- **Fallbacks**: si la API falla o no retorna ciudad/país, el mensaje degrada
  gracefully:
  - con geo: `📍 Ciudad, País · a.b.*.*`
  - sin geo: `📍 Ubicación desconocida · a.b.*.*`
  - sin IP: `📍 Ubicación desconocida`
- **IPv4 vía IPv6**: Luanti loguea las IPv4 como `::ffff:a.b.c.d`; el notifier
  quita ese prefijo antes de enmascarar (antes salía `::*:*`, visto como `:::`).
- Las desconexiones no llevan IP ni geolocalización (solo importa el origen
  del ingreso).

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
  - SERVER_PORT=<Puerto público>
  - DISCORD_WEBHOOK_URL=${DISCORD_WEBHOOK_URL}
```

`CONTAINER_NAME`, `SERVER_LABEL` y `SERVER_PORT` se pueden sobreescribir localmente sin
tocar el compose (definir antes de `docker compose up -d`). `SERVER_PORT` es opcional;
si falta, la fila del mundo va sin puerto.

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

- **IP siempre enmascarada**: la IP del log se usa para geolocalizar y se
  publica truncada (ver "Geolocalización y privacidad de la IP"). No hay forma
  de que el mensaje muestre la IP completa — es intencional (privacidad).
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
| `docker-compose.yml` | 5 servicios `discord-notifier*` |
| `.env` | `DISCORD_WEBHOOK_URL` (gitignored) |
| `docs/02-VALDIVIA-30001/operations/VALDIVIA_REMAP_Y_VEHICULOS_2026-03-22.md` | Historial (anotó el alta del sidecar de Valdivia) |
