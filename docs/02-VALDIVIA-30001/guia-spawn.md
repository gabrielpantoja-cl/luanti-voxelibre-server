# NPC Guía del Spawn — `valdivia_spawn_npc`

Mod exclusivo de Valdivia (puerto 30001) que mejora la primera impresión del
servidor: un **recepcionista estático** parado en el spawn (Plaza de la
República) que da la bienvenida, entrega el enlace de Discord, muestra las
reglas y teletransporta a lugares clave de la ciudad.

Estado: **en producción** desde 2026-07-05.

## Qué hace

| Elemento | Detalle |
|----------|---------|
| NPC guía | Estático e inmortal (anti-grief). Skin `indie-boy` recortado a 64×32 sobre `mcl_armor_character.b3d`. Entidad `valdivia_spawn_npc:guia`. |
| Panel al click derecho | Enlace de Discord copiable + Reglas de Valdivia + menú de Lugares + Cerrar. |
| Bienvenida | Mensaje en el chat ~3 s después de entrar, apuntando al guía y a `/discord`. |
| Discord | `https://discord.gg/Y3vfy2JnX` (constante `DISCORD_INVITE` en `init.lua`). |

## Comandos

| Comando | Priv | Uso |
|---------|------|-----|
| `/discord` | — | Muestra el enlace de Discord en el chat (respaldo del NPC). |
| `/spawn_guia` | `server` | Coloca al guía en tu posición. Elimina duplicados en radio 6, así que puedes reubicarlo repitiendo el comando. |
| `/lugar_guardar <id> <nombre>` | `server` | Guarda tu posición actual como destino de teletransporte. El `id` sólo admite `[a-zA-Z0-9_]`. |
| `/lugares` | — | Lista los destinos registrados con sus coordenadas. |

## Arquitectura

- **Un solo mod autónomo** `server/mods/valdivia_spawn_npc/`. No reutiliza el
  sistema de amistad/misiones/comercio de `wetlands_npcs` (no aplica a un
  recepcionista), pero sí replica su patrón de inmortalidad y anti-grief.
- **Estático**: `walk_chance = 0`, `jump = false`, `walk_velocity = 0`, más un
  *ancla* en `do_custom` que lo regresa a su posición si lo empujan (>0.6 nodos).
- **Persistencia de lugares**: `worldpath/valdivia_lugares.json`
  (`minetest.write_json`). Sembrado por defecto con dos destinos: **Plaza de la
  República / spawn** (`3766,-4,-3249`) y **Parque Catrico** (`5025.5,-17.5,-7028.5`).
  El admin puede agregar más en vivo con `/lugar_guardar`.
- **Menú de Lugares consciente del contexto**: oculta el destino que esté a
  ≤`HIDE_RADIUS` (20 nodos) del jugador, así nunca ofrece "viajar a donde ya
  estás". Esto hace el teletransporte **bidireccional con una sola lista**: en
  la Plaza el menú ofrece "Parque Catrico"; en el Parque ofrece "Plaza de la
  República". El **mismo** NPC `guia` sirve para ambos extremos — sólo hay que
  plantar una segunda instancia en el Parque (ver despliegue).
- **No toca `valdivia_teleporter`**, que sigue deshabilitado por coordenadas
  stale. Este guía lo reemplaza como puerta de entrada al teletransporte.

### Skin
El fuente `server/skins/2024_06_19_indie-boy-22622590.png` es 64×64 (formato skin
moderno de Minecraft). Se recorta a 64×32 con `tools/convert_skin.py` (mismo
proceso que los NPCs Star Wars de `wetlands_npcs`). El PNG resultante
`textures/valdivia_guia_skin.png` está versionado; no hace falta re-generarlo.

## Despliegue (ya aplicado)

1. `load_mod_valdivia_spawn_npc = true` en `server/config/luanti-valdivia.conf` (git).
2. Misma línea en `server/worlds/valdivia/world.mt` del VPS (sudo; `world.mt`
   gana sobre el `.conf`). Ver jerarquía de config en `AGENTS.md`.
3. `docker compose restart luanti-valdivia`.
4. In-game como admin, plantar **dos** instancias del guía:
   - En el spawn: párate en la Plaza y corre `/spawn_guia`.
   - En el Parque Catrico: viaja allá (habla con el guía → Lugares → "Parque
     Catrico") y corre `/spawn_guia` de nuevo. El NPC del Parque ofrecerá
     "Plaza de la República" para volver.
   Cada NPC persiste con su mapblock (activo mientras haya jugadores cerca).

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
- Mitigantes ya aplicados: el borrado es **cosmético y no persistente** (se
  restaura al reabrir el panel) y el enlace también se hace **eco al chat**.
- **Mejor upgrade posible (pendiente): código QR.** Generar un PNG con el QR de
  la invitación y mostrarlo en el formspec con `image[]`. El jugador lo escanea
  con la cámara del teléfono y abre Discord — sin copiar ni escribir nada. Es la
  vía "un toque" que reemplaza al link cliqueable. Requiere la lib `qrcode` de
  Python para generar la textura (una vez, versionada).

## Fuera de alcance

- Construcción física del spawn (plaza/portal decorativo) con WorldEdit in-game.
- Notificador de conexiones hacia Discord (webhook).
