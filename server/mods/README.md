# 🌱 Documentación de Mods - Wetlands Server

Esta carpeta contiene toda la documentación técnica para desarrollo, deployment y mantenimiento de mods del servidor Wetlands.

---

## 📚 Índice de Documentación

### 🎯 Guías Principales

#### [MOD_DEVELOPMENT.md](./MOD_DEVELOPMENT.md)
**Guía Completa de Desarrollo de Mods**
Documento maestro que cubre TODO el proceso de desarrollo de mods para Wetlands:
- Filosofía de desarrollo compasivo y educativo
- Arquitectura Docker y mapeo de volúmenes (**Git → Docker automático**)
- Estructura profesional de mods
- APIs de VoxeLibre y tabla de conversiones
- Patrones de código profesional (nodos, entidades, comandos)
- Proceso completo de deployment (local → git → VPS)
- Troubleshooting avanzado
- Testing y validación
- Best practices y convenciones

**👉 EMPIEZA AQUÍ si vas a desarrollar un nuevo mod.**

---

### 🔧 Documentación de Mods Específicos

#### [education_blocks.md](./education_blocks.md)
**Mod: Education Blocks**
Bloques interactivos educativos sobre compasión animal y alimentación consciente.
- Comandos: `/filosofia`, `/santuario` (deprecado - ahora en server_rules)
- Bloques educativos con mensajes interactivos
- Sistema de partículas y efectos visuales

#### [voxelibre_protection.md](./voxelibre_protection.md)
**Mod: VoxeLibre Protection System**
Sistema completo de protección de áreas compatible con VoxeLibre.
- Comandos: `/area_*` para gestión de áreas
- Protección de construcciones por usuario
- Sistema de permisos y privilegios
- Compatible con WorldEdit

**Nota:** Revisar también `docs/admin/areas_protegidas.md` para guía de administración.

---

## 🗂️ Estructura de Mods en el Servidor

### Ubicación Física
```
server/mods/                           # ✅ Repositorio Git
├── server_rules/                      # Sistema de reglas y bienvenida
├── vegan_food/                        # Comida vegana
├── education_blocks/                  # Bloques educativos
├── voxelibre_protection/              # Protección de áreas
├── animal_sanctuary/                  # Santuarios de animales
├── back_to_spawn/                     # Teleportación a spawn (tercero)
├── areas/                             # Sistema de áreas (tercero)
├── protector/                         # Protector de bloques (tercero)
├── sethome/                           # Sistema de homes (tercero)
├── halloween_ghost/                   # Evento temporal Halloween
├── worldedit/                         # Editor de mundos (tercero)
└── ...                                # Otros mods
```

### Mapeo Docker (CRÍTICO)
```yaml
# docker-compose.yml
volumes:
  - ./server/mods:/config/.minetest/mods           # ✅ PRIORIDAD ALTA
  - ./server/games:/config/.minetest/games         # Base VoxeLibre
```

**Principio fundamental:**
> Los mods en `/config/.minetest/mods/` tienen **PRIORIDAD ALTA** sobre los mods base de VoxeLibre en `/config/.minetest/games/mineclone2/mods/`

---

## 🚀 Flujo de Trabajo: Git → Docker

### Workflow Estándar

1. **Desarrollo Local**
   ```bash
   cd server/mods/mi_mod/
   nano init.lua
   ```

2. **Commit y Push**
   ```bash
   git add server/mods/mi_mod/
   git commit -m "✨ Update mi_mod: nueva funcionalidad"
   git push origin main
   ```

3. **Deployment VPS**
   ```bash
   ssh gabriel@<IP_VPS_ANTERIOR> "cd /home/gabriel/luanti-voxelibre-server && git pull origin main && docker-compose restart luanti-server"
   ```

4. **Verificación**
   ```bash
   ssh gabriel@<IP_VPS_ANTERIOR> "docker-compose logs --tail=50 luanti-server | grep mi_mod"
   ```

### ✅ Ventajas de este sistema
- **NO necesitas copiar archivos manualmente** al contenedor
- Cambios en Git se reflejan automáticamente después de reiniciar
- Deployment simplificado y versionado
- Rollback fácil con `git revert`

---

## 📋 Lista de Mods Activos

### Mods Desarrollados por Wetlands

| Mod | Versión | Comandos | Descripción | Documentación |
|-----|---------|----------|-------------|---------------|
| `server_rules` | 2.0 | `/reglas`, `/r`, `/filosofia`, `/santuario`, `/info`, `/discord` | Sistema de reglas, bienvenida y filosofía | [README.md](./server_rules/README.md) |
| `education_blocks` | 1.0 | `/filosofia` | Bloques educativos interactivos | [README.md](./education_blocks/README.md) |
| `voxelibre_protection` | 1.1.0 | `/area_*` | Sistema de protección de áreas | [README.md](./voxelibre_protection/README.md) |
| `auto_road_builder` | 1.2.0 | `/build_road`, `/build_road_from`, `/repair_road`, `/continue_road` | Construcción automática de carreteras | [README.md](./auto_road_builder/README.md) |
| `wetlands-music` | 2.1.0 | - | Discos de música personalizados | [README.md](./wetlands-music/README.md) |
| `broom_racing` | 1.0.0 | `/mejores_tiempos`, `/reset_carrera`, `/dar_escoba`, `/evento_carreras` | Sistema de carreras de escobas | [README.md](./broom_racing/README.md) |
| `halloween_ghost` | 1.0 | - | Evento temporal Halloween | [README.md](./halloween_ghost/README.md) |
| `halloween_zombies` | 1.0 | - | Zombies pacíficos para Halloween | [README.md](./halloween_zombies/README.md) |
| `wetlands_christmas` | 1.0 | - | Decoraciones navideñas | (Pendiente) |
| `voxelibre_tv` | 1.0 | - | Sistema de televisión educativa | (Pendiente) |
| `wetland_city` | 1.0 | - | Generación de ciudades | (Pendiente) |
| `creative_force` | 1.0 | `/starter_kit`, `/give_starter_kit` | Forzar modo creativo y eliminar violencia | [README.md](./creative_force/README.md) |
| `mcl_potions_hotfix` | 1.0 | - | Fix temporal para bug de invisibilidad | [README.md](./mcl_potions_hotfix/README.md) |
| `vegan_replacements` | 1.0 | `/vegancheck`, `/listveganbans` | Eliminación de items no veganos | [README.md](./vegan_replacements/README.md) |

### Mods de Terceros

| Mod | Fuente | Comandos | Descripción |
|-----|--------|----------|-------------|
| `back_to_spawn` | [ContentDB](https://content.luanti.org/packages/Alex5002/mcl_back_to_spawn/) | `/back_to_spawn` | Teleportación a spawn personal |
| `areas` | ContentDB | `/area_*` | Sistema de protección de áreas |
| `protector` | ContentDB | - | Protector de bloques |
| `sethome` | ContentDB | `/sethome`, `/home` | Sistema de homes |
| `worldedit` | ContentDB | `//pos1`, `//pos2`, etc. | Editor de mundos |

**Nota:** Ver `CLAUDE.md` sección "Third-Party Content Attribution" para más detalles de mods de terceros.

---

## 🛠️ Recursos de Desarrollo

### APIs de VoxeLibre

**APIs Estables (usar siempre):**
- `mcl_core` - Bloques fundamentales
- `mcl_farming` - Agricultura
- `mcl_mobs` - Entidades/mobs
- `mcl_util` - Utilidades
- `mcl_inventory` - Inventarios
- `mcl_player` - Mecánicas del jugador

**APIs Problemáticas (evitar):**
- `default` - No existe en VoxeLibre (usar `mcl_core`)
- `farming` - Usar `mcl_farming`
- `mcl_sounds` - Eliminada en versiones recientes
- `mobs` - Usar `mcl_mobs`

### Tabla de Conversión Rápida

| Luanti Vanilla | VoxeLibre | Uso |
|----------------|-----------|-----|
| `default:apple` | `mcl_core:apple` | Comida |
| `default:stick` | `mcl_core:stick` | Crafteo |
| `default:stone` | `mcl_core:stone` | Bloques |
| `farming:wheat` | `mcl_farming:wheat_item` | Agricultura |

---

## 🧪 Testing y Debugging

### Logs del Servidor
```bash
# Logs en tiempo real
docker-compose logs -f luanti-server

# Filtrar por mod específico
docker-compose logs luanti-server | grep "nombre_mod"

# Ver solo errores
docker-compose logs luanti-server | grep -i "error\|warning"
```

### Debug In-Game
```lua
-- En init.lua del mod
local debug_mode = minetest.settings:get_bool("mi_mod_debug", false)

if debug_mode then
    minetest.log("action", "[mi_mod] DEBUG: variable = " .. tostring(variable))
end
```

### Comandos Admin Útiles
```
/reload                    # Recargar mods sin reiniciar (requiere privilegio 'server')
/mods                      # Ver mods cargados
/privs <usuario>          # Ver privilegios de usuario
/grant <usuario> <priv>   # Otorgar privilegio
```

---

## 🎯 Filosofía de Desarrollo Wetlands

Todo mod debe adherirse a estos principios:

### 🌿 Compasivo y Pacífico
Sin mecánicas de violencia, caza o explotación animal. Enfoque en cuidado, protección y cooperación.

### 📚 Educativo
Cada mod debe enseñar sobre compasión, sostenibilidad o habilidades técnicas de forma natural.

### 👶 Apropiado para Niños
Contenido seguro y constructivo para edades 7+ años.

### ⚡ Rendimiento y Calidad
Código limpio, eficiente y bien documentado para estabilidad del servidor.

### 🤝 Construcción de Comunidad
Fomentar colaboración y experiencias compartidas positivas.

---

## 📖 Convenciones

### Idioma
- **Código y comentarios:** Español
- **Variables:** `snake_case` (ej: `cuidar_animal`)
- **Items:** `modname:item_name` (ej: `vegan_food:tofu`)

### Estructura de Archivos
```
mi_mod/
├── mod.conf              # Configuración obligatoria
├── init.lua              # Punto de entrada
├── locale/               # Traducciones (opcional)
│   ├── template.txt
│   └── es.tr
├── textures/             # Imágenes PNG
├── sounds/               # Archivos OGG
└── README.md             # Documentación del mod
```

### Logging
```lua
minetest.log("action", "[mi_mod] Mensaje informativo")
minetest.log("error", "[mi_mod] Error: " .. error_msg)
minetest.log("warning", "[mi_mod] Advertencia")
```

---

## 🔗 Enlaces Útiles

### Documentación Oficial
- [Luanti Lua API Reference](https://github.com/minetest/minetest/blob/master/doc/lua_api.md)
- [VoxeLibre Wiki](https://git.minetest.land/VoxeLibre/VoxeLibre/wiki)
- [Minetest Modding Book](https://rubenwardy.com/minetest_modding_book/)

### Repositorios
- [Wetlands Luanti Server GitHub](https://github.com/gabrielpantoja-cl/luanti-voxelibre-server)
- [VoxeLibre GitHub](https://git.minetest.land/VoxeLibre/VoxeLibre)

### Herramientas
- [luacheck](https://github.com/mpeterv/luacheck) - Linter para Lua
- [Luanti ContentDB](https://content.luanti.org/) - Mods de terceros

---

## 🚨 Troubleshooting Común

### Mod no carga
1. Verificar sintaxis Lua: `luacheck server/mods/mi_mod/init.lua`
2. Revisar logs: `docker-compose logs luanti-server | grep mi_mod`
3. Verificar `mod.conf` (nombre correcto, dependencias)
4. Comprobar que está habilitado en `world.mt`

### Texturas no se ven
1. Verificar nombres de archivos (case-sensitive)
2. Formato PNG válido
3. Nombres coinciden con `inventory_image` en código

### Cambios no se aplican
1. **Reiniciar servidor:** `docker-compose restart luanti-server`
2. Verificar que hiciste `git pull` en VPS
3. Limpiar caché del cliente Luanti

### Items/Comandos no funcionan
1. Verificar compatibilidad con VoxeLibre (usar `mcl_*` en lugar de `default:`)
2. Revisar dependencias en `mod.conf`
3. Comprobar privilegios requeridos para comandos

---

## 📝 TODO: Documentación Pendiente

- [ ] `wetlands_christmas` - Documentar decoraciones navideñas
- [ ] `voxelibre_tv` - Documentar sistema de televisión
- [ ] `wetland_city` - Documentar generación de ciudades
- [ ] Actualizar guías con ejemplos de mods existentes

## 📚 Documentación Completa

Para documentación detallada sobre el ecosistema completo de mods, ver:
- **[docs/mods/README.md](../docs/mods/README.md)**: Documentación completa del ecosistema de mods
- **[docs/mods/MODDING_GUIDE.md](../docs/mods/MODDING_GUIDE.md)**: Guía de desarrollo de mods

---

**Última actualización:** 2025-10-04
**Mantenedor:** Gabriel Pantoja
**Licencia:** GPL-3.0