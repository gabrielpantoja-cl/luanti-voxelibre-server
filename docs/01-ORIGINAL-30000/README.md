# Wetlands (Puerto 30000)

Mundo principal: creativo, educativo, apto para niños, **compassivo y plant-based**. NPCs no-violentos, animales, música, PvP arena opt-in.

| Aspecto | Valor |
|---------|-------|
| Puerto | 30000/UDP |
| Juego | VoxeLibre (mineclone2) |
| Mapgen | v7 |
| Spawn actual | `655.1,18.5,243.9` |
| Spawn historico original | `0,15,0` (usado antes del cambio de julio de 2026) |
| Creativo | Sí |
| Daño | Sí (mobs hostiles de noche) |
| PvP | Solo en arena (mod `pvp_arena`) |
| Filosofía | 🌱 Compassivo y plant-based (ver [VEGAN_PHILOSOPHY.md](VEGAN_PHILOSOPHY.md)) |
| Mods clave | `wetlands_npcs`, `wetlands_music`, `wetlands_no_creeper`, `wetlands_lastpos`, `voxelibre_protection`, `pvp_arena`, `vegan_food`, `vegan_replacements`, `education_blocks` |

## Documentación de este mundo

### Filosofía del servidor
- [VEGAN_PHILOSOPHY.md](VEGAN_PHILOSOPHY.md) — 🌱 qué significa "compassivo y plant-based" en Wetlands, mods que lo implementan, qué se mantiene y qué se cambia

### Configuración (específica de Wetlands)
- [config/03-MIXED_GAMEMODE.md](config/03-MIXED_GAMEMODE.md) — creativo + supervivencia simultáneos (caso pepelomo)
- [config/05-BLOCK_PROTECTION.md](config/05-BLOCK_PROTECTION.md) — sistema de bloques protectores anti-griefing
- [config/06-RULES_SYSTEM.md](config/06-RULES_SYSTEM.md) — sistema de reglas (`/reglas`, `/veganinfo`) y moderación

### Admin
- [admin/CREATIVE_INVENTORY_MANAGEMENT.md](admin/CREATIVE_INVENTORY_MANAGEMENT.md) — ocultar items del inventario creativo (filosofía vegana)

### Jugadores
- [quickstart/primeros-pasos.md](quickstart/primeros-pasos.md) — tutorial inicial con la filosofía educativa

### Construcción y otros
- [construccion/](construccion/) — guías de WorldEdit (edificio de oficinas, jardín zen, ascensor)
- [construccion/SCHEMATICS_REMapeADOS_DESDE_MG_VILLAGES.md](construccion/SCHEMATICS_REMapeADOS_DESDE_MG_VILLAGES.md) — intento de importar chateau/biblioteca/torre medievales desde Sokomine/mg_villages; documenta el script de remap y el lío con el comando `/mtschemplace` vs `/load`
- [pvp/PVP_ARENA_WORLDEDIT_GUIDE.md](pvp/PVP_ARENA_WORLDEDIT_GUIDE.md) — arena PvP
- [auto-road-builder/](auto-road-builder/) — mod constructor de caminos

> Mecánica agnóstica al mundo (jerarquía de config, VoxeLibre, mods, backups) vive en
> [`../00-SHARED/`](../00-SHARED/).
