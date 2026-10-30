-- ============================================================================
-- valdivia_halloween / cielo.lua  --  luna de sangre y noches largas
-- ============================================================================
-- Dos cosas independientes que comparten archivo porque las dos son "clima":
--
--   1. El cielo: luna roja enorme, estrellas rojas, horizonte y niebla de
--      sangre. Es por jugador (set_sky / set_moon / set_stars) y se reaplica
--      cada pocos segundos.
--   2. La noche larga: la noche pasa FACTOR veces mas lenta que el dia.
--
-- Por que se REAPLICA el cielo cada 4 s en vez de fijarlo una vez:
-- VoxeLibre trae mcl_weather.skycolor, que recalcula y reenvia el cielo de
-- cada jugador en su propio globalstep (es lo que hace el degradado del
-- amanecer y el cielo del Nether). Si solo lo fijaramos al encender el evento,
-- mcl_weather lo pisaria a los pocos segundos y la luna roja duraria un
-- suspiro. Se intenta apagar skycolor (es su API documentada: el flag
-- `active`), pero NO se confia en que exista: la reaplicacion periodica es la
-- que garantiza el efecto en cualquier version de VoxeLibre. Son 20 jugadores
-- como maximo y un paquete chico cada 4 s, nada medible.
--
-- Por que la noche larga NO toca time_speed:
-- time_speed es un ajuste del motor que se lee al arrancar; cambiarlo en
-- caliente con settings:set no es fiable entre versiones y ademas alargaria
-- tambien el dia. Aca se hace a mano: cada segundo se mira cuanto avanzo el
-- reloj del mundo y, si es de noche, se lo devuelve para atras hasta dejar
-- solo 1/FACTOR de lo avanzado. El dia queda intacto. Es un solo set_timeofday
-- por segundo, y solo de noche.

local modname = minetest.get_current_modname()
local V = valdivia_halloween

local function num(key, default)
    return tonumber(minetest.settings:get("valdivia_halloween_" .. key)) or default
end

local FACTOR_NOCHE = num("noche_factor", 3)  -- la noche dura esto veces mas
local REAPLICAR    = 4                       -- segundos entre reenvios del cielo

-- Ventana de noche de VoxeLibre: el sol se pone cerca de 0.76 y sale cerca de
-- 0.24. Se usa el mismo rango para "es de noche" en todo el mod.
local NOCHE_INICIO = 0.76
local NOCHE_FIN    = 0.24

function V.es_noche()
    local t = minetest.get_timeofday()
    return t >= NOCHE_INICIO or t <= NOCHE_FIN
end

-- ============================================================================
-- 1. EL CIELO
-- ============================================================================
local CIELO_EVENTO = {
    type = "regular",
    clouds = true,
    sky_color = {
        day_sky       = "#8a5560",
        day_horizon   = "#b5848a",
        dawn_sky      = "#8f1f22",
        dawn_horizon  = "#c7503c",
        night_sky     = "#2a0609",
        night_horizon = "#5e0d11",
        indoors       = "#1a0608",
        fog_sun_tint  = "#ff6b4a",
        fog_moon_tint = "#ff2b2b",
        fog_tint_type = "custom",
    },
    -- fog_distance -1 = el motor decide la distancia; solo movemos el inicio
    -- y el color, para que la ciudad se vea entre bruma roja sin tapar el
    -- horizonte entero.
    fog = {
        fog_distance = -1,
        fog_start = 0.45,
        fog_color = "#53100f",
    },
}

local function poner_cielo(player)
    player:set_sky(CIELO_EVENTO)
    player:set_moon({
        visible = true,
        texture = "valdivia_halloween_luna.png",
        scale = 1.8,                -- bien grande: es LA imagen del evento
    })
    player:set_stars({
        visible = true,
        count = 1400,
        star_color = "#ff8f8fcc",
        scale = 1.2,
    })
end

local function quitar_cielo(player)
    -- Tabla vacia = vuelta a los valores por defecto del motor. Enseguida
    -- mcl_weather retoma el control y repinta su propio cielo.
    player:set_sky({type = "regular"})
    player:set_moon({visible = true, texture = "", scale = 1})
    player:set_stars({visible = true, count = 1000, star_color = "#ebebff69", scale = 1})
end

-- mcl_weather.skycolor pisaria lo nuestro. Se apaga si se puede; si la API
-- cambio de nombre, no pasa nada: la reaplicacion periodica cubre igual.
local function skycolor(encendido)
    if mcl_weather and mcl_weather.skycolor
    and type(mcl_weather.skycolor) == "table" then
        mcl_weather.skycolor.active = encendido
        V.log("mcl_weather.skycolor.active = " .. tostring(encendido))
    end
end

V.al_encender(function()
    skycolor(false)
    for _, p in ipairs(minetest.get_connected_players()) do poner_cielo(p) end
end)

V.al_apagar(function()
    skycolor(true)
    for _, p in ipairs(minetest.get_connected_players()) do quitar_cielo(p) end
end)

minetest.register_on_joinplayer(function(player)
    if not V.activo then return end
    -- Un pelo de espera: al entrar, el cliente todavia esta recibiendo el
    -- mundo y mcl_weather le manda su cielo justo despues del join.
    minetest.after(1.5, function()
        if V.activo and player:is_player() then poner_cielo(player) end
    end)
end)

-- ============================================================================
-- 2. LA NOCHE LARGA
-- ============================================================================
local reloj = 0
local ultimo_tod = nil
local era_noche = false

minetest.register_globalstep(function(dtime)
    reloj = reloj + dtime
    if reloj < 1 then return end
    local paso = reloj
    reloj = 0

    if not V.activo then
        ultimo_tod = nil
        return
    end

    -- Reenvio del cielo (ver cabecera: mcl_weather lo pisa).
    V._reaplicar = (V._reaplicar or 0) + paso
    if V._reaplicar >= REAPLICAR then
        V._reaplicar = 0
        for _, p in ipairs(minetest.get_connected_players()) do poner_cielo(p) end
    end

    local tod = minetest.get_timeofday()

    -- Anuncio de la luna de sangre al caer la noche.
    local noche = V.es_noche()
    if noche and not era_noche then
        V.anunciar(minetest.colorize("#FF2B2B",
            "Sale la LUNA DE SANGRE sobre Valdivia. La noche va a ser larga."))
        era_noche = true
    elseif not noche and era_noche then
        V.anunciar("Se esconde la luna de sangre. Aprovecha la luz.")
        era_noche = false
    end

    if ultimo_tod == nil then
        ultimo_tod = tod
        return
    end

    -- Cuanto avanzo el reloj del mundo desde la ultima vuelta. El mundo da la
    -- vuelta en 1.0, asi que un salto negativo grande es medianoche.
    local avance = tod - ultimo_tod
    if avance < -0.5 then avance = avance + 1 end

    -- Si alguien movio la hora a mano (/time), no peleamos con el.
    if avance < 0 or avance > 0.2 then
        ultimo_tod = tod
        return
    end

    if noche and avance > 0 then
        local nuevo = ultimo_tod + avance / FACTOR_NOCHE
        if nuevo >= 1 then nuevo = nuevo - 1 end
        minetest.set_timeofday(nuevo)
        ultimo_tod = nuevo
    else
        ultimo_tod = tod
    end
end)

minetest.log("action", "[" .. modname .. "] cielo.lua: luna de sangre y noche x" ..
    FACTOR_NOCHE)
