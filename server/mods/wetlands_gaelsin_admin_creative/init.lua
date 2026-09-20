-- wetlands_gaelsin_admin_creative
-- Solo para el mundo GAELSIN (puerto 30002).
-- Otorga inventario creativo + privilegios admin a un jugador en whitelist,
-- sin tocar al resto (que mantiene los privilegios de supervivencia del mod
-- `wetlands_gaelsin_newplayer`).
--
-- Por defecto solo `gabo` recibe el tratamiento. Para añadir otros admins,
-- ampliar `ADMIN_NAMES` (consistente con el resto del servidor).

local modname = minetest.get_current_modname()

-- Lista de jugadores que reciben inventario creativo + privilegios admin.
-- Mantener sincronizado con `admin_name` en server/config/luanti-gaelsin.conf.
local ADMIN_NAMES = {
	gabo = true,
}

-- Privilegios que `name = gabo` debe tener para usar el mundo como admin.
-- Es un superconjunto de `admin_privs` en luanti-gaelsin.conf (incluye
-- `creative` y `fly`, que alli faltan). El conf hace grant al primer join;
-- este mod aplica el set completo cada vez que el admin entra.
local ADMIN_PRIVS = {
	interact = true,
	shout = true,
	teleport = true,
	home = true,
	spawn = true,
	creative = true,
	give = true,
	fly = true,
	fast = true,
	noclip = true,
	worldedit = true,
	server = true,
	privs = true,
	ban = true,
	kick = true,
	settime = true,
	debug = true,
	password = true,
	-- `rollback_check` NO es un privilegio de Luanti. /rollback_check y
	-- /rollback exigen ambos `rollback` (builtin/game/chat.lua).
	rollback = true,
}

-- Garantiza que el jugador vea el inventario creativo de VoxeLibre/Mineclonia.
-- La metadata `gamemode = "creative"` es lo que consulta `is_creative_enabled`
-- cuando el engine no esta en creative global (mcl_gamemode/init.lua:30).
local function apply_admin_gamemode(name)
	local player = minetest.get_player_by_name(name)
	if not player then
		return
	end
	player:get_meta():set_string("gamemode", "creative")
end

local function is_admin(name)
	return ADMIN_NAMES[name] == true
end

local function grant_admin(name)
	if not is_admin(name) then
		return
	end

	local current = minetest.get_player_privs(name)
	for priv, _ in pairs(ADMIN_PRIVS) do
		current[priv] = true
	end
	minetest.set_player_privs(name, current)

	apply_admin_gamemode(name)

	minetest.log("action", "[" .. modname .. "] Admin creativo aplicado a " .. name)
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if is_admin(name) then
		-- Aplica despues de que el engine termine de inicializar al jugador,
		-- para que la metadata no sea pisada por otro mod del mismo join.
		minetest.after(0, grant_admin, name)
	end
end)

-- Cubre el caso raro: admin logueado cuando se hace /reload o carga el mod.
minetest.register_on_mods_loaded(function()
	for _, player in ipairs(minetest.get_connected_players()) do
		grant_admin(player:get_player_name())
	end
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully - admin whitelist: " .. table.concat((function()
	local t = {}
	for n in pairs(ADMIN_NAMES) do t[#t + 1] = n end
	return t
end)(), ", "))
