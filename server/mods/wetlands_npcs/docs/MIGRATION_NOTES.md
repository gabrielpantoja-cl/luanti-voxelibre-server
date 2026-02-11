# Notas de Migración: custom_villagers → wetlands_npcs

**Fecha**: 2026-01-16
**Versión**: 2.1.1
**Autor**: Gabriel Pantoja + Claude Code (lua-mod-expert)

---

## Resumen de Cambios

Este documento detalla la migración completa de `custom_villagers` (versión problemática) a `wetlands_npcs` (versión estable y compatible con VoxeLibre v0.90.1).

---

## Problemas Resueltos

### 1. Crash al Click Derecho (CRÍTICO)

**Error Original**:
```
ERROR: attempt to get length of local 'def_textures' (a nil value)
...minetest/games/mineclone2/mods/ENTITIES/mcl_mobs/api.lua:101
```

**Causa Raíz**:
- Formato incorrecto de texturas (string simple en lugar de array de arrays)
- `hp_min`/`hp_max` en ubicación incorrecta (`initial_properties` en lugar de nivel raíz)
- Falta de validación defensiva

**Solución Aplicada**:
```lua
-- ANTES (INCORRECTO):
initial_properties = {
    hp_max = 20,
    textures = def.textures or {"mobs_mc_villager.png"},
}

-- DESPUÉS (CORRECTO):
hp_min = 20,
hp_max = 20,
textures = {{"mobs_mc_villager_farmer.png"}},  -- Array de arrays
```

### 2. Namespace y Nombres de Entidades

**Cambios**:
- `custom_villagers` → `wetlands_npcs` (namespace global)
- `custom_villagers:farmer` → `wetlands_npcs:farmer` (entidades)
- `custom_villagers:interact_` → `wetlands_npcs:interact_` (formspecs)
- `custom_villagers:trade_` → `wetlands_npcs:trade_` (formspecs)

**Retrocompatibilidad**:
El mod detecta automáticamente aldeanos spawneados con el nombre antiguo:
```lua
local villager_type = entity_name:match("wetlands_npcs:(.+)") or
                     entity_name:match("custom_villagers:(.+)")
```

### 3. Validación Defensiva

**Mejoras Implementadas**:
- Validación de `clicker:is_player()` antes de procesar clicks
- Validación de `self.custom_villager_type` con recuperación automática
- `pcall()` wrappers en operaciones críticas (formspecs, pathfinding)
- Logging detallado de errores con contexto
- Mensajes amigables al jugador en caso de error

**Ejemplo**:
```lua
local success, err = pcall(function()
    show_interaction_formspec(player_name, self.custom_villager_type, villager_name)
end)

if not success then
    log("error", "on_rightclick failed: " .. tostring(err))
    minetest.chat_send_player(player_name, "[Servidor] Error al interactuar. Intenta de nuevo.")
end
```

---

## Archivos Modificados

### Archivos Core
1. **init.lua** - Inicialización, registro de mobs, comandos
   - Renombrado namespace: `custom_villagers` → `wetlands_npcs`
   - Fix texturas: formato array de arrays
   - Fix hp_min/hp_max: nivel raíz
   - Validación defensiva completa

2. **config.lua** - Configuración centralizada
   - Renombrado namespace: `custom_villagers.config` → `wetlands_npcs.config`
   - Actualizado settings: `wetlands_npcs_debug`

3. **ai_behaviors.lua** - Sistema de comportamientos AI
   - Renombrado namespace: `custom_villagers.behaviors` → `wetlands_npcs.behaviors`
   - Actualizado config: `wetlands_npcs.config`

### Documentación
4. **README.md** - Documentación principal (reescrita completamente)
5. **MIGRATION_NOTES.md** - Este documento (nuevo)
6. **mod.conf** - Metadatos del mod (ya actualizado previamente)

---

## Cambios de API

### Para Desarrolladores

Si tienes código externo que interactúa con este mod:

**ANTES**:
```lua
-- Namespace global
custom_villagers.config.get("movement.walk_velocity")
custom_villagers.dialogues.farmer.greetings

-- Spawning
minetest.add_entity(pos, "custom_villagers:farmer")

-- Formspecs
minetest.show_formspec(player_name, "custom_villagers:interact_farmer", formspec)
```

**AHORA**:
```lua
-- Namespace global
wetlands_npcs.config.get("movement.walk_velocity")
wetlands_npcs.dialogues.farmer.greetings

-- Spawning
minetest.add_entity(pos, "wetlands_npcs:farmer")

-- Formspecs
minetest.show_formspec(player_name, "wetlands_npcs:interact_farmer", formspec)
```

---

## Testing Recomendado

Después de actualizar, verificar:

### Test 1: Carga del Mod
```bash
docker-compose logs luanti-server | grep wetlands_npcs
# Debe mostrar:
# [wetlands_npcs] Wetlands NPCs v2.1.1 loaded successfully!
```

### Test 2: Spawn de Aldeanos
```
/spawn_villager farmer
/spawn_villager librarian
/spawn_villager teacher
/spawn_villager explorer
```

Verificar que todos se spawnean correctamente sin errores.

### Test 3: Interacción
1. Click derecho en cada tipo de aldeano
2. Verificar que formspec se abre correctamente
3. Probar cada botón (Saludar, Trabajo, Educación, Comerciar)

### Test 4: Comportamientos AI
1. Observar aldeanos durante varios ciclos día/noche
2. Verificar que caminan, trabajan, socializan, duermen
3. Comprobar que no hay crashes en logs

### Test 5: Retrocompatibilidad
1. Si tienes aldeanos spawneados con nombre antiguo (`custom_villagers:*`)
2. Verificar que aún funcionan correctamente
3. Auto-detección debe recuperar el tipo correctamente

---

## Rollback (En caso de problemas)

Si el nuevo mod causa problemas inesperados:

```bash
# 1. Deshabilitar mod nuevo
mv server/mods/wetlands_npcs server/mods/wetlands_npcs.disabled

# 2. Habilitar mod antiguo (si tienes backup)
mv server/mods/custom_villagers.disabled server/mods/custom_villagers

# 3. Reiniciar servidor
docker-compose restart luanti-server

# 4. Reportar issue en GitHub con logs completos
```

---

## Deployment Checklist

Antes de deployment a producción:

- [x] Todos los archivos .lua renombrados
- [x] Config files actualizados
- [x] README.md reescrito
- [x] mod.conf validado
- [x] Testing local completado
- [x] Backup del mundo creado
- [ ] Notificar jugadores de mantenimiento
- [ ] Deploy a VPS
- [ ] Testing post-deployment
- [ ] Monitorear logs por 24 horas

---

## Compatibilidad

### Versiones Soportadas
- **VoxeLibre**: v0.90.1+ (requerido)
- **Luanti/Minetest**: 5.4.0+ (requerido)
- **mcl_mobs**: API moderna (incluido en VoxeLibre)

### Dependencias Obligatorias
- `mcl_core`
- `mcl_mobs`

### Dependencias Opcionales
- `mcl_farming`, `mcl_inventory`, `mcl_formspec`, `mcl_books`, `doc_items`

---

## Créditos

- **Mod Original**: custom_villagers (Wetlands Team)
- **Migración y Fix**: Gabriel Pantoja + Claude Code (lua-mod-expert agent)
- **Testing**: Servidor Wetlands (luanti.gabrielpantoja.cl:30000)

---

## Referencias

- **CRASH_FIX_PATCH.md** - Detalles técnicos del parche original
- **README.md** - Documentación completa del mod
- **docs/AI_BEHAVIORS.md** - Sistema de comportamientos AI
- **CLAUDE.md** - Contexto del servidor Wetlands

---

**Estado Final**: ✅ Migración completa, mod listo para testing y deployment
**Próximo Paso**: Testing exhaustivo en servidor local antes de producción
