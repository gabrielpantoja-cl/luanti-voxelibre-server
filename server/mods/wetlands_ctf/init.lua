-- wetlands_ctf — Captura la bandera casero para la Llanura CTF (puerto 30003)
-- Dos equipos (rojo / azul), una bandera por equipo en su base. Toca la bandera
-- enemiga, llevala a tu base (con tu bandera en casa) y anota un punto.
-- Todo sobre VoxeLibre. Texto en espanol, apto para ninos 7+.

local modname = minetest.get_current_modname()

local ctf = {}
_G.wetlands_ctf = ctf

-- ============================================================
-- CONFIGURACION
-- ============================================================
-- La superficie de tierra esta en y=0 (ver wetlands_flatworld), asi que las
-- banderas se colocan en y=1 (sobre el suelo) y los spawns en y=2.
ctf.WIN_SCORE = 3            -- capturas para ganar la ronda
ctf.CHECK_DT  = 0.5         -- cada cuanto se revisa la captura (segundos)
ctf.CAP_DIST  = 3           -- distancia a la base propia para capturar

ctf.teams = {
    rojo = {
        label    = "Rojo",
        color    = "#d83030",
        flag_pos = { x = -60, y = 1, z = 0 },
        spawn    = { x = -60, y = 2, z = 10 },
    },
    azul = {
        label    = "Azul",
        color    = "#3060e0",
        flag_pos = { x = 60, y = 1, z = 0 },
        spawn    = { x = 60, y = 2, z = 10 },
    },
}

-- ============================================================
-- ESTADO EN MEMORIA
-- ============================================================
ctf.player_team  = {}                       -- name -> "rojo"/"azul"
ctf.carrier      = { rojo = nil, azul = nil } -- quien lleva la bandera de cada equipo
ctf.flag_home    = { rojo = true, azul = true } -- la bandera esta en su base?
ctf.score        = { rojo = 0, azul = 0 }
ctf.markers      = {}                        -- name -> entidad marcador
ctf.hud          = {}                        -- name -> id del hud del marcador

-- ============================================================
-- NODOS BANDERA
-- ============================================================
-- Cubo de color solido y luminoso (visible de lejos), indestructible (anti-grief).
-- on_rightclick = tomar la bandera enemiga.
for tname, team in pairs(ctf.teams) do
    minetest.register_node("wetlands_ctf:flag_" .. tname, {
        description = "Bandera " .. team.label .. " (CTF)",
        drawtype = "normal",
        tiles = { "[fill:16x16:" .. team.color },
        light_source = 12,
        is_ground_content = false,
        diggable = false,
        pointable = true,
        groups = { not_in_creative_inventory = 1, immortal = 1 },
        on_blast = function() end,
        drop = "",
        on_rightclick = function(pos, node, clicker)
            if clicker and clicker:is_player() then
                ctf.try_grab(clicker:get_player_name(), tname)
            end
        end,
    })
end

-- Entidad que cuelga sobre quien lleva una bandera (marcador visual).
minetest.register_entity("wetlands_ctf:marker", {
    initial_properties = {
        visual = "cube",
        visual_size = { x = 0.45, y = 0.45 },
        physical = false,
        pointable = false,
        static_save = false,
        glow = 12,
    },
    on_activate = function(self, staticdata)
        local color = staticdata ~= "" and staticdata or "#ffffff"
        local tex = "[fill:16x16:" .. color            -- textura generada por el motor
        self.object:set_properties({ textures = { tex, tex, tex, tex, tex, tex } })
    end,
})

-- ============================================================
-- BANDERAS: COLOCAR / DEVOLVER
-- ============================================================
function ctf.place_flag(tname)
    local pos = ctf.teams[tname].flag_pos
    minetest.forceload_block(pos, true)        -- mantener la base cargada
    ctf.flag_home[tname] = true
    -- El bloque de la base puede no estar generado todavia (singlenode + emerge
    -- asincrono). Emergerlo y colocar la bandera en el callback garantiza que el
    -- set_node no se pierda en area no cargada.
    minetest.emerge_area(pos, pos, function(blockpos, action, calls_remaining)
        if calls_remaining == 0 then
            minetest.set_node(pos, { name = "wetlands_ctf:flag_" .. tname })
        end
    end)
end

-- Devuelve la bandera tname a su base y limpia al portador.
function ctf.return_flag(tname, announce)
    local carrier = ctf.carrier[tname]
    if carrier and ctf.markers[carrier] then
        ctf.markers[carrier]:remove()
        ctf.markers[carrier] = nil
    end
    ctf.carrier[tname] = nil
    ctf.place_flag(tname)
    if announce then
        minetest.chat_send_all("[CTF] La bandera " .. ctf.teams[tname].label .. " volvio a su base.")
    end
end

-- ============================================================
-- TOMAR LA BANDERA
-- ============================================================
function ctf.try_grab(name, flag_team)
    local team = ctf.player_team[name]
    if not team then
        minetest.chat_send_player(name, "[CTF] Primero unete a un equipo con /ctf entrar")
        return
    end
    if flag_team == team then
        minetest.chat_send_player(name, "[CTF] Esa es tu propia bandera, defiendela!")
        return
    end
    if not ctf.flag_home[flag_team] then
        minetest.chat_send_player(name, "[CTF] Esa bandera ya la tiene alguien.")
        return
    end

    -- Tomar: quitar el nodo, marcar portador, colgar marcador.
    ctf.carrier[flag_team] = name
    ctf.flag_home[flag_team] = false
    minetest.set_node(ctf.teams[flag_team].flag_pos, { name = "air" })

    local player = minetest.get_player_by_name(name)
    if player then
        local marker = minetest.add_entity(
            vector.add(player:get_pos(), { x = 0, y = 1.1, z = 0 }),
            "wetlands_ctf:marker",
            ctf.teams[flag_team].color
        )
        if marker then
            marker:set_attach(player, "", { x = 0, y = 11, z = 0 }, { x = 0, y = 0, z = 0 })
            ctf.markers[name] = marker
        end
    end

    minetest.chat_send_all("[CTF] " .. name .. " (" .. ctf.teams[team].label ..
        ") tomo la bandera " .. ctf.teams[flag_team].label .. "! Llevala a tu base.")
end

-- ============================================================
-- CAPTURA / PUNTAJE / VICTORIA
-- ============================================================
local function reset_round(keep_score)
    if not keep_score then
        ctf.score.rojo = 0
        ctf.score.azul = 0
    end
    ctf.return_flag("rojo", false)
    ctf.return_flag("azul", false)
    ctf.update_all_hud()
end

local function score_capture(team)
    ctf.score[team] = ctf.score[team] + 1
    minetest.chat_send_all("[CTF] Equipo " .. ctf.teams[team].label ..
        " captura! Marcador  Rojo " .. ctf.score.rojo .. " - " .. ctf.score.azul .. " Azul")
    ctf.update_all_hud()

    if ctf.score[team] >= ctf.WIN_SCORE then
        minetest.chat_send_all("[CTF] *** Equipo " .. ctf.teams[team].label ..
            " GANA la ronda! *** Nueva ronda en 5 segundos.")
        minetest.after(5, function() reset_round(false) end)
    end
end

-- ============================================================
-- BUCLE: detectar captura
-- ============================================================
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < ctf.CHECK_DT then return end
    timer = 0

    for flag_team, carrier in pairs(ctf.carrier) do
        if carrier then
            local player = minetest.get_player_by_name(carrier)
            if not player then
                ctf.return_flag(flag_team, true)   -- portador ya no esta
            else
                local team = ctf.player_team[carrier]      -- equipo del portador
                -- Solo se anota si la bandera propia esta en casa.
                if team and ctf.flag_home[team] then
                    local d = vector.distance(player:get_pos(), ctf.teams[team].flag_pos)
                    if d <= ctf.CAP_DIST then
                        ctf.return_flag(flag_team, false)  -- la enemiga vuelve a su base
                        score_capture(team)
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- HUD MARCADOR
-- ============================================================
function ctf.update_all_hud()
    for _, p in ipairs(minetest.get_connected_players()) do
        ctf.update_hud(p:get_player_name())
    end
end

function ctf.update_hud(name)
    local player = minetest.get_player_by_name(name)
    if not player then return end
    local text = "CTF   Rojo " .. ctf.score.rojo .. "  -  " .. ctf.score.azul .. " Azul"
    local team = ctf.player_team[name]
    if team then
        text = text .. "   (tu equipo: " .. ctf.teams[team].label .. ")"
    end
    if ctf.hud[name] then
        player:hud_change(ctf.hud[name], "text", text)
    else
        ctf.hud[name] = player:hud_add({
            hud_elem_type = "text",
            position = { x = 0.5, y = 0 },
            offset = { x = 0, y = 24 },
            alignment = { x = 0, y = 0 },
            number = 0xFFFFFF,
            text = text,
        })
    end
end

-- ============================================================
-- EQUIPOS: ENTRAR / SALIR / RESPAWN
-- ============================================================
local function team_count(t)
    local n = 0
    for _, tm in pairs(ctf.player_team) do
        if tm == t then n = n + 1 end
    end
    return n
end

function ctf.join(name, want)
    -- Auto-balance si no se pide equipo.
    local team = want
    if team ~= "rojo" and team ~= "azul" then
        team = (team_count("rojo") <= team_count("azul")) and "rojo" or "azul"
    end
    ctf.player_team[name] = team
    minetest.chat_send_player(name, "[CTF] Te uniste al equipo " .. ctf.teams[team].label ..
        ". Escribe /ctf base para ir a tu base.")
    ctf.update_hud(name)
    -- Llevar al spawn del equipo.
    local player = minetest.get_player_by_name(name)
    if player then player:set_pos(ctf.teams[team].spawn) end
end

function ctf.leave(name)
    -- Si llevaba una bandera, devolverla.
    for flag_team, carrier in pairs(ctf.carrier) do
        if carrier == name then ctf.return_flag(flag_team, true) end
    end
    ctf.player_team[name] = nil
    ctf.update_hud(name)
end

minetest.register_on_respawnplayer(function(player)
    local team = ctf.player_team[player:get_player_name()]
    if team then
        player:set_pos(ctf.teams[team].spawn)
        return true
    end
end)

minetest.register_on_dieplayer(function(player)
    local name = player:get_player_name()
    for flag_team, carrier in pairs(ctf.carrier) do
        if carrier == name then ctf.return_flag(flag_team, true) end
    end
end)

minetest.register_on_joinplayer(function(player)
    ctf.update_hud(player:get_player_name())
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    ctf.leave(name)
    ctf.hud[name] = nil
    ctf.markers[name] = nil
end)

-- ============================================================
-- COMANDO /ctf
-- ============================================================
minetest.register_chatcommand("ctf", {
    description = "Captura la bandera: entrar | salir | base | marcador | reset",
    params = "<entrar|salir|base|marcador|reset> [rojo|azul]",
    func = function(name, param)
        local sub, arg = param:match("^(%S+)%s*(%S*)$")
        sub = sub or ""

        if sub == "entrar" then
            ctf.join(name, arg)
            return true
        elseif sub == "salir" then
            ctf.leave(name)
            return true, "[CTF] Saliste del juego."
        elseif sub == "base" then
            local team = ctf.player_team[name]
            if not team then return false, "[CTF] Primero /ctf entrar" end
            local player = minetest.get_player_by_name(name)
            if player then player:set_pos(ctf.teams[team].spawn) end
            return true, "[CTF] Vas a tu base " .. ctf.teams[team].label .. "."
        elseif sub == "marcador" then
            return true, "[CTF] Rojo " .. ctf.score.rojo .. " - " .. ctf.score.azul .. " Azul"
        elseif sub == "reset" then
            if not minetest.check_player_privs(name, { server = true }) then
                return false, "[CTF] Necesitas el privilegio 'server'."
            end
            reset_round(false)
            minetest.chat_send_all("[CTF] " .. name .. " reinicio la ronda. Marcador 0-0.")
            return true
        end
        return false, "Uso: /ctf entrar | salir | base | marcador | reset"
    end,
})

-- ============================================================
-- ARRANQUE: colocar las banderas cuando el mundo este listo
-- ============================================================
minetest.after(3, function()
    ctf.place_flag("rojo")
    ctf.place_flag("azul")
    minetest.log("action", "[" .. modname .. "] Banderas colocadas en sus bases.")
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully")
