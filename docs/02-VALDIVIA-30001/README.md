# Valdivia [Chile] (Puerto 30001)

Recreación fiel de la ciudad de Valdivia, Chile desde OpenStreetMap con Arnis.

| Aspecto | Valor |
|---------|-------|
| Puerto | 30001/UDP |
| Juego | VoxeLibre (mineclone2) |
| Mapgen | singlenode (mundo pre-generado) |
| Spawn | `3766, -4, -3249` (Plaza de la República) |
| Creativo | Sí |
| Vehículos | 10 mods automobiles |
| Teletransporte | NPC guía del spawn (`valdivia_spawn_npc`) → menú "Lugares". El viejo `valdivia_teleporter` (`/ir`) está deshabilitado (coords stale). |
| Público | Sí (anunciado en lista de servidores) |

## Documentos

- [`current.md`](current.md) — Mundo nuevo (Arnis v2.9.0, baked lighting, remapeado)
- [`guia-spawn.md`](guia-spawn.md) — NPC guía del spawn: bienvenida, Discord, reglas y teletransporte (`valdivia_spawn_npc`)
- [`anti-explosivos.md`](anti-explosivos.md) — Anti-grief: sin explosiones ni incendios (`mcl_explosions_griefing=false` + `valdivia_no_explosions`)
- [`legacy.md`](legacy.md) — Mundo anterior (Arnis PR#808, reemplazado)
- [`operaciones/`](operaciones/) — Operaciones específicas de Valdivia
  - [`SERVER_LIST_DUPLICATE_BUG.md`](operaciones/SERVER_LIST_DUPLICATE_BUG.md) — Bug del image `linuxserver/luanti` que duplica el servidor de Valdivia en la lista pública de Luanti (solo aplica porque Valdivia usa puerto 30001, no el 30000 default).
