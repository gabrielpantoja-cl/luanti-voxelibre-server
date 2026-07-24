-- wetlands_newplayer: Privilegios para jugadores nuevos en Wetlands
-- VoxeLibre ignora default_privs de minetest.conf, asi que los otorgamos via mod
--
-- Ademas (2026-07-24): bienvenida plant-based en CADA join + comando /veganinfo
-- para que los jugadores vean que mods veganos estan activos.

local modname = minetest.get_current_modname()

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

local VEGAN_WELCOME = {
	"🌱 ¡Bienvenid@ a Wetlands!",
	"   Servidor compassivo y plant-based.",
	"   Construimos un mundo basado en plantas, sin items de origen animal.",
	"   Tip: /reglas para las reglas, /veganinfo para ver los mods activos.",
}

local VEGAN_MODS = {
	{mod = "vegan_food",          desc = "Recetas plant-based: tofu, seitan, notfish, plant milk, syrups"},
	{mod = "vegan_replacements",  desc = "Elimina 13 items animales (carne, cuero, etc.) y los reemplaza con alternativas vegetales"},
	{mod = "education_blocks",    desc = "Bloques y comandos educativos sobre compasión y sostenibilidad"},
	{mod = "wetlands_no_creeper", desc = "Bloquea creepers para mantener la paz nocturna"},
}

-- Mensaje de bienvenida + privs para jugadores NUEVOS
minetest.register_on_newplayer(function(player)
	local name = player:get_player_name()
	local current = minetest.get_player_privs(name)

	for priv, _ in pairs(PRIVS) do
		current[priv] = true
	end

	minetest.set_player_privs(name, current)
	minetest.log("action", "[" .. modname .. "] Privilegios otorgados a nuevo jugador: " .. name)
end)

-- Mensaje plant-based en CADA join (no solo primer join)
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	for _, line in ipairs(VEGAN_WELCOME) do
		minetest.chat_send_player(name, line)
	end
end)

-- Comando /veganinfo: muestra los mods veganos activos y resumen
minetest.register_chatcommand("veganinfo", {
	description = "Muestra los mods plant-based/veganos activos en el servidor",
	func = function(name, param)
		minetest.chat_send_player(name, "🌱 INFORMACIÓN PLANT-BASED DE WETLANDS")
		minetest.chat_send_player(name, "")
		minetest.chat_send_player(name, "Wetlands es un servidor compassivo con compromiso")
		minetest.chat_send_player(name, "plant-based: promovemos alternativas vegetales y")
		minetest.chat_send_player(name, "reemplazamos items de origen animal.")
		minetest.chat_send_player(name, "")
		minetest.chat_send_player(name, "📦 Mods activos que mantienen este compromiso:")
		for _, entry in ipairs(VEGAN_MODS) do
			minetest.chat_send_player(name, "  • " .. entry.mod .. " — " .. entry.desc)
		end
		minetest.chat_send_player(name, "")
		minetest.chat_send_player(name, "📖 Más info: /reglas  |  🌐 Filosofía: docs/01-ORIGINAL-30000/VEGAN_PHILOSOPHY.md")
		return true
	end,
})

minetest.log("action", "[" .. modname .. "] Mod cargado - privilegios para nuevos jugadores: fly, fast, noclip, give, spawn, creative, interact, shout")
minetest.log("action", "[" .. modname .. "] Mensaje plant-based + comando /veganinfo activos")
