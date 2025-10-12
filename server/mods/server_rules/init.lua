-- Mod de reglas del servidor Wetlands v2.0
-- Sistema completo de reglas, bienvenida y filosofía compasiva
-- Compatible con VoxeLibre siguiendo patrón de back_to_spawn

-- Declarar traductor para futuro soporte multiidioma
local S = minetest.get_translator('server_rules')

minetest.register_chatcommand("reglas", {
    description = "Muestra las reglas del servidor",
    func = function(name, param)
        local reglas = {
            "🌱 REGLAS DE WETLANDS 🌱",
            "",
            "🏠 SERVIDOR EDUCATIVO Y COMPASIVO",
            "Diseñado especialmente para niños 7+ años",
            "Mundo pacífico sin violencia, solo diversión",
            "",
            "📝 REGLAS BÁSICAS (OBLIGATORIAS):",
            "",
            "1. 🚫 NO MOLESTAR A OTROS JUGADORES",
            "   - No destruir construcciones ajenas",
            "   - No seguir o acosar a otros jugadores",
            "   - Respeta el espacio personal de cada uno",
            "",
            "2. 👤 USA UN NOMBRE APROPIADO",
            "   - Nada de nombres random como 'player123' o 'guest456'",
            "   - Elige un nombre que te represente",
            "   - Sin palabras ofensivas o inapropiadas",
            "",
            "3. 🤝 NO ECHAR A OTROS JUGADORES SIN RAZÓN",
            "   - Este es un espacio para todos",
            "   - Reporta problemas a los moderadores",
            "   - Sé amable y tolerante",
            "",
            "4. 💬 CHAT RESPETUOSO",
            "   - Usa lenguaje apropiado (niños 7+)",
            "   - No spam ni mensajes repetitivos",
            "   - Ayuda a crear un ambiente positivo",
            "",
            "5. 🌱 ESPÍRITU COMPASIVO",
            "   - Cuida a los animales del servidor",
            "   - Comparte y ayuda a otros jugadores",
            "   - Disfruta construyendo juntos",
            "",
            "⚠️ CONSECUENCIAS:",
            "1ra vez: Advertencia",
            "2da vez: Silencio temporal (mute)",
            "3ra vez: Expulsión temporal (kick)",
            "4ta vez: Baneo permanente",
            "",
            "📞 REPORTAR PROBLEMAS:",
            "- Usa el chat para llamar a moderadores",
            "- Comando: /msg admin [tu reporte]",
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
        -- Mensaje de bienvenida mejorado
        minetest.chat_send_player(name, "🌈 ════════════════════════════════════ 🌈")
        minetest.chat_send_player(name, "🌱 ¡Bienvenid@ a Wetlands, " .. name .. "! 🌱")
        minetest.chat_send_player(name, "🏠 Servidor Educativo y Compasivo (7+ años)")
        minetest.chat_send_player(name, "🕊️ Modo Pacífico: Solo diversión, sin violencia")
        minetest.chat_send_player(name, "🌈 ════════════════════════════════════ 🌈")
        minetest.chat_send_player(name, "")

        -- Reglas básicas automáticas
        minetest.chat_send_player(name, "📋 REGLAS BÁSICAS IMPORTANTES:")
        minetest.chat_send_player(name, "1) 🚫 No molestes a otros jugadores")
        minetest.chat_send_player(name, "2) 👤 Usa un nombre apropiado y respetuoso")
        minetest.chat_send_player(name, "3) 🤝 Respeta a todos por igual")
        minetest.chat_send_player(name, "4) 💬 Chat limpio (ambiente familiar)")
        minetest.chat_send_player(name, "5) 🌱 Cuida y respeta a los animales")
        minetest.chat_send_player(name, "")

        -- Comandos útiles
        minetest.chat_send_player(name, "⚡ COMANDOS PRINCIPALES:")
        minetest.chat_send_player(name, "• /reglas - Ver reglas completas")
        minetest.chat_send_player(name, "• /filosofia - Conocer nuestra filosofía")
        minetest.chat_send_player(name, "• /santuario - Aprende sobre santuarios")
        minetest.chat_send_player(name, "• /back_to_spawn - Volver a tu spawn")
        minetest.chat_send_player(name, "")
        minetest.chat_send_player(name, "👤 Importante: Usa siempre el mismo nombre de usuario para evitar confusiones y gestionar tus áreas protegidas")
    end)
end)

-- Mostrar mensaje especial adicional para jugadores nuevos
minetest.register_on_newplayer(function(player)
    local name = player:get_player_name()

    minetest.after(8, function()
        minetest.chat_send_player(name, "")
        minetest.chat_send_player(name, "🎆 ¡Jugador Nuevo Detectado! 🎆")
        minetest.chat_send_player(name, "🌱 Bienvenido a tu primer día en Wetlands")
        minetest.chat_send_player(name, "")
        minetest.chat_send_player(name, "🎯 QUÉ HACE ESPECIAL A NUESTRO SERVIDOR:")
        minetest.chat_send_player(name, "• 🕊️ Mundo pacífico: Sin monstruos ni violencia")
        minetest.chat_send_player(name, "• 🌱 Educación compasiva sobre animales")
        minetest.chat_send_player(name, "• 🌈 Comunidad amigable para familias")
        minetest.chat_send_player(name, "• 🏠 Santuarios virtuales para animales")
        minetest.chat_send_player(name, "")
        minetest.chat_send_player(name, "🚀 TU AVENTURA COMIENZA:")
        minetest.chat_send_player(name, "1. 👾 Explora y observa a los animales felices")
        minetest.chat_send_player(name, "2. 🏠 Construye refugios cómodos para ellos")
        minetest.chat_send_player(name, "3. 🌾 Planta cultivos y crea jardines bonitos")
        minetest.chat_send_player(name, "4. 🥗 Prueba alimentos a base de plantas deliciosos")
        minetest.chat_send_player(name, "5. 🤝 Haz amigos y construyan proyectos juntos")
        minetest.chat_send_player(name, "")
        minetest.chat_send_player(name, "💚 ¡Disfruta tu aventura compasiva!")
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

-- Comando /filosofia para mostrar la filosofía del servidor
minetest.register_chatcommand("filosofia", {
    description = "Muestra la filosofía y misión de Wetlands",
    func = function(name, param)
        local filosofia = {
            "🌱 FILOSOFÍA DE WETLANDS 🌱",
            "",
            "🎯 NUESTRA MISIÓN:",
            "Crear un espacio virtual donde niños y familias",
            "aprendan sobre compasión hacia los animales",
            "mientras se divierten construyendo y explorando.",
            "",
            "💚 VALORES FUNDAMENTALES:",
            "• Respeto hacia todos los seres vivos",
            "• Educación a través del juego",
            "• Construcción de comunidad compasiva",
            "• Alimentación consciente y saludable",
            "• Creatividad sin límites",
            "",
            "🏡 SANTUARIOS VIRTUALES:",
            "Los animales en nuestro mundo viven libres",
            "y felices, sin ser usados para nada.",
            "Son nuestros compañeros de aventuras.",
            "",
            "🌾 ALIMENTACIÓN COMPASIVA:",
            "Descubre deliciosos alimentos vegetales:",
            "tofu, seitan, leche de avena, frutas frescas.",
            "¡Nutritivos y respetuosos con los animales!",
            "",
            "👨‍👩‍👧‍👦 COMUNIDAD FAMILIAR:",
            "Un lugar seguro donde padres e hijos",
            "pueden jugar juntos aprendiendo valores",
            "de respeto y cuidado hacia la naturaleza.",
            "",
            "🌈 Construyamos un mundo mejor, bloque a bloque"
        }

        for _, linea in ipairs(filosofia) do
            minetest.chat_send_player(name, linea)
        end

        return true
    end
})

-- Recordatorio periódico más educativo (cada 20 minutos)
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 1200 then -- 20 minutos = 1200 segundos
        timer = 0
        local mensajes_rotativos = {
            "🌱 Recordatorio: Usa /reglas para las reglas completas",
            "💚 Descubre nuestra filosofía con /filosofia",
            "👤 Importante: Usa siempre el mismo nombre de usuario para evitar confusiones y gestionar tus áreas protegidas",
            "🌐 Visita nuestra página web: https://luanti.gabrielpantoja.cl"
        }
        local mensaje = mensajes_rotativos[math.random(1, #mensajes_rotativos)]
        minetest.chat_send_all(mensaje)
    end
end)