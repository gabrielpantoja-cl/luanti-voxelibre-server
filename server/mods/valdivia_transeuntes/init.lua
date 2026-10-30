-- ============================================================================
-- valdivia_transeuntes
-- ============================================================================
-- Gente que camina por las calles de Valdivia (puerto 30001). No son guias ni
-- comerciantes: son figurantes. Aparecen solos cerca de cada jugador, caminan
-- por la calle, se detienen a mirar, y se borran cuando ya no hay nadie cerca.
--
-- Dos decisiones de diseno que explican casi todo el archivo:
--
-- 1. NO HAY PATHFINDING. El A* de mcl_mobs se traba en los patios y escaleras
--    de la ciudad generada con Arnis (documentado en valdivia_policia). En vez
--    de buscar una ruta, el transeunte "sigue la calle": sondea lo que tiene
--    adelante y, si no se puede pisar, gira al rumbo valido mas parecido. En
--    una ciudad OSM las calles son los unicos corredores continuos que son
--    caminables, con dos nodos de aire y cielo abierto, asi que seguir ese
--    corredor equivale a caminar por la vereda.
--
-- 2. NO SE GUARDAN. Son efimeros (static_save = false): nacen cerca de un
--    jugador y se borran al alejarse. Asi no hay roster que reconciliar ni
--    huerfanos despues de un apagon (aca `docker stop` siempre termina en
--    SIGKILL y los mapblocks no alcanzan a escribirse).
--
-- Solo Valdivia: load_mod_valdivia_transeuntes = true en luanti-valdivia.conf
-- (y en el world.mt del VPS).

local modname = minetest.get_current_modname()

-- ============================================================================
-- 1. AJUSTES
-- ============================================================================
local function num(key, default)
    return tonumber(minetest.settings:get("valdivia_transeuntes_" .. key)) or default
end

local MAX_GLOBAL  = num("max", 15)          -- tope de transeuntes vivos en todo el mundo
local POR_JUGADOR = num("por_jugador", 5)   -- cuantos acompanan a cada jugador
local DIST_MIN    = num("dist_min", 30)     -- no nacen mas cerca que esto
local DIST_MAX    = num("dist_max", 45)     -- ni mas lejos
local DIST_BORRAR = num("dist_borrar", 70)  -- se borran al pasar esta distancia
local VELOCIDAD   = num("velocidad", 1.5)   -- nodos/segundo (un jugador va a 4.3)
local INTERVALO   = num("intervalo", 5)     -- segundos entre rondas del sembrador
local LUZ_MIN     = num("luz_min", 14)      -- luz natural a mediodia para contar como calle

local PASO      = 0.4    -- segundos entre decisiones de rumbo
local SONDEO    = 1.6    -- nodos por delante que mira antes de avanzar
local P_GIRO    = 0.10   -- probabilidad de doblar aunque el frente este libre
local P_PAUSA   = 0.04   -- probabilidad de quedarse mirando
local PAUSA_MIN = 2
local PAUSA_MAX = 6
local HP        = 10000  -- inmortal de facto

local ENTITY = modname .. ":transeunte"
local C_NPC  = "#9FE09F"

-- ============================================================================
-- 2. QUIENES SON
-- ============================================================================
-- Un tipo = un oficio + sus skins + lo que dice al hacerle clic derecho. Las
-- frases son cortas, en espanol y apropiadas para ninos: hablan de la ciudad
-- real (el rio, la lluvia, la feria, la universidad).
local TIPOS = {
    vecino = {
        label = "vecino de Valdivia",
        skins = {"valdivia_transeunte_vecino_1.png", "valdivia_transeunte_vecino_2.png"},
        frases = {
            "Buenos dias. Linda la ciudad hoy, no?",
            "Si llueve, ya pasara. Aca siempre vuelve a salir el sol.",
            "Cuidado al cruzar, que pasan autos.",
            "Vivo a la vuelta. Si te pierdes, busca una cabina roja.",
        },
    },
    escolar = {
        label = "escolar",
        skins = {"valdivia_transeunte_escolar_1.png", "valdivia_transeunte_escolar_2.png"},
        frases = {
            "Voy atrasado al colegio!",
            "Sabias que el rio Calle-Calle pasa por aca al lado?",
            "Hoy tengo prueba de historia. Deseame suerte.",
            "Mi curso fue de paseo al humedal. Habia muchos pajaros.",
        },
    },
    estudiante = {
        label = "estudiante",
        skins = {"valdivia_transeunte_estudiante_1.png", "valdivia_transeunte_estudiante_2.png"},
        frases = {
            "Estudio en la Austral, alla en Isla Teja.",
            "Voy a la biblioteca, tengo que entregar un trabajo.",
            "Conoces el Parque Saval? Queda cruzando el puente.",
            "Me falta un ramo para salir de vacaciones.",
        },
    },
    feriante = {
        label = "feriante",
        skins = {"valdivia_transeunte_feriante_1.png", "valdivia_transeunte_feriante_2.png"},
        frases = {
            "Llevelo, casero! Todo fresquito.",
            "Trabajo en el Mercado Fluvial, a la orilla del rio.",
            "A esta hora ya tengo el puesto armado.",
            "Lo mejor de la feria son las papas y la murta.",
        },
    },
    pescador = {
        label = "pescador",
        skins = {"valdivia_transeunte_pescador_1.png", "valdivia_transeunte_pescador_2.png"},
        frases = {
            "Vengo llegando del rio. Hoy estuvo tranquilo.",
            "Con este impermeable no me moja ni el invierno valdiviano.",
            "En el muelle siempre hay lobos marinos esperando.",
            "Sal temprano si quieres ver el rio con neblina.",
        },
    },
    turista = {
        label = "turista",
        skins = {"valdivia_transeunte_turista_1.png", "valdivia_transeunte_turista_2.png"},
        frases = {
            "Vine a conocer la ciudad. Es preciosa!",
            "Me dijeron que tengo que ver el Torreon. Sabes donde queda?",
            "Estoy buscando la Costanera para sacar fotos.",
            "Nunca habia visto tantos rios juntos.",
        },
    },
}

local TIPOS_ORDEN = {}
for k in pairs(TIPOS) do table.insert(TIPOS_ORDEN, k) end
table.sort(TIPOS_ORDEN)

local NOMBRES = {
    "Camila", "Matias", "Javiera", "Benjamin", "Antonia", "Vicente",
    "Florencia", "Martin", "Josefa", "Agustin", "Emilia", "Tomas",
    "Catalina", "Joaquin", "Isidora", "Cristobal", "Amanda", "Gaspar",
    "Rayen", "Lautaro", "Millaray", "Nahuel", "Paz", "Elias",
}

local function al_azar(t) return t[math.random(#t)] end

-- ============================================================================
-- 3. ESTO ES CALLE?
-- ============================================================================
-- El corazon del mod. `p` es la posicion de los PIES.
--
-- La prueba de cielo abierto es la que separa calle de interior sin tener que
-- conocer los nombres de nodo con que Arnis pavimento la ciudad. Se pide la luz
-- natural con timeofday = 0.5 (mediodia) a proposito: la pregunta es "hay cielo
-- encima?", no "que hora es?". Sin ese 0.5 los transeuntes se meterian a las
-- casas de noche.
local function es_suelo(name)
    if name == "air" or name == "ignore" then return false end
    local def = minetest.registered_nodes[name]
    return def ~= nil and def.walkable == true and def.liquidtype == "none"
end

local function es_calle(p)
    if not es_suelo(minetest.get_node({x = p.x, y = p.y - 1, z = p.z}).name) then
        return false
    end
    if minetest.get_node(p).name ~= "air" then return false end
    if minetest.get_node({x = p.x, y = p.y + 1, z = p.z}).name ~= "air" then return false end
    local luz = minetest.get_natural_light(p, 0.5)
    return luz ~= nil and luz >= LUZ_MIN
end

-- Un techo plano pasa `es_calle` sin problema: es caminable y tiene cielo. Lo
-- que lo delata es el hueco de abajo, que es el interior del edificio. Bajo una
-- calle hay tierra; bajo un techo, a dos o tres nodos, hay aire.
local function tiene_suelo_macizo(p)
    for dy = 2, 4 do
        if minetest.get_node({x = p.x, y = p.y - dy, z = p.z}).name == "air" then
            return false
        end
    end
    return true
end

-- Descarta parches de un solo nodo: patios interiores, cornisas, la orilla del
-- rio. Una calle de verdad sigue siendo calle a los lados.
local function es_calle_ancha(p)
    local vecinos = 0
    for _, d in ipairs({{1, 0}, {-1, 0}, {0, 1}, {0, -1}}) do
        if es_calle({x = p.x + d[1], y = p.y, z = p.z + d[2]}) then
            vecinos = vecinos + 1
        end
    end
    return vecinos >= 3
end

-- ============================================================================
-- 4. RUMBOS
-- ============================================================================
-- Ocho direcciones fijas. Girar es moverse en esta lista, asi que "el giro mas
-- pequeno" es simplemente la diferencia de indice.
local DIRS = {}
for i = 0, 7 do
    local a = i * math.pi / 4
    DIRS[i + 1] = {x = math.cos(a), z = math.sin(a), yaw = a - math.pi / 2}
end

-- Se puede avanzar en este rumbo? Se mira el nodo de adelante y tambien uno
-- intermedio, para que no corte una esquina por la diagonal metiendose en un
-- muro. Se tolera un nodo de desnivel (veredas, badenes) porque mcl_mobs sube
-- solo hasta stepheight.
local function rumbo_libre(pos, idx)
    local d = DIRS[idx]
    local y = math.floor(pos.y + 0.5)
    for _, dist in ipairs({1, SONDEO}) do
        local x = math.floor(pos.x + d.x * dist)
        local z = math.floor(pos.z + d.z * dist)
        local ok = false
        for _, dy in ipairs({0, 1, -1}) do
            if es_calle({x = x, y = y + dy, z = z}) then
                ok = true
                break
            end
        end
        if not ok then return false end
    end
    return true
end

-- Rumbos validos ordenados por cuanto hay que girar (0 = seguir recto).
local function rumbos_validos(pos, actual)
    local out = {}
    for _, giro in ipairs({0, 1, -1, 2, -2, 3, -3, 4}) do
        local idx = ((actual - 1 + giro) % 8) + 1
        if rumbo_libre(pos, idx) then
            table.insert(out, {idx = idx, giro = math.abs(giro)})
        end
    end
    return out
end

-- ============================================================================
-- 5. EL TRANSEUNTE
-- ============================================================================
-- Igual que los guias y el carabinero: mcl_mobs solo registra, dibuja y aporta
-- la gravedad; el movimiento es nuestro. walk_chance = 0 es obligatorio o el
-- FSM de mcl_mobs pisa el set_velocity y el NPC avanza a tirones.
local vivos = {}  -- ObjectRef -> true (se limpia en el globalstep)

local function contar_vivos()
    local n = 0
    for obj in pairs(vivos) do
        if obj:get_pos() then n = n + 1 else vivos[obj] = nil end
    end
    return n
end

-- Cara, ropa y nombre. Se aplica tanto al crear como en el primer paso, porque
-- no damos por sentado CUANDO llama mcl_mobs a nuestro on_activate: si lo
-- llamara dentro de add_entity, el tipo todavia no estaria puesto.
local function aplicar_aspecto(self)
    local t = TIPOS[self._tipo]
    if not t then return false end
    self.object:set_properties({
        textures = {self._skin or t.skins[1], "blank.png", "blank.png"},
        infotext = (self._nombre or "Vecina") .. " - " .. t.label,
        static_save = false,
    })
    self._aspecto = true
    return true
end

local function registrar_mob()
    mcl_mobs.register_mob(ENTITY, {
        description = "Transeunte de Valdivia",
        type = "npc",
        spawn_class = "passive",
        passive = true,
        xp_min = 0,
        xp_max = 0,
        initial_properties = {
            hp_min = HP,
            hp_max = HP,
            -- Este VoxeLibre lo quiere aca Y en la raiz: con el collisionbox
            -- solo en la raiz loguea "Mob without collisionbox" al activarse.
            collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
        },
        collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
        visual = "mesh",
        mesh = "mcl_armor_character.b3d",
        -- 3 capas que pide mcl_armor_character.b3d: {skin, armadura, capa}
        textures = {{"valdivia_transeunte_vecino_1.png", "blank.png", "blank.png"}},
        makes_footstep_sound = true,
        walk_velocity = VELOCIDAD,
        run_velocity = VELOCIDAD,
        walk_chance = 0,
        -- Sin saltos: asi no se trepan a los techos ni a los autos.
        jump = false,
        stepheight = 1.1,
        fear_height = 0,
        fall_damage = 0,
        view_range = 16,
        drops = {},
        can_despawn = true,
        armor_groups = {immortal = 1, fleshy = 0},
        animation = {
            stand_start = 0, stand_end = 79, stand_speed = 30,
            walk_start = 168, walk_end = 187, walk_speed = 25,
            run_start = 168, run_end = 187, run_speed = 25,
        },

        on_activate = function(self, staticdata, dtime_s)
            self.object:set_armor_groups({immortal = 1, fleshy = 0})
            self.object:set_hp(HP)
            self.health = HP
            -- Efimeros: nunca se escriben en el mapblock.
            self.object:set_properties({static_save = false})
            self._edad = 0
            self._pausa = 0
            self._acum = 0
            self._rumbo = self._rumbo or math.random(8)
            if self._tipo then aplicar_aspecto(self) end
            vivos[self.object] = true
        end,

        do_custom = function(self, dtime)
            if self.object:get_hp() < HP then
                self.object:set_hp(HP)
                self.object:set_armor_groups({immortal = 1, fleshy = 0})
            end

            -- Sin tipo no hay transeunte. Un recien creado lo recibe en el
            -- mismo paso del servidor; si pasado un segundo sigue sin tipo es
            -- un resto de una version anterior del mod y se borra solo.
            self._edad = (self._edad or 0) + dtime
            if not TIPOS[self._tipo or ""] then
                if self._edad > 1 then
                    vivos[self.object] = nil
                    self.object:remove()
                end
                return
            end
            if not self._aspecto then aplicar_aspecto(self) end

            local pos = self.object:get_pos()
            if not pos then return end

            -- Decide rumbo cada PASO segundos, no cada tick: ocho sondeos por
            -- decision serian demasiados a veinte pasos por segundo.
            self._acum = (self._acum or 0) + dtime
            if self._acum < PASO then return end
            self._acum = 0

            local vel = self.object:get_velocity()
            local vy = vel and vel.y or 0

            -- Pausa: se queda mirando.
            if (self._pausa or 0) > 0 then
                self._pausa = self._pausa - PASO
                self.object:set_velocity({x = 0, y = vy, z = 0})
                self.object:set_animation({x = 0, y = 79}, 30, 0, true)
                return
            end

            local recto = rumbo_libre(pos, self._rumbo)
            if not recto or math.random() < P_GIRO then
                local opciones = rumbos_validos(pos, self._rumbo)
                if #opciones == 0 then
                    -- Encerrado (lo taparon, o la calle se cerro). Mejor
                    -- desaparecer que quedar vibrando contra un muro.
                    vivos[self.object] = nil
                    self.object:remove()
                    return
                end
                if recto then
                    -- Dobla en la esquina: cualquiera menos seguir recto.
                    local giros = {}
                    for _, o in ipairs(opciones) do
                        if o.giro > 0 then table.insert(giros, o) end
                    end
                    if #giros > 0 then self._rumbo = al_azar(giros).idx end
                else
                    -- Se acabo la calle: el giro mas suave que si sirva. Entre
                    -- los empatados (izquierda y derecha) se sortea.
                    local mejor = opciones[1].giro
                    local empatados = {}
                    for _, o in ipairs(opciones) do
                        if o.giro == mejor then table.insert(empatados, o) end
                    end
                    self._rumbo = al_azar(empatados).idx
                end
            end

            if math.random() < P_PAUSA then
                self._pausa = PAUSA_MIN + math.random() * (PAUSA_MAX - PAUSA_MIN)
                return
            end

            local d = DIRS[self._rumbo]
            self.object:set_velocity({x = d.x * VELOCIDAD, y = vy, z = d.z * VELOCIDAD})
            self.object:set_yaw(d.yaw)
            self.object:set_animation({x = 168, y = 187}, 25, 0, true)
        end,

        -- Anti-grief: no se les puede hacer nada.
        do_punch = function(self, puncher)
            self.object:set_armor_groups({immortal = 1, fleshy = 0})
            self.object:set_hp(HP)
            self.health = HP
            if puncher and puncher:is_player() then
                minetest.chat_send_player(puncher:get_player_name(),
                    minetest.colorize("#FF6B6B", "[" .. (self._nombre or "Vecina") ..
                    "] Oye! No me pegues, voy pasando no mas."))
            end
            return false
        end,

        on_rightclick = function(self, clicker)
            if not clicker or not clicker:is_player() then return end
            local t = TIPOS[self._tipo or ""]
            if not t then return end
            minetest.chat_send_player(clicker:get_player_name(),
                minetest.colorize(C_NPC, "[" .. (self._nombre or "Vecina") .. "] ") ..
                al_azar(t.frases))
            -- Se detiene un momento a conversar y mira a quien le hablo.
            self._pausa = 4
            local pos = self.object:get_pos()
            local cpos = clicker:get_pos()
            if pos and cpos then
                local dir = vector.subtract(cpos, pos)
                self.object:set_yaw(math.atan2(dir.z, dir.x) - math.pi / 2)
            end
        end,
    })
end

-- ============================================================================
-- 6. CREAR UNO
-- ============================================================================
local function crear(pos, tipo)
    tipo = tipo or al_azar(TIPOS_ORDEN)
    local t = TIPOS[tipo]
    if not t then return nil end

    local obj = minetest.add_entity(pos, ENTITY)
    if not obj then return nil end

    local le = obj:get_luaentity()
    if not le then
        obj:remove()
        return nil
    end

    le._tipo = tipo
    le._skin = al_azar(t.skins)
    le._nombre = al_azar(NOMBRES)
    le._rumbo = math.random(8)
    le._edad = 0
    aplicar_aspecto(le)
    vivos[obj] = true
    return obj
end

-- ============================================================================
-- 7. DONDE NACEN
-- ============================================================================
-- Tres filtros (calle / no es techo / calle ancha) y dos reglas de aparicion:
-- lejos y fuera de la vista. La segunda es la que evita que al jugador le
-- aparezca gente de la nada delante de los ojos.
local function buscar_sitio(player)
    local ppos = player:get_pos()
    if not ppos then return nil end
    local ojos = {x = ppos.x, y = ppos.y + 1.5, z = ppos.z}

    for _ = 1, 25 do
        local ang = math.random() * 2 * math.pi
        local r = DIST_MIN + math.random() * (DIST_MAX - DIST_MIN)
        local x = math.floor(ppos.x + math.cos(ang) * r)
        local z = math.floor(ppos.z + math.sin(ang) * r)

        -- Barrido vertical: la ciudad tiene desniveles, el suelo no esta a la
        -- misma altura que el jugador.
        for dy = 5, -8, -1 do
            local p = {x = x, y = math.floor(ppos.y + 0.5) + dy, z = z}
            if es_calle(p) and tiene_suelo_macizo(p) and es_calle_ancha(p) then
                local centro = {x = p.x + 0.5, y = p.y + 1, z = p.z + 0.5}
                if not minetest.line_of_sight(ojos, centro) then
                    return {x = p.x + 0.5, y = p.y, z = p.z + 0.5}
                end
                break  -- es calle, pero a la vista: probar otro punto
            end
        end
    end
    return nil
end

-- ============================================================================
-- 8. EL SEMBRADOR
-- ============================================================================
-- Un solo globalstep para todo el mod: siembra los que faltan y borra los que
-- quedaron lejos. Por jugador, no por NPC.
local reloj = 0

minetest.register_globalstep(function(dtime)
    reloj = reloj + dtime
    if reloj < INTERVALO then return end
    reloj = 0

    local jugadores = minetest.get_connected_players()

    -- Borrar los que ya no acompanan a nadie.
    for obj in pairs(vivos) do
        local pos = obj:get_pos()
        if not pos then
            vivos[obj] = nil
        else
            local cerca = false
            for _, p in ipairs(jugadores) do
                local pp = p:get_pos()
                if pp and vector.distance(pos, pp) <= DIST_BORRAR then
                    cerca = true
                    break
                end
            end
            if not cerca then
                vivos[obj] = nil
                obj:remove()
            end
        end
    end

    if #jugadores == 0 then return end

    local total = contar_vivos()
    if total >= MAX_GLOBAL then return end

    -- De noche hay menos gente en la calle.
    local hora = minetest.get_timeofday()
    local noche = hora < 0.25 or hora > 0.78
    local cupo = noche and math.max(1, math.floor(POR_JUGADOR / 2)) or POR_JUGADOR

    for _, player in ipairs(jugadores) do
        if total >= MAX_GLOBAL then break end
        local ppos = player:get_pos()
        -- Si el jugador esta bajo tierra o encerrado no hay calle que sembrar,
        -- y los 25 sondeos serian puro gasto.
        local luz = ppos and minetest.get_natural_light(ppos, 0.5)
        if ppos and luz and luz >= 8 then
            local acompanantes = 0
            for obj in pairs(vivos) do
                local opos = obj:get_pos()
                if opos and vector.distance(opos, ppos) <= DIST_BORRAR then
                    acompanantes = acompanantes + 1
                end
            end
            if acompanantes < cupo then
                local sitio = buscar_sitio(player)
                if sitio and crear(sitio) then
                    total = total + 1
                end
            end
        end
    end
end)

-- ============================================================================
-- 9. COMANDOS (admin)
-- ============================================================================
minetest.register_chatcommand("transeunte", {
    params = "[" .. table.concat(TIPOS_ORDEN, "|") .. "]",
    description = "Coloca un transeunte en tu posicion (admin). Sin argumento, al azar.",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end
        local tipo = (param or ""):lower():match("%S+")
        if tipo and not TIPOS[tipo] then
            return false, "Tipo invalido. Opciones: " .. table.concat(TIPOS_ORDEN, ", ")
        end
        local pos = player:get_pos()
        pos.y = pos.y + 0.5
        local obj = crear(pos, tipo)
        if not obj then return false, "No se pudo crear el transeunte" end
        local le = obj:get_luaentity()
        return true, (le._nombre or "?") .. " (" .. (le._tipo or "?") ..
            ") colocada en " .. minetest.pos_to_string(vector.round(pos))
    end,
})

minetest.register_chatcommand("transeuntes", {
    params = "[info|limpiar]",
    description = "Estado de los transeuntes, o borrarlos a todos (admin).",
    privs = {server = true},
    func = function(name, param)
        local sub = (param or ""):lower():match("%S+") or "info"
        if sub == "limpiar" then
            local n = 0
            for obj in pairs(vivos) do
                if obj:get_pos() then obj:remove() end
                n = n + 1
            end
            vivos = {}
            return true, "Borrados " .. n .. " transeuntes."
        end
        local lineas = {"Transeuntes vivos: " .. contar_vivos() .. "/" .. MAX_GLOBAL ..
            " (hasta " .. POR_JUGADOR .. " por jugador)"}
        for obj in pairs(vivos) do
            local le = obj:get_luaentity()
            local pos = obj:get_pos()
            if le and pos then
                table.insert(lineas, "  " .. (le._nombre or "?") .. " (" ..
                    (le._tipo or "?") .. ") en " .. minetest.pos_to_string(vector.round(pos)))
            end
        end
        return true, table.concat(lineas, "\n")
    end,
})

-- Diagnostico: dice por que un punto es o no es calle. Sirve para calibrar
-- LUZ_MIN sin adivinar; pararse en una calle, en una plaza, dentro de una casa
-- y sobre un techo, y comparar las cuatro salidas.
minetest.register_chatcommand("transeunte_scan", {
    description = "Explica si donde estas parado cuenta como calle (admin).",
    privs = {server = true},
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end
        local ppos = player:get_pos()
        local p = {x = math.floor(ppos.x), y = math.floor(ppos.y + 0.5), z = math.floor(ppos.z)}
        local suelo = minetest.get_node({x = p.x, y = p.y - 1, z = p.z}).name
        local luz = minetest.get_natural_light(p, 0.5)

        -- Cuantos de los 24 nodos de alrededor pasan el filtro completo.
        local ok, total = 0, 0
        for dx = -2, 2 do
            for dz = -2, 2 do
                if dx ~= 0 or dz ~= 0 then
                    total = total + 1
                    if es_calle({x = p.x + dx, y = p.y, z = p.z + dz}) then ok = ok + 1 end
                end
            end
        end

        return true, table.concat({
            "== scan en " .. minetest.pos_to_string(p) .. " ==",
            "suelo:           " .. suelo .. (es_suelo(suelo) and " (pisable)" or " (NO pisable)"),
            "luz natural 12h: " .. tostring(luz) .. "  (minimo " .. LUZ_MIN .. ")",
            "es_calle:        " .. tostring(es_calle(p)),
            "suelo macizo:    " .. tostring(tiene_suelo_macizo(p)) .. "  (false = techo)",
            "calle ancha:     " .. tostring(es_calle_ancha(p)),
            "alrededor:       " .. ok .. "/" .. total .. " nodos son calle",
        }, "\n")
    end,
})

-- ============================================================================
-- 10. ARRANQUE
-- ============================================================================
if minetest.get_modpath("mcl_mobs") and mcl_mobs and mcl_mobs.register_mob then
    registrar_mob()
    minetest.log("action", "[" .. modname .. "] Loaded successfully")
else
    minetest.log("error", "[" .. modname ..
        "] mcl_mobs no disponible; los transeuntes no se registraron.")
end
