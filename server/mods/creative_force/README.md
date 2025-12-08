# 🌱 Creative Force - Forzar Modo Creativo y Eliminar Violencia

**Versión**: 1.0  
**Autor**: Wetlands Team  
**Compatibilidad**: VoxeLibre v0.90.1

## 📖 Descripción

Mod "nuclear" que fuerza completamente el modo creativo y elimina toda violencia del servidor. Garantiza un ambiente 100% seguro y creativo para niños, otorgando automáticamente todos los privilegios creativos y eliminando cualquier entidad hostil.

## 🎯 Propósito

Este mod es **CRÍTICO** para:
- **Forzar modo creativo** para todos los jugadores
- **Eliminar completamente** mobs hostiles y violencia
- **Otorgar kit de inicio** completo a nuevos jugadores
- **Garantizar ambiente seguro** para niños 7+ años
- **Prevenir daño** a jugadores

## 🚀 Características

### Privilegios Automáticos

Todos los jugadores reciben automáticamente:
- `creative` - Modo creativo
- `give` - Dar items
- `fly` - Volar
- `fast` - Movimiento rápido
- `noclip` - Atravesar bloques
- `interact` - Interactuar con todo
- `shout` - Hablar en chat
- `home` - Sistema de homes
- `spawn` - Teleportación a spawn
- `teleport` - Teleportación general
- `settime` - Cambiar tiempo
- `debug` - Modo debug
- `basic_privs` - Privilegios básicos

### Kit de Inicio Completo

Los nuevos jugadores reciben automáticamente un inventario completo con:
- Bloques de construcción (piedra, tierra, madera, etc.)
- Materiales de decoración (lana, vidrio, etc.)
- Comida vegana (manzanas, pan, zanahorias, etc.)
- Herramientas (pico, pala, hacha)
- Items de redstone y automatización
- Rieles y minecarts
- Semillas y agricultura
- Items de cuidado animal (huesos, heno)

### Eliminación de Violencia

El mod elimina completamente:
- ✅ Todo daño a jugadores (HP siempre al máximo)
- ✅ Todos los mobs hostiles (zombies, esqueletos, creepers, etc.)
- ✅ Flechas y proyectiles
- ✅ Spawning de entidades hostiles

### Comandos

| Comando | Descripción | Privilegios |
|---------|-------------|-------------|
| `/starter_kit` | Obtener kit de inicio completo | Todos |
| `/give_starter_kit <jugador>` | Dar kit a otro jugador | `give` |

## 🔧 Configuración

### Dependencias

```lua
depends =
```

No tiene dependencias obligatorias, pero funciona con:
- `mcl_core` (para items base)
- `vegan_food` (para comida vegana en el kit)

### Habilitar el Mod

Agregar en `server/config/luanti.conf`:
```ini
load_mod_creative_force = true
```

O en `server/worlds/world/world.mt`:
```ini
load_mod_creative_force = true
```

## ⚠️ Advertencias

### Modo "Nuclear"

Este mod es extremadamente agresivo:
- Elimina entidades hostiles **cada segundo**
- Fuerza HP completo **cada segundo**
- Bloquea completamente el daño
- Elimina mobs hostiles del sistema de spawning

**No usar** si quieres mantener alguna mecánica de supervivencia.

### Compatibilidad

Este mod puede:
- ✅ Funcionar con `server_rules` (bienvenida coordinada)
- ✅ Funcionar con `vegan_food` (agrega items veganos al kit)
- ⚠️ Conflictos potenciales con mods de supervivencia
- ⚠️ Puede interferir con mods de PvP (pero PvP está deshabilitado en Wetlands)

## 🔄 Funcionamiento Técnico

### Sistema de Eliminación de Mobs

El mod ejecuta cada segundo:
1. Busca todas las entidades en un radio de 65536 bloques
2. Identifica entidades hostiles por nombre
3. Elimina inmediatamente cualquier entidad hostil encontrada

### Sistema de Privilegios

Al conectar un jugador:
1. Se otorgan automáticamente todos los privilegios creativos
2. Se verifica que el jugador es nuevo
3. Se entrega kit de inicio después de 1.5 segundos

### Sistema de Daño

El mod intercepta todos los eventos de cambio de HP:
- Retorna siempre `0` (sin daño)
- Fuerza HP completo cada segundo como respaldo

## 📝 Lista de Mobs Eliminados

El mod elimina automáticamente:
- `mobs_mc:zombie`
- `mobs_mc:skeleton`
- `mobs_mc:creeper`
- `mobs_mc:spider`
- `mobs_mc:cave_spider`
- `mobs_mc:witch`
- `mobs_mc:enderman`
- `mobs_mc:slime_*` (todas las variantes)
- `mobs_mc:magma_cube_*` (todas las variantes)
- `mobs_mc:ghast`
- `mobs_mc:blaze`
- `mobs_mc:zombiepig`
- `mobs_mc:wither_skeleton`
- `mobs_mc:wither`
- `mobs_mc:ender_dragon`
- `mobs_mc:shulker`
- `mobs_mc:guardian`
- `mobs_mc:guardian_elder`
- `mobs_mc:vindicator`
- `mobs_mc:evoker`
- `mobs_mc:vex`
- `mobs_mc:pillager`
- `mobs_mc:ravager`
- `mobs_mc:phantom`
- `mcl_bows:arrow_entity` (flechas)

## 🐛 Troubleshooting

### Los privilegios no se otorgan

1. Verificar que el mod está habilitado:
   ```bash
   docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/world.mt | grep creative_force
   ```

2. Verificar logs:
   ```bash
   docker-compose logs luanti-server | grep creative_force
   ```

3. Verificar privilegios manualmente:
   ```
   /privs nombre_jugador
   ```

### El kit de inicio no se entrega

1. Verificar que el jugador es nuevo (primera conexión)
2. El kit se entrega después de 1.5 segundos de conexión
3. Usar `/starter_kit` manualmente si es necesario

### Los mobs hostiles siguen apareciendo

1. Verificar logs para ver si se están eliminando:
   ```bash
   docker-compose logs luanti-server | grep "REMOVED.*hostile"
   ```

2. El sistema verifica cada segundo, puede haber un pequeño delay
3. Verificar que el mod está cargado correctamente

## 📊 Impacto en Rendimiento

Este mod puede tener un impacto en rendimiento:
- **Búsqueda de entidades**: Cada segundo busca en un radio grande
- **Eliminación de entidades**: Puede ser costoso si hay muchas

**Recomendación**: Este mod es necesario para la filosofía de Wetlands, pero monitorear rendimiento del servidor.

## 🔗 Integración con Otros Mods

Este mod es fundamental y debe cargarse:
- ✅ **Antes** de mods que dependen de modo creativo
- ✅ **Junto con** `server_rules` (bienvenida coordinada)
- ✅ **Junto con** `vegan_replacements` (eliminación de items no veganos)

## 📚 Documentación Adicional

- Ver documentación general en `docs/mods/README.md`
- Ver configuración nuclear en `docs/config/nuclear-config.md`

---

**Última actualización**: Diciembre 7, 2025  
**Mantenedor**: Equipo Wetlands  
**Licencia**: GPL-3.0  
**⚠️ Mod Crítico**: No deshabilitar sin reemplazo adecuado

