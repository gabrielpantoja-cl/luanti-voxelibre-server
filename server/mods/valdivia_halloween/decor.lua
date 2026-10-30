-- ============================================================================
-- valdivia_halloween / decor.lua  --  los edificios ensangrentados
-- ============================================================================
-- Valdivia no se puede decorar de antemano: son 1.15 millones de mapblocks en
-- un map.sqlite de ~420 MB. Asi que la ciudad se ensangrenta SOLA Y A MEDIDA
-- QUE SE CAMINA: cada pocos segundos, alrededor de cada jugador, se pintan un
-- par de manchas en las paredes y el piso que tiene cerca.
--
-- La regla de oro, y el motivo de que exista el registro de posiciones
-- (invariante A del init.lua): **solo se escribe sobre `air`**. Nunca se
-- reemplaza un nodo del mapa de Arnis, ni siquiera "guardando el original":
-- si solo se pisa aire, deshacer es poner aire, y es imposible perder un
-- pedazo de ciudad por un bug del limpiador.
--
-- Cada posicion pintada se anota en V.decor (hashes). /halloween off y
-- /halloween limpiar recorren esa lista por tandas y devuelven cada nodo a
-- aire, siempre que el nodo siga siendo nuestro: si un jugador ya lo pico, o
-- construyo encima, no se toca nada.

local modname = minetest.get_current_modname()
local V = valdivia_halloween

local function num(key, default)
    return tonumber(minetest.settings:get("valdivia_halloween_" .. key)) or default
end

local MAX_DECOR  = num("max_manchas", 2500)  -- tope global de manchas vivas
local INTERVALO  = num("decor_intervalo", 6) -- segundos entre rondas
local POR_RONDA  = num("decor_por_ronda", 4) -- manchas por ronda y jugador
local RADIO_MIN  = 4
local RADIO_MAX  = 22
local INTENTOS   = 20                        -- sondeos por ronda antes de rendirse
local MOVIO_MIN  = 6                         -- nodos que hay que caminar para otra ronda

local TELARANA = "mcl_core:cobweb"
local P_TELARANA = 0.12

-- ============================================================================
-- 1. PINTAR UNA MANCHA
-- ============================================================================
-- `p` tiene que ser aire. Se busca una cara solida vecina y se pega la
-- calcomania contra ella. Las caras verticales van primero a proposito: lo que
-- se quiere ver son los MUROS de los edificios manchados, no solo el piso.
local CARAS_MURO = {
    {x = 1, y = 0, z = 0}, {x = -1, y = 0, z = 0},
    {x = 0, y = 0, z = 1}, {x = 0, y = 0, z = -1},
}

local function solido(nombre)
    if nombre == "air" or nombre == "ignore" then return false end
    if V.ES_NODO[nombre] then return false end
    local def = minetest.registered_nodes[nombre]
    return def ~= nil and def.walkable == true and def.liquidtype == "none"
end

local function anotar(p)
    table.insert(V.decor, minetest.hash_node_position(p))
    V.marcar_sucio()
end

-- Pinta en `p` si se puede. Devuelve true si pinto.
function V.mancha_en(p)
    if #V.decor >= MAX_DECOR then return false end
    if minetest.get_node(p).name ~= "air" then return false end

    -- Caras de muro en orden al azar, y el piso al final como ultimo recurso.
    local caras = {}
    for i, d in ipairs(CARAS_MURO) do caras[i] = d end
    for i = #caras, 2, -1 do
        local j = math.random(i)
        caras[i], caras[j] = caras[j], caras[i]
    end
    caras[#caras + 1] = {x = 0, y = -1, z = 0}

    local solidas = 0
    local elegida
    for _, d in ipairs(caras) do
        if solido(minetest.get_node(vector.add(p, d)).name) then
            solidas = solidas + 1
            elegida = elegida or d
        end
    end
    if not elegida then return false end

    -- Telarana en los rincones (tres o mas caras solidas alrededor): es lo que
    -- da el aire de casa abandonada. Ocupa el nodo entero, por eso solo va
    -- donde no estorba el paso.
    if solidas >= 3 and math.random() < P_TELARANA
    and minetest.registered_nodes[TELARANA] then
        minetest.set_node(p, {name = TELARANA})
        anotar(p)
        return true
    end

    minetest.set_node(p, {
        name = V.NODOS[math.random(#V.NODOS)],
        -- dir_to_wallmounted espera la direccion DESDE el nodo HACIA la
        -- superficie donde se pega, que es exactamente `elegida`.
        param2 = minetest.dir_to_wallmounted(elegida),
    })
    anotar(p)
    return true
end

-- ============================================================================
-- 2. ENSANGRENTAR UNA ZONA
-- ============================================================================
-- Devuelve cuantas manchas pinto. `cuantas` limita el resultado; los intentos
-- son mas que las manchas porque la mayoria de los sondeos cae en roca maciza
-- o en medio del aire.
function V.ensangrentar(centro, cuantas, intentos)
    cuantas = cuantas or POR_RONDA
    intentos = intentos or (cuantas * 5)
    local puestas = 0
    local base_y = math.floor(centro.y + 0.5)

    for _ = 1, intentos do
        if puestas >= cuantas or #V.decor >= MAX_DECOR then break end
        local ang = math.random() * math.pi * 2
        local r = RADIO_MIN + math.random() * (RADIO_MAX - RADIO_MIN)
        local x = math.floor(centro.x + math.cos(ang) * r)
        local z = math.floor(centro.z + math.sin(ang) * r)
        -- De arriba hacia abajo: asi una mancha alta (segundo piso, alero) gana
        -- a una a ras de suelo, y la ciudad se ve manchada, no solo la vereda.
        for dy = 4, -3, -1 do
            if V.mancha_en({x = x, y = base_y + dy, z = z}) then
                puestas = puestas + 1
                break
            end
        end
    end
    return puestas
end

-- Charco donde acaba de pasar algo (una mordida, una infeccion). Es el mismo
-- pintor, pero pegado al punto y sin anillo.
function V.charco(pos, cuantas)
    local puestas = 0
    local base = vector.round(pos)
    for _ = 1, (cuantas or 3) * 4 do
        if puestas >= (cuantas or 3) then break end
        local p = {
            x = base.x + math.random(-2, 2),
            y = base.y + math.random(-1, 1),
            z = base.z + math.random(-2, 2),
        }
        if V.mancha_en(p) then puestas = puestas + 1 end
    end
    return puestas
end

-- ============================================================================
-- 3. DESHACER
-- ============================================================================
-- Por tandas y con load_area: muchas manchas van a estar en mapblocks que ya
-- se descargaron, y un set_node sobre un bloque no cargado no hace nada. Se
-- cargan a la fuerza, de a 50, para no congelar el servidor cuando hay miles.
function V.limpiar_decor(cb)
    local lista = V.decor
    V.decor = {}
    V.marcar_sucio()

    local i, borradas = 1, 0
    local function tanda()
        local fin = math.min(i + 49, #lista)
        for k = i, fin do
            local p = minetest.get_position_from_hash(lista[k])
            if p then
                minetest.load_area(p)
                local n = minetest.get_node(p).name
                -- Solo si sigue siendo nuestro: si el jugador lo pico o
                -- construyo encima, su trabajo manda.
                if V.ES_NODO[n] or n == TELARANA then
                    minetest.set_node(p, {name = "air"})
                    borradas = borradas + 1
                end
            end
        end
        i = fin + 1
        if i <= #lista then
            minetest.after(0.1, tanda)
        else
            V.guardar()
            V.log("limpieza terminada: " .. borradas .. "/" .. #lista .. " manchas")
            if cb then cb(borradas) end
        end
    end
    tanda()
end

-- ============================================================================
-- 4. EL PINTOR AUTOMATICO
-- ============================================================================
local reloj = 0
local ultimo_centro = {}   -- nombre de jugador -> donde pinto la ultima vez

minetest.register_globalstep(function(dtime)
    if not V.activo then return end
    reloj = reloj + dtime
    if reloj < INTERVALO then return end
    reloj = 0

    if #V.decor >= MAX_DECOR then return end

    for _, player in ipairs(minetest.get_connected_players()) do
        local nombre = player:get_player_name()
        local pos = player:get_pos()
        if pos then
            -- Si el jugador no se movio, no se insiste: si no, quedarse quieto
            -- un rato dejaria su cuadra entera cubierta de sangre.
            local antes = ultimo_centro[nombre]
            if not antes or vector.distance(antes, pos) >= MOVIO_MIN then
                ultimo_centro[nombre] = pos
                V.ensangrentar(pos, POR_RONDA, INTENTOS)
            end
        end
    end
end)

minetest.register_on_leaveplayer(function(player)
    ultimo_centro[player:get_player_name()] = nil
end)

-- Apagar el evento borra toda la sangre. Es la mitad de la promesa de
-- /halloween off: el cielo vuelve y la ciudad queda limpia.
V.al_apagar(function()
    V.limpiar_decor(function(n)
        V.anunciar("Se limpiaron " .. n .. " manchas de sangre de la ciudad.")
    end)
end)

minetest.log("action", "[" .. modname .. "] decor.lua: pintor listo (tope " ..
    MAX_DECOR .. " manchas)")
