-- wetlands_teleporter
-- Teletransportador de ubicaciones clave de Wetlands (puerto 30000).
-- Un pedestal luminoso (click derecho) y el comando /irt abren un menu para
-- saltar a 2 ubicaciones: spawn actual y spawn histórico.
-- Apropiado para niños 7+. Idioma: español.

local modname = minetest.get_current_modname()

-- ============================================================================
-- 1. UBICACIONES PREDEFINIDAS
-- ============================================================================
local DESTINOS = {
	{id = "spawn_actual",    nombre = "Spawn Actual",    pos = {x = 655.1, y = 18.5, z = 243.9}},
	{id = "spawn_historico", nombre = "Spawn Histórico", pos = {x = 0, y = 15, z = 0}},
}

local FORMNAME = "wetlands_teleporter:menu"

-- ============================================================================
-- 2. MENU (FORMSPEC)
-- ============================================================================
local function mostrar_menu(player_name)
	if not player_name then return end

	local alto = 1.5 + (#DESTINOS + 1) * 1.0
	local fs = "formspec_version[4]" ..
		"size[8," .. alto .. "]" ..
		"label[0.5,0.7;" .. minetest.formspec_escape("Teletransportador de Wetlands") .. "]"

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
-- 4. COMANDO /irt
-- ============================================================================
minetest.register_chatcommand("irt", {
	description = "Abre el teletransportador de Wetlands para viajar a ubicaciones clave",
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
minetest.register_node("wetlands_teleporter:pad", {
	description = "Teletransportador de Wetlands",
	tiles = {
		"valdivia_teleporter_top.png",
		"valdivia_teleporter_top.png",
		"valdivia_teleporter_side.png",
	},
	drawtype = "nodebox",
	node_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, -0.1, 0.5}},
	paramtype = "light",
	light_source = 14,
	walkable = true,
	is_ground_content = false,
	groups = {immovable = 1},
	diggable = false,
	on_rightclick = function(pos, node, clicker)
		if clicker and clicker:is_player() then
			mostrar_menu(clicker:get_player_name())
		end
	end,
})

minetest.log("action", "[" .. modname .. "] Loaded successfully")
