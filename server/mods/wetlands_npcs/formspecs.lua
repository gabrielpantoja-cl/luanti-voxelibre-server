-- ============================================================================
-- formspecs.lua - Sistema de interfaz de usuario (formspecs)
-- ============================================================================

wetlands_npcs.formspecs = {}

local S = wetlands_npcs.S
local F = minetest.formspec_escape
local STAR_WARS_NPCS = wetlands_npcs.STAR_WARS_NPCS

-- ============================================================================
-- HELPER: Nombres de niveles de amistad (traducibles)
-- ============================================================================

local FRIENDSHIP_NAMES = {
    [0] = S("Desconocido"),
    [1] = S("Conocido"),
    [2] = S("Amigo"),
    [3] = S("Buen Amigo"),
    [4] = S("Confidente"),
    [5] = S("Mejor Amigo"),
}

local MOOD_COLORS = {
    happy = "#00FF00",
    neutral = "#FFFF00",
    sad = "#FF8800",
    tired = "#FF4444",
}

local MOOD_NAMES = {
    happy = S("feliz"),
    neutral = S("neutral"),
    sad = S("triste"),
    tired = S("cansado"),
}

-- ============================================================================
-- FORMSPEC PRINCIPAL DE INTERACCION
-- ============================================================================

function wetlands_npcs.formspecs.show_interaction(player_name, npc_type, display_name, npc_id)
    if not player_name or not npc_type then return end

    local name_str = display_name or wetlands_npcs.display_names[npc_type] or npc_type
    name_str = minetest.formspec_escape(name_str)

    -- Obtener datos de relacion
    local friendship = wetlands_npcs.persistence.get_friendship(player_name, npc_type)
    local friendship_name = FRIENDSHIP_NAMES[friendship] or "Desconocido"

    -- Obtener mood del NPC
    local mood_text = "happy"
    local mood_color = "#00FF00"
    if npc_id then
        local npc_state = wetlands_npcs.persistence.load_npc(npc_id)
        if npc_state then
            mood_text = npc_state.mood or "happy"
            mood_color = MOOD_COLORS[mood_text] or "#FFFFFF"
        end
    end

    -- Contar misiones disponibles y activas
    local available_quests = wetlands_npcs.quests.get_available(player_name, npc_type)
    local active_quests = wetlands_npcs.quests.get_active(player_name, npc_type)
    local quest_badge = ""
    if #available_quests > 0 then
        quest_badge = " [" .. S("@1 nueva(s)", #available_quests) .. "]"
    elseif #active_quests > 0 then
        quest_badge = " [" .. S("@1 activa(s)", #active_quests) .. "]"
    end

    -- Botones (unificados en espaniol base, traducidos via i18n)
    local third_button
    if STAR_WARS_NPCS[npc_type] then
        third_button = "button[0.5,4;9,0.8;play_iconic;" .. F(S("Reproducir audio iconico")) .. "]"
    else
        third_button = "button[0.5,4;9,0.8;dialogue_education;" .. F(S("Dato educativo")) .. "]"
    end

    local btn_greet = "button[0.5,2;9,0.8;dialogue_greeting;" .. F(S("Saludar")) .. "]"
    local btn_work = "button[0.5,3;9,0.8;dialogue_work;" .. F(S("Sobre su historia")) .. "]"
    local btn_trade = "button[0.5,5;9,0.8;trade;" .. F(S("Comerciar")) .. "]"
    local btn_quests = "button[0.5,6;9,0.8;quests;" .. F(S("Misiones") .. F(quest_badge)) .. "]"
    local btn_close = "button_exit[0.5,7;9,0.8;close;" .. F(S("Cerrar")) .. "]"

    local formspec = "formspec_version[4]" ..
        "size[10,8.5]" ..
        "label[0.5,0.5;" .. name_str .. "]" ..
        "label[0.5,1.1;" .. F(S("Amistad")) .. ": " .. F(friendship_name) ..
            " (" .. F(S("Nv.")) .. friendship .. ")  |  " .. F(S("Animo")) .. ": " ..
            minetest.colorize(mood_color, F(MOOD_NAMES[mood_text] or mood_text)) .. "]" ..
        btn_greet ..
        btn_work ..
        third_button ..
        btn_trade ..
        btn_quests ..
        btn_close

    minetest.show_formspec(player_name,
        "wetlands_npcs:interact_" .. npc_type, formspec)
end

-- ============================================================================
-- FORMSPEC DE COMERCIO
-- ============================================================================

function wetlands_npcs.formspecs.show_trade(player_name, npc_type)
    if not player_name or not npc_type then return end

    local trades = wetlands_npcs.trades[npc_type]
    if not trades then
        minetest.chat_send_player(player_name, S("[NPC] No tengo nada para comerciar ahora."))
        return
    end

    local display = wetlands_npcs.display_names[npc_type] or npc_type
    local formspec = "formspec_version[4]" ..
        "size[12,11]" ..
        "label[0.5,0.5;" .. F(S("Comercio")) .. " - " .. F(display) .. "]" ..
        "label[0.5,1;" .. F(S("Ofrece esmeraldas por items:")) .. "]" ..
        "list[current_player;main;0.5,6;8,4;]"

    local y = 2
    for i, trade in ipairs(trades) do
        formspec = formspec .. "label[0.5," .. y .. ";" .. i .. ". " ..
                   F(trade.give) .. " <- " ..
                   F(trade.wants) .. "]"
        formspec = formspec .. "button[7," .. (y-0.2) .. ";3,0.8;trade_" .. i .. ";" .. F(S("Comerciar")) .. "]"
        y = y + 1
    end

    -- Boton volver
    formspec = formspec .. "button[0.5," .. (y + 0.3) .. ";3,0.8;back_to_interact;" .. F(S("Volver")) .. "]"

    minetest.show_formspec(player_name,
        "wetlands_npcs:trade_" .. npc_type, formspec)
end

-- ============================================================================
-- FORMSPEC DE MISIONES
-- ============================================================================

function wetlands_npcs.formspecs.show_quests(player_name, npc_type)
    if not player_name or not npc_type then return end

    -- Actualizar progreso de misiones tipo collect
    wetlands_npcs.quests.check_collect_progress(player_name, npc_type)

    local available = wetlands_npcs.quests.get_available(player_name, npc_type)
    local active = wetlands_npcs.quests.get_active(player_name, npc_type)
    local display = wetlands_npcs.display_names[npc_type] or npc_type

    local formspec = "formspec_version[4]" ..
        "size[12,11]" ..
        "label[0.5,0.4;" .. F(S("Misiones")) .. " - " .. F(display) .. "]"

    local y = 1.2

    -- Misiones activas
    if #active > 0 then
        formspec = formspec ..
            "label[0.5," .. y .. ";" ..
            minetest.colorize("#FFAA00", F(S("MISIONES ACTIVAS:"))) .. "]"
        y = y + 0.6

        for _, quest_data in ipairs(active) do
            local def = quest_data.definition
            local state = quest_data.state
            local completable = wetlands_npcs.quests.is_completable(player_name, def.id)

            formspec = formspec ..
                "label[0.5," .. y .. ";" ..
                minetest.formspec_escape(def.title) .. "]"
            y = y + 0.5

            -- Mostrar progreso de cada objetivo
            if def.objectives and state.progress then
                for i, obj in ipairs(def.objectives) do
                    local prog = state.progress[i]
                    if prog then
                        local color = prog.completed and "#00FF00" or "#FFFF00"
                        local status_text = string.format("%d/%d",
                            prog.current, prog.target)
                        local desc = obj.description or S("Objetivo")
                        formspec = formspec ..
                            "label[1," .. y .. ";" ..
                            minetest.colorize(color, status_text .. " " ..
                            minetest.formspec_escape(desc)) .. "]"
                        y = y + 0.4
                    end
                end
            end

            if completable then
                formspec = formspec ..
                    "button[7," .. (y - 0.3) .. ";4,0.7;complete_" .. def.id ..
                    ";" .. minetest.colorize("#00FF00", F(S("Entregar!"))) .. "]"
                y = y + 0.5
            end
            y = y + 0.3
        end
    end

    -- Misiones disponibles
    if #available > 0 then
        formspec = formspec ..
            "label[0.5," .. y .. ";" ..
            minetest.colorize("#00CCFF", F(S("MISIONES DISPONIBLES:"))) .. "]"
        y = y + 0.6

        for _, quest in ipairs(available) do
            formspec = formspec ..
                "label[0.5," .. y .. ";" ..
                minetest.formspec_escape(quest.title) .. "]"
            y = y + 0.4

            -- Descripcion breve
            if quest.description then
                formspec = formspec ..
                    "label[1," .. y .. ";" ..
                    minetest.colorize("#AAAAAA",
                    minetest.formspec_escape(quest.description)) .. "]"
                y = y + 0.4
            end

            -- Recompensas
            local reward_text = ""
            if quest.rewards then
                if quest.rewards.items then
                    for _, r in ipairs(quest.rewards.items) do
                        reward_text = reward_text .. r.name .. " x" .. (r.count or 1) .. "  "
                    end
                end
                if quest.rewards.unique_item then
                    reward_text = reward_text .. minetest.colorize("#FFD700", S("Item Unico!"))
                end
            end
            if reward_text ~= "" then
                formspec = formspec ..
                    "label[1," .. y .. ";" .. F(S("Recompensa:")) .. " " ..
                    F(reward_text) .. "]"
                y = y + 0.4
            end

            formspec = formspec ..
                "button[7," .. (y - 0.3) .. ";4,0.7;accept_" .. quest.id ..
                "_" .. npc_type .. ";" .. F(S("Aceptar")) .. "]"
            y = y + 0.6
        end
    end

    -- Sin misiones
    if #available == 0 and #active == 0 then
        formspec = formspec ..
            "label[0.5," .. y .. ";" ..
            minetest.colorize("#888888",
            F(S("No hay misiones disponibles por ahora. Sube tu nivel de amistad!"))) .. "]"
        y = y + 0.6
    end

    -- Boton volver
    formspec = formspec ..
        "button[0.5," .. math.max(y + 0.3, 9.5) .. ";3,0.7;back_to_interact;" .. F(S("Volver")) .. "]"

    minetest.show_formspec(player_name,
        "wetlands_npcs:quests_" .. npc_type, formspec)
end

-- ============================================================================
-- HANDLER DE CAMPOS (CLICKS)
-- ============================================================================

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local player_name = player:get_player_name()
    local player_pos = player:get_pos()

    -- === FORMSPEC DE INTERACCION ===
    if formname:find("^wetlands_npcs:interact_") then
        local npc_type = formname:gsub("^wetlands_npcs:interact_", "")

        if fields.dialogue_greeting then
            local msg = wetlands_npcs.get_dialogue(npc_type, "greetings")
            local display = wetlands_npcs.display_names[npc_type] or npc_type
            minetest.chat_send_player(player_name, "[" .. display .. "] " .. msg)
            wetlands_npcs.play_npc_voice(npc_type, player_pos)
            wetlands_npcs.persistence.update_relationship(player_name, npc_type, "talk")

        elseif fields.dialogue_work then
            local msg = wetlands_npcs.get_dialogue(npc_type, "about_work")
            local display = wetlands_npcs.display_names[npc_type] or npc_type
            minetest.chat_send_player(player_name, "[" .. display .. "] " .. msg)
            wetlands_npcs.play_npc_voice(npc_type, player_pos)

        elseif fields.play_iconic then
            wetlands_npcs.play_npc_iconic(npc_type, player_pos)
            local phrase = wetlands_npcs.get_iconic_phrase(npc_type)
            local display = wetlands_npcs.display_names[npc_type] or npc_type
            minetest.chat_send_player(player_name, "[" .. display .. "] " .. phrase)

        elseif fields.dialogue_education then
            local msg = wetlands_npcs.get_dialogue(npc_type, "education")
            local display = wetlands_npcs.display_names[npc_type] or npc_type
            minetest.chat_send_player(player_name, "[" .. display .. "] " .. msg)
            wetlands_npcs.play_npc_voice(npc_type, player_pos)

        elseif fields.trade then
            wetlands_npcs.formspecs.show_trade(player_name, npc_type)

        elseif fields.quests then
            wetlands_npcs.formspecs.show_quests(player_name, npc_type)
        end
    end

    -- === FORMSPEC DE COMERCIO ===
    if formname:find("^wetlands_npcs:trade_") then
        local npc_type = formname:gsub("^wetlands_npcs:trade_", "")

        if fields.back_to_interact then
            local display = wetlands_npcs.display_names[npc_type] or npc_type
            wetlands_npcs.formspecs.show_interaction(player_name, npc_type, display)
            return
        end

        local trades = wetlands_npcs.trades[npc_type]
        if not trades then return end

        for field, _ in pairs(fields) do
            if field:find("^trade_") then
                local trade_index = tonumber(field:gsub("^trade_", ""))
                if not trade_index then break end
                local trade = trades[trade_index]

                if trade then
                    local inv = player:get_inventory()
                    local wants_item, wants_count = trade.wants:match("(%S+)%s+(%d+)")
                    wants_count = tonumber(wants_count) or 1

                    if inv:contains_item("main", wants_item .. " " .. wants_count) then
                        inv:remove_item("main", wants_item .. " " .. wants_count)
                        inv:add_item("main", trade.give)
                        minetest.chat_send_player(player_name,
                            minetest.colorize("#00FF00", S("[Comercio exitoso] Gracias por tu intercambio!")))
                        wetlands_npcs.persistence.update_relationship(
                            player_name, npc_type, "trade")
                    else
                        minetest.chat_send_player(player_name,
                            minetest.colorize("#FF4444", S("[Comercio fallido] No tienes suficientes items.")))
                    end
                end
            end
        end
    end

    -- === FORMSPEC DE MISIONES ===
    if formname:find("^wetlands_npcs:quests_") then
        local npc_type = formname:gsub("^wetlands_npcs:quests_", "")

        if fields.back_to_interact then
            local display = wetlands_npcs.display_names[npc_type] or npc_type
            wetlands_npcs.formspecs.show_interaction(player_name, npc_type, display)
            return
        end

        for field, _ in pairs(fields) do
            -- Aceptar mision
            if field:find("^accept_") then
                local rest = field:gsub("^accept_", "")
                -- El formato es: accept_QUESTID_NPCTYPE
                -- Necesitamos separar quest_id de npc_type
                local quest_id, quest_npc = rest:match("^(.+)_([^_]+)$")
                if quest_id and quest_npc then
                    wetlands_npcs.quests.accept(player_name, quest_id, quest_npc)
                    wetlands_npcs.formspecs.show_quests(player_name, npc_type)
                end
            end

            -- Completar mision
            if field:find("^complete_") then
                local quest_id = field:gsub("^complete_", "")
                local ok, msg = wetlands_npcs.quests.complete(player_name, quest_id)
                if not ok then
                    minetest.chat_send_player(player_name,
                        minetest.colorize("#FF4444", S("[Mision] @1", msg or "Error")))
                end
                wetlands_npcs.formspecs.show_quests(player_name, npc_type)
            end
        end
    end
end)

minetest.log("action", "[wetlands_npcs] Formspecs system loaded")
