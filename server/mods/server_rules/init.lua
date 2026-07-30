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
            "🏠 SERVIDOR CREATIVO Y EDUCATIVO",
            "Diseñado especialmente para niños 7+ años",
            "Construye, explora y aprende con amigos",
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
            "5. 🌱 COMPROMISO PLANT-BASED",
            "   - Wetlands promueve alternativas vegetales y reemplaza items de origen animal",
            "   - Mods activos: vegan_food, vegan_replacements, education_blocks",
            "   - No se promueven estilos de juego basados en explotación animal",
            "   - Cuida a los animales del servidor y comparte con la comunidad",
            "   - Tip: /veganinfo para ver los mods y filosofía detallada",
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
            "3) Respeto 4) Chat limpio 5) Plant-based",
            "Usa /reglas para ver todas  |  /veganinfo para los mods"
        }

        for _, linea in ipairs(reglas_cortas) do
            minetest.chat_send_player(name, linea)
        end

        return true
    end,
})

-- Mostrar reglas automáticamente a TODOS los jugadores al conectarse.
-- 2026-07-30: deshabilitado para mantener el chat minimalista al ingresar.
-- La bienvenida breve vive en `motd` (luanti-original.conf). Toda la
-- información detallada sigue accesible via /reglas, /ayuda, /veganinfo.
minetest.register_on_joinplayer(function(player)
end)

-- Mostrar mensaje especial adicional para jugadores nuevos.
-- 2026-07-30: deshabilitado por la misma razon que el bloque on_joinplayer.
minetest.register_on_newplayer(function(player)
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

-- Comando /ayuda - Unifica reglas, filosofía y santuario
minetest.register_chatcommand("ayuda", {
    description = "Información completa sobre Wetlands (reglas, filosofía, comandos)",
    func = function(name, param)
        local ayuda = {
            "🌱 ════════════════════════════════════ 🌱",
            "       GUÍA COMPLETA DE WETLANDS",
            "🌱 ════════════════════════════════════ 🌱",
            "",
            "📋 REGLAS BÁSICAS:",
            "1. 🚫 No molestes ni destruyas construcciones ajenas",
            "2. 👤 Usa un nombre apropiado (no 'guest123')",
            "3. 🤝 Respeta a todos - ambiente familiar",
            "4. 💬 Chat limpio (niños 7+)",
            "5. 🌱 Cuida y respeta a los animales",
            "",
            "🎯 NUESTRA MISIÓN:",
            "Servidor educativo donde niños y familias aprenden",
            "sobre compasión hacia los animales mientras juegan.",
            "",
            "🐾 SANTUARIOS ANIMALES:",
            "Los animales viven libres y felices. No los lastimes.",
            "Obsérvalos, construye refugios para ellos, planta cultivos.",
            "",
            "⚡ COMANDOS ÚTILES:",
            "• /back_to_spawn - Volver a tu spawn",
            "• /arena_tp - Ir a Arena Principal (PVP)",
            "• /pos1 y /pos2 - Marcar área a proteger",
            "• /protect_area - Proteger área marcada",
            "• /list_areas - Ver tus áreas protegidas",
            "• /reglas - Ver reglas detalladas",
            "• /filosofia - Nuestra filosofía completa",
            "• /santuario - Más sobre cuidado animal",
            "• /discord - Únete a nuestra comunidad Discord",
            "",
            "🛏️ SISTEMA DE SPAWN:",
            "Duerme en una cama para establecer tu spawn personal.",
            "Usa /back_to_spawn para teleportarte allí.",
            "",
            "🌐 Web: https://luanti.gabrielpantoja.cl",
            "💬 Discord: /discord",
            "💚 ¡Diviértete construyendo un mundo compasivo!",
            ""
        }

        for _, linea in ipairs(ayuda) do
            minetest.chat_send_player(name, linea)
        end

        return true
    end
})

-- Comando /discord para información del servidor de Discord
minetest.register_chatcommand("discord", {
    description = "Información del servidor Discord de Wetlands",
    func = function(name, param)
        local discord_info = {
            "💬 ════════════════════════════════════ 💬",
            "       SERVIDOR DISCORD DE WETLANDS",
            "💬 ════════════════════════════════════ 💬",
            "",
            "🌱 ¡Únete a nuestra comunidad!",
            "",
            "📱 ¿Qué encontrarás en Discord?",
            "• 💬 Chat con otros jugadores",
            "• 🔔 Notificaciones cuando alguien se conecta",
            "• 📢 Anuncios de eventos y novedades",
            "• 🎮 Coordinación para jugar juntos",
            "• 🤝 Ayuda y soporte de la comunidad",
            "• 🏗️ Comparte tus construcciones",
            "",
            "🔗 ENLACE DE INVITACIÓN:",
            "https://discord.gg/JDmZ5uhKM",
            "",
            "📝 Recuerda seguir las mismas reglas del servidor:",
            "Respeto, amabilidad y espíritu compasivo 💚",
            ""
        }

        for _, linea in ipairs(discord_info) do
            minetest.chat_send_player(name, linea)
        end

        return true
    end
})

-- Anuncios recurrentes por mundo.
--
-- Filtro por nombre del mundo (no por puerto): los tres containers usan
-- port=30000 internamente y Docker mapea a 30001/30002 en el host, así
-- que minetest.settings:get("port") sería idéntico en los tres.
-- minetest.get_worldpath() termina en world | valdivia | gaelsin | ctf, que
-- es lo que docker-compose monta y world_name pinea en cada .conf.
--
-- Cada lista rota: cada ANNOUNCEMENT_INTERVAL segundos se emite el
-- siguiente mensaje. Lista vacía o mundo no listado → no se anuncia nada.
--
-- 2026-07-30: anuncios desactivados en todos los mundos para mantener el
-- chat minimalista (consistente con la bienvenida breve en `motd`). Los
-- comandos (/reglas, /ayuda, /veganinfo, /discord) siguen disponibles.

local ANNOUNCEMENT_INTERVAL = 60

local ANNOUNCEMENTS = {
    -- Wetlands (puerto público 30000): anuncios desactivados (minimalismo).
    world = {},
    -- Valdivia (puerto público 30001): anuncios desactivados (minimalismo).
    valdivia = {},
    -- GAELSIN (puerto público 30002): sin anuncios desde 2026-06-27.
    gaelsin = {},
}

local world_id = (minetest.get_worldpath() or ""):match("([^/]+)/?$") or "world"
local messages = ANNOUNCEMENTS[world_id] or {}

if #messages > 0 then
    local timer = 0
    local idx = 1
    minetest.register_globalstep(function(dtime)
        timer = timer + dtime
        if timer >= ANNOUNCEMENT_INTERVAL then
            timer = 0
            minetest.chat_send_all(messages[idx])
            idx = (idx % #messages) + 1
        end
    end)
end