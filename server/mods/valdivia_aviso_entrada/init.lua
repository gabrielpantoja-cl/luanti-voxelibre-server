-- valdivia_aviso_entrada: cuando un jugador entra a Valdivia, los que ya estan
-- conectados ven un aviso "<nombre> entrando..." arriba a la izquierda durante
-- unos segundos. El que entra no lo ve. Si entran varios seguidos, los avisos se
-- apilan (maximo MAX_LINES; el mas antiguo cede su lugar).
--
-- Este mod SOLO se carga en Valdivia (load_mod_valdivia_aviso_entrada en
-- luanti-valdivia.conf y world.mt). Complementa el "*** X joined the game" del
-- chat, que se pierde facil entre otros mensajes.

local modname = minetest.get_current_modname()

local DURATION = 6          -- segundos que dura cada aviso
local MAX_LINES = 5         -- avisos simultaneos por jugador
local LINE_HEIGHT = 24      -- px entre avisos apilados
-- Arriba a la izquierda, pero bajo las primeras lineas del chat (que tambien
-- vive arriba a la izquierda) para no taparlo. Subir/bajar con POSITION.y.
local POSITION = {x = 0, y = 0.22}
local OFFSET_X = 12
local COLOR = 0xFFD966      -- amarillo, igual que la bienvenida de valdivia_spawn_npc

local avisos = {}  -- nombre del que mira -> lista de {id = hud_id}

local function reordenar(player, list)
    for i, aviso in ipairs(list) do
        player:hud_change(aviso.id, "offset", {x = OFFSET_X, y = (i - 1) * LINE_HEIGHT})
    end
end

local function quitar(viewer_name, aviso)
    local player = minetest.get_player_by_name(viewer_name)
    local list = avisos[viewer_name]
    if not player or not list then return end
    for i, a in ipairs(list) do
        if a == aviso then
            player:hud_remove(a.id)
            table.remove(list, i)
            reordenar(player, list)
            return
        end
    end
end

local function mostrar(viewer, texto)
    local name = viewer:get_player_name()
    local list = avisos[name]
    if not list then
        list = {}
        avisos[name] = list
    end
    if #list >= MAX_LINES then
        viewer:hud_remove(table.remove(list, 1).id)
    end
    local id = viewer:hud_add({
        type = "text",
        position = POSITION,
        alignment = {x = 1, y = 1},
        offset = {x = OFFSET_X, y = #list * LINE_HEIGHT},
        text = texto,
        number = COLOR,
        style = 1,  -- negrita
        z_index = 100,
    })
    if not id then return end
    local aviso = {id = id}
    table.insert(list, aviso)
    reordenar(viewer, list)
    minetest.after(DURATION, quitar, name, aviso)
end

minetest.register_on_joinplayer(function(player)
    local joiner = player:get_player_name()
    local texto = joiner .. " entrando..."
    for _, other in ipairs(minetest.get_connected_players()) do
        if other:get_player_name() ~= joiner then
            mostrar(other, texto)
        end
    end
end)

-- Los HUD se pierden al desconectarse; los minetest.after pendientes no
-- encuentran su aviso en la lista nueva y no hacen nada.
minetest.register_on_leaveplayer(function(player)
    avisos[player:get_player_name()] = nil
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully")
