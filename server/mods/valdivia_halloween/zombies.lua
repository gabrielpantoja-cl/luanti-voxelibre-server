-- ============================================================================
-- valdivia_halloween / zombies.lua  --  la infestacion
-- ============================================================================
-- Los zombies del evento NO se dejan al spawner de VoxeLibre. Dos razones:
--
--  1. Valdivia es mapgen `singlenode` (el mapa viene de Arnis/OpenStreetMap),
--     asi que en la superficie no hay biomas y el spawner de mcl_mobs descarta
--     el intento en silencio al no encontrar el bioma en spawn_biomes. Es el
--     mismo problema que documenta valdivia_spawn_fix.
--  2. Aunque funcionara, un spawner natural no se puede apagar de golpe ni
--     acotar: el evento necesita poder desaparecer entero con /halloween off.
--
-- Entonces se siembran a mano, igual que los transeuntes: aparecen en la calle
-- cerca de cada jugador PERO fuera de su vista (sin linea de vision), caminan
-- hasta el, y se borran al quedar lejos. Nacen con static_save = false, asi
-- que un SIGKILL del contenedor no deja hordas plantadas en la ciudad.

local modname = minetest.get_current_modname()
local V = valdivia_halloween

local function num(key, default)
    return tonumber(minetest.settings:get("valdivia_halloween_" .. key)) or default
end

local MAX_GLOBAL   = num("zombies_max", 45)        -- tope en todo el mundo
local POR_JUGADOR  = num("zombies_por_jugador", 8) -- cuantos rondan a cada uno de noche
local DIST_MIN     = 16
local DIST_MAX     = 34
local DIST_BORRAR  = 85
local INTERVALO    = 4                             -- segundos entre rondas
local P_GRUNIDO    = 0.35                          -- probabilidad de gruñido ambiental

-- Tipos y su peso. El zombie comun domina; los demas dan variedad. Se filtran
-- al arrancar contra registered_entities, asi que si una version de VoxeLibre
-- no trae alguno, simplemente no sale.
local TIPOS = {
    {name = "mobs_mc:zombie",          peso = 70},
    {name = "mobs_mc:baby_zombie",     peso = 10},
    {name = "mobs_mc:husk",            peso = 10},
    {name = "mobs_mc:villager_zombie", peso = 10},
}

local disponibles = nil   -- se calcula en el primer uso (ver mods_loaded abajo)

local function elegir_tipo()
    if not disponibles or #disponibles == 0 then return nil end
    local total = 0
    for _, t in ipairs(disponibles) do total = total + t.peso end
    local r = math.random() * total
    for _, t in ipairs(disponibles) do
        r = r - t.peso
        if r <= 0 then return t.name end
    end
    return disponibles[1].name
end

minetest.register_on_mods_loaded(function()
    disponibles = {}
    for _, t in ipairs(TIPOS) do
        if minetest.registered_entities[t.name] then
            table.insert(disponibles, t)
        else
            V.log("tipo no registrado, se omite: " .. t.name)
        end
    end
    V.log("zombies disponibles: " .. #disponibles)
end)

-- ============================================================================
-- 1. EL CENSO
-- ============================================================================
local vivos = {}   -- ObjectRef -> true

function V.zombies_vivos()
    local n = 0
    for obj in pairs(vivos) do
        if obj:get_pos() then n = n + 1 else vivos[obj] = nil end
    end
    return n
end

-- Un zombie del evento se reconoce por la marca, no por el nombre: asi un
-- zombie que haya spawneado por otra via no se cuenta ni se borra.
function V.es_zombie_evento(obj)
    local le = obj and obj:get_luaentity()
    return le ~= nil and le._halloween_zombie == true
end

function V.purgar_zombies()
    local n = 0
    for obj in pairs(vivos) do
        if obj:get_pos() then
            V.salpicar(obj:get_pos(), 6, 1)
            obj:remove()
            n = n + 1
        end
    end
    vivos = {}
    return n
end

-- ============================================================================
-- 2. SEMBRAR
-- ============================================================================
-- Devuelve el ObjectRef, o nil. `marcar` deja los ajustes que convierten un
-- zombie cualquiera en uno del evento; tambien lo usa combate.lua cuando un
-- transeunte se infecta.
function V.marcar_zombie(obj)
    local le = obj:get_luaentity()
    if not le then return end
    le._halloween_zombie = true
    -- No se guarda en el mapblock (invariante B del init.lua).
    obj:set_properties({static_save = false})
    -- El despawner por distancia de mcl_mobs no manda: la limpieza la hace
    -- este mod, que es el unico que sabe cuando termina el evento.
    le.can_despawn = false
    -- Que no se quemen con el sol. Con noches 3x el dia igual llega, y una
    -- horda que se prende fuego al amanecer deja la ciudad vacia de golpe.
    le.sunlight_damage = 0
    le.ignited_by_sunlight = false
    -- Que acepten NPC como blanco (el que decide es combate.lua, pero si la
    -- version de VoxeLibre mira este campo, mejor que diga que si).
    le.attack_npcs = true
    vivos[obj] = true
    return le
end

function V.sembrar_zombie(pos)
    local tipo = elegir_tipo()
    if not tipo then return nil end
    local obj = minetest.add_entity(pos, tipo)
    if not obj then return nil end
    V.marcar_zombie(obj)
    return obj
end

-- ============================================================================
-- 3. LA RONDA
-- ============================================================================
local reloj = 0

minetest.register_globalstep(function(dtime)
    if not V.activo then return end
    reloj = reloj + dtime
    if reloj < INTERVALO then return end
    reloj = 0

    -- Barrido: borra los que quedaron lejos de todos. Igual que los
    -- transeuntes, la ciudad "se renueva" alrededor del jugador en vez de
    -- acumular mobs en mapblocks que nadie mira.
    local jugadores = minetest.get_connected_players()
    for obj in pairs(vivos) do
        local p = obj:get_pos()
        if not p then
            vivos[obj] = nil
        else
            local cerca = false
            for _, pl in ipairs(jugadores) do
                local pp = pl:get_pos()
                if pp and vector.distance(p, pp) <= DIST_BORRAR then
                    cerca = true
                    break
                end
            end
            if not cerca then
                obj:remove()
                vivos[obj] = nil
            end
        end
    end

    local total = V.zombies_vivos()
    if total >= MAX_GLOBAL then return end

    -- De dia salen muchos menos: la idea es que la noche de sangre de miedo y
    -- el dia sirva para respirar (y para que los chicos reconstruyan).
    local cupo = V.es_noche() and POR_JUGADOR or math.max(2, math.floor(POR_JUGADOR / 3))

    for _, player in ipairs(jugadores) do
        if total >= MAX_GLOBAL then break end
        local ppos = player:get_pos()
        if ppos then
            -- Cuantos tiene ya encima
            local suyos = 0
            for obj in pairs(vivos) do
                local p = obj:get_pos()
                if p and vector.distance(p, ppos) <= DIST_MAX + 12 then
                    suyos = suyos + 1
                end
            end

            if suyos < cupo then
                -- `true` = exigir que NO haya linea de vision: nadie ve
                -- aparecer un zombie de la nada, lo ve doblar la esquina.
                local sitio = V.buscar_calle(ppos, DIST_MIN, DIST_MAX, true)
                if sitio and V.sembrar_zombie(sitio) then
                    total = total + 1
                end
            end

            -- Ambiente: un gruñido cerca, sin mob a la vista, es la mitad del
            -- susto. El sonido lo trae VoxeLibre con los mobs.
            if math.random() < P_GRUNIDO then
                minetest.sound_play("mobs_mc_zombie_growl", {
                    pos = vector.add(ppos, {
                        x = math.random(-12, 12), y = 0, z = math.random(-12, 12)}),
                    gain = 0.5,
                    max_hear_distance = 26,
                }, true)
            end
        end
    end
end)

-- ============================================================================
-- 4. GANCHOS
-- ============================================================================
V.al_apagar(function()
    local n = V.purgar_zombies()
    V.log("purgados " .. n .. " zombies al apagar")
end)

minetest.log("action", "[" .. modname .. "] zombies.lua: infestacion lista (tope " ..
    MAX_GLOBAL .. ")")
