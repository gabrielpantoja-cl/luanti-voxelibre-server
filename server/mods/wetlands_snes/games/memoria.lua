-- ============================================================
-- Memoria - por turnos, sobre formspec
-- 16 cartas, 8 pares de colores. Clasico juego de memoria: destapa dos,
-- si no coinciden se vuelven a tapar solas. Menos intentos = mas puntos.
-- ============================================================

local arcade = wetlands_snes

local COLS, ROWS = 4, 4
local TOTAL      = COLS * ROWS
local PAIRS      = math.floor(TOTAL / 2)
local FLIP_BACK  = 1.0     -- segundos que quedan visibles las cartas falladas

local SYMBOLS = { "red", "orange", "yellow", "green", "cyan", "blue", "purple", "pink" }

local function shuffled_deck()
    local deck = {}
    for i = 1, PAIRS do
        deck[#deck + 1] = SYMBOLS[i]
        deck[#deck + 1] = SYMBOLS[i]
    end
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
    return deck
end

local function card_formspec(s, msg)
    local fs = {
        "formspec_version[4]",
        "size[8.6,10.6]",
        "bgcolor[#101a2e;true]",
        "style_type[label;font=bold]",
        "label[3.1,0.6;MEMORIA]",
        "style_type[label;font=normal]",
        "label[0.6,1.2;Pares: " .. s.found .. "/" .. PAIRS ..
            "    Intentos: " .. s.tries .. "]",
    }

    for i = 1, TOTAL do
        local col = (i - 1) % COLS
        local row = math.floor((i - 1) / COLS)
        local x   = 0.6 + col * 1.9
        local y   = 1.7 + row * 1.9
        local tex
        if s.matched[i] or s.shown[i] then
            tex = "wetlands_snes_px_" .. s.deck[i] .. ".png"
        else
            tex = "wetlands_snes_card.png"
        end
        if s.matched[i] then
            -- Las encontradas quedan fijas, sin boton (no se pueden volver a tocar)
            fs[#fs + 1] = "image[" .. x .. "," .. y .. ";1.7,1.7;" .. tex .. "]"
        else
            fs[#fs + 1] = "image_button[" .. x .. "," .. y .. ";1.7,1.7;" ..
                tex .. ";c" .. i .. ";]"
        end
    end

    if msg then
        fs[#fs + 1] = "label[0.6,9.4;" .. minetest.formspec_escape(msg) .. "]"
    end
    fs[#fs + 1] = "button[0.6,9.7;3.5,0.8;new;Nuevo juego]"
    fs[#fs + 1] = "button_exit[4.5,9.7;3.5,0.8;quit;Salir]"
    return table.concat(fs)
end

local function reset(s)
    s.deck    = shuffled_deck()
    s.shown   = {}
    s.matched = {}
    s.first   = nil
    s.tries   = 0
    s.found   = 0
    s.score   = 0
    s.over    = false
    s.rank    = nil
    s.busy    = false
end

arcade.register_game({
    id       = "memoria",
    title    = "Memoria",
    desc     = "Encuentra los 8 pares de colores",
    realtime = false,

    on_start = function(s)
        reset(s)
        arcade.show(s, "board", card_formspec(s, "Destapa dos cartas iguales."))
    end,

    on_fields = function(s, page, fields)
        if fields.quit then
            arcade.stop(s.pname, true)
            return
        end
        if fields.new then
            reset(s)
            arcade.show(s, "board", card_formspec(s, "Nuevo mazo mezclado!"))
            return
        end
        if s.busy or s.over then return end

        local idx
        for i = 1, TOTAL do
            if fields["c" .. i] then idx = i end
        end
        if not idx or s.matched[idx] or s.shown[idx] then return end

        s.shown[idx] = true

        if not s.first then
            s.first = idx
            arcade.show(s, "board", card_formspec(s))
            return
        end

        local a, b = s.first, idx
        s.first = nil
        s.tries = s.tries + 1

        if s.deck[a] == s.deck[b] then
            s.matched[a], s.matched[b] = true, true
            s.shown[a], s.shown[b] = nil, nil
            s.found = s.found + 1

            if s.found >= PAIRS then
                -- Puntaje: perfecto = 8 intentos. Cada intento extra resta 40.
                s.score = math.max(50, 1000 - (s.tries - PAIRS) * 40)
                arcade.game_over(s)
                arcade.show(s, "board", card_formspec(s,
                    "Listo en " .. s.tries .. " intentos! " ..
                    s.score .. " puntos. " .. arcade.record_text(s)))
            else
                arcade.show(s, "board", card_formspec(s, "Par encontrado!"))
            end
            return
        end

        -- No coinciden: se muestran un momento y se tapan solas.
        s.busy = true
        arcade.show(s, "board", card_formspec(s, "No son iguales..."))
        local pname = s.pname
        minetest.after(FLIP_BACK, function()
            local cur = arcade.session(pname)
            if not cur or cur ~= s then return end
            s.shown[a], s.shown[b] = nil, nil
            s.busy = false
            arcade.show(s, "board", card_formspec(s))
        end)
    end,
})
