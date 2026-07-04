-- valdivia_music: musica ambiental automatica para el mundo Valdivia
-- Reutiliza los tracks .ogg de wetlands-music y los reproduce en bucle por
-- jugador, sin jukebox. Cada jugador escucha su propio stream (to_player).

local modname = minetest.get_current_modname()

-- Tracks curados para una ciudad tranquila. Se excluyen los dos temas de
-- combate (wetlands_music_pvp_battle_2 / _4) por ser demasiado intensos.
-- Los nombres son el filename del .ogg SIN extension (viven en wetlands-music).
local TRACKS = {
    "wetlands_music_dinosaur_spirit",
    "wetlands_music_gagaga_song",
    "wetlands_music_groovy_goblins",
    "wetlands_music_princess",
    "wetlands_music_rock_city_ransom",
    "wetlands_music_warp_zone",
    "wetlands_music_youthful_elf",
    "wetlands_music_te_quedas",
    "wetlands_music_juegazos",
}

local GAIN = 0.3          -- volumen suave, de fondo
local TRACK_SECONDS = 240 -- ~4 min por track (los .ogg son mas cortos y se cortan solos)
local SILENCE_SECONDS = 30 -- pausa entre tracks para no saturar
local JOIN_DELAY = 5      -- espera a que cargue el mundo antes del primer track

-- Estado por jugador. `gen` es un contador que invalida timers viejos: si un
-- jugador sale y vuelve, la generacion cambia y los minetest.after pendientes
-- de la sesion anterior se descartan (evita doble reproduccion).
local handles = {}  -- name -> sound handle actual
local gen = {}      -- name -> numero de generacion vigente
local paused = {}   -- name -> true si otro mod (ej. valdivia_discoteca) pausó el ambiental

local function stop_player(name)
    if handles[name] then
        minetest.sound_stop(handles[name])
        handles[name] = nil
    end
end

local function play_ambient(name, my_gen)
    -- Cancela si la generacion cambio (el jugador salio/reentro), no está, o está pausado.
    if gen[name] ~= my_gen or not minetest.get_player_by_name(name) or paused[name] then
        return
    end

    stop_player(name)
    local track = TRACKS[math.random(1, #TRACKS)]
    handles[name] = minetest.sound_play(track, {
        to_player = name,
        gain = GAIN,
    })

    -- Programa el siguiente track: duracion + silencio.
    minetest.after(TRACK_SECONDS + SILENCE_SECONDS, function()
        play_ambient(name, my_gen)
    end)
end

-- API publica para que otros mods (valdivia_discoteca) puedan pausar/reanudar
-- la musica ambiental por jugador sin romper el estado interno.
valdivia_music = {
    pause = function(name)
        paused[name] = true
        stop_player(name)
    end,
    resume = function(name)
        if not paused[name] then return end
        paused[name] = nil
        -- Reanuda inmediatamente con la generacion vigente del jugador.
        local my_gen = gen[name]
        if my_gen and minetest.get_player_by_name(name) then
            play_ambient(name, my_gen)
        end
    end,
}

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    gen[name] = (gen[name] or 0) + 1
    local my_gen = gen[name]
    minetest.after(JOIN_DELAY, function()
        play_ambient(name, my_gen)
    end)
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    gen[name] = (gen[name] or 0) + 1  -- invalida timers pendientes
    stop_player(name)
end)

minetest.log("action", "[" .. modname .. "] Loaded successfully")
