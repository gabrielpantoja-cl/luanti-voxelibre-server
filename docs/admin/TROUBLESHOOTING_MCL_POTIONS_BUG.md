# 🚨 Bug Crítico: mcl_potions - Crashes con Pociones de Invisibilidad

**Fecha del incidente**: 2025-10-12
**Severidad**: CRÍTICA (causa crashes constantes del servidor)
**Estado**: ✅ RESUELTO

## Descripción del Problema

El mod **`mcl_potions`** de VoxeLibre v0.90.1 contiene un bug crítico que causa crashes del servidor cuando los jugadores usan **pociones de invisibilidad** (`mcl_potions:invisibility_lingering`).

### Error Específico

```
ServerError: AsyncErr: Lua: Runtime error from mod 'mcl_potions' in callback environment_Step():
.../games/mineclone2/mods/ITEMS/mcl_potions/functions.lua:1717:
attempt to index local 'luaentity' (a nil value)

stack traceback:
    .../games/mineclone2/mods/ITEMS/mcl_potions/functions.lua:1717: in function 'make_invisible'
    .../games/mineclone2/mods/ITEMS/mcl_potions/functions.lua:208: in function 'on_end'
    .../games/mineclone2/mods/ITEMS/mcl_potions/functions.lua:1357: in function <...>
```

### Causa Raíz

El código del mod intenta acceder a una **entidad Lua (`luaentity`) que ya no existe** (fue eliminada del juego pero el código de efectos de la poción sigue intentando procesarla).

Esto ocurre específicamente en la función `make_invisible()` línea 1717 de `functions.lua`.

### Síntomas

- ✅ Servidor se crashea cada vez que se usa una poción de invisibilidad
- ✅ Se reinicia automáticamente (Docker restart policy)
- ✅ Jugadores experimentan desconexiones frecuentes
- ✅ Logs muestran el error repetidamente
- ✅ No es problema de recursos (RAM/CPU estaban normales)

### Impacto

- **Jugabilidad**: Interrupciones constantes durante el juego
- **Experiencia del usuario**: Frustrante para jugadores (gabo y pepelomo afectados)
- **Estabilidad del servidor**: Reinicios cada ~30 segundos cuando el efecto de la poción está activo

## Solución Implementada

### Opción 1: Deshabilitar `mcl_potions` (Aplicada)

**Método**: Deshabilitar el mod completo en `world.mt`

```bash
# En el VPS
echo 'load_mod_mcl_potions = false' >> $PROJECT_PATH/server/worlds/original/world.mt

# Reiniciar servidor
cd $PROJECT_PATH
docker compose restart luanti-server
```

**Resultado**: ✅ Servidor estable, sin crashes

**Trade-offs**:
- ❌ Pociones no disponibles en el servidor
- ✅ Servidor 100% estable
- ✅ Alineado con filosofía del servidor (modo creativo compasivo)

### Verificación de la Solución

```bash
# Ver logs sin errores de mcl_potions
docker compose logs --tail=50 luanti-server | grep -E 'mcl_potions|ERROR'

# Verificar servidor healthy
docker compose ps luanti-server

# Estado esperado: Up (healthy), puerto 30000 abierto
```

## Alternativas Consideradas

### Opción 2: Parche del Mod (No implementada)

Crear un override del mod con validación de `nil`:

```lua
-- En server/mods/mcl_potions_fix/init.lua
local original_make_invisible = mcl_potions.make_invisible

mcl_potions.make_invisible = function(obj, factor)
    if not obj or not obj:get_luaentity() then
        minetest.log("warning", "[mcl_potions_fix] Attempted to make_invisible on nil entity")
        return
    end
    return original_make_invisible(obj, factor)
end
```

**Razón no implementada**: Solución más compleja, requiere testing extensivo

### Opción 3: Actualizar VoxeLibre (Futura)

Verificar si versiones más recientes de VoxeLibre tienen el fix:
- Revisar changelog en https://content.luanti.org/packages/Wuzzy/mineclone2/
- Considerar actualización si hay fix oficial

## Prevención Futura

### Monitoreo Proactivo

**Script de monitoreo de errores** (agregar a cron):

```bash
#!/bin/bash
# $PROJECT_PATH/scripts/monitor-errors.sh

ERRORS=$(docker compose logs --tail=100 luanti-server | grep -c "ERROR\[Main\]: ServerError")

if [ "$ERRORS" -gt 5 ]; then
    echo "⚠️ ALERTA: $ERRORS errores detectados en los últimos 100 logs"
    # Enviar notificación (webhook n8n, email, etc.)
fi
```

### Testing de Mods

**Protocolo antes de habilitar mods nuevos**:
1. ✅ Buscar issues conocidos en ContentDB
2. ✅ Probar en entorno local primero
3. ✅ Monitorear logs durante las primeras 24 horas
4. ✅ Tener backup reciente del mundo

### Lista de Mods Problemáticos

| Mod | Problema | Estado | Alternativa |
|-----|----------|--------|-------------|
| `mcl_potions` | Crash con pociones invisibilidad | ❌ Deshabilitado | Ninguna (no crítico para servidor creativo) |
| `motorboat` | Incompatible con VoxeLibre | ❌ Deshabilitado | N/A |
| `biofuel` | Incompatible con VoxeLibre | ❌ Deshabilitado | N/A |
| `mobkit` | Incompatible con VoxeLibre | ❌ Deshabilitado | N/A |

## Documentación de Referencia

### Archivos Afectados

- `server/worlds/original/world.mt` - Configuración de mods del mundo
- `server/games/mineclone2/mods/ITEMS/mcl_potions/` - Mod problemático (VoxeLibre)

### Comandos Útiles

```bash
# Ver mods cargados en el mundo
cat server/worlds/original/world.mt | grep load_mod

# Verificar salud del servidor
docker compose ps
docker stats --no-stream luanti-voxelibre-server

# Buscar errores específicos
docker compose logs luanti-server | grep -A 5 "mcl_potions"
```

## Lecciones Aprendidas

1. **Mods de VoxeLibre pueden tener bugs**: Incluso mods base del juego necesitan testing
2. **Crashes repetidos indican patrón**: Buscar en logs qué acción del jugador los causa
3. **Deshabilitar > Parchar**: Para bugs críticos, mejor deshabilitar que arriesgar
4. **Docker restart policy salva**: Aunque crasheaba, el servidor volvía automáticamente

## Contacto y Soporte

- **Admin del servidor**: gabo
- **Issue tracker**: https://github.com/gabrielpantoja-cl/luanti-voxelibre-server/issues
- **VoxeLibre ContentDB**: https://content.luanti.org/packages/Wuzzy/mineclone2/

---

**Documentado por**: Claude Code + Gabriel Pantoja
**Última actualización**: 2025-10-12