-- Wetlands NPCs v2.0.0 - Star Wars Edition
-- NPCs interactivos con misiones, persistencia y sistema de amistad
-- Para servidor educativo Wetlands (7+ anios)
-- Compatible con VoxeLibre v0.90.1 (mcl_mobs)

-- ============================================================================
-- 1. INICIALIZACION Y VERIFICACION
-- ============================================================================

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

-- Verificar dependencias criticas
if not minetest.get_modpath("mcl_mobs") then
    minetest.log("error", "[" .. modname .. "] mcl_mobs es requerido!")
    return
end

if not minetest.get_modpath("mcl_core") then
    minetest.log("error", "[" .. modname .. "] mcl_core es requerido!")
    return
end

if not mcl_mobs.register_mob then
    minetest.log("error", "[" .. modname .. "] mcl_mobs.register_mob no disponible!")
    return
end

-- Namespace global
wetlands_npcs = {}
wetlands_npcs.version = "2.0.0"

local function log(level, message)
    minetest.log(level, "[" .. modname .. "] " .. message)
end

log("info", "Initializing Wetlands NPCs v" .. wetlands_npcs.version)

-- ============================================================================
-- 2. SISTEMA DE SONIDO (debe cargarse ANTES de otros modulos)
-- ============================================================================

function wetlands_npcs.play_npc_voice(npc_type, pos)
    local sound_config = wetlands_npcs.config and wetlands_npcs.config.sounds
    if sound_config and not sound_config.enabled then return end

    local variant = math.random(1, 3)
    local sound_name = "wetlands_npc_talk_" .. npc_type .. variant
    local gain = (sound_config and sound_config.gain) or 0.8
    local max_dist = (sound_config and sound_config.max_hear_distance) or 20

    minetest.sound_play(sound_name, {
        pos = pos, gain = gain, max_hear_distance = max_dist,
    })
end

local STAR_WARS_NPCS = {
    luke = true, anakin = true, yoda = true, mandalorian = true, leia = true,
}
wetlands_npcs.STAR_WARS_NPCS = STAR_WARS_NPCS

function wetlands_npcs.play_npc_iconic(npc_type, pos)
    if not STAR_WARS_NPCS[npc_type] then return end
    local sound_config = wetlands_npcs.config and wetlands_npcs.config.sounds
    if sound_config and not sound_config.enabled then return end

    local gain = (sound_config and sound_config.gain) or 0.8
    local max_dist = (sound_config and sound_config.max_hear_distance) or 20

    minetest.sound_play("wetlands_npc_iconic_" .. npc_type, {
        pos = pos, gain = gain, max_hear_distance = max_dist,
    })
end

function wetlands_npcs.play_npc_greeting(npc_type, pos)
    local sound_config = wetlands_npcs.config and wetlands_npcs.config.sounds
    if sound_config and not sound_config.enabled then return end

    local variant = math.random(1, 2)
    local gain = (sound_config and sound_config.gain) or 0.8
    local max_dist = (sound_config and sound_config.max_hear_distance) or 20

    minetest.sound_play("wetlands_npc_greet_" .. npc_type .. variant, {
        pos = pos, gain = gain, max_hear_distance = max_dist,
    })
end

-- ============================================================================
-- 3. NOMBRES DE DISPLAY
-- ============================================================================

wetlands_npcs.display_names = {
    luke = "Luke Skywalker",
    anakin = "Anakin Skywalker",
    yoda = "Baby Yoda",
    mandalorian = "Mandalorian",
    leia = "Princess Leia",
    farmer = "Agricultor",
    librarian = "Bibliotecario",
    teacher = "Maestro",
    explorer = "Explorador",
}

-- ============================================================================
-- 4. SISTEMA DE COMERCIO
-- ============================================================================

wetlands_npcs.trades = {
    luke = {
        {give = "mcl_core:stick 2", wants = "mcl_core:emerald 1"},
        {give = "mcl_books:book 1", wants = "mcl_core:emerald 2"},
        {give = "mcl_core:apple 10", wants = "mcl_core:emerald 1"},
    },
    anakin = {
        {give = "mcl_core:iron_ingot 3", wants = "mcl_core:emerald 2"},
        {give = "mcl_core:stick 2", wants = "mcl_core:emerald 1"},
        {give = "mcl_core:gold_ingot 1", wants = "mcl_core:emerald 3"},
    },
    yoda = {
        {give = "mcl_core:emerald 3", wants = "mcl_core:emerald 1"},
        {give = "mcl_books:book 2", wants = "mcl_core:emerald 3"},
        {give = "mcl_farming:carrot_item 10", wants = "mcl_core:emerald 1"},
    },
    mandalorian = {
        {give = "mcl_core:iron_ingot 5", wants = "mcl_core:emerald 2"},
        {give = "mcl_core:diamond 1", wants = "mcl_core:emerald 5"},
        {give = "mcl_core:apple 10", wants = "mcl_core:emerald 1"},
    },
    leia = {
        {give = "mcl_books:book 2", wants = "mcl_core:emerald 2"},
        {give = "mcl_core:gold_ingot 2", wants = "mcl_core:emerald 3"},
        {give = "mcl_core:apple 10", wants = "mcl_core:emerald 1"},
    },
    farmer = {
        {give = "mcl_farming:carrot_item 5", wants = "mcl_core:emerald 1"},
        {give = "mcl_farming:potato_item 5", wants = "mcl_core:emerald 1"},
        {give = "mcl_farming:wheat_item 10", wants = "mcl_core:emerald 2"},
    },
    librarian = {
        {give = "mcl_books:book 1", wants = "mcl_core:emerald 3"},
        {give = "mcl_core:paper 10", wants = "mcl_core:emerald 1"},
    },
    teacher = {
        {give = "mcl_books:book 2", wants = "mcl_core:emerald 5"},
        {give = "mcl_core:paper 15", wants = "mcl_core:emerald 2"},
    },
    explorer = {
        {give = "mcl_core:apple 10", wants = "mcl_core:emerald 2"},
        {give = "mcl_core:stick 20", wants = "mcl_core:emerald 1"},
    },
}

-- ============================================================================
-- 5. CARGAR MODULOS (orden importa)
-- ============================================================================

-- Config (base para todo)
dofile(modpath .. "/config.lua")
log("info", "Config loaded")

-- Persistencia (ModStorage para NPCs y jugadores)
dofile(modpath .. "/persistence.lua")
log("info", "Persistence loaded")

-- Dialogos (desde archivos separados)
dofile(modpath .. "/dialogues/loader.lua")
log("info", "Dialogues loaded")

-- Items unicos
dofile(modpath .. "/items.lua")
log("info", "Items loaded")

-- Motor de misiones
dofile(modpath .. "/quest_engine.lua")
log("info", "Quest engine loaded")

-- Comportamientos AI
dofile(modpath .. "/ai_behaviors.lua")
log("info", "AI Behaviors loaded (v" .. wetlands_npcs.behaviors.version .. ")")

-- Registro de NPCs (usa todos los sistemas anteriores)
dofile(modpath .. "/npc_registry.lua")
log("info", "NPC registry loaded")

-- Formspecs (UI, depende de todos los sistemas)
dofile(modpath .. "/formspecs.lua")
log("info", "Formspecs loaded")

-- ============================================================================
-- 6. COMANDOS DE ADMINISTRACION
-- ============================================================================

local FRIENDSHIP_NAMES = {
    [0] = "Desconocido", [1] = "Conocido", [2] = "Amigo",
    [3] = "Buen Amigo", [4] = "Confidente", [5] = "Mejor Amigo",
}

local NPC_TYPES = {
    luke        = "Luke Skywalker - Caballero Jedi",
    anakin      = "Anakin Skywalker - Piloto legendario",
    yoda        = "Baby Yoda (Grogu) - Poderoso en la Fuerza",
    mandalorian = "Mandalorian - Cazarrecompensas beskar",
    leia        = "Princess Leia - Lider rebelde",
    farmer      = "Agricultor - cultiva vegetales",
    librarian   = "Bibliotecario - guarda conocimiento",
    teacher     = "Maestro - ensenia ciencia y compasion",
    explorer    = "Explorador - descubre el mundo",
}

minetest.register_chatcommand("spawn_npc", {
    params = "<luke|anakin|yoda|mandalorian|leia|farmer|librarian|teacher|explorer>",
    description = "Spawnea un NPC de Wetlands",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end

        local npc_type = param:lower():gsub("^%s+", ""):gsub("%s+$", "")

        if npc_type == "" then
            local lines = {"=== NPCs disponibles ==="}
            for ntype, desc in pairs(NPC_TYPES) do
                table.insert(lines, "  /spawn_npc " .. ntype .. " - " .. desc)
            end
            return true, table.concat(lines, "\n")
        end

        if not NPC_TYPES[npc_type] then
            local lines = {"'" .. npc_type .. "' no existe. NPCs disponibles:"}
            for ntype, desc in pairs(NPC_TYPES) do
                table.insert(lines, "  " .. ntype .. " - " .. desc)
            end
            return false, table.concat(lines, "\n")
        end

        local pos = player:get_pos()
        pos.y = pos.y + 1

        local obj = minetest.add_entity(pos, modname .. ":" .. npc_type)
        if obj then
            local display = wetlands_npcs.display_names[npc_type] or npc_type
            return true, display .. " spawneado exitosamente!"
        else
            return false, "Error al spawnear NPC"
        end
    end,
})

-- Alias por compatibilidad
minetest.register_chatcommand("spawn_villager", {
    params = "<type>",
    description = "Alias de /spawn_npc",
    privs = {server = true},
    func = function(name, param)
        return minetest.registered_chatcommands["spawn_npc"].func(name, param)
    end,
})

minetest.register_chatcommand("npc_info", {
    params = "",
    description = "Muestra info sobre los NPCs",
    privs = {},
    func = function(name, param)
        local info = {
            "=== NPCs de Wetlands v" .. wetlands_npcs.version .. " ===",
            "",
            "Star Wars:",
            "- Luke Skywalker (/spawn_npc luke)",
            "- Anakin Skywalker (/spawn_npc anakin)",
            "- Baby Yoda (/spawn_npc yoda)",
            "- Mandalorian (/spawn_npc mandalorian)",
            "- Princess Leia (/spawn_npc leia)",
            "",
            "Clasicos:",
            "- Agricultor (/spawn_npc farmer)",
            "- Bibliotecario (/spawn_npc librarian)",
            "- Maestro (/spawn_npc teacher)",
            "- Explorador (/spawn_npc explorer)",
            "",
            "Click derecho para interactuar!",
            "Cada NPC tiene misiones, comercio y sistema de amistad.",
        }
        return true, table.concat(info, "\n")
    end,
})

-- Comando para ver progreso del jugador
minetest.register_chatcommand("mi_progreso", {
    params = "",
    description = "Ver tu progreso con los NPCs de Wetlands",
    privs = {},
    func = function(name, param)
        local data = wetlands_npcs.persistence.load_player(name)
        local lines = {
            "=== Tu Progreso en Wetlands ===",
            "",
        }

        -- Relaciones
        local met_count = 0
        for npc_type, rel in pairs(data.npc_relationships) do
            met_count = met_count + 1
            local display = wetlands_npcs.display_names[npc_type] or npc_type
            local fname = FRIENDSHIP_NAMES[rel.friendship_level] or "Desconocido"
            table.insert(lines, "  " .. display .. ": " .. fname ..
                " (Nv." .. rel.friendship_level .. ", " ..
                rel.friendship_xp .. " XP)")
        end
        if met_count == 0 then
            table.insert(lines, "  Aun no has conocido a ningun NPC.")
        end

        -- Estadisticas
        table.insert(lines, "")
        table.insert(lines, "Estadisticas:")
        table.insert(lines, "  Misiones completadas: " .. data.stats.total_quests_completed)
        table.insert(lines, "  Intercambios: " .. data.stats.total_trades)
        table.insert(lines, "  NPCs conocidos: " .. data.stats.total_npcs_met .. "/9")
        table.insert(lines, "  Items unicos: " .. data.stats.total_unique_items)

        -- Logros
        local achievement_count = 0
        for _ in pairs(data.achievements) do achievement_count = achievement_count + 1 end
        if achievement_count > 0 then
            table.insert(lines, "")
            table.insert(lines, "Logros (" .. achievement_count .. "):")
            for id, _ in pairs(data.achievements) do
                local def = wetlands_npcs.persistence.achievement_defs[id]
                if def then
                    table.insert(lines, "  - " .. def.title)
                end
            end
        end

        -- Misiones activas
        local active_count = 0
        for _ in pairs(data.active_quests) do active_count = active_count + 1 end
        if active_count > 0 then
            table.insert(lines, "")
            table.insert(lines, "Misiones activas (" .. active_count .. "):")
            for quest_id, _ in pairs(data.active_quests) do
                local def = wetlands_npcs.quests.find_definition(quest_id)
                if def then
                    table.insert(lines, "  - " .. def.title)
                end
            end
        end

        return true, table.concat(lines, "\n")
    end,
})

-- ============================================================================
-- 7. FINALIZACION
-- ============================================================================

log("info", "Wetlands NPCs v" .. wetlands_npcs.version .. " loaded!")
log("info", "9 NPCs | Quests | Persistence | Friendship | Unique Items")
