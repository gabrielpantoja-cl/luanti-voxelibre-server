# wetlands_contact

`/gabo <mensaje>` para Wetlands (puerto 30000): el jugador escribe hasta 300
caracteres y el mod lo envía con un `POST` HTTPS asíncrono **directo** al
celular del administrador, por **Telegram** (bot) o **Discord** (webhook). No
hay servicios intermedios.

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

(en español para clientes en español). En modo `piloto` solo lo ven quienes
tienen el privilegio `avisar`; sin destino configurado no lo ve nadie. Se
apaga con `/gabo_admin anuncio off`.

## Configuración

1. `secure.http_mods = wetlands_contact` en `server/config/luanti-original.conf`
   (sin esto `request_http_api()` devuelve `nil` y `/gabo` responde
   "not available").
2. `load_mod_wetlands_contact = true` en el `.conf` **y** en el `world.mt` del
   mundo `original`.
3. Archivo **fuera de git** `server/worlds/original/wetlands_contact.conf`
   (dueño `1000:1000`, modo `600`), gestionado por operaciones:

   ```ini
   # Telegram (por defecto)
   telegram_token = <token de @BotFather>
   telegram_chat_id = <id del chat del admin>
   ```

   ```ini
   # Discord
   destination = discord
   discord_webhook = https://discord.com/api/webhooks/<id>/<token>
   ```

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
- Por ambas razones conviene un **bot dedicado** a Wetlands (que solo puede
  escribirle al admin) en vez de reutilizar un bot con más permisos.

## Límites y filtros

| Regla | Valor |
|---|---|
| Por jugador | 1 mensaje cada 10 min (los `server` quedan exentos para pruebas) |
| Global | 30 mensajes por hora |
| Longitud | 5–300 caracteres (UTF-8) |
| Rechazo | enlaces, teléfonos (8+ dígitos seguidos), correos, repeticiones, mismo mensaje que el anterior |
| Persistencia | `mod_storage`: sobreviven a reinicios. Se guarda el hash del último mensaje, no el texto |
| Fallos | Error HTTP, de red o timeout (10 s): el jugador ve "could not be sent" y recupera su turno. No hay reintentos automáticos |

## Operación

| Comando | Priv | Efecto |
|---|---|---|
| `/gabo <mensaje>` | `shout` (+ `avisar` en modo piloto) | Envía el mensaje; sin texto muestra uso + aviso de seguridad |
| `/gabo_admin estado` | `server` | Modo, anuncio, API HTTP, destino, uso de la última hora |
| `/gabo_admin pausa` | `server` | Corta los envíos al instante (sin reiniciar) |
| `/gabo_admin piloto` | `server` | Solo jugadores con `avisar` (valor por defecto) |
| `/gabo_admin abierto` | `server` | Cualquier jugador con `shout` |
| `/gabo_admin anuncio on\|off` | `server` | Muestra u oculta el anuncio del HUD al entrar |

Durante el piloto: `/grant <jugador> avisar`. El admin (`name` del `.conf`)
recibe `avisar` automáticamente.

## Prueba local

`scripts/mock-telegram-discord.py` imita ambas APIs sin salir a internet:

```bash
python scripts/mock-telegram-discord.py --token prueba-local
# server/worlds/original/wetlands_contact.conf:
#   telegram_api = http://host.docker.internal:8787
#   telegram_token = prueba-local
#   telegram_chat_id = 12345
docker compose up -d luanti-server
```

`--fail 403` simula un bot bloqueado y `--delay 15` fuerza el timeout.
