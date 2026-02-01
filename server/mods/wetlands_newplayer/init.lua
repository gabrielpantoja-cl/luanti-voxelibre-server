-- wetlands_newplayer: Privilegios para jugadores nuevos en Wetlands
-- VoxeLibre ignora default_privs de minetest.conf, asi que los otorgamos via mod

local PRIVS = {
	fly = true,
	fast = true,
	noclip = true,
	give = true,
	spawn = true,
	creative = true,
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
	minetest.log("action", "[wetlands_newplayer] Privilegios otorgados a nuevo jugador: " .. name)
end)

minetest.log("action", "[wetlands_newplayer] Mod cargado - privilegios para nuevos jugadores: fly, fast, noclip, give, spawn, creative, interact, shout")
