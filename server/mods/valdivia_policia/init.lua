-- valdivia_policia
-- Cuando alguien intenta romper (o construir en) un area protegida ajena,
-- aparece un carabinero que lo persigue, lo reta por chat y le dispara con la
-- ballesta hasta que se acaba el tiempo de persecucion.
--
-- Por defecto NO es letal: nunca dispara el tiro que te mataria (deja al
-- infractor con al menos un corazon). Se puede volver letal con
-- valdivia_policia_letal = 1 en luanti-valdivia.conf.
--
-- Gancho: minetest.register_on_protection_violation, que el motor dispara
-- cuando minetest.is_protected niega una accion. El mod protector (Redo) usa
-- ese mismo gancho para protector_hurt / protector_flip (ambos apagados aca);
-- el registro es plural, asi que convivimos sin tocar protector.

local modname = minetest.get_current_modname()

-- ============================================================================
-- 1. AJUSTES
-- ============================================================================
local function num(key, default)
    return tonumber(minetest.settings:get("valdivia_policia_" .. key)) or default
end

local DURACION      = num("duracion", 25)    -- segundos que dura la persecucion
local COOLDOWN      = num("cooldown", 60)    -- segundos entre policias para el mismo jugador
local MAX_POLICIAS  = num("max", 3)          -- tope global simultaneo
local VELOCIDAD     = num("velocidad", 3.2)  -- nodos/segundo
local DANIO         = num("danio", 2)        -- HP por dardo (2 = medio corazon x2)
local CADENCIA      = num("cadencia", 2.5)   -- segundos entre disparos
local ALCANCE       = num("alcance", 14)     -- distancia maxima de tiro
local LETAL         = num("letal", 0) == 1   -- 1 = puede matar

local DIST_LEJOS    = 25                     -- si se aleja mas, reaparece cerca
local DIST_CERCA    = 2.0                    -- a esta distancia deja de correr
local T_ATASCO      = 4                      -- segundos sin acercarse antes de reubicarlo
local T_RETO        = 6                      -- segundos entre retos por chat
local DEBOUNCE      = 1                      -- segundos entre evaluaciones por jugador
local HP            = 10000                  -- inmortal de facto
local VEL_DARDO     = 22                     -- nodos/segundo del proyectil

local ENTITY = "valdivia_policia:policia"
local DARDO  = "valdivia_policia:dardo"
local COLOR  = "#4FA3E3"

local RETOS = {
    "¡Alto ahí! Esa construcción tiene dueño.",
    "¡Oye! No se rompe lo que no es tuyo.",
    "¡Te vi! Aléjate de ahí ahora mismo.",
    "¡Deténgase! Respeta el trabajo de los demás.",
    "Construye lo tuyo al lado, ¡pero no toques eso!",
}
local RENDIRSE = {
    "Esta vez te salvaste... ¡pero te estoy mirando!",
    "Me cansé de perseguirte. ¡Pórtate bien!",
    "Me vuelvo a la comisaría. No lo intentes de nuevo.",
}
local PERDON = {
    "Estás muy herido, te dejo ir. ¡Que no se repita!",
    "No te voy a rematar. Aprende la lección.",
}

-- ============================================================================
-- 2. ESTADO EN MEMORIA
-- ============================================================================
local policias  = {}  -- nombre del infractor -> ObjectRef del policia
local cooldown  = {}  -- nombre -> os.time() del ultimo policia enviado
local ultima_ev = {}  -- nombre -> os.clock() de la ultima violacion evaluada

local function contar_policias()
    local n = 0
    for nombre, obj in pairs(policias) do
        if obj and obj:get_pos() then
            n = n + 1
        else
            policias[nombre] = nil
        end
    end
    return n
end

local function decir(nombre, msg)
    minetest.chat_send_player(nombre, minetest.colorize(COLOR, "[Carabinero] ") .. msg)
end

local function al_azar(t) return t[math.random(#t)] end

local function destello(pos)
    minetest.add_particlespawner({
        amount = 20, time = 0.4,
        minpos = vector.subtract(pos, 0.4), maxpos = vector.add(pos, 0.4),
        minvel = {x = -0.5, y = 0.6, z = -0.5}, maxvel = {x = 0.5, y = 1.4, z = 0.5},
        minexptime = 0.6, maxexptime = 1.2,
        minsize = 1, maxsize = 2.5,
        texture = "valdivia_policia_particula.png",
        glow = 8,
    })
end

-- ============================================================================
-- 3. DONDE APARECE
-- ============================================================================
-- Busca suelo firme con dos nodos de aire encima, a ~5 nodos del jugador.
-- Si no encuentra nada (jugador encerrado en una pieza), no spawnea: mejor
-- ningun policia que uno empotrado dentro de un muro de Arnis.
local function buscar_pos(ppos)
    for _, r in ipairs({5, 7, 3}) do
        for i = 0, 7 do
            local ang = (math.pi / 4) * i
            local bx = math.floor(ppos.x + math.cos(ang) * r + 0.5)
            local bz = math.floor(ppos.z + math.sin(ang) * r + 0.5)
            for dy = 2, -3, -1 do
                local suelo  = {x = bx, y = math.floor(ppos.y + 0.5) + dy - 1, z = bz}
                local pies   = {x = bx, y = suelo.y + 1, z = bz}
                local cabeza = {x = bx, y = suelo.y + 2, z = bz}
                local n_suelo = minetest.get_node(suelo).name
                local def = minetest.registered_nodes[n_suelo]
                if def and def.walkable and n_suelo ~= "ignore"
                and minetest.get_node(pies).name == "air"
                and minetest.get_node(cabeza).name == "air" then
                    return {x = pies.x + 0.5, y = pies.y, z = pies.z + 0.5}
                end
            end
        end
    end
    return nil
end

-- ============================================================================
-- 4. EL DARDO DE BALLESTA
-- ============================================================================
-- Proyectil propio en vez de mcl_bows:arrow_entity: no dependemos de los
-- internos de VoxeLibre (que no estan en este checkout) y controlamos que solo
-- danie al infractor, nunca a quien pase por ahi.
minetest.register_entity(DARDO, {
    initial_properties = {
        physical = false,
        collide_with_objects = false,
        collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
        visual = "sprite",
        visual_size = {x = 0.5, y = 0.5},
        textures = {"valdivia_policia_flecha.png"},
        pointable = false,
        static_save = false,   -- jamas se guarda en el mapa
        glow = 3,
    },

    _vida = 0,
    _objetivo = nil,

    on_step = function(self, dtime)
        self._vida = self._vida + dtime
        if self._vida > 6 then self.object:remove() return end

        local pos = self.object:get_pos()
        if not pos then return end

        -- Choca con el terreno
        local def = minetest.registered_nodes[minetest.get_node(pos).name]
        if def and def.walkable then
            self.object:remove()
            return
        end

        -- Solo impacta al infractor
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 1.1)) do
            if obj:is_player() and obj:get_player_name() == self._objetivo then
                local vel = self.object:get_velocity() or {x = 0, y = 0, z = 0}
                local dir = vector.normalize(vel)
                obj:punch(self.object, 1.0, {
                    full_punch_interval = 1.0,
                    damage_groups = {fleshy = DANIO},
                }, dir)
                destello(pos)
                self.object:remove()
                return
            end
        end
    end,
})

-- ============================================================================
-- 5. EL MOB
-- ============================================================================
-- Mismo patron probado en valdivia_spawn_npc / wetlands_npcs: mcl_mobs solo
-- registra y dibuja; el movimiento y el disparo los maneja do_custom
-- (walk_chance = 0 para que el FSM de mcl_mobs no pelee con el nuestro).
local function registrar_mob()
    mcl_mobs.register_mob(ENTITY, {
        description = "Carabinero de Valdivia",
        type = "npc",
        spawn_class = "passive",
        passive = true,
        xp_min = 0,
        xp_max = 0,
        initial_properties = {
            hp_min = HP,
            hp_max = HP,
        },
        collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
        visual = "mesh",
        mesh = "mcl_armor_character.b3d",
        -- 3 capas que pide mcl_armor_character.b3d: {skin, armadura, capa}
        textures = {{"valdivia_policia_skin.png", "blank.png", "blank.png"}},
        makes_footstep_sound = true,
        walk_velocity = VELOCIDAD,
        run_velocity = VELOCIDAD,
        walk_chance = 0,
        jump = true,
        jump_height = 5,
        stepheight = 1.1,
        fear_height = 0,
        fall_damage = 0,
        view_range = 32,
        drops = {},
        can_despawn = true,
        armor_groups = {immortal = 1, fleshy = 0},
        animation = {
            stand_start = 0, stand_end = 79, stand_speed = 30,
            walk_start = 168, walk_end = 187, walk_speed = 30,
            run_start = 168, run_end = 187, run_speed = 30,
        },

        on_activate = function(self, staticdata, dtime_s)
            self.object:set_armor_groups({immortal = 1, fleshy = 0})
            self.object:set_hp(HP)
            self.health = HP

            -- Anti-huerfanos: si el contenedor se reinicio a mitad de
            -- persecucion (aca docker stop siempre termina en SIGKILL), el
            -- policia revive sin objetivo valido. Que se borre solo en vez de
            -- quedar plantado para siempre en media ciudad.
            if not self._objetivo or not self._vence or os.time() > self._vence then
                self.object:remove()
                return
            end
            policias[self._objetivo] = self.object
        end,

        do_custom = function(self, dtime)
            if self.object:get_hp() < HP then
                self.object:set_hp(HP)
                self.object:set_armor_groups({immortal = 1, fleshy = 0})
            end

            local nombre = self._objetivo
            if not nombre then self.object:remove() return end

            local pos = self.object:get_pos()
            if not pos then return end

            local player = minetest.get_player_by_name(nombre)
            if not player then  -- se desconecto
                policias[nombre] = nil
                self.object:remove()
                return
            end

            -- Se acabo el tiempo: se rinde y se va.
            self._vida = (self._vida or 0) + dtime
            if self._vida > DURACION then
                decir(nombre, al_azar(RENDIRSE))
                destello(pos)
                policias[nombre] = nil
                self.object:remove()
                return
            end

            local ppos = player:get_pos()
            local dist = vector.distance(pos, ppos)

            -- Anti-atasco SIN pathfinding: Valdivia es una ciudad densa de
            -- Arnis y el A* de mcl_mobs se traba en patios y escaleras. Si se
            -- quedo lejos o dejo de acercarse, reaparece cerca del jugador
            -- (como si hubiera dado la vuelta a la manzana).
            self._mejor = math.min(self._mejor or dist, dist)
            self._atasco = (dist <= self._mejor + 0.5) and 0 or ((self._atasco or 0) + dtime)
            if dist > DIST_LEJOS or self._atasco > T_ATASCO then
                local destino = buscar_pos(ppos)
                if destino then
                    destello(pos)
                    self.object:set_pos(destino)
                    destello(destino)
                end
                self._mejor = nil
                self._atasco = 0
                return
            end

            -- Movimiento
            local dir = vector.subtract(ppos, pos)
            dir.y = 0
            local largo = math.sqrt(dir.x * dir.x + dir.z * dir.z)
            if dist < DIST_CERCA or largo == 0 then
                local vel = self.object:get_velocity()
                self.object:set_velocity({x = 0, y = vel and vel.y or 0, z = 0})
                self.object:set_animation({x = 0, y = 79}, 30, 0, true)
                if largo > 0 then
                    self.object:set_yaw(math.atan2(dir.z, dir.x) - math.pi / 2)
                end
            else
                local vel = self.object:get_velocity()
                self.object:set_velocity({
                    x = (dir.x / largo) * VELOCIDAD,
                    y = vel and vel.y or 0,
                    z = (dir.z / largo) * VELOCIDAD,
                })
                -- Misma convencion de yaw que los otros NPC de este modelo.
                self.object:set_yaw(math.atan2(dir.z, dir.x) - math.pi / 2)
                self.object:set_animation({x = 168, y = 187}, 30, 0, true)
            end

            -- Ballesta: dispara si hay linea de vision y esta a tiro.
            self._tiro = (self._tiro or 0) + dtime
            if self._tiro >= CADENCIA and dist <= ALCANCE then
                self._tiro = 0

                local hp = player:get_hp()
                if not LETAL and hp <= DANIO then
                    -- No remata: avisa una vez y sigue acompaniando.
                    if not self._perdono then
                        self._perdono = true
                        decir(nombre, al_azar(PERDON))
                    end
                else
                    local origen = {x = pos.x, y = pos.y + 1.5, z = pos.z}
                    local blanco = {x = ppos.x, y = ppos.y + 1.2, z = ppos.z}
                    if minetest.line_of_sight(origen, blanco) then
                        local d = vector.normalize(vector.subtract(blanco, origen))
                        local obj = minetest.add_entity(
                            vector.add(origen, vector.multiply(d, 0.8)), DARDO)
                        if obj then
                            local le = obj:get_luaentity()
                            if le then le._objetivo = nombre end
                            obj:set_velocity(vector.multiply(d, VEL_DARDO))
                            obj:set_acceleration({x = 0, y = 0, z = 0})
                        end
                    end
                end
            end

            -- Reto periodico por chat.
            self._reto = (self._reto or 0) + dtime
            if self._reto > T_RETO then
                self._reto = 0
                decir(nombre, al_azar(RETOS))
            end
        end,

        -- Inmortal: si le pegan, no pasa nada.
        do_punch = function(self, puncher)
            self.object:set_armor_groups({immortal = 1, fleshy = 0})
            self.object:set_hp(HP)
            self.health = HP
            if puncher and puncher:is_player() then
                decir(puncher:get_player_name(), "¡Resistirse a la autoridad! Peor para ti.")
            end
            return false
        end,

        on_rightclick = function(self, clicker)
            if not clicker or not clicker:is_player() then return end
            decir(clicker:get_player_name(),
                "Protege tus cosas con el bloque de protección y no toques las ajenas.")
        end,
    })
end

-- ============================================================================
-- 6. ENVIAR / RETIRAR
-- ============================================================================
local function enviar_policia(nombre)
    local player = minetest.get_player_by_name(nombre)
    if not player then return false end

    if policias[nombre] and policias[nombre]:get_pos() then return false end
    policias[nombre] = nil

    if contar_policias() >= MAX_POLICIAS then return false end

    local pos = buscar_pos(player:get_pos())
    if not pos then return false end

    local obj = minetest.add_entity(pos, ENTITY)
    if not obj then return false end

    local luaent = obj:get_luaentity()
    if not luaent then obj:remove() return false end

    luaent._objetivo = nombre
    luaent._vida = 0
    luaent._vence = os.time() + DURACION + 30  -- margen para el chequeo anti-huerfanos
    policias[nombre] = obj
    cooldown[nombre] = os.time()

    destello(pos)
    decir(nombre, al_azar(RETOS))
    minetest.log("action", "[" .. modname .. "] policia enviado tras " .. nombre ..
        " en " .. minetest.pos_to_string(vector.round(pos)))
    return true
end

local function retirar_policia(nombre)
    local obj = policias[nombre]
    if obj and obj:get_pos() then obj:remove() end
    policias[nombre] = nil
end

-- ============================================================================
-- 7. GANCHO: VIOLACION DE AREA PROTEGIDA
-- ============================================================================
minetest.register_on_protection_violation(function(pos, name)
    if not name or name == "" then return end

    local player = minetest.get_player_by_name(name)
    if not player then return end

    -- El admin (protection_bypass) no deberia llegar aca, pero por si acaso.
    if minetest.check_player_privs(name, {protection_bypass = true}) then return end

    -- Un clic sostenido dispara este callback varias veces por segundo.
    local ahora = os.clock()
    if ultima_ev[name] and (ahora - ultima_ev[name]) < DEBOUNCE then return end
    ultima_ev[name] = ahora

    if policias[name] and policias[name]:get_pos() then return end
    if cooldown[name] and (os.time() - cooldown[name]) < COOLDOWN then return end

    enviar_policia(name)
end)

minetest.register_on_leaveplayer(function(player)
    local nombre = player:get_player_name()
    retirar_policia(nombre)
    ultima_ev[nombre] = nil
end)

minetest.register_on_dieplayer(function(player)
    retirar_policia(player:get_player_name())
end)

-- ============================================================================
-- 8. COMANDOS DE ADMIN
-- ============================================================================
minetest.register_chatcommand("policia", {
    params = "[jugador]",
    description = "Envia un carabinero a perseguir a un jugador (prueba, admin)",
    privs = {server = true},
    func = function(name, param)
        local objetivo = (param or ""):match("%S+") or name
        if not minetest.get_player_by_name(objetivo) then
            return false, "Ese jugador no esta conectado."
        end
        cooldown[objetivo] = nil
        retirar_policia(objetivo)
        if enviar_policia(objetivo) then
            return true, "Carabinero enviado tras " .. objetivo .. "."
        end
        return false, "No se pudo (sin espacio alrededor o tope de " .. MAX_POLICIAS .. ")."
    end,
})

minetest.register_chatcommand("policia_limpiar", {
    params = "",
    description = "Retira todos los carabineros activos (admin)",
    privs = {server = true},
    func = function(name, param)
        local n = 0
        for nombre in pairs(policias) do
            retirar_policia(nombre)
            n = n + 1
        end
        -- Barrido por si quedo alguno huerfano cerca del admin.
        local player = minetest.get_player_by_name(name)
        if player then
            for _, obj in ipairs(minetest.get_objects_inside_radius(player:get_pos(), 48)) do
                local le = obj:get_luaentity()
                if le and le.name == ENTITY then obj:remove() ; n = n + 1 end
            end
        end
        return true, "Carabineros retirados: " .. n
    end,
})

-- ============================================================================
-- 9. CARGA
-- ============================================================================
if minetest.get_modpath("mcl_mobs") and mcl_mobs and mcl_mobs.register_mob then
    registrar_mob()
    minetest.log("action", "[" .. modname .. "] Loaded successfully")
else
    minetest.log("error", "[" .. modname .. "] mcl_mobs no disponible; el carabinero no se registro.")
end
