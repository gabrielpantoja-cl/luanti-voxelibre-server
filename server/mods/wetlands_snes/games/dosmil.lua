-- ============================================================
-- 2048 - por turnos, sobre formspec
-- Reglas identicas al original: 4x4, aparece un 2 (o un 4) tras cada
-- movimiento valido, las fichas iguales se fusionan una sola vez por jugada.
-- ============================================================

local arcade = wetlands_snes

local N = 4

local TILE_COLOR = {
    [0]    = "#2b2140",
    [2]    = "#4d4466",
    [4]    = "#5e5280",
    [8]    = "#c47a3c",
    [16]   = "#cf6a33",
    [32]   = "#d9552f",
    [64]   = "#e03b24",
    [128]  = "#d8bf4a",
    [256]  = "#d8b63a",
    [512]  = "#d8ad22",
    [1024] = "#d8a40c",
    [2048] = "#f0d040",
}

-- Desliza una fila de 4 hacia el indice 1. Devuelve nueva fila, puntaje y si cambio.
-- Funcion pura: es la que se testea en tools/test_logic.py.
local function slide_line(line)
    local vals = {}
    for i = 1, N do
        if line[i] then vals[#vals + 1] = line[i] end
    end

    local out, gained = {}, 0
    local i = 1
    while i <= #vals do
        if vals[i + 1] and vals[i + 1] == vals[i] then
            local v = vals[i] * 2
            out[#out + 1] = v
            gained = gained + v
            i = i + 2
        else
            out[#out + 1] = vals[i]
            i = i + 1
        end
    end

    local changed = false
    for k = 1, N do
        if out[k] ~= line[k] then changed = true end
    end
    return out, gained, changed
end

-- Lee la fila/columna en el orden en que se "cae" hacia la direccion dir.
local function read_line(grid, dir, idx)
    local line = {}
    for k = 1, N do
        local x, y
        if dir == "left"  then x, y = k, idx
        elseif dir == "right" then x, y = N + 1 - k, idx
        elseif dir == "up"    then x, y = idx, k
        else                       x, y = idx, N + 1 - k end
        line[k] = grid[y][x]
    end
    return line
end

local function write_line(grid, dir, idx, line)
    for k = 1, N do
        local x, y
        if dir == "left"  then x, y = k, idx
        elseif dir == "right" then x, y = N + 1 - k, idx
        elseif dir == "up"    then x, y = idx, k
        else                       x, y = idx, N + 1 - k end
        grid[y][x] = line[k]
    end
end

local function apply_move(grid, dir)
    local total, moved = 0, false
    for idx = 1, N do
        local line = read_line(grid, dir, idx)
        local out, gained, changed = slide_line(line)
        if changed then moved = true end
        total = total + gained
        write_line(grid, dir, idx, out)
    end
    return moved, total
end

local function empty_cells(grid)
    local free = {}
    for y = 1, N do
        for x = 1, N do
            if not grid[y][x] then free[#free + 1] = { x = x, y = y } end
        end
    end
    return free
end

local function spawn(grid)
    local free = empty_cells(grid)
    if #free == 0 then return false end
    local c = free[math.random(#free)]
    grid[c.y][c.x] = (math.random(10) == 1) and 4 or 2
    return true
end

local function copy_grid(grid)
    local g = {}
    for y = 1, N do
        g[y] = {}
        for x = 1, N do g[y][x] = grid[y][x] end
    end
    return g
end

local function any_move(grid)
    for _, dir in ipairs({ "left", "right", "up", "down" }) do
        local moved = apply_move(copy_grid(grid), dir)
        if moved then return true end
    end
    return false
end

local function best_tile(grid)
    local best = 0
    for y = 1, N do
        for x = 1, N do
            if grid[y][x] and grid[y][x] > best then best = grid[y][x] end
        end
    end
    return best
end

local function board_formspec(s, msg)
    local fs = {
        "formspec_version[4]",
        "size[9.2,12.4]",
        "bgcolor[#1b1230;true]",
        "style_type[label;font=bold]",
        "label[3.6,0.6;2048]",
        "style_type[label;font=normal]",
        "label[0.6,1.2;Puntos: " .. s.score .. "    Mayor ficha: " .. best_tile(s.grid) .. "]",
    }

    for y = 1, N do
        for x = 1, N do
            local v  = s.grid[y][x]
            local px = 0.6 + (x - 1) * 2.0
            local py = 1.7 + (y - 1) * 2.0
            fs[#fs + 1] = "box[" .. px .. "," .. py .. ";1.8,1.8;" ..
                (TILE_COLOR[v or 0] or "#f0d040") .. "]"
            if v then
                local digits = #tostring(v)
                local off    = 0.9 - digits * 0.17
                fs[#fs + 1] = "style_type[label;font=bold;font_size=*1.4]"
                fs[#fs + 1] = "label[" .. (px + off) .. "," .. (py + 0.95) ..
                    ";" .. v .. "]"
                fs[#fs + 1] = "style_type[label;font=normal;font_size=*1]"
            end
        end
    end

    if msg then
        fs[#fs + 1] = "style_type[label;font=bold]"
        fs[#fs + 1] = "label[0.6,10.1;" .. minetest.formspec_escape(msg) .. "]"
        fs[#fs + 1] = "style_type[label;font=normal]"
    end

    -- Controles en cruz
    fs[#fs + 1] = "button[3.7,10.5;1.8,0.8;up;Arriba]"
    fs[#fs + 1] = "button[1.8,11.4;1.8,0.8;left;Izq]"
    fs[#fs + 1] = "button[3.7,11.4;1.8,0.8;down;Abajo]"
    fs[#fs + 1] = "button[5.6,11.4;1.8,0.8;right;Der]"
    fs[#fs + 1] = "button[0.6,10.5;1.8,0.8;new;Reiniciar]"
    fs[#fs + 1] = "button_exit[6.8,10.5;1.8,0.8;quit;Salir]"
    return table.concat(fs)
end

local function reset(s)
    s.grid  = {}
    for y = 1, N do s.grid[y] = {} end
    s.score = 0
    s.won   = false
    s.over  = false
    s.rank  = nil
    spawn(s.grid)
    spawn(s.grid)
end

arcade.register_game({
    id       = "dosmil",
    title    = "2048",
    desc     = "Fusiona fichas hasta llegar a 2048",
    realtime = false,

    on_start = function(s)
        reset(s)
        arcade.show(s, "board", board_formspec(s))
    end,

    on_fields = function(s, page, fields)
        if fields.quit then
            arcade.stop(s.pname, true)
            return
        end
        if fields.new then
            reset(s)
            arcade.show(s, "board", board_formspec(s))
            return
        end

        local dir
        for _, d in ipairs({ "left", "right", "up", "down" }) do
            if fields[d] then dir = d end
        end
        if not dir or s.over then return end

        local moved, gained = apply_move(s.grid, dir)
        if not moved then
            arcade.show(s, "board", board_formspec(s, "Por ahi no se mueve nada."))
            return
        end

        s.score = s.score + gained
        spawn(s.grid)

        local msg
        if not s.won and best_tile(s.grid) >= 2048 then
            s.won = true
            s.score = s.score + 2000
            msg = "LLEGASTE A 2048! Puedes seguir jugando."
        end

        if not any_move(s.grid) then
            arcade.game_over(s)
            msg = "Sin movimientos. " .. arcade.record_text(s)
        end

        arcade.show(s, "board", board_formspec(s, msg))
    end,
})

-- Expuesto solo para los tests de tools/test_logic.py
arcade._dosmil_internals = {
    slide_line = slide_line,
    apply_move = apply_move,
    any_move   = any_move,
}
