-- ============================================================
-- Tetris - tiempo real sobre pantalla HUD
-- Las 7 piezas clasicas, giro con patada de muro, limpieza de lineas,
-- puntaje estilo NES (40/100/300/1200 x nivel) y un nivel mas cada 10 lineas.
-- El panel de 4x4 a la derecha muestra la pieza siguiente.
-- ============================================================

local arcade = wetlands_snes

local BW, BH = 10, 18        -- celdas del tablero (sin marco: la pantalla ES el tablero)
local SOFT_REPEAT = 0.07     -- repeticion al mantener S (bajar)
local DAS_DELAY   = 0.18     -- espera antes de repetir A/D
local DAS_REPEAT  = 0.06

-- Cada pieza son sus rotaciones dibujadas en una caja de 4x4.
local SHAPES = {
    { color = "cyan",   rot = { { "....", "####", "....", "...." },
                               { "..#.", "..#.", "..#.", "..#." } } },               -- I
    { color = "yellow", rot = { { ".##.", ".##.", "....", "...." } } },               -- O
    { color = "purple", rot = { { ".#..", "###.", "....", "...." },
                               { ".#..", ".##.", ".#..", "...." },
                               { "....", "###.", ".#..", "...." },
                               { ".#..", "##..", ".#..", "...." } } },               -- T
    { color = "green",  rot = { { ".##.", "##..", "....", "...." },
                               { "#...", "##..", ".#..", "...." } } },               -- S
    { color = "red",    rot = { { "##..", ".##.", "....", "...." },
                               { ".#..", "##..", "#...", "...." } } },               -- Z
    { color = "blue",   rot = { { "#...", "###.", "....", "...." },
                               { "##..", "#...", "#...", "...." },
                               { "....", "###.", "..#.", "...." },
                               { ".#..", ".#..", "##..", "...." } } },               -- J
    { color = "orange", rot = { { "..#.", "###.", "....", "...." },
                               { "#...", "#...", "##..", "...." },
                               { "....", "###.", "#...", "...." },
                               { "##..", ".#..", ".#..", "...." } } },               -- L
}

-- Precalcula las celdas (dx, dy) de cada rotacion: 0-indexadas dentro de la caja.
local PIECES = {}
for i, def in ipairs(SHAPES) do
    local rots = {}
    for r, grid in ipairs(def.rot) do
        local cells = {}
        for row = 1, 4 do
            local line = grid[row]
            for col = 1, 4 do
                if line:sub(col, col) == "#" then
                    cells[#cells + 1] = { x = col - 1, y = row - 1 }
                end
            end
        end
        rots[r] = cells
    end
    PIECES[i] = { color = def.color, rots = rots }
end

local function cells_of(s)
    return PIECES[s.piece].rots[s.rot]
end

-- ¿La pieza id/rot cabe con su caja en (px, py)?
local function fits(s, id, rot, px, py)
    for _, c in ipairs(PIECES[id].rots[rot]) do
        local x, y = px + c.x, py + c.y
        if x < 1 or x > BW or y > BH then return false end
        if y >= 1 and s.board[y][x] then return false end
    end
    return true
end

local function level_interval(level)
    return math.max(0.12, 0.60 - (level - 1) * 0.055)
end

local function next_bag(s)
    -- Bolsa de 7: cada pieza aparece una vez por ronda, como en el Tetris moderno.
    if #s.bag == 0 then
        local pool = {}
        for i = 1, #PIECES do pool[i] = i end
        while #pool > 0 do
            table.insert(s.bag, table.remove(pool, math.random(#pool)))
        end
    end
    return table.remove(s.bag)
end

local function draw_panel(s)
    local sc = s.screen
    for y = 1, 4 do
        for x = 1, 4 do sc:pset(x, y, "off") end
    end
    local p = PIECES[s.nextp]
    for _, c in ipairs(p.rots[1]) do
        sc:pset(c.x + 1, c.y + 1, p.color)
    end
end

local function draw(s)
    local sc = s.screen
    sc:clear("off")
    for y = 1, BH do
        local row = s.board[y]
        for x = 1, BW do
            if row[x] then sc:set(x, y, row[x]) end
        end
    end
    local color = PIECES[s.piece].color
    for _, c in ipairs(cells_of(s)) do
        local y = s.py + c.y
        if y >= 1 then sc:set(s.px + c.x, y, color) end
    end
    draw_panel(s)
    sc:line("status", "Puntos: " .. s.score ..
        "   Lineas: " .. s.lines .. "   Nivel: " .. s.level)
end

local function spawn(s)
    s.piece = s.nextp
    s.nextp = next_bag(s)
    s.rot   = 1
    s.px    = math.floor((BW - 4) / 2) + 1
    s.py    = 1
    if not fits(s, s.piece, s.rot, s.px, s.py) then
        draw(s)
        arcade.game_over(s, "GAME OVER")
        return false
    end
    return true
end

local LINE_SCORE = { 40, 100, 300, 1200 }

local function lock_piece(s)
    local color = PIECES[s.piece].color
    for _, c in ipairs(cells_of(s)) do
        local y = s.py + c.y
        if y >= 1 then s.board[y][s.px + c.x] = color end
    end

    -- Limpieza de lineas completas, de abajo hacia arriba.
    local cleared = 0
    local y = BH
    while y >= 1 do
        local full = true
        for x = 1, BW do
            if not s.board[y][x] then full = false break end
        end
        if full then
            table.remove(s.board, y)
            local empty = {}
            table.insert(s.board, 1, empty)
            cleared = cleared + 1
        else
            y = y - 1
        end
    end

    if cleared > 0 then
        s.lines    = s.lines + cleared
        s.score    = s.score + LINE_SCORE[math.min(cleared, 4)] * s.level
        s.level    = math.floor(s.lines / 10) + 1
        s.interval = level_interval(s.level)
    end

    return spawn(s)
end

local function rotate(s)
    local rots  = PIECES[s.piece].rots
    local nrot  = (s.rot % #rots) + 1
    for _, kick in ipairs({ 0, -1, 1, -2, 2 }) do
        if fits(s, s.piece, nrot, s.px + kick, s.py) then
            s.rot = nrot
            s.px  = s.px + kick
            return
        end
    end
end

local function move(s, dx)
    if fits(s, s.piece, s.rot, s.px + dx, s.py) then
        s.px = s.px + dx
        return true
    end
    return false
end

local function step_down(s)
    if fits(s, s.piece, s.rot, s.px, s.py + 1) then
        s.py = s.py + 1
        return true
    end
    return false
end

arcade.register_game({
    id       = "tetris",
    title    = "Tetris",
    desc     = "Arma lineas con las 7 piezas",
    realtime = true,
    w = BW, h = BH, scale = 1.3,
    panel_w = 4, panel_h = 4,
    hint     = "A/D mover  S bajar  ESPACIO girar  SHIFT soltar  E salir",

    on_start = function(s)
        s.board = {}
        for y = 1, BH do s.board[y] = {} end
        s.bag      = {}
        s.nextp    = next_bag(s)
        s.lines    = 0
        s.level    = 1
        s.interval = level_interval(1)
        s.acc      = 0
        s.das      = 0
        s.das_dir  = 0
        s.soft     = 0
        spawn(s)
        draw(s)
        s.screen:flush()
    end,

    on_step = function(s, dtime, pressed, held)
        -- Giro y soltar de golpe
        if pressed.jump  then rotate(s) end
        if pressed.sneak then
            local dropped = 0
            while step_down(s) do dropped = dropped + 1 end
            s.score = s.score + dropped * 2
            if not lock_piece(s) then return end
            s.acc = 0
        end

        -- Mover izquierda/derecha con repeticion (DAS)
        local dir = 0
        if held.left  then dir = -1 end
        if held.right then dir = 1 end
        if pressed.left or pressed.right then
            dir = pressed.left and -1 or 1
            move(s, dir)
            s.das_dir = dir
            s.das     = 0
        elseif dir ~= 0 and dir == s.das_dir then
            s.das = s.das + dtime
            if s.das >= DAS_DELAY then
                s.das = s.das - DAS_REPEAT
                move(s, dir)
            end
        else
            s.das_dir = dir
            s.das     = 0
        end

        -- Bajar suave
        if held.down then
            s.soft = s.soft + dtime
            if pressed.down or s.soft >= SOFT_REPEAT then
                s.soft = 0
                if step_down(s) then
                    s.score = s.score + 1
                    s.acc   = 0
                else
                    if not lock_piece(s) then return end
                    s.acc = 0
                end
            end
        else
            s.soft = SOFT_REPEAT
        end

        -- Gravedad
        s.acc = s.acc + dtime
        if s.acc >= s.interval then
            s.acc = 0
            if not step_down(s) then
                if not lock_piece(s) then return end
            end
        end

        draw(s)
    end,
})
