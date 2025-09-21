-- Mod de reglas del servidor Wetlands
-- Comando /reglas para mostrar las reglas completas

minetest.register_chatcommand("reglas", {
    description = "Muestra las reglas del servidor",
    func = function(name, param)
        local reglas = {
            "🌱 REGLAS DE WETLANDS 🌱",
            "",
            "📝 REGLAS BÁSICAS (OBLIGATORIAS):",
            "",
            "1. 🚫 NO MOLESTAR A OTROS JUGADORES",
            "   - No destruir construcciones ajenas",
            "   - No seguir o acosar a otros jugadores",
            "   - Respeta el espacio personal",
            "",
            "2. 👤 USA UN NOMBRE APROPIADO",
            "   - Nada de nombres random como 'player123'",
            "   - Elige un nombre que te represente",
            "   - Sin palabras ofensivas",
            "",
            "3. 🤝 NO ECHAR A OTROS SIN RAZÓN",
            "   - Este es un espacio para todos",
            "   - Reporta problemas a moderadores",
            "   - Sé amable y tolerante",
            "",
            "4. 💬 CHAT RESPETUOSO",
            "   - Lenguaje apropiado (niños 7+)",
            "   - No spam ni mensajes repetitivos",
            "   - Ayuda a crear ambiente positivo",
            "",
            "5. 🌱 ESPÍRITU COMPASIVO",
            "   - Cuida a los animales del servidor",
            "   - Comparte y ayuda a otros",
            "   - Disfruta construyendo juntos",
            "",
            "⚠️ CONSECUENCIAS:",
            "1ra vez: Advertencia",
            "2da vez: Silencio temporal",
            "3ra vez: Expulsión temporal",
            "4ta vez: Baneo permanente",
            "",
            "¡Diviértanse y sean compasivos! 🎮💚"
        }

        for _, linea in ipairs(reglas) do
            minetest.chat_send_player(name, linea)
        end

        return true
    end
})

-- Comando corto /r para reglas rápidas
minetest.register_chatcommand("r", {
    description = "Reglas rápidas del servidor",
    func = function(name, param)
        local reglas_cortas = {
            "🌱 REGLAS RÁPIDAS:",
            "1) No molestar 2) Nombre apropiado",
            "3) Respeto 4) Chat limpio 5) Ser compasivo",
            "Usa /reglas para ver todas las reglas"
        }

        for _, linea in ipairs(reglas_cortas) do
            minetest.chat_send_player(name, linea)
        end

        return true
    end
})

-- Mostrar reglas automáticamente a TODOS los jugadores al conectarse
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()

    minetest.after(3, function()
        -- Mensaje de bienvenida personalizado
        minetest.chat_send_player(name, "🌱 ¡Bienvenid@ a Wetlands, " .. name .. "!")
        minetest.chat_send_player(name, "")

        -- Reglas básicas automáticas
        minetest.chat_send_player(name, "📋 REGLAS BÁSICAS:")
        minetest.chat_send_player(name, "1) 🚫 No molestar a otros jugadores")
        minetest.chat_send_player(name, "2) 👤 Usa un nombre apropiado")
        minetest.chat_send_player(name, "3) 🤝 Respeta a todos")
        minetest.chat_send_player(name, "4) 💬 Chat limpio (niños 7+)")
        minetest.chat_send_player(name, "5) 🌱 Sé compasivo con los animales")
        minetest.chat_send_player(name, "")

        -- Comandos útiles
        minetest.chat_send_player(name, "⚡ COMANDOS ÚTILES:")
        minetest.chat_send_player(name, "• /reglas - Ver reglas completas")
        minetest.chat_send_player(name, "• /filosofia - Conocer nuestra misión")
        minetest.chat_send_player(name, "• /santuario - Info sobre cuidado animal")
        minetest.chat_send_player(name, "")
        minetest.chat_send_player(name, "🎮 ¡Disfruta construyendo en nuestro mundo compasivo!")
    end)
end)

-- Mostrar mensaje especial adicional para jugadores nuevos
minetest.register_on_newplayer(function(player)
    local name = player:get_player_name()

    minetest.after(8, function()
        minetest.chat_send_player(name, "")
        minetest.chat_send_player(name, "🌟 ¡Eres nuevo en Wetlands! 🌟")
        minetest.chat_send_player(name, "Este es un servidor educativo y compasivo.")
        minetest.chat_send_player(name, "Aquí aprendemos sobre respeto hacia los animales")
        minetest.chat_send_player(name, "y disfrutamos construyendo sin violencia.")
        minetest.chat_send_player(name, "")
        minetest.chat_send_player(name, "🎯 Consejos para comenzar:")
        minetest.chat_send_player(name, "• Explora y observa los animales con respeto")
        minetest.chat_send_player(name, "• Construye refugios bonitos para ellos")
        minetest.chat_send_player(name, "• Prueba alimentos veganos como tofu y seitan")
        minetest.chat_send_player(name, "• Haz amigos y construyan juntos")
    end)
end)

-- Comando /santuario para información sobre cuidado animal
minetest.register_chatcommand("santuario", {
    description = "Información sobre el cuidado de animales en santuarios",
    func = function(name, param)
        local santuario_info = {
            "🌱 SANTUARIOS ANIMALES EN WETLANDS 🐾",
            "",
            "🏡 ¿QUÉ ES UN SANTUARIO?",
            "Un lugar seguro donde los animales viven libres,",
            "sin ser usados, solo respetados y cuidados.",
            "",
            "🐮 ANIMALES EN NUESTRO MUNDO:",
            "• Vacas felices pastando libremente",
            "• Cerdos jugando en el barro sin preocupaciones",
            "• Gallinas corriendo por prados verdes",
            "• Cabras saltando en colinas soleadas",
            "",
            "💚 CÓMO CUIDARLOS:",
            "• Obsérvalos con respeto y cariño",
            "• Construye refugios cómodos para ellos",
            "• Planta pastos y cultivos para su alimento",
            "• Protege sus espacios de vida",
            "",
            "🌾 ALIMENTACIÓN COMPASIVA:",
            "Disfruta alimentos deliciosos a base de plantas:",
            "tofu, seitan, leche de avena, frutas y verduras.",
            "",
            "¡Construyamos un mundo donde todos prosperemos! 🌈"
        }

        for _, linea in ipairs(santuario_info) do
            minetest.chat_send_player(name, linea)
        end

        return true
    end
})

-- Recordatorio periódico de reglas (cada 15 minutos)
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 900 then -- 15 minutos = 900 segundos
        timer = 0
        minetest.chat_send_all("🌱 Recordatorio: Usa /reglas para ver las reglas del servidor. ¡Mantengamos un ambiente compasivo!")
    end
end)