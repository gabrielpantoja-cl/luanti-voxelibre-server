-- wetlands_motd
-- Mensaje de bienvenida personalizado y multiidioma para Wetlands 30000.
-- Se muestra al conectar, en el idioma del cliente (inglés por defecto, español si está configurado).

local modname = minetest.get_current_modname()

-- MOTD principal en inglés (default para todos los clientes)
local MOTD_EN = table.concat({
	"Welcome to the original world of pepelomo and gabo 🌿",
	"Kid-friendly survival: gather, build and explore with us.",
	"If you found us by chance, you are welcome here.",
	"Please play with kindness and respect.",
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
			"¡Bienvenido al mundo original de pepelomo y gabo 🌿",
			"Supervivencia amistosa para niños: recolecta, construye y explora con nosotros.",
			"Si encontraste este mundo por casualidad, eres bienvenido.",
			"Por favor juega con amabilidad y respeto.",
			"Lee /reglas para las guías completas.",
		}, "\n")) or
		minetest.colorize("#A0A0A0", MOTD_EN)

	minetest.chat_send_player(name, motd_text)
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully")
