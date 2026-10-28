local modname = minetest.get_current_modname()

-- player_name -> { game="topo"|"trivia", score, time_left, mole_pos, qi, ... }
local active_games = {}

-- ============================================================
-- JUEGO 1: Atrapa al Topo (Whack-a-Mole)
-- ============================================================

local TOPO_N        = 9
local TOPO_DURATION = 30
local TOPO_INTERVAL = 1.8

local function topo_next_pos(current)
    local p
    repeat p = math.random(1, TOPO_N) until p ~= current
    return p
end

local function topo_formspec(state)
    local fs = "formspec_version[4]"
        .. "size[6.5,8]"
        .. "bgcolor[#0d001a;true]"
        .. "label[1.5,0.4;Atrapa al Topo!]"
        .. "label[0.5,1.1;Puntos: " .. state.score .. "]"
        .. "label[3.5,1.1;Tiempo: " .. math.max(0, math.ceil(state.time_left)) .. "s]"
    for i = 1, TOPO_N do
        local row = math.floor((i - 1) / 3)
        local col = (i - 1) % 3
        local x   = 0.5 + col * 1.85
        local y   = 1.7 + row * 1.85
        local tex = (i == state.mole_pos) and "wetlands_snes_mole.png" or "wetlands_snes_hole.png"
        fs = fs .. "image_button[" .. x .. "," .. y .. ";1.7,1.7;" .. tex .. ";t" .. i .. ";]"
    end
    return fs .. "button_exit[2.0,7.2;2.5,0.8;quit;Salir]"
end

local function topo_gameover_formspec(score)
    local msg = score >= 12 and "Increible! Eres un cazador de topos!" or
                score >= 7  and "Muy bien hecho!" or
                score >= 3  and "Sigue practicando!" or
                "Proxima vez lo haras mejor!"
    return "formspec_version[4]"
        .. "size[7,5]"
        .. "bgcolor[#0d001a;true]"
        .. "label[1.5,0.8;Tiempo agotado!]"
        .. "label[0.5,2.0;Atrapaste " .. score .. " topos. " .. msg .. "]"
        .. "button_exit[2.5,4.0;2,0.8;quit;Cerrar]"
end

local function start_topo(pname)
    active_games[pname] = {
        game      = "topo",
        score     = 0,
        time_left = TOPO_DURATION,
        mole_pos  = math.random(1, TOPO_N),
        last_move = minetest.get_gametime(),
    }
    minetest.show_formspec(pname, modname .. ":topo",
        topo_formspec(active_games[pname]))
end

-- ============================================================
-- JUEGO 2: Trivia de Valdivia
-- ============================================================

local TRIVIA = {
    {
        q = "En que anio fue fundada Valdivia, Chile?",
        o = { "1552", "1620", "1810", "1450" }, a = 1,
        e = "Pedro de Valdivia fundo la ciudad en 1552.",
    },
    {
        q = "Como se llama el rio principal que pasa por Valdivia?",
        o = { "Rio Bio-Bio", "Rio Calle-Calle", "Rio Maule", "Rio Baker" }, a = 2,
        e = "El Rio Calle-Calle (o Rio Valdivia) es simbolo de la ciudad.",
    },
    {
        q = "En que isla esta la Universidad Austral de Chile?",
        o = { "Isla Chiloe", "Isla Mocha", "Isla Teja", "Isla Robinson" }, a = 3,
        e = "La Universidad Austral esta en la hermosa Isla Teja.",
    },
    {
        q = "El terremoto de Valdivia 1960 fue el mas grande de la historia?",
        o = { "Si, 9.5 Richter", "No, fue 5.0", "No existio", "No, fue 7.0" }, a = 1,
        e = "El terremoto de 1960 fue el mas grande jamas registrado: 9.5 Richter.",
    },
    {
        q = "Que pais europeo se instalo fuertemente en Valdivia en el siglo XIX?",
        o = { "Francia", "Italia", "Alemania", "Portugal" }, a = 3,
        e = "Colonos alemanes llegaron a Valdivia en 1850, dejando gran huella cultural.",
    },
    {
        q = "Como se llama el lago famoso cercano a Valdivia?",
        o = { "Lago Llanquihue", "Lago Rinihue", "Lago Villarrica", "Lago Panguipulli" }, a = 2,
        e = "El Lago Rinihue fue clave en la catastrofe del terremoto de 1960.",
    },
    {
        q = "Que animal europeo es muy comun en los bosques de Valdivia hoy?",
        o = { "Condor", "Jabali", "Llama", "Guanaco" }, a = 2,
        e = "El jabali fue traido por colonos europeos y hoy abunda en el sur de Chile.",
    },
}

local function trivia_formspec(state)
    local q = TRIVIA[state.qi]
    local fs = "formspec_version[4]"
        .. "size[9,8]"
        .. "bgcolor[#001a32;true]"
        .. "label[2.0,0.3;Trivia de Valdivia!]"
        .. "label[0.5,0.9;Pregunta " .. state.qi .. " de " .. #TRIVIA
        .. "   Puntos: " .. state.score .. "]"
        .. "label[0.5,1.7;" .. q.q .. "]"
    for i, opt in ipairs(q.o) do
        local y = 2.8 + (i - 1) * 1.1
        fs = fs .. "button[0.5," .. y .. ";8,0.9;a" .. i .. ";" .. opt .. "]"
    end
    return fs .. "button_exit[3.5,7.2;2,0.8;quit;Salir]"
end

local function trivia_fb_formspec(correct, explanation, score)
    local header = correct and "Correcto!" or "Incorrecto"
    local color  = correct and "#00cc44" or "#cc4400"
    return "formspec_version[4]"
        .. "size[9,5.5]"
        .. "bgcolor[#001a32;true]"
        .. "style_type[label;color=" .. color .. "]"
        .. "label[3.5,0.7;" .. header .. "]"
        .. "style_type[label;color=#ffffff]"
        .. "label[0.5,1.8;" .. explanation .. "]"
        .. "label[0.5,3.0;Puntos: " .. score .. "]"
        .. "button_exit[3.5,4.5;2,0.8;next;Siguiente]"
end

local function trivia_final_formspec(score)
    local total = #TRIVIA
    local pct   = math.floor(score / total * 100)
    local msg   = pct == 100 and "Experto total en Valdivia!" or
                  pct >= 71  and "Excelente conocimiento!" or
                  pct >= 43  and "Buen trabajo, sigue aprendiendo!" or
                  "Explora Valdivia para aprender mas!"
    return "formspec_version[4]"
        .. "size[9,5.5]"
        .. "bgcolor[#001a32;true]"
        .. "label[2.0,0.7;Trivia completada!]"
        .. "label[0.5,2.0;Respondiste bien " .. score .. " de " .. total
        .. " preguntas (" .. pct .. "%)]"
        .. "label[1.5,3.0;" .. msg .. "]"
        .. "button_exit[3.5,4.5;2,0.8;quit;Cerrar]"
end

local function start_trivia(pname)
    active_games[pname] = { game = "trivia", score = 0, qi = 1 }
    minetest.show_formspec(pname, modname .. ":trivia",
        trivia_formspec(active_games[pname]))
end

-- ============================================================
-- MENU PRINCIPAL
-- ============================================================

local function menu_formspec()
    return "formspec_version[4]"
        .. "size[8,6.5]"
        .. "bgcolor[#1a0032;true]"
        .. "label[2.5,0.5;SNES Wetlands]"
        .. "label[1.5,1.5;Elige un juego:]"
        .. "button[1.0,2.2;6,1.3;game_topo;Atrapa al Topo]"
        .. "button[1.0,3.8;6,1.3;game_trivia;Trivia de Valdivia]"
        .. "button_exit[3.0,5.5;2,0.8;quit;Cerrar]"
end

-- ============================================================
-- MANEJADORES DE FORMSPEC
-- ============================================================

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local pname = player:get_player_name()

    if formname == modname .. ":menu" then
        if     fields.game_topo   then start_topo(pname)
        elseif fields.game_trivia then start_trivia(pname) end
        return true
    end

    if formname == modname .. ":topo" then
        local state = active_games[pname]
        if not state or state.game ~= "topo" then return end
        if fields.quit then active_games[pname] = nil; return true end
        for i = 1, TOPO_N do
            if fields["t" .. i] then
                if i == state.mole_pos then
                    state.score    = state.score + 1
                    state.mole_pos = topo_next_pos(state.mole_pos)
                    state.last_move = minetest.get_gametime()
                end
                minetest.show_formspec(pname, formname, topo_formspec(state))
                break
            end
        end
        return true
    end

    if formname == modname .. ":trivia" then
        local state = active_games[pname]
        if not state or state.game ~= "trivia" then return end
        if fields.quit then active_games[pname] = nil; return true end
        local q = TRIVIA[state.qi]
        for i = 1, 4 do
            if fields["a" .. i] then
                local correct = (i == q.a)
                if correct then state.score = state.score + 1 end
                state.qi = state.qi + 1
                minetest.show_formspec(pname, modname .. ":trivia_fb",
                    trivia_fb_formspec(correct, q.e, state.score))
                break
            end
        end
        return true
    end

    if formname == modname .. ":trivia_fb" then
        local state = active_games[pname]
        if not state or state.game ~= "trivia" then return end
        -- button_exit "next" sets both fields.next and fields.quit
        if fields.next then
            if state.qi > #TRIVIA then
                local final = state.score
                active_games[pname] = nil
                minetest.show_formspec(pname, modname .. ":trivia_fin",
                    trivia_final_formspec(final))
            else
                minetest.show_formspec(pname, modname .. ":trivia",
                    trivia_formspec(state))
            end
        elseif fields.quit then
            active_games[pname] = nil
        end
        return true
    end
end)

minetest.register_on_leaveplayer(function(player)
    active_games[player:get_player_name()] = nil
end)

-- ============================================================
-- GLOBALSTEP: timer Atrapa al Topo
-- ============================================================

local step_acc = 0
minetest.register_globalstep(function(dtime)
    step_acc = step_acc + dtime
    if step_acc < 1.0 then return end
    step_acc = step_acc - 1.0

    local now = minetest.get_gametime()
    for pname, state in pairs(active_games) do
        if state.game == "topo" then
            state.time_left = state.time_left - 1.0
            if now - state.last_move >= TOPO_INTERVAL then
                state.mole_pos  = topo_next_pos(state.mole_pos)
                state.last_move = now
            end
            if state.time_left <= 0 then
                local final = state.score
                active_games[pname] = nil
                minetest.show_formspec(pname, modname .. ":topo_fin",
                    topo_gameover_formspec(final))
            else
                minetest.show_formspec(pname, modname .. ":topo",
                    topo_formspec(state))
            end
        end
    end
end)

-- ============================================================
-- NODO: Consola SNES
-- ============================================================

minetest.register_node(modname .. ":console", {
    description = "Consola Super Nintendo",
    tiles = {
        "wetlands_snes_top.png",
        "wetlands_snes_bottom.png",
        "wetlands_snes_side.png",
        "wetlands_snes_side.png",
        "wetlands_snes_back.png",
        "wetlands_snes_front.png",
    },
    drawtype   = "nodebox",
    paramtype  = "light",
    paramtype2 = "facedir",
    node_box = {
        type  = "fixed",
        fixed = {
            { -0.5, -0.5, -0.25, 0.5, -0.08, 0.38 },  -- cuerpo plano
            { -0.13, -0.08, 0.05, 0.13, 0.22, 0.20 },  -- ranura cartucho
        },
    },
    selection_box = {
        type  = "fixed",
        fixed = { -0.5, -0.5, -0.25, 0.5, 0.22, 0.38 },
    },
    groups = {
        cracky                  = 2,
        oddly_breakable_by_hand = 1,
        handy                   = 1,
    },
    _mcl_blast_resistance = 3,
    _mcl_hardness         = 2,
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        minetest.show_formspec(player:get_player_name(),
            modname .. ":menu", menu_formspec())
        return itemstack
    end,
})

-- ITEM: Control SNES
minetest.register_craftitem(modname .. ":controller", {
    description     = "Control SNES",
    inventory_image = "wetlands_snes_controller.png",
})

-- Recetas de crafteo
if minetest.get_modpath("mcl_core") then
    minetest.register_craft({
        output = modname .. ":console",
        recipe = {
            { "mcl_core:iron_ingot", "mcl_core:stone",      "mcl_core:iron_ingot" },
            { "mcl_core:stone",      "mcl_core:stone",      "mcl_core:stone"      },
            { "mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot" },
        },
    })
    minetest.register_craft({
        output = modname .. ":controller 2",
        recipe = {
            { "mcl_core:iron_ingot", "mcl_core:stone", "mcl_core:iron_ingot" },
            { "mcl_core:iron_ingot", "",               "mcl_core:iron_ingot" },
        },
    })
end

minetest.log("action", "[" .. modname .. "] Cargado exitosamente")
