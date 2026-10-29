-- ============================================================
-- Atrapa al Topo (whack-a-mole) - formspec con reloj propio
-- Mejoras sobre la primera version: los topos aceleran, aparecen hasta dos a
-- la vez, hay topos dorados que valen 3, racha con bonus y penalizacion por
-- pegarle al hoyo vacio.
-- ============================================================

local arcade = wetlands_snes

local N            = 9          -- 3x3
local DURATION     = 40
local INTERVAL_MAX = 1.45
local INTERVAL_MIN = 0.55
local TWO_MOLES_AT = 15         -- segundos jugados antes de permitir dos topos
local GOLD_AT      = 10
local GOLD_CHANCE  = 5          -- 1 de cada N topos nuevos es dorado
local COMBO_EVERY  = 5

local function interval_for(elapsed)
    local f = math.min(1, elapsed / DURATION)
    return INTERVAL_MAX - (INTERVAL_MAX - INTERVAL_MIN) * f
end

local function place_moles(s)
    local elapsed = DURATION - s.time_left
    s.holes = {}
    local count = (elapsed >= TWO_MOLES_AT and math.random(2) == 1) and 2 or 1
    local used = {}
    for _ = 1, count do
        local p
        repeat p = math.random(N) until not used[p]
        used[p] = true
        local gold = elapsed >= GOLD_AT and math.random(GOLD_CHANCE) == 1
        s.holes[p] = gold and "gold" or "normal"
    end
end

local function board_formspec(s, msg)
    local fs = {
        "formspec_version[4]",
        "size[7.2,9.4]",
        "bgcolor[#0d001a;true]",
        "style_type[label;font=bold]",
        "label[1.9,0.6;ATRAPA AL TOPO]",
        "style_type[label;font=normal]",
        "label[0.6,1.25;Puntos: " .. s.score ..
            "    Tiempo: " .. math.max(0, math.ceil(s.time_left)) .. "s" ..
            "    Racha: " .. s.combo .. "]",
    }
    for i = 1, N do
        local col = (i - 1) % 3
        local row = math.floor((i - 1) / 3)
        local x   = 0.6 + col * 2.0
        local y   = 1.8 + row * 2.0
        local tex = "wetlands_snes_hole.png"
        if s.holes[i] == "normal" then
            tex = "wetlands_snes_mole.png"
        elseif s.holes[i] == "gold" then
            tex = "wetlands_snes_mole_gold.png"
        end
        fs[#fs + 1] = "image_button[" .. x .. "," .. y .. ";1.8,1.8;" ..
            tex .. ";t" .. i .. ";]"
    end
    fs[#fs + 1] = "label[0.6,8.1;" ..
        minetest.formspec_escape(msg or "El dorado vale 3 puntos!") .. "]"
    fs[#fs + 1] = "button_exit[2.4,8.5;2.4,0.8;quit;Salir]"
    return table.concat(fs)
end

local function final_formspec(s)
    local msg = s.score >= 45 and "Increible! Eres cazador experto de topos!" or
                s.score >= 28 and "Muy bien hecho!" or
                s.score >= 14 and "Buen reflejo, sigue practicando!" or
                "La proxima lo haras mejor!"
    return "formspec_version[4]" ..
        "size[8,5.6]" ..
        "bgcolor[#0d001a;true]" ..
        "style_type[label;font=bold]" ..
        "label[2.6,0.8;TIEMPO AGOTADO]" ..
        "style_type[label;font=normal]" ..
        "label[0.6,2.0;Puntos: " .. s.score .. ". " .. minetest.formspec_escape(msg) .. "]" ..
        "label[0.6,2.7;" .. minetest.formspec_escape(arcade.record_text(s)) .. "]" ..
        "button[0.6,4.4;3.2,0.8;new;Otra vez]" ..
        "button_exit[4.2,4.4;3.2,0.8;quit;Cerrar]"
end

local function reset(s)
    s.score     = 0
    s.time_left = DURATION
    s.combo     = 0
    s.hits      = 0
    s.acc       = 0
    s.over      = false
    s.rank      = nil
    s.holes     = {}
    place_moles(s)
end

arcade.register_game({
    id       = "topo",
    title    = "Atrapa al Topo",
    desc     = "Reflejos: 40 segundos de topos",
    realtime = false,

    on_start = function(s)
        reset(s)
        arcade.show(s, "board", board_formspec(s))
    end,

    on_step = function(s, dtime)
        s.time_left = s.time_left - dtime
        if s.time_left <= 0 then
            arcade.game_over(s)
            arcade.show(s, "final", final_formspec(s))
            return
        end

        s.acc = s.acc + dtime
        if s.acc >= interval_for(DURATION - s.time_left) then
            s.acc = 0
            s.combo = 0                -- se escapo: adios racha
            place_moles(s)
            arcade.show(s, "board", board_formspec(s, "Se escapo!"))
        end
    end,

    on_fields = function(s, page, fields)
        if fields.new then
            reset(s)
            arcade.show(s, "board", board_formspec(s))
            return
        end
        if fields.quit then
            arcade.stop(s.pname, true)
            return
        end
        if s.over then return end

        for i = 1, N do
            if fields["t" .. i] then
                local kind = s.holes[i]
                local msg
                if kind then
                    local pts = (kind == "gold") and 3 or 1
                    s.score = s.score + pts
                    s.hits  = s.hits + 1
                    s.combo = s.combo + 1
                    msg = (kind == "gold") and "Topo dorado! +3" or "Atrapado! +1"
                    if s.combo % COMBO_EVERY == 0 then
                        s.score = s.score + 2
                        msg = "Racha de " .. s.combo .. "! +2 extra"
                    end
                    s.holes[i] = nil
                    if not next(s.holes) then
                        s.acc = 0
                        place_moles(s)
                    end
                else
                    s.score = math.max(0, s.score - 1)
                    s.combo = 0
                    msg = "Hoyo vacio... -1"
                end
                arcade.show(s, "board", board_formspec(s, msg))
                return
            end
        end
    end,
})
