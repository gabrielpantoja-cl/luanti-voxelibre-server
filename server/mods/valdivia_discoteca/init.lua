-- valdivia_discoteca: discoteca interactiva en la ciudad de Valdivia (30001)
--
-- Al entrar a la zona configurada, arranca musica posicional en bucle, se
-- encienden luces de colores sobre la pista y (si el admin los coloco) un DJ
-- y varios bailarines animan el lugar. Todo se apaga cuando el ultimo jugador
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
local MAX_HEAR_DISTANCE = 30      -- radio audible del emisor (metros)
local POLL_INTERVAL = 1.0         -- cada cuanto se revisa la posicion del jugador
local LIGHT_INTERVAL = 2.0        -- cada cuanto cambian de color las luces
local COLLISIONBOX = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3}  -- del registry humano

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

-- Estilos de baile: rangos de frames del modelo humano (wetlands_npc_human.b3d).
--   sit 81-160 -> rebote; walk 168-187 -> pasos en el sitio; mine 189-198 -> brazos.
local DANCE_STYLES = {
    { name = "rebote", frames = {81, 160},  speed = 30 },
    { name = "pasos",  frames = {168, 187}, speed = 45 },
    { name = "brazos", frames = {189, 198}, speed = 30 },
}
local DJ_ANIM = { frames = {189, 198}, speed = 25 }  -- brazo oscilando en la consola

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
        self._style = data.style or math.random(#DANCE_STYLES)
        self._yaw = data.yaw or 0
        self.object:set_properties({textures = {self._skin, "blank.png", "blank.png"}})
        self.object:set_yaw(self._yaw)
        local s = DANCE_STYLES[self._style]
        self.object:set_animation({x = s.frames[1], y = s.frames[2]}, s.speed, 0, true)
    end,
    get_staticdata = function(self)
        return minetest.serialize({skin = self._skin, style = self._style, yaw = self._yaw})
    end,
    on_punch = function() return true end,  -- indestructible (anti-grief)
})

-- ===========================================================================
-- MUSICA POSICIONAL EN BUCLE
-- ===========================================================================

local music_handle = nil

local function start_music()
    if music_handle then return end
    local pos = emitter_pos()
    if not pos then return end
    music_handle = minetest.sound_play(MUSIC_TRACK, {
        pos = pos,
        loop = true,
        gain = MUSIC_GAIN,
        max_hear_distance = MAX_HEAR_DISTANCE,
    })
end

local function stop_music()
    if not music_handle then return end
    local h = music_handle
    music_handle = nil
    minetest.sound_fade(h, -0.8, 0.0)         -- fade suave
    minetest.after(1.5, function()
        minetest.sound_stop(h)                 -- corte definitivo tras el fade
    end)
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
    -- Silenciar musica ambiental para este jugador mientras esta en la disco.
    if valdivia_music then valdivia_music.pause(name) end
    start_music()
    start_lights()
    minetest.chat_send_player(name, minetest.colorize("#FF66CC",
        "\u{266A} Bienvenido a la Discoteca de Valdivia \u{266A}"))
end

local function on_exit(name)
    -- Reanudar musica ambiental para este jugador.
    if valdivia_music then valdivia_music.resume(name) end
    if not has_players() then
        stop_music()
        -- las luces se auto-detienen en el proximo cycle_lights (has_players()==false)
    end
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
            pos.y >= ZONE.min.y and pos.y <= ZONE.max.y and
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
    if players_in_disco[name] then
        players_in_disco[name] = nil
        on_exit(name)
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
    params = "zona_min | zona_max | dj_pos | info | dj | bailarin | borrar | limpiar",
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
            -- si la musica esta sonando, reinicia el emisor en la nueva posicion
            if music_handle then stop_music(); minetest.after(1.6, start_music) end
            return true, "Emisor de audio (DJ) fijado en " .. minetest.pos_to_string(ppos)

        elseif sub == "info" then
            local lines = {"=== Discoteca de Valdivia ==="}
            lines[#lines+1] = "Zona min: " .. (ZONE.min and minetest.pos_to_string(ZONE.min) or "(sin fijar)")
            lines[#lines+1] = "Zona max: " .. (ZONE.max and minetest.pos_to_string(ZONE.max) or "(sin fijar)")
            lines[#lines+1] = "Emisor DJ: " .. (DJ_POS and minetest.pos_to_string(DJ_POS) or "(usa centro de zona)")
            lines[#lines+1] = "Jugadores dentro: " .. tostring((function() local c=0 for _ in pairs(players_in_disco) do c=c+1 end return c end)())
            lines[#lines+1] = "Musica activa: " .. tostring(music_handle ~= nil)
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
            local pos = player:get_pos()
            local obj = minetest.add_entity(pos, modname .. ":dancer")
            if obj then
                local le = obj:get_luaentity()
                le._yaw = player:get_look_horizontal()
                obj:set_yaw(le._yaw)
            end
            return true, "Bailarin colocado (skin y estilo aleatorios)."

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
            return false, "Uso: /discoteca <zona_min|zona_max|dj_pos|info|dj|bailarin|borrar|limpiar>"
        end
    end,
})

minetest.log("action", "[" .. modname .. "] Loaded successfully")
