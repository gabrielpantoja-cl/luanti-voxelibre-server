local modname = minetest.get_current_modname()
local port = tonumber(minetest.settings:get("port") or "0")

-- Valdivia es el unico mundo publico: no necesita anunciar otros mundos.
if port == 30001 then
    minetest.log("action", "[" .. modname .. "] /mundos omitido en Valdivia (30001)")
    return
end

local MUNDOS = {
    {port = 30000, host = "luanti.gabrielpantoja.cl", icon = "🌱", name = "Wetlands", purpose = "mundo creativo"},
    {port = 30001, host = "luanti.gabrielpantoja.cl", icon = "🏙️", name = "Valdivia", purpose = "ciudad para explorar"},
    {port = 30002, host = "luanti.gabrielpantoja.cl", icon = "⚔️", name = "GAELSIN", purpose = "mundo de aventura"},
    {port = 30003, host = "luanti.gabrielpantoja.cl", icon = "🏴", name = "CTF", purpose = "captura la bandera"},
    {port = 30004, host = "luanti.gabrielpantoja.cl", icon = "🎮", name = "Mineclonia", purpose = "mundo creativo"},
}

table.sort(MUNDOS, function(a, b)
    return (tonumber(a.port) or math.huge) < (tonumber(b.port) or math.huge)
end)

local function mundo_texto(mundo)
    local mundo_port = tostring(mundo.port or "?")
    local mundo_name = tostring(mundo.name or "Mundo sin nombre")
    local mundo_icon = tostring(mundo.icon or "🌍")
    local mundo_purpose = tostring(mundo.purpose or "un lugar para jugar")
    local mundo_host = tostring(mundo.host or "luanti.gabrielpantoja.cl")

    return string.format("%s  %s:%s  •  %s — %s", mundo_icon, mundo_host,
        mundo_port, mundo_name, mundo_purpose)
end

minetest.register_chatcommand("mundos", {
    description = "Muestra las direcciones de los mundos Wetlands",
    func = function(name)
        minetest.chat_send_player(name, minetest.colorize("#FFD966", "🌍  MUNDOS WETLANDS"))
        minetest.chat_send_player(name, minetest.colorize("#7FB3D5", "────────────────────────────"))
        minetest.chat_send_player(name, "Elige un mundo y usa su puerto en Luanti:")
        for _, mundo in ipairs(MUNDOS) do
            minetest.chat_send_player(name, minetest.colorize("#E8F8F5", mundo_texto(mundo)))
        end
        minetest.chat_send_player(name, minetest.colorize("#7FB3D5", "────────────────────────────"))
        minetest.chat_send_player(name, minetest.colorize("#A9DFBF", "¡Que disfrutes explorando y creando! 🌱"))
        return true
    end,
})

minetest.log("action", "[" .. modname .. "] Loaded successfully; /mundos disponible")
