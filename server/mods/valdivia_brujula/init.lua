local modname = minetest.get_current_modname()

if not minetest.get_modpath("valdivia_cabina") then
    minetest.log("warning", "[" .. modname .. "] valdivia_cabina no disponible; brujula desactivada.")
    return
end

-- Flechas Unicode en orden: N, NE, E, SE, S, SW, W, NW
local ARROWS = {"↑", "↗", "→", "↘", "↓", "↙", "←", "↖"}
local UPDATE_INTERVAL = 1.0
local HUD_COLOR = 0xFFD966  -- amarillo calido, legible sobre cielo/terreno

local hud_ids = {}  -- name -> hud_id
local timer = 0

-- Devuelve la flecha segun la diferencia de posicion (XZ, ignorando Y)
local function direction_arrow(dx, dz)
    -- atan2(dx, -dz): angulo 0=Norte, creciente sentido horario
    local angle = math.atan2(dx, -dz)
    if angle < 0 then angle = angle + 2 * math.pi end
    local sector = math.floor((angle / (2 * math.pi)) * 8 + 0.5) % 8
    return ARROWS[sector + 1]
end

local function update_hud(player)
    local name = player:get_player_name()
    local cabinas = valdivia_cabina.get_lugares()

    if #cabinas == 0 then
        -- Sin cabinas: borrar texto si existia
        if hud_ids[name] then
            player:hud_change(hud_ids[name], "text", "")
        end
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
    local arrow = direction_arrow(dx, dz)
    local text = arrow .. " " .. nearest.nombre .. "  " .. dist .. " m"

    if not hud_ids[name] then
        hud_ids[name] = player:hud_add({
            type = "text",
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
