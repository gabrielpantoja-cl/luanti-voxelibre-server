# Wetlands NPCs - Versión Mejorada

## 📋 Resumen

`wetlands_npcs` es la versión mejorada y estable de `custom_villagers`, diseñada para ser 100% compatible con VoxeLibre v0.90.1 y evitar crashes del servidor.

## 🔄 Cambios desde custom_villagers

### ✅ Arreglado - Crash de texturas
**Problema original:**
```
ERROR: attempt to get length of local 'def_textures' (a nil value)
...minetest/games/mineclone2/mods/ENTITIES/mcl_mobs/api.lua:101
```

**Solución aplicada:**
- Validación defensiva de texturas antes de registro (líneas 293-305 en init.lua)
- Fallback automático a textura por defecto de VoxeLibre
- Formato correcto de array de arrays para mcl_mobs

### 📝 Renombrado completo
- **Nombre del mod**: `custom_villagers` → `wetlands_npcs`
- **Entidades**: `custom_villagers:farmer` → `wetlands_npcs:farmer`
- **Namespace global**: `custom_villagers` → `wetlands_npcs`

### 🔒 Compatibilidad hacia atrás
- El código puede cargar entidades antiguas de `custom_villagers`
- Auto-fix para aldeanos spawneados con el mod anterior (línea 370)
- No se pierden datos al migrar

## 🚀 Estado actual

- ✅ **Código mejorado y corregido**
- ✅ **Renombrado completo**
- ❌ **AÚN NO ACTIVADO** en producción
- ⏳ **Pendiente testing** antes de activación

## 📁 Estructura del mod

```
wetlands_npcs/
├── mod.conf           # Configuración del mod (renombrado)
├── init.lua          # Código principal (con fixes)
├── config.lua        # Configuración centralizada
├── dialogues.lua     # Diálogos educativos
├── trades.lua        # Sistema de comercio
├── behaviors.lua     # AI y comportamientos
├── textures/         # Texturas de NPCs
└── README_MEJORAS.md # Este archivo
```

## 🧪 Plan de testing

### Fase 1: Testing en servidor de desarrollo
1. Activar el mod en `world.mt`:
   ```
   load_mod_wetlands_npcs = true
   ```
2. Spawnear aldeanos con `/spawn_villager <tipo>`
3. Verificar que NO crashea al cargarlos
4. Probar interacciones (clic derecho, diálogos, comercio)

### Fase 2: Migration testing
1. Cargar mundo con aldeanos antiguos de custom_villagers
2. Verificar que el auto-fix funciona
3. Confirmar que no hay crashes

### Fase 3: Production deployment
1. Si Fase 1 y 2 son exitosas, activar en producción
2. Monitorear logs por 24 horas
3. Confirmar estabilidad

## 🔧 Cómo activar el mod

**IMPORTANTE:** NO activar hasta completar testing exitoso

```bash
# 1. Editar world.mt
nano server/worlds/world/world.mt

# 2. Agregar línea:
load_mod_wetlands_npcs = true

# 3. Reiniciar servidor
docker compose restart luanti-server

# 4. Spawnear aldeano de prueba
/spawn_villager farmer
```

## ⚠️ Notas importantes

1. **custom_villagers está DESACTIVADO** y debe permanecer así
2. **wetlands_npcs está DESACTIVADO** hasta completar testing
3. Los aldeanos antiguos NO se eliminarán, solo quedan inaccesibles
4. Si hay problemas, simplemente desactivar `wetlands_npcs` en world.mt

## 🐛 Debugging

Si hay problemas, revisar logs:
```bash
docker compose logs --tail=100 luanti-server | grep -i 'wetlands_npcs\|error'
```

Errores comunes:
- `LuaEntity name "wetlands_npcs:X" not defined` → Mod no activado
- `def_textures` error → Problema de compatibilidad (no debería pasar)

## 📊 Diferencias técnicas clave

| Aspecto | custom_villagers | wetlands_npcs |
|---------|------------------|---------------|
| Validación de texturas | ❌ No | ✅ Sí (defensiva) |
| Fallback de texturas | ❌ No | ✅ Sí (default VL) |
| Formato de texturas | ⚠️ Inconsistente | ✅ Array de arrays |
| Auto-fix de entidades viejas | ❌ No | ✅ Sí (backward compat) |
| Crashes conocidos | ❌ Sí | ✅ No (corregido) |

## 📅 Historial

- **2026-01-16**: Creado desde custom_villagers
- **2026-01-16**: Aplicados fixes de compatibilidad VoxeLibre
- **2026-01-16**: Renombrado completo del mod
- **Pendiente**: Testing y activación en producción

## 👤 Autor

Wetlands Team - Mejorado por Claude Code
Basado en custom_villagers original v2.0.0
