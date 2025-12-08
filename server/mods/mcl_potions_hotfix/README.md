# 🔧 MCL Potions Hotfix - Fix para Bug de Invisibilidad

**Versión**: 1.0  
**Autor**: Wetlands Team  
**Compatibilidad**: VoxeLibre v0.90.1

## 📖 Descripción

Hotfix temporal para un bug crítico en VoxeLibre v0.90.1 relacionado con pociones de invisibilidad. El bug causa crashes del servidor con el error: `attempt to index local 'luaentity' (a nil value)` en `functions.lua:1717`.

## 🎯 Propósito

Este mod es un **hotfix temporal** para:
- **Prevenir crashes** del servidor por pociones de invisibilidad
- **Ocultar pociones problemáticas** del inventario creativo
- **Parchear función problemática** con validación nil-safe
- **Eliminar entidades problemáticas** existentes

## 🚀 Características

### Pociones Deshabilitadas

El mod oculta del inventario creativo:
- `mcl_potions:invisibility` - Poción de invisibilidad
- `mcl_potions:invisibility_plus` - Poción de invisibilidad mejorada
- `mcl_potions:invisibility_splash` - Poción splash de invisibilidad
- `mcl_potions:invisibility_plus_splash` - Poción splash mejorada
- `mcl_potions:invisibility_lingering` - Poción lingering de invisibilidad
- `mcl_potions:invisibility_plus_lingering` - Poción lingering mejorada
- `mcl_potions:invisibility_arrow` - Flecha de invisibilidad

### Parche de Función

El mod parchea `mcl_potions.make_invisible()` con:
- Validación de objeto nil
- Validación de métodos necesarios
- Validación de luaentity
- Manejo seguro de errores

### Limpieza Automática

El mod elimina automáticamente:
- Entidades de pociones de invisibilidad existentes
- Cualquier entidad problemática relacionada

## 🔧 Configuración

### Dependencias

```lua
depends = mcl_potions
```

**Requisito**: El mod `mcl_potions` debe estar cargado (viene con VoxeLibre base).

### Habilitar el Mod

Agregar en `server/config/luanti.conf`:
```ini
load_mod_mcl_potions_hotfix = true
```

O en `server/worlds/world/world.mt`:
```ini
load_mod_mcl_potions_hotfix = true
```

## ⚠️ Advertencias

### Hotfix Temporal

Este mod es un **hotfix temporal**:
- ⚠️ No es una solución permanente
- ⚠️ Debe eliminarse cuando VoxeLibre arregle el bug
- ⚠️ Puede necesitar actualización si cambia la API de `mcl_potions`

### Impacto en Gameplay

- Los jugadores **no pueden** obtener pociones de invisibilidad
- Las pociones existentes se eliminan automáticamente
- Los administradores reciben notificación del hotfix activo

## 🔄 Funcionamiento Técnico

### Sistema de Ocultación

1. **Al cargar**: Identifica todas las pociones de invisibilidad
2. **Sobrescribe items**: Agrega `not_in_creative_inventory = 1`
3. **Modifica descripción**: Agrega "[DESHABILITADA - Bug conocido]"

### Sistema de Parche

1. **Guarda función original**: Almacena `mcl_potions.make_invisible`
2. **Crea función parcheada**: Con validaciones nil-safe
3. **Reemplaza función**: Sobrescribe la función original

### Sistema de Limpieza

1. **Cada frame**: Busca entidades problemáticas
2. **Identifica por nombre**: Busca entidades con "invisibility" en el nombre
3. **Elimina automáticamente**: Remueve entidades problemáticas

## 🐛 Bug Original

### Error Original

```
ERROR[Main]: attempt to index local 'luaentity' (a nil value)
stack traceback:
    .../mcl_potions/functions.lua:1717: in function 'make_invisible'
```

### Causa

La función `make_invisible()` intenta acceder a `luaentity` sin validar que existe:
```lua
local luaentity = obj:get_luaentity()
-- Error: luaentity puede ser nil
local something = luaentity.some_property  -- CRASH aquí
```

### Solución

El hotfix valida antes de acceder:
```lua
local luaentity = obj:get_luaentity()
if not luaentity then
    return  -- Salir seguramente
end
-- Ahora es seguro acceder a luaentity
```

## 📝 Notificaciones

### Para Administradores

Los administradores reciben un mensaje al conectarse:
```
⚠️ [Hotfix Activo] Pociones de invisibilidad deshabilitadas por bug conocido de VoxeLibre
```

### En Logs

El mod registra:
- Pociones ocultadas
- Función parcheada exitosamente
- Entidades eliminadas

## 🔗 Integración con Otros Mods

Este mod es independiente pero:
- ✅ Funciona con todos los mods de VoxeLibre
- ✅ No interfiere con otras pociones
- ⚠️ Depende de `mcl_potions` (viene con VoxeLibre)

## 🐛 Troubleshooting

### El servidor sigue crasheando

1. Verificar que el mod está habilitado:
   ```bash
   docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/world.mt | grep mcl_potions_hotfix
   ```

2. Verificar logs:
   ```bash
   docker-compose logs luanti-server | grep mcl_potions_hotfix
   ```

3. Verificar que `mcl_potions` está cargado:
   ```bash
   docker-compose logs luanti-server | grep "mcl_potions"
   ```

### Las pociones siguen apareciendo

1. Verificar que el mod se cargó después de `mcl_potions`
2. El orden de carga puede afectar
3. Reiniciar servidor para asegurar orden correcto

## 🔄 Actualización Futura

Cuando VoxeLibre arregle el bug:
1. Verificar que el bug está resuelto en la nueva versión
2. Deshabilitar este mod
3. Probar pociones de invisibilidad
4. Si funciona, eliminar el mod del repositorio

## 📚 Referencias

- Bug report: (agregar link si existe)
- VoxeLibre issue tracker: (agregar link si existe)
- Documentación de `mcl_potions`: Ver mods base de VoxeLibre

---

**Última actualización**: Diciembre 7, 2025  
**Mantenedor**: Equipo Wetlands  
**Licencia**: GPL-3.0  
**⚠️ Hotfix Temporal**: Eliminar cuando VoxeLibre arregle el bug

