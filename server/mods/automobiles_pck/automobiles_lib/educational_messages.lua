--
-- Educational Messages for Wetlands Server
-- Teaching sustainable transportation and compassionate living
-- Added: November 15, 2025 by Gabriel Pantoja
--

automobiles_lib.educational = {}

-- Welcome messages when entering a vehicle
automobiles_lib.educational.welcome_messages = {
    "🌱 ¡Vehículo propulsado por energía vegetal!",
    "♻️ ¡Recuerda usar combustibles renovables!",
    "🌍 Transporte sostenible para un mundo mejor",
    "🌿 Este vehículo funciona con plantas, ¡no con petróleo!",
    "💚 Cuida el planeta mientras exploras Wetlands",
}

-- Fuel messages when refueling
automobiles_lib.educational.fuel_messages = {
    wheat = "🌾 ¡El trigo puede crear biodiesel limpio!",
    carrot = "🥕 ¡Las zanahorias producen etanol renovable!",
    potato = "🥔 ¡Las papas son excelente fuente de biocombustible!",
    beetroot = "🫐 ¡La remolacha es perfecta para biodiesel!",
    pumpkin = "🎃 ¡Las calabazas tienen alto contenido energético!",
    hay = "🌾 ¡Biomasa comprimida = energía eficiente!",
    coal = "⚫ Usa carbón vegetal (renovable plantando árboles)",
    gold = "☀️ ¡Energía solar! El oro representa paneles solares",
    emerald = "🔋 ¡Batería eléctrica! Energía limpia del futuro",
    cooking_oil = "🫗 ¡Aceite vegetal = combustible premium!",
}

-- Function to get random welcome message
function automobiles_lib.educational.get_welcome_message()
    local index = math.random(1, #automobiles_lib.educational.welcome_messages)
    return automobiles_lib.educational.welcome_messages[index]
end

-- Function to get fuel-specific message
function automobiles_lib.educational.get_fuel_message(fuel_item)
    -- Extract the base item name (e.g., "wheat_item" -> "wheat")
    local base_name = fuel_item:match(":([^:]+)"):gsub("_item", ""):gsub("_lump", ""):gsub("_ingot", "")

    -- Return specific message or generic one
    return automobiles_lib.educational.fuel_messages[base_name] or
           "🌱 ¡Gracias por usar combustibles renovables!"
end

-- Function to show educational tips periodically
function automobiles_lib.educational.show_tip(player_name)
    local tips = {
        "💡 Tip: Planta más árboles para tener carbón vegetal renovable",
        "💡 Tip: Los cultivos son excelentes fuentes de energía limpia",
        "💡 Tip: En el mundo real, los vehículos eléctricos no producen emisiones",
        "💡 Tip: El transporte público reduce la contaminación del aire",
        "💡 Tip: Caminar y usar bicicleta es saludable y ecológico",
        "💡 Tip: Los biocombustibles pueden reducir nuestra dependencia del petróleo",
        "💡 Tip: La energía solar es limpia, silenciosa y renovable",
        "💡 Tip: Compartir vehículos reduce el tráfico y la contaminación",
    }

    local index = math.random(1, #tips)
    minetest.chat_send_player(player_name, tips[index])
end

-- Register chat command for educational info
minetest.register_chatcommand("transporte_sostenible", {
    description = "Información sobre transporte sostenible",
    func = function(name)
        minetest.chat_send_player(name, [[
🌍 === TRANSPORTE SOSTENIBLE EN WETLANDS ===

En nuestro servidor, los vehículos funcionan con:

🌱 COMBUSTIBLES VEGETALES:
• Trigo, zanahorias, papas → biodiesel/etanol
• Calabazas, melones → biocombustible líquido
• Remolacha → biodiesel de alta calidad

🔋 ENERGÍA LIMPIA:
• Oro (paneles solares simbólicos)
• Esmeralda (baterías eléctricas)

♻️ ¿POR QUÉ ES IMPORTANTE?
En el mundo real, el transporte produce mucha
contaminación. Usar energías renovables ayuda
a cuidar nuestro planeta y los animales.

💚 ¡Aprende mientras juegas!
]])
        return true
    end,
})

return automobiles_lib.educational
