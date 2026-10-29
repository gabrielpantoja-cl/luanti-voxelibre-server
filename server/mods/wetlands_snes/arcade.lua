-- ============================================================================
-- wetlands_snes / arcade.lua
-- Framework compartido de la consola retro.
--
-- Dos tipos de juego:
--   * realtime = true  -> la "pantalla" es una rejilla de elementos HUD tipo
--     image (un elemento por celda, estilo matriz LED). El jugador queda
--     congelado y sus teclas WASD actuan como D-pad. Asi se juega igual que en
--     una consola de verdad, sin clics.
--   * realtime = false -> el juego vive en un formspec (turnos, sin prisa).
--
-- IMPORTANTE: nunca se generan texturas dinamicas ([combine: o [png:) por
-- frame. El cliente cachea las texturas generadas de forma indefinida y la
-- memoria crece sin limite. En su lugar se intercambian texturas fijas
-- wetlands_snes_px_*.png celda por celda, y solo las que cambiaron.
-- ============================================================================

local modname = minetest.get_current_modname()

local arcade = {
    games    = {},   -- id -> def
    order    = {},   -- ids en orden de menu
    sessions = {},   -- player_name -> session
}

local storage       = minetest.get_mod_storage()
local CELL_TEX      = 16     -- pixeles de las texturas de celda
local MAX_SCORES    = 5      -- entradas guardadas por juego
local DEFAULT_SCALE = 1.4

-- Paleta de celdas disponibles (ver tools/generate_textures.py)
arcade.PX = {}
for _, c in ipairs({
    "off", "frame", "white", "gray", "red", "orange", "yellow",
    "green", "lime", "cyan", "blue", "purple", "pink", "brown",
}) do
    arcade.PX[c] = "wetlands_snes_px_" .. c .. ".png"
end

-- ============================================================
-- PUNTAJES ALTOS (mod_storage, compartidos por todo el mundo)
-- ============================================================

function arcade.get_scores(game_id)
    local raw = storage:get_string("hs_" .. game_id)
    if raw == "" then return {} end
    return minetest.deserialize(raw) or {}
end

-- Devuelve la posicion (1..MAX_SCORES) si el puntaje entro al top, o nil.
function arcade.add_score(game_id, pname, score)
    if type(score) ~= "number" or score <= 0 then return nil end
    local list = arcade.get_scores(game_id)
    table.insert(list, { name = pname, score = score })
    table.sort(list, function(a, b) return a.score > b.score end)
    while #list > MAX_SCORES do table.remove(list) end
    storage:set_string("hs_" .. game_id, minetest.serialize(list))
    for i, e in ipairs(list) do
        if e.name == pname and e.score == score then return i end
    end
    return nil
end

function arcade.best_score(game_id)
    local list = arcade.get_scores(game_id)
    return list[1]
end

-- ============================================================
-- PANTALLA HUD (rejilla de celdas)
-- ============================================================

local Screen = {}
Screen.__index = Screen

local function add_cell(player, scale, x, y)
    return player:hud_add({
        type      = "image",
        position  = { x = 0.5, y = 0.5 },
        alignment = { x = 0,   y = 0   },   -- centrado en position + offset
        offset    = { x = math.floor(x + 0.5), y = math.floor(y + 0.5) },
        scale     = { x = scale, y = scale },
        text      = arcade.PX.off,
        z_index   = 1,
    })
end

local function add_text(player, y, color, size)
    return player:hud_add({
        type      = "text",
        position  = { x = 0.5, y = 0.5 },
        alignment = { x = 0,   y = 0   },
        offset    = { x = 0,   y = math.floor(y + 0.5) },
        scale     = { x = 100, y = 100 },
        text      = "",
        number    = color,
        style     = 5,   -- 1 negrita + 4 monoespaciada (look retro)
        size      = { x = size or 0, y = 0 },
        z_index   = 2,
    })
end

-- w, h: celdas de la pantalla principal.
-- opts.panel_w / opts.panel_h: rejilla extra a la derecha (ej. "siguiente
-- pieza" de Tetris), separada por una celda de aire.
function arcade.new_screen(player, w, h, opts)
    opts = opts or {}
    local scale = opts.scale or DEFAULT_SCALE
    local cell  = CELL_TEX * scale
    local pw    = opts.panel_w or 0
    local ph    = opts.panel_h or 0

    -- Ancho total (principal + aire + panel) para centrar el conjunto.
    local total_w = w + (pw > 0 and (pw + 1) or 0)
    local left    = -(total_w * cell) / 2 + cell / 2   -- centro de la columna 1
    local top     = -(h * cell) / 2 + cell / 2         -- centro de la fila 1

    local self = setmetatable({
        player = player,
        pname  = player:get_player_name(),
        w = w, h = h, panel_w = pw, panel_h = ph,
        cell = cell, scale = scale,
        buf = {}, cur = {}, ids = {},
        pbuf = {}, pcur = {}, pids = {},
        texts = {},
    }, Screen)

    for row = 1, h do
        for col = 1, w do
            local i = (row - 1) * w + col
            self.ids[i] = add_cell(player, scale,
                left + (col - 1) * cell, top + (row - 1) * cell)
            self.cur[i] = "off"
            self.buf[i] = "off"
        end
    end

    if pw > 0 and ph > 0 then
        local pleft = left + (w + 1) * cell
        for row = 1, ph do
            for col = 1, pw do
                local i = (row - 1) * pw + col
                self.pids[i] = add_cell(player, scale,
                    pleft + (col - 1) * cell, top + (row - 1) * cell)
                self.pcur[i] = "off"
                self.pbuf[i] = "off"
            end
        end
    end

    local half = (h * cell) / 2
    self.texts.title  = add_text(player, -half - 30, 0xFFE066, 24)
    self.texts.status = add_text(player,  half + 18, 0xFFFFFF, 20)
    self.texts.hint   = add_text(player,  half + 44, 0x99AACC, 16)
    self.texts.big    = add_text(player, 0, 0xFF6666, 32)

    return self
end

function Screen:set(x, y, color)
    if x < 1 or x > self.w or y < 1 or y > self.h then return end
    self.buf[(y - 1) * self.w + x] = color or "off"
end

function Screen:pset(x, y, color)
    if self.panel_w == 0 then return end
    if x < 1 or x > self.panel_w or y < 1 or y > self.panel_h then return end
    self.pbuf[(y - 1) * self.panel_w + x] = color or "off"
end

function Screen:clear(color)
    color = color or "off"
    for i = 1, self.w * self.h do self.buf[i] = color end
    for i = 1, self.panel_w * self.panel_h do self.pbuf[i] = color end
end

-- Dibuja un marco de una celda de grosor en el borde de la pantalla.
function Screen:border(color)
    color = color or "frame"
    for x = 1, self.w do
        self:set(x, 1, color)
        self:set(x, self.h, color)
    end
    for y = 1, self.h do
        self:set(1, y, color)
        self:set(self.w, y, color)
    end
end

-- Solo manda al cliente las celdas que cambiaron.
function Screen:flush()
    local player = self.player
    if not player then return end
    for i = 1, self.w * self.h do
        local want = self.buf[i] or "off"
        if want ~= self.cur[i] then
            player:hud_change(self.ids[i], "text", arcade.PX[want] or arcade.PX.off)
            self.cur[i] = want
        end
    end
    for i = 1, self.panel_w * self.panel_h do
        local want = self.pbuf[i] or "off"
        if want ~= self.pcur[i] then
            player:hud_change(self.pids[i], "text", arcade.PX[want] or arcade.PX.off)
            self.pcur[i] = want
        end
    end
end

function Screen:line(slot, text, color)
    local id = self.texts[slot]
    if not id or not self.player then return end
    self.player:hud_change(id, "text", text or "")
    if color then self.player:hud_change(id, "number", color) end
end

function Screen:destroy()
    local player = self.player
    if not player then return end
    for _, id in ipairs(self.ids)  do player:hud_remove(id) end
    for _, id in ipairs(self.pids) do player:hud_remove(id) end
    for _, id in pairs(self.texts) do player:hud_remove(id) end
    self.ids, self.pids, self.texts = {}, {}, {}
    self.player = nil
end

-- ============================================================
-- CONGELAR / LIBERAR AL JUGADOR
-- ============================================================

local function lock_player(player, s)
    s.saved_physics = player:get_physics_override()
    s.saved_flags   = player:hud_get_flags()
    player:set_physics_override({ speed = 0, jump = 0, sneak = false })
    player:hud_set_flags({
        hotbar = false, healthbar = false, crosshair = false,
        wielditem = false, breathbar = false, minimap = false,
    })
end

local function unlock_player(player, s)
    if not player then return end
    if s.saved_physics then player:set_physics_override(s.saved_physics) end
    if s.saved_flags   then player:hud_set_flags(s.saved_flags) end
end

-- ============================================================
-- SESIONES
-- ============================================================

function arcade.register_game(def)
    assert(def.id and def.title, "wetlands_snes: juego sin id/title")
    arcade.games[def.id] = def
    table.insert(arcade.order, def.id)
end

function arcade.session(pname)
    return arcade.sessions[pname]
end

-- Cierra la sesion. silent = true evita reabrir el menu.
function arcade.stop(pname, silent)
    local s = arcade.sessions[pname]
    if not s then return end
    arcade.sessions[pname] = nil
    local player = minetest.get_player_by_name(pname)
    if s.def.on_stop then
        local ok, err = pcall(s.def.on_stop, s)
        if not ok then
            minetest.log("error", "[" .. modname .. "] on_stop: " .. tostring(err))
        end
    end
    if s.screen then s.screen:destroy() end
    if s.locked and player then unlock_player(player, s) end
    if not silent and player then
        minetest.close_formspec(pname, "")
        minetest.after(0.1, function()
            if minetest.get_player_by_name(pname) and not arcade.sessions[pname] then
                arcade.show_menu(pname)
            end
        end)
    end
end

function arcade.start(pname, game_id)
    local def = arcade.games[game_id]
    if not def then return false end
    local player = minetest.get_player_by_name(pname)
    if not player then return false end

    arcade.stop(pname, true)

    local s = {
        pname  = pname,
        player = player,
        def    = def,
        game   = game_id,
        score  = 0,
        over   = false,
        t      = 0,
        prev   = {},
    }
    arcade.sessions[pname] = s

    if def.realtime then
        minetest.close_formspec(pname, "")
        lock_player(player, s)
        s.locked = true
        s.screen = arcade.new_screen(player, def.w, def.h, {
            scale = def.scale, panel_w = def.panel_w, panel_h = def.panel_h,
        })
        s.screen:line("title", def.title)
        s.screen:line("hint", def.hint or "E = salir")
    end

    local ok, err = pcall(def.on_start, s)
    if not ok then
        minetest.log("error", "[" .. modname .. "] on_start " .. game_id ..
            ": " .. tostring(err))
        arcade.stop(pname, true)
        minetest.chat_send_player(pname, "La consola se trabo. Avisale a gabo con /gabo")
        return false
    end
    return true
end

-- Fin de partida: guarda el puntaje y deja la pantalla en modo "PRESS START".
-- Devuelve la posicion en la tabla de records, o nil.
function arcade.game_over(s, title)
    if s.over then return s.rank end
    s.over = true
    local rank = arcade.add_score(s.game, s.pname, s.score)
    s.rank = rank
    if s.screen then
        s.screen:line("big", title or "GAME OVER")
        local best = arcade.best_score(s.game)
        local txt  = "Puntos: " .. s.score
        if rank then
            txt = txt .. "   NUEVO RECORD #" .. rank .. "!"
        elseif best then
            txt = txt .. "   Record: " .. best.score .. " (" .. best.name .. ")"
        end
        s.screen:line("status", txt)
        s.screen:line("hint", "ESPACIO = otra vez   |   E = salir")
    end
    return rank
end

-- Texto listo para pegar en el final de un juego de formspec.
function arcade.record_text(s)
    local best = arcade.best_score(s.game)
    if s.rank then
        return "NUEVO RECORD! Quedaste #" .. s.rank .. " de la tabla."
    elseif best then
        return "Record actual: " .. best.score .. " (" .. best.name .. ")"
    end
    return ""
end

-- ============================================================
-- ENTRADA (D-pad) + LOOP DE JUEGO
-- ============================================================

local KEYS = { "up", "down", "left", "right", "jump", "sneak", "aux1" }

minetest.register_globalstep(function(dtime)
    for pname, s in pairs(arcade.sessions) do
        local player = minetest.get_player_by_name(pname)
        if not player then
            arcade.sessions[pname] = nil
        elseif s.def.realtime then
            local ctrl    = player:get_player_control()
            local pressed = {}
            for _, k in ipairs(KEYS) do
                local now = ctrl[k] and true or false
                if now and not s.prev[k] then pressed[k] = true end
                s.prev[k] = now
            end

            if pressed.aux1 then
                arcade.stop(pname)
            elseif s.over then
                if pressed.jump then arcade.start(pname, s.game) end
            else
                s.t = s.t + dtime
                local ok, err = pcall(s.def.on_step, s, dtime, pressed, ctrl)
                if not ok then
                    minetest.log("error", "[" .. modname .. "] on_step " ..
                        s.game .. ": " .. tostring(err))
                    arcade.stop(pname, true)
                    minetest.chat_send_player(pname,
                        "La consola se trabo. Avisale a gabo con /gabo")
                elseif s.screen then
                    s.screen:flush()
                end
            end
        elseif s.def.on_step and not s.over then
            -- Juegos de formspec que igual necesitan reloj (ej. el topo).
            s.t = s.t + dtime
            local ok, err = pcall(s.def.on_step, s, dtime)
            if not ok then
                minetest.log("error", "[" .. modname .. "] on_step " ..
                    s.game .. ": " .. tostring(err))
                arcade.stop(pname, true)
            end
        end
    end
end)

-- Mientras juega, el jugador esta inmovil: no puede recibir dano.
minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if hp_change < 0 and arcade.sessions[player:get_player_name()] then
        return 0
    end
    return hp_change
end, true)

minetest.register_on_leaveplayer(function(player)
    arcade.sessions[player:get_player_name()] = nil
end)

minetest.register_on_dieplayer(function(player)
    arcade.stop(player:get_player_name(), true)
end)

minetest.register_on_shutdown(function()
    for pname in pairs(arcade.sessions) do
        arcade.stop(pname, true)
    end
end)

-- ============================================================
-- MENU PRINCIPAL
-- ============================================================

local function esc(t)
    return minetest.formspec_escape(t)
end

function arcade.show_menu(pname)
    local n    = #arcade.order
    local rows = math.ceil(n / 2)
    local h    = 1.9 + rows * 1.55 + 1.3

    local fs = {
        "formspec_version[4]",
        "size[12,", h, "]",
        "bgcolor[#120024;true]",
        "style_type[label;font=bold]",
        "label[4.4,0.6;CONSOLA RETRO]",
        "style_type[label;font=normal]",
        "label[0.6,1.25;Elige un juego. Los de tiempo real se juegan con WASD.]",
    }

    for i, id in ipairs(arcade.order) do
        local def  = arcade.games[id]
        local col  = (i - 1) % 2
        local row  = math.floor((i - 1) / 2)
        local x    = 0.6 + col * 5.6
        local y    = 1.8 + row * 1.55
        local best = arcade.best_score(id)
        local tag  = def.realtime and "  [WASD]" or ""
        fs[#fs + 1] = "button[" .. x .. "," .. y .. ";5.2,0.9;play_" .. id ..
            ";" .. esc(def.title .. tag) .. "]"
        local sub = def.desc or ""
        if best then
            sub = sub .. "  -  Record: " .. best.score .. " (" .. best.name .. ")"
        end
        fs[#fs + 1] = "style_type[label;font_size=*0.8]"
        fs[#fs + 1] = "label[" .. (x + 0.1) .. "," .. (y + 1.2) .. ";" .. esc(sub) .. "]"
        fs[#fs + 1] = "style_type[label;font_size=*1]"
    end

    local by = 1.8 + rows * 1.55 + 0.35
    fs[#fs + 1] = "button[0.6," .. by .. ";5.2,0.9;scores;Tabla de records]"
    fs[#fs + 1] = "button_exit[6.2," .. by .. ";5.2,0.9;quit;Apagar consola]"

    minetest.show_formspec(pname, modname .. ":menu", table.concat(fs))
end

function arcade.show_scores(pname)
    local fs = {
        "formspec_version[4]",
        "size[11,", 2.4 + #arcade.order * 1.5, "]",
        "bgcolor[#120024;true]",
        "style_type[label;font=bold]",
        "label[3.9,0.6;TABLA DE RECORDS]",
        "style_type[label;font=normal]",
    }
    for i, id in ipairs(arcade.order) do
        local y    = 1.3 + (i - 1) * 1.5
        local list = arcade.get_scores(id)
        local line = "(sin jugadas todavia)"
        if #list > 0 then
            local parts = {}
            for k, e in ipairs(list) do
                parts[#parts + 1] = k .. ". " .. e.name .. " " .. e.score
            end
            line = table.concat(parts, "    ")
        end
        fs[#fs + 1] = "style_type[label;font=bold]"
        fs[#fs + 1] = "label[0.6," .. y .. ";" .. esc(arcade.games[id].title) .. "]"
        fs[#fs + 1] = "style_type[label;font=normal;font_size=*0.9]"
        fs[#fs + 1] = "label[0.6," .. (y + 0.55) .. ";" .. esc(line) .. "]"
        fs[#fs + 1] = "style_type[label;font_size=*1]"
    end
    fs[#fs + 1] = "button[4," .. (1.4 + #arcade.order * 1.5) .. ";3,0.9;back;Volver]"
    minetest.show_formspec(pname, modname .. ":scores", table.concat(fs))
end

-- ============================================================
-- RUTEO DE FORMSPECS
-- ============================================================

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local pname = player:get_player_name()

    if formname == modname .. ":menu" then
        if fields.scores then
            arcade.show_scores(pname)
            return true
        end
        for id in pairs(arcade.games) do
            if fields["play_" .. id] then
                arcade.start(pname, id)
                return true
            end
        end
        return true
    end

    if formname == modname .. ":scores" then
        if fields.back then arcade.show_menu(pname) end
        return true
    end

    -- Juegos de formspec: el formname es "<mod>:<game>:<pagina>"
    local game_id, page = formname:match("^" .. modname .. ":([%w_]+):(.*)$")
    if not game_id then return false end
    local s = arcade.sessions[pname]
    if not s or s.game ~= game_id or not s.def.on_fields then return true end
    local ok, err = pcall(s.def.on_fields, s, page, fields)
    if not ok then
        minetest.log("error", "[" .. modname .. "] on_fields " .. game_id ..
            ": " .. tostring(err))
        arcade.stop(pname, true)
    end
    return true
end)

-- Helper para juegos de formspec.
function arcade.show(s, page, fs)
    minetest.show_formspec(s.pname, modname .. ":" .. s.game .. ":" .. page, fs)
end

arcade.modname = modname
return arcade
