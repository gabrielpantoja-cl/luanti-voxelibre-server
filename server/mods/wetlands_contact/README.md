# wetlands_contact

`/gabo <mensaje>` para Wetlands (puerto 30000) y Valdivia (puerto 30001): el
jugador escribe hasta 300 caracteres y el mod lo envía con un `POST` HTTPS
asíncrono directo a Telegram o Discord. Wetlands y Valdivia usan **un solo bot
Telegram**. El sidecar interno `wetlands-contact-relay` es el único consumidor
de `getUpdates`; no tiene puertos publicados ni dependencias Python externas.

Plan e historia de la decisión: `docs/01-ORIGINAL-30000/WHATSAPP_ADMIN_ALERTS_PLAN.md`.

## Qué recibe el admin

```text
🌿 Wetlands — mensaje para gabo
Jugador: NombreJugador
Mensaje: Necesito ayuda en mi construcción.
```

Sin IP, coordenadas ni datos del cliente. En Telegram se envía sin
`parse_mode` (el texto del jugador no se interpreta como formato); en Discord
con `allowed_mentions: {"parse": []}` (un `@everyone` del jugador no notifica a
nadie).

## Idioma

Wetlands recibe jugadores de muchos países: los textos para jugadores están en
**inglés** y `locale/wetlands_contact.es.tr` los traduce automáticamente para
clientes con Luanti en español. Si agregas o cambias una cadena `S("...")`,
actualiza también el `.tr` (la clave debe coincidir exacta). `/gabo_admin` y los
logs quedan en español (solo los ve el admin).

## Anuncio en pantalla

Al entrar al mundo, cada jugador que **puede** usar `/gabo` ve durante 60 s,
abajo a la derecha y parpadeando en amarillo/naranjo:

```text
Need help? Type /gabo <message>
to write directly to the admin
```

(en español para clientes en español). Lo ve todo jugador con `shout`; en
`pausa` o sin destino configurado no lo ve nadie. Se
apaga con `/gabo_admin anuncio off`.

## Configuración

1. `secure.http_mods = wetlands_contact` en el archivo `server/config/luanti-<mundo>.conf`
   (sin esto `request_http_api()` devuelve `nil` y `/gabo` responde
   "not available").
2. `load_mod_wetlands_contact = true` en el `.conf` **y** en el `world.mt` del
   mundo (`original` o `valdivia`).
3. Archivo **fuera de git** `server/worlds/<mundo>/wetlands_contact.conf`
   (dueño `1000:1000`, modo `600`), gestionado por operaciones:

   ```ini
   # Original; Valdivia usa el mismo token/chat y world_id = valdivia.
   world_name = Wetlands
   world_id = original
   destination = telegram
   telegram_token = <token de @BotFather compartido por ambos mundos>
   telegram_chat_id = <id positivo del chat privado del admin>
   relay_url = http://wetlands-contact-relay:8788
   ```

   ```ini
   # Discord
   destination = discord
   discord_webhook = https://discord.com/api/webhooks/<id>/<token>
   ```

   Para Telegram, `bash scripts/set-gabo-telegram.sh` usa
   `WETLANDS_TELEGRAM_BOT_TOKEN` y `WETLANDS_TELEGRAM_CHAT_ID` del `.env` local
   (gitignored). Valida token, chat privado y ausencia de webhook antes de
   reemplazar atómicamente los dos archivos; úsalo también para rotar el token.
   La misma ejecución actualiza únicamente esas dos variables en el `.env` del
   VPS, preservando sus demás entradas, para que Compose se las entregue al
   sidecar. Después de una rotación hay que recrear el sidecar.

   En la primera instalación hay que evitar que la versión Lua anterior y el
   relay ejecuten `getUpdates` al mismo tiempo. Primero crea un backup por el
   procedimiento operacional habitual y pide una ventana breve sin respuestas
   desde Telegram. Espera al menos un ciclo de polling, detén limpiamente el
   `luanti-server` antiguo y confirma que terminó. Después inicia el relay y
   recrea `luanti-server` y `luanti-valdivia` con `docker compose up -d
   wetlands-contact-relay luanti-server luanti-valdivia`. Un simple `restart`
   no crea servicios nuevos. No borres el volumen: allí persisten la cola y el
   offset Telegram.

   Se relee en cada envío: cambiar de destino o rotar el token no requiere
   reiniciar. Si falta o está incompleto, `/gabo` queda "not available" y el
   log lo avisa al arrancar. Con Telegram, el admin debe haberle escrito
   `/start` al bot al menos una vez (si no, Telegram responde 403).

### Advertencias de seguridad

- El token de Telegram y el del webhook de Discord van **dentro de la URL**.
  Cuando un envío falla, el motor escribe la URL completa en
  `ERROR[CurlFetch]`: los logs del servidor (`docker logs`, `debug.txt`) deben
  tratarse como privados. Si alguna vez se comparten, rota el token.
- `wetlands_contact.conf` vive dentro del mundo, así que entra en los tarballs
  de `backup-cron` y en las copias externas.
- El volumen nombrado `wetlands-contact-relay-data` contiene la SQLite de cola y
  el offset Telegram. No contiene mundos y no se monta en los procesos Luanti.
- El relay deriva una clave interna por mundo desde el token y `world_id`; no
  requiere crear otra credencial. El API solo está en la red Docker interna.

## Respuestas privadas desde Telegram

Cada aviso Telegram termina con un marcador generado por el mod que contiene
`world_id`, jugador y `request_id`. El administrador debe usar **Responder**
sobre ese aviso. El relay acepta únicamente mensajes del chat privado indicado,
exige que `chat.id` y `from.id` sean ese ID, valida que el mensaje respondido sea
del propio bot y extrae el marcador solo desde `reply_to_message`.

La respuesta queda en SQLite para ese mundo y jugador durante 7 días. El Lua
consulta el relay para cada jugador conectado y usa exclusivamente
`minetest.chat_send_player`; nunca publica con `chat_send_all`. Si el jugador
está desconectado no se envía ACK y la respuesta se entrega al reconectar. El
ACK elimina la cola; una deduplicación local evita repetirla si el ACK falla.

El offset de `getUpdates` avanza en la misma transacción SQLite que guarda o
descarta el update, y `update_id` es la clave de deduplicación. La cola acepta
solo `original` y `valdivia`, respuestas de hasta 500 caracteres y resultados
HTTP acotados. Al iniciar, el relay valida `getMe`, la identidad del bot y que
no exista un webhook. La identidad queda ligada a la SQLite: cambiar a otro bot
falla de forma segura y conserva las respuestas en cola. `/health` comprueba
SQLite y degrada el estado si `getUpdates` deja de responder después del margen
normal de arranque; los logs de reintento nunca incluyen el token.

## Límites y filtros

| Regla | Valor |
|---|---|
| Por jugador | 15 s entre mensajes y máximo 20 por hora (los `server` quedan exentos para pruebas) |
| Global | 100 mensajes por hora entre todos |
| Longitud | 2–300 caracteres (UTF-8): "hola" o "ayuda!" valen |
| Rechazo | enlaces, teléfonos (8+ dígitos seguidos), correos, repeticiones, el mismo mensaje dentro de 3 min |
| Persistencia | `mod_storage`: sobreviven a reinicios. Se guarda el hash del último mensaje, no el texto |
| Fallos | Error HTTP, de red o timeout (10 s): el jugador ve "could not be sent" y recupera su turno. No hay reintentos automáticos |

## Operación

| Comando | Priv | Efecto |
|---|---|---|
| `/gabo <mensaje>` | `shout` | Envía el mensaje; sin texto muestra uso + aviso de seguridad |
| `/gabo_admin estado` | `server` | Modo, anuncio, API HTTP, destino, uso de la última hora |
| `/gabo_admin pausa` | `server` | Corta los envíos al instante (sin reiniciar) |
| `/gabo_admin abierto` | `server` | Cualquier jugador con `shout` (valor por defecto) |
| `/gabo_admin anuncio on\|off` | `server` | Muestra u oculta el anuncio del HUD al entrar |

No hay privilegio propio: basta `shout`, que `wetlands_newplayer` otorga en
Wetlands y `valdivia_newplayer` en Valdivia. Esos mods administran los
privilegios de ingreso, así que no hace falta un `/grant` adicional.

## Prueba local

`scripts/mock-telegram-discord.py` imita ambas APIs sin salir a internet:

```bash
python scripts/mock-telegram-discord.py --token prueba-local
# server/worlds/original/wetlands_contact.conf:
#   telegram_api = http://host.docker.internal:8787
#   telegram_token = prueba-local
#   telegram_chat_id = 12345
#   world_id = original
#   relay_url = http://wetlands-contact-relay:8788
# --no-deps evita arrancar el relay real durante esta prueba solo de envío.
docker compose up -d --no-deps luanti-server
```

`--fail 403` simula un bot bloqueado y `--delay 15` fuerza el timeout. El mock
solo cubre el envío directo; para probar respuestas debe ejecutarse el relay con
un bot de prueba y su volumen SQLite separado.
