-- server/mods/wetlands_mineclonia_trampas/init.lua
--
-- Bloque secreto que parece piedra pero al pisarlo muestra un mensaje
-- amistoso. Diseñado para Mineclonia (puerto 30004) - creativo sin
-- daño, así que es solo un guiño visual/chat, sin knockback ni daño.
--
-- Patrón: el callback de nodo `on_stand` se removió del engine en
-- Luanti 5.14+. Las pressure plates de vanilla ahora usan
-- globalstep + chequeo de posición. Usamos el mismo patrón.

local modname = core.get_current_modname()
local S = core.get_translator(modname)

local COOLDOWN = 5
local POLL_INTERVAL = 0.5
local MESSAGE = "ME ENCANTA JUGAR CONTIGO ❤️"

local trap_positions = {}
local cooldowns = {}

local sound_table = mcl_sounds and mcl_sounds.node_sound_stone_defaults() or {}

core.register_node(":" .. modname .. ":secret_heart", {
	description = S("Bloque Secreto de Cariño"),
	short_description = S("Bloque Secreto"),
	tiles = {"default_stone.png"},
	groups = {pickaxey = 1, stone = 1, handy = 1},
	drop = "mcl_core:cobble",
	is_ground_content = false,
	sounds = sound_table,

	on_construct = function(pos)
		trap_positions[core.pos_to_string(pos)] = true
	end,

	on_destruct = function(pos)
		trap_positions[core.pos_to_string(pos)] = nil
	end,
})

core.register_abm({
	label = modname .. ":scan",
	nodenames = {modname .. ":secret_heart"},
	interval = 5,
	chance = 1,
	action = function(pos)
		trap_positions[core.pos_to_string(pos)] = true
	end,
})

local timer = 0
core.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < POLL_INTERVAL then return end
	timer = 0

	for _, player in ipairs(core.get_connected_players()) do
		local name = player:get_player_name()
		local pos = player:get_pos()
		if pos then
			local bx = math.floor(pos.x + 0.5)
			local by = math.floor(pos.y - 0.5)
			local bz = math.floor(pos.z + 0.5)
			local key = core.pos_to_string({x = bx, y = by, z = bz})

			if trap_positions[key] then
				local now = os.time()
				if not cooldowns[name] or (now - cooldowns[name]) >= COOLDOWN then
					cooldowns[name] = now
					core.chat_send_player(name, core.colorize("#FF69B4", MESSAGE))
					core.add_particlespawner({
						amount = 30,
						time = 0.6,
						pos = {x = bx, y = by + 1, z = bz},
						radius = 0.5,
						texture = modname .. "_heart.png",
						exptime = 1,
						glow = 14,
					})
				end
			end
		end
	end
end)

core.register_on_leaveplayer(function(player)
	cooldowns[player:get_player_name()] = nil
end)
