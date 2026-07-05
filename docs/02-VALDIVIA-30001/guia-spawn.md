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
  (`minetest.write_json`). Sembrado por defecto **vacío** — el spawn NO es un
  destino (no tiene sentido teletransportarse a donde ya estás). Los destinos
  reales los registra el admin en vivo con `/lugar_guardar`, evitando adivinar
  coordenadas viejas post-Arnis.
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
4. In-game como admin: `/spawn_guia` en el spawn para plantar al NPC (persiste
   con el mapblock del spawn, que siempre está cargado).

## Tareas pendientes

- [ ] **Registrar ubicaciones clave** con `/lugar_guardar`. Hasta que se haga, el
      menú "Lugares" muestra "Todavía no hay lugares para viajar". Candidatos
      (volar a cada uno y registrar la posición real post-Arnis):
      Mercado Fluvial, Costanera, Los Fundadores, Santa Elena, Huachocopihue,
      Feria Fluvial, Universidad Austral, Puente Pedro de Valdivia.
- [ ] **Enlace de Discord borrable (cosmético).** El link va en un `field[]`
      porque es el **único** widget de Luanti que permite seleccionar y copiar
      texto (labels y chat no son copiables en el cliente). Efecto lateral: el
      jugador puede borrar el texto con Delete, lo que se ve poco pulido. Se
      restaura solo al cerrar y reabrir el panel. Luanti **no** ofrece un campo
      de sólo-lectura ni una API server-side para abrir el navegador
      (`open_url` es sólo cliente), así que no hay un arreglo limpio nativo.
      Alternativas a evaluar: un cartel/nodo físico con la invitación, o un bot
      que publique el enlace en `#conexiones-servidor`.

## Fuera de alcance

- Construcción física del spawn (plaza/portal decorativo) con WorldEdit in-game.
- Notificador de conexiones hacia Discord (webhook).
