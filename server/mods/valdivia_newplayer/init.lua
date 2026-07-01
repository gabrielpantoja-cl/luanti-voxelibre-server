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
--
-- IMPORTANTE: mcl_privs/init.lua (VoxeLibre) otorga fly automaticamente a cualquier
-- jugador con is_creative_enabled()=true, a menos que la metadata
-- "mcl_privs:fly_changed"=1 indique que el fly fue gestionado manualmente.
-- Sin esta segunda flag, todos los jugadores en modo creativo recibian fly al conectarse.
minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()
	meta:set_string("gamemode", "creative")
	meta:set_int("mcl_privs:fly_changed", 1)
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully")
