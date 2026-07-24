-- server/mods/wetlands_gabo_skin/init.lua
-- Skin personal "Enderman" del admin "gabo" en GAELSIN.
--
-- La textura se carga en el cliente desde _world_folder_media
-- (server/worlds/gaelsin/_world_folder_media/textures/enderman.png).
-- Solo se aplica al jugador "gabo" y NO aparece en el menu /skin del resto.
--
-- Tecnica:
--   1. mcl_skins.register_simple_skin() deja la textura en
--      texture_to_simple_skin (lookup usado por update_player_skin).
--   2. Quitamos la entrada de simple_skins para que no se muestre en /skin
--      del resto de jugadores.
--   3. En on_joinplayer, si el jugador es "gabo", forzamos
--      simple_skins_id = "enderman.png" y llamamos update_player_skin().

local modname = minetest.get_current_modname()

local SKIN_OWNER = "gabo"
local SKIN_TEXTURE = "enderman.png"
local SKIN_SLIM_ARMS = false

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

	minetest.register_on_joinplayer(function(player)
		local name = player:get_player_name()
		if name ~= SKIN_OWNER then
			return
		end
		-- mcl_skins corre su propio on_joinplayer antes que nosotros, pero
		-- deferimos un instante para asegurar que player_skins esta listo.
		minetest.after(0.5, function()
			local p = minetest.get_player_by_name(SKIN_OWNER)
			if p and apply_gabo_skin(p) then
				minetest.log("action", "[" .. modname .. "] Skin '" .. SKIN_TEXTURE .. "' aplicado a " .. SKIN_OWNER)
			end
		end)
	end)
end

minetest.log("action", "[" .. modname .. "] Loaded successfully - skin personal para " .. SKIN_OWNER .. " (world: gaelsin)")
