# Wetlands (Puerto 30000)

Mundo principal: **supervivencia compassiva y plant-based**, educativa, apta para niños. NPCs no-violentos, animales, sin creepers, sin PvP.

| Aspecto | Valor |
|---------|-------|
| Puerto | 30000/UDP |
| Juego | VoxeLibre (mineclone2) |
| Mapgen | v7 |
| Spawn actual | `655.1,18.5,243.9` |
| Spawn historico original | `0,15,0` (usado antes del cambio de julio de 2026) |
| Creativo | **No** (supervivencia dura desde 2026-07-31) |
| Daño | Sí (mobs hostiles de noche, sin creepers) |
| PvP | **No** (deshabilitado a nivel engine + arena opt-in retirada 2026-07-31) |
| Filosofía | 🌱 Compassivo y plant-based (ver [VEGAN_PHILOSOPHY.md](VEGAN_PHILOSOPHY.md)) |
| Mods clave | `wetlands_no_creeper`, `wetlands_lastpos`, `worldedit`, `mcl_custom_world_skins` |
| Admin (`gabo`) | Conserva inventario creativo + fly/noclip/worldedit/debug vía whitelist en `wetlands_newplayer` |

## Documentación de este mundo

### Filosofía del servidor
- [VEGAN_PHILOSOPHY.md](VEGAN_PHILOSOPHY.md) — 🌱 qué significa "compassivo y plant-based" en Wetlands, mods que lo implementan, qué se mantiene y qué se cambia

### Configuración (específica de Wetlands)
- [config/05-BLOCK_PROTECTION.md](config/05-BLOCK_PROTECTION.md) — sistema de bloques protectores anti-griefing (deshabilitado en supervivencia)
- [config/06-RULES_SYSTEM.md](config/06-RULES_SYSTEM.md) — sistema de reglas (`/reglas`, `/veganinfo`) y moderación

### Admin
- [admin/CREATIVE_INVENTORY_MANAGEMENT.md](admin/CREATIVE_INVENTORY_MANAGEMENT.md) — ocultar items del inventario creativo (filosofía vegana)

### Jugadores
- [quickstart/primeros-pasos.md](quickstart/primeros-pasos.md) — tutorial inicial con la filosofía educativa (nota: actualizado para supervivencia dura)

### Construcción y otros
- [pvp/PVP_ARENA_WORLDEDIT_GUIDE.md](pvp/PVP_ARENA_WORLDEDIT_GUIDE.md) — guía histórica de la arena PvP (arena retirada el 2026-07-31 al pasar a supervivencia dura)
- [auto-road-builder/](auto-road-builder/) — mod constructor de caminos (deshabilitado en supervivencia)

> Mecánica agnóstica al mundo (jerarquía de config, VoxeLibre, mods, backups) vive en
> [`../00-SHARED/`](../00-SHARED/).
