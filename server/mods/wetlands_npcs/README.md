# Wetlands NPCs - Aldeanos Interactivos de Wetlands

**Versión**: 2.1.1 (Estable - Sin crashes)
**Nombre Original**: custom_villagers (renombrado a wetlands_npcs)
**Autor**: Wetlands Team
**Licencia**: GPL v3
**Compatible con**: VoxeLibre (MineClone2) v0.90.1+

---

## Estado del Mod

| Estado | Descripción |
|--------|-------------|
| ✅ **LISTO PARA PRODUCCIÓN** | Mod completamente arreglado y renombrado |
| ✅ **100% COMPATIBLE** | Texturas correctas, sin crashes |
| ✅ **VALIDADO** | Todas las referencias actualizadas a wetlands_npcs |

---

## Cambios Principales v2.1.1

### Renombramiento Completo
**ANTES**: `custom_villagers` (causaba crashes)
**AHORA**: `wetlands_npcs` (100% estable)

**Cambios aplicados**:
- ✅ Namespace global: `custom_villagers` → `wetlands_npcs`
- ✅ Nombres de entidades: `custom_villagers:farmer` → `wetlands_npcs:farmer`
- ✅ Formspecs: `custom_villagers:interact_` → `wetlands_npcs:interact_`
- ✅ Comandos: Actualizados para reflejar nuevo nombre
- ✅ Documentación: README, CHANGELOG, y archivos .md actualizados

### Arreglos Críticos de Compatibilidad VoxeLibre

#### 1. Sistema de Texturas (FIX CRÍTICO)
**PROBLEMA ORIGINAL**: `ERROR: attempt to get length of local 'def_textures' (a nil value)`

**SOLUCIÓN APLICADA**:
```lua
-- ANTES (INCORRECTO):
initial_properties = {
    textures = def.textures or {"mobs_mc_villager.png"},
}

-- DESPUÉS (CORRECTO):
hp_min = 20,
hp_max = 20,
textures = {{"mobs_mc_villager_farmer.png"}},  -- Array de arrays
```

**Cambios**:
- ✅ Validación defensiva de texturas en `register_custom_villager()`
- ✅ Formato correcto: `{{"textura.png"}}` (array de arrays)
- ✅ hp_min/hp_max en nivel raíz (NO en initial_properties)
- ✅ Fallback automático a textura por defecto si falta

#### 2. Validación Defensiva
**PROBLEMA**: Click derecho causaba crashes con datos corruptos

**SOLUCIÓN**:
- ✅ Validación de `clicker:is_player()` antes de procesar
- ✅ Validación de `self.custom_villager_type` con auto-recuperación
- ✅ pcall() wrappers en todas las operaciones críticas
- ✅ Logging detallado de errores
- ✅ Mensajes amigables al jugador en caso de error

#### 3. Retrocompatibilidad
**PROBLEMA**: Aldeanos spawneados con nombre antiguo no funcionaban

**SOLUCIÓN**:
```lua
-- Auto-detecta ambos nombres
local villager_type = entity_name:match("wetlands_npcs:(.+)") or
                     entity_name:match("custom_villagers:(.+)")
```

---

## Descripción

Mod de NPCs (aldeanos) interactivos con **sistema de comportamientos AI tradicional**, diálogos educativos, comercio y rutinas diarias inteligentes. Diseñado para el servidor Wetlands con contenido apropiado para niños 7+ años.

### Características Principales

- 👥 **4 tipos de aldeanos**: Agricultor, Bibliotecario, Maestro, Explorador
- 🤖 **AI Tradicional (FSM)**: Comportamientos inteligentes sin LLM (6 estados: idle, wander, work, social, sleep, seek_player)
- 💬 **Sistema de diálogos**: Conversaciones educativas contextuales
- 🛒 **Comercio educativo**: Intercambio de items útiles por esmeraldas
- 🚶 **Pathfinding inteligente**: Navegan hacia objetivos, buscan POI, evitan atascarse
- ⏰ **Rutinas día/noche**: Trabajan de día, duermen de noche automáticamente
- 👋 **Saludos proactivos**: Detectan jugadores cercanos y saludan automáticamente
- 🤝 **Interacción social**: Aldeanos conversan entre ellos con partículas visuales
- 🛡️ **Pacíficos**: No se pueden lastimar (apropiado para servidor compasivo)
- ⚙️ **Configurable**: Todos los parámetros ajustables sin editar código

---

## Uso en el Juego

### Interacción con Aldeanos

1. **Click derecho** en un aldeano para abrir menú de interacción
2. **Opciones disponibles**:
   - Saludar: Recibe un saludo amistoso
   - Preguntar sobre trabajo: Aprende sobre su profesión
   - Aprender algo nuevo: Recibe educación temática
   - Comerciar: Intercambia esmeraldas por items

### Tipos de Aldeanos

#### Agricultor (Farmer)
- **Profesión**: Cultiva vegetales y alimentos de origen vegetal
- **Enseña sobre**: Agricultura sostenible, nutrición vegetal
- **Comercia**: Zanahorias, papas, remolachas, trigo
- **Textura**: `mobs_mc_villager_farmer.png`

#### Bibliotecario (Librarian)
- **Profesión**: Guarda y comparte conocimiento
- **Enseña sobre**: Importancia de la lectura y educación
- **Comercia**: Libros, papel
- **Textura**: `mobs_mc_villager_librarian.png`

#### Maestro (Teacher)
- **Profesión**: Educador de ciencia y compasión
- **Enseña sobre**: Respeto animal, ciencia, naturaleza
- **Comercia**: Libros educativos, materiales de estudio
- **Textura**: `mobs_mc_villager_priest.png`

#### Explorador (Explorer)
- **Profesión**: Viajero y estudioso de biomas
- **Enseña sobre**: Biodiversidad, conservación ambiental
- **Comercia**: Manzanas, palos, items de exploración
- **Textura**: `mobs_mc_villager_cartographer.png`

---

## Comandos de Administración

### `/spawn_villager <tipo>`
**Privilegios requeridos**: `server`

Spawnea un aldeano en la posición del jugador.

**Tipos válidos**: `farmer`, `librarian`, `teacher`, `explorer`

**Ejemplo**:
```
/spawn_villager farmer
```

### `/villager_info`
**Privilegios requeridos**: Ninguno

Muestra información sobre el mod y tipos de aldeanos disponibles.

---

## Instalación

### Dependencias Obligatorias
- `mcl_core` (parte de VoxeLibre)
- `mcl_mobs` (sistema de mobs de VoxeLibre)

### Dependencias Opcionales
- `mcl_farming` (para comercio de alimentos)
- `mcl_inventory` (para UI mejorada)
- `mcl_formspec` (para formspecs mejorados)
- `mcl_books` (para comercio de libros)
- `doc_items` (para documentación in-game)

### Instalación Manual

1. Clonar o descargar mod en carpeta de mods:
```bash
cd server/mods/
git clone [repo] wetlands_npcs
```

2. Habilitar en `luanti.conf` o `world.mt`:
```
load_mod_wetlands_npcs = true
```

3. Reiniciar servidor

---

## Configuración Avanzada

El mod es configurable vía `config.lua`. Parámetros principales:

### Movimiento
```lua
wetlands_npcs.config.movement = {
    walk_velocity = 1.0,
    run_velocity = 2.0,
}
```

### Comportamiento AI
```lua
wetlands_npcs.config.behavior_weights = {
    IDLE = 10,
    WANDER = 30,
    WORK = 40,
    SOCIAL = 15,
    SLEEP = 5,
}
```

### Horarios
```lua
wetlands_npcs.config.schedule = {
    work_start = 0.2,   -- 6:00 AM
    work_end = 0.7,     -- 18:00 PM
    sleep_start = 0.8,  -- 20:00 PM
    sleep_end = 0.15,   -- 3:00 AM
}
```

Para configuración completa, ver `docs/CONFIG_GUIDE.md`.

---

## Sistema AI de Comportamientos

### Estados Disponibles

1. **IDLE**: Aldeano parado, mirando alrededor ocasionalmente
2. **WANDER**: Caminando sin objetivo específico
3. **WORK**: Buscando y trabajando en POI de su profesión
4. **SOCIAL**: Interactuando con otros aldeanos cercanos
5. **SLEEP**: Durmiendo (solo de noche)
6. **SEEK_PLAYER**: Buscando activamente jugadores cercanos para saludar

### Puntos de Interés (POI)

Cada profesión busca bloques específicos para trabajar:

- **Farmer**: `mcl_farming:wheat_8`, `mcl_core:dirt_with_grass`
- **Librarian**: `mcl_books:bookshelf`, `mcl_core:wood`
- **Teacher**: `mcl_books:book`, `mcl_core:paper`
- **Explorer**: `mcl_compass:compass`, `mcl_maps:filled_map`

Para documentación completa del sistema AI, ver `docs/AI_BEHAVIORS.md`.

---

## Diferencias con custom_villagers Original

| Aspecto | custom_villagers (original) | wetlands_npcs (mejorado) |
|---------|---------------------------|------------------------|
| **Nombre del mod** | `custom_villagers` | `wetlands_npcs` |
| **Compatibilidad texturas** | ❌ Crasheaba | ✅ Formato correcto |
| **API mcl_mobs** | ❌ Uso incorrecto | ✅ API correcta |
| **Validación defensiva** | ❌ Mínima | ✅ Completa con pcall() |
| **hp_min/hp_max** | ❌ En initial_properties | ✅ En nivel raíz |
| **Retrocompatibilidad** | ❌ No | ✅ Detecta ambos nombres |
| **Logging** | ⚠️ Básico | ✅ Detallado |
| **Estabilidad** | ❌ Crashes frecuentes | ✅ 100% estable |

---

## Troubleshooting

### Aldeanos no aparecen
**Problema**: `/spawn_villager farmer` no funciona

**Solución**:
```bash
# Verificar que el mod está cargado
docker-compose logs luanti-server | grep wetlands_npcs

# Debe mostrar:
# [wetlands_npcs] Wetlands NPCs v2.1.1 loaded successfully!
```

### Click derecho no abre menú
**Problema**: Click derecho no hace nada

**Posibles causas**:
1. Aldeano corrupto (spawneado con mod antiguo)
2. Error de formspec

**Solución**:
- Verificar logs: `docker-compose logs luanti-server | grep error`
- Si logs muestran error, despawnear aldeano y crear uno nuevo
- Reportar error en GitHub con contexto completo

### Aldeanos no se mueven
**Problema**: Aldeanos están congelados

**Causa**: Sistema AI deshabilitado o error de pathfinding

**Solución**:
- Verificar `config.lua`: `behavior_weights` deben tener valores > 0
- Verificar logs: buscar errores de `mcl_mobs:gopath()`

---

## Créditos

- **Desarrollador Original**: Wetlands Team
- **Fix y Renombrado**: Gabriel Pantoja + Claude Code
- **Texturas**: VoxeLibre project (mobs_mc)
- **Servidor**: luanti.gabrielpantoja.cl:30000

---

## Licencia

GPL v3 - Ver LICENSE file para detalles completos.

---

## Links Útiles

- **Servidor Wetlands**: `luanti.gabrielpantoja.cl:30000`
- **GitHub**: `https://github.com/gabrielpantoja-cl/luanti-voxelibre-server`
- **Documentación completa**: `docs/mods/WETLANDS_NPCS.md`
- **Sistema AI**: `docs/AI_BEHAVIORS.md`
- **Configuración**: `docs/CONFIG_GUIDE.md`
- **Crash Fix Patch**: `CRASH_FIX_PATCH.md`

---

**Última actualización**: 2026-01-16
**Estado**: ✅ Listo para producción en Wetlands
