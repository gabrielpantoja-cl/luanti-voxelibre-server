-- wetlands_gaelsin_newplayer: Privilegios para jugadores nuevos en GAELSIN (supervivencia)
-- VoxeLibre ignora default_privs de minetest.conf, asi que los otorgamos via mod.
-- A diferencia de Wetlands, aqui solo damos interact y shout (juego de supervivencia).

local modname = minetest.get_current_modname()

local PRIVS = {
	interact = true,
	shout = true,
}

minetest.register_on_newplayer(function(player)
	local name = player:get_player_name()
	local current = minetest.get_player_privs(name)

	for priv, _ in pairs(PRIVS) do
		current[priv] = true
	end

	minetest.set_player_privs(name, current)
	minetest.log("action", "[" .. modname .. "] Privilegios de supervivencia otorgados a nuevo jugador: " .. name)
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully - privilegios para nuevos jugadores: interact, shout")
