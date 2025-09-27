# 🌱 Guía Completa de Desarrollo de Mods para Wetlands

**Versión**: 3.0
**Última actualización**: Septiembre 27, 2025
**Motor**: Luanti (Minetest) + VoxeLibre v0.90.1

Esta guía unifica toda la información técnica necesaria para desarrollar, modificar y mantener mods para el servidor Wetlands. Dirigida a programadores familiarizados con Lua y el entorno Luanti.

---

## 🎯 1. Filosofía de Desarrollo Wetlands

Todo mod desarrollado para Wetlands debe adherirse a principios fundamentales:

### 📋 Principios Básicos
1. **🌿 Compasivo y Pacífico**: Sin mecánicas de violencia, caza o explotación animal. Enfoque en cuidado, protección y cooperación.
2. **📚 Educativo**: Cada mod debe enseñar sobre compasión, sostenibilidad o habilidades técnicas.
3. **⚡ Rendimiento y Calidad**: Código limpio, eficiente y bien documentado para estabilidad del servidor.
4. **👶 Apropiado para niños**: Contenido seguro y constructivo para edades 7+ años.
5. **🤝 Construcción de comunidad**: Fomentar colaboración y experiencias compartidas positivas.

### 🎨 Valores de Desarrollo
- **Compasión primero**: Cada mecánica debe promover empatía
- **Educación natural**: Aprendizaje integrado, no forzado
- **Inclusión total**: Accesible para todos los niños
- **Sostenibilidad**: Promover conciencia ambiental
- **Comunidad positiva**: Fomentar colaboración y amistad

---

## 🏗️ 2. Arquitectura VoxeLibre (CRÍTICO)

### ⚠️ La Regla de Oro
**VoxeLibre NO usa el directorio `/mods` estándar**. Solo carga mods desde su estructura de carpetas categorizadas específica.

### 📁 Estructura de Directorios Docker

```yaml
# docker-compose.yml - Mapeo correcto de mods
services:
  luanti-server:
    volumes:
      # ✅ CORRECTO - Mapeo a categorías VoxeLibre:
      - ./server/mods/vegan_foods:/config/.minetest/games/mineclone2/mods/ITEMS/vegan_foods
      - ./server/mods/animal_sanctuary:/config/.minetest/games/mineclone2/mods/ENTITIES/animal_sanctuary
      - ./server/mods/education_blocks:/config/.minetest/games/mineclone2/mods/HELP/education_blocks

      # ❌ INCORRECTO - No funciona con VoxeLibre:
      # - ./server/mods/mi_mod:/config/.minetest/mods/mi_mod
```

### 🗂️ Categorías VoxeLibre Principales

| Categoría | Uso | Ejemplos |
|-----------|-----|----------|
| `ITEMS` | Comida, herramientas, bloques crafteables | vegan_foods, herramientas_cuidado |
| `ENTITIES` | Animales, NPCs, mobs pacíficos | animal_sanctuary, robot_companion |
| `HELP` | Mods educativos, sistemas de ayuda | education_blocks, coding_blocks |
| `CORE` | Funcionalidad central, APIs base | compassion_system |
| `PLAYER` | Mecánicas del jugador | back_to_spawn |
| `MAPGEN` | Generación de mundo, biomas | sustainable_biomes |

### 🔗 APIs y Dependencias VoxeLibre

#### ✅ APIs Estables (Usar siempre)
- **`mcl_core`**: Bloques fundamentales (piedra, tierra, madera)
- **`mcl_farming`**: Sistema de agricultura
- **`mcl_mobs`**: API robusta para entidades
- **`mcl_util`**: Utilidades y helpers comunes
- **`mcl_inventory`**: Sistema de inventarios
- **`mcl_formspec`**: Construcción de interfaces
- **`mcl_player`**: Mecánicas del jugador
- **`mcl_weather`**: Sistema climático

#### ❌ APIs Problemáticas (EVITAR)
- **`default`**: No existe en VoxeLibre (usar `mcl_core`)
- **`farming`**: Usar `mcl_farming` en su lugar
- **`mcl_sounds`**: Eliminada en versiones recientes
- **`mobs`**: Usar `mcl_mobs` exclusivamente

#### 🔄 Tabla de Conversiones Críticas

| Luanti Estándar (❌) | VoxeLibre (✅) | Uso |
|---------------------|-----------------|-----|
| `default:apple` | `mcl_core:apple` | Comida básica |
| `default:stick` | `mcl_core:stick` | Crafteo |
| `default:stone` | `mcl_core:stone` | Construcción |
| `farming:wheat` | `mcl_farming:wheat_item` | Agricultura |
| `default.node_sound_wood_defaults()` | `mcl_sounds.node_sound_wood_defaults()` | Sonidos |
| `bucket:bucket_water` | `mcl_buckets:bucket_water` | Líquidos |

---

## 🛠️ 3. Estructura de Mod Profesional

### 📦 Estructura Mínima Requerida
```
mi_mod_educativo/
├── mod.conf              # Configuración obligatoria
├── init.lua              # Punto de entrada principal
├── locale/               # Traducciones
│   ├── template.txt
│   └── es.tr
├── textures/             # Assets visuales
├── sounds/               # Efectos de sonido
└── models/               # Modelos 3D (opcional)
```

### 📦 Estructura Avanzada Recomendada
```
mi_mod_educativo/
├── mod.conf              # Configuración y dependencias
├── init.lua              # Punto de entrada y configuración
├── api.lua               # APIs públicas del mod
├── nodes.lua             # Definición de bloques
├── items.lua             # Herramientas y objetos
├── entities.lua          # Mobs y entidades
├── crafting.lua          # Recetas de crafteo
├── commands.lua          # Comandos de chat
├── locale/               # Sistema de traducciones
│   ├── template.txt      # Plantilla de traducciones
│   └── es.tr             # Español (idioma principal)
├── textures/             # Texturas y assets visuales
├── sounds/               # Efectos de sonido
├── models/               # Modelos 3D
├── tests/                # Tests automatizados
└── README.md             # Documentación del mod
```

### 📄 mod.conf Completo para Wetlands
```ini
# Información básica
name = mi_mod_educativo
title = Mod Educativo Para Wetlands
description = Mod que promueve educación compasiva y cuidado animal
author = TuNombre
license = GPL v3
version = 1.0.0
min_minetest_version = 5.4.0

# Dependencias VoxeLibre
depends = mcl_core
optional_depends = mcl_mobs, mcl_farming, mcl_inventory, doc_items

# Configuración específica Wetlands
supported_games = mineclone2
```

---

## 💻 4. Patrones de Código Profesional

### 🚀 Inicialización Robusta (init.lua)
```lua
-- init.lua - Patrón profesional para Wetlands
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

-- Tabla global del mod (namespace)
local mod = {}
_G[modname] = mod

-- Verificación de compatibilidad VoxeLibre
if not minetest.get_modpath("mcl_core") then
    minetest.log("error", "[" .. modname .. "] VoxeLibre (mcl_core) es requerido!")
    return
end

-- Configuración del mod
mod.settings = {
    enable_educational_messages = minetest.settings:get_bool(modname .. "_educational", true),
    max_animals_per_area = tonumber(minetest.settings:get(modname .. "_max_animals") or "10"),
    debug_mode = minetest.settings:get_bool(modname .. "_debug", false)
}

-- Sistema de logging
local function log(level, message)
    minetest.log(level, "[" .. modname .. "] " .. message)
end

local function debug(message)
    if mod.settings.debug_mode then
        log("info", "DEBUG: " .. message)
    end
end

-- Carga modular de archivos
if minetest.get_modpath(modname) then
    local files_to_load = {
        "api",       -- APIs públicas primero
        "nodes",     -- Bloques y nodos
        "items",     -- Herramientas y objetos
        "entities",  -- Mobs y entidades
        "crafting",  -- Recetas
        "commands"   -- Comandos de chat
    }

    for _, file in ipairs(files_to_load) do
        local filepath = modpath .. "/" .. file .. ".lua"
        local f = io.open(filepath, "r")
        if f then
            f:close()
            dofile(filepath)
            debug("Loaded " .. file .. ".lua")
        end
    end
end

-- Inicialización post-carga
mod.initialize = function()
    log("info", "Mod inicializado exitosamente v" .. (mod.version or "unknown"))
end

minetest.register_on_mods_loaded(mod.initialize)
```

### 🧱 Registro de Nodos Educativos
```lua
-- nodes.lua - Bloques educativos profesionales
local S = minetest.get_translator(modname)

-- Función helper para nodos educativos
local function register_education_node(name, def)
    -- Validación de entrada
    assert(type(name) == "string", "Node name must be string")
    assert(type(def) == "table", "Node definition must be table")
    assert(type(def.education_message) == "string", "education_message required")

    -- Defaults profesionales para Wetlands
    local base_def = {
        description = def.description or S("Bloque Educativo"),
        tiles = def.tiles or {"education_default.png"},
        groups = def.groups or {cracky=2, educational=1},
        sounds = mcl_sounds and mcl_sounds.node_sound_stone_defaults() or {},

        -- Propiedades VoxeLibre
        _mcl_hardness = def._mcl_hardness or 1.5,
        _mcl_blast_resistance = def._mcl_blast_resistance or 6.0,

        -- Interacción educativa estándar
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            if not clicker or not clicker:is_player() then
                return
            end

            local player_name = clicker:get_player_name()

            -- Mensaje educativo
            minetest.chat_send_player(player_name, "🌱 " .. S(def.education_message))

            -- Efecto visual de aprendizaje
            minetest.add_particlespawner({
                amount = 15,
                time = 2,
                minpos = vector.subtract(pos, {x=0.5, y=0.5, z=0.5}),
                maxpos = vector.add(pos, {x=0.5, y=1.5, z=0.5}),
                minvel = {x=-1, y=0, z=-1},
                maxvel = {x=1, y=1, z=1},
                minacc = {x=0, y=-1, z=0},
                maxacc = {x=0, y=-1, z=0},
                minexptime = 1,
                maxexptime = 3,
                minsize = 1,
                maxsize = 3,
                texture = "heart.png^[colorize:#90EE90:127",
            })

            return itemstack
        end,

        -- Documentación automática
        _doc_items_longdesc = def._doc_items_longdesc,
        _doc_items_usagehelp = S("Haz clic derecho para aprender algo nuevo."),
    }

    -- Merge con definición personalizada
    for k, v in pairs(def) do
        if k ~= "education_message" then
            base_def[k] = v
        end
    end

    minetest.register_node(modname .. ":" .. name, base_def)

    -- Auto-registro en documentación si está disponible
    if minetest.get_modpath("doc_items") and def._doc_items_longdesc then
        doc.add_entry("nodes", modname .. ":" .. name, {
            name = base_def.description,
            data = {
                longdesc = def._doc_items_longdesc,
                usagehelp = base_def._doc_items_usagehelp
            }
        })
    end
end

-- Ejemplo de uso
register_education_node("compassion_block", {
    description = S("Bloque de Compasión"),
    tiles = {"compassion_block.png"},
    education_message = "La compasión es entender que todos los seres sienten y merecen respeto.",
    _doc_items_longdesc = S("Un bloque especial que enseña sobre la compasión hacia todos los seres vivos."),
    groups = {cracky=2, educational=1, compassion=1},
})
```

### 🐾 Sistema de Animales de Santuario
```lua
-- entities.lua - Animales educativos
local S = minetest.get_translator(modname)

-- Función para registrar animales de santuario
local function register_sanctuary_animal(name, def)
    local full_name = modname .. ":" .. name

    mcl_mobs.register_mob(full_name, {
        description = def.description or S("Animal del Santuario"),
        type = "animal",
        spawn_class = "passive",

        -- Propiedades físicas base
        hp_min = def.hp_min or 15,
        hp_max = def.hp_max or 20,
        xp_min = 0, -- Sin XP por matar (anti-violencia)
        xp_max = 0,
        collisionbox = def.collisionbox or {-0.25, -0.01, -0.25, 0.25, 0.49, 0.25},
        visual = "mesh",
        mesh = def.mesh or "default_animal.b3d",
        textures = def.textures or {{"default_animal.png"}},

        -- Comportamiento pacífico
        passive = true,
        walk_velocity = def.walk_velocity or 1,
        run_velocity = def.run_velocity or 2,
        jump_height = def.jump_height or 4,
        view_range = def.view_range or 8,
        fear_height = 4,

        -- Sin drops agresivos
        drops = {},

        -- Propiedades especiales Wetlands
        damage = 0, -- Sin daño
        fall_damage = false,

        -- Interacción educativa estándar
        on_rightclick = function(self, clicker)
            if not clicker or not clicker:is_player() then
                return
            end

            local item = clicker:get_wielded_item()
            local item_name = item:get_name()
            local player_name = clicker:get_player_name()

            -- Sistema de alimentación compasiva
            local food_items = def.food_items or {
                "mcl_farming:carrot_item",
                "mcl_farming:potato_item",
                "mcl_farming:beetroot_item"
            }

            local is_food = false
            for _, food in ipairs(food_items) do
                if item_name == food then
                    is_food = true
                    break
                end
            end

            if is_food then
                -- Consumir comida
                if not minetest.is_creative_enabled(player_name) then
                    item:take_item()
                    clicker:set_wielded_item(item)
                end

                -- Curar al animal
                self:heal(5)

                -- Mensaje educativo específico
                local food_message = def.food_message or
                    "¡El animal está feliz! Los animales necesitan alimentos nutritivos para estar sanos."
                minetest.chat_send_player(player_name, "🥕 " .. S(food_message))

                -- Efecto de corazones
                minetest.add_particlespawner({
                    amount = 10,
                    time = 1,
                    minpos = vector.add(self.object:get_pos(), {x=-0.5, y=0.5, z=-0.5}),
                    maxpos = vector.add(self.object:get_pos(), {x=0.5, y=1.5, z=0.5}),
                    minvel = {x=-1, y=1, z=-1},
                    maxvel = {x=1, y=2, z=1},
                    minacc = {x=0, y=-3, z=0},
                    maxacc = {x=0, y=-3, z=0},
                    minexptime = 1,
                    maxexptime = 2,
                    minsize = 2,
                    maxsize = 4,
                    texture = "heart.png",
                })

            -- Cepillado (herramientas de cuidado)
            elseif item_name == modname .. ":animal_brush" or
                   (def.care_items and table.concat(def.care_items, ","):find(item_name)) then

                local care_message = def.care_message or
                    "¡El animal disfruta ser cepillado! El cuidado regular es fundamental para su bienestar."
                minetest.chat_send_player(player_name, "🧹 " .. S(care_message))

            -- Interacción general educativa
            else
                local general_message = def.general_message or
                    "Este animal vive seguro en el santuario. Puedes alimentarlo con verduras frescas."
                minetest.chat_send_player(player_name, "🐾 " .. S(general_message))
            end
        end,

        -- Animaciones si están definidas
        animation = def.animation or {
            speed_normal = 25,
            stand_start = 0, stand_end = 0,
            walk_start = 0, walk_end = 20,
            run_start = 0, run_end = 20,
        },

        -- Sonidos opcionales
        sounds = def.sounds,

        -- Callbacks personalizados
        on_spawn = def.on_spawn,
    })
end

-- Ejemplo: Conejo del santuario
register_sanctuary_animal("sanctuary_rabbit", {
    description = S("Conejo del Santuario"),
    mesh = "mobs_mc_rabbit.b3d",
    textures = {{"mobs_mc_rabbit_brown.png"}},
    collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.49, 0.25},
    hp_min = 12,
    hp_max = 18,
    walk_velocity = 1,
    run_velocity = 3,
    food_items = {"mcl_farming:carrot_item", "mcl_farming:potato_item", "mcl_core:apple"},
    food_message = "¡Al conejo le encantan las verduras frescas! Una buena alimentación es clave para su salud.",
    care_message = "¡El conejo disfruta ser cepillado! Los conejos necesitan cuidado regular de su pelaje.",
    general_message = "Este conejo vive feliz en el santuario. Es muy social y le gusta la compañía."
})
```

---

## 🚀 5. Proceso de Deployment Completo

### 📋 Flujo de Trabajo Git-First (Recomendado)
```
Desarrollo Local → Commit/Push → Pull VPS → Habilitar Mod → Restart Server
```

### 1️⃣ Desarrollo Local
```bash
# Crear estructura del mod
cd /home/gabriel/Documentos/Vegan-Wetlands/server/mods/
mkdir mi_mod_educativo
cd mi_mod_educativo

# Crear archivos básicos
touch mod.conf init.lua
mkdir -p textures sounds locale

# Desarrollar y probar sintaxis
lua -c init.lua  # Verificar sintaxis básica
```

### 2️⃣ Commit y Push
```bash
# En directorio raíz del proyecto
cd /home/gabriel/Documentos/Vegan-Wetlands/

# Agregar archivos al staging
git add server/mods/mi_mod_educativo/

# Commit descriptivo siguiendo convenciones
git commit -m "🌱 Add: Educational mod mi_mod_educativo v1.0

🎯 Características:
• Bloques educativos interactivos sobre compasión
• Sistema de animales de santuario
• Herramientas de cuidado animal

🛡️ Compatibilidad:
• Compatible con VoxeLibre v0.90.1
• Depende solo de mcl_core
• Sin modificaciones a archivos core

📚 Educación:
• Enseña compasión hacia animales
• Promueve alimentación consciente
• Apropiado para niños 7+ años

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push al repositorio
git push origin main
```

### 3️⃣ Deployment en VPS
```bash
# Conectar al VPS
ssh gabriel@167.172.251.27

# Navegar al directorio
cd /home/gabriel/Vegan-Wetlands

# Pull oficial desde GitHub
git pull origin main

# Verificar que el mod se descargó
ls -la server/mods/mi_mod_educativo/
```

### 4️⃣ Configuración VoxeLibre
```bash
# Opción 1: Mapeo Docker (para estructura compleja)
# Editar docker-compose.yml para agregar mapeo específico

# Opción 2: Mod en directorio estándar (para mods simples)
# El mod ya está en server/mods/ que se mapea a /config/.minetest/mods/

# Habilitar mod en world.mt
docker-compose exec -T luanti-server sh -c 'echo "load_mod_mi_mod_educativo = true" >> /config/.minetest/worlds/world/world.mt'

# Verificar configuración
docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/world.mt | grep mi_mod_educativo
```

### 5️⃣ Reinicio y Verificación
```bash
# Reiniciar servidor
docker-compose restart luanti-server

# Esperar inicio completo
sleep 15

# Verificar logs de carga del mod
docker-compose logs --tail=30 luanti-server | grep mi_mod_educativo

# Verificar estado del servidor
docker-compose ps
ss -tulpn | grep :30000
```

---

## 🔍 6. Troubleshooting Avanzado

### ❌ Problema: Mod No Carga
**Síntomas**: Mod no aparece en el juego, comandos no funcionan

**Diagnóstico**:
```bash
# 1. Verificar archivo de configuración
docker-compose exec -T luanti-server cat /config/.minetest/mods/mi_mod/mod.conf

# 2. Verificar habilitación en world.mt
docker-compose exec -T luanti-server cat /config/.minetest/worlds/world/world.mt | grep mi_mod

# 3. Revisar logs de errores
docker-compose logs luanti-server | grep -i error | tail -10

# 4. Verificar dependencias
docker-compose exec -T luanti-server ls -la /config/.minetest/games/mineclone2/mods/CORE/
```

**Soluciones**:
1. **Sintaxis Lua incorrecta**: Verificar con `lua -c archivo.lua`
2. **Dependencias faltantes**: Revisar mod.conf y APIs disponibles
3. **Mod no habilitado**: Agregar `load_mod_nombre = true` a world.mt
4. **Mapeo Docker incorrecto**: Verificar docker-compose.yml

### ❌ Problema: Items No Registrados
**Síntomas**: `WARNING: Undeclared global variable "mcl_core" accessed`

**Causa**: Dependencias de VoxeLibre no disponibles

**Solución**:
```lua
-- Verificar disponibilidad antes de usar
if minetest.get_modpath("mcl_core") then
    -- Usar APIs de mcl_core
    local apple = "mcl_core:apple"
else
    minetest.log("warning", "[" .. modname .. "] mcl_core not available")
    return
end
```

### ❌ Problema: Texturas No Cargan
**Síntomas**: Bloques aparecen con texturas incorrectas o faltantes

**Solución**:
```lua
-- Verificar nombres de archivos exactos
textures = {
    "mi_mod_bloque_top.png",     -- Debe existir en textures/
    "mi_mod_bloque_side.png",    -- Nombres case-sensitive
}

-- Debug de texturas
minetest.log("info", "[" .. modname .. "] Registrando texturas: " ..
    table.concat(def.tiles or {"none"}, ", "))
```

### ❌ Problema: Performance/Lag
**Síntomas**: Servidor lento cuando hay muchas entidades

**Optimizaciones**:
```lua
-- Limitar entidades por área
local MAX_ENTITIES_PER_AREA = 8
local AREA_RADIUS = 24

local function count_entities_in_area(pos, entity_name)
    local objs = minetest.get_objects_inside_radius(pos, AREA_RADIUS)
    local count = 0
    for _, obj in ipairs(objs) do
        local ent = obj:get_luaentity()
        if ent and ent.name == entity_name then
            count = count + 1
        end
    end
    return count
end

-- En función de spawn
if count_entities_in_area(spawn_pos, modname .. ":mi_entidad") >= MAX_ENTITIES_PER_AREA then
    return false -- No spawnear más
end
```

---

## 🧪 7. Testing y Validación

### 🔬 Tests Automatizados
```lua
-- tests/test_mod.lua
local tests = {}

function tests.test_mod_loading()
    assert(minetest.get_modpath(modname), "Mod no cargado")
    assert(_G[modname], "Namespace no existe")
end

function tests.test_voxelibre_compatibility()
    assert(minetest.get_modpath("mcl_core"), "VoxeLibre no disponible")

    -- Verificar que no usamos APIs vanilla
    local items = minetest.registered_items
    for name, def in pairs(items) do
        if name:find("^" .. modname .. ":") then
            -- Verificar recetas no usan items vanilla
            assert(not name:find("default:"), "Usando items vanilla: " .. name)
        end
    end
end

function tests.test_educational_content()
    local commands = minetest.registered_chatcommands
    assert(commands["santuario"] or commands["filosofia"], "Comandos educativos faltantes")
end

-- Ejecutor de tests
local function run_tests()
    local passed, failed = 0, 0
    for test_name, test_func in pairs(tests) do
        local success, error_msg = pcall(test_func)
        if success then
            minetest.log("info", "[" .. modname .. "] ✅ " .. test_name)
            passed = passed + 1
        else
            minetest.log("error", "[" .. modname .. "] ❌ " .. test_name .. ": " .. error_msg)
            failed = failed + 1
        end
    end
    minetest.log("info", string.format("[%s] Tests: %d passed, %d failed", modname, passed, failed))
end

-- Ejecutar si debug habilitado
if minetest.settings:get_bool(modname .. "_run_tests", false) then
    minetest.register_on_mods_loaded(run_tests)
end
```

### 🛠️ Comandos de Testing para Admins
```lua
-- commands.lua - Comandos de desarrollo
if minetest.settings:get_bool(modname .. "_debug", false) then
    minetest.register_chatcommand(modname .. "_test", {
        params = "[test_name]",
        description = "Ejecutar tests del mod",
        privs = {server = true},
        func = function(name, param)
            local player = minetest.get_player_by_name(name)
            local pos = player:get_pos()

            if param == "spawn_entity" then
                pos.y = pos.y + 1
                local obj = minetest.add_entity(pos, modname .. ":sanctuary_rabbit")
                return obj and true or false, obj and "Entity spawneada" or "Error spawning"

            elseif param == "place_block" then
                pos.y = pos.y - 1
                minetest.set_node(pos, {name = modname .. ":compassion_block"})
                return true, "Bloque colocado en " .. minetest.pos_to_string(pos)

            elseif param == "give_items" then
                local inv = player:get_inventory()
                inv:add_item("main", modname .. ":animal_brush 1")
                inv:add_item("main", "mcl_farming:carrot_item 10")
                return true, "Items de testing agregados"
            end

            return false, "Tests disponibles: spawn_entity, place_block, give_items"
        end,
    })
end
```

---

## 📚 8. Mods Existentes y Referencias

### ✅ Mods Funcionando Actualmente

| Mod | Ubicación | Comandos | Descripción |
|-----|-----------|----------|-------------|
| `mcl_back_to_spawn` | `/server/mods/` | `/back_to_spawn` | Teleportación a spawn personal |
| `server_rules` v2.0 | `/server/mods/` | `/reglas`, `/filosofia`, `/santuario` | Sistema completo de reglas |

### 🚧 Roadmap de Desarrollo

#### Prioridad Alta:
1. **`animal_sanctuary_v2`**: Sistema avanzado de rescate y adopción
2. **`compassion_system`**: Sistema de puntos por actos compasivos
3. **`coding_blocks`**: Programación visual tipo Scratch para niños
4. **`robot_companion`**: Robot programable con coding_blocks

#### Prioridad Media:
- **`climate_science`**: Educación sobre cambio climático
- **`sustainable_farming`**: Permacultura y agricultura sostenible
- **`community_projects`**: Mecánicas de construcción colaborativa

---

## 📖 9. Convenciones y Mejores Prácticas

### 🌍 Idioma y Localización
- **Idioma principal**: Español (todos los textos visibles)
- **Comentarios**: En español para colaboración local
- **Variables**: `snake_case` (ej: `cuidar_animal`)
- **Items**: `modname:item_name` (ej: `animal_sanctuary:cepillo_animales`)

### 📁 Estructura de Archivos
```
mi_mod/
├── mod.conf                 # Configuración
├── init.lua                 # Inicialización
├── locale/
│   ├── template.txt         # Plantilla traducciones
│   └── es.tr               # Español
├── textures/
│   ├── mi_mod_item.png     # 16x16 para items
│   └── mi_mod_block.png    # 64x64+ para bloques
├── sounds/
│   ├── mi_mod_sound.ogg    # Formato OGG preferido
│   └── mi_mod_ambient.ogg  # Sonidos ambientales
└── models/                 # Solo si es necesario
    └── mi_mod_entity.b3d   # Modelos Blender
```

### 🔧 Logging y Debug
```lua
-- Sistema de logging estandarizado
local function log(level, message)
    minetest.log(level, "[" .. modname .. "] " .. message)
end

local function debug(message)
    if minetest.settings:get_bool(modname .. "_debug", false) then
        log("info", "DEBUG: " .. message)
    end
end

-- Métricas de performance
local function profile_function(name, func)
    return function(...)
        local start = minetest.get_us_time()
        local result = {func(...)}
        local duration = minetest.get_us_time() - start

        if duration > 1000 then -- > 1ms
            log("warning", "Función lenta " .. name .. ": " .. duration .. "μs")
        end

        return unpack(result)
    end
end
```

### 🔒 Validación y Seguridad
```lua
-- Validadores estándar
local function validate_pos(pos)
    return pos and type(pos) == "table" and
           type(pos.x) == "number" and
           type(pos.y) == "number" and
           type(pos.z) == "number"
end

local function validate_player(player)
    return player and player:is_player() and
           player:get_player_name() ~= ""
end

-- Sanitización de input
local function sanitize_string(str)
    if type(str) ~= "string" then return "" end
    return str:gsub("[^%w%s%-_]", "")  -- Solo alfanuméricos, espacios, guiones
end
```

---

## 🎯 10. Objetivos y Valores Finales

### 🌱 Meta de Wetlands
Crear un ecosistema de mods educativos que:

- **🤗 Promuevan compasión**: Enseñen cuidado animal y respeto por la vida
- **📚 Eduquen naturalmente**: Integren aprendizaje en la jugabilidad
- **👶 Sean apropiados**: Contenido seguro y constructivo para 7+ años
- **🔧 Mantengan calidad**: Código limpio, eficiente y bien documentado
- **🤝 Fomenten comunidad**: Experiencias compartidas positivas

### ✅ Checklist de Calidad
Antes de deployment, verificar:

- [ ] **Compatibilidad VoxeLibre**: Usa solo APIs `mcl_*`
- [ ] **Contenido educativo**: Enseña valores positivos
- [ ] **Apropiado para niños**: Sin violencia o contenido inapropiado
- [ ] **Performance**: Sin lags o funciones costosas
- [ ] **Documentación**: README y comentarios en español
- [ ] **Testing**: Tests básicos implementados
- [ ] **Logging**: Sistema de debug y métricas

### 🌟 Filosofía de Desarrollo
*"En Wetlands, cada línea de código es una semilla de compasión que florece en las mentes jóvenes."*

---

**Versión**: 3.0
**Última actualización**: Septiembre 27, 2025
**Próxima revisión**: Al agregar nuevos mods o cambios en VoxeLibre