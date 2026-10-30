-- ============================================================================
-- valdivia_halloween / combate.lua  --  zombies contra la gente de Valdivia
-- ============================================================================
-- Esta es la pieza que Gabriel pidio: que los zombies NO vayan solo por los
-- jugadores, sino que cacen a los transeuntes, y que los transeuntes se
-- defiendan.
--
-- Como se hace que un zombie persiga a un NPC:
-- mcl_mobs ya sabe perseguir y golpear (es lo que hace con el jugador), asi
-- que no se reimplementa: se le ENTREGA el blanco con su propio
-- `mob:do_attack(objeto)`, que es la via que usa el propio VoxeLibre cuando un
-- zombie va por un aldeano. Solo si esa llamada fallara (otra version, otro
-- nombre) se cae al asignamiento directo de self.attack/self.state. Asi la
-- persecucion usa las animaciones, los sonidos y los golpes de siempre.
--
-- Como se hace que un transeunte pelee:
-- valdivia_transeuntes NO tiene combate y no queremos metérselo: ese mod tiene
-- que seguir funcionando igual con el evento apagado. Lo que hace este archivo
-- es TOMARLE EL CONTROL mientras dura la pelea — le pone la marca `_halloween`
-- (el unico cambio en ese mod: dos lineas al principio de su do_custom, que
-- con el evento apagado nunca se cumplen) y a partir de ahi le maneja la
-- velocidad, el giro y la animacion desde aca. Al soltarlo, el transeunte
-- retoma su caminata como si nada.
--
-- Los transeuntes son inmortales de verdad (armor_groups immortal, HP 10000):
-- eso no se toca, porque es lo que impide que un jugador los mate a golpes. La
-- "vida" frente a los zombies es una vida VIRTUAL que lleva este archivo. Al
-- llegar a cero el transeunte no muere: se INFECTA, o sea desaparece y en su
-- lugar queda un zombie aldeano. Nadie ve morir a nadie, que es lo que
-- corresponde en un servidor para chicos de 7+, y el susto queda igual.
--
-- No hay pathfinding propio (invariante C del init.lua): para arrancar se usa
-- el mismo sondeo de calle del resto del mod, y para un zombie que se quedo
-- trabado se reutiliza el truco ya probado en valdivia_policia (reubicarlo
-- cerca del objetivo, como si hubiera dado la vuelta a la manzana).

local modname = minetest.get_current_modname()
local V = valdivia_halloween

local function num(key, default)
    return tonumber(minetest.settings:get("valdivia_halloween_" .. key)) or default
end

local INTERVALO      = 0.5   -- segundos entre vueltas del director
local RADIO_ESCANEO  = 48    -- se mira solo alrededor de los jugadores
local DIST_CAZA      = 20    -- a esta distancia un zombie elige transeunte
local DIST_COMBATE   = 3.0   -- aca empieza la pelea / la huida
local DIST_SOLTAR    = 7     -- mas lejos que esto, el transeunte se calma
local T_SOLTAR       = 3     -- segundos sin zombie cerca antes de soltarlo

local HP_PEATON      = num("peaton_hp", 20)      -- vida virtual del transeunte
local DANIO_PEATON   = num("peaton_danio", 3)    -- lo que pega el transeunte
local CADENCIA_PEATON = 1.2
local DANIO_ZOMBIE   = num("zombie_danio", 3)    -- lo que muerde el zombie
local CADENCIA_ZOMBIE = 1.6
local P_MIEDO        = num("miedo", 0.4)         -- probabilidad de arrancar en vez de pelear
local VEL_HUIDA      = 2.9                       -- el zombie comun va a ~2.4

local DANIO_GUIA     = 6     -- el guia del spawn pega mas fuerte
local CADENCIA_GUIA  = 1.0
local DIST_GUIA      = 3.4

local T_ATASCO       = 3.5   -- segundos sin acercarse antes de reubicar al zombie

-- Animaciones de mcl_armor_character.b3d (el modelo de los transeuntes y los
-- guias). "mine" es el brazo que golpea; es lo mas parecido a pelear que
-- tiene el modelo.
local ANIM_QUIETO = {x = 0,   y = 79}
local ANIM_CAMINA = {x = 168, y = 187}
local ANIM_GOLPE  = {x = 189, y = 198}

-- Quien es quien. Por prefijo, no por nombre exacto: valdivia_spawn_npc
-- registra una entidad por tipo de guia.
local PREFIJO_PEATON  = "valdivia_transeuntes:"
local PREFIJO_GUIA    = "valdivia_spawn_npc:"

-- Zombies que cuentan como cazadores: los del evento (por la marca) y
-- cualquier zombie de VoxeLibre que ande suelto.
local ZOMBIES_VANILLA = {
    ["mobs_mc:zombie"]          = true,
    ["mobs_mc:baby_zombie"]     = true,
    ["mobs_mc:husk"]            = true,
    ["mobs_mc:villager_zombie"] = true,
}

local GRITOS_PELEA = {
    "Fuera de aqui, cosa horrible!",
    "No te me acerques!",
    "Auxilio! Alguien que me ayude!",
    "Te voy a dar con el bolso!",
    "Esto no pasaba antes en Valdivia!",
}

local GRITOS_HUIDA = {
    "Corran! Corran todos!",
    "No quiero morir en Halloween!",
    "Que alguien llame a los carabineros!",
    "Ayuda! Me persiguen!",
}

local GRITOS_VICTORIA = {
    "Eso! Le gane!",
    "Uf... estuvo cerca.",
    "Y asi se hace en Valdivia!",
}

local GRITOS_GUIA = {
    "Atras! El spawn esta protegido.",
    "Mientras yo este aqui, no pasan.",
    "Jugadores, a mis espaldas!",
}

-- ============================================================================
-- 1. RUMBOS (para arrancar)
-- ============================================================================
local DIRS = {}
for i = 0, 7 do
    local a = i * math.pi / 4
    DIRS[i + 1] = {x = math.cos(a), z = math.sin(a), ang = a, yaw = a - math.pi / 2}
end

local function puede_ir(pos, d)
    local y = math.floor(pos.y + 0.5)
    for _, dist in ipairs({1, 1.8}) do
        local x = math.floor(pos.x + d.x * dist)
        local z = math.floor(pos.z + d.z * dist)
        local ok = false
        for _, dy in ipairs({0, 1, -1}) do
            if V.es_calle({x = x, y = y + dy, z = z}) then
                ok = true
                break
            end
        end
        if not ok then return false end
    end
    return true
end

-- El rumbo transitable que mas se aleja del zombie. Si esta acorralado
-- devuelve nil, y el que llama lo hace pelear: no sirve de nada vibrar
-- contra un muro.
local function rumbo_huida(pos, amenaza)
    local dx, dz = pos.x - amenaza.x, pos.z - amenaza.z
    if dx * dx + dz * dz < 0.01 then return nil end
    local ideal = math.atan2(dz, dx)

    local orden = {}
    for i, d in ipairs(DIRS) do
        local dif = math.abs((d.ang - ideal + math.pi) % (2 * math.pi) - math.pi)
        table.insert(orden, {i = i, dif = dif})
    end
    table.sort(orden, function(a, b) return a.dif < b.dif end)

    for _, o in ipairs(orden) do
        -- Mas de 90 grados hacia el zombie ya no es huir.
        if o.dif > math.pi / 2 then break end
        if puede_ir(pos, DIRS[o.i]) then return DIRS[o.i] end
    end
    return nil
end

-- ============================================================================
-- 2. ENTREGARLE EL BLANCO AL ZOMBIE
-- ============================================================================
local aviso_do_attack = false

local function cazar(le, blanco)
    if le.attack == blanco then return end
    if type(le.do_attack) == "function" then
        local ok, err = pcall(function() le:do_attack(blanco) end)
        if ok then return end
        if not aviso_do_attack then
            aviso_do_attack = true
            minetest.log("warning", "[" .. modname ..
                "] do_attack fallo, se usa asignacion directa: " .. tostring(err))
        end
    end
    -- Plan B: lo mismo que hace do_attack por dentro.
    le.attack = blanco
    le.state = "attack"
end

-- ============================================================================
-- 3. LA INFECCION
-- ============================================================================
-- El transeunte no muere: desaparece entre humo y queda un zombie aldeano.
local function infectar(obj, le)
    local pos = obj:get_pos()
    if not pos then return end
    local nombre = "Alguien"
    local props = obj:get_properties()
    if props and props.infotext then
        nombre = props.infotext:match("^[^%-]+") or nombre
        nombre = nombre:trim()
    end

    V.salpicar(pos, 24, 3)
    V.charco(pos, 3)
    minetest.add_particlespawner({
        amount = 25, time = 0.4,
        minpos = vector.subtract(pos, {x = 0.4, y = 0, z = 0.4}),
        maxpos = vector.add(pos, {x = 0.4, y = 1.8, z = 0.4}),
        minvel = {x = -0.6, y = 0.6, z = -0.6},
        maxvel = {x = 0.6, y = 1.8, z = 0.6},
        minexptime = 0.6, maxexptime = 1.4,
        minsize = 2, maxsize = 5,
        texture = "mcl_particles_smoke.png", glow = 2,
    })

    -- El transeunte se va primero; valdivia_transeuntes libera su personaje
    -- solo en la siguiente ronda de su censo, asi que no hay nada que avisar.
    obj:remove()

    local tipo = minetest.registered_entities["mobs_mc:villager_zombie"]
        and "mobs_mc:villager_zombie" or "mobs_mc:zombie"
    local nuevo = minetest.add_entity(pos, tipo)
    if nuevo then V.marcar_zombie(nuevo) end

    V.avisar_cerca(pos, minetest.colorize("#FF2B2B",
        "[Halloween] ") .. nombre .. " fue infectado... ya no es quien era.", 28)
    V.log("infectado: " .. nombre)
end

-- ============================================================================
-- 4. SOLTAR AL TRANSEUNTE
-- ============================================================================
local function soltar(obj, le)
    if not le._halloween then return end
    le._halloween = nil
    le._hw_modo = nil
    le._hw_hp = nil
    le._hw_golpe = nil
    le._hw_mordida = nil
    le._hw_libre = nil
    le._hw_grito = nil
    local vel = obj:get_velocity()
    obj:set_velocity({x = 0, y = vel and vel.y or 0, z = 0})
    obj:set_animation(ANIM_QUIETO, 30, 0, true)
end

-- ============================================================================
-- 5. EL DIRECTOR
-- ============================================================================
local reloj = 0

minetest.register_globalstep(function(dtime)
    if not V.activo then return end
    reloj = reloj + dtime
    if reloj < INTERVALO then return end
    local paso = reloj
    reloj = 0

    -- 5.1 Censo alrededor de los jugadores. Se usa una tabla por ObjectRef
    -- porque dos jugadores cercanos devuelven los mismos objetos.
    local zombies, peatones, guias = {}, {}, {}
    local vistos = {}

    for _, player in ipairs(minetest.get_connected_players()) do
        local pp = player:get_pos()
        if pp then
            for _, obj in ipairs(minetest.get_objects_inside_radius(pp, RADIO_ESCANEO)) do
                if not vistos[obj] and not obj:is_player() then
                    vistos[obj] = true
                    local le = obj:get_luaentity()
                    local n = le and le.name
                    if le and n then
                        if le._halloween_zombie or ZOMBIES_VANILLA[n] then
                            table.insert(zombies, {obj = obj, le = le, pos = obj:get_pos()})
                        elseif n:sub(1, #PREFIJO_PEATON) == PREFIJO_PEATON then
                            table.insert(peatones, {obj = obj, le = le, pos = obj:get_pos()})
                        elseif n:sub(1, #PREFIJO_GUIA) == PREFIJO_GUIA then
                            table.insert(guias, {obj = obj, le = le, pos = obj:get_pos()})
                        end
                    end
                end
            end
        end
    end

    if #zombies == 0 then
        -- Sin zombies cerca no hay nada que dirigir, pero puede haber
        -- transeuntes que quedaron tomados de una pelea anterior.
        for _, p in ipairs(peatones) do
            if p.le._halloween then soltar(p.obj, p.le) end
        end
        return
    end

    -- 5.2 Cada zombie elige a quien caza: el NPC mas cercano a tiro.
    for _, z in ipairs(zombies) do
        if z.pos then
            local mejor, mejor_d
            for _, lista in ipairs({peatones, guias}) do
                for _, n in ipairs(lista) do
                    if n.pos then
                        local d = vector.distance(z.pos, n.pos)
                        if d <= DIST_CAZA and (not mejor_d or d < mejor_d) then
                            mejor, mejor_d = n, d
                        end
                    end
                end
            end

            if mejor then
                cazar(z.le, mejor.obj)

                -- Anti-atasco: la ciudad de Arnis llena de patios y escaleras
                -- traba al A* de mcl_mobs. Si dejo de acercarse, se reubica
                -- cerca del NPC, como si hubiera dado la vuelta a la manzana.
                -- Solo con los zombies del evento: no se teletransporta un mob
                -- que no pusimos nosotros.
                if z.le._halloween_zombie and mejor_d > DIST_COMBATE then
                    z.le._hw_mejor = math.min(z.le._hw_mejor or mejor_d, mejor_d)
                    if mejor_d <= z.le._hw_mejor + 0.5 then
                        z.le._hw_atasco = 0
                    else
                        z.le._hw_atasco = (z.le._hw_atasco or 0) + paso
                    end
                    if z.le._hw_atasco > T_ATASCO then
                        local destino = V.buscar_calle(mejor.pos, 3, 8, false)
                        if destino then
                            z.obj:set_pos(destino)
                            V.salpicar(destino, 4, 1)
                        end
                        z.le._hw_mejor = nil
                        z.le._hw_atasco = 0
                    end
                else
                    z.le._hw_mejor = nil
                    z.le._hw_atasco = 0
                end
            end
        end
    end

    -- 5.3 Los transeuntes: pelean, arrancan o se calman.
    for _, p in ipairs(peatones) do
        if p.pos then
            local amenaza, d_amenaza
            for _, z in ipairs(zombies) do
                if z.pos then
                    local d = vector.distance(p.pos, z.pos)
                    if not d_amenaza or d < d_amenaza then
                        amenaza, d_amenaza = z, d
                    end
                end
            end

            local le = p.le

            if amenaza and d_amenaza <= DIST_COMBATE then
                -- Entra en combate (o sigue en el).
                if not le._halloween then
                    le._halloween = true
                    le._hw_hp = HP_PEATON
                    le._hw_golpe = 0
                    le._hw_mordida = 0
                    le._hw_libre = 0
                    -- La decision de pelear o arrancar se toma UNA vez y no se
                    -- revisa: un NPC que cambia de idea cada medio segundo se
                    -- ve como un bug, no como miedo.
                    le._hw_modo = (math.random() < P_MIEDO) and "huir" or "pelear"
                    V.avisar_cerca(p.pos, minetest.colorize("#FFD24A", "[!] ") ..
                        V.al_azar(le._hw_modo == "huir" and GRITOS_HUIDA or GRITOS_PELEA), 24)
                end
                le._hw_libre = 0

                local dir = vector.subtract(amenaza.pos, p.pos)
                dir.y = 0
                local largo = math.sqrt(dir.x * dir.x + dir.z * dir.z)
                local vel = p.obj:get_velocity()
                local vy = vel and vel.y or 0

                if le._hw_modo == "huir" then
                    local r = rumbo_huida(p.pos, amenaza.pos)
                    if r then
                        p.obj:set_velocity({x = r.x * VEL_HUIDA, y = vy, z = r.z * VEL_HUIDA})
                        p.obj:set_yaw(r.yaw)
                        p.obj:set_animation(ANIM_CAMINA, 38, 0, true)
                    else
                        -- Acorralado: ya no hay a donde arrancar, pelea.
                        le._hw_modo = "pelear"
                    end
                end

                if le._hw_modo == "pelear" then
                    p.obj:set_velocity({x = 0, y = vy, z = 0})
                    if largo > 0 then
                        -- Misma convencion de yaw que el resto de los NPC de
                        -- este modelo en el repo.
                        p.obj:set_yaw(math.atan2(dir.z, dir.x) - math.pi / 2)
                    end
                    p.obj:set_animation(ANIM_GOLPE, 30, 0, true)

                    le._hw_golpe = (le._hw_golpe or 0) + paso
                    if le._hw_golpe >= CADENCIA_PEATON then
                        le._hw_golpe = 0
                        local d = largo > 0 and vector.normalize(dir) or {x = 0, y = 0, z = 1}
                        amenaza.obj:punch(p.obj, 1.0, {
                            full_punch_interval = 1.0,
                            damage_groups = {fleshy = DANIO_PEATON},
                        }, d)
                        V.salpicar({x = amenaza.pos.x, y = amenaza.pos.y + 1, z = amenaza.pos.z}, 6, 1)
                    end
                end

                -- La mordida del zombie. Se resuelve por cercania y reloj, no
                -- por detectar el punch: mcl_mobs golpea cuando quiere y el
                -- transeunte es inmortal, asi que el golpe real no deja rastro
                -- que podamos leer. Esta es la vida virtual que lleva el mod.
                le._hw_mordida = (le._hw_mordida or 0) + paso
                if d_amenaza <= 2.4 and le._hw_mordida >= CADENCIA_ZOMBIE then
                    le._hw_mordida = 0
                    le._hw_hp = (le._hw_hp or HP_PEATON) - DANIO_ZOMBIE
                    V.salpicar({x = p.pos.x, y = p.pos.y + 1, z = p.pos.z}, 8, 1.5)
                    if le._hw_hp <= 0 then
                        infectar(p.obj, le)
                    end
                end

            elseif le._halloween then
                -- Ya no hay zombie encima. Se le da unos segundos antes de
                -- devolverlo a su caminata, para que no alterne pelea/paseo
                -- cada vez que el zombie se aleja un paso.
                le._hw_libre = (le._hw_libre or 0) + paso
                if le._hw_modo == "huir" and amenaza and d_amenaza <= DIST_SOLTAR then
                    local r = rumbo_huida(p.pos, amenaza.pos)
                    local vel = p.obj:get_velocity()
                    if r then
                        p.obj:set_velocity({x = r.x * VEL_HUIDA,
                                            y = vel and vel.y or 0,
                                            z = r.z * VEL_HUIDA})
                        p.obj:set_yaw(r.yaw)
                        p.obj:set_animation(ANIM_CAMINA, 38, 0, true)
                    end
                    le._hw_libre = 0
                elseif le._hw_libre >= T_SOLTAR then
                    if le._hw_modo == "pelear" and math.random() < 0.4 then
                        V.avisar_cerca(p.pos, minetest.colorize("#9FE09F", "[:)] ") ..
                            V.al_azar(GRITOS_VICTORIA), 20)
                    end
                    soltar(p.obj, le)
                end
            end
        end
    end

    -- 5.4 Los guias del spawn: no se mueven y no se infectan, pero pegan. Son
    -- la zona segura del mundo y tienen que sentirse asi.
    for _, g in ipairs(guias) do
        if g.pos then
            local cerca, d_cerca
            for _, z in ipairs(zombies) do
                if z.pos then
                    local d = vector.distance(g.pos, z.pos)
                    if d <= DIST_GUIA and (not d_cerca or d < d_cerca) then
                        cerca, d_cerca = z, d
                    end
                end
            end
            if cerca then
                local le = g.le
                le._hw_golpe = (le._hw_golpe or 0) + paso
                if le._hw_golpe >= CADENCIA_GUIA then
                    le._hw_golpe = 0
                    local dir = vector.subtract(cerca.pos, g.pos)
                    dir.y = 0
                    local largo = math.sqrt(dir.x * dir.x + dir.z * dir.z)
                    local d = largo > 0 and vector.normalize(dir) or {x = 0, y = 0, z = 1}
                    if largo > 0 then
                        g.obj:set_yaw(math.atan2(dir.z, dir.x) - math.pi / 2)
                    end
                    cerca.obj:punch(g.obj, 1.0, {
                        full_punch_interval = 1.0,
                        damage_groups = {fleshy = DANIO_GUIA},
                    }, d)
                    V.salpicar({x = cerca.pos.x, y = cerca.pos.y + 1, z = cerca.pos.z}, 8, 1.5)
                    le._hw_grito = (le._hw_grito or 0) + 1
                    if le._hw_grito % 6 == 1 then
                        V.avisar_cerca(g.pos, minetest.colorize("#4FA3E3", "[Guia] ") ..
                            V.al_azar(GRITOS_GUIA), 24)
                    end
                end
            end
        end
    end
end)

-- Al apagar el evento, cualquier transeunte que quedo tomado vuelve a su
-- caminata. Sin esto se quedarian congelados en pose de golpe para siempre.
V.al_apagar(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        local pp = player:get_pos()
        if pp then
            for _, obj in ipairs(minetest.get_objects_inside_radius(pp, RADIO_ESCANEO)) do
                local le = obj:get_luaentity()
                if le and le._halloween then soltar(obj, le) end
            end
        end
    end
end)

minetest.log("action", "[" .. modname .. "] combate.lua: director listo")
