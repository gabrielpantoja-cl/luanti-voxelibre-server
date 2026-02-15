-- ============================================================================
-- ai_behaviors.lua - Sistema de Comportamientos AI Tradicional
-- ============================================================================
-- Mod: Wetlands NPCs v1.0.0
-- Propósito: Implementar máquina de estados finitos (FSM) para comportamientos
--            inteligentes de aldeanos sin usar LLM/Machine Learning
-- Autor: Wetlands Team
-- Documentación: README_AI_BEHAVIORS.md
-- ============================================================================

--[[
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║                    ARQUITECTURA DEL SISTEMA                           ║
    ╠═══════════════════════════════════════════════════════════════════════╣
    ║                                                                       ║
    ║  ┌─────────────────────────────────────────────────────────────┐    ║
    ║  │             MÁQUINA DE ESTADOS FINITOS (FSM)                │    ║
    ║  ├─────────────────────────────────────────────────────────────┤    ║
    ║  │                                                             │    ║
    ║  │   IDLE ──────► WANDER ──────► WORK ──────► SOCIAL          │    ║
    ║  │    │               │             │            │             │    ║
    ║  │    │               │             │            │             │    ║
    ║  │    └───────────────┴─────────────┴────────────┴──► SLEEP   │    ║
    ║  │                                                      │       │    ║
    ║  │                      ┌───────────────────────────────┘       │    ║
    ║  │                      │                                       │    ║
    ║  │                      └──► SEEK_PLAYER (opcional)            │    ║
    ║  │                                                             │    ║
    ║  └─────────────────────────────────────────────────────────────┘    ║
    ║                                                                       ║
    ║  CADA ALDEANO TIENE:                                                  ║
    ║  - Estado actual (state)                                              ║
    ║  - Timer interno (cuánto lleva en ese estado)                         ║
    ║  - Objetivo actual (target_pos, target_entity)                        ║
    ║  - Memoria de corto plazo (last_greeting, work_poi)                   ║
    ║                                                                       ║
    ║  ACTUALIZACIÓN:                                                       ║
    ║  - Se llama update() cada 0.5 segundos (configurable)                 ║
    ║  - Evalúa si debe cambiar de estado según pesos probabilísticos       ║
    ║  - Ejecuta comportamiento del estado actual                           ║
    ║                                                                       ║
    ╚═══════════════════════════════════════════════════════════════════════╝
--]]

-- Namespace del sistema de comportamientos
wetlands_npcs.behaviors = {}
wetlands_npcs.behaviors.version = "1.0.0"

-- ============================================================================
-- SECCIÓN 1: CONSTANTES Y ENUMERACIONES
-- ============================================================================

--[[
    ESTADOS DE LA MÁQUINA DE ESTADOS

    Cada estado representa un comportamiento macro del aldeano.
    Los estados son mutuamente excluyentes (solo uno activo a la vez).

    DISEÑO: Usamos strings en lugar de números para claridad en debugging
--]]
local STATES = {
    IDLE = "idle",              -- Parado, mirando alrededor ocasionalmente
    WANDER = "wander",          -- Caminando sin objetivo específico
    WORK = "work",              -- Trabajando (busca POI de su profesión)
    SOCIAL = "social",          -- Interactuando con otros NPCs
    SLEEP = "sleep",            -- Durmiendo (solo de noche)
    SEEK_PLAYER = "seek_player", -- Buscando jugador cercano (proactivo)
    FLEE = "flee",              -- Huyendo (reservado para futuras features)
}

--[[
    PRIORIDADES DE ESTADO

    Algunos estados tienen prioridad sobre otros.
    Por ejemplo, SLEEP siempre interrumpe cualquier otro estado si es de noche.

    PRIORIDADES (mayor = más prioritario):
    1. SLEEP (de noche, debe dormir)
    2. SEEK_PLAYER (si jugador muy cerca)
    3. WORK, SOCIAL, WANDER (normal)
    4. IDLE (por defecto, menos prioritario)
--]]
local STATE_PRIORITIES = {
    [STATES.SLEEP] = 100,
    [STATES.SEEK_PLAYER] = 80,
    [STATES.WORK] = 50,
    [STATES.SOCIAL] = 50,
    [STATES.WANDER] = 40,
    [STATES.IDLE] = 10,
}

-- ============================================================================
-- SECCIÓN 1B: HELPERS DE CONFIGURACION POR NPC
-- ============================================================================

-- Obtener radio maximo de wander para un NPC especifico
local function get_npc_max_radius(villager_type)
    local overrides = wetlands_npcs.config.movement_overrides
    if overrides and overrides[villager_type] then
        return overrides[villager_type].max_wander_radius
            or wetlands_npcs.config.movement.max_wander_radius
    end
    return wetlands_npcs.config.movement.max_wander_radius or 15
end

-- Obtener threshold de retorno a home para un NPC especifico
local function get_npc_return_threshold(villager_type)
    local overrides = wetlands_npcs.config.movement_overrides
    if overrides and overrides[villager_type] then
        return overrides[villager_type].return_home_threshold
            or wetlands_npcs.config.movement.return_home_threshold
    end
    return wetlands_npcs.config.movement.return_home_threshold or 20
end

-- Obtener radio de busqueda de POI para un NPC especifico
local function get_npc_poi_radius(villager_type)
    local overrides = wetlands_npcs.config.movement_overrides
    if overrides and overrides[villager_type] then
        return overrides[villager_type].poi_search_radius
            or wetlands_npcs.config.poi_search_radius
    end
    return wetlands_npcs.config.poi_search_radius or 15
end

-- Obtener radio de busqueda social para un NPC especifico
local function get_npc_social_radius(villager_type)
    local overrides = wetlands_npcs.config.movement_overrides
    if overrides and overrides[villager_type] then
        return overrides[villager_type].social_search_radius
            or wetlands_npcs.config.npc_interaction.detection_radius
    end
    return wetlands_npcs.config.npc_interaction.detection_radius or 10
end

-- ============================================================================
-- SECCIÓN 2: MEMORIA Y CONTEXTO DEL ALDEANO
-- ============================================================================

--[[
    Cada aldeano mantiene un "contexto" de memoria que persiste mientras existe.

    ESTRUCTURA:
    self.ai_state = string      -- Estado actual
    self.ai_timer = number      -- Segundos en estado actual
    self.ai_target = table      -- {pos=vector, entity=obj, type=string}
    self.ai_memory = table      -- Memoria de corto plazo

    self.ai_memory:
        last_greet_player = {player_name = timestamp}  -- Cooldown de saludos
        visited_poi = {pos_hash = true}                -- POIs ya visitados
        social_partner = entity                        -- NPC con quien interactúa
        home_pos = vector                              -- Posición "home"
--]]

--[[
    FUNCIÓN: init_ai_context(self)

    Inicializa el contexto AI de un aldeano recién spawneado.
    Se llama automáticamente la primera vez que update() se ejecuta.

    PARÁMETROS:
        self: Entidad del aldeano (luaentity)

    RETORNA: nada (modifica self directamente)
--]]
local function init_ai_context(self)
    if self.ai_initialized then return end

    self.ai_state = STATES.IDLE
    self.ai_timer = 0
    self.ai_target = nil
    self.ai_memory = {
        last_greet_player = {},  -- {player_name = os.time()}
        visited_poi = {},        -- {hash = true}
        social_partner = nil,
        home_pos = self.object:get_pos(),  -- Donde spawneó
        stuck_counter = 0,       -- Contador anti-stuck
        last_pos = nil,          -- Para detectar si está atascado
    }

    self.ai_initialized = true

    if wetlands_npcs.config.debug.log_state_changes then
        minetest.log("action", "[wetlands_npcs] AI context initialized for " ..
                     (self.custom_villager_type or "unknown"))
    end
end

-- ============================================================================
-- SECCIÓN 3: FUNCIONES HELPER DE UTILIDAD
-- ============================================================================

--[[
    FUNCIÓN: is_night_time()

    Determina si es de noche en el mundo.
    Usa el sistema de timeofday de Luanti (0.0 - 1.0).

    RETORNA: boolean (true si es hora de dormir)
--]]
local function is_night_time()
    local time = minetest.get_timeofday()
    local schedule = wetlands_npcs.config.schedule

    -- Lógica: Es noche si time > sleep_start O time < sleep_end
    -- Ejemplo: sleep_start=0.8, sleep_end=0.2
    -- Es noche si time > 0.8 (8pm-12am) O time < 0.2 (12am-5am)
    return time > schedule.sleep_start or time < schedule.sleep_end
end

--[[
    FUNCIÓN: get_nearest_player(pos, radius)

    Encuentra el jugador más cercano dentro de un radio.

    PARÁMETROS:
        pos: vector - Posición de búsqueda
        radius: number - Radio de búsqueda

    RETORNA: player object o nil si no hay jugadores
--]]
local function get_nearest_player(pos, radius)
    local nearest = nil
    local nearest_dist = radius

    local objects = minetest.get_objects_inside_radius(pos, radius)
    for _, obj in ipairs(objects) do
        if obj:is_player() then
            local player_pos = obj:get_pos()
            local dist = vector.distance(pos, player_pos)

            if dist < nearest_dist then
                nearest = obj
                nearest_dist = dist
            end
        end
    end

    return nearest
end

--[[
    FUNCIÓN: get_nearest_villager(pos, radius, exclude_self)

    Encuentra otro aldeano cercano (para interacción social).

    PARÁMETROS:
        pos: vector - Posición de búsqueda
        radius: number - Radio de búsqueda
        exclude_self: luaentity - Entidad a excluir (usualmente self)

    RETORNA: luaentity de otro aldeano o nil
--]]
local function get_nearest_villager(pos, radius, exclude_self)
    local nearest = nil
    local nearest_dist = radius

    local objects = minetest.get_objects_inside_radius(pos, radius)
    for _, obj in ipairs(objects) do
        local entity = obj:get_luaentity()

        if entity and entity.custom_villager_type and entity ~= exclude_self then
            local entity_pos = obj:get_pos()
            local dist = vector.distance(pos, entity_pos)

            if dist < nearest_dist then
                nearest = entity
                nearest_dist = dist
            end
        end
    end

    return nearest
end

--[[
    FUNCIÓN: find_poi_nearby(pos, poi_list, radius)

    Busca puntos de interés (POI) cercanos según la profesión.

    ALGORITMO:
    1. Itera en un cubo de radio especificado
    2. Optimización: Busca en espiral para encontrar más rápido
    3. Verifica si el nodo es un POI válido
    4. Retorna la primera coincidencia

    PARÁMETROS:
        pos: vector - Posición central de búsqueda
        poi_list: table - Lista de node names que son POI
        radius: number - Radio de búsqueda

    RETORNA: vector de posición del POI o nil
--]]
local function find_poi_nearby(pos, poi_list, radius)
    -- Búsqueda en espiral (más eficiente que iterar todo el cubo)
    -- Prioriza bloques cercanos antes que lejanos

    for distance = 1, radius do
        for dx = -distance, distance do
            for dz = -distance, distance do
                for dy = -3, 3 do  -- Limitar búsqueda vertical
                    local check_pos = vector.add(pos, {x=dx, y=dy, z=dz})
                    local node = minetest.get_node(check_pos)

                    -- Verificar si el nodo está en la lista de POI
                    for _, poi_name in ipairs(poi_list) do
                        if node.name == poi_name then
                            return check_pos
                        end
                    end
                end
            end
        end
    end

    return nil  -- No se encontró POI
end

--[[
    FUNCIÓN: find_nearest_bed(pos, radius)

    Busca la cama más cercana para dormir.

    PARÁMETROS:
        pos: vector - Posición de búsqueda
        radius: number - Radio de búsqueda

    RETORNA: vector de posición de la cama o nil

    NOTA: VoxeLibre tiene diferentes tipos de camas (mcl_beds:bed_*)
--]]
local function find_nearest_bed(pos, radius)
    -- Lista de nodos de cama en VoxeLibre
    local bed_nodes = {
        "mcl_beds:bed_red_bottom",
        "mcl_beds:bed_blue_bottom",
        "mcl_beds:bed_cyan_bottom",
        "mcl_beds:bed_grey_bottom",
        "mcl_beds:bed_silver_bottom",
        "mcl_beds:bed_black_bottom",
        "mcl_beds:bed_yellow_bottom",
        "mcl_beds:bed_green_bottom",
        "mcl_beds:bed_magenta_bottom",
        "mcl_beds:bed_orange_bottom",
        "mcl_beds:bed_purple_bottom",
        "mcl_beds:bed_brown_bottom",
        "mcl_beds:bed_pink_bottom",
        "mcl_beds:bed_lime_bottom",
        "mcl_beds:bed_light_blue_bottom",
        "mcl_beds:bed_white_bottom",
    }

    return find_poi_nearby(pos, bed_nodes, radius)
end

--[[
    FUNCIÓN: is_stuck(self)

    Detecta si el aldeano está atascado (no se mueve durante mucho tiempo).
    Útil para reiniciar pathfinding o cambiar de estado.

    RETORNA: boolean (true si está atascado)
--]]
local function is_stuck(self)
    local current_pos = self.object:get_pos()

    if not self.ai_memory.last_pos then
        self.ai_memory.last_pos = current_pos
        self.ai_memory.stuck_counter = 0
        return false
    end

    local dist = vector.distance(current_pos, self.ai_memory.last_pos)

    if dist < 0.5 then  -- Se movió menos de 0.5 bloques
        self.ai_memory.stuck_counter = self.ai_memory.stuck_counter + 1
    else
        self.ai_memory.stuck_counter = 0
    end

    self.ai_memory.last_pos = current_pos

    -- Si lleva más de 10 ticks sin moverse, está atascado
    return self.ai_memory.stuck_counter > 10
end

-- ============================================================================
-- SECCIÓN 4: SELECCIÓN DE ESTADO (FSM Logic)
-- ============================================================================

--[[
    FUNCIÓN: choose_next_state(self, villager_type)

    Elige el próximo estado basado en pesos probabilísticos.

    ALGORITMO:
    1. Obtener pesos de comportamiento para esta profesión
    2. Calcular peso total
    3. Generar número aleatorio
    4. Seleccionar estado según probabilidad acumulativa

    EJEMPLO:
        farmer = {idle=20, wander=30, work=40, social=10}
        Total = 100
        Random(1-100):
            1-20  → IDLE
            21-50 → WANDER
            51-90 → WORK
            91-100 → SOCIAL

    PARÁMETROS:
        self: Entidad del aldeano
        villager_type: string (farmer, librarian, etc.)

    RETORNA: string - nuevo estado
--]]
local function choose_next_state(self, villager_type)
    local weights = wetlands_npcs.config.behavior_weights[villager_type]

    if not weights then
        -- Fallback a farmer si no existe la profesión
        weights = wetlands_npcs.config.behavior_weights.farmer
    end

    -- Calcular peso total
    local total_weight = 0
    for _, weight in pairs(weights) do
        total_weight = total_weight + weight
    end

    -- Generar número aleatorio
    local random_value = math.random(1, total_weight)
    local cumulative = 0

    -- Seleccionar estado según acumulación
    for state_name, weight in pairs(weights) do
        cumulative = cumulative + weight
        if random_value <= cumulative then
            return state_name
        end
    end

    -- Fallback (no debería llegar aquí)
    return STATES.IDLE
end

--[[
    FUNCIÓN: should_override_state(self, current_state)

    Verifica si un estado de alta prioridad debe interrumpir el estado actual.

    CASOS DE OVERRIDE:
    1. Es de noche → forzar SLEEP
    2. Jugador muy cerca → forzar SEEK_PLAYER (opcional)
    3. Aldeano está atascado → cambiar a WANDER

    RETORNA: string (nuevo estado) o nil (mantener actual)
--]]
local function should_override_state(self, current_state)
    -- PRIORIDAD 1: Dormir de noche
    if is_night_time() and current_state ~= STATES.SLEEP then
        return STATES.SLEEP
    end

    -- PRIORIDAD 2: Despertar de día
    if not is_night_time() and current_state == STATES.SLEEP then
        return STATES.IDLE
    end

    -- PRIORIDAD 3: Detectar jugador muy cerca (opcional)
    if wetlands_npcs.config.auto_greet.enabled then
        local pos = self.object:get_pos()
        local radius = wetlands_npcs.config.auto_greet.detection_radius
        local player = get_nearest_player(pos, radius)

        if player and current_state ~= STATES.SEEK_PLAYER then
            -- Verificar cooldown de saludo
            local player_name = player:get_player_name()
            local last_greet = self.ai_memory.last_greet_player[player_name] or 0
            local cooldown = wetlands_npcs.config.auto_greet.cooldown_seconds

            if os.time() - last_greet > cooldown then
                -- Probabilidad de buscar al jugador
                if math.random(1, 100) <= wetlands_npcs.config.auto_greet.greeting_chance then
                    return STATES.SEEK_PLAYER
                end
            end
        end
    end

    -- PRIORIDAD 4: Home tether - forzar WANDER (que ahora respeta home_pos)
    if self.ai_memory and self.ai_memory.home_pos then
        local pos = self.object:get_pos()
        local home = self.ai_memory.home_pos
        local villager_type = self.custom_villager_type or "farmer"
        local return_threshold = get_npc_return_threshold(villager_type)
        local dist_from_home = vector.distance(pos, home)

        if dist_from_home > return_threshold and current_state ~= STATES.WANDER then
            return STATES.WANDER  -- do_wander se encarga de volver a home
        end
    end

    -- PRIORIDAD 5: Anti-stuck (cambiar a WANDER si atascado)
    -- NO aplicar a NPCs en IDLE (estar quieto es intencional, no estar atascado)
    if current_state ~= STATES.IDLE and current_state ~= STATES.WANDER then
        if is_stuck(self) then
            return STATES.WANDER
        end
    end

    return nil  -- No hay override necesario
end

-- ============================================================================
-- SECCIÓN 5: IMPLEMENTACIÓN DE COMPORTAMIENTOS POR ESTADO
-- ============================================================================

--[[
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║                     COMPORTAMIENTOS POR ESTADO                        ║
    ╠═══════════════════════════════════════════════════════════════════════╣
    ║                                                                       ║
    ║  Cada función do_*() implementa el comportamiento de un estado.      ║
    ║  Son llamadas cada tick (0.5s) mientras el aldeano esté en ese       ║
    ║  estado.                                                              ║
    ║                                                                       ║
    ║  CONVENCIÓN:                                                          ║
    ║  - Modifican self.object (movimiento, animación)                      ║
    ║  - Pueden actualizar self.ai_target                                   ║
    ║  - No cambian self.ai_state (eso lo hace update())                    ║
    ║                                                                       ║
    ╚═══════════════════════════════════════════════════════════════════════╝
--]]

--[[
    COMPORTAMIENTO: IDLE (Parado, mirando alrededor)

    DESCRIPCIÓN:
    El aldeano se queda quieto, pero ocasionalmente gira la cabeza para
    mirar alrededor. Es un estado de "descanso" de bajo consumo de CPU.

    ACCIONES:
    - Detener movimiento (velocity = 0)
    - Cada X ticks, rotar yaw aleatoriamente
    - Mostrar animación de idle (si existe)
--]]
local function do_idle(self)
    -- Detener movimiento horizontal, preservar velocidad Y (gravedad)
    local vel = self.object:get_velocity()
    if vel then
        self.object:set_velocity({x=0, y=vel.y, z=0})
    end

    local pos = self.object:get_pos()
    if not pos then return end
    if not self.ai_memory then return end

    local villager_type = self.custom_villager_type or "farmer"

    -- === SISTEMA DE GESTOS ===
    -- Si hay un gesto activo, mantener la animacion y no interrumpir
    if self.ai_memory._gesture_timer and self.ai_memory._gesture_timer > 0 then
        self.ai_memory._gesture_timer = self.ai_memory._gesture_timer - 0.5

        -- Mantener animacion del gesto cada tick (sobreescribe mcl_mobs)
        local g = self.ai_memory._gesture_data
        if g then
            self.object:set_animation(g.frames, g.speed, 0, true)
        end

        -- Seguir mirando al jugador durante el gesto
        local player = get_nearest_player(pos, 10)
        if player then
            local player_pos = player:get_pos()
            local dir = vector.subtract(player_pos, pos)
            local target_yaw = math.atan2(dir.z, dir.x) - math.pi / 2
            self.object:set_yaw(target_yaw)
        end

        -- Cuando termina el gesto, volver a animacion stand
        if self.ai_memory._gesture_timer <= 0 then
            self.ai_memory._gesture_timer = nil
            self.ai_memory._gesture_data = nil
            self.object:set_animation({x=0, y=79}, 30, 0, true)
        end
        return
    end

    -- Decrementar cooldown de gestos
    if self.ai_memory._gesture_cooldown and self.ai_memory._gesture_cooldown > 0 then
        self.ai_memory._gesture_cooldown = self.ai_memory._gesture_cooldown - 0.5
    end

    -- === DETECCION DE JUGADOR Y ORIENTACION ===
    local player = get_nearest_player(pos, 8)

    if player then
        -- Hay jugador cerca: girar hacia el suavemente
        local player_pos = player:get_pos()
        local dir = vector.subtract(player_pos, pos)
        local target_yaw = math.atan2(dir.z, dir.x) - math.pi / 2
        local current_yaw = self.object:get_yaw() or 0

        -- Interpolacion suave
        local diff = target_yaw - current_yaw
        while diff > math.pi do diff = diff - 2 * math.pi end
        while diff < -math.pi do diff = diff + 2 * math.pi end
        local new_yaw = current_yaw + diff * 0.3
        self.object:set_yaw(new_yaw)

        -- === LANZAR GESTO SI CORRESPONDE ===
        local gesture_config = wetlands_npcs.config.idle_gestures
            and wetlands_npcs.config.idle_gestures[villager_type]

        if gesture_config and gesture_config.enabled then
            local cooldown = self.ai_memory._gesture_cooldown or 0
            if cooldown <= 0 and math.random(1, 15) == 1 then
                -- Elegir gesto aleatorio
                local gestures = gesture_config.gestures
                local g = gestures[math.random(1, #gestures)]

                -- Activar gesto
                self.ai_memory._gesture_timer = g.duration
                self.ai_memory._gesture_data = g
                self.ai_memory._gesture_cooldown = gesture_config.cooldown
                self.object:set_animation(g.frames, g.speed, 0, true)
            end
        end
    else
        -- No hay jugador: mirar alrededor ocasionalmente (10% cada tick)
        if math.random(1, 10) == 1 then
            local yaw = math.random() * math.pi * 2
            self.object:set_yaw(yaw)
        end
    end
end

--[[
    COMPORTAMIENTO: WANDER (Caminar aleatorio)

    DESCRIPCIÓN:
    El aldeano camina hacia posiciones aleatorias cercanas.
    No tiene un objetivo específico, solo explora su entorno.

    ALGORITMO:
    1. Cada N ticks, elegir nueva posición aleatoria
    2. Usar mcl_mobs:gopath() para navegar
    3. Posición aleatoria en radio de 10 bloques

    PARÁMETROS CONFIGURABLES:
    - Frecuencia de cambio de objetivo (cada 20 ticks = 10 seg)
    - Radio de exploración (10 bloques)
--]]
local function do_wander(self)
    -- Cambiar direccion cada 20 ticks (~10 segundos)
    if not self.ai_target or math.random(1, 20) == 1 then
        local pos = self.object:get_pos()
        local home = self.ai_memory and self.ai_memory.home_pos
        local villager_type = self.custom_villager_type or "farmer"
        local max_radius = get_npc_max_radius(villager_type)

        -- Si no tiene home_pos, usar posicion actual como home
        if not home then
            home = pos
            if self.ai_memory then
                self.ai_memory.home_pos = {x = pos.x, y = pos.y, z = pos.z}
            end
        end

        -- Verificar si esta demasiado lejos de home -> forzar retorno
        local dist_from_home = vector.distance(pos, home)
        local return_threshold = get_npc_return_threshold(villager_type)

        local target
        if dist_from_home > return_threshold then
            -- Demasiado lejos, volver hacia home
            local jitter = math.min(3, max_radius)
            target = {
                x = home.x + math.random(-jitter, jitter),
                y = home.y,
                z = home.z + math.random(-jitter, jitter),
            }
        else
            -- Generar posicion aleatoria DENTRO del radio permitido desde home
            local wander_range = math.min(10, max_radius)
            local offset_x = math.random(-wander_range, wander_range)
            local offset_z = math.random(-wander_range, wander_range)
            target = {
                x = home.x + offset_x,
                y = pos.y,
                z = home.z + offset_z,
            }

            -- Clamp al radio maximo desde home
            local target_dist = math.sqrt(offset_x^2 + offset_z^2)
            if target_dist > max_radius then
                local scale = max_radius / target_dist
                target.x = home.x + offset_x * scale
                target.z = home.z + offset_z * scale
            end
        end

        self.ai_target = {pos = target, type = "wander"}
    end

    -- Mover hacia el objetivo directamente (no depende de walk_chance de mcl_mobs)
    if self.ai_target and self.ai_target.pos then
        local pos = self.object:get_pos()
        if not pos then return end

        local target = self.ai_target.pos
        local dist = vector.distance(pos, target)

        if dist < 1 then
            -- Llego al objetivo, detenerse
            local vel = self.object:get_velocity()
            self.object:set_velocity({x=0, y=vel and vel.y or 0, z=0})
            self.ai_target = nil
        else
            -- Caminar hacia el objetivo: calcular direccion y aplicar velocidad
            local dir = vector.subtract(target, pos)
            dir.y = 0  -- Solo movimiento horizontal
            local len = math.sqrt(dir.x^2 + dir.z^2)
            if len > 0 then
                local speed = wetlands_npcs.config.movement.walk_velocity or 1.2
                local vel = self.object:get_velocity()
                self.object:set_velocity({
                    x = (dir.x / len) * speed,
                    y = vel and vel.y or 0,
                    z = (dir.z / len) * speed,
                })
                -- Orientar hacia el objetivo
                local yaw = math.atan2(dir.z, dir.x) - math.pi / 2
                self.object:set_yaw(yaw)
                -- Animacion de caminar
                self.object:set_animation({x=168, y=187}, 30, 0, true)
            end
        end
    end
end

--[[
    COMPORTAMIENTO: WORK (Trabajar según profesión)

    DESCRIPCIÓN:
    El aldeano busca puntos de interés (POI) relacionados con su profesión
    y se mueve hacia ellos. Simula que está "trabajando".

    EJEMPLOS:
    - Farmer: Busca cultivos (wheat, carrots) y camina hacia ellos
    - Librarian: Busca estanterías y se queda cerca
    - Explorer: Busca árboles y flores

    ALGORITMO:
    1. Si no tiene POI objetivo, buscar uno cercano
    2. Navegar hacia el POI
    3. Al llegar, "interactuar" (mostrar partículas)
    4. Después de X tiempo, buscar nuevo POI
--]]
local function do_work(self, villager_type, pos)
    -- Obtener lista de POI para esta profesión
    local poi_list = wetlands_npcs.config.poi_types[villager_type]

    if not poi_list then
        -- Si no hay POI definidos, volver a wander
        self.ai_state = STATES.WANDER
        return
    end

    -- Si no tiene objetivo de trabajo, buscar uno
    if not self.ai_target or self.ai_target.type ~= "work" then
        local radius = get_npc_poi_radius(villager_type)
        local poi_pos = find_poi_nearby(pos, poi_list, radius)

        -- Verificar que el POI no este fuera del radio de wander desde home
        if poi_pos and self.ai_memory and self.ai_memory.home_pos then
            local max_radius = get_npc_max_radius(villager_type)
            local dist_from_home = vector.distance(poi_pos, self.ai_memory.home_pos)
            if dist_from_home > max_radius then
                poi_pos = nil  -- Descartar POI fuera de rango
            end
        end

        if poi_pos then
            self.ai_target = {pos = poi_pos, type = "work"}

            -- Navegar hacia el POI
            -- DEFENSIVE: Validar mcl_mobs antes de usar
            if mcl_mobs and type(mcl_mobs.gopath) == "function" then
                local success, err = pcall(function()
                    mcl_mobs:gopath(self, poi_pos)
                end)
                if not success and wetlands_npcs.config.debug.enabled then
                    minetest.log("warning", "[wetlands_npcs] gopath failed in work: " .. tostring(err))
                end
            end

            if wetlands_npcs.config.debug.log_pathfinding then
                minetest.log("action", "[wetlands_npcs] " .. villager_type ..
                           " found POI at " .. minetest.pos_to_string(poi_pos))
            end
        else
            -- No se encontró POI, volver a wander
            self.ai_state = STATES.WANDER
            return
        end
    end

    -- Verificar si llegó al POI
    if self.ai_target and self.ai_target.pos then
        local dist = vector.distance(pos, self.ai_target.pos)

        if dist < 2 then  -- Llegó (menos de 2 bloques)
            -- Mostrar partícula de trabajo
            if wetlands_npcs.config.particles.enabled then
                local particle_config = wetlands_npcs.config.particles.work_particle

                if math.random(1, 100) <= particle_config.spawn_chance then
                    minetest.add_particlespawner({
                        amount = particle_config.amount,
                        time = 1,
                        minpos = {x = pos.x, y = pos.y + 1.5, z = pos.z},
                        maxpos = {x = pos.x, y = pos.y + 2, z = pos.z},
                        minvel = {x = -0.1, y = 0.2, z = -0.1},
                        maxvel = {x = 0.1, y = 0.5, z = 0.1},
                        minacc = {x = 0, y = 0, z = 0},
                        maxacc = {x = 0, y = 0, z = 0},
                        minexptime = 1,
                        maxexptime = 2,
                        minsize = 1,
                        maxsize = 2,
                        texture = particle_config.texture,
                    })
                end
            end

            -- Después de trabajar un rato, buscar nuevo POI
            if math.random(1, 40) == 1 then  -- 2.5% cada tick = ~10 seg promedio
                self.ai_target = nil  -- Forzar búsqueda de nuevo POI
            end
        end
    end
end

--[[
    COMPORTAMIENTO: SOCIAL (Interactuar con otros NPCs)

    DESCRIPCIÓN:
    El aldeano busca otros aldeanos cercanos y "conversa" con ellos.
    Se visualiza mediante partículas de corazón y proximidad física.

    ALGORITMO:
    1. Buscar otro aldeano en radio de detección
    2. Navegar hacia él
    3. Al llegar cerca, detenerse y mirar hacia él
    4. Generar partículas ocasionalmente
    5. Después de X tiempo, cambiar de estado
--]]
local function do_social(self, pos)
    if not wetlands_npcs.config.npc_interaction.enabled then
        self.ai_state = STATES.WANDER
        return
    end

    local villager_type = self.custom_villager_type or "farmer"

    -- Si no tiene pareja social, buscar una
    if not self.ai_memory.social_partner then
        local radius = get_npc_social_radius(villager_type)
        local other_villager = get_nearest_villager(pos, radius, self)

        -- Verificar que ir hacia el otro NPC no nos saque del radio de home
        if other_villager and self.ai_memory and self.ai_memory.home_pos then
            local max_radius = get_npc_max_radius(villager_type)
            local other_pos = other_villager.object:get_pos()
            if other_pos then
                local dist_from_home = vector.distance(other_pos, self.ai_memory.home_pos)
                if dist_from_home > max_radius then
                    other_villager = nil  -- Descartar, esta fuera de rango
                end
            end
        end

        if other_villager then
            self.ai_memory.social_partner = other_villager
            local target_pos = other_villager.object:get_pos()

            -- Navegar hacia el otro aldeano
            -- DEFENSIVE: Validar mcl_mobs antes de usar
            if mcl_mobs and type(mcl_mobs.gopath) == "function" then
                local success, err = pcall(function()
                    mcl_mobs:gopath(self, target_pos)
                end)
                if not success and wetlands_npcs.config.debug.enabled then
                    minetest.log("warning", "[wetlands_npcs] gopath failed in social: " .. tostring(err))
                end
            end
        else
            -- No hay otros aldeanos, volver a wander
            self.ai_state = STATES.WANDER
            return
        end
    end

    -- Verificar si la pareja social aún existe
    if self.ai_memory.social_partner then
        local partner_obj = self.ai_memory.social_partner.object

        if not partner_obj or not partner_obj:get_pos() then
            -- La pareja desapareció, resetear
            self.ai_memory.social_partner = nil
            return
        end

        local partner_pos = partner_obj:get_pos()
        local dist = vector.distance(pos, partner_pos)

        if dist < 3 then  -- Cerca suficiente para "conversar"
            -- Detener movimiento y mirar al compañero
            self.object:set_velocity({x=0, y=0, z=0})

            -- Calcular dirección hacia el compañero
            local dir = vector.subtract(partner_pos, pos)
            local yaw = math.atan2(dir.z, dir.x) - math.pi/2
            self.object:set_yaw(yaw)

            -- Mostrar partícula de interacción social
            if wetlands_npcs.config.particles.enabled then
                local particle_config = wetlands_npcs.config.particles.social_particle

                if math.random(1, 100) <= particle_config.spawn_chance then
                    minetest.add_particlespawner({
                        amount = particle_config.amount,
                        time = 1,
                        minpos = {x = pos.x, y = pos.y + 1.5, z = pos.z},
                        maxpos = {x = pos.x, y = pos.y + 2, z = pos.z},
                        minvel = {x = -0.1, y = 0.2, z = -0.1},
                        maxvel = {x = 0.1, y = 0.5, z = 0.1},
                        minacc = {x = 0, y = 0, z = 0},
                        maxacc = {x = 0, y = 0, z = 0},
                        minexptime = 1,
                        maxexptime = 2,
                        minsize = 1,
                        maxsize = 2,
                        texture = particle_config.texture,
                    })
                end
            end
        else
            -- Demasiado lejos, navegar de nuevo
            -- DEFENSIVE: Validar mcl_mobs antes de usar
            if mcl_mobs and type(mcl_mobs.gopath) == "function" then
                local success, err = pcall(function()
                    mcl_mobs:gopath(self, partner_pos)
                end)
                if not success and wetlands_npcs.config.debug.enabled then
                    minetest.log("warning", "[wetlands_npcs] gopath failed in social (re-nav): " .. tostring(err))
                end
            end
        end
    end
end

--[[
    COMPORTAMIENTO: SLEEP (Dormir)

    DESCRIPCIÓN:
    El aldeano busca una cama cercana y "duerme" (se queda quieto).
    Solo activo durante la noche.

    ALGORITMO:
    1. Si no tiene cama objetivo, buscar una cercana
    2. Navegar hacia la cama
    3. Al llegar, detenerse y mostrar partículas de sueño
    4. Permanecer dormido hasta que amanezca
--]]
local function do_sleep(self, pos)
    -- Si tiene cama objetivo, ir hacia ella
    if not self.ai_target or self.ai_target.type ~= "sleep" then
        if wetlands_npcs.config.schedule.seek_bed_on_sleep then
            local radius = wetlands_npcs.config.schedule.bed_search_radius
            local bed_pos = find_nearest_bed(pos, radius)

            if bed_pos then
                self.ai_target = {pos = bed_pos, type = "sleep"}

                -- Navegar hacia la cama
                -- DEFENSIVE: Validar mcl_mobs antes de usar
                if mcl_mobs and type(mcl_mobs.gopath) == "function" then
                    local success, err = pcall(function()
                        mcl_mobs:gopath(self, bed_pos)
                    end)
                    if not success and wetlands_npcs.config.debug.enabled then
                        minetest.log("warning", "[wetlands_npcs] gopath failed in sleep: " .. tostring(err))
                    end
                end
            else
                -- No hay cama, dormir donde está
                self.object:set_velocity({x=0, y=0, z=0})
            end
        else
            -- No buscar cama, dormir donde está
            self.object:set_velocity({x=0, y=0, z=0})
        end
    else
        -- Verificar si llegó a la cama
        local dist = vector.distance(pos, self.ai_target.pos)

        if dist < 2 then
            -- Llegó a la cama, detenerse
            self.object:set_velocity({x=0, y=0, z=0})
        end
    end

    -- Mostrar partículas de sueño ocasionalmente
    if wetlands_npcs.config.particles.enabled then
        local particle_config = wetlands_npcs.config.particles.sleep_particle

        if math.random(1, 100) <= particle_config.spawn_chance then
            -- Usar bubble.png como fallback si zzz.png no existe
            local texture = particle_config.texture

            minetest.add_particlespawner({
                amount = particle_config.amount,
                time = 1,
                minpos = {x = pos.x, y = pos.y + 1.5, z = pos.z},
                maxpos = {x = pos.x, y = pos.y + 2, z = pos.z},
                minvel = {x = -0.1, y = 0.2, z = -0.1},
                maxvel = {x = 0.1, y = 0.5, z = 0.1},
                minacc = {x = 0, y = 0, z = 0},
                maxacc = {x = 0, y = 0, z = 0},
                minexptime = 1,
                maxexptime = 2,
                minsize = 1,
                maxsize = 2,
                texture = "bubble.png",  -- Fallback texture
            })
        end
    end
end

--[[
    COMPORTAMIENTO: SEEK_PLAYER (Buscar jugador)

    DESCRIPCIÓN:
    El aldeano detecta un jugador cercano y se acerca proactivamente
    para saludarlo. Comportamiento amigable y acogedor.

    ALGORITMO:
    1. Buscar jugador más cercano
    2. Navegar hacia él
    3. Al llegar cerca, saludar en chat
    4. Registrar saludo en cooldown
    5. Volver a estado anterior
--]]
local function do_seek_player(self, pos)
    local radius = wetlands_npcs.config.auto_greet.detection_radius * 2  -- Radio extendido
    local player = get_nearest_player(pos, radius)

    if not player then
        -- No hay jugador, volver a wander
        self.ai_state = STATES.WANDER
        return
    end

    local player_pos = player:get_pos()
    local dist = vector.distance(pos, player_pos)

    if dist > 3 then
        -- Navegar hacia el jugador
        -- DEFENSIVE: Validar mcl_mobs antes de usar
        if mcl_mobs and type(mcl_mobs.gopath) == "function" then
            local success, err = pcall(function()
                mcl_mobs:gopath(self, player_pos)
            end)
            if not success and wetlands_npcs.config.debug.enabled then
                minetest.log("warning", "[wetlands_npcs] gopath failed in seek_player: " .. tostring(err))
            end
        end
    else
        -- Llego cerca del jugador, saludar
        local player_name = player:get_player_name()
        local villager_type = self.custom_villager_type or "villager"

        -- Usar dialogos desde archivos separados (dialogues/*.lua)
        local greeting = wetlands_npcs.get_seek_greeting(villager_type, player_name)
        minetest.chat_send_player(player_name, greeting)

        -- Reproducir sonido de saludo (greeting) del NPC
        if wetlands_npcs.play_npc_greeting then
            wetlands_npcs.play_npc_greeting(villager_type, pos)
        end

        -- Registrar saludo en cooldown
        self.ai_memory.last_greet_player[player_name] = os.time()

        -- Volver a estado anterior (usualmente WANDER o IDLE)
        self.ai_state = STATES.IDLE
    end
end

-- ============================================================================
-- SECCIÓN 6: FUNCIÓN PRINCIPAL DE ACTUALIZACIÓN (Update Loop)
-- ============================================================================

--[[
    FUNCIÓN: wetlands_npcs.behaviors.update(self)

    Esta es la función principal que se llama cada tick (0.5 seg por defecto).
    Implementa el loop de la máquina de estados.

    FLUJO:
    1. Inicializar contexto AI si es primera vez
    2. Verificar overrides de prioridad (noche, jugador cerca, etc.)
    3. Incrementar timer de estado actual
    4. Evaluar si debe cambiar de estado
    5. Ejecutar comportamiento del estado actual

    PARÁMETROS:
        self: Entidad del aldeano (luaentity)

    RETORNA: nada (modifica self directamente)

    LLAMADA: Desde on_step() de cada aldeano (ver init.lua)
--]]
function wetlands_npcs.behaviors.update(self, dtime)
    -- PASO 1: Inicializar si es necesario
    init_ai_context(self)

    -- PASO 2: Obtener información básica
    local pos = self.object:get_pos()
    if not pos then return end  -- Aldeano no válido

    local villager_type = self.custom_villager_type or "farmer"

    -- PASO 3: Verificar overrides de alta prioridad
    local override_state = should_override_state(self, self.ai_state)
    if override_state then
        if override_state ~= self.ai_state then
            -- Cambio forzado de estado
            if wetlands_npcs.config.debug.log_state_changes then
                minetest.log("action", "[wetlands_npcs] " .. villager_type ..
                           " override: " .. self.ai_state .. " → " .. override_state)
            end

            self.ai_state = override_state
            self.ai_timer = 0
            self.ai_target = nil  -- Resetear objetivo
        end
    end

    -- PASO 4: Incrementar timer
    self.ai_timer = self.ai_timer + (dtime or 0.5)

    -- PASO 5: Evaluar cambio de estado normal (cada X segundos)
    local state_duration_min = wetlands_npcs.config.state_duration.min
    local state_duration_max = wetlands_npcs.config.state_duration.max
    local duration_threshold = math.random(state_duration_min, state_duration_max)

    if self.ai_timer > duration_threshold and not override_state then
        -- Es hora de evaluar cambio de estado
        local new_state = choose_next_state(self, villager_type)

        if new_state ~= self.ai_state then
            if wetlands_npcs.config.debug.log_state_changes then
                minetest.log("action", "[wetlands_npcs] " .. villager_type ..
                           " transition: " .. self.ai_state .. " → " .. new_state)
            end

            self.ai_state = new_state
            self.ai_timer = 0
            self.ai_target = nil  -- Resetear objetivo al cambiar de estado
        end
    end

    -- PASO 6: Ejecutar comportamiento del estado actual
    if self.ai_state == STATES.IDLE then
        do_idle(self)

    elseif self.ai_state == STATES.WANDER then
        do_wander(self)

    elseif self.ai_state == STATES.WORK then
        do_work(self, villager_type, pos)

    elseif self.ai_state == STATES.SOCIAL then
        do_social(self, pos)

    elseif self.ai_state == STATES.SLEEP then
        do_sleep(self, pos)

    elseif self.ai_state == STATES.SEEK_PLAYER then
        do_seek_player(self, pos)
    end

    -- PASO 7: Debug visual (opcional)
    if wetlands_npcs.config.debug.show_state_above then
        -- TODO: Implementar nametag con estado actual
        -- Requiere modificar el mob definition para agregar nametag dinámico
    end
end

-- ============================================================================
-- SECCIÓN 7: INTEGRACIÓN CON mcl_mobs
-- ============================================================================

--[[
    FUNCIÓN: wetlands_npcs.behaviors.inject_into_mob(mob_def)

    Modifica la definición de un mob para agregar el sistema de comportamientos AI.

    USO:
        local mob_def = {
            type = "npc",
            mesh = "villager.b3d",
            -- ... otras propiedades
        }

        wetlands_npcs.behaviors.inject_into_mob(mob_def)
        mcl_mobs.register_mob("mod:villager", mob_def)

    PARÁMETROS:
        mob_def: table - Definición del mob según mcl_mobs

    RETORNA: mob_def modificado (también modifica in-place)
--]]
function wetlands_npcs.behaviors.inject_into_mob(mob_def)
    -- Guardar on_step original si existe
    local original_on_step = mob_def.on_step

    -- Inyectar nuestro on_step
    mob_def.on_step = function(self, dtime)
        -- Llamar on_step original si existe
        if original_on_step then
            original_on_step(self, dtime)
        end

        -- Ejecutar sistema de comportamientos AI
        wetlands_npcs.behaviors.update(self, dtime)
    end

    return mob_def
end

-- ============================================================================
-- SECCIÓN 8: COMANDOS DE DEBUG Y TESTING
-- ============================================================================

--[[
    COMANDO: /villager_debug <on|off>

    Activa o desactiva el modo debug para ver estados de los aldeanos.
--]]
minetest.register_chatcommand("villager_debug", {
    params = "<on|off>",
    description = "Activar/desactivar debug de comportamientos AI",
    privs = {server = true},
    func = function(name, param)
        if param == "on" then
            wetlands_npcs.config.debug.enabled = true
            wetlands_npcs.config.debug.log_state_changes = true
            return true, "✅ Debug activado. Revisa la consola del servidor."
        elseif param == "off" then
            wetlands_npcs.config.debug.enabled = false
            wetlands_npcs.config.debug.log_state_changes = false
            return true, "✅ Debug desactivado."
        else
            return false, "Uso: /villager_debug <on|off>"
        end
    end,
})

--[[
    COMANDO: /villager_state <player_name>

    Muestra el estado actual de todos los aldeanos cercanos al jugador.
--]]
minetest.register_chatcommand("villager_state", {
    params = "",
    description = "Mostrar estados de aldeanos cercanos",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Jugador no encontrado"
        end

        local pos = player:get_pos()
        local villagers = minetest.get_objects_inside_radius(pos, 20)
        local count = 0
        local report = {"🤖 Estados de aldeanos cercanos:"}

        for _, obj in ipairs(villagers) do
            local entity = obj:get_luaentity()
            if entity and entity.custom_villager_type then
                count = count + 1
                local state = entity.ai_state or "unknown"
                local timer = math.floor(entity.ai_timer or 0)
                local type_name = entity.custom_villager_type

                table.insert(report, string.format("  %d. %s: %s (%ds)",
                    count, type_name, state, timer))
            end
        end

        if count == 0 then
            return true, "No hay aldeanos cercanos (radio 20 bloques)"
        end

        return true, table.concat(report, "\n")
    end,
})

-- ============================================================================
-- FINALIZACIÓN
-- ============================================================================

minetest.log("action", "[wetlands_npcs] AI Behaviors system v" ..
             wetlands_npcs.behaviors.version .. " loaded successfully")

-- ============================================================================
-- FIN DE ai_behaviors.lua
-- ============================================================================
