# Changelog - Custom Villagers

Todas las actualizaciones notables de este mod serán documentadas aquí.

---

## [v2.1.1] - 2026-01-16

### Fixed
- **API Deprecada**: Migrado `hp_min` y `hp_max` desde nivel base a `initial_properties`
  - Elimina warnings de mcl_mobs sobre API deprecada
  - Mejora compatibilidad con versiones futuras de VoxeLibre
  - Sigue el estándar moderno de mcl_mobs para definiciones de entidades

### Changed
- Reorganizada estructura de `mob_def` en función `register_custom_villager()`
- Movidas propiedades visuales y físicas a `initial_properties`:
  - `hp_max = 20`
  - `collisionbox`
  - `visual` y `mesh`
  - `textures`
  - `makes_footstep_sound`

### Technical Details
```lua
-- Antes (API deprecada):
hp_min = 20,
hp_max = 20,
collisionbox = {...},

-- Ahora (API moderna):
initial_properties = {
    hp_max = 20,
    collisionbox = {...},
    visual = "mesh",
    mesh = "mobs_mc_villager.b3d",
    textures = {...},
    makes_footstep_sound = true,
}
```

### Notes
- NO requiere cambios en mundos existentes (compatibilidad total)
- Los aldeanos ya spawneados conservan su salud y propiedades
- Se eliminan warnings de logs del servidor
- Preparado para futuras versiones de mcl_mobs

---

## [v2.1.0] - 2026-01-16

### Added
- Sistema de comportamientos AI tradicional (FSM - Finite State Machine)
- 6 estados de comportamiento: IDLE, WANDER, WORK, SOCIAL, SLEEP, SEEK_PLAYER
- Saludos automáticos proactivos cuando jugadores se acercan
- Sistema de configuración centralizado (config.lua)
- Pathfinding inteligente para buscar POIs (puntos de interés)
- Ciclo día/noche (aldeanos duermen de noche)
- Interacción social entre aldeanos
- Partículas visuales para estados (trabajo, social, sueño)

### Changed
- Arquitectura modular con archivos separados:
  - `init.lua` - Registro de entidades y comandos
  - `config.lua` - Configuración centralizada
  - `ai_behaviors.lua` - Sistema de comportamientos AI
- Mejorado sistema de pathfinding con validación defensiva

### Fixed
- Protección pcall() en pathfinding para evitar crashes
- Validación exhaustiva de parámetros en callbacks

---

## [v2.0.0] - 2026-01-16

### Major Rewrite
- Migrado completamente de mobs_redo a mcl_mobs (VoxeLibre nativo)
- Sistema completamente reescrito para compatibilidad VoxeLibre

### Fixed (Critical)
- **RESUELTO**: Click derecho en NPCs ya NO crashea el servidor
- Eliminados emojis de mensajes (causaban crashes en clientes)
- Validación defensiva implementada en todos los formspecs
- Protección pcall() en interacciones críticas
- Logging mejorado para debugging

### Added
- Texturas profesionales de VoxeLibre para cada profesión:
  - Farmer: `mobs_mc_villager_farmer.png`
  - Librarian: `mobs_mc_villager_librarian.png`
  - Teacher: `mobs_mc_villager_priest.png`
  - Explorer: `mobs_mc_villager_cartographer.png`
- Sistema de diálogos educativos (3 categorías por profesión)
- Sistema de comercio con esmeraldas
- Protección anti-daño (aldeanos no se pueden lastimar)
- Comandos de administración:
  - `/spawn_villager <tipo>` - Spawnear aldeanos
  - `/villager_info` - Información del mod

### Changed
- Modelo 3D: `mobs_mc_villager.b3d` (modelo de VoxeLibre)
- Sistema de colisiones mejorado
- Animaciones actualizadas para compatibilidad mcl_mobs

### Removed
- Dependencia de mobs_redo (obsoleta en VoxeLibre)
- Emojis en mensajes (causaban crashes)
- APIs vanilla Minetest (migrado a mcl_*)

---

## [v1.0.0] - Versión Inicial (Pre-mcl_mobs)

### Initial Release
- Sistema básico con mobs_redo
- 4 tipos de aldeanos (farmer, librarian, teacher, explorer)
- Diálogos simples
- Comercio básico

### Issues (Pre-v2.0.0)
- Crashes al click derecho (resuelto en v2.0.0)
- Incompatibilidad con VoxeLibre moderno
- Emojis causaban problemas
- API deprecada sin migrar

---

## Referencias

- **Documentación**: README.md
- **TODO**: TODO.md
- **Crash Fix Details**: CRASH_FIX_PATCH.md
- **AI Behaviors**: docs/AI_BEHAVIORS.md

---

## Convenciones de Versionado

Seguimos [Semantic Versioning](https://semver.org/):
- **MAJOR** (X.0.0): Cambios incompatibles de API
- **MINOR** (0.X.0): Nuevas funcionalidades compatibles
- **PATCH** (0.0.X): Correcciones de bugs y fixes

**Formato**: `[vMAJOR.MINOR.PATCH] - YYYY-MM-DD`
