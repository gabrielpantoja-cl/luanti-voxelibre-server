# Sistema de Mods VoxeLibre - Guía Técnica

## ⚠️ INFORMACIÓN CRÍTICA

**Fecha de documentación**: 2025-09-21
**Problema resuelto**: Comandos /reglas, /filosofia, /santuario no funcionaban
**Causa raíz**: Incompatibilidades entre sistema de mods de Luanti y VoxeLibre

## 🏗️ Arquitectura del Sistema de Mods

### Directorios de Mods en el Contenedor

VoxeLibre (MineClone2) utiliza un sistema de mods específico que difiere del Luanti vanilla:

```
/config/.minetest/
├── mods/                    # 🎯 DIRECTORIO PRINCIPAL (Alta prioridad)
│   ├── server_rules/        # ✅ Mods personalizados van aquí
│   ├── education_blocks/    # ✅ Funcionan correctamente
│   ├── vegan_food/          # ✅ Cargan automáticamente
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

### Orden de Prioridad de Carga

1. **`/config/.minetest/mods/`** - **PRIORIDAD MÁXIMA**
   - Mods personalizados del servidor
   - Cargan automáticamente si están habilitados en config
   - Pueden sobreescribir mods del juego base

2. **`/config/.minetest/games/mineclone2/mods/`** - **PRIORIDAD BAJA**
   - Mods del juego base VoxeLibre
   - Solo se cargan si no hay conflictos de nombres

3. **`/config/.minetest/worlds/world/world.mt`** - **CONFIGURACIÓN POR MUNDO**
   - Puede habilitar/deshabilitar mods específicos
   - Útil para mods que van en el directorio del juego

## 🚨 Problemas Comunes y Soluciones

### 1. Conflictos de Nombres de Mods

**Problema**: `ModError: Unresolved name conflicts for mods "nombre_mod"`

**Causa**: Mods con el mismo nombre en múltiples ubicaciones:
- `/config/.minetest/mods/education_blocks/`
- `/config/.minetest/mods/education_blocks.disabled/`
- `/config/.minetest/games/mineclone2/mods/education_blocks/`

**✅ Solución**:
```bash
# Eliminar duplicados
rm -rf /config/.minetest/mods/nombre_mod.disabled
rm -rf /config/.minetest/games/mineclone2/mods/nombre_mod_duplicado
```

### 2. Dependencias Incorrectas

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

### 3. APIs y Recetas Incompatibles

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

## 🔧 Proceso de Depuración de Mods

### Paso 1: Verificar Carga de Mods
```bash
# En el VPS
docker compose logs luanti-server | grep -i "error\|warn\|conflict"
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

## 📋 Configuración Recomendada

### Docker Compose Volume Mapping
```yaml
volumes:
  - ./server/mods:/config/.minetest/mods          # ✅ Correcto
  - ./server/games:/config/.minetest/games        # ✅ Para VoxeLibre
  - ./server/config/luanti.conf:/config/.minetest/minetest.conf  # ✅ Config global
```

### Estructura de Repositorio
```
server/
├── mods/                    # 🎯 Mods personalizados
│   ├── server_rules/        # Sistema de reglas
│   ├── education_blocks/    # Bloques educativos
│   ├── vegan_food/          # Comida vegana
│   └── ...
├── config/
│   └── luanti.conf          # 📋 Configuración global
└── games/
    └── mineclone2/          # 🏠 VoxeLibre (descargado)
```

## ✅ Verificación de Funcionamiento

### Comandos de Prueba
```bash
# Conectarse al servidor y probar:
/reglas      # ✅ Debe mostrar reglas completas
/filosofia   # ✅ Debe mostrar filosofía del servidor
/santuario   # ✅ Debe mostrar info de cuidado animal
/r           # ✅ Debe mostrar reglas rápidas
```

### Sistema de Reglas Automáticas
- ✅ Reglas aparecen automáticamente al conectarse (todos los usuarios)
- ✅ Mensajes especiales para jugadores nuevos
- ✅ Comandos útiles mostrados en bienvenida

## 🚨 Reglas de Oro para Evitar Problemas

1. **NUNCA** duplicar mods entre `/config/.minetest/mods/` y `/config/.minetest/games/mineclone2/mods/`
2. **SIEMPRE** usar items de VoxeLibre (`mcl_*`) en lugar de Minetest vanilla (`default:*`)
3. **VERIFICAR** dependencias en `mod.conf` antes de deployment
4. **ELIMINAR** archivos `.disabled` que puedan causar conflictos
5. **PROBAR** comandos después de cada cambio de mods

## 📚 Referencias

- **VoxeLibre Official**: https://git.minetest.land/VoxeLibre/VoxeLibre
- **Luanti Modding Book**: https://rubenwardy.com/minetest_modding_book/
- **ContentDB**: https://content.luanti.org/

---
**Última actualización**: 2025-09-21
**Estado**: Sistema de mods funcionando correctamente
**Próxima revisión**: Al agregar nuevos mods