-- ============================================================
-- Breakout / Arkanoid - tiempo real sobre pantalla HUD
-- Paleta de 3 celdas, pelota en rejilla con rebote por eje y efecto segun
-- la parte de la paleta que golpea. 4 filas de ladrillos, 3 vidas.
-- ============================================================

local arcade = wetlands_snes

local W, H          = 12, 15
local PLAY_MINX     = 2
local PLAY_MAXX     = W - 1
local PADDLE_Y      = H - 1
local PADDLE_W      = 3
local BRICK_ROWS    = { 3, 4, 5, 6 }
local BRICK_COLORS  = { "red", "orange", "yellow", "green" }
local BALL_INTERVAL = 0.11
local PADDLE_STEP   = 0.055
local LIVES         = 3

local function brick_at(s, x, y)
    local row = s.bricks[y]
    return row and row[x] or nil
end

-- Celda que detiene la pelota: muro, ladrillo o paleta.
local function blocked(s, x, y)
    if x < PLAY_MINX or x > PLAY_MAXX then return "wall" end
    if y < 2 then return "wall" end
    if brick_at(s, x, y) then return "brick" end
    if y == PADDLE_Y and x >= s.paddle and x < s.paddle + PADDLE_W then
        return "paddle"
    end
    return nil
end

local function break_brick(s, x, y)
    local row = s.bricks[y]
    if not (row and row[x]) then return end
    row[x] = nil
    s.left  = s.left - 1
    s.score = s.score + 10 * (7 - y)   -- las filas de arriba valen mas
end

local function paddle_english(s, x)
    local rel = x - s.paddle          -- 0, 1, 2
    if rel == 0 then
        s.ball.dx = -1
    elseif rel == PADDLE_W - 1 then
        s.ball.dx = 1
    end
end

local function hit(s, x, y, what)
    if what == "brick" then
        break_brick(s, x, y)
    elseif what == "paddle" then
        paddle_english(s, x)
    end
end

local function reset_ball(s)
    s.ball = { x = s.paddle + 1, y = PADDLE_Y - 1, dx = 1, dy = -1 }
    s.held_ball = true
end

local function draw(s)
    local sc = s.screen
    sc:clear("off")
    for y = 1, H - 1 do
        sc:set(1, y, "frame")
        sc:set(W, y, "frame")
    end
    for x = 1, W do sc:set(x, 1, "frame") end

    for _, y in ipairs(BRICK_ROWS) do
        local row = s.bricks[y]
        if row then
            for x = PLAY_MINX, PLAY_MAXX do
                if row[x] then sc:set(x, y, row[x]) end
            end
        end
    end

    for i = 0, PADDLE_W - 1 do
        sc:set(s.paddle + i, PADDLE_Y, "cyan")
    end
    sc:set(s.ball.x, s.ball.y, "white")

    sc:line("status", "Puntos: " .. s.score .. "   Vidas: " .. s.lives ..
        "   Ladrillos: " .. s.left)
end

arcade.register_game({
    id       = "breakout",
    title    = "Breakout",
    desc     = "Rompe los ladrillos con la paleta",
    realtime = true,
    w = W, h = H, scale = 1.4,
    hint     = "A/D mover  ESPACIO lanzar  E salir",

    on_start = function(s)
        s.bricks = {}
        s.left   = 0
        for i, y in ipairs(BRICK_ROWS) do
            s.bricks[y] = {}
            for x = PLAY_MINX, PLAY_MAXX do
                s.bricks[y][x] = BRICK_COLORS[i]
                s.left = s.left + 1
            end
        end
        s.paddle  = math.floor((W - PADDLE_W) / 2) + 1
        s.lives   = LIVES
        s.acc     = 0
        s.pacc    = 0
        reset_ball(s)
        draw(s)
        s.screen:flush()
    end,

    on_step = function(s, dtime, pressed, held)
        -- Paleta
        s.pacc = s.pacc + dtime
        if s.pacc >= PADDLE_STEP then
            s.pacc = 0
            if held.left  and s.paddle > PLAY_MINX then
                s.paddle = s.paddle - 1
            end
            if held.right and s.paddle + PADDLE_W - 1 < PLAY_MAXX then
                s.paddle = s.paddle + 1
            end
        end

        if s.held_ball then
            s.ball.x = s.paddle + 1
            s.ball.y = PADDLE_Y - 1
            if pressed.jump then s.held_ball = false end
            draw(s)
            return
        end

        s.acc = s.acc + dtime
        if s.acc < BALL_INTERVAL then
            draw(s)
            return
        end
        s.acc = 0

        local b = s.ball
        local nx, ny = b.x + b.dx, b.y + b.dy
        local bx = blocked(s, nx, b.y)
        local by = blocked(s, b.x, ny)
        local bd = (not bx and not by) and blocked(s, nx, ny) or nil

        if bx then hit(s, nx, b.y, bx); b.dx = -b.dx end
        if by then hit(s, b.x, ny, by); b.dy = -b.dy end
        if bd then
            hit(s, nx, ny, bd)
            b.dx = -b.dx
            b.dy = -b.dy
        end

        local tx, ty = b.x + b.dx, b.y + b.dy
        if not blocked(s, tx, ty) then
            b.x, b.y = tx, ty
        end

        if s.left <= 0 then
            s.score = s.score + 500 + s.lives * 200
            draw(s)
            return arcade.game_over(s, "GANASTE!")
        end

        if b.y >= H then
            s.lives = s.lives - 1
            if s.lives <= 0 then
                draw(s)
                return arcade.game_over(s, "GAME OVER")
            end
            reset_ball(s)
        end

        draw(s)
    end,
})
