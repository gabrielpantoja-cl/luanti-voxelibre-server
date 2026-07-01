local modname = minetest.get_current_modname()

local PRIVS = {
	interact  = true,
	shout     = true,
	creative  = true,
	fast      = true,
	spawn     = true,
	teleport  = true,
}

-- Privilegios para jugadores nuevos
-- minetest.after(0) para correr DESPUES de que el engine aplique default_privs
minetest.register_on_newplayer(function(player)
	local name = player:get_player_name()
	minetest.after(0, function()
		minetest.set_player_privs(name, PRIVS)
		minetest.log("action", "[" .. modname .. "] Privilegios otorgados a " .. name)
	end)
end)

-- Inventario creativo para todos los jugadores al conectarse.
-- VoxeLibre con creative_mode=false ignora el privilegio "creative" de Luanti:
-- usa su propio sistema de gamemode por jugador (metadata "gamemode"="creative").
-- Sin esto, el inventario creativo no aparece aunque el jugador tenga el privilegio.
minetest.register_on_joinplayer(function(player)
	player:get_meta():set_string("gamemode", "creative")
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully")
