local modname = minetest.get_current_modname()

local PRIVS = {
	interact  = true,
	shout     = true,
	creative  = true,
	fast      = true,
	spawn     = true,
	teleport  = true,
}

minetest.register_on_newplayer(function(player)
	local name = player:get_player_name()
	-- minetest.after(0) para correr DESPUES de que el engine aplique default_privs
	minetest.after(0, function()
		minetest.set_player_privs(name, PRIVS)
		minetest.log("action", "[" .. modname .. "] Privilegios otorgados a " .. name)
	end)
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully")
