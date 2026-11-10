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
local DIST_LEJOS   = 30       -- si la victima se aleja mas, reaparece cerca
local T_ATASCO     = 1.5      -- segundos sin acercarse antes de reubicarlo
local DIST_ATRAPA  = 1.7
local ESCALA       = 1.3      -- mas alto que un jugador
local ALTO         = 1.94 * ESCALA
local ACELERACION  = 14
local SALTO_VEL    = 6.5
local T_TRABA      = 0.4
local HP           = 10000

local ENTITY = "valdivia_scp096:scp096"
local COLOR  = "#B03030"

local ANIM_SENTADO = {x = 81,  y = 160}
local ANIM_PASO    = {x = 168, y = 187}
local ANIM_FURIA   = {x = 189, y = 198}  -- "minar": brazos agitandose

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

-- Suelo firme + 3 de aire. Con `calle`, ademas cielo abierto (luz natural a
-- mediodia >= 14: el mismo truco de valdivia_transeuntes para no aparecer
-- dentro de un edificio ni en la mina) y fuera de la vista del jugador.
local function buscar_pos(ppos, rmin, rmax, calle)
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
                if calle then
                    local luz = minetest.get_natural_light(pies, 0.5)
                    ok = luz and luz >= 14
                        and not minetest.line_of_sight(ojo, {x = bx + 0.5, y = pies.y + 1.5, z = bz + 0.5})
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
-- 4. MOVIMIENTO (igual que valdivia_policia, seccion 4bis)
-- ============================================================================
local function animar(self, rango, fps)
    if self._anim == rango.x then return end
    self._anim = rango.x
    self.object:set_animation(rango, fps, 0, true)
end

local function empujar(self, dirx, dirz, pedida, dtime)
    local v = self.object:get_velocity() or {x = 0, y = 0, z = 0}
    local dx, dz = dirx * pedida - v.x, dirz * pedida - v.z
    local dif = math.sqrt(dx * dx + dz * dz)
    local paso = ACELERACION * dtime
    if dif > paso and dif > 0 then
        dx, dz = dx * (paso / dif), dz * (paso / dif)
    end
    local nx, nz = v.x + dx, v.z + dz
    self.object:set_velocity({x = nx, y = v.y, z = nz})
    return math.sqrt(nx * nx + nz * nz)
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
    self.object:set_velocity({x = 0, y = 0, z = 0})
    animar(self, ANIM_FURIA, 30)
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
    esfumar(self, pos)
end

local function calma(self, pos, dtime)
    self._vida = (self._vida or 0) + dtime
    empujar(self, 0, 0, 0, dtime)
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
    empujar(self, 0, 0, 0, dtime)
    animar(self, ANIM_FURIA, 30)
    mirar_hacia(self, pos, player:get_pos(), 4)

    self._gota = (self._gota or 0) + dtime
    if self._gota > 0.3 then
        self._gota = 0
        particulas(cabeza(pos), "valdivia_scp096_furia.png", 6, 1)
    end
    if self._t >= FURIA then
        self._estado = "caza"
        self._t = 0
        self._mejor, self._atasco = nil, 0
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

    -- Nada lo detiene: si se traba o se queda atras, reaparece al lado.
    self._mejor = math.min(self._mejor or dist, dist)
    self._atasco = (dist <= self._mejor + 0.5) and 0 or (self._atasco + dtime)
    if dist > DIST_LEJOS or self._atasco > T_ATASCO then
        local destino = buscar_pos(ppos, 4, 7, false)
        if destino then
            sonar(S_SALTO, pos, 1.0, 32, 0.6)
            self.object:set_pos(destino)
            self.object:set_velocity({x = 0, y = 0, z = 0})
            sonar(S_SALTO, destino, 1.0, 32, 0.6)
        end
        self._mejor, self._atasco = nil, 0
        return
    end

    local dx, dz = ppos.x - pos.x, ppos.z - pos.z
    local largo = math.sqrt(dx * dx + dz * dz)
    mirar_hacia(self, pos, ppos, 2)
    animar(self, ANIM_PASO, 30)
    if largo > 0 then
        local real = empujar(self, dx / largo, dz / largo, VELOCIDAD, dtime)
        self._pausa_salto = math.max((self._pausa_salto or 0) - dtime, 0)
        self._traba = (real < VELOCIDAD * 0.35) and ((self._traba or 0) + dtime) or 0
        if self._traba > T_TRABA and self._pausa_salto == 0 and en_suelo(pos) then
            self._traba, self._pausa_salto = 0, 0.6
            local v = self.object:get_velocity()
            self.object:set_velocity({x = v.x, y = SALTO_VEL, z = v.z})
        end
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
            collisionbox = {-0.3, -0.01, -0.3, 0.3, ALTO, 0.3},
            static_save = false,
        },
        collisionbox = {-0.3, -0.01, -0.3, 0.3, ALTO, 0.3},
        visual = "mesh",
        mesh = "mcl_armor_character.b3d",
        visual_size = {x = 0.9, y = ESCALA},
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

            if self._estado == "furia" then
                furia(self, pos, dtime)
            elseif self._estado == "caza" then
                caza(self, pos, dtime)
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
    local pos = buscar_pos(p:get_pos(), 20, 34, true)
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
        local pos = buscar_pos(ppos, 8, 14, false)
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
