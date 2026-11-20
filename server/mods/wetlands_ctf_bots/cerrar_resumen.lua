-- Boton "Cerrar" en la pantalla de puntaje (resumen) del CTF.
--
-- El resumen de fin de partida (ctf_modebase/summary.lua, formulario
-- "ctf_modebase:summary") no trae boton de cierre: en PC se sale con Esc, pero
-- en celular no hay Esc y la pantalla quedaba atrapada. Para no tocar el juego
-- (server/games/capturetheflag esta en .gitignore y se pierde al actualizarlo)
-- envolvemos ctf_gui.show_formspec y le agregamos un button_exit al formspec
-- que arma el resumen. Funciona tambien con /summary y al refrescar (ordenar,
-- ver anterior/siguiente), porque ctf_gui guarda la funcion envuelta.

local FORM_RESUMEN = "ctf_modebase:summary"

local function con_boton(fs)
	if type(fs) ~= "string" then return fs end
	local ancho = tonumber(fs:match("size%[([%d%.]+),"))
	if not ancho then return fs end
	return fs .. string.format("button_exit[%.1f,0.3;3,1;wetlands_cerrar;Cerrar]", ancho - 3.3)
end

minetest.register_on_mods_loaded(function()
	if not (minetest.global_exists("ctf_gui") and type(ctf_gui.show_formspec) == "function") then
		minetest.log("warning", "[wetlands_ctf_bots] ctf_gui no encontrado: el resumen queda sin boton Cerrar")
		return
	end
	local original = ctf_gui.show_formspec
	ctf_gui.show_formspec = function(player, formname, formspec, formcontext)
		if formname == FORM_RESUMEN then
			if type(formspec) == "function" then
				local armar = formspec
				formspec = function(...) return con_boton(armar(...)) end
			else
				formspec = con_boton(formspec)
			end
		end
		return original(player, formname, formspec, formcontext)
	end
end)
