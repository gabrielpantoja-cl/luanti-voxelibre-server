-- ============================================================
-- Snake / Nibbler - tiempo real sobre pantalla HUD
-- Mecanica identica al clasico: la serpiente avanza sola, crece al comer,
-- muere al chocar con el muro o consigo misma, y acelera cada 4 frutas.
-- ============================================================

local arcade = wetlands_snes

local W, H             = 14, 14      -- incluye el marco de una celda
local MINX, MAXX       = 2, W - 1
local MINY, MAXY       = 2, H - 1
local START_INTERVAL   = 0.32
local MIN_INTERVAL     = 0.12
local SPEEDUP_EVERY    = 4           -- frutas entre cada aumento de velocidad
local SPEEDUP_STEP     = 0.022

local function key(x, y)
    return y * 100 + x
end

local function spawn_food(s)
    local taken = {}
    for _, p in ipairs(s.body) do taken[key(p.x, p.y)] = true end
    local free = {}
    for y = MINY, MAXY do
        for x = MINX, MAXX do
            if not taken[key(x, y)] then
                free[#free + 1] = { x = x, y = y }
            end
        end
    end
    if #free == 0 then return nil end
    return free[math.random(#free)]
end

local function draw(s)
    local sc = s.screen
    sc:clear("off")
    sc:border("frame")
    if s.food then sc:set(s.food.x, s.food.y, "red") end
    for i = #s.body, 1, -1 do
        local p = s.body[i]
        sc:set(p.x, p.y, i == 1 and "lime" or "green")
    end
    sc:line("status", "Puntos: " .. s.score .. "   Largo: " .. #s.body)
end

local function turn(s, dx, dy)
    -- No se permite el giro de 180 grados sobre la direccion ya aplicada.
    if s.dir.dx == -dx and s.dir.dy == -dy then return end
    s.next = { dx = dx, dy = dy }
end

arcade.register_game({
    id       = "snake",
    title    = "Snake",
    desc     = "Come y crece sin chocar",
    realtime = true,
    w = W, h = H, scale = 1.4,
    hint     = "WASD = mover   |   E = salir",

    on_start = function(s)
        local cx, cy = math.floor(W / 2), math.floor(H / 2)
        s.body     = { { x = cx, y = cy }, { x = cx - 1, y = cy }, { x = cx - 2, y = cy } }
        s.dir      = { dx = 1, dy = 0 }
        s.next     = { dx = 1, dy = 0 }
        s.interval = START_INTERVAL
        s.acc      = 0
        s.eaten    = 0
        s.food     = spawn_food(s)
        draw(s)
        s.screen:flush()
    end,

    on_step = function(s, dtime, pressed)
        if pressed.up    then turn(s,  0, -1) end
        if pressed.down  then turn(s,  0,  1) end
        if pressed.left  then turn(s, -1,  0) end
        if pressed.right then turn(s,  1,  0) end

        s.acc = s.acc + dtime
        if s.acc < s.interval then return end
        s.acc = 0

        s.dir = s.next
        local head = s.body[1]
        local nx, ny = head.x + s.dir.dx, head.y + s.dir.dy

        if nx < MINX or nx > MAXX or ny < MINY or ny > MAXY then
            return arcade.game_over(s, "CHOCASTE!")
        end
        -- La ultima celda se libera en este mismo paso (salvo que crezca).
        for i = 1, #s.body - 1 do
            if s.body[i].x == nx and s.body[i].y == ny then
                return arcade.game_over(s, "TE MORDISTE!")
            end
        end

        table.insert(s.body, 1, { x = nx, y = ny })

        if s.food and nx == s.food.x and ny == s.food.y then
            s.score = s.score + 10
            s.eaten = s.eaten + 1
            if s.eaten % SPEEDUP_EVERY == 0 then
                s.interval = math.max(MIN_INTERVAL, s.interval - SPEEDUP_STEP)
            end
            s.food = spawn_food(s)
            if not s.food then
                draw(s)
                return arcade.game_over(s, "PANTALLA LLENA!")
            end
        else
            table.remove(s.body)
        end

        draw(s)
    end,
})
