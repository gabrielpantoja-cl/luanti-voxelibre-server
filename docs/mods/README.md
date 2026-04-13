# 🌱 Ecosistema de Mods - Wetlands Server

**Última actualización**: Diciembre 7, 2025  
**Motor**: Luanti (Minetest) + VoxeLibre v0.90.1

Este documento explica el ecosistema completo de mods del servidor Wetlands: qué mods existen, de dónde vienen, cómo se relacionan entre sí, y por qué desarrollamos nuestros propios mods.

---

## 📋 Tabla de Contenidos

1. [¿Por qué desarrollamos mods?](#por-qué-desarrollamos-mods)
2. [Arquitectura del Sistema de Mods](#arquitectura-del-sistema-de-mods)
3. [Categorías de Mods](#categorías-de-mods)
4. [Mods del Juego Base VoxeLibre](#mods-del-juego-base-voxelibre)
5. [Mods Desarrollados por Wetlands](#mods-desarrollados-por-wetlands)
6. [Mods Instalados de Terceros](#mods-instalados-de-terceros)
7. [Relaciones entre Mods](#relaciones-entre-mods)
8. [Documentación Individual de Mods](#documentación-individual-de-mods)

---

## 🎯 ¿Por qué desarrollamos mods?

### Filosofía Wetlands

Wetlands es un servidor único con una misión específica: crear un espacio **compasivo, educativo y seguro** para niños de 7+ años. Los mods del juego base de VoxeLibre están diseñados para un juego de supervivencia genérico, pero nosotros necesitamos:

1. **🌿 Compasión Animal**: Eliminar mecánicas de violencia, caza y explotación animal
2. **📚 Educación Integrada**: Enseñar valores éticos, sostenibilidad y programación de forma natural
3. **🛡️ Seguridad para Niños**: Contenido apropiado y ambiente protegido
4. **🤝 Construcción de Comunidad**: Mecánicas que fomenten colaboración, no competencia
5. **🎨 Personalización**: Experiencia única que refleje nuestros valores

### Necesidades Específicas

Los mods desarrollados por nosotros resuelven problemas que los mods genéricos no pueden:

- **`server_rules`**: Sistema de bienvenida y reglas personalizado con nuestra filosofía
- **`education_blocks`**: Bloques interactivos que enseñan sobre compasión y sostenibilidad
- **`vegan_food`**: Sistema de alimentación consciente (aunque este es de terceros, lo adaptamos)
- **`voxelibre_protection`**: Sistema de protección compatible con VoxeLibre
- **`auto_road_builder`**: Herramienta de construcción colaborativa
- **`wetlands-music`**: Música personalizada con mensajes educativos
- **`broom_racing`**: Eventos educativos y divertidos sin violencia

---

## 🏗️ Arquitectura del Sistema de Mods

### Jerarquía de Carga (Prioridad)

```
/config/.minetest/
├── mods/                              # ✅ PRIORIDAD ALTA
│   ├── server_rules/                 # Mods desarrollados por nosotros
│   ├── education_blocks/             # Mods desarrollados por nosotros
│   ├── voxelibre_protection/         # Mods desarrollados por nosotros
│   ├── areas/                        # Mods de terceros instalados
│   ├── worldedit/                    # Mods de terceros instalados
│   └── ...
│
└── games/mineclone2/
    └── mods/                          # ⚠️ PRIORIDAD BAJA (Juego Base)
        ├── CORE/                      # Mods core de VoxeLibre
        │   ├── mcl_core/              # Bloques fundamentales
        │   ├── mcl_farming/           # Sistema de agricultura
        │   └── ...
        ├── ITEMS/                      # Items y herramientas
        │   ├── mcl_maps/              # Mapas (causó problemas con skins)
        │   └── ...
        ├── ENTITIES/                   # Mobs y entidades
        │   ├── mcl_mobs/              # Sistema de mobs
        │   └── ...
        ├── MAPGEN/                     # Generación de mundo
        ├── PLAYER/                     # Mecánicas del jugador
        └── ...
```

### Principio Fundamental

> **Los mods en `/config/.minetest/mods/` tienen PRIORIDAD ALTA sobre los mods base de VoxeLibre.**

Esto significa que:
- ✅ Nuestros mods custom pueden sobrescribir comportamiento de VoxeLibre si es necesario
- ✅ Mods de terceros instalados también tienen prioridad
- ✅ Podemos deshabilitar mods base sin modificar el juego base

---

## 📦 Categorías de Mods

### 1. Mods del Juego Base VoxeLibre

**Ubicación**: `/config/.minetest/games/mineclone2/mods/`  
**Origen**: Vienen con VoxeLibre v0.90.1  
**Propósito**: Funcionalidad core del juego

Estos mods están organizados en categorías:

| Categoría | Propósito | Ejemplos |
|-----------|-----------|----------|
| `CORE` | Funcionalidad fundamental | `mcl_core`, `mcl_farming`, `mcl_util` |
| `ITEMS` | Items, herramientas, bloques | `mcl_maps`, `mcl_chests`, `mcl_tools` |
| `ENTITIES` | Mobs, animales, entidades | `mcl_mobs`, `mcl_animals` |
| `MAPGEN` | Generación de mundo | `mcl_mapgen`, `mcl_structures` |
| `PLAYER` | Mecánicas del jugador | `mcl_player`, `mcl_skins` |
| `HUD` | Interfaz de usuario | `mcl_hud`, `mcl_inventory` |
| `ENVIRONMENT` | Clima, tiempo, efectos | `mcl_weather`, `mcl_particles` |
| `MISC` | Utilidades varias | `mcl_sounds`, `mcl_colors` |
| `HELP` | Sistema de ayuda | `mcl_help` |

**Total aproximado**: ~150-200 mods base

### 2. Mods Desarrollados por Wetlands

**Ubicación**: `/config/.minetest/mods/`  
**Origen**: Desarrollados específicamente para Wetlands  
**Propósito**: Funcionalidad única y personalizada

Ver sección detallada más abajo.

### 3. Mods Instalados de Terceros

**Ubicación**: `/config/.minetest/mods/`  
**Origen**: ContentDB, GitHub, otros repositorios  
**Propósito**: Funcionalidad adicional sin desarrollar desde cero

Ver sección detallada más abajo.

---

## 🎮 Mods del Juego Base VoxeLibre

### APIs Principales que Usamos

Nuestros mods dependen de estas APIs estables de VoxeLibre:

#### ✅ APIs Estables (Usar siempre)

- **`mcl_core`**: Bloques fundamentales (piedra, tierra, madera, items básicos)
- **`mcl_farming`**: Sistema de agricultura (semillas, cultivos, herramientas)
- **`mcl_mobs`**: API robusta para entidades y mobs
- **`mcl_util`**: Utilidades y helpers comunes
- **`mcl_inventory`**: Sistema de inventarios
- **`mcl_formspec`**: Construcción de interfaces de usuario
- **`mcl_player`**: Mecánicas del jugador (salud, hambre, respiración)
- **`mcl_weather`**: Sistema climático
- **`mcl_sounds`**: Sistema de sonidos
- **`mcl_skins`**: Sistema de skins personalizadas

#### ⚠️ APIs Problemáticas (Evitar o usar con cuidado)

- **`mcl_maps`**: Tuvo problemas con nombres de skins (ver [CUSTOM_SKINS_SETUP.md](../CUSTOM_SKINS_SETUP.md))
- **`mcl_sounds`**: Algunas versiones tienen problemas de compatibilidad

### Mods Base que Modificamos/Deshabilitamos

Algunos mods base de VoxeLibre están deshabilitados o modificados para cumplir nuestra filosofía:

- **Mobs hostiles**: Deshabilitados completamente (configuración nuclear)
- **Sistema de daño**: Modificado para modo creativo
- **PvP**: Deshabilitado completamente
- **Fuego**: Deshabilitado para seguridad

---

## 🌱 Mods Desarrollados por Wetlands

Estos mods fueron creados específicamente para el servidor Wetlands y reflejan nuestra filosofía única.

### Lista Completa

| Mod | Versión | Autor | Propósito | Documentación |
|-----|---------|-------|-----------|---------------|
| **`server_rules`** | 2.0 | gabo | Sistema de reglas, bienvenida y filosofía | [Ver README](../../server/mods/server_rules/README.md) |
| **`education_blocks`** | 1.0 | Wetlands Team | Bloques educativos interactivos | [Ver README](../../server/mods/education_blocks/README.md) |
| **`voxelibre_protection`** | 1.1.0 | Gabriel Pantoja | Sistema de protección de áreas | [Ver README](../../server/mods/voxelibre_protection/README.md) |
| **`auto_road_builder`** | 1.2.0 | Gabriel Pantoja | Construcción automática de carreteras | [Ver README](../../server/mods/auto_road_builder/README.md) |
| **`wetlands-music`** | 2.1.0 | Gabriel Pantoja | Discos de música personalizados | [Ver README](../../server/mods/wetlands-music/README.md) |
| **`broom_racing`** | 1.0.0 | Wetlands Team | Sistema de carreras de escobas | [Ver README](../../server/mods/broom_racing/README.md) |
| **`halloween_ghost`** | 1.0 | Wetlands Team | Evento temporal Halloween | [Ver README](../../server/mods/halloween_ghost/README.md) |
| **`halloween_zombies`** | 1.0 | Wetlands Team | Zombies pacíficos para Halloween | [Ver README](../../server/mods/halloween_zombies/README.md) |
| **`wetlands_christmas`** | 1.0 | Wetlands Team | Decoraciones navideñas | [Ver README](../../server/mods/wetlands_christmas/README.md) |
| **`voxelibre_tv`** | 1.0 | Wetlands Team | Sistema de televisión educativa | [Ver README](../../server/mods/voxelibre_tv/README.md) |
| **`wetland_city`** | 1.0 | Wetlands Team | Generación de ciudades | [Ver README](../../server/mods/wetland_city/README.md) |
| **`creative_force`** | 1.0 | Wetlands Team | Forzar modo creativo | [Ver README](../../server/mods/creative_force/README.md) |
| **`mcl_potions_hotfix`** | 1.0 | Wetlands Team | Fix temporal para potions | [Ver README](../../server/mods/mcl_potions_hotfix/README.md) |
| **`vegan_replacements`** | 1.0 | Wetlands Team | Reemplazos veganos de items | [Ver README](../../server/mods/vegan_replacements/README.md) |

### Características Comunes

Todos nuestros mods comparten:

1. **🌿 Filosofía Compasiva**: Sin violencia, sin explotación animal
2. **📚 Valor Educativo**: Enseñan algo positivo
3. **👶 Seguridad**: Apropiados para niños 7+
4. **⚡ Calidad**: Código limpio y bien documentado
5. **🔗 Compatibilidad**: Funcionan con VoxeLibre v0.90.1

---

## 📥 Mods Instalados de Terceros

Estos mods fueron descargados e instalados desde ContentDB, GitHub u otras fuentes.

### Lista Completa

| Mod | Fuente | Propósito | Documentación |
|-----|--------|-----------|----------------|
| **`vegan_food`** | [ContentDB](https://content.luanti.org/packages/Daenvil/vegan_food/) | Comida vegana (tofu, seitan, etc.) | [Ver README](../../server/mods/vegan_food/README.md) |
| **`areas`** | [ContentDB](https://content.luanti.org/packages/ShadowNinja/areas/) | Sistema de protección de áreas | [Ver doc](../mods/AREAS_PROTECTION_SYSTEM.md) |
| **`protector`** | [ContentDB](https://content.luanti.org/packages/TenPlus1/protector/) | Protector de bloques | Ver README del mod |
| **`sethome`** | [ContentDB](https://content.luanti.org/packages/rubenwardy/sethome/) | Sistema de homes | Ver README del mod |
| **`back_to_spawn`** | [ContentDB](https://content.luanti.org/packages/Alex5002/mcl_back_to_spawn/) | Teleportación a spawn | [Ver README](../../server/mods/back_to_spawn/README.md) |
| **`worldedit`** | [ContentDB](https://content.luanti.org/packages/sfan5/worldedit/) | Editor de mundos | [Ver doc](../mods/WORLDEDIT_GUIDE.md) |
| **`worldedit_brush`** | ContentDB | Pincel de WorldEdit | Ver README del mod |
| **`worldedit_commands`** | ContentDB | Comandos de WorldEdit | Ver README del mod |
| **`worldedit_gui`** | ContentDB | GUI de WorldEdit | Ver README del mod |
| **`worldedit_shortcommands`** | ContentDB | Comandos cortos de WorldEdit | Ver README del mod |
| **`chess`** | [ContentDB](https://content.luanti.org/packages/Chess/) | Juego de ajedrez | [Ver doc](../mods/CHESS_MOD.md) |
| **`celevator`** | [ContentDB](https://content.luanti.org/packages/celevator/) | Ascensores avanzados | Ver README del mod |
| **`realtime_elevator`** | [ContentDB](https://content.luanti.org/packages/realtime_elevator/) | Ascensores en tiempo real | [Ver README](../../server/mods/realtime_elevator/README.md) |
| **`automobiles_pck`** | Adaptado para VoxeLibre | Vehículos sostenibles | [Ver README](../../server/mods/automobiles_pck/README_WETLANDS.md) |
| **`3dforniture`** | ContentDB | Muebles 3D | Ver README del mod |
| **`mcl_custom_world_skins`** | [ContentDB](https://content.luanti.org/packages/covertiii/mcl_custom_world_skins/) | Skins personalizadas | [Ver doc](../CUSTOM_SKINS_SETUP.md) |
| **`_world_folder_media`** | [ContentDB](https://content.luanti.org/packages/MisterE/_world_folder_media/) | Medios desde carpeta del mundo | Ver README del mod |
| **`mcl_decor`** | ContentDB | Decoraciones adicionales | Ver README del mod |

### Criterios de Selección

Instalamos mods de terceros cuando:

1. ✅ Cumplen nuestra filosofía (sin violencia, educativo)
2. ✅ Son compatibles con VoxeLibre v0.90.1
3. ✅ Están bien mantenidos y documentados
4. ✅ No duplican funcionalidad que podemos desarrollar mejor
5. ✅ Tienen licencia compatible (GPL v3 preferido)

---

## 🔗 Relaciones entre Mods

### Dependencias Principales

```
server_rules
  └─> mcl_core (base)

education_blocks
  └─> mcl_core (base)

voxelibre_protection
  ├─> mcl_core (base)
  └─> pvp_arena (opcional, para arenas)

auto_road_builder
  ├─> mcl_core (base)
  └─> mcl_stairs (opcional, para escaleras)

wetlands-music
  ├─> mcl_jukebox (base)
  └─> mcl_core (base)

broom_racing
  ├─> mcl_core (base)
  ├─> mcl_mobitems (base)
  └─> mcl_dye (base)

vegan_food (tercero)
  ├─> mcl_core (base)
  ├─> mcl_farming (base)
  └─> mcl_buckets (base)

areas (tercero)
  └─> mcl_core (base)

worldedit (tercero)
  └─> mcl_core (base)
```

### Integraciones Específicas

#### 1. Sistema de Protección

```
voxelibre_protection (nuestro)
    ↓ extiende
areas (tercero)
    ↓ usa
mcl_core (base)
```

**Relación**: `voxelibre_protection` extiende el sistema de `areas` para mejor compatibilidad con VoxeLibre.

#### 2. Sistema de Skins

```
mcl_custom_world_skins (tercero)
    ↓ usa
_world_folder_media (tercero)
    ↓ carga desde
server/worlds/world/_world_folder_media/textures/
    ↓ registra en
mcl_skins (base)
    ↓ genera nodos en
mcl_maps (base) ← Problema resuelto con nombres sanitizados
```

**Relación**: Sistema completo de skins personalizadas que carga desde la carpeta del mundo.

#### 3. Sistema de Construcción

```
auto_road_builder (nuestro)
    ↓ usa
worldedit (tercero) - para selección de áreas
    ↓ usa
mcl_core (base) - para bloques
```

**Relación**: `auto_road_builder` puede usar WorldEdit para seleccionar puntos, pero también funciona independientemente.

#### 4. Sistema de Eventos

```
broom_racing (nuestro)
    ↓ usa
halloween_ghost (nuestro) - eventos temporales
    ↓ usa
halloween_zombies (nuestro) - eventos temporales
    ↓ todos usan
mcl_core (base)
```

**Relación**: Mods de eventos temporales que comparten APIs base.

### Conflictos y Soluciones

#### Problema: mcl_maps con skins personalizadas

**Problema**: El mod `mcl_maps` (base) intentaba crear nodos con IDs de skins que contenían caracteres no permitidos (ej: `panda-panda-23030559`).

**Solución**: Renombrar archivos de skins a nombres simples (ej: `panda.png`) en lugar de parchear el mod base.

**Lección**: Siempre usar nombres simples para assets personalizados.

---

## 📚 Documentación Individual de Mods

Cada mod desarrollado por nosotros tiene su propia documentación en su carpeta:

### Mods con Documentación Completa

- ✅ **`auto_road_builder`**: [README.md](../../server/mods/auto_road_builder/README.md)
- ✅ **`broom_racing`**: [README.md](../../server/mods/broom_racing/README.md)
- ✅ **`voxelibre_protection`**: [README.md](../../server/mods/voxelibre_protection/README.md) + [docs/](../../server/mods/voxelibre_protection/docs/)
- ✅ **`wetlands-music`**: [README.md](../../server/mods/wetlands-music/README.md)
- ✅ **`halloween_ghost`**: [README.md](../../server/mods/halloween_ghost/README.md)
- ✅ **`halloween_zombies`**: [README.md](../../server/mods/halloween_zombies/README.md)

### Mods que Necesitan Documentación

- ⚠️ **`server_rules`**: Documentación pendiente
- ⚠️ **`education_blocks`**: Tiene docs básica, necesita expandir
- ⚠️ **`wetlands_christmas`**: Documentación pendiente
- ⚠️ **`voxelibre_tv`**: Documentación pendiente
- ⚠️ **`wetland_city`**: Documentación pendiente
- ⚠️ **`creative_force`**: Documentación pendiente
- ⚠️ **`mcl_potions_hotfix`**: Documentación pendiente
- ⚠️ **`vegan_replacements`**: Documentación pendiente

---

## 🛠️ Guías de Desarrollo

Para desarrollar nuevos mods, consulta:

- **[MODDING_GUIDE.md](./MODDING_GUIDE.md)**: Guía completa de desarrollo
- **[AREAS_PROTECTION_SYSTEM.md](./AREAS_PROTECTION_SYSTEM.md)**: Sistema de protección
- **[WORLDEDIT_GUIDE.md](./WORLDEDIT_GUIDE.md)**: Uso de WorldEdit
- **[CHESS_MOD.md](./CHESS_MOD.md)**: Sistema de ajedrez
- **[PVP_ARENA_WORLDEDIT_GUIDE.md](./PVP_ARENA_WORLDEDIT_GUIDE.md)**: Arenas PvP

---

## 📊 Estadísticas del Ecosistema

- **Mods base de VoxeLibre**: ~150-200 mods
- **Mods desarrollados por nosotros**: 14 mods
- **Mods instalados de terceros**: ~18 mods
- **Total de mods activos**: ~180-230 mods

---

## 🔄 Mantenimiento y Actualizaciones

### Actualizar Mods Base de VoxeLibre

Los mods base se actualizan cuando actualizamos VoxeLibre:

```bash
# En VPS
cd $PROJECT_PATH
# Actualizar VoxeLibre (proceso manual)
docker-compose restart luanti-server
```

### Actualizar Mods de Terceros

```bash
# Descargar nueva versión desde ContentDB
# Reemplazar en server/mods/nombre_mod/
git add server/mods/nombre_mod/
git commit -m "📦 Update nombre_mod to vX.X.X"
git push
```

### Actualizar Mods Desarrollados por Nosotros

```bash
# Editar código
nano server/mods/mi_mod/init.lua
# Commit y push
git add server/mods/mi_mod/
git commit -m "✨ Update mi_mod: nueva funcionalidad"
git push
# En VPS
ssh <VPS_USER>@<VPS_IP> "cd $PROJECT_PATH && git pull && docker-compose restart luanti-server"
```

---

## 📞 Soporte

Para problemas con mods:

1. **Revisar documentación individual** del mod
2. **Consultar logs**: `docker-compose logs luanti-server | grep nombre_mod`
3. **Verificar dependencias** en `mod.conf`
4. **Revisar [MODDING_GUIDE.md](./MODDING_GUIDE.md)** para troubleshooting

---

**Última actualización**: Diciembre 7, 2025  
**Mantenedor**: Equipo Wetlands  
**Licencia**: GPL-3.0 (mods desarrollados por nosotros)

