-- ============================================================================
-- dialogues/loader.lua - Carga dialogos desde archivos separados
-- ============================================================================

local modpath = minetest.get_modpath("wetlands_npcs")

wetlands_npcs.dialogues = {}

local NPC_LIST = {
    "luke", "anakin", "yoda", "mandalorian", "leia",
    "farmer", "librarian", "teacher", "explorer",
}

for _, npc_name in ipairs(NPC_LIST) do
    local filepath = modpath .. "/dialogues/" .. npc_name .. ".lua"
    local data = dofile(filepath)
    if data then
        wetlands_npcs.dialogues[npc_name] = data
    else
        minetest.log("error", "[wetlands_npcs] Failed to load dialogues for: " .. npc_name)
    end
end

-- Obtener un dialogo aleatorio de una categoria
function wetlands_npcs.get_dialogue(npc_type, category)
    local dialogues = wetlands_npcs.dialogues[npc_type]
    if not dialogues or not dialogues[category] then
        return "..."
    end
    local options = dialogues[category]
    return options[math.random(1, #options)]
end

-- Obtener la frase iconica de un NPC
function wetlands_npcs.get_iconic_phrase(npc_type)
    local dialogues = wetlands_npcs.dialogues[npc_type]
    if not dialogues or not dialogues.iconic_phrase then
        return "..."
    end
    return dialogues.iconic_phrase
end

-- Obtener saludo de seek_player (con nombre del jugador)
function wetlands_npcs.get_seek_greeting(npc_type, player_name)
    local dialogues = wetlands_npcs.dialogues[npc_type]
    if not dialogues or not dialogues.seek_player then
        return "Hola, " .. player_name .. "!"
    end
    local options = dialogues.seek_player
    local template = options[math.random(1, #options)]
    return string.format(template, player_name)
end

minetest.log("action", "[wetlands_npcs] Dialogues loaded for " .. #NPC_LIST .. " NPCs")
