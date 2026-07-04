-- valdivia_discoteca: discoteca interactiva en la ciudad de Valdivia (30001)
--
-- Al entrar a la zona configurada, arranca musica per-player en bucle, se
-- encienden luces de colores sobre la pista y (si el admin los coloco) un DJ
-- y varios bailarines con coreografias (pasos laterales, saltos, agachadas,
-- brazos arriba) animan el lugar. Todo se apaga cuando el ultimo jugador
-- sale de la zona.
--
-- El modelo humano y los skins provienen de wetlands_npcs; los tracks de
-- wetlands-music. Ambos estan activos en Valdivia (ver luanti-valdivia.conf).

local modname = minetest.get_current_modname()
local storage = minetest.get_mod_storage()

-- ===========================================================================
-- CONFIGURACION
-- ===========================================================================

-- Track que suena en la discoteca. Es el nombre del .ogg SIN extension,
-- servido por wetlands-music. Para usar un rave 8-bit propio: dejar el .ogg en
-- valdivia_discoteca/sounds/ y cambiar esta constante.
local MUSIC_TRACK = "wetlands_music_groovy_goblins"
local MUSIC_GAIN = 0.9
local POLL_INTERVAL = 0.5         -- cada cuanto se revisa la posicion del jugador
local LIGHT_INTERVAL = 2.0        -- cada cuanto cambian de color las luces
local COLLISIONBOX = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3}  -- del registry humano

-- Colchon vertical del AABB de la zona. get_pos() devuelve los PIES del
-- jugador, que al caminar por el piso quedan ~0.5 nodos por debajo del y
-- redondeado que guardo /discoteca zona_min (por eso antes habia que saltar o
-- subirse a la mesa del DJ para activar la musica). El colchon de arriba
-- ademas evita que un salto corte el stream.
local ZONE_Y_PAD_BELOW = 2
local ZONE_Y_PAD_ABOVE = 3

-- Skins validos para el modelo humano (UV 64x32 de player skin).
-- Servidos por mcl_custom_world_skins/_world_folder_media desde server/skins/.
local DJ_SKIN = "wetlands_npc_mandalorian.png"  -- casco = look de DJ
-- Skins convertidos a 64x32 (crop del top-half de los originales 64x64 de Minecraft).
-- Guardados en textures/ de este mod para evitar rutas con caracteres especiales.
local DANCER_SKINS = {
    -- Rave/fiesta
    "valdivia_discoteca_dancer_rave1.png",
    "valdivia_discoteca_dancer_rave2.png",
    "valdivia_discoteca_dancer_bunny.png",
    -- Coloridos/festivos
    "valdivia_discoteca_dancer_summer.png",
    "valdivia_discoteca_dancer_flourish.png",
    "valdivia_discoteca_dancer_pinkie.png",
    "valdivia_discoteca_dancer_yellow.png",
    "valdivia_discoteca_dancer_firecracker.png",
    -- Urbano/hipster
    "valdivia_discoteca_dancer_hipster1.png",
    "valdivia_discoteca_dancer_hipster2.png",
    "valdivia_discoteca_dancer_indie.png",
    -- Clasico
    "wetlands_npc_leia.png",
}

-- Rangos de frames del modelo humano (wetlands_npc_human.b3d = mcl_armor_character.b3d).
local ANIMS = {
    stand     = { frames = {0, 79},    speed = 30 },
    sit       = { frames = {81, 160},  speed = 30 },
    walk      = { frames = {168, 187}, speed = 45 },
    mine      = { frames = {189, 198}, speed = 35 },
    walk_mine = { frames = {200, 219}, speed = 45 },
}
local DJ_ANIM = { frames = {189, 198}, speed = 25 }  -- brazo oscilando en la consola

-- Poses via bone override (radianes). El modelo no tiene frames de sneak:
-- VoxeLibre agacha al jugador rotando Body_Control, aca hacemos lo mismo.
local BODY_CROUCH = {x = 0.5, y = 0, z = 0}          -- torso inclinado ~29 grados
local ARM_UP_R    = {x = math.pi * 0.95, y = 0, z = 0.2}   -- brazo derecho arriba
local ARM_UP_L    = {x = math.pi * 0.95, y = 0, z = -0.2}  -- brazo izquierdo arriba

local JUMP_GRAVITY = 14  -- saltos cortos y rapidos (arco = g*dur^2/8)

-- Coreografias: cada rutina es una lista de pasos que se repite en bucle.
-- Campos por paso:
--   anim   = clave en ANIMS
--   dur    = duracion en segundos
--   at     = {x,z} donde TERMINA el paso, relativo al punto donde se coloco el
--            bailarin y a su orientacion inicial (x = derecha+, z = adelante+).
--            El bailarin se desliza hacia ahi durante el paso (autocorrige deriva).
--   crouch = true -> agachado (torso inclinado) durante el paso
--   arm    = "right" | "left" | "both" -> brazo(s) levantado(s)
--   jump   = true -> un salto que dura todo el paso
--   turn   = radianes que gira al iniciar el paso (giro seco, estilo baile)
-- Las rutinas con 'at' necesitan ~1 nodo libre alrededor del bailarin.
local DANCE_ROUTINES = {
    -- paso agachado a la izquierda, se para con brazos arriba, agachado a la derecha
    { name = "agachadito", steps = {
        { anim = "walk",  dur = 0.9, at = {x = -0.8, z = 0}, crouch = true },
        { anim = "stand", dur = 0.5, at = {x = -0.8, z = 0}, arm = "both" },
        { anim = "walk",  dur = 0.9, at = {x = 0.8, z = 0}, crouch = true },
        { anim = "stand", dur = 0.5, at = {x = 0.8, z = 0}, arm = "both" },
    }},
    -- salta levantando una mano, alternando derecha e izquierda
    { name = "saltarin", steps = {
        { anim = "stand", dur = 0.6, jump = true, arm = "right" },
        { anim = "mine",  dur = 0.4 },
        { anim = "stand", dur = 0.6, jump = true, arm = "left" },
        { anim = "mine",  dur = 0.4 },
    }},
    -- gira en cuartos de vuelta dando pasitos y cierra el giro con un salto
    { name = "girador", steps = {
        { anim = "walk", dur = 0.5, turn = math.pi / 2 },
        { anim = "walk", dur = 0.5, turn = math.pi / 2 },
        { anim = "walk", dur = 0.5, turn = math.pi / 2 },
        { anim = "walk_mine", dur = 0.7, turn = math.pi / 2, jump = true, arm = "both" },
    }},
    -- adelante y atras, pasando agachado por el centro
    { name = "vaiven", steps = {
        { anim = "walk", dur = 0.8, at = {x = 0, z = 0.8} },
        { anim = "walk", dur = 0.8, at = {x = 0, z = 0}, crouch = true },
        { anim = "walk_mine", dur = 0.8, at = {x = 0, z = -0.8}, arm = "right" },
        { anim = "walk", dur = 0.8, at = {x = 0, z = 0}, crouch = true },
    }},
    -- dos saltos con las dos manos arriba y una bajadita agachado
    { name = "manos_arriba", steps = {
        { anim = "stand", dur = 0.5, jump = true, arm = "both" },
        { anim = "stand", dur = 0.5, jump = true, arm = "both" },
        { anim = "mine",  dur = 0.8, crouch = true },
        { anim = "stand", dur = 0.4 },
    }},
}

local ROUTINE_BY_NAME = {}
local ROUTINE_NAMES = {}
for i, r in ipairs(DANCE_ROUTINES) do
    ROUTINE_BY_NAME[r.name] = i
    ROUTINE_NAMES[#ROUTINE_NAMES + 1] = r.name
end

-- Colores de las luces de discoteca.
local DISCO_COLORS = {"#FF0044", "#00AAFF", "#00FF88", "#FF8800", "#AA00FF", "#FFEE00"}

-- ===========================================================================
-- ESTADO PERSISTENTE (zona + emisor)
-- ===========================================================================

local ZONE = { min = nil, max = nil }  -- AABB {x,y,z}
local DJ_POS = nil                     -- punto de emision de audio; fallback = centro de zona

local function save_config()
    storage:set_string("zone", minetest.serialize({min = ZONE.min, max = ZONE.max}))
    storage:set_string("dj_pos", DJ_POS and minetest.serialize(DJ_POS) or "")
end

local function load_config()
    local z = storage:get_string("zone")
    if z and z ~= "" then
        local t = minetest.deserialize(z)
        if t then ZONE.min, ZONE.max = t.min, t.max end
    end
    local d = storage:get_string("dj_pos")
    if d and d ~= "" then DJ_POS = minetest.deserialize(d) end
end
load_config()

-- Normaliza la zona para que min sea realmente el minimo por eje.
local function normalize_zone()
    if not (ZONE.min and ZONE.max) then return end
    local a, b = ZONE.min, ZONE.max
    ZONE.min = {x = math.min(a.x, b.x), y = math.min(a.y, b.y), z = math.min(a.z, b.z)}
    ZONE.max = {x = math.max(a.x, b.x), y = math.max(a.y, b.y), z = math.max(a.z, b.z)}
end

local function zone_ready()
    return ZONE.min ~= nil and ZONE.max ~= nil
end

local function zone_center()
    return {
        x = (ZONE.min.x + ZONE.max.x) / 2,
        y = (ZONE.min.y + ZONE.max.y) / 2,
        z = (ZONE.min.z + ZONE.max.z) / 2,
    }
end

local function emitter_pos()
    return DJ_POS or (zone_ready() and zone_center()) or nil
end

-- ===========================================================================
-- ENTIDADES: DJ y bailarines (planas, sin FSM de mcl_mobs)
-- ===========================================================================
-- IMPORTANTE: la animacion se fija UNA sola vez en on_activate. Re-fijarla en
-- on_step la reiniciaria al primer frame cada tick (modelo congelado).

minetest.register_entity(modname .. ":dj", {
    initial_properties = {
        visual = "mesh",
        mesh = "wetlands_npc_human.b3d",
        textures = {DJ_SKIN, "blank.png", "blank.png"},
        visual_size = {x = 1, y = 1},
        collisionbox = COLLISIONBOX,
        physical = false,
        pointable = true,
        static_save = true,
        infotext = "DJ de la Discoteca de Valdivia",
    },
    _yaw = 0,
    on_activate = function(self, staticdata)
        local data = (staticdata ~= "") and minetest.deserialize(staticdata) or {}
        self._yaw = data.yaw or 0
        self.object:set_yaw(self._yaw)
        self.object:set_animation({x = DJ_ANIM.frames[1], y = DJ_ANIM.frames[2]},
            DJ_ANIM.speed, 0, true)
    end,
    get_staticdata = function(self)
        return minetest.serialize({yaw = self._yaw})
    end,
    on_punch = function() return true end,  -- indestructible (anti-grief)
})

-- Aplica las poses de hueso de un paso (agachado / brazos arriba).
-- absolute=true hace que el override le gane a la animacion de frames en ese
-- hueso; pasar {} lo limpia y la animacion recupera el control.
local function apply_pose(obj, step)
    if not obj.set_bone_override then return end  -- engine < 5.9: baila sin poses
    local function rot(bone, vec)
        if vec then
            obj:set_bone_override(bone, {
                rotation = {vec = vec, absolute = true, interpolation = 0.2},
            })
        else
            obj:set_bone_override(bone, {})
        end
    end
    rot("Body_Control", step.crouch and BODY_CROUCH or nil)
    rot("Arm_Right_Pitch_Control", (step.arm == "right" or step.arm == "both") and ARM_UP_R or nil)
    rot("Arm_Left_Pitch_Control", (step.arm == "left" or step.arm == "both") and ARM_UP_L or nil)
end

-- Punto 'at' de un paso (coords locales al yaw inicial) -> coords de mundo.
local function step_target(self, at)
    local cy, sy = math.cos(self._yaw), math.sin(self._yaw)
    return {
        x = self._anchor.x + at.x * cy - at.z * sy,
        z = self._anchor.z + at.x * sy + at.z * cy,
    }
end

local function begin_step(self, idx)
    local step = self._routine.steps[idx]
    self._step_i = idx
    self._t = 0
    local obj = self.object

    if step.turn then
        self._yaw_off = (self._yaw_off + step.turn) % (2 * math.pi)
        obj:set_yaw(self._yaw + self._yaw_off)
    end

    -- Re-fijar la animacion en cada paso la sincroniza con el "beat" de la rutina
    local a = ANIMS[step.anim]
    obj:set_animation({x = a.frames[1], y = a.frames[2]}, a.speed, 0, true)
    apply_pose(obj, step)

    local pos = obj:get_pos()
    if not pos then return end

    -- Cada paso arranca con los pies en el y del anclaje (los saltos despegan
    -- del suelo y el desfase de un tick al aterrizar no se acumula)
    if pos.y ~= self._anchor.y then
        obj:set_pos({x = pos.x, y = self._anchor.y, z = pos.z})
        pos.y = self._anchor.y
    end

    local vx, vz = 0, 0
    if step.at then
        local target = step_target(self, step.at)
        vx = (target.x - pos.x) / step.dur
        vz = (target.z - pos.z) / step.dur
    end
    local vy, ay = 0, 0
    if step.jump then
        ay = -JUMP_GRAVITY
        vy = JUMP_GRAVITY * step.dur / 2  -- arco simetrico: despega y aterriza en el paso
    end
    obj:set_velocity({x = vx, y = vy, z = vz})
    obj:set_acceleration({x = 0, y = ay, z = 0})
end

minetest.register_entity(modname .. ":dancer", {
    initial_properties = {
        visual = "mesh",
        mesh = "wetlands_npc_human.b3d",
        textures = {DANCER_SKINS[1], "blank.png", "blank.png"},
        visual_size = {x = 1, y = 1},
        collisionbox = COLLISIONBOX,
        physical = false,
        pointable = true,
        static_save = true,
        infotext = "Bailarin de la Discoteca de Valdivia",
    },
    _skin = nil,
    _style = nil,
    _yaw = 0,
    on_activate = function(self, staticdata)
        local data = (staticdata ~= "") and minetest.deserialize(staticdata) or {}
        self._skin = data.skin or DANCER_SKINS[math.random(#DANCER_SKINS)]
        self._style = data.style or math.random(#DANCE_ROUTINES)
        if self._style > #DANCE_ROUTINES then  -- staticdata de una version anterior
            self._style = math.random(#DANCE_ROUTINES)
        end
        self._yaw = data.yaw or 0
        self._anchor = data.anchor or vector.new(self.object:get_pos())
        self._routine = DANCE_ROUTINES[self._style]
        self._yaw_off = 0
        self.object:set_properties({textures = {self._skin, "blank.png", "blank.png"}})
        self.object:set_yaw(self._yaw)
        begin_step(self, 1)
    end,
    on_step = function(self, dtime)
        if not self._routine then return end
        self._t = self._t + dtime
        local step = self._routine.steps[self._step_i]
        if self._t >= step.dur then
            begin_step(self, self._step_i % #self._routine.steps + 1)
        end
    end,
    get_staticdata = function(self)
        return minetest.serialize({
            skin = self._skin, style = self._style,
            yaw = self._yaw, anchor = self._anchor,
        })
    end,
    on_punch = function() return true end,  -- indestructible (anti-grief)
})

-- ===========================================================================
-- MUSICA POR JUGADOR (to_player = volumen constante en toda la zona)
-- ===========================================================================
-- Cada jugador que entra recibe su propio stream en bucle a volumen fijo,
-- independientemente de donde este dentro del salon. No hay atenuacion por
-- distancia. Al salir, el stream hace fade-out y se detiene.

local player_handles = {}  -- name -> sound handle activo

local function start_music_for(name)
    if player_handles[name] then return end
    player_handles[name] = minetest.sound_play(MUSIC_TRACK, {
        to_player = name,
        loop = true,
        gain = MUSIC_GAIN,
    })
end

local function stop_music_for(name)
    if not player_handles[name] then return end
    local h = player_handles[name]
    player_handles[name] = nil
    minetest.sound_fade(h, -0.8, 0.0)
    minetest.after(1.5, function() minetest.sound_stop(h) end)
end

-- ===========================================================================
-- LUCES DE DISCOTECA (particulas con glow, ciclando colores)
-- ===========================================================================

local players_in_disco = {}
local light_spawners = {}
local light_active = false

local function has_players()
    return next(players_in_disco) ~= nil
end

local cycle_lights  -- forward-declare para la recursion via minetest.after
cycle_lights = function()
    if not has_players() or not zone_ready() then
        -- Apagar: limpiar spawners y salir
        for _, id in ipairs(light_spawners) do
            minetest.delete_particlespawner(id)
        end
        light_spawners = {}
        light_active = false
        return
    end

    local c = zone_center()
    local ceiling_y = ZONE.max.y - 1

    -- CREAR nuevos spawners ANTES de borrar los viejos: sin gap visual.
    -- 5 haces (era 3) para mayor densidad de luces.
    local new_spawners = {}
    for _ = 1, 5 do
        local col = DISCO_COLORS[math.random(#DISCO_COLORS)]
        local ox = math.random(-5, 5)
        local oz = math.random(-5, 5)
        local id = minetest.add_particlespawner({
            amount = 40,
            time = LIGHT_INTERVAL + 0.5,  -- viven mas que el intervalo → overlap garantizado
            minpos = {x = c.x + ox - 0.3, y = ceiling_y, z = c.z + oz - 0.3},
            maxpos = {x = c.x + ox + 0.3, y = ceiling_y, z = c.z + oz + 0.3},
            minvel = {x = -0.4, y = -5, z = -0.4},
            maxvel = {x = 0.4,  y = -1, z = 0.4},
            minexptime = 0.6,
            maxexptime = 1.8,
            minsize = 1.5,
            maxsize = 4,
            texture = "valdivia_discoteca_light.png^[colorize:" .. col .. ":200",
            glow = 14,
            collisiondetection = false,
        })
        table.insert(new_spawners, id)
    end

    -- Borrar spawners del ciclo anterior DESPUES de crear los nuevos
    for _, id in ipairs(light_spawners) do
        minetest.delete_particlespawner(id)
    end
    light_spawners = new_spawners

    minetest.after(LIGHT_INTERVAL, cycle_lights)
end

local function start_lights()
    if light_active then return end
    light_active = true
    cycle_lights()
end

-- ===========================================================================
-- ENTRAR / SALIR DE LA ZONA
-- ===========================================================================

local function on_enter(name)
    if valdivia_music then valdivia_music.pause(name) end
    start_music_for(name)
    start_lights()
    minetest.chat_send_player(name, minetest.colorize("#FF66CC",
        "\u{266A} Bienvenido a la Discoteca de Valdivia \u{266A}"))
end

local function on_exit(name)
    stop_music_for(name)
    if valdivia_music then valdivia_music.resume(name) end
    -- Las luces se auto-detienen en el proximo cycle_lights cuando has_players()==false
end

-- ===========================================================================
-- GLOBALSTEP: deteccion de zona (patron reutilizado de pvp_arena)
-- ===========================================================================

local poll_timer = 0
minetest.register_globalstep(function(dtime)
    poll_timer = poll_timer + dtime
    if poll_timer < POLL_INTERVAL then return end
    poll_timer = 0
    if not zone_ready() then return end

    for _, p in ipairs(minetest.get_connected_players()) do
        local name = p:get_player_name()
        local pos = p:get_pos()
        local inside =
            pos.x >= ZONE.min.x and pos.x <= ZONE.max.x and
            pos.y >= ZONE.min.y - ZONE_Y_PAD_BELOW and
            pos.y <= ZONE.max.y + ZONE_Y_PAD_ABOVE and
            pos.z >= ZONE.min.z and pos.z <= ZONE.max.z
        local was = players_in_disco[name]
        if inside and not was then
            players_in_disco[name] = true
            on_enter(name)
        elseif not inside and was then
            players_in_disco[name] = nil
            on_exit(name)
        end
    end
end)

-- limpia el estado si un jugador se desconecta dentro de la disco
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    stop_music_for(name)  -- siempre detiene, sea o no que estaba en la disco
    if players_in_disco[name] then
        players_in_disco[name] = nil
        if valdivia_music then valdivia_music.resume(name) end
    end
end)

-- ===========================================================================
-- COMANDO ADMIN: /discoteca
-- ===========================================================================

local function count_disco_entities_near(pos, radius)
    local n = 0
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
        local le = obj:get_luaentity()
        if le and (le.name == modname .. ":dj" or le.name == modname .. ":dancer") then
            n = n + 1
        end
    end
    return n
end

minetest.register_chatcommand("discoteca", {
    params = "zona_min | zona_max | dj_pos | info | dj | bailarin [estilo] | borrar | limpiar",
    description = "Configura la discoteca de Valdivia",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Solo en juego." end
        local ppos = vector.round(player:get_pos())
        local sub = param:match("^(%S+)") or ""

        if sub == "zona_min" then
            ZONE.min = ppos; normalize_zone(); save_config()
            return true, "Esquina MIN de la zona fijada en " .. minetest.pos_to_string(ppos)

        elseif sub == "zona_max" then
            ZONE.max = ppos; normalize_zone(); save_config()
            return true, "Esquina MAX de la zona fijada en " .. minetest.pos_to_string(ppos)

        elseif sub == "dj_pos" then
            DJ_POS = ppos; save_config()
            return true, "Posicion del DJ fijada en " .. minetest.pos_to_string(ppos)

        elseif sub == "info" then
            local lines = {"=== Discoteca de Valdivia ==="}
            lines[#lines+1] = "Zona min: " .. (ZONE.min and minetest.pos_to_string(ZONE.min) or "(sin fijar)")
            lines[#lines+1] = "Zona max: " .. (ZONE.max and minetest.pos_to_string(ZONE.max) or "(sin fijar)")
            lines[#lines+1] = "Emisor DJ: " .. (DJ_POS and minetest.pos_to_string(DJ_POS) or "(usa centro de zona)")
            local count = 0
            local names = {}
            for n in pairs(players_in_disco) do count = count + 1; names[#names+1] = n end
            lines[#lines+1] = "Jugadores dentro: " .. count .. (count > 0 and (" (" .. table.concat(names, ", ") .. ")") or "")
            lines[#lines+1] = "Streams de musica activos: " .. (function() local c=0 for _ in pairs(player_handles) do c=c+1 end return c end)()
            return true, table.concat(lines, "\n")

        elseif sub == "dj" then
            local pos = player:get_pos()
            local obj = minetest.add_entity(pos, modname .. ":dj")
            if obj then
                local le = obj:get_luaentity()
                le._yaw = player:get_look_horizontal()
                obj:set_yaw(le._yaw)
            end
            return true, "DJ colocado. Mira hacia donde quieres que apunte antes de invocarlo."

        elseif sub == "bailarin" then
            local estilo = param:match("^%S+%s+(%S+)")
            local style_i = nil
            if estilo then
                style_i = ROUTINE_BY_NAME[estilo]
                if not style_i then
                    return false, "Estilo desconocido. Estilos: " .. table.concat(ROUTINE_NAMES, ", ")
                end
            end
            local pos = player:get_pos()
            local obj = minetest.add_entity(pos, modname .. ":dancer")
            if obj then
                local le = obj:get_luaentity()
                le._yaw = player:get_look_horizontal()
                if style_i then
                    le._style = style_i
                    le._routine = DANCE_ROUTINES[style_i]
                end
                obj:set_yaw(le._yaw)
                begin_step(le, 1)  -- reinicia la rutina con el yaw/estilo definitivos
            end
            return true, "Bailarin colocado (estilo " .. (estilo or "aleatorio") ..
                "). Estilos: " .. table.concat(ROUTINE_NAMES, ", ")

        elseif sub == "borrar" then
            -- Elimina la entidad de discoteca mas cercana al jugador.
            local pos = player:get_pos()
            local nearest, nearest_dist = nil, math.huge
            for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 20)) do
                local le = obj:get_luaentity()
                if le and (le.name == modname .. ":dj" or le.name == modname .. ":dancer") then
                    local d = vector.distance(pos, obj:get_pos())
                    if d < nearest_dist then
                        nearest, nearest_dist = obj, d
                    end
                end
            end
            if nearest then
                local le = nearest:get_luaentity()
                local tipo = le.name == modname .. ":dj" and "DJ" or "Bailarin"
                nearest:remove()
                return true, tipo .. " eliminado (a " .. math.floor(nearest_dist) .. "m)."
            else
                return false, "No hay entidades de discoteca en 20m."
            end

        elseif sub == "limpiar" then
            local removed = 0
            for _, obj in ipairs(minetest.get_objects_inside_radius(player:get_pos(), 30)) do
                local le = obj:get_luaentity()
                if le and (le.name == modname .. ":dj" or le.name == modname .. ":dancer") then
                    obj:remove(); removed = removed + 1
                end
            end
            return true, "Eliminadas " .. removed .. " entidades de discoteca en 30m."

        else
            return false, "Uso: /discoteca <zona_min|zona_max|dj_pos|info|dj|bailarin [estilo]|borrar|limpiar>"
        end
    end,
})

minetest.log("action", "[" .. modname .. "] Loaded successfully")
