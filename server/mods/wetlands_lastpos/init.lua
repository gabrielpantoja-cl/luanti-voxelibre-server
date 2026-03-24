-- wetlands_lastpos/init.lua
-- Guarda la última posición del jugador al desconectarse
-- y lo teletransporta ahí al reconectarse.
-- Jugadores NUEVOS (sin posición guardada) quedan en el static_spawnpoint del minetest.conf

local STORAGE_KEY = "wetlands_lastpos:pos"

-- Al desconectarse: guardar posición actual
minetest.register_on_leaveplayer(function(player, timed_out)
	local name = player:get_player_name()
	local pos = player:get_pos()
	if not pos then return end

	local meta = player:get_meta()
	meta:set_string(STORAGE_KEY, minetest.pos_to_string(pos))
	minetest.log("action", "[wetlands_lastpos] Posición guardada para " .. name ..
		" en " .. minetest.pos_to_string(pos))
end)

-- Al conectarse: restaurar posición si existe (jugador antiguo)
-- Jugadores nuevos no tienen la clave guardada → quedan en spawn estático
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local meta = player:get_meta()
	local pos_str = meta:get_string(STORAGE_KEY)

	if pos_str and pos_str ~= "" then
		local pos = minetest.string_to_pos(pos_str)
		if pos then
			-- Pequeño delay para que el cliente termine de cargar antes de mover al jugador
			minetest.after(0.5, function()
				local p = minetest.get_player_by_name(name)
				if p then
					p:set_pos(pos)
					minetest.log("action", "[wetlands_lastpos] " .. name ..
						" teletransportado a última posición: " .. pos_str)
				end
			end)
		end
	else
		minetest.log("action", "[wetlands_lastpos] " .. name ..
			" es jugador nuevo, aparece en spawn estático.")
	end
end)

minetest.log("action", "[wetlands_lastpos] Mod cargado - jugadores antiguos regresan a su última posición.")
