-- valdivia_scp096
-- SCP-096, "el Timido". De noche aparece sentado en alguna calle de Valdivia,
-- llorando. Mientras nadie le vea la cara es inofensivo. Si un jugador lo mira
-- de frente (mirada centrada en su cabeza, el de cara hacia el jugador y sin
-- paredes de por medio), grita unos segundos y despues corre tras ese jugador
-- hasta alcanzarlo. Al alcanzarlo lo mata (valdivia_scp096_letal = 0 lo deja
-- en medio corazon) y desaparece.
--
-- Patron de movimiento heredado de valdivia_policia (ver AGENTS.md, pitfall
-- "walk_chance = 0"): mcl_mobs solo registra y dibuja, el movimiento es propio
-- en do_custom, jump = false, do_custom devuelve false y nada de A*: si se
-- traba, reaparece cerca de la victima. Para SCP-096 eso encaja con el
-- personaje: nada lo detiene.
--
-- Nace con static_save = false: un SIGKILL del contenedor no deja ninguno
-- plantado en la ciudad.

local modname = minetest.get_current_modname()

-- ============================================================================
-- 1. AJUSTES
-- ============================================================================
local function num(key, default)
    return tonumber(minetest.settings:get("valdivia_scp096_" .. key)) or default
end

local LETAL        = num("letal", 1) == 1     -- 0 = te deja con medio corazon
local VELOCIDAD    = num("velocidad", 6.5)    -- n/s (jugador: 4.3, corriendo ~5.6)
local FURIA        = num("furia", 5)          -- segundos gritando antes de correr
local MAX_CAZA     = num("caza_max", 120)     -- segundos de persecucion antes de rendirse
local INTERVALO    = num("intervalo", 45)     -- segundos entre intentos de aparicion
local PROB         = num("prob", 0.2)         -- probabilidad por intento (de noche)
local VIDA_CALMA   = num("vida", 300)         -- segundos sentado antes de esfumarse
local MAX_VIVOS    = num("max", 1)            -- cuantos a la vez en el mundo
local COOLDOWN     = num("cooldown", 600)     -- segundos sin aparecerle de nuevo a una victima

local VISTA_MAX    = 48       -- mas lejos que esto no cuenta como "verle la cara"
local COS_MIRADA   = 0.94     -- ~20 grados entre la mirada y su cabeza
local COS_CARA     = 0.30     -- el tiene que estar mas o menos de frente al jugador
local DIST_ATRAPA  = 1.6
-- Silueta de 096: no se agranda el modelo entero, se estiran los huesos
-- (set_bone_override, Luanti >= 5.9) sobre mcl_armor_character.b3d. Medido en
-- el .b3d: la cadera (Body_Control) esta a 6,75 unidades = 0,675 nodos, y las
-- piernas y brazos estan girados 180 grados en X, asi que su +y apunta hacia
-- abajo: escalar y alarga la extremidad desde la cadera / el hombro.
local PIERNA       = 1.45     -- largo de piernas
local BRAZO        = 1.8      -- largo de brazos: le llegan a media canilla
local GROSOR_BRAZO = 0.7
local TORSO_ANCHO  = 0.8      -- torso (y con el, todo lo que cuelga) mas flaco
local CABEZA_LARGA = 1.15
local CADERA       = 6.75     -- unidades del modelo (1 unidad = 0,1 nodo)
local ESCALA       = 1.1      -- visual_size en y, encima de lo anterior
-- Altura total aprox.: 1,8 + subida de cadera (0,30) + cabeza (0,05) = 2,15 x 1,1
local ALTO         = 2.37
local ALTO_COLISION = 1.9     -- choca como un jugador, para pasar por puertas de 2
local ACELERACION  = 10       -- n/s^2: tarda ~0,6 s en llegar a tope
local SALTO_VEL    = 6.5
local T_TRABA      = 0.35     -- segundos casi sin avanzar antes de saltar
local HP           = 10000

-- Ruta. Con vista directa corre en linea recta; si hay un edificio de por
-- medio usa minetest.find_path (el A* del motor, no el de mcl_mobs) y sigue los
-- puntos. Se recalcula cada RUTA_CADA s porque la victima se mueve.
local RUTA_CADA     = 1.0
local RUTA_BUSQUEDA = 40      -- radio de busqueda del A* (nodos)
-- Ultimo recurso, no metodo de persecucion: solo si lleva T_PERDIDO s sin
-- acortar distancia Y la victima no lo esta viendo, reaparece escondido a
-- 12-20 nodos (nunca al lado). Asi nadie lo ve teletransportarse.
local T_PERDIDO     = 8
local DIST_PERDIDO  = 60      -- tan lejos y fuera de vista: tambien reaparece

local ENTITY = "valdivia_scp096:scp096"
local COLOR  = "#B03030"

local ANIM_SENTADO = {x = 81,  y = 160}
local ANIM_PARADO  = {x = 0,   y = 79}
local ANIM_PASO    = {x = 168, y = 187}
local ANIM_ZARPAZO = {x = 189, y = 198}  -- "minar": solo al alcanzar a la victima

local S_LLANTO = "mobs_mc_enderman_random"
local S_GRITO  = "mobs_mc_enderman_death"
local S_SALTO  = "mobs_mc_enderman_teleport_src"

local storage = minetest.get_mod_storage()
local function auto_activo()
    local v = storage:get_string("auto")
    if v == "" then return num("auto", 1) == 1 end
    return v == "1"
end

-- ============================================================================
-- 2. ESTADO EN MEMORIA
-- ============================================================================
local vivos     = {}   -- ObjectRef -> true
local cooldown  = {}   -- nombre -> os.time() de la ultima aparicion/caza

local function contar()
    local n = 0
    for obj in pairs(vivos) do
        if obj:get_pos() then n = n + 1 else vivos[obj] = nil end
    end
    return n
end

local function decir(nombre, msg)
    minetest.chat_send_player(nombre, minetest.colorize(COLOR, "[SCP-096] ") .. msg)
end

local function avisar_cerca(pos, radio, msg, excepto)
    for _, p in ipairs(minetest.get_connected_players()) do
        local n = p:get_player_name()
        if n ~= excepto and vector.distance(p:get_pos(), pos) <= radio then
            decir(n, msg)
        end
    end
end

local function sonar(nombre_sonido, pos, ganancia, distancia, tono)
    minetest.sound_play(nombre_sonido, {
        pos = pos, gain = ganancia, max_hear_distance = distancia, pitch = tono or 1,
    }, true)
end

local function particulas(pos, textura, cantidad, subida)
    minetest.add_particlespawner({
        amount = cantidad, time = 0.5,
        minpos = vector.subtract(pos, 0.3), maxpos = vector.add(pos, 0.3),
        minvel = {x = -0.6, y = subida, z = -0.6}, maxvel = {x = 0.6, y = subida + 1, z = 0.6},
        minacc = {x = 0, y = -6, z = 0}, maxacc = {x = 0, y = -9, z = 0},
        minexptime = 0.5, maxexptime = 1.0,
        minsize = 1, maxsize = 2,
        texture = textura,
    })
end

local function cabeza(pos)
    return {x = pos.x, y = pos.y + ALTO - 0.3, z = pos.z}
end

-- ============================================================================
-- 3. DONDE APARECE
-- ============================================================================
local function libre(p)
    return minetest.get_node(p).name == "air"
end

-- Suelo firme + 3 de aire. modo "calle": ademas cielo abierto (luz natural a
-- mediodia >= 14: el mismo truco de valdivia_transeuntes para no aparecer
-- dentro de un edificio ni en la mina) y fuera de la vista del jugador.
-- modo "oculto": solo fuera de la vista del jugador.
local function buscar_pos(ppos, rmin, rmax, modo)
    local ojo = {x = ppos.x, y = ppos.y + 1.5, z = ppos.z}
    for _ = 1, 40 do
        local ang = math.random() * math.pi * 2
        local r = rmin + math.random() * (rmax - rmin)
        local bx = math.floor(ppos.x + math.cos(ang) * r + 0.5)
        local bz = math.floor(ppos.z + math.sin(ang) * r + 0.5)
        for dy = 4, -6, -1 do
            local suelo = {x = bx, y = math.floor(ppos.y + 0.5) + dy - 1, z = bz}
            local n = minetest.get_node(suelo).name
            local def = minetest.registered_nodes[n]
            local pies = {x = bx, y = suelo.y + 1, z = bz}
            if n ~= "ignore" and def and def.walkable and def.liquidtype == "none"
            and libre(pies) and libre({x = bx, y = pies.y + 1, z = bz})
            and libre({x = bx, y = pies.y + 2, z = bz}) then
                local ok = true
                if modo then
                    ok = not minetest.line_of_sight(ojo, {x = bx, y = pies.y + 1.5, z = bz})
                end
                if ok and modo == "calle" then
                    local luz = minetest.get_natural_light(pies, 0.5)
                    ok = luz and luz >= 14
                end
                if ok then
                    return {x = bx + 0.5, y = pies.y, z = bz + 0.5}
                end
                break
            end
        end
    end
    return nil
end

-- ============================================================================
-- 4. MOVIMIENTO
-- ============================================================================
local function animar(self, rango, fps)
    if self._anim == rango.x then return end
    self._anim = rango.x
    self.object:set_animation(rango, fps, 0, true)
end

-- Aplica la silueta. Overrides relativos (absolute = false por defecto): se
-- suman / multiplican a la animacion, asi que caminar y sentarse siguen
-- funcionando. De pie la cadera sube lo que se alargaron las piernas para que
-- no se entierren; sentado vuelve al suelo (las piernas quedan estiradas
-- hacia adelante) para que no flote.
local function cuerpo(self, sentado)
    local o = self.object
    if not o.set_bone_override then return end   -- motor < 5.9: silueta normal
    local clave = sentado and "s" or "p"
    if self._cuerpo == clave then return end
    local primera = self._cuerpo == nil
    self._cuerpo = clave
    if primera then
        local pierna = {scale = {vec = {x = 0.85, y = PIERNA, z = 0.85}}}
        local brazo  = {scale = {vec = {x = GROSOR_BRAZO, y = BRAZO, z = GROSOR_BRAZO}}}
        o:set_bone_override("Leg_Right", pierna)
        o:set_bone_override("Leg_Left", pierna)
        o:set_bone_override("Arm_Right", brazo)
        o:set_bone_override("Arm_Left", brazo)
        o:set_bone_override("Body", {scale = {vec = {x = TORSO_ANCHO, y = 1, z = 0.85}}})
        o:set_bone_override("Head", {scale = {vec = {x = 1, y = CABEZA_LARGA, z = 1}}})
    end
    o:set_bone_override("Body_Control", {position = {
        vec = {x = 0, y = sentado and 0 or CADERA * (PIERNA - 1), z = 0},
        interpolation = 0.3,
    }})
end

-- La velocidad horizontal se lleva en el propio mob (_vx/_vz) y NO se lee de
-- get_velocity(). Motivo: mcl_mobs multiplica la velocidad horizontal por 0.7
-- en CADA paso, antes de do_custom (check_death_and_slow_mob, physics.lua:247).
-- Acelerando desde ese valor ya frenado, el tope real quedaba en ~4,2 n/s en
-- vez de 6,5: mas lento que un jugador corriendo, y el anti-atasco lo
-- teletransportaba cada 1,5 s (lo que se veia en produccion el 2026-11-10).
-- Como el motor mueve la entidad con lo que fijamos al final del paso, llevar
-- la cuenta aparte esquiva el freno por completo.
local function empujar(self, dirx, dirz, pedida, dtime)
    local vx, vz = self._vx or 0, self._vz or 0
    local dx, dz = dirx * pedida - vx, dirz * pedida - vz
    local dif = math.sqrt(dx * dx + dz * dz)
    local paso = ACELERACION * dtime
    if dif > paso and dif > 0 then
        dx, dz = dx * (paso / dif), dz * (paso / dif)
    end
    vx, vz = vx + dx, vz + dz
    self._vx, self._vz = vx, vz
    local v = self.object:get_velocity() or {x = 0, y = 0, z = 0}
    self.object:set_velocity({x = vx, y = v.y, z = vz})
end

local function frenar(self)
    self._vx, self._vz = 0, 0
    local v = self.object:get_velocity() or {x = 0, y = 0, z = 0}
    self.object:set_velocity({x = 0, y = v.y, z = 0})
end

-- Cuanto avanzo de verdad desde el paso anterior (n/s). Es lo que delata un
-- choque contra una pared, aunque la velocidad pedida siga alta.
local function avance_real(self, pos, dtime)
    local prev = self._prev
    self._prev = {x = pos.x, y = pos.y, z = pos.z}
    if not prev or dtime <= 0 then return 0 end
    local dx, dz = pos.x - prev.x, pos.z - prev.z
    return math.sqrt(dx * dx + dz * dz) / dtime
end

local function en_suelo(pos)
    local def = minetest.registered_nodes[
        minetest.get_node({x = pos.x, y = pos.y - 0.2, z = pos.z}).name]
    return def and def.walkable
end

local function mirar_hacia(self, pos, objetivo, delay)
    local dx, dz = objetivo.x - pos.x, objetivo.z - pos.z
    if dx ~= 0 or dz ~= 0 then
        self:set_yaw(math.atan2(dz, dx) - math.pi / 2, delay)
    end
end

-- ============================================================================
-- 5. ESTADOS: calma -> furia -> caza
-- ============================================================================
local function esfumar(self, pos)
    if pos then
        particulas(cabeza(pos), "valdivia_scp096_furia.png", 30, 0.5)
        sonar(S_SALTO, pos, 0.8, 24, 0.6)
    end
    vivos[self.object] = nil
    self.object:remove()
end

-- Alguien le vio la cara?
local function quien_lo_ve(self, pos)
    local cab = cabeza(pos)
    local cara = minetest.yaw_to_dir(self.object:get_yaw() or 0)
    for _, p in ipairs(minetest.get_connected_players()) do
        local ppos = p:get_pos()
        if p:get_hp() > 0 and vector.distance(ppos, pos) <= VISTA_MAX then
            local ojo = {x = ppos.x, y = ppos.y + (p:get_properties().eye_height or 1.47), z = ppos.z}
            local hacia = vector.subtract(cab, ojo)
            local d = vector.length(hacia)
            if d > 0.1 then
                local mirada = vector.dot(p:get_look_dir(), vector.divide(hacia, d))
                local horiz = vector.normalize({x = ojo.x - pos.x, y = 0, z = ojo.z - pos.z})
                local frente = cara.x * horiz.x + cara.z * horiz.z
                if mirada >= COS_MIRADA and frente >= COS_CARA
                and minetest.line_of_sight(ojo, cab) then
                    return p:get_player_name()
                end
            end
        end
    end
end

local function enfurecer(self, pos, nombre)
    self._estado = "furia"
    self._t = 0
    self._objetivo = nombre
    cooldown[nombre] = os.time()
    frenar(self)
    animar(self, ANIM_PARADO, 30)   -- se levanta
    sonar(S_GRITO, pos, 2.0, 80, 0.55)
    decir(nombre, "Le viste la cara.")
    avisar_cerca(pos, 64, "Un grito horrible retumba en la calle...", nombre)
    minetest.log("action", "[" .. modname .. "] " .. nombre .. " le vio la cara en " ..
        minetest.pos_to_string(vector.round(pos)))
end

local function atrapar(self, pos, player, nombre)
    if LETAL then
        player:set_hp(0, {type = "set_hp", from = "mod"})
        minetest.chat_send_all(minetest.colorize(COLOR,
            nombre .. " le vio la cara a SCP-096."))
    else
        player:set_hp(1, {type = "set_hp", from = "mod"})
        decir(nombre, "Te alcanzo... y se calmo. Esta vez sobreviviste.")
    end
    minetest.log("action", "[" .. modname .. "] alcanzo a " .. nombre)
    particulas({x = pos.x, y = pos.y + 1, z = pos.z}, "valdivia_scp096_furia.png", 60, 1)
    -- Zarpazo, y despues se vuelve a sentar a llorar un rato antes de irse.
    frenar(self)
    animar(self, ANIM_ZARPAZO, 30)
    self._estado = "fin"
    self._t = 0
end

local function fin(self, pos, dtime)
    self._t = self._t + dtime
    frenar(self)
    if self._t > 0.8 then animar(self, ANIM_SENTADO, 30) end
    if self._t > 6 then esfumar(self, pos) end
end

local function calma(self, pos, dtime)
    self._vida = (self._vida or 0) + dtime
    frenar(self)
    animar(self, ANIM_SENTADO, 30)

    -- Nadie cerca o se aburrio: se esfuma sin hacer ruido.
    if self._vida > VIDA_CALMA then esfumar(self, nil) return end
    self._chequeo_lejos = (self._chequeo_lejos or 0) + dtime
    if self._chequeo_lejos > 5 then
        self._chequeo_lejos = 0
        local alguien = false
        for _, p in ipairs(minetest.get_connected_players()) do
            if vector.distance(p:get_pos(), pos) < 90 then alguien = true break end
        end
        if not alguien then esfumar(self, nil) return end
    end

    -- Lagrimas y llanto.
    self._lagrima = (self._lagrima or 0) + dtime
    if self._lagrima > 0.8 then
        self._lagrima = 0
        particulas({x = pos.x, y = pos.y + 1.3, z = pos.z}, "valdivia_scp096_lagrima.png", 4, 0)
    end
    self._llanto = (self._llanto or 0) - dtime
    if self._llanto <= 0 then
        self._llanto = 6 + math.random() * 6
        sonar(S_LLANTO, pos, 0.5, 18, 0.5)
    end

    -- De vez en cuando gira la cabeza (y la cara) hacia otro lado.
    self._giro = (self._giro or 0) - dtime
    if self._giro <= 0 then
        self._giro = 10 + math.random() * 15
        self:set_yaw((self.object:get_yaw() or 0) + (math.random() - 0.5) * math.pi, 20)
    end

    self._mira = (self._mira or 0) + dtime
    if self._mira >= 0.25 then
        self._mira = 0
        local nombre = quien_lo_ve(self, pos)
        if nombre then enfurecer(self, pos, nombre) end
    end
end

local function furia(self, pos, dtime)
    self._t = self._t + dtime
    local player = minetest.get_player_by_name(self._objetivo or "")
    if not player then esfumar(self, pos) return end
    frenar(self)
    animar(self, ANIM_PARADO, 30)
    -- De pie, sacudiendo la cabeza y el torso de lado a lado mientras grita.
    local ppos = player:get_pos()
    local base = math.atan2(ppos.z - pos.z, ppos.x - pos.x) - math.pi / 2
    self:set_yaw(base + math.sin(self._t * 22) * 0.35, 0)

    self._gota = (self._gota or 0) + dtime
    if self._gota > 0.3 then
        self._gota = 0
        particulas(cabeza(pos), "valdivia_scp096_furia.png", 6, 1)
    end
    if self._t >= FURIA then
        self._estado = "caza"
        self._t = 0
        self._mejor, self._sin_acortar = nil, 0
        self._ruta, self._t_ruta, self._prev = nil, 0, nil
        sonar(S_GRITO, pos, 2.0, 80, 0.45)
        decir(self._objetivo, "CORRE.")
    end
end

local function caza(self, pos, dtime)
    self._t = self._t + dtime
    local nombre = self._objetivo
    local player = minetest.get_player_by_name(nombre or "")
    if not player or player:get_hp() <= 0 then esfumar(self, pos) return end
    if self._t > MAX_CAZA then
        decir(nombre, "Perdio tu rastro... por ahora.")
        esfumar(self, pos)
        return
    end

    local ppos = player:get_pos()
    local dist = vector.distance(pos, ppos)

    if dist <= DIST_ATRAPA and math.abs(ppos.y - pos.y) < 2.5 then
        atrapar(self, pos, player, nombre)
        return
    end

    -- Ultimo recurso: lleva mucho sin acortar distancia (o la victima se fue
    -- lejisimos) y NADIE lo esta mirando -> reaparece escondido, a media
    -- distancia, y sigue corriendo desde ahi. Nunca al lado ni a la vista.
    if not self._mejor or dist < self._mejor - 0.5 then
        self._mejor, self._sin_acortar = dist, 0
    else
        self._sin_acortar = (self._sin_acortar or 0) + dtime
    end
    if (self._sin_acortar > T_PERDIDO or dist > DIST_PERDIDO) then
        local ojo = {x = ppos.x, y = ppos.y + 1.5, z = ppos.z}
        if not minetest.line_of_sight(ojo, cabeza(pos)) then
            local destino = buscar_pos(ppos, 12, 20, "oculto")
            if destino then
                self.object:set_pos(destino)
                frenar(self)
                self._ruta, self._t_ruta, self._prev = nil, 0, nil
                minetest.log("action", "[" .. modname .. "] reubicado tras " .. nombre)
            end
            self._mejor, self._sin_acortar = nil, 0
            return
        end
    end

    -- Hacia donde correr: directo si lo ve (a la altura de las piernas y de
    -- la cabeza, para no embestir un muro bajo), si no por la ruta del A*.
    local meta = ppos
    local pies_a  = {x = pos.x,  y = pos.y + 0.6,  z = pos.z}
    local pies_b  = {x = ppos.x, y = ppos.y + 0.6, z = ppos.z}
    local directo = math.abs(ppos.y - pos.y) < 1.5
        and minetest.line_of_sight(pies_a, pies_b)
        and minetest.line_of_sight(vector.add(pies_a, {x = 0, y = 1.2, z = 0}),
                                   vector.add(pies_b, {x = 0, y = 1.2, z = 0}))
    if directo then
        self._ruta = nil
    else
        self._t_ruta = (self._t_ruta or 0) - dtime
        if not self._ruta or self._t_ruta <= 0 then
            self._t_ruta = RUTA_CADA
            self._ruta = minetest.find_path(vector.round({x = pos.x, y = pos.y + 0.1, z = pos.z}),
                vector.round({x = ppos.x, y = ppos.y + 0.1, z = ppos.z}),
                RUTA_BUSQUEDA, 1, 4, "A*_noprefetch")
            self._i_ruta = 2
        end
        if self._ruta then
            local w = self._ruta[self._i_ruta]
            while w and math.abs(w.x - pos.x) < 0.6 and math.abs(w.z - pos.z) < 0.6 do
                self._i_ruta = self._i_ruta + 1
                w = self._ruta[self._i_ruta]
            end
            if w then meta = w else self._ruta = nil end
        end
    end

    local dx, dz = meta.x - pos.x, meta.z - pos.z
    local largo = math.sqrt(dx * dx + dz * dz)
    mirar_hacia(self, pos, meta, 3)
    animar(self, ANIM_PASO, 30)
    local real = avance_real(self, pos, dtime)
    if largo > 0.05 then
        empujar(self, dx / largo, dz / largo, VELOCIDAD, dtime)
    end

    -- Salto: solo si el siguiente punto esta mas arriba, o si quiere correr y
    -- casi no avanza (choco con algo de 1-1,5 nodos). stepheight resuelve los
    -- escalones simples sin saltar.
    self._pausa_salto = math.max((self._pausa_salto or 0) - dtime, 0)
    local quiere = math.sqrt((self._vx or 0) ^ 2 + (self._vz or 0) ^ 2)
    if quiere > 2 and real < quiere * 0.3 then
        self._traba = (self._traba or 0) + dtime
    else
        self._traba = 0
    end
    local sube = meta.y > pos.y + 0.6 and largo < 1.6
    if (sube or self._traba > T_TRABA) and self._pausa_salto == 0 and en_suelo(pos) then
        self._traba, self._pausa_salto = 0, 0.6
        local v = self.object:get_velocity() or {x = 0, y = 0, z = 0}
        self.object:set_velocity({x = self._vx or v.x, y = SALTO_VEL, z = self._vz or v.z})
        -- Si sigue trabado tras saltar, que el A* busque otro camino ya.
        self._t_ruta = 0
    end

    self._grito = (self._grito or 0) + dtime
    if self._grito > 4 then
        self._grito = 0
        sonar(S_GRITO, pos, 1.5, 48, 0.5 + math.random() * 0.1)
    end
end

-- ============================================================================
-- 6. EL MOB
-- ============================================================================
local function registrar_mob()
    mcl_mobs.register_mob(ENTITY, {
        description = "SCP-096",
        type = "npc",
        spawn_class = "passive",
        passive = true,
        xp_min = 0,
        xp_max = 0,
        initial_properties = {
            hp_min = HP,
            hp_max = HP,
            collisionbox = {-0.3, -0.01, -0.3, 0.3, ALTO_COLISION, 0.3},
            static_save = false,
        },
        collisionbox = {-0.3, -0.01, -0.3, 0.3, ALTO_COLISION, 0.3},
        visual = "mesh",
        mesh = "mcl_armor_character.b3d",
        visual_size = {x = 1, y = ESCALA},
        textures = {{"valdivia_scp096_skin.png", "blank.png", "blank.png"}},
        makes_footstep_sound = true,
        walk_velocity = VELOCIDAD,
        run_velocity = VELOCIDAD,
        walk_chance = 0,
        jump = false,
        stepheight = 1.1,
        fear_height = 0,
        fall_damage = 0,
        view_range = VISTA_MAX,
        drops = {},
        can_despawn = false,
        armor_groups = {immortal = 1, fleshy = 0},
        animation = {
            stand_start = 81, stand_end = 160, stand_speed = 30,
            walk_start = 168, walk_end = 187, walk_speed = 30,
            run_start = 168, run_end = 187, run_speed = 30,
        },

        do_custom = function(self, dtime)
            -- Huerfano (no lo creo spawnear() en esta sesion): fuera.
            if not vivos[self.object] then
                self._sin_dueno = (self._sin_dueno or 0) + dtime
                if self._sin_dueno > 1 then self.object:remove() end
                return false
            end
            if self.object:get_hp() < HP then
                self.object:set_hp(HP)
                self.object:set_armor_groups({immortal = 1, fleshy = 0})
            end
            local pos = self.object:get_pos()
            if not pos then return false end

            -- Sentado en calma y al final; de pie al gritar y al correr.
            local est = self._estado or "calma"
            cuerpo(self, est == "calma" or (est == "fin" and (self._t or 0) > 0.8))

            if self._estado == "furia" then
                furia(self, pos, dtime)
            elseif self._estado == "caza" then
                caza(self, pos, dtime)
            elseif self._estado == "fin" then
                fin(self, pos, dtime)
            else
                calma(self, pos, dtime)
            end
            return false   -- corta do_states de mcl_mobs (api.lua:398)
        end,

        -- Pegarle tambien lo enfurece.
        do_punch = function(self, puncher)
            self.object:set_armor_groups({immortal = 1, fleshy = 0})
            self.object:set_hp(HP)
            self.health = HP
            if (self._estado or "calma") == "calma" and vivos[self.object]
            and puncher and puncher:is_player() then
                enfurecer(self, self.object:get_pos(), puncher:get_player_name())
            end
            return false
        end,
    })
end

-- ============================================================================
-- 7. APARECER
-- ============================================================================
local function spawnear(pos, de_espaldas_a)
    local obj = minetest.add_entity(pos, ENTITY)
    if not obj then return nil end
    local le = obj:get_luaentity()
    if not le then obj:remove() return nil end
    vivos[obj] = true
    le._estado = "calma"
    le._vida = 0
    le._llanto = 1
    le._giro = 10 + math.random() * 10
    -- Cadencia de piernas: mcl_mobs da walk_speed fps a run_velocity (6,5 n/s);
    -- un jugador anda a ~7 fps por n/s, asi que a 6,5 n/s tocan ~45 fps.
    -- No se puede poner en la definicion (register_mob lo fija en 1).
    le.frame_speed_multiplier = 1.5
    local yaw = math.random() * math.pi * 2
    if de_espaldas_a then
        local dx, dz = pos.x - de_espaldas_a.x, pos.z - de_espaldas_a.z
        yaw = math.atan2(dz, dx) - math.pi / 2
    end
    obj:set_yaw(yaw)
    minetest.log("action", "[" .. modname .. "] aparecio en " ..
        minetest.pos_to_string(vector.round(pos)))
    return obj
end

local function es_de_noche()
    local t = minetest.get_timeofday()
    return t < 0.21 or t > 0.79
end

local reloj = 0
minetest.register_globalstep(function(dtime)
    reloj = reloj + dtime
    if reloj < INTERVALO then return end
    reloj = 0
    if not auto_activo() or not es_de_noche() then return end
    if contar() >= MAX_VIVOS or math.random() > PROB then return end

    local candidatos = {}
    for _, p in ipairs(minetest.get_connected_players()) do
        local n = p:get_player_name()
        if p:get_hp() > 0 and not (cooldown[n] and os.time() - cooldown[n] < COOLDOWN) then
            table.insert(candidatos, p)
        end
    end
    if #candidatos == 0 then return end
    local p = candidatos[math.random(#candidatos)]
    local pos = buscar_pos(p:get_pos(), 20, 34, "calle")
    if pos then
        cooldown[p:get_player_name()] = os.time()
        spawnear(pos, nil)
    end
end)

minetest.register_on_leaveplayer(function(player)
    local nombre = player:get_player_name()
    for obj in pairs(vivos) do
        local le = obj:get_luaentity()
        if le and le._objetivo == nombre then
            vivos[obj] = nil
            obj:remove()
        end
    end
end)

-- ============================================================================
-- 8. COMANDOS DE ADMIN
-- ============================================================================
minetest.register_chatcommand("scp096", {
    params = "[jugador | limpiar | auto on|off | info]",
    description = "SCP-096: hacerlo aparecer cerca de alguien, retirarlo o (des)activar su aparicion nocturna",
    privs = {server = true},
    func = function(name, param)
        local a, b = (param or ""):match("^(%S*)%s*(%S*)")
        if a == "limpiar" then
            local n = 0
            for obj in pairs(vivos) do
                if obj:get_pos() then obj:remove() n = n + 1 end
                vivos[obj] = nil
            end
            return true, "SCP-096 retirados: " .. n
        elseif a == "auto" then
            if b == "on" or b == "off" then
                storage:set_string("auto", b == "on" and "1" or "0")
            end
            return true, "Aparicion nocturna: " .. (auto_activo() and "activada" or "desactivada")
        elseif a == "info" then
            return true, string.format("Vivos: %d | auto: %s | letal: %s | noche: %s",
                contar(), auto_activo() and "si" or "no", LETAL and "si" or "no",
                es_de_noche() and "si" or "no")
        end

        local objetivo = (a ~= "" and a) or name
        local player = minetest.get_player_by_name(objetivo)
        if not player then return false, "Ese jugador no esta conectado." end
        local ppos = player:get_pos()
        local pos = buscar_pos(ppos, 8, 14, nil)
        if not pos then return false, "No hay espacio libre alrededor de " .. objetivo .. "." end
        -- De espaldas, para que no se enfurezca apenas aparece.
        if spawnear(pos, ppos) then
            return true, "SCP-096 aparecio cerca de " .. objetivo .. " (de espaldas). No le mires la cara."
        end
        return false, "No se pudo crear la entidad."
    end,
})

-- ============================================================================
-- 9. CARGA
-- ============================================================================
if minetest.get_modpath("mcl_mobs") and mcl_mobs and mcl_mobs.register_mob then
    registrar_mob()
    -- warning: con debug_log_level = warning un "action" no se ve en docker logs.
    minetest.log("warning", "[" .. modname .. "] Loaded successfully (letal=" ..
        tostring(LETAL) .. ")")
else
    minetest.log("error", "[" .. modname .. "] mcl_mobs no disponible; SCP-096 no se registro.")
end
