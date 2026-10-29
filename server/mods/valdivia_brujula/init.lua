local modname = minetest.get_current_modname()

if not minetest.get_modpath("valdivia_cabina") then
    minetest.log("warning", "[" .. modname .. "] valdivia_cabina no disponible; brujula desactivada.")
    return
end

local ARROWS = {"↑", "↗", "→", "↘", "↓", "↙", "←", "↖"}
local UPDATE_INTERVAL = 1.0
local HUD_COLOR = 0xFFD966
local META_KEY = "brujula_enabled"

local hud_ids = {}
local timer = 0

local function is_enabled(player)
    -- default true: nuevos jugadores la ven desde el primer ingreso
    return player:get_meta():get_string(META_KEY) ~= "false"
end

local function direction_arrow(dx, dz)
    local angle = math.atan2(dx, -dz)
    if angle < 0 then angle = angle + 2 * math.pi end
    local sector = math.floor((angle / (2 * math.pi)) * 8 + 0.5) % 8
    return ARROWS[sector + 1]
end

local function update_hud(player)
    local name = player:get_player_name()

    if not is_enabled(player) then
        if hud_ids[name] then player:hud_change(hud_ids[name], "text", "") end
        return
    end

    local cabinas = valdivia_cabina.get_lugares()
    if #cabinas == 0 then
        if hud_ids[name] then player:hud_change(hud_ids[name], "text", "") end
        return
    end

    local ppos = player:get_pos()
    local nearest, nearest_d2
    for _, l in ipairs(cabinas) do
        local dx = l.pos.x - ppos.x
        local dz = l.pos.z - ppos.z
        local d2 = dx * dx + dz * dz
        if not nearest_d2 or d2 < nearest_d2 then
            nearest = l
            nearest_d2 = d2
        end
    end

    local dx = nearest.pos.x - ppos.x
    local dz = nearest.pos.z - ppos.z
    local dist = math.floor(math.sqrt(nearest_d2))
    local text = direction_arrow(dx, dz) .. " " .. nearest.nombre .. "  " .. dist .. " m"

    if not hud_ids[name] then
        hud_ids[name] = player:hud_add({
            type       = "text",
            position   = {x = 0.82, y = 0.06},
            offset     = {x = 0,    y = 0},
            alignment  = {x = 0,    y = 0},
            scale      = {x = 100,  y = 100},
            text       = text,
            number     = HUD_COLOR,
        })
    else
        player:hud_change(hud_ids[name], "text", text)
    end
end

minetest.register_chatcommand("brujula", {
    description = "Activa o desactiva la brujula de cabinas TP",
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "No estas conectado." end
        local meta = player:get_meta()
        if is_enabled(player) then
            meta:set_string(META_KEY, "false")
            if hud_ids[name] then player:hud_change(hud_ids[name], "text", "") end
            return true, minetest.colorize("#FFB347", "Brujula desactivada. Usa /brujula para reactivarla.")
        else
            meta:set_string(META_KEY, "true")
            return true, minetest.colorize("#7CFC7C", "Brujula activada.")
        end
    end,
})

minetest.register_on_leaveplayer(function(player)
    hud_ids[player:get_player_name()] = nil
end)

minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < UPDATE_INTERVAL then return end
    timer = 0
    for _, player in ipairs(minetest.get_connected_players()) do
        update_hud(player)
    end
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully")
