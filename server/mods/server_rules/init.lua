-- Mod de reglas del servidor Vegan Wetlands
-- Comando /reglas para mostrar las reglas completas

minetest.register_chatcommand("reglas", {
    description = "Muestra las reglas del servidor",
    func = function(name, param)
        local reglas = {
            "🌱 REGLAS DE VEGAN WETLANDS 🌱",
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

-- Mostrar reglas automáticamente a nuevos jugadores
minetest.register_on_newplayer(function(player)
    local name = player:get_player_name()

    minetest.after(3, function()
        minetest.chat_send_player(name, "🌱 ¡Bienvenid@ a Vegan Wetlands!")
        minetest.chat_send_player(name, "📝 Usa /reglas para ver las reglas del servidor")
        minetest.chat_send_player(name, "🎮 Usa /filosofia para conocer nuestra misión")
        minetest.chat_send_player(name, "🏠 Usa /santuario para info sobre cuidado animal")
    end)
end)

-- Recordatorio periódico de reglas (cada 15 minutos)
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 900 then -- 15 minutos = 900 segundos
        timer = 0
        minetest.chat_send_all("🌱 Recordatorio: Usa /reglas para ver las reglas del servidor. ¡Mantengamos un ambiente compasivo!")
    end
end)