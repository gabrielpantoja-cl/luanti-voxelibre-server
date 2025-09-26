# Análisis Interno del Juego Voxelibre (Mineclone 2)

**Fecha de Análisis:** 2025-09-25

## 1. Introducción

Este documento detalla la arquitectura interna y el funcionamiento del juego base `Voxelibre` (anteriormente conocido como Mineclone 2), que sirve como fundamento para el servidor "Wetlands Valdivia". El análisis se basa en la revisión del código fuente ubicado en `estudio-juego-basevoxelibre/`.

Voxelibre es un juego de tipo *sandbox* de supervivencia construido sobre el motor Luanti (un fork de Minetest). Su diseño es altamente modular y extensible, con toda la lógica del juego implementada a través de un sistema de **mods en Lua**.

## 2. Arquitectura General

La estructura del directorio del juego sigue un patrón claro y organizado, separando la configuración, la lógica del juego (mods), los assets (texturas, sonidos) y la documentación.

- **`game.conf`**: Define la identidad del juego, como su nombre (`VoxeLibre`) y descripción.
- **`minetest.conf`**: Archivo para anular o extender la configuración por defecto del motor Minetest/Luanti.
- **`mods/`**: El corazón del juego. Contiene todos los scripts de Lua que definen los bloques, items, entidades, biomas y mecánicas. Está subdividido en categorías lógicas:
    - `CORE`: Funcionalidad central y APIs base.
    - `ITEMS`: Definición de todos los items, herramientas y bloques.
    - `ENTITIES`: Lógica para todas las criaturas y objetos dinámicos (mobs).
    - `MAPGEN`: Generación del mundo, incluyendo biomas, cuevas y estructuras.
    - `HUD`: Elementos de la interfaz de usuario (Heads-Up Display).
    - `PLAYER`: Mecánicas relacionadas con el jugador (movimiento, inventario, etc.).
- **`textures/`**: Contiene los archivos de imagen (PNG) para todos los nodos, items y entidades.
- **`API.md`, `TEXTURES.md`**: Documentación de alto nivel sobre cómo interactuar con el sistema de mods y cómo crear assets.

## 3. El Sistema de Mods en Lua

Toda la funcionalidad del juego se implementa a través de mods. Cada subdirectorio en la carpeta `mods/` representa un mod individual o un grupo de mods relacionados.

### 3.1. Punto de Entrada: `init.lua`

Cada mod tiene un archivo `init.lua` que actúa como su punto de entrada. El motor del juego ejecuta este archivo al cargar el mod. Este script es responsable de:
- Cargar otros archivos Lua del mod usando `dofile()`.
- Registrar nodos, items, crafteos y entidades.
- Establecer callbacks para eventos del juego.

### 3.2. Registro de Contenido

El juego se construye registrando objetos en el motor a través de una API global de Lua, accesible principalmente a través del objeto `minetest`.

#### **Registro de Nodos y Herramientas (Bloques e Items)**

El archivo `mods/ITEMS/mcl_tools/init.lua` es un ejemplo claro de cómo se definen las herramientas. Se utiliza la función `minetest.register_tool()`:

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

- **`"mcl_tools:pick_wood"`**: Es el identificador único del item, compuesto por `nombre_del_mod:nombre_del_item`.
- **`description`**: El nombre que ve el jugador.
- **`inventory_image`**: La textura que se muestra en el inventario.
- **`tool_capabilities`**: Define el comportamiento del item como herramienta, incluyendo daño, durabilidad y velocidad.
- **`_mcl_diggroups`**: Una API personalizada de Voxelibre que define la eficiencia de la herramienta contra tipos específicos de bloques (grupos).

De forma similar, los bloques se registran con `minetest.register_node()`.

#### **Registro de Entidades (Mobs)**

El mod `mcl_mobs` (`mods/ENTITIES/mcl_mobs/`) proporciona una API robusta para crear criaturas. El archivo `init.lua` de este mod carga una serie de helpers (`physics.lua`, `movement.lua`, `combat.lua`) y expone la función `mcl_mobs.register_mob()`:

```lua
function mcl_mobs.register_mob(name, def)
    -- ... lógica interna de la API ...

    minetest.register_entity(name, setmetatable(final_def, mcl_mobs.mob_class_meta))
end
```

Esta función es un wrapper sobre `minetest.register_entity()` que añade una gran cantidad de lógica predefinida para el comportamiento de los mobs, como:
- **`spawn_class`**: Categoría del mob (pasivo, hostil, etc.).
- **Propiedades físicas**: `collisionbox`, `stepheight`.
- **Comportamiento**: `walk_velocity`, `run_velocity`, `damage`, `view_range`.
- **Animaciones, sonidos y drops**.
- **Lógica de IA**: `on_activate`, `on_step` para controlar el comportamiento en cada tick del servidor.

## 4. Generación del Mundo (`Mapgen`)

La generación del mundo es un proceso complejo gestionado por los mods en la carpeta `MAPGEN/`.

### 4.1. Biomas

El archivo `mods/MAPGEN/mcl_biomes/init.lua` define todos los biomas del juego usando `minetest.register_biome()`:

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

- **`name`**: Identificador del bioma.
- **`node_top`, `node_filler`**: Definen los bloques que componen la capa superior y el relleno del terreno.
- **`heat_point`, `humidity_point`**: Determinan en qué lugar del mapa puede aparecer el bioma, basado en el ruido Perlin de temperatura y humedad.
- **`y_min`, `y_max`**: Restringen la altura a la que puede generarse el bioma.
- **`_mcl_*`**: Propiedades personalizadas para definir paletas de colores de vegetación y agua, y el tipo de bioma.

### 4.2. Estructuras y Minerales

El generador de mapas también utiliza `minetest.register_ore()` para generar vetas de minerales y `minetest.register_decoration()` para colocar objetos como árboles, flores y estructuras predefinidas en el mundo.

## 5. Dimensiones y Coordinadas

El archivo `mods/CORE/mcl_init/init.lua` establece variables globales cruciales para la estructura del mundo. Voxelibre simula múltiples dimensiones (Overworld, Nether, The End) apilándolas verticalmente en el eje Y:

- **Overworld**: Cerca de Y=0.
- **The End**: Cerca de Y=-27000.
- **The Nether**: Cerca de Y=-29000.

El código define constantes como `mcl_vars.mg_overworld_min`, `mcl_vars.mg_nether_min`, etc., que son utilizadas por los mods de `mapgen` para colocar los biomas y estructuras en la dimensión correcta.

## 6. Conclusión

Voxelibre es un ejemplo sofisticado de la flexibilidad del motor Luanti/Minetest. Su arquitectura se basa en los siguientes principios:

- **Modularidad Extrema**: Cada aspecto del juego es un mod autocontenido.
- **APIs en Lua**: El juego se construye registrando objetos y callbacks en el motor a través de la API de Lua.
- **Abstracción sobre la API nativa**: Mods como `mcl_mobs` crean APIs de más alto nivel para simplificar el desarrollo de contenido.
- **Configuración por Archivos**: El comportamiento del generador de mapas y de los biomas se controla mediante tablas de Lua y parámetros numéricos, lo que permite un ajuste fino del mundo.

Este diseño permite que el juego sea fácilmente modificable y extensible, lo cual es fundamental para la personalización realizada en el servidor "Vegan Wetlands".
