# NPC Guía del Spawn — `valdivia_spawn_npc`

Mod exclusivo de Valdivia (puerto 30001) que mejora la primera impresión del
servidor: un **recepcionista estático** parado en el spawn (Plaza de la
República) que da la bienvenida, entrega el enlace de Discord, muestra las
reglas y teletransporta a lugares clave de la ciudad.

Estado: **en producción** desde 2026-07-05.

## Qué hace

| Elemento | Detalle |
|----------|---------|
| NPC guías (uno por lugar) | Estáticos e inmortales (anti-grief), mismo comportamiento pero **skin distinto** cada uno, sobre `mcl_armor_character.b3d`. Definidos en la tabla `GUIAS`: spawn (`:guia`, indie-boy), Parque Catrico (`:guia_parque`, summer-gala), Santa Elena (`:guia_santa_elena`, vegan-activist). |
| Panel al click derecho | **QR de Discord** (escaneable) + enlace copiable + Reglas + menú de Lugares + Cerrar. |
| Bienvenida | **Un solo** mensaje ~3 s después de entrar: título amarillo + "Explora la capital de Los Ríos y haz amigos en la ciudad más linda de Chile". El MOTD se vació y el aviso "Modo pacífico activo" de `mcl_mobs` se silencia (des-registro de su `on_joinplayer`) para no duplicar saludos ni ensuciar el chat. |
| Discord | `https://discord.gg/Y3vfy2JnX` (constante `DISCORD_INVITE`). QR en `textures/valdivia_guia_discord_qr.png` (`tools/generate_discord_qr.py`). |

## Comandos

| Comando | Priv | Uso |
|---------|------|-----|
| `/discord` | — | Muestra el enlace de Discord en el chat (respaldo del NPC). |
| `/spawn_guia [spawn\|parque\|santa_elena]` | `server` | Coloca un guía en tu posición con el skin de ese lugar (sin arg = spawn). Elimina cualquier guía duplicado en radio 6. |
| `/lugar_guardar <id> <nombre>` | `server` | Guarda tu posición actual como destino de teletransporte. El `id` sólo admite `[a-zA-Z0-9_]`. |
| `/lugares` | — | Lista los destinos registrados con sus coordenadas. |

## Arquitectura

- **Un solo mod autónomo** `server/mods/valdivia_spawn_npc/`. No reutiliza el
  sistema de amistad/misiones/comercio de `wetlands_npcs` (no aplica a un
  recepcionista), pero sí replica su patrón de inmortalidad y anti-grief.
- **Estático**: `walk_chance = 0`, `jump = false`, `walk_velocity = 0`, más un
  *ancla* en `do_custom` que lo regresa a su posición si lo empujan (>0.6 nodos).
- **Gira a mirar al jugador**: en `do_custom` orienta su yaw (suavemente) hacia
  el jugador más cercano dentro de `FACE_RANGE` (12 nodos), para que nunca lo
  encuentres de espalda. Misma convención de yaw que `wetlands_npcs`
  (`atan2(dir.z, dir.x) - π/2`) para el modelo `mcl_armor_character.b3d`.
- **Persistencia de lugares**: `worldpath/valdivia_lugares.json`
  (`minetest.write_json`). Sembrado por defecto con tres destinos: **Plaza de la
  República / spawn** (`3766,-4,-3249`), **Parque Catrico** (`5025.5,-17.5,-7028.5`)
  y **Santa Elena** (`6323.1,-15.5,-7270`). El admin puede agregar más en vivo
  con `/lugar_guardar`.
- **Menú de Lugares consciente del contexto**: oculta el destino que esté a
  ≤`HIDE_RADIUS` (20 nodos) del jugador, así nunca ofrece "viajar a donde ya
  estás". Esto hace el teletransporte **bidireccional con una sola lista**: en
  la Plaza el menú ofrece "Parque Catrico"; en el Parque ofrece "Plaza de la
  República". Ambos guías comparten formspec/comportamiento vía
  `register_guia(entity, skin)`; sólo se plantan por separado (ver despliegue).
- **No toca `valdivia_teleporter`**, que sigue deshabilitado por coordenadas
  stale. Este guía lo reemplaza como puerta de entrada al teletransporte.

### Skins (uno distinto por lugar, a propósito)
Cada guía usa un skin de jugador **64×32** sobre `mcl_armor_character.b3d`. Los
fuentes en `server/skins/` son 64×64 (formato moderno de Minecraft) y se recortan
a 64×32 con `tools/convert_skin.py` (lista `JOBS`). Los PNG resultantes están
versionados; sólo re-generar si cambias el skin fuente.

| Guía | Fuente | Textura |
|------|--------|---------|
| Spawn (Plaza) | `2024_06_19_indie-boy-*.png` | `textures/valdivia_guia_skin.png` |
| Parque Catrico | `2026_06_30_summer-gala-*.png` | `textures/valdivia_guia_parque_skin.png` |
| Santa Elena | `2025_06_17_vegan-...-activist-*.png` | `textures/valdivia_guia_santa_elena_skin.png` |

Para **agregar otro guía**: añade el skin a `JOBS` en `convert_skin.py` y córrelo,
añade una entrada a la tabla `GUIAS` en `init.lua`, y (si es un destino nuevo) un
lugar a `DEFAULT_LUGARES`. Luego plántalo con `/spawn_guia <tipo>`.

## Despliegue (ya aplicado)

1. `load_mod_valdivia_spawn_npc = true` en `server/config/luanti-valdivia.conf` (git).
2. Misma línea en `server/worlds/valdivia/world.mt` del VPS (sudo; `world.mt`
   gana sobre el `.conf`). Ver jerarquía de config en `AGENTS.md`.
3. `docker compose restart luanti-valdivia`.
4. In-game como admin, plantar un guía por lugar (skins distintos). Viaja a cada
   sitio (habla con un guía → Lugares) y planta el suyo:
   - Spawn (Plaza): `/spawn_guia`
   - Parque Catrico: `/spawn_guia parque`
   - Santa Elena: `/spawn_guia santa_elena`
   Cada NPC persiste con su mapblock (activo mientras haya jugadores cerca). El
   menú de Lugares oculta el destino donde ya estás, así cada guía ofrece viajar
   a los otros.

## Tareas pendientes

- [ ] **Registrar más ubicaciones clave** con `/lugar_guardar` (ya vienen Plaza
      y Parque Catrico). Candidatos (volar a cada uno y registrar la posición
      real post-Arnis): Mercado Fluvial, Costanera, Los Fundadores, Santa Elena,
      Huachocopihue, Feria Fluvial, Universidad Austral, Puente Pedro de Valdivia.
- [ ] **Voz del NPC.** Que el guía "hable" al interactuar (sonido + frase). El
      mod `wetlands_npcs` ya tiene un sistema de voces reutilizable
      (`play_npc_voice`); falta cablearlo aquí.
- [ ] **Mod de colectivo** que recorra la ciudad siguiendo recorridos reales de
      los colectivos de Valdivia (reemplazo elaborado del teletransporte).
## Enlace de Discord: limitaciones de Luanti (investigado 2026-07-05)

Resumen: en Luanti **no** se puede hacer el enlace *cliqueable* (que abra el
navegador) desde un mod del servidor, y **sí** tiene que ser *borrable* si
queremos que el jugador lo seleccione y copie a mano. Detalle:

- **¿Cliqueable (abre el navegador)? NO.** No existe API server-side para abrir
  una URL en el cliente. `core.open_url()` es sólo del menú principal / CSM del
  cliente, nunca invocable por el servidor (decisión de seguridad). El elemento
  `hypertext[]` sólo dispara *acciones de formulario* (`<action>`), no abre URLs.
  El chat tampoco hipervincula URLs en el cliente vanilla.
- **¿No borrable pero copiable? NO se puede tener ambas.** El **único** widget
  cuyo texto el jugador puede seleccionar y copiar es un `field[]`/`textarea[]`
  *editable* (y por eso, borrable). Los widgets de sólo-lectura (`label`,
  `textarea` sin nombre, `hypertext`) **no** son seleccionables/copiables en el
  cliente. Conclusión: para copiar-pegar manual, el campo **debe** ser borrable.
- Mitigantes aplicados: el borrado es **cosmético y no persistente** (se
  restaura al reabrir el panel) y el enlace también se hace **eco al chat**.
- **✅ Upgrade implementado (2026-07-05): código QR.** El panel muestra un QR de
  la invitación (`image[]`) que el jugador escanea con la cámara del teléfono y
  abre Discord — sin copiar ni escribir nada. Es la vía "un toque" que reemplaza
  al link cliqueable. La textura se genera con `tools/generate_discord_qr.py`
  (lib `qrcode` de Python) y queda versionada; sólo re-generar si cambia
  `DISCORD_INVITE`. El campo copiable se mantiene como respaldo.

## Fuera de alcance

- Construcción física del spawn (plaza/portal decorativo) con WorldEdit in-game.
- Notificador de conexiones hacia Discord (webhook).
