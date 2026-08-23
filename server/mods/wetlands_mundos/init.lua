local modname = minetest.get_current_modname()
local port = tonumber(minetest.settings:get("port") or "0")

-- Valdivia es el unico mundo publico: no necesita anunciar otros mundos.
if port == 30001 then
    minetest.log("action", "[" .. modname .. "] /mundos omitido en Valdivia (30001)")
    return
end

local MUNDOS = {
    "🏙️ Valdivia — luanti.gabrielpantoja.cl:30001",
    "🌱 Wetlands — luanti.gabrielpantoja.cl:30000",
    "⚔️ GAELSIN — luanti.gabrielpantoja.cl:30002",
    "🏴 CTF — luanti.gabrielpantoja.cl:30003",
    "🎮 Mineclonia — luanti.gabrielpantoja.cl:30004",
}

minetest.register_chatcommand("mundos", {
    description = "Muestra las direcciones de los mundos Wetlands",
    func = function(name)
        minetest.chat_send_player(name, minetest.colorize("#FFD966", "== Mundos Wetlands =="))
        minetest.chat_send_player(name, "Usa la direccion y el puerto indicados en el cliente Luanti:")
        for _, mundo in ipairs(MUNDOS) do
            minetest.chat_send_player(name, mundo)
        end
        return true
    end,
})

minetest.log("action", "[" .. modname .. "] Loaded successfully; /mundos disponible")
