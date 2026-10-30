-- ============================================================================
-- valdivia_halloween  --  "Valdivia Infectada"
-- ============================================================================
-- Mega-evento de Halloween para Valdivia (puerto 30001) CON INTERRUPTOR DE
-- ADMIN: el mod se carga siempre, pero no hace absolutamente nada hasta que
-- alguien con priv `server` escribe /halloween on, y /halloween off devuelve
-- el mundo a como estaba.
--
-- Cinco piezas, cada una en su archivo:
--
--   nodes.lua     los nodos "mancha de sangre" (calcomanias planas)
--   cielo.lua     luna de sangre, cielo y niebla rojos, noches mas largas
--   decor.lua     ensangrenta los edificios cerca de los jugadores, y lo DESHACE
--   zombies.lua   infestacion: zombies efimeros sembrados en las calles
--   combate.lua   los zombies cazan transeuntes; los transeuntes pelean o arrancan
--
-- Tres invariantes que explican casi todas las decisiones del mod:
--
-- A. TODO ES REVERSIBLE. El mapa de Valdivia es un map.sqlite de ~420 MB hecho
--    con Arnis desde OpenStreetMap: no se puede "regenerar" si se arruina. Por
--    eso la sangre se escribe SOLO sobre nodos `air`, nunca sobre un nodo del
--    mapa, y cada posicion queda anotada en worldpath/valdivia_halloween.json.
--    Apagar el evento devuelve cada una de esas posiciones a `air` y nada mas.
--
-- B. NADA SE GUARDA EN EL MAPA. Los zombies del evento nacen con
--    static_save = false, igual que los transeuntes. Aca `docker stop` siempre
--    termina en SIGKILL (ver AGENTS.md), asi que un apagon a mitad del evento
--    no puede dejar hordas plantadas para siempre en la ciudad.
--
-- C. SIN PATHFINDING PROPIO. El A* de mcl_mobs se traba en los patios y
--    escaleras de la ciudad de Arnis (documentado en valdivia_policia y en
--    valdivia_transeuntes). Aca se usa el mismo recurso probado: sondeo de
--    "esto es calle?" para sembrar y para arrancar, y reubicacion cerca del
--    objetivo cuando un zombie lleva rato sin acercarse.
--
-- Solo Valdivia: load_mod_valdivia_halloween = true en luanti-valdivia.conf
-- (y en el world.mt del VPS).

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- ============================================================================
-- 1. AJUSTES
-- ============================================================================
local function num(key, default)
    return tonumber(minetest.settings:get("valdivia_halloween_" .. key)) or default
end

local LUZ_MIN    = num("luz_min", 14)   -- luz natural a mediodia para contar como calle
local VIDA_CACHE = 25                   -- segundos por generacion de la cache de calle

-- ============================================================================
-- 2. LA TABLA GLOBAL DEL MOD
-- ============================================================================
-- Un solo global, con el nombre del mod (convencion del repo). Los cinco
-- archivos de abajo cuelgan de aca: estado, ayudantes de calle y los ganchos
-- de encender/apagar.
valdivia_halloween = {
    modname = modname,
    activo  = false,     -- lo unico que decide si el evento corre
    decor   = {},        -- hashes de posicion donde escribimos sangre/telarana
    C       = "#FF4A3D", -- color del chat del evento
}
local V = valdivia_halloween

function V.al_azar(t) return t[math.random(#t)] end

-- Mensaje a todo el servidor, con la marca del evento.
function V.anunciar(msg)
    minetest.chat_send_all(minetest.colorize(V.C, "[Halloween] ") .. msg)
end

-- Mensaje solo a quien esta cerca: lo que grita un transeunte no le importa a
-- un jugador que esta a diez cuadras.
function V.avisar_cerca(pos, msg, radio)
    radio = radio or 22
    for _, p in ipairs(minetest.get_connected_players()) do
        local pp = p:get_pos()
        if pp and vector.distance(pp, pos) <= radio then
            minetest.chat_send_player(p:get_player_name(), msg)
        end
    end
end

function V.log(msg)
    minetest.log("action", "[" .. modname .. "] " .. msg)
end

-- ============================================================================
-- 3. ESTO ES CALLE?
-- ============================================================================
-- Copia deliberada (no import) de la prueba de valdivia_transeuntes: ese mod
-- puede estar apagado y este tiene que seguir funcionando igual. La prueba de
-- cielo abierto se hace con timeofday = 0.5 (mediodia) a proposito: la
-- pregunta es "hay cielo encima?", no "que hora es?". Sin ese 0.5, de noche
-- toda la ciudad pasaria por interior y no se sembraria un solo zombie.
local function es_suelo(name)
    if name == "air" or name == "ignore" then return false end
    local def = minetest.registered_nodes[name]
    return def ~= nil and def.walkable == true and def.liquidtype == "none"
end

local function calcular_calle(p)
    if not es_suelo(minetest.get_node({x = p.x, y = p.y - 1, z = p.z}).name) then
        return false
    end
    if minetest.get_node(p).name ~= "air" then return false end
    if minetest.get_node({x = p.x, y = p.y + 1, z = p.z}).name ~= "air" then return false end
    local luz = minetest.get_natural_light(p, 0.5)
    return luz ~= nil and luz >= LUZ_MIN
end

-- Cache generacional, misma razon y mismo diseno que en valdivia_transeuntes:
-- la ciudad es practicamente estatica, los sondeos repiten los mismos nodos
-- miles de veces por minuto, y rotar dos generaciones acota la memoria sola y
-- nota los cambios del mapa en a lo mas dos ciclos.
local cache_actual, cache_vieja = {}, {}
local reloj_cache = 0
local reloj_guardado = 0

function V.es_calle(p)
    local k = minetest.hash_node_position(p)
    local v = cache_actual[k]
    if v ~= nil then return v end
    v = cache_vieja[k]
    if v == nil then v = calcular_calle(p) end
    cache_actual[k] = v
    return v
end

-- Un techo plano pasa `es_calle` sin problema. Lo que lo delata es el hueco de
-- abajo: bajo una calle hay tierra, bajo un techo hay el interior de la casa.
function V.tiene_suelo_macizo(p)
    for dy = 2, 4 do
        if minetest.get_node({x = p.x, y = p.y - dy, z = p.z}).name == "air" then
            return false
        end
    end
    return true
end

-- Descarta parches de un nodo: patios, cornisas, la orilla del rio.
function V.es_calle_ancha(p)
    local vecinos = 0
    for _, d in ipairs({{1, 0}, {-1, 0}, {0, 1}, {0, -1}}) do
        if V.es_calle({x = p.x + d[1], y = p.y, z = p.z + d[2]}) then
            vecinos = vecinos + 1
        end
    end
    return vecinos >= 3
end

-- Busca un pedazo de calle en un anillo alrededor de `centro`. Con `oculto`,
-- ademas exige que NO haya linea de vision desde el centro: asi los zombies
-- no aparecen de la nada delante del jugador, sino que "vienen llegando".
function V.buscar_calle(centro, dmin, dmax, oculto)
    local ojo = {x = centro.x, y = centro.y + 1.5, z = centro.z}
    for _ = 1, 24 do
        local ang = math.random() * math.pi * 2
        local r = dmin + math.random() * (dmax - dmin)
        local x = math.floor(centro.x + math.cos(ang) * r)
        local z = math.floor(centro.z + math.sin(ang) * r)
        for dy = 3, -4, -1 do
            local p = {x = x, y = math.floor(centro.y + 0.5) + dy, z = z}
            if V.es_calle(p) and V.tiene_suelo_macizo(p) and V.es_calle_ancha(p) then
                local blanco = {x = p.x + 0.5, y = p.y + 1, z = p.z + 0.5}
                if not oculto or not minetest.line_of_sight(ojo, blanco) then
                    return {x = p.x + 0.5, y = p.y, z = p.z + 0.5}
                end
            end
        end
    end
    return nil
end

-- ============================================================================
-- 4. PERSISTENCIA
-- ============================================================================
-- Dos cosas y nada mas: si el evento quedo encendido, y donde escribimos
-- sangre. Lo segundo es lo que hace reversible el evento (invariante A), asi
-- que se graba tambien cada 30 s y no solo al apagar: aca el contenedor muere
-- con SIGKILL y register_on_shutdown no siempre alcanza a correr.
local STORAGE = minetest.get_worldpath() .. "/valdivia_halloween.json"
local sucio = false

function V.marcar_sucio() sucio = true end

function V.guardar()
    local f = io.open(STORAGE, "w")
    if not f then
        minetest.log("error", "[" .. modname .. "] no se pudo escribir " .. STORAGE)
        return false
    end
    f:write(minetest.write_json({activo = V.activo, decor = V.decor}))
    f:close()
    sucio = false
    return true
end

local function cargar()
    local f = io.open(STORAGE, "r")
    if not f then return end
    local data = minetest.parse_json(f:read("*a") or "")
    f:close()
    if type(data) ~= "table" then return end
    V.activo = data.activo == true
    if type(data.decor) == "table" then
        -- Los hashes de posicion caben en un double sin perder precision, pero
        -- igual se normalizan por si el JSON los trajo como texto.
        for _, h in ipairs(data.decor) do
            local n = tonumber(h)
            if n then table.insert(V.decor, n) end
        end
    end
    V.log("estado cargado: activo=" .. tostring(V.activo) ..
          ", manchas=" .. #V.decor)
end

cargar()

-- ============================================================================
-- 5. GANCHOS DE ENCENDIDO / APAGADO
-- ============================================================================
-- Cada archivo registra lo suyo. Encender y apagar es correr estas listas; no
-- hay ninguna otra via para cambiar el estado.
V.ganchos = {encender = {}, apagar = {}}

function V.al_encender(fn) table.insert(V.ganchos.encender, fn) end
function V.al_apagar(fn)   table.insert(V.ganchos.apagar, fn) end

local function correr(lista)
    for _, fn in ipairs(lista) do
        local ok, err = pcall(fn)
        if not ok then
            minetest.log("error", "[" .. modname .. "] gancho fallo: " .. tostring(err))
        end
    end
end

function V.encender(quien)
    if V.activo then return false, "El evento ya esta encendido." end
    V.activo = true
    correr(V.ganchos.encender)
    V.guardar()
    V.log("ENCENDIDO por " .. (quien or "el servidor"))
    V.anunciar(minetest.colorize("#FF2B2B",
        "La niebla roja cubre Valdivia. Algo se arrastra entre las casas..."))
    V.anunciar("Cuida a la gente de la calle: los zombies van por ellos.")
    return true
end

function V.apagar(quien)
    if not V.activo then return false, "El evento ya esta apagado." end
    V.activo = false
    correr(V.ganchos.apagar)
    V.guardar()
    V.log("APAGADO por " .. (quien or "el servidor"))
    V.anunciar("Amanece. Valdivia vuelve a la normalidad.")
    return true
end

-- ============================================================================
-- 6. LAS CINCO PIEZAS
-- ============================================================================
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/cielo.lua")
dofile(modpath .. "/decor.lua")
dofile(modpath .. "/zombies.lua")
dofile(modpath .. "/combate.lua")

-- ============================================================================
-- 7. MANTENIMIENTO
-- ============================================================================
minetest.register_globalstep(function(dtime)
    reloj_cache = reloj_cache + dtime
    if reloj_cache >= VIDA_CACHE then
        reloj_cache = 0
        cache_vieja, cache_actual = cache_actual, {}
    end

    reloj_guardado = reloj_guardado + dtime
    if reloj_guardado >= 30 then
        reloj_guardado = 0
        if sucio then V.guardar() end
    end
end)

minetest.register_on_shutdown(function()
    if sucio then V.guardar() end
end)

-- Si el servidor se reinicio con el evento encendido, hay que volver a
-- aplicarlo. Se espera un poco: mcl_weather y los mobs todavia se estan
-- terminando de registrar cuando este archivo corre.
if V.activo then
    minetest.after(3, function()
        correr(V.ganchos.encender)
        V.log("evento reanudado tras reinicio")
    end)
end

-- ============================================================================
-- 8. EL COMANDO DE ADMIN
-- ============================================================================
local function estado_texto()
    local lineas = {
        "Evento Halloween de Valdivia: " ..
            (V.activo and minetest.colorize("#5BE35B", "ENCENDIDO")
                       or minetest.colorize("#E35B5B", "apagado")),
        "  manchas de sangre colocadas: " .. #V.decor,
        "  zombies del evento: " .. V.zombies_vivos(),
        "  hora del mundo: " .. string.format("%.2f", minetest.get_timeofday()) ..
            (V.es_noche() and "  (noche larga)" or "  (dia)"),
    }
    return table.concat(lineas, "\n")
end

minetest.register_chatcommand("halloween", {
    params = "[on | off | estado | sangre | limpiar | purga]",
    description = "Enciende o apaga el evento de Halloween de Valdivia",
    privs = {server = true},
    func = function(nombre, param)
        param = (param or ""):trim():lower()

        if param == "" or param == "estado" then
            return true, estado_texto()

        elseif param == "on" or param == "encender" then
            local ok, err = V.encender(nombre)
            return ok, ok and estado_texto() or err

        elseif param == "off" or param == "apagar" then
            local ok, err = V.apagar(nombre)
            return ok, ok and ("Apagando. " .. estado_texto()) or err

        elseif param == "sangre" then
            local player = minetest.get_player_by_name(nombre)
            if not player then return false, "No estas conectado." end
            local n = V.ensangrentar(player:get_pos(), 30)
            return true, "Se pintaron " .. n .. " manchas alrededor tuyo."

        elseif param == "limpiar" then
            local total = #V.decor
            V.limpiar_decor(function(borradas)
                minetest.chat_send_player(nombre,
                    minetest.colorize(V.C, "[Halloween] ") ..
                    "listo: " .. borradas .. " de " .. total .. " manchas borradas.")
            end)
            return true, "Borrando " .. total .. " manchas (va por tandas, avisa al terminar)."

        elseif param == "purga" then
            local n = V.purgar_zombies()
            return true, "Se eliminaron " .. n .. " zombies del evento."
        end

        return false, "Uso: /halloween [on | off | estado | sangre | limpiar | purga]"
    end,
})

V.log("cargado. Evento " .. (V.activo and "ENCENDIDO" or "apagado") ..
      " (usa /halloween para cambiarlo)")
