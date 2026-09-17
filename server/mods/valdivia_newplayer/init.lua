local modname = minetest.get_current_modname()

-- El unico jugador que puede volar / tiene todos los privilegios.
local ADMIN = "gabo"

-- Set de privilegios para TODOS los jugadores no-admin en Valdivia.
-- Sin fly, sin noclip, sin give. Con fast. Sin creative (supervivencia).
-- El privilege 'creative' solo se concede al admin 'gabo'.
local PRIVS = {
	interact  = true,
	shout     = true,
	-- creative  = true,   ← quitado: modo supervivencia para jugadores normales
	fast      = true,
	spawn     = true,
	teleport  = true,
}

-- Aplica el estado deseado a un jugador no-admin: gamemode creativo (inventario full)
-- y el set exacto de privilegios (sin fly). Corre en cada join.
--
-- Por que en cada join y con minetest.after(0):
--   * mcl_privs/init.lua (VoxeLibre) tiene su propio register_on_joinplayer que OTORGA
--     fly a cualquier jugador con is_creative_enabled()=true (que es true porque seteamos
--     gamemode=creative para el inventario). Ese callback puede correr DESPUES del nuestro.
--   * minetest.after(0) difiere nuestra logica al siguiente game step, ya despues de que
--     TODOS los callbacks de join sincronos (incluido mcl_privs) terminaron. Asi nuestro
--     set de privilegios es el ultimo en escribirse y siempre gana.
--   * Imponerlo en cada join lo hace auto-reparable: aunque la DB tenga un fly viejo
--     (por un writeback de privs cacheados al desconectarse), el proximo join lo limpia.
local function enforce_state(name)
	local meta_player = minetest.get_player_by_name(name)
	if not meta_player then return end
	local meta = meta_player:get_meta()

	if name == ADMIN then
		-- Admin: inventario creativo + fly gestionado manualmente.
		meta:set_string("gamemode", "creative")
		meta:set_int("mcl_privs:fly_changed", 1)
		minetest.set_player_privs(name, {interact=true, shout=true, fast=true, creative=true, fly=true, spawn=true, teleport=true})
		minetest.log("action", "[" .. modname .. "] Privilegios completos para admin " .. name)
		return
	end

	-- Jugadores normales: modo supervivencia, sin creative, sin fly.
	-- No se setea gamemode (queda en survival por defecto en VoxeLibre).
	-- Marca fly como "gestionado manualmente" por si acaso.
	meta:set_int("mcl_privs:fly_changed", 1)

	minetest.set_player_privs(name, PRIVS)
	-- 1. Quitar privilegio creativo directamente de su perfil guardado
	local player_privs = minetest.get_player_privs(name)
	if player_privs.creative then
		player_privs.creative = nil
		minetest.set_player_privs(name, player_privs)
	end
	-- 2. Forzar la interfaz de supervivencia usando la API de VoxeLibre
	if mcl_gamemode then
		mcl_gamemode.set_gamemode(name, "survival")
	end
	minetest.log("action", "[" .. modname .. "] Privilegios impostos a " .. name .. " (modo supervivencia, sin fly)")
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	minetest.after(0, function()
		enforce_state(name)
	end)
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully")
