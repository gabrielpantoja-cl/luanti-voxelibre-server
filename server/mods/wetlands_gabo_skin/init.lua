-- server/mods/wetlands_gabo_skin/init.lua
-- Disfraz completo del admin "gabo" en GAELSIN: skin de Enderman + nametag
-- invisible. Asi los demas jugadores no pueden identificarlo.
--
-- Textura: se sirve al cliente desde _world_folder_media
--   (server/worlds/gaelsin/_world_folder_media/textures/enderman.png).
-- Solo se aplica a "gabo" y NO aparece en el menu /skin del resto.
--
-- Tecnica del skin (mcl_skins):
--   1. mcl_skins.register_simple_skin() deja la textura en
--      texture_to_simple_skin (lookup usado por update_player_skin).
--   2. Quitamos la entrada de simple_skins para que no se muestre en /skin
--      del resto de jugadores.
--   3. En on_joinplayer, si el jugador es "gabo", forzamos
--      simple_skins_id = "enderman.png" y llamamos update_player_skin().
--
-- Tecnica del nametag (set_nametag_attributes):
--   1. text="" + color.a=0 = invisible para TODOS los que miren (Luanti no
--      tiene nametag per-viewer; lo ve el server entero o nadie).
--   2. Se aplica inmediatamente en on_joinplayer (no necesita delay).
--   3. Se re-aplica en on_respawnplayer por si VoxeLibre resetea el nametag
--      al respawnear.

local modname = minetest.get_current_modname()

local SKIN_OWNER = "gabo"
local SKIN_TEXTURE = "enderman.png"
local SKIN_SLIM_ARMS = false

-- ColorSpec invisible (alpha 0). El RGB no importa cuando alpha es 0.
local INVISIBLE_NAMETAG = {
	text = "",
	color = { a = 0, r = 255, g = 255, b = 255 },
}

local function apply_gabo_skin(player)
	if not mcl_skins or not mcl_skins.player_skins then
		return false
	end
	local player_skins = mcl_skins.player_skins[player]
	if not player_skins then
		return false
	end
	player_skins.simple_skins_id = SKIN_TEXTURE
	player_skins.slim_arms = SKIN_SLIM_ARMS
	mcl_skins.update_player_skin(player)
	mcl_skins.save(player)
	return true
end

local function hide_gabo_nametag(player)
	if not player or not player:is_player() then
		return false
	end
	player:set_nametag_attributes(INVISIBLE_NAMETAG)
	return true
end

if mcl_skins then
	mcl_skins.register_simple_skin({
		texture = SKIN_TEXTURE,
		slim_arms = SKIN_SLIM_ARMS,
	})

	for i = #mcl_skins.simple_skins, 1, -1 do
		if mcl_skins.simple_skins[i].texture == SKIN_TEXTURE then
			table.remove(mcl_skins.simple_skins, i)
		end
	end

	minetest.log("action", "[" .. modname .. "] Skin '" .. SKIN_TEXTURE .. "' registrado (oculto del menu /skin)")
end

minetest.register_on_joinplayer(function(player)
	if player:get_player_name() ~= SKIN_OWNER then
		return
	end
	-- Nametag: hide inmediatamente (no depende de mcl_skins ni de delays).
	if hide_gabo_nametag(player) then
		minetest.log("action", "[" .. modname .. "] Nametag de " .. SKIN_OWNER .. " ocultado al entrar")
	end
	-- Skin: deferir 0.5s para que mcl_skins haya inicializado player_skins.
	minetest.after(0.5, function()
		local p = minetest.get_player_by_name(SKIN_OWNER)
		if p and apply_gabo_skin(p) then
			minetest.log("action", "[" .. modname .. "] Skin '" .. SKIN_TEXTURE .. "' aplicado a " .. SKIN_OWNER)
		end
	end)
end)

-- Re-aplicar el nametag al respawnear, por si VoxeLibre lo resetea.
minetest.register_on_respawnplayer(function(player)
	if player:get_player_name() ~= SKIN_OWNER then
		return
	end
	minetest.after(0.1, function()
		local p = minetest.get_player_by_name(SKIN_OWNER)
		if p and hide_gabo_nametag(p) then
			minetest.log("action", "[" .. modname .. "] Nametag de " .. SKIN_OWNER .. " re-ocultado tras respawn")
		end
	end)
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully - disfraz completo (skin + nametag) para " .. SKIN_OWNER .. " (world: gaelsin)")
