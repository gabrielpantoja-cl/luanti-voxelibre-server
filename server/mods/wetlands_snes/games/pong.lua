-- ============================================================
-- Pong - tiempo real sobre pantalla HUD, contra la maquina
-- Paletas de 3 celdas. La maquina sigue la pelota con un pequeno retardo
-- para que sea ganable. Gana quien llega a 5 puntos.
-- El puntaje guardado es la cantidad de rebotes logrados (la habilidad real).
-- ============================================================

local arcade = wetlands_snes

local W, H          = 16, 12
local PADDLE_H      = 3
local PX_PLAYER     = 2
local PX_CPU        = W - 1
local TOP, BOTTOM   = 2, H - 1
local BALL_INTERVAL = 0.10
local CPU_INTERVAL  = 0.13       -- mas alto = maquina mas lenta
local WIN_POINTS    = 5

local function clamp_paddle(y)
    if y < TOP then return TOP end
    if y > BOTTOM - PADDLE_H + 1 then return BOTTOM - PADDLE_H + 1 end
    return y
end

local function on_paddle(top, y)
    return y >= top and y < top + PADDLE_H
end

local function serve(s, towards)
    s.ball = {
        x  = math.floor(W / 2),
        y  = math.floor(H / 2),
        dx = towards,
        dy = (math.random(2) == 1) and -1 or 1,
    }
    s.pause = 0.6
end

local function draw(s)
    local sc = s.screen
    sc:clear("off")
    for x = 1, W do
        sc:set(x, 1, "frame")
        sc:set(x, H, "frame")
    end
    -- red central punteada
    for y = 2, H - 1, 2 do sc:set(math.floor(W / 2), y, "gray") end

    for i = 0, PADDLE_H - 1 do
        sc:set(PX_PLAYER, s.py + i, "cyan")
        sc:set(PX_CPU,    s.cy + i, "red")
    end
    sc:set(s.ball.x, s.ball.y, "white")

    sc:line("status", "Tu " .. s.points .. " - " .. s.cpu_points ..
        " Maquina   Rebotes: " .. s.score)
end

arcade.register_game({
    id       = "pong",
    title    = "Pong",
    desc     = "El duelo original contra la maquina",
    realtime = true,
    w = W, h = H, scale = 1.5,
    hint     = "W/S mover   |   E = salir",

    on_start = function(s)
        s.py         = clamp_paddle(math.floor(H / 2) - 1)
        s.cy         = s.py
        s.points     = 0
        s.cpu_points = 0
        s.acc        = 0
        s.cacc       = 0
        s.pacc       = 0
        serve(s, 1)
        draw(s)
        s.screen:flush()
    end,

    on_step = function(s, dtime, pressed, held)
        -- Paleta del jugador
        s.pacc = s.pacc + dtime
        if s.pacc >= 0.055 then
            s.pacc = 0
            if held.up   then s.py = clamp_paddle(s.py - 1) end
            if held.down then s.py = clamp_paddle(s.py + 1) end
        end

        -- Maquina: persigue el centro de la pelota, un paso cada CPU_INTERVAL
        s.cacc = s.cacc + dtime
        if s.cacc >= CPU_INTERVAL then
            s.cacc = 0
            local center = s.cy + math.floor(PADDLE_H / 2)
            if s.ball.y < center then
                s.cy = clamp_paddle(s.cy - 1)
            elseif s.ball.y > center then
                s.cy = clamp_paddle(s.cy + 1)
            end
        end

        if s.pause and s.pause > 0 then
            s.pause = s.pause - dtime
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
        local ny = b.y + b.dy
        if ny <= 1 or ny >= H then
            b.dy = -b.dy
        else
            b.y = ny
        end

        local nx = b.x + b.dx
        if nx == PX_PLAYER and on_paddle(s.py, b.y) then
            b.dx   = 1
            s.score = s.score + 1
            -- efecto segun la parte de la paleta
            local rel = b.y - s.py
            if rel == 0 then b.dy = -1 elseif rel == PADDLE_H - 1 then b.dy = 1 end
        elseif nx == PX_CPU and on_paddle(s.cy, b.y) then
            b.dx = -1
        else
            b.x = nx
        end

        if b.x <= 1 then
            s.cpu_points = s.cpu_points + 1
            if s.cpu_points >= WIN_POINTS then
                draw(s)
                return arcade.game_over(s, "PERDISTE")
            end
            serve(s, 1)
        elseif b.x >= W then
            s.points = s.points + 1
            s.score  = s.score + 10
            if s.points >= WIN_POINTS then
                draw(s)
                return arcade.game_over(s, "GANASTE!")
            end
            serve(s, -1)
        end

        draw(s)
    end,
})
