-- ============================================================================
-- quest_engine.lua - Motor de misiones principales y secundarias
-- ============================================================================

local modpath = minetest.get_modpath("wetlands_npcs")

wetlands_npcs.quests = {}

-- ============================================================================
-- CARGAR DEFINICIONES DE MISIONES
-- ============================================================================

wetlands_npcs.quests.definitions = {}

local NPC_LIST = {
    "luke", "anakin", "yoda", "mandalorian", "leia",
    "farmer", "librarian", "teacher", "explorer",
}

for _, npc_name in ipairs(NPC_LIST) do
    local filepath = modpath .. "/quests/" .. npc_name .. "_quests.lua"
    local f = io.open(filepath, "r")
    if f then
        f:close()
        local data = dofile(filepath)
        if data then
            wetlands_npcs.quests.definitions[npc_name] = data
        end
    end
end

-- ============================================================================
-- API DE MISIONES
-- ============================================================================

-- Obtener misiones disponibles para un jugador con un NPC especifico
function wetlands_npcs.quests.get_available(player_name, npc_type)
    local defs = wetlands_npcs.quests.definitions[npc_type]
    if not defs then return {} end

    local player_data = wetlands_npcs.persistence.load_player(player_name)
    local friendship = wetlands_npcs.persistence.get_friendship(player_name, npc_type)
    local available = {}

    -- Main quests
    if defs.main_quests then
        for _, quest in ipairs(defs.main_quests) do
            -- No mostrar si ya esta activa o completada
            if not player_data.active_quests[quest.id]
               and not player_data.completed_quests[quest.id] then
                -- Verificar prerequisitos
                local prereq_met = true
                if quest.requires then
                    if not player_data.completed_quests[quest.requires] then
                        prereq_met = false
                    end
                end
                -- Verificar nivel de amistad
                if quest.min_friendship and friendship < quest.min_friendship then
                    prereq_met = false
                end
                if prereq_met then
                    table.insert(available, quest)
                end
            end
        end
    end

    -- Side quests
    if defs.side_quests then
        for _, quest in ipairs(defs.side_quests) do
            local cooldown_ok = true
            if quest.repeatable and player_data.completed_quests[quest.id] then
                local cooldown_end = player_data.side_quest_cooldowns[quest.id] or 0
                if os.time() < cooldown_end then
                    cooldown_ok = false
                end
            elseif not quest.repeatable and player_data.completed_quests[quest.id] then
                cooldown_ok = false
            end
            if cooldown_ok and not player_data.active_quests[quest.id] then
                if not quest.min_friendship or friendship >= quest.min_friendship then
                    table.insert(available, quest)
                end
            end
        end
    end

    return available
end

-- Obtener misiones activas del jugador (opcionalmente filtrar por NPC)
function wetlands_npcs.quests.get_active(player_name, npc_type)
    local player_data = wetlands_npcs.persistence.load_player(player_name)
    local active = {}

    for quest_id, quest_state in pairs(player_data.active_quests) do
        if not npc_type or quest_state.npc_type == npc_type then
            -- Buscar definicion completa
            local def = wetlands_npcs.quests.find_definition(quest_id)
            if def then
                table.insert(active, {
                    definition = def,
                    state = quest_state,
                })
            end
        end
    end

    return active
end

-- Buscar definicion de quest por ID
function wetlands_npcs.quests.find_definition(quest_id)
    for npc_type, defs in pairs(wetlands_npcs.quests.definitions) do
        if defs.main_quests then
            for _, quest in ipairs(defs.main_quests) do
                if quest.id == quest_id then return quest end
            end
        end
        if defs.side_quests then
            for _, quest in ipairs(defs.side_quests) do
                if quest.id == quest_id then return quest end
            end
        end
    end
    return nil
end

-- Aceptar una mision
function wetlands_npcs.quests.accept(player_name, quest_id, npc_type)
    local def = wetlands_npcs.quests.find_definition(quest_id)
    if not def then return false, "Mision no encontrada" end

    local player_data = wetlands_npcs.persistence.load_player(player_name)
    if player_data.active_quests[quest_id] then
        return false, "Ya tienes esta mision activa"
    end

    -- Inicializar progreso
    local progress = {}
    if def.objectives then
        for i, obj in ipairs(def.objectives) do
            progress[i] = {
                type = obj.type,
                current = 0,
                target = obj.count or 1,
                completed = false,
            }
        end
    end

    player_data.active_quests[quest_id] = {
        npc_type = npc_type,
        accepted_at = os.time(),
        progress = progress,
    }

    wetlands_npcs.persistence.save_player(player_name, player_data)

    -- Mensaje de aceptacion
    if def.dialogue_on_accept then
        local display = wetlands_npcs.display_names[npc_type] or npc_type
        minetest.chat_send_player(player_name,
            minetest.colorize("#FFAA00", "[" .. display .. "] " .. def.dialogue_on_accept))
    end

    minetest.chat_send_player(player_name,
        minetest.colorize("#00FF00", "[Mision Aceptada] " .. def.title))

    return true
end

-- Verificar y actualizar progreso de misiones tipo "collect"
function wetlands_npcs.quests.check_collect_progress(player_name, npc_type)
    local player_data = wetlands_npcs.persistence.load_player(player_name)
    local player = minetest.get_player_by_name(player_name)
    if not player then return end

    local inv = player:get_inventory()
    local updated = false

    for quest_id, quest_state in pairs(player_data.active_quests) do
        if quest_state.npc_type == npc_type then
            local def = wetlands_npcs.quests.find_definition(quest_id)
            if def and def.objectives then
                for i, obj in ipairs(def.objectives) do
                    if obj.type == "collect" and quest_state.progress[i] then
                        local count = 0
                        for j = 1, inv:get_size("main") do
                            local stack = inv:get_stack("main", j)
                            if stack:get_name() == obj.item then
                                count = count + stack:get_count()
                            end
                        end
                        quest_state.progress[i].current = math.min(count, obj.count)
                        if count >= obj.count then
                            quest_state.progress[i].completed = true
                        end
                        updated = true
                    end
                end
            end
        end
    end

    if updated then
        wetlands_npcs.persistence.save_player(player_name, player_data)
    end
end

-- Verificar si una mision esta lista para completar
function wetlands_npcs.quests.is_completable(player_name, quest_id)
    local player_data = wetlands_npcs.persistence.load_player(player_name)
    local quest_state = player_data.active_quests[quest_id]
    if not quest_state then return false end

    for _, prog in pairs(quest_state.progress) do
        if not prog.completed then return false end
    end
    return true
end

-- Completar una mision y dar recompensas
function wetlands_npcs.quests.complete(player_name, quest_id)
    if not wetlands_npcs.quests.is_completable(player_name, quest_id) then
        return false, "Aun no has completado todos los objetivos"
    end

    local def = wetlands_npcs.quests.find_definition(quest_id)
    if not def then return false, "Mision no encontrada" end

    local player_data = wetlands_npcs.persistence.load_player(player_name)
    local quest_state = player_data.active_quests[quest_id]
    local npc_type = quest_state.npc_type
    local player = minetest.get_player_by_name(player_name)
    if not player then return false, "Jugador no encontrado" end

    local inv = player:get_inventory()

    -- Remover items requeridos del inventario (tipo collect)
    if def.objectives then
        for _, obj in ipairs(def.objectives) do
            if obj.type == "collect" and obj.item then
                inv:remove_item("main", obj.item .. " " .. obj.count)
            end
        end
    end

    -- Dar recompensas
    if def.rewards then
        if def.rewards.items then
            for _, reward in ipairs(def.rewards.items) do
                local stack = ItemStack(reward.name .. " " .. (reward.count or 1))
                if inv:room_for_item("main", stack) then
                    inv:add_item("main", stack)
                else
                    minetest.item_drop(stack, player, player:get_pos())
                end
            end
        end

        -- Item unico como recompensa
        if def.rewards.unique_item then
            wetlands_npcs.items.award_unique(npc_type, player_name)
        end
    end

    -- Mover de activas a completadas
    player_data.active_quests[quest_id] = nil
    player_data.completed_quests[quest_id] = {
        completed_at = os.time(),
    }

    -- Cooldown para side quests repetibles
    if def.repeatable and def.cooldown then
        player_data.side_quest_cooldowns[quest_id] = os.time() + def.cooldown
    end

    -- Estadisticas
    player_data.stats.total_quests_completed = player_data.stats.total_quests_completed + 1

    wetlands_npcs.persistence.save_player(player_name, player_data)

    -- Actualizar relacion
    wetlands_npcs.persistence.update_relationship(player_name, npc_type, "quest_complete")

    -- Actualizar mood del NPC
    if quest_state.npc_type then
        -- Buscar el NPC activo mas cercano de ese tipo para actualizar mood
        for _, obj in pairs(minetest.object_refs) do
            local entity = obj:get_luaentity()
            if entity and entity.custom_villager_type == npc_type and entity._npc_id then
                wetlands_npcs.persistence.update_mood(entity._npc_id, 15)
                break
            end
        end
    end

    -- Logros
    if player_data.stats.total_quests_completed == 1 then
        wetlands_npcs.persistence.grant_achievement(player_name, "quest_novice")
    elseif player_data.stats.total_quests_completed >= 10 then
        wetlands_npcs.persistence.grant_achievement(player_name, "quest_veteran")
    end

    -- Mensaje de completado
    local display = wetlands_npcs.display_names[npc_type] or npc_type
    if def.dialogue_on_complete then
        minetest.chat_send_player(player_name,
            minetest.colorize("#FFAA00", "[" .. display .. "] " .. def.dialogue_on_complete))
    end
    minetest.chat_send_player(player_name,
        minetest.colorize("#00FF00", "[Mision Completada] " .. def.title))

    return true
end

-- Obtener texto de progreso para mostrar en formspec
function wetlands_npcs.quests.get_progress_text(player_name, quest_id)
    local player_data = wetlands_npcs.persistence.load_player(player_name)
    local quest_state = player_data.active_quests[quest_id]
    if not quest_state then return "" end

    local def = wetlands_npcs.quests.find_definition(quest_id)
    if not def then return "" end

    local lines = {}
    if def.objectives then
        for i, obj in ipairs(def.objectives) do
            local prog = quest_state.progress[i]
            if prog then
                local status = prog.completed and "[OK]" or
                    string.format("[%d/%d]", prog.current, prog.target)
                local desc = obj.description or obj.item or "Objetivo"
                table.insert(lines, status .. " " .. desc)
            end
        end
    end
    return table.concat(lines, "\n")
end

minetest.log("action", "[wetlands_npcs] Quest engine loaded")
