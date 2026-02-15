-- ============================================================================
-- config.lua - Configuracion Centralizada del Sistema AI
-- ============================================================================
-- Mod: Wetlands NPCs v1.0.0
-- Proposito: Centralizar toda la configuracion del sistema de comportamientos
-- Autor: Wetlands Team
-- Documentacion: README_AI_BEHAVIORS.md
-- ============================================================================

--[[
    ARQUITECTURA DE CONFIGURACIÓN:

    Este archivo actúa como "single source of truth" para todos los parámetros
    configurables del sistema de comportamientos AI tradicional.

    JERARQUÍA DE CONFIGURACIÓN:
    1. Valores por defecto (definidos aquí)
    2. minetest.conf (sobreescribe defaults si existe)
    3. Comandos in-game de admin (sobreescribe en runtime)

    VENTAJAS:
    - Fácil ajuste de parámetros sin tocar lógica
    - Testing rápido de diferentes configuraciones
    - Documentación inline de cada parámetro
--]]

-- Namespace global de configuración
wetlands_npcs.config = {}

-- ============================================================================
-- SECCIÓN 1: CONFIGURACIÓN DE COMPORTAMIENTOS AI
-- ============================================================================

--[[
    MÁQUINA DE ESTADOS (Finite State Machine)

    Los aldeanos operan en diferentes "estados" que determinan su comportamiento.
    Cada estado tiene un peso probabilístico que afecta la frecuencia de ese comportamiento.

    ESTADOS DISPONIBLES:
    - IDLE: Parado, mirando alrededor (bajo consumo CPU)
    - WANDER: Caminando aleatorio (exploración del entorno)
    - WORK: Trabajando en su profesión (busca POI relevantes)
    - SOCIAL: Interactuando con otros NPCs (cercanía social)
    - SLEEP: Durmiendo (solo de noche)
    - SEEK_PLAYER: Buscando jugador cercano (interacción proactiva)
--]]

-- Pesos de comportamiento por profesión (suman ~100 para facilitar cálculo porcentual)
wetlands_npcs.config.behavior_weights = {
    -- Star Wars NPCs
    luke = {
        idle = 20,
        wander = 30,
        work = 35,
        social = 15,
    },
    anakin = {
        idle = 10,
        wander = 40,
        work = 35,
        social = 15,
    },
    yoda = {
        idle = 40,      -- Yoda es contemplativo
        wander = 20,
        work = 25,
        social = 15,
    },
    mandalorian = {
        idle = 15,
        wander = 50,    -- Siempre en movimiento
        work = 25,
        social = 10,
    },
    leia = {
        idle = 20,
        wander = 25,
        work = 30,
        social = 25,    -- Leia es diplomatica y social
    },
    splinter = {
        idle = 80,      -- Splinter es MUY contemplativo, casi estatico
        wander = 5,     -- Minimo movimiento (solo gira en su sitio)
        work = 5,       -- Casi nunca busca POIs
        social = 10,    -- Solo socializa si alguien viene a el
    },
    sensei_wu = {
        idle = 60,      -- Wu medita y hace gestos (gestures en idle)
        wander = 15,    -- Da unos pasos cortos y vuelve (radius=4)
        work = 5,       -- Casi nunca busca POIs
        social = 20,    -- Social: le gusta interactuar con jugadores y NPCs
    },
    -- Classic NPCs
    farmer = {
        idle = 20,
        wander = 30,
        work = 40,
        social = 10,
    },
    librarian = {
        idle = 40,
        wander = 20,
        work = 30,
        social = 10,
    },
    teacher = {
        idle = 25,
        wander = 25,
        work = 35,
        social = 15,
    },
    explorer = {
        idle = 10,
        wander = 60,
        work = 20,
        social = 10,
    },
}

--[[
    DURACIÓN DE ESTADOS

    Controla cuánto tiempo (en segundos) permanece un aldeano en cada estado
    antes de evaluar un cambio de comportamiento.

    BALANCE:
    - Muy corto (<5s): Aldeanos parecen "nerviosos" o indecisivos
    - Muy largo (>30s): Aldeanos parecen "robóticos" o estáticos
    - Óptimo: 10-20s con variación aleatoria
--]]
wetlands_npcs.config.state_duration = {
    min = 10,  -- Mínimo 10 segundos en un estado
    max = 20,  -- Máximo 20 segundos (luego evalúa cambio)
}

--[[
    PUNTOS DE INTERÉS (POI - Points of Interest)

    Define qué bloques/nodos son "interesantes" para cada profesión.
    Los aldeanos buscarán activamente estos bloques cuando están en estado WORK.

    FORMATO: Lista de node names de VoxeLibre

    IMPLEMENTACIÓN:
    - Radio de búsqueda: 15 bloques (configurable abajo)
    - Algoritmo: Busca en espiral desde posición actual
    - Pathfinding: Usa mcl_mobs:gopath() para navegar
--]]
wetlands_npcs.config.poi_types = {
    -- Star Wars NPCs
    luke = {
        "mcl_books:bookshelf", "mcl_core:tree",
        "mcl_flowers:dandelion", "mcl_core:stone",
    },
    anakin = {
        "mcl_core:iron_ingot", "mcl_core:stone",
        "mcl_core:tree", "mcl_farming:farmland",
    },
    yoda = {
        "mcl_flowers:dandelion", "mcl_flowers:poppy",
        "mcl_core:water_source", "mcl_core:tree",
    },
    mandalorian = {
        "mcl_core:stone", "mcl_core:iron_ingot",
        "mcl_core:tree", "mcl_core:water_source",
    },
    leia = {
        "mcl_books:bookshelf", "mcl_core:tree",
        "mcl_flowers:poppy", "mcl_core:water_source",
    },
    splinter = {
        "mcl_books:bookshelf", "mcl_core:tree",
        "mcl_flowers:dandelion", "mcl_core:stone",
    },
    sensei_wu = {
        "mcl_books:bookshelf", "mcl_core:tree",
        "mcl_flowers:poppy", "mcl_core:gold_ingot",
    },
    -- Classic NPCs
    farmer = {
        "mcl_farming:wheat_1", "mcl_farming:wheat_2", "mcl_farming:wheat_7",
        "mcl_farming:carrot_1", "mcl_farming:carrot_2", "mcl_farming:carrot_3",
        "mcl_core:dirt_with_grass", "mcl_farming:farmland",
    },
    librarian = {
        "mcl_books:bookshelf", "mcl_enchanting:table",
    },
    teacher = {
        "mcl_books:bookshelf", "mcl_core:paper", "mcl_core:stick",
    },
    explorer = {
        "mcl_core:tree", "mcl_flowers:dandelion",
        "mcl_core:water_source", "mcl_core:stone",
    },
}

-- Radio de búsqueda de POI (en bloques)
wetlands_npcs.config.poi_search_radius = 15

-- ============================================================================
-- SECCIÓN 2: CONFIGURACIÓN DE INTERACCIÓN SOCIAL
-- ============================================================================

--[[
    SISTEMA DE SALUDOS AUTOMÁTICOS

    Los aldeanos pueden saludar proactivamente a los jugadores cuando se acercan.
    Esto crea una experiencia más "viva" y acogedora.

    PARÁMETROS:
    - enabled: true/false para activar/desactivar
    - detection_radius: Distancia para detectar jugadores
    - greeting_chance: Probabilidad (1-100) de saludar cada vez
    - cooldown: Tiempo mínimo entre saludos al mismo jugador
--]]
wetlands_npcs.config.auto_greet = {
    enabled = true,
    detection_radius = 5,        -- 5 bloques de radio
    greeting_chance = 30,        -- 30% de probabilidad cada tick
    cooldown_seconds = 30,       -- No saludar al mismo jugador por 30 seg
}

--[[
    INTERACCIÓN ENTRE NPCs

    Los aldeanos pueden "hablar" entre ellos cuando están cerca.
    Esto se visualiza con partículas de corazón o burbujas de chat.

    COMPORTAMIENTO:
    - Solo en estado SOCIAL
    - Buscan otros aldeanos en detection_radius
    - Caminan hacia el aldeano más cercano
    - Generan partículas visuales periódicamente
--]]
wetlands_npcs.config.npc_interaction = {
    enabled = true,
    detection_radius = 10,       -- Detectar otros NPCs a 10 bloques
    particle_chance = 5,         -- 5% probabilidad de mostrar partícula
    interaction_duration = 15,   -- Interactúan por 15 segundos
}

-- ============================================================================
-- SECCIÓN 3: CONFIGURACIÓN DE RUTINAS DÍA/NOCHE
-- ============================================================================

--[[
    CICLO CIRCADIANO (Día/Noche)

    Los aldeanos tienen rutinas diferentes según la hora del día.
    Esto simula un ciclo de vida realista.

    HORARIOS EN LUANTI:
    - 0.0 = Medianoche
    - 0.25 = Amanecer
    - 0.5 = Mediodía
    - 0.75 = Atardecer
    - 1.0 = Medianoche (ciclo completo)

    NOTA: time_of_day retorna valor entre 0.0 y 1.0
--]]
wetlands_npcs.config.schedule = {
    -- Hora de dormir (noche)
    sleep_start = 0.8,   -- 80% del día = ~7:00 PM
    sleep_end = 0.2,     -- 20% del día = ~5:00 AM

    -- Hora de trabajo (día)
    work_start = 0.25,   -- Amanecer
    work_end = 0.75,     -- Atardecer

    -- Buscar cama al dormir
    seek_bed_on_sleep = true,
    bed_search_radius = 20,  -- Buscar camas en 20 bloques
}

-- ============================================================================
-- SECCIÓN 4: CONFIGURACIÓN DE MOVIMIENTO Y PATHFINDING
-- ============================================================================

--[[
    PARÁMETROS DE MOVIMIENTO

    Controla la velocidad y comportamiento de navegación de los aldeanos.
    Estos valores se pasan a mcl_mobs para control de movimiento.

    VELOCIDADES:
    - walk_velocity: Velocidad al caminar normal
    - run_velocity: Velocidad al correr (perseguir/huir)

    UNIDADES: Bloques por segundo
--]]
wetlands_npcs.config.movement = {
    walk_velocity = 1.2,     -- Caminar tranquilo
    run_velocity = 2.4,      -- Correr (si es necesario)
    jump_height = 5,         -- Altura de salto
    stepheight = 1.1,        -- Subir escalones automaticamente
    max_wander_radius = 15,  -- Radio maximo de movimiento desde spawn point (home_pos)
    return_home_threshold = 20, -- Si esta mas lejos que esto, forzar retorno
}

-- Overrides de movimiento por NPC (para NPCs que deben ser casi estaticos)
-- Si un NPC tiene override aqui, sus valores reemplazan los globales
wetlands_npcs.config.movement_overrides = {
    splinter = {
        max_wander_radius = 3,      -- Solo 3 bloques desde spawn
        return_home_threshold = 5,   -- Forzar retorno si se aleja 5+
        poi_search_radius = 3,       -- Solo buscar POIs muy cercanos
        social_search_radius = 4,    -- Solo socializar con NPCs muy cercanos
    },
    sensei_wu = {
        max_wander_radius = 4,      -- 4 bloques desde spawn (pasos cortos)
        return_home_threshold = 6,   -- Forzar retorno si se aleja 6+
        poi_search_radius = 4,       -- Solo buscar POIs cercanos
        social_search_radius = 6,    -- Socializar con NPCs cercanos
    },
}

-- Gestos/animaciones especiales cuando el NPC esta en IDLE cerca de jugadores
-- Animaciones del modelo mcl_armor_character.b3d:
--   stand=0-79, sit=81-160, lay=162-166, walk=168-187,
--   mine=189-198 (swing brazo), walk_mine=200-219
wetlands_npcs.config.idle_gestures = {
    sensei_wu = {
        enabled = true,
        cooldown = 8,  -- segundos entre gestos
        gestures = {
            { name = "wave", frames = {x=189, y=198}, speed = 28, duration = 2.5 },
            { name = "meditate", frames = {x=81, y=160}, speed = 15, duration = 4 },
        },
    },
    splinter = {
        enabled = true,
        cooldown = 10,
        gestures = {
            { name = "wave", frames = {x=189, y=198}, speed = 28, duration = 2 },
            { name = "meditate", frames = {x=81, y=160}, speed = 15, duration = 5 },
        },
    },
}

--[[
    PATHFINDING (Navegación)

    Controla cómo los aldeanos encuentran rutas hacia objetivos.

    ALGORITMO: A* (implementado por mcl_mobs)

    PARÁMETROS:
    - max_distance: Distancia máxima para calcular ruta
    - timeout: Tiempo máximo de cálculo (evita lag)
    - stuck_threshold: Si no se mueve por X segundos, abandonar objetivo
--]]
wetlands_npcs.config.pathfinding = {
    max_distance = 30,       -- No buscar rutas de más de 30 bloques
    timeout = 5,             -- 5 segundos máximo de cálculo
    stuck_threshold = 10,    -- Si no se mueve por 10 seg, abandonar
}

-- ============================================================================
-- SECCIÓN 5: CONFIGURACIÓN DE ANIMACIONES Y EFECTOS VISUALES
-- ============================================================================

--[[
    PARTÍCULAS Y EFECTOS VISUALES

    Define los efectos visuales que comunican el estado del aldeano.

    PARTÍCULAS DISPONIBLES:
    - heart.png: Corazones (felicidad, social)
    - bubble.png: Burbujas (pensando, trabajando)
    - note.png: Notas musicales (contento)
    - angry.png: Nube de enojo (si está molesto)
--]]
wetlands_npcs.config.particles = {
    enabled = true,

    -- Partículas de trabajo (cuando está en estado WORK)
    work_particle = {
        texture = "bubble.png",
        amount = 2,
        spawn_chance = 10,  -- 10% cada tick
    },

    -- Partículas de interacción social
    social_particle = {
        texture = "heart.png",
        amount = 3,
        spawn_chance = 5,   -- 5% cada tick
    },

    -- Partículas de sueño
    sleep_particle = {
        texture = "zzz.png",  -- Si existe, sino usar bubble.png
        amount = 1,
        spawn_chance = 20,  -- 20% cada tick cuando duerme
    },
}

-- ============================================================================
-- SECCION 5B: CONFIGURACION DE SONIDO (VOCES NPC)
-- ============================================================================

wetlands_npcs.config.sounds = {
    enabled = true,
    gain = 0.8,
    max_hear_distance = 20,
}

-- ============================================================================
-- SECCION 6: CONFIGURACION DE SPAWNING Y LIMITES
-- ============================================================================

--[[
    CONTROL DE SPAWNING

    Evita sobrepoblación de aldeanos y controla su distribución.

    LÍMITES:
    - max_per_area: Máximo de aldeanos del mismo tipo en un área
    - area_radius: Radio del área (en bloques)
    - max_total: Máximo absoluto de aldeanos en el servidor
--]]
wetlands_npcs.config.spawning = {
    max_per_area = 3,        -- Máximo 3 del mismo tipo en 50 bloques
    area_radius = 50,
    max_total_villagers = 20, -- Máximo 20 aldeanos en todo el servidor
}

-- ============================================================================
-- SECCIÓN 7: CONFIGURACIÓN DE DEBUG Y LOGGING
-- ============================================================================

--[[
    SISTEMA DE DEBUG

    Ayuda a diagnosticar problemas y optimizar comportamientos.

    NIVELES:
    - 0: Sin debug
    - 1: Errores críticos
    - 2: Warnings y cambios de estado
    - 3: Verbose (todos los eventos)

    VISUALIZACIÓN:
    - show_state_above: Muestra texto del estado sobre el aldeano
    - log_state_changes: Imprime en consola cada cambio de estado
--]]
wetlands_npcs.config.debug = {
    enabled = minetest.settings:get_bool("wetlands_npcs_debug", false),
    level = tonumber(minetest.settings:get("wetlands_npcs_debug_level")) or 1,
    show_state_above = false,  -- Nametag con estado actual
    log_state_changes = false, -- Log en consola
    log_pathfinding = false,   -- Log de cálculos de ruta
}

-- ============================================================================
-- SECCIÓN 8: FUNCIONES HELPER DE CONFIGURACIÓN
-- ============================================================================

--[[
    FUNCIÓN: get_config(path)

    Obtiene un valor de configuración usando dot notation.

    EJEMPLO:
        local radius = wetlands_npcs.config.get("poi_search_radius")
        local sleep_start = wetlands_npcs.config.get("schedule.sleep_start")

    VENTAJA: Permite sobreescribir con minetest.conf fácilmente
--]]
function wetlands_npcs.config.get(path)
    local keys = string.split(path, ".")
    local value = wetlands_npcs.config

    for _, key in ipairs(keys) do
        if value[key] ~= nil then
            value = value[key]
        else
            return nil
        end
    end

    return value
end

--[[
    FUNCIÓN: set_config(path, value)

    Establece un valor de configuración en runtime.
    Útil para comandos de admin que ajustan parámetros sin reiniciar.

    EJEMPLO:
        wetlands_npcs.config.set("poi_search_radius", 25)
        wetlands_npcs.config.set("auto_greet.enabled", false)
--]]
function wetlands_npcs.config.set(path, value)
    local keys = string.split(path, ".")
    local target = wetlands_npcs.config

    for i = 1, #keys - 1 do
        local key = keys[i]
        if target[key] == nil then
            target[key] = {}
        end
        target = target[key]
    end

    target[keys[#keys]] = value

    minetest.log("action", "[wetlands_npcs] Config updated: " .. path .. " = " .. tostring(value))
end

--[[
    FUNCIÓN: reload_from_conf()

    Recarga configuración desde minetest.conf.
    Permite ajustar parámetros sin editar código Lua.

    FORMATO EN minetest.conf:
        wetlands_npcs_poi_radius = 20
        wetlands_npcs_auto_greet = true
        wetlands_npcs_debug = false
--]]
function wetlands_npcs.config.reload_from_conf()
    -- POI radius
    local poi_radius = minetest.settings:get("wetlands_npcs_poi_radius")
    if poi_radius then
        wetlands_npcs.config.poi_search_radius = tonumber(poi_radius)
    end

    -- Auto greet enabled
    local auto_greet = minetest.settings:get_bool("wetlands_npcs_auto_greet")
    if auto_greet ~= nil then
        wetlands_npcs.config.auto_greet.enabled = auto_greet
    end

    -- Debug mode
    local debug = minetest.settings:get_bool("wetlands_npcs_debug")
    if debug ~= nil then
        wetlands_npcs.config.debug.enabled = debug
    end

    minetest.log("action", "[wetlands_npcs] Configuration reloaded from minetest.conf")
end

-- ============================================================================
-- SECCIÓN 9: VALIDACIÓN DE CONFIGURACIÓN
-- ============================================================================

--[[
    FUNCIÓN: validate()

    Valida que todos los valores de configuración sean coherentes.
    Previene crashes por valores inválidos.

    RETORNA: true si válido, false + mensaje de error si inválido
--]]
function wetlands_npcs.config.validate()
    local errors = {}

    -- Validar pesos de comportamiento suman aproximadamente 100
    for profession, weights in pairs(wetlands_npcs.config.behavior_weights) do
        local total = 0
        for state, weight in pairs(weights) do
            total = total + weight
        end

        if total < 80 or total > 120 then
            table.insert(errors, "Behavior weights for " .. profession .. " sum to " .. total .. " (should be ~100)")
        end
    end

    -- Validar radios son positivos
    if wetlands_npcs.config.poi_search_radius <= 0 then
        table.insert(errors, "poi_search_radius must be positive")
    end

    if wetlands_npcs.config.auto_greet.detection_radius <= 0 then
        table.insert(errors, "auto_greet.detection_radius must be positive")
    end

    -- Validar horarios están en rango 0.0-1.0
    if wetlands_npcs.config.schedule.sleep_start < 0 or wetlands_npcs.config.schedule.sleep_start > 1 then
        table.insert(errors, "schedule.sleep_start must be between 0.0 and 1.0")
    end

    if #errors > 0 then
        return false, table.concat(errors, "\n")
    end

    return true
end

-- ============================================================================
-- INICIALIZACIÓN
-- ============================================================================

-- Recargar configuración desde minetest.conf al cargar el mod
wetlands_npcs.config.reload_from_conf()

-- Validar configuración
local valid, error_msg = wetlands_npcs.config.validate()
if not valid then
    minetest.log("error", "[wetlands_npcs] Invalid configuration:\n" .. error_msg)
else
    minetest.log("action", "[wetlands_npcs] Configuration loaded and validated successfully")
end

-- ============================================================================
-- COMANDO DE ADMIN: /villager_config
-- ============================================================================

minetest.register_chatcommand("villager_config", {
    params = "[get|set] <parameter> [value]",
    description = "Configurar sistema de comportamientos AI en runtime",
    privs = {server = true},
    func = function(name, param)
        local args = string.split(param, " ")
        local action = args[1]

        if action == "get" then
            local key = args[2]
            if not key then
                return false, "Uso: /villager_config get <parameter>"
            end

            local value = wetlands_npcs.config.get(key)
            if value == nil then
                return false, "Parameter not found: " .. key
            end

            return true, key .. " = " .. tostring(value)

        elseif action == "set" then
            local key = args[2]
            local value = args[3]

            if not key or not value then
                return false, "Uso: /villager_config set <parameter> <value>"
            end

            -- Intentar convertir a número si es posible
            local numeric_value = tonumber(value)
            if numeric_value then
                value = numeric_value
            elseif value == "true" then
                value = true
            elseif value == "false" then
                value = false
            end

            wetlands_npcs.config.set(key, value)
            return true, "✅ " .. key .. " = " .. tostring(value)

        elseif action == "reload" then
            wetlands_npcs.config.reload_from_conf()
            return true, "✅ Configuration reloaded from minetest.conf"

        else
            return false, "Uso: /villager_config [get|set|reload] <parameter> [value]"
        end
    end,
})

-- ============================================================================
-- FIN DE config.lua
-- ============================================================================
