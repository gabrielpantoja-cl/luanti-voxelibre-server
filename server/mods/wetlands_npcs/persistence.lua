-- ============================================================================
-- persistence.lua - Sistema de persistencia con ModStorage
-- ============================================================================
-- Guarda estado de NPCs y progreso de jugadores en la base de datos del mundo

local storage = minetest.get_mod_storage()

wetlands_npcs.persistence = {}

-- ============================================================================
-- UTILIDADES DE SERIALIZACIÓN
-- ============================================================================

local function save_data(key, data)
    storage:set_string(key, minetest.serialize(data))
end

local function load_data(key)
    local raw = storage:get_string(key)
    if raw and raw ~= "" then
        return minetest.deserialize(raw)
    end
    return nil
end

-- ============================================================================
-- ESTADO DE NPCs
-- ============================================================================

-- Generar ID unico para un NPC basado en tipo y posicion de spawn
function wetlands_npcs.persistence.make_npc_id(npc_type, pos)
    if not pos then return npc_type .. "_unknown" end
    return string.format("%s_%d_%d_%d", npc_type,
        math.floor(pos.x), math.floor(pos.y), math.floor(pos.z))
end

-- Estado por defecto de un NPC
local function default_npc_state(npc_type, pos)
    return {
        npc_type = npc_type,
        spawn_pos = pos and {x = pos.x, y = pos.y, z = pos.z} or nil,
        -- Estado emocional
        mood = "happy",
        mood_score = 75,  -- 0-100
        -- Memoria social
        known_players = {},
        -- Timestamps
        last_active = os.time(),
        created_at = os.time(),
    }
end

function wetlands_npcs.persistence.save_npc(npc_id, state)
    state.last_active = os.time()
    save_data("npc_" .. npc_id, state)
end

function wetlands_npcs.persistence.load_npc(npc_id)
    return load_data("npc_" .. npc_id)
end

-- Actualizar mood del NPC
function wetlands_npcs.persistence.update_mood(npc_id, delta)
    local state = wetlands_npcs.persistence.load_npc(npc_id)
    if not state then return end
    state.mood_score = math.max(0, math.min(100, state.mood_score + delta))
    -- Derivar mood textual del score
    if state.mood_score >= 80 then
        state.mood = "happy"
    elseif state.mood_score >= 60 then
        state.mood = "neutral"
    elseif state.mood_score >= 40 then
        state.mood = "sad"
    else
        state.mood = "tired"
    end
    wetlands_npcs.persistence.save_npc(npc_id, state)
    return state
end

-- Registrar interaccion de jugador con NPC
function wetlands_npcs.persistence.record_interaction(npc_id, player_name)
    local state = wetlands_npcs.persistence.load_npc(npc_id)
    if not state then return end

    if not state.known_players[player_name] then
        state.known_players[player_name] = {
            first_met = os.time(),
            times_talked = 0,
            trades_done = 0,
            quests_completed = 0,
        }
    end

    state.known_players[player_name].times_talked =
        (state.known_players[player_name].times_talked or 0) + 1

    -- Hablar con el NPC sube su mood
    state.mood_score = math.min(100, state.mood_score + 3)
    if state.mood_score >= 80 then state.mood = "happy" end

    wetlands_npcs.persistence.save_npc(npc_id, state)
    return state
end

-- Inicializar o cargar estado de NPC
function wetlands_npcs.persistence.init_npc(npc_type, pos)
    local npc_id = wetlands_npcs.persistence.make_npc_id(npc_type, pos)
    local state = wetlands_npcs.persistence.load_npc(npc_id)
    if not state then
        state = default_npc_state(npc_type, pos)
        wetlands_npcs.persistence.save_npc(npc_id, state)
    end
    return npc_id, state
end

-- ============================================================================
-- PROGRESO DEL JUGADOR
-- ============================================================================

local function default_player_data()
    return {
        -- Misiones
        active_quests = {},
        completed_quests = {},
        side_quest_cooldowns = {},
        -- Relaciones con NPCs
        npc_relationships = {},
        -- Logros
        achievements = {},
        -- Estadisticas
        stats = {
            total_quests_completed = 0,
            total_trades = 0,
            total_npcs_met = 0,
            total_unique_items = 0,
        },
        -- Timestamp
        first_join = os.time(),
        last_seen = os.time(),
    }
end

function wetlands_npcs.persistence.save_player(player_name, data)
    data.last_seen = os.time()
    save_data("player_" .. player_name, data)
end

function wetlands_npcs.persistence.load_player(player_name)
    local data = load_data("player_" .. player_name)
    if not data then
        data = default_player_data()
        wetlands_npcs.persistence.save_player(player_name, data)
    end
    return data
end

-- Obtener nivel de amistad con un NPC
function wetlands_npcs.persistence.get_friendship(player_name, npc_type)
    local data = wetlands_npcs.persistence.load_player(player_name)
    local rel = data.npc_relationships[npc_type]
    if not rel then return 0 end
    return rel.friendship_level or 0
end

-- Actualizar relacion con NPC (cada interaccion)
function wetlands_npcs.persistence.update_relationship(player_name, npc_type, interaction_type)
    local data = wetlands_npcs.persistence.load_player(player_name)

    if not data.npc_relationships[npc_type] then
        data.npc_relationships[npc_type] = {
            friendship_level = 0,
            friendship_xp = 0,
            total_talks = 0,
            total_trades = 0,
            quests_completed = 0,
            last_interaction = os.time(),
        }
        data.stats.total_npcs_met = data.stats.total_npcs_met + 1
        -- Logro: conocer NPCs
        if data.stats.total_npcs_met >= 9 then
            wetlands_npcs.persistence.grant_achievement(player_name, "all_npcs_met")
        end
    end

    local rel = data.npc_relationships[npc_type]
    rel.last_interaction = os.time()

    -- XP segun tipo de interaccion
    local xp_gains = {
        talk = 5,
        trade = 10,
        quest_complete = 25,
    }
    local xp = xp_gains[interaction_type] or 5

    if interaction_type == "talk" then
        rel.total_talks = rel.total_talks + 1
    elseif interaction_type == "trade" then
        rel.total_trades = rel.total_trades + 1
        data.stats.total_trades = data.stats.total_trades + 1
        if data.stats.total_trades == 1 then
            wetlands_npcs.persistence.grant_achievement(player_name, "first_trade")
        end
    elseif interaction_type == "quest_complete" then
        rel.quests_completed = rel.quests_completed + 1
    end

    rel.friendship_xp = rel.friendship_xp + xp

    -- Calcular nivel de amistad (0-5)
    -- Niveles: 0=desconocido, 1=conocido(50xp), 2=amigo(150xp),
    --          3=buen_amigo(350xp), 4=confidente(600xp), 5=mejor_amigo(1000xp)
    local thresholds = {50, 150, 350, 600, 1000}
    local new_level = 0
    for i, threshold in ipairs(thresholds) do
        if rel.friendship_xp >= threshold then
            new_level = i
        end
    end

    if new_level > rel.friendship_level then
        rel.friendship_level = new_level
    end

    wetlands_npcs.persistence.save_player(player_name, data)
    return rel
end

-- ============================================================================
-- LOGROS
-- ============================================================================

local ACHIEVEMENT_DEFS = {
    first_trade = {title = "Primer Intercambio", desc = "Completaste tu primer trade con un NPC"},
    quest_novice = {title = "Aprendiz de Aventuras", desc = "Completaste tu primera mision"},
    quest_veteran = {title = "Veterano", desc = "Completaste 10 misiones"},
    all_npcs_met = {title = "Sociable", desc = "Conociste a los 9 NPCs de Wetlands"},
    friend_max = {title = "Mejor Amigo", desc = "Alcanzaste nivel 5 de amistad con un NPC"},
    collector = {title = "Coleccionista", desc = "Obtuviste 5 items unicos"},
}

wetlands_npcs.persistence.achievement_defs = ACHIEVEMENT_DEFS

function wetlands_npcs.persistence.grant_achievement(player_name, achievement_id)
    local data = wetlands_npcs.persistence.load_player(player_name)
    if data.achievements[achievement_id] then return false end -- ya lo tiene

    data.achievements[achievement_id] = {
        earned_at = os.time(),
    }
    wetlands_npcs.persistence.save_player(player_name, data)

    -- Notificar al jugador
    local def = ACHIEVEMENT_DEFS[achievement_id]
    if def then
        local player = minetest.get_player_by_name(player_name)
        if player then
            minetest.chat_send_player(player_name,
                minetest.colorize("#FFD700", "[Logro Desbloqueado] " .. def.title .. " - " .. def.desc))
        end
    end

    return true
end

-- ============================================================================
-- DECAY DE MOOD (ejecutar periodicamente)
-- ============================================================================

local MOOD_DECAY_INTERVAL = 300  -- 5 minutos reales
local mood_decay_timer = 0

minetest.register_globalstep(function(dtime)
    mood_decay_timer = mood_decay_timer + dtime
    if mood_decay_timer < MOOD_DECAY_INTERVAL then return end
    mood_decay_timer = 0

    -- Decaer mood de NPCs que no han sido visitados
    -- Solo procesamos NPCs activos en el mundo
    for _, obj in pairs(minetest.object_refs) do
        local entity = obj:get_luaentity()
        if entity and entity.custom_villager_type and entity._npc_id then
            local state = wetlands_npcs.persistence.load_npc(entity._npc_id)
            if state then
                -- Decay lento: -1 por periodo si nadie habla con el NPC
                state.mood_score = math.max(30, state.mood_score - 1)
                if state.mood_score >= 80 then
                    state.mood = "happy"
                elseif state.mood_score >= 60 then
                    state.mood = "neutral"
                elseif state.mood_score >= 40 then
                    state.mood = "sad"
                else
                    state.mood = "tired"
                end
                wetlands_npcs.persistence.save_npc(entity._npc_id, state)
            end
        end
    end
end)

-- ============================================================================
-- GUARDAR AL SALIR JUGADOR
-- ============================================================================

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    local data = load_data("player_" .. name)
    if data then
        data.last_seen = os.time()
        save_data("player_" .. name, data)
    end
end)

minetest.log("action", "[wetlands_npcs] Persistence system loaded (ModStorage)")
