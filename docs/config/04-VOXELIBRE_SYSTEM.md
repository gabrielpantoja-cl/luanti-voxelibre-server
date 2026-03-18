# 04 - VOXELIBRE SYSTEM: Complete Technical Guide

**Última actualización**: 2026-01-16
**Estado**: ✅ Sistema funcionando correctamente
**Cobertura**: Arquitectura interna, sistema de mods, optimización

---

## 📋 Tabla de Contenidos

1. [Arquitectura Interna de VoxeLibre](#1-arquitectura-interna-de-voxelibre)
2. [Sistema de Mods Técnico](#2-sistema-de-mods-técnico)
3. [Optimización y Rendimiento](#3-optimización-y-rendimiento)
4. [Troubleshooting y Mantenimiento](#4-troubleshooting-y-mantenimiento)
5. [Referencias y Recursos](#5-referencias-y-recursos)

---

# 1. Arquitectura Interna de VoxeLibre

**Análisis Original**: 2025-09-25

## 1.1. Introducción

VoxeLibre (anteriormente conocido como Mineclone 2) es un juego de tipo *sandbox* de supervivencia construido sobre el motor Luanti (fork de Minetest). Su diseño es altamente modular y extensible, con toda la lógica del juego implementada a través de un sistema de **mods en Lua**.

Este análisis se basa en la revisión del código fuente que sirve como fundamento para el servidor "Wetlands".

## 1.2. Estructura General del Directorio

La estructura del directorio del juego sigue un patrón claro y organizado, separando la configuración, la lógica del juego (mods), los assets (texturas, sonidos) y la documentación.

```
server/games/mineclone2/
├── game.conf           # Identidad del juego (nombre, descripción)
├── minetest.conf       # Sobrescritura de config por defecto
├── mods/               # ⭐ CORAZÓN DEL JUEGO - Scripts Lua
│   ├── CORE/           # Funcionalidad central y APIs base
│   ├── ITEMS/          # Bloques, herramientas, items
│   ├── ENTITIES/       # Criaturas y objetos dinámicos (mobs)
│   ├── MAPGEN/         # Generación de mundo (biomas, cuevas, estructuras)
│   ├── HUD/            # Interfaz de usuario (Heads-Up Display)
│   └── PLAYER/         # Mecánicas del jugador (movimiento, inventario)
├── textures/           # Archivos PNG para nodos, items, entidades
└── API.md, TEXTURES.md # Documentación de alto nivel
```

## 1.3. El Sistema de Mods en Lua

Toda la funcionalidad del juego se implementa a través de mods. Cada subdirectorio en la carpeta `mods/` representa un mod individual o un grupo de mods relacionados.

### 1.3.1. Punto de Entrada: `init.lua`

Cada mod tiene un archivo `init.lua` que actúa como su punto de entrada. El motor del juego ejecuta este archivo al cargar el mod. Este script es responsable de:

- Cargar otros archivos Lua del mod usando `dofile()`
- Registrar nodos, items, crafteos y entidades
- Establecer callbacks para eventos del juego

### 1.3.2. Registro de Contenido

El juego se construye registrando objetos en el motor a través de una API global de Lua, accesible principalmente a través del objeto `minetest`.

#### **Registro de Herramientas**

Ejemplo de `mods/ITEMS/mcl_tools/init.lua`:

```lua
minetest.register_tool("mcl_tools:pick_wood", {
    description = "Wooden Pickaxe",
    inventory_image = "default_tool_woodpick.png",
    tool_capabilities = {
        full_punch_interval = 0.83333333,
        max_drop_level=1,
        damage_groups = {fleshy=2},
        punch_attack_uses = 30,
    },
    _mcl_diggroups = {
        pickaxey = { speed = 2, level = 1, uses = 60 }
    },
    -- ... más propiedades
})
```

**Componentes clave**:
- **`"mcl_tools:pick_wood"`**: Identificador único (`nombre_del_mod:nombre_del_item`)
- **`description`**: Nombre visible para el jugador
- **`inventory_image`**: Textura en el inventario
- **`tool_capabilities`**: Daño, durabilidad y velocidad
- **`_mcl_diggroups`**: API personalizada de VoxeLibre para eficiencia contra bloques

De forma similar, los bloques se registran con `minetest.register_node()`.

#### **Registro de Entidades (Mobs)**

El mod `mcl_mobs` (`mods/ENTITIES/mcl_mobs/`) proporciona una API robusta para crear criaturas:

```lua
function mcl_mobs.register_mob(name, def)
    -- ... lógica interna de la API ...
    minetest.register_entity(name, setmetatable(final_def, mcl_mobs.mob_class_meta))
end
```

Esta función es un wrapper sobre `minetest.register_entity()` que añade lógica predefinida para:

- **`spawn_class`**: Categoría del mob (pasivo, hostil, etc.)
- **Propiedades físicas**: `collisionbox`, `stepheight`
- **Comportamiento**: `walk_velocity`, `run_velocity`, `damage`, `view_range`
- **Animaciones, sonidos y drops**
- **Lógica de IA**: `on_activate`, `on_step` para comportamiento en cada tick

## 1.4. Generación del Mundo (Mapgen)

La generación del mundo es un proceso complejo gestionado por los mods en `MAPGEN/`.

### 1.4.1. Biomas

Ejemplo de registro de bioma en `mods/MAPGEN/mcl_biomes/init.lua`:

```lua
minetest.register_biome({
    name = "Plains",
    node_top = "mcl_core:dirt_with_grass",
    depth_top = 1,
    node_filler = "mcl_core:dirt",
    depth_filler = 2,
    y_min = 3,
    y_max = 9999,
    humidity_point = 39,
    heat_point = 58,
    _mcl_biome_type = "medium",
    -- ... paletas de colores y otras propiedades personalizadas
})
```

**Componentes clave**:
- **`name`**: Identificador del bioma
- **`node_top`, `node_filler`**: Bloques de superficie y relleno
- **`heat_point`, `humidity_point`**: Ubicación en el mapa basado en ruido Perlin
- **`y_min`, `y_max`**: Restricciones de altura
- **`_mcl_*`**: Propiedades personalizadas para paletas de colores

### 1.4.2. Estructuras y Minerales

El generador de mapas utiliza:
- **`minetest.register_ore()`**: Para vetas de minerales
- **`minetest.register_decoration()`**: Para árboles, flores y estructuras

## 1.5. Dimensiones y Coordinadas

El archivo `mods/CORE/mcl_init/init.lua` establece variables globales para la estructura del mundo. VoxeLibre simula múltiples dimensiones apilándolas verticalmente en el eje Y:

- **Overworld**: Cerca de Y=0
- **The End**: Cerca de Y=-27000
- **The Nether**: Cerca de Y=-29000

El código define constantes como `mcl_vars.mg_overworld_min`, `mcl_vars.mg_nether_min`, etc., utilizadas por los mods de `mapgen` para colocar biomas y estructuras en la dimensión correcta.

## 1.6. Principios de Arquitectura

VoxeLibre se basa en estos principios fundamentales:

1. **Modularidad Extrema**: Cada aspecto del juego es un mod autocontenido
2. **APIs en Lua**: El juego se construye registrando objetos y callbacks en el motor
3. **Abstracción sobre la API nativa**: Mods como `mcl_mobs` crean APIs de más alto nivel
4. **Configuración por Archivos**: Control mediante tablas de Lua y parámetros numéricos

Este diseño permite que el juego sea fácilmente modificable y extensible, fundamental para la personalización del servidor Wetlands.

---

# 2. Sistema de Mods Técnico

**Documentación Original**: 2025-09-21
**Problema Resuelto**: Comandos `/reglas`, `/filosofia`, `/santuario` no funcionaban
**Causa Raíz**: Incompatibilidades entre sistema de mods de Luanti y VoxeLibre

## 2.1. Arquitectura del Sistema de Mods

### 2.1.1. Directorios de Mods en el Contenedor

VoxeLibre utiliza un sistema de mods específico que difiere del Luanti vanilla:

```
/config/.minetest/
├── mods/                    # 🎯 DIRECTORIO PRINCIPAL (Alta prioridad)
│   ├── server_rules/        # ✅ Mods personalizados van aquí
│   ├── education_blocks/    # ✅ Funcionan correctamente
│   ├── vegan_food/          # ✅ Cargan automáticamente
│   ├── creative_force/      # ✅ Modo creativo forzado
│   ├── pvp_arena/           # ✅ Sistema PvP
│   └── ...
├── games/
│   └── mineclone2/
│       └── mods/            # 🏠 Mods del juego base (Baja prioridad)
│           ├── mcl_core/    # VoxeLibre core mods
│           ├── mcl_farming/ # VoxeLibre farming
│           └── ...
└── worlds/
    └── world/
        └── world.mt         # 📋 Configuración de mods por mundo
```

### 2.1.2. Orden de Prioridad de Carga

1. **`/config/.minetest/mods/`** - **PRIORIDAD MÁXIMA** 🎯
   - Mods personalizados del servidor
   - Cargan automáticamente si están habilitados en config
   - Pueden sobreescribir mods del juego base

2. **`/config/.minetest/games/mineclone2/mods/`** - **PRIORIDAD BAJA** 🏠
   - Mods del juego base VoxeLibre
   - Solo se cargan si no hay conflictos de nombres

3. **`/config/.minetest/worlds/world/world.mt`** - **CONFIGURACIÓN POR MUNDO** 📋
   - Puede habilitar/deshabilitar mods específicos
   - Útil para mods que van en el directorio del juego

## 2.2. Problemas Comunes y Soluciones

### 2.2.1. Conflictos de Nombres de Mods

**Problema**: `ModError: Unresolved name conflicts for mods "nombre_mod"`

**Causa**: Mods con el mismo nombre en múltiples ubicaciones:
- `/config/.minetest/mods/education_blocks/`
- `/config/.minetest/mods/education_blocks.disabled/`
- `/config/.minetest/games/mineclone2/mods/education_blocks/`

**✅ Solución**:
```bash
# Eliminar duplicados
docker compose exec luanti-server rm -rf /config/.minetest/mods/nombre_mod.disabled
docker compose exec luanti-server rm -rf /config/.minetest/games/mineclone2/mods/nombre_mod_duplicado
```

### 2.2.2. Dependencias Incorrectas

**Problema**: `ModError: mod "nombre_mod" is missing: default farming`

**Causa**: Mods que dependen de APIs de Minetest vanilla que no existen en VoxeLibre

**VoxeLibre vs Minetest Vanilla - Equivalencias**:

| Minetest Vanilla | VoxeLibre | Descripción |
|------------------|-----------|-------------|
| `default:book` | `mcl_books:book` | Libros |
| `default:stick` | `mcl_core:stick` | Palos |
| `default:apple` | `mcl_core:apple` | Manzanas |
| `farming:wheat` | `mcl_farming:wheat_item` | Trigo |
| `default:stone` | `mcl_core:stone` | Piedra |
| `mcl_sounds` | ❌ **NO EXISTE** | Sonidos |

**✅ Solución en mod.conf**:
```ini
# ❌ Incorrecto
depends = mcl_sounds, default, farming

# ✅ Correcto
depends =
optional_depends = mcl_core, mcl_farming
```

### 2.2.3. APIs y Recetas Incompatibles

**Problema**: Recetas que usan items inexistentes en VoxeLibre

**✅ Solución**: Actualizar recetas en `init.lua`:
```lua
-- ❌ Minetest vanilla
core.register_craft({
    recipe = {
        {"default:stone", "default:book", "farming:wheat"}
    }
})

-- ✅ VoxeLibre compatible
core.register_craft({
    recipe = {
        {"mcl_core:stone", "mcl_books:book", "mcl_farming:wheat_item"}
    }
})
```

## 2.3. Proceso de Depuración de Mods

### Paso 1: Verificar Carga de Mods
```bash
# En el VPS
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && docker compose logs luanti-server | grep -i 'error\|warn\|conflict'"
```

### Paso 2: Verificar Estructura de Directorios
```bash
# Verificar que el mod esté en la ubicación correcta
docker compose exec luanti-server ls -la /config/.minetest/mods/nombre_mod/

# Verificar contenido del mod
docker compose exec luanti-server cat /config/.minetest/mods/nombre_mod/mod.conf
```

### Paso 3: Limpiar Conflictos
```bash
# Eliminar versiones .disabled
docker compose exec luanti-server rm -rf /config/.minetest/mods/*.disabled

# Verificar no hay duplicados en directorio del juego
docker compose exec luanti-server ls /config/.minetest/games/mineclone2/mods/
```

### Paso 4: Reiniciar y Verificar
```bash
docker compose restart luanti-server
sleep 15
docker compose logs --tail=20 luanti-server
```

## 2.4. Configuración Recomendada

### 2.4.1. Docker Compose Volume Mapping

```yaml
volumes:
  - ./server/mods:/config/.minetest/mods          # ✅ Correcto
  - ./server/games:/config/.minetest/games        # ✅ Para VoxeLibre
  - ./server/config/luanti.conf:/config/.minetest/minetest.conf  # ✅ Config global
```

### 2.4.2. Estructura de Repositorio

```
server/
├── mods/                    # 🎯 Mods personalizados
│   ├── server_rules/        # Sistema de reglas
│   ├── education_blocks/    # Bloques educativos
│   ├── vegan_food/          # Comida vegana
│   ├── creative_force/      # Modo creativo forzado
│   └── pvp_arena/           # Sistema PvP
├── config/
│   └── luanti.conf          # 📋 Configuración global
└── games/
    └── mineclone2/          # 🏠 VoxeLibre (descargado)
```

## 2.5. Verificación de Funcionamiento

### 2.5.1. Comandos de Prueba

Conectarse al servidor y probar:
```
/reglas      # ✅ Debe mostrar reglas completas
/filosofia   # ✅ Debe mostrar filosofía del servidor
/santuario   # ✅ Debe mostrar info de cuidado animal
/r           # ✅ Debe mostrar reglas rápidas
```

### 2.5.2. Sistema de Reglas Automáticas

- ✅ Reglas aparecen automáticamente al conectarse (todos los usuarios)
- ✅ Mensajes especiales para jugadores nuevos
- ✅ Comandos útiles mostrados en bienvenida

## 2.6. Reglas de Oro para Evitar Problemas

1. **NUNCA** duplicar mods entre `/config/.minetest/mods/` y `/config/.minetest/games/mineclone2/mods/`
2. **SIEMPRE** usar items de VoxeLibre (`mcl_*`) en lugar de Minetest vanilla (`default:*`)
3. **VERIFICAR** dependencias en `mod.conf` antes de deployment
4. **ELIMINAR** archivos `.disabled` que puedan causar conflictos
5. **PROBAR** comandos después de cada cambio de mods
6. **HABILITAR** mods personalizados en `world.mt` cuando sea necesario

---

# 3. Optimización y Rendimiento

**Implementación**: 2025-09-25
**Estado**: ✅ Implementado y funcionando
**Contexto**: Post-Incidente HAKER
**Commit**: `b4ad2d7`

## 3.1. Cambios Implementados

### 3.1.1. Cambio Crítico Principal

```conf
max_objects_per_block = 256  # Era 64
```

**Efecto**: Resuelve desconexiones masivas automáticas causadas por exceso de objetos en bloques.

### 3.1.2. Optimizaciones de Rendimiento

```conf
active_block_range = 2                    # Era 3 - Reduce CPU 33%
max_block_send_distance = 8               # Era 12 - Reduce bandwidth 33%
num_emerge_threads = 2                    # Nuevo - Multi-thread generación
server_unload_unused_data_timeout = 600   # Nuevo - Cache 10 minutos
```

**Beneficios**:
- **33% menos carga CPU**: Menor rango de bloques activos
- **33% menos bandwidth**: Distancia de envío reducida
- **Generación multi-thread**: Mejor performance en carga de chunks
- **Cache optimizado**: Reducción de I/O en disco

### 3.1.3. Protecciones para Niños

```conf
server_map_save_interval = 60                   # Auto-guardado cada minuto
chat_message_count_per_player_per_5min = 100    # Anti-spam suave
kick_msg_crash_msgqueue = "Error de conexión - reconéctate en un momento"
kick_msg_shutdown = "Servidor en mantenimiento - vuelve pronto 🌱"
```

**Beneficios**:
- **Auto-guardado frecuente**: Mínima pérdida de progreso
- **Anti-spam amigable**: Permite comunicación natural
- **Mensajes child-friendly**: No asusta a los niños

## 3.2. Resultados Obtenidos

- ✅ **Incidente HAKER resuelto**: No más desconexiones masivas automáticas
- ✅ **Rendimiento mejorado**: Menos carga CPU y bandwidth optimizado
- ✅ **Protección infantil**: Auto-guardado y mensajes amigables
- ✅ **Servidor funcionando**: Puerto 30000 activo y saludable

## 3.3. Verificación Exitosa

```bash
# Estado del servidor tras reinicio
✅ Container: Up (healthy)
✅ Puerto: 30000/UDP escuchando
✅ Logs: Sin errores críticos
✅ VoxeLibre: Cargado correctamente
```

### Comando de Verificación

```bash
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && docker compose ps && ss -tulpn | grep :30000"
```

## 3.4. Monitoreo Continuo

### 3.4.1. Verificar Performance

```bash
# Ver uso de recursos
docker stats luanti-voxelibre-server

# Ver logs de performance
docker compose logs --tail=50 luanti-server | grep -i "lag\|slow\|timeout"
```

### 3.4.2. Métricas Importantes

| Métrica | Valor Esperado | Acción si Excede |
|---------|----------------|------------------|
| **CPU Usage** | < 50% | Reducir `active_block_range` |
| **Memory Usage** | < 2GB | Reducir `max_objects_per_block` |
| **Bandwidth** | < 10 Mbps | Reducir `max_block_send_distance` |
| **Lag** | < 100ms | Revisar `num_emerge_threads` |

---

# 4. Troubleshooting y Mantenimiento

## 4.1. Problemas Comunes

### 4.1.1. Mods No Cargan

**Síntomas**: Comandos no funcionan, mods no aparecen en logs

**Diagnóstico**:
```bash
# Verificar mods cargados
docker compose exec luanti-server ls -la /config/.minetest/mods/

# Verificar world.mt
docker compose exec luanti-server cat /config/.minetest/worlds/world/world.mt | grep "load_mod"
```

**Solución**:
```bash
# Habilitar mod manualmente en world.mt
echo "load_mod_nombre_mod = true" >> server/worlds/world/world.mt
docker compose restart luanti-server
```

### 4.1.2. Servidor Lento o Lagueado

**Síntomas**: Players reportan lag, movimiento entrecortado

**Diagnóstico**:
```bash
# Ver uso de recursos
docker stats luanti-voxelibre-server --no-stream

# Ver logs de performance
docker compose logs --tail=100 luanti-server | grep -i "lag\|slow"
```

**Solución**:
```conf
# En server/config/luanti.conf
active_block_range = 1                    # Reducir a 1 en casos extremos
max_block_send_distance = 6               # Reducir a 6
dedicated_server_step = 0.05              # Aumentar de 0.09 a 0.05
```

### 4.1.3. Items Desaparecen o No se Craftean

**Síntomas**: Recetas no funcionan, items missing

**Diagnóstico**:
```bash
# Verificar errores de items
docker compose logs luanti-server | grep -i "unknown item\|not registered"
```

**Solución**: Verificar que el mod que provee el item esté cargado y use nombres VoxeLibre (`mcl_*`).

## 4.2. Mantenimiento Preventivo

### 4.2.1. Rutina Semanal

```bash
# 1. Backup del mundo
ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && ./scripts/backup.sh"

# 2. Verificar logs de errores
docker compose logs --since 7d luanti-server | grep -i "error\|critical"

# 3. Verificar uso de disco
docker compose exec luanti-server du -sh /config/.minetest/worlds/world

# 4. Limpiar logs antiguos
docker compose logs --tail=100 > /dev/null
```

### 4.2.2. Rutina Mensual

```bash
# 1. Actualizar VoxeLibre (si hay nueva versión)
# Ver: docs/VOXELIBRE_INSTALLATION.md

# 2. Revisar configuración de mods
cat server/worlds/world/world.mt | grep "load_mod"

# 3. Optimizar base de datos SQLite
docker compose exec luanti-server sqlite3 /config/.minetest/worlds/world/auth.sqlite "VACUUM;"

# 4. Backup completo
tar -czf backup-mensual-$(date +%Y%m%d).tar.gz server/worlds/
```

## 4.3. Recuperación de Desastres

### 4.3.1. Restaurar Backup

```bash
# 1. Detener servidor
docker compose down

# 2. Restaurar backup
tar -xzf server/backups/backup-YYYYMMDD-HHMMSS.tar.gz -C server/worlds/

# 3. Reiniciar servidor
docker compose up -d

# 4. Verificar
docker compose logs --tail=50 luanti-server
```

### 4.3.2. Reset Completo de Mods

```bash
# 1. Backup actual
cp -r server/mods server/mods.backup

# 2. Limpiar conflictos
docker compose exec luanti-server rm -rf /config/.minetest/mods/*.disabled

# 3. Reiniciar desde cero
docker compose down
docker system prune -f
docker compose up -d
```

---

# 5. Referencias y Recursos

## 5.1. Documentación Oficial

- **VoxeLibre Official**: https://git.minetest.land/VoxeLibre/VoxeLibre
- **Luanti Official**: https://www.luanti.org/
- **Luanti Modding Book**: https://rubenwardy.com/minetest_modding_book/
- **ContentDB**: https://content.luanti.org/

## 5.2. Documentación Interna

- **01-CONFIGURATION_HIERARCHY.md** - Jerarquía de configuraciones
- **02-NUCLEAR_CONFIG.md** - Configuración anti-mobs crítica
- **03-MIXED_GAMEMODE.md** - Sistema de modos de juego mixtos
- **05-BLOCK_PROTECTION.md** - Sistema de protección
- **06-RULES_SYSTEM.md** - Sistema de reglas automáticas
- **07-CUSTOM_SKINS.md** - Skins personalizados

## 5.3. Herramientas Útiles

- **SQLite Browser**: Para explorar `auth.sqlite` manualmente
- **Luanti Client**: Para testing local en modo desarrollo
- **Docker Desktop**: Para monitorear containers visualmente

## 5.4. Comunidad y Soporte

- **Luanti Forum**: https://forum.luanti.org/
- **VoxeLibre Issues**: https://git.minetest.land/VoxeLibre/VoxeLibre/issues
- **Discord Luanti**: https://discord.gg/luanti (comunidad oficial)

---

## 📊 Histórico de Cambios

| Fecha | Cambio | Estado |
|-------|--------|--------|
| 2025-09-25 | Análisis arquitectura interna VoxeLibre | ✅ Documentado |
| 2025-09-21 | Sistema de mods técnico y troubleshooting | ✅ Implementado |
| 2025-09-25 | Optimización post-incidente HAKER | ✅ Funcionando |
| 2026-01-16 | Consolidación en archivo único | ✅ Completado |

---

**Última actualización**: 2026-01-16
**Mantenedor**: Gabriel Pantoja (gabo)
**Estado**: ✅ Sistema VoxeLibre completamente funcional y optimizado
**Próxima revisión**: Al actualizar VoxeLibre o agregar mods significativos
