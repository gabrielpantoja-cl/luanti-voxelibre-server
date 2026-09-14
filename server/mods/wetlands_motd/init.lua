-- wetlands_motd
-- Mensaje de bienvenida personalizado y multiidioma para Wetlands 30000.
-- Se muestra al conectar, en el idioma del cliente (inglés por defecto, español si está configurado).

local modname = minetest.get_current_modname()

-- MOTD principal en inglés (default para todos los clientes)
local MOTD_EN = table.concat({
	"Welcome to Wetlands 🌿 — the oldest and most beloved world of this server!",
	"",
	"This is a kid-friendly, plant-based survival playground.",
	"We build together with compassion and respect.",
	"",
	"If you're new or returning, we're happy you're here.",
	"Read /reglas for full guidelines.",
}, "\n")

-- Hook: mostrar MOTD al conectar
minetest.register_on_joinplayer(function(player)
	if not player or not player:is_player() then return end

	local name = player:get_player_name()
	-- Mostrar el MOTD como chat del sistema (color gris claro para que se destaque)
	-- S() busca la clave en el idioma del cliente; si no existe, devuelve la clave misma
	local motd_text = minetest.get_player_information(name).lang_code == "es" and
		minetest.colorize("#A0A0A0", table.concat({
			"Bienvenido a Wetlands 🌿 — ¡el mundo más antiguo y especial de este servidor!",
			"",
			"Este es un mundo amistoso para niños, basado en plantas, de supervivencia creativa.",
			"Construimos juntos con compasión y respeto.",
			"",
			"Si eres nuevo o regresas, ¡nos alegra que estés aquí!",
			"Lee /reglas para las guías completas.",
		}, "\n")) or
		minetest.colorize("#A0A0A0", MOTD_EN)

	minetest.chat_send_player(name, motd_text)
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully")
