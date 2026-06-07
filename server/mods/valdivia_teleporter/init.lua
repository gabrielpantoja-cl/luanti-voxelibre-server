-- valdivia_teleporter
-- Teletransportador de ubicaciones de la ciudad de Valdivia (puerto 30001).
-- Un pedestal luminoso (click derecho) y el comando /ir abren un menu para
-- saltar a 4 ubicaciones predefinidas de la ciudad.
-- Apropiado para ninos 7+. Idioma: espanol.

local modname = minetest.get_current_modname()

-- ============================================================================
-- 1. UBICACIONES PREDEFINIDAS
-- ============================================================================
-- Coordenadas verificadas en docs/projects/VALDIVIA_COORDENADAS.md y por el admin.
local DESTINOS = {
    {id = "planeta_azul",  nombre = "Planeta Azul (spawn)", pos = {x = 2389, y = -55, z = -2887}},
    {id = "fundadores",    nombre = "Los Fundadores",       pos = {x = 4360, y = -51, z = -4211}},
    {id = "santa_elena",   nombre = "Santa Elena",          pos = {x = 5844, y = -51, z = -4532}},
    {id = "huachocopihue", nombre = "Huachocopihue",        pos = {x = 3761, y = -43, z = -3170}},
    {id = "ferroviarios",  nombre = "Asociación de Ferroviarios", pos = {x = 5079, y = -50, z = -2076}},
}

local FORMNAME = "valdivia_teleporter:menu"

-- ============================================================================
-- 2. MENU (FORMSPEC)
-- ============================================================================
local function mostrar_menu(player_name)
    if not player_name then return end

    local alto = 1.5 + (#DESTINOS + 1) * 1.0
    local fs = "formspec_version[4]" ..
        "size[8," .. alto .. "]" ..
        "label[0.5,0.7;" .. minetest.formspec_escape("Teletransportador de Valdivia") .. "]"

    local y = 1.4
    for _, d in ipairs(DESTINOS) do
        fs = fs .. "button[0.5," .. y .. ";7,0.8;tp_" .. d.id .. ";" ..
            minetest.formspec_escape(d.nombre) .. "]"
        y = y + 1.0
    end

    fs = fs .. "button_exit[0.5," .. y .. ";7,0.8;cerrar;" ..
        minetest.formspec_escape("Cerrar") .. "]"

    minetest.show_formspec(player_name, FORMNAME, fs)
end

-- ============================================================================
-- 3. TELEPORT
-- ============================================================================
local function teleportar(player, destino)
    if not (player and player:is_player()) then return end
    local name = player:get_player_name()
    player:set_pos(destino.pos)
    minetest.chat_send_player(name, "Teletransportado a " .. destino.nombre .. ".")
    minetest.log("action", "[" .. modname .. "] " .. name ..
        " -> " .. destino.nombre .. " " .. minetest.pos_to_string(destino.pos))
end

-- ============================================================================
-- 4. COMANDO /ir
-- ============================================================================
minetest.register_chatcommand("ir", {
    description = "Abre el teletransportador de Valdivia para viajar a lugares de la ciudad",
    privs = {},
    func = function(name)
        mostrar_menu(name)
        return true
    end,
})

-- ============================================================================
-- 5. HANDLER DEL MENU
-- ============================================================================
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= FORMNAME then return end
    for _, d in ipairs(DESTINOS) do
        if fields["tp_" .. d.id] then
            teleportar(player, d)
            return true
        end
    end
end)

-- ============================================================================
-- 6. NODO PEDESTAL FISICO
-- ============================================================================
minetest.register_node("valdivia_teleporter:pad", {
    description = "Teletransportador de Valdivia",
    tiles = {
        "valdivia_teleporter_top.png",
        "valdivia_teleporter_top.png",
        "valdivia_teleporter_side.png",
    },
    drawtype = "nodebox",
    node_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, -0.1, 0.5}}, -- losa baja, se pisa
    paramtype = "light",
    light_source = 14,            -- brilla para ser descubrible
    walkable = true,
    is_ground_content = false,
    groups = {immovable = 1},
    diggable = false,             -- anti-grief: nadie lo rompe
    on_rightclick = function(pos, node, clicker)
        if clicker and clicker:is_player() then
            mostrar_menu(clicker:get_player_name())
        end
    end,
})

minetest.log("action", "[" .. modname .. "] Loaded successfully")
