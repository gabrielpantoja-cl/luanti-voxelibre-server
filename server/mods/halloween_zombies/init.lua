-- Halloween Zombies Mod
-- Sistema de zombies amigables para Halloween en modo pacífico
-- Apropiado para servidor educativo y compasivo (7+ años)
-- Spawn Location: 123, 25, -204

-- Configuración del mod
local ZOMBIE_SPAWN_POS = {x = 123, y = 25, z = -204}
local SPAWN_RADIUS = 15  -- Radio de spawn alrededor del punto central
local MAX_ZOMBIES = 10   -- Máximo de zombies activos simultáneamente
local SPAWN_INTERVAL = 30  -- Segundos entre spawns automáticos
local ZOMBIE_LIFETIME = 300  -- 5 minutos antes de desaparecer automáticamente

-- Contador de zombies activos
local active_zombies = 0

-- Función para verificar si estamos en época de Halloween (Octubre)
local function is_halloween_season()
    local date = os.date("*t")
    return date.month == 10  -- Octubre
end

-- Registro del zombie como entity
minetest.register_entity("halloween_zombies:friendly_zombie", {
    initial_properties = {
        hp_max = 20,
        physical = true,
        collide_with_objects = true,
        collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.9, 0.3},
        visual = "mesh",
        mesh = "mobs_mc_zombie.b3d",
        visual_size = {x=3, y=3},
        textures = {
            {
                "mobs_mc_empty.png",    -- armor overlay
                "mobs_mc_zombie.png",   -- zombie texture
            }
        },
        is_visible = true,
        makes_footstep_sound = true,
        automatic_rotate = 0,
        glow = 3,  -- Brillo tenue para atmósfera espeluznante
    },

    timer = 0,
    lifetime = 0,
    direction = 0,
    walk_timer = 0,

    on_activate = function(self, staticdata)
        -- Inmortales en modo pacífico (no reciben daño)
        self.object:set_armor_groups({immortal = 1})
        self.timer = 0
        self.lifetime = 0
        self.direction = math.random(0, 360) * (math.pi / 180)
        self.walk_timer = 0

        active_zombies = active_zombies + 1

        minetest.log("action", "[Halloween Zombies] Zombie spawneado. Total activos: " .. active_zombies)
    end,

    on_step = function(self, dtime)
        self.timer = self.timer + dtime
        self.lifetime = self.lifetime + dtime
        self.walk_timer = self.walk_timer + dtime

        local pos = self.object:get_pos()
        if not pos then return end

        -- Auto-despawn después del tiempo de vida
        if self.lifetime > ZOMBIE_LIFETIME then
            -- Efecto de partículas al desaparecer
            for i = 1, 20 do
                minetest.add_particle({
                    pos = pos,
                    velocity = {
                        x = math.random(-2, 2),
                        y = math.random(0, 3),
                        z = math.random(-2, 2)
                    },
                    acceleration = {x=0, y=-5, z=0},
                    expirationtime = math.random(1, 2),
                    size = math.random(1, 3),
                    collisiondetection = true,
                    texture = "halloween_zombie_particle.png",
                    glow = 8,
                })
            end

            active_zombies = math.max(0, active_zombies - 1)
            self.object:remove()
            return
        end

        -- Cambiar dirección cada 3-5 segundos
        if self.walk_timer > math.random(3, 5) then
            self.walk_timer = 0
            self.direction = math.random(0, 360) * (math.pi / 180)
        end

        -- Movimiento lento y tambaleante (como zombie)
        local speed = 0.5
        local vel = {
            x = math.sin(self.direction) * speed,
            y = -5,  -- Gravedad
            z = math.cos(self.direction) * speed
        }

        -- Movimiento tambaleante (zigzag)
        local wobble = math.sin(self.timer * 3) * 0.2
        vel.x = vel.x + wobble
        vel.z = vel.z + wobble

        self.object:set_velocity(vel)

        -- Rotar hacia la dirección de movimiento
        self.object:set_yaw(self.direction)

        -- Efecto de partículas ocasional (humo/miasma)
        if math.random(1, 20) == 1 then
            minetest.add_particle({
                pos = {x = pos.x, y = pos.y + 1, z = pos.z},
                velocity = {x=math.random(-1, 1) * 0.1, y=0.3, z=math.random(-1, 1) * 0.1},
                acceleration = {x=0, y=0.1, z=0},
                expirationtime = 2,
                size = 3,
                collisiondetection = false,
                vertical = false,
                texture = "halloween_zombie_smoke.png",
                glow = 2,
            })
        end

        -- Sonidos espeluznantes ocasionales (sonido real)
        if math.random(1, 200) == 1 then
            minetest.sound_play("mobs_mc_zombie_growl", {
                pos = pos,
                gain = 0.5,
                max_hear_distance = 16,
            })
        end
    end,

    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        if not puncher or not puncher:is_player() then return end

        local pos = self.object:get_pos()
        local player_name = puncher:get_player_name()

        -- En modo pacífico, el zombie no ataca, solo da items de Halloween
        local rewards = {
            "mcl_core:apple",
            "mcl_farming:carrot_item",
            "mcl_farming:potato_item",
            "mcl_farming:beetroot_item",
        }

        local reward = rewards[math.random(1, #rewards)]
        minetest.add_item(pos, reward .. " " .. math.random(1, 3))

        -- Mensaje temático
        local messages = {
            "🧟 El zombie soltó algo antes de desaparecer!",
            "🧟 *GRRR* El zombie dejó caer comida!",
            "🧟 El zombie parecía guardar esto... *gruñido*",
        }
        minetest.chat_send_player(player_name, messages[math.random(1, #messages)])

        -- Efecto de partículas al eliminar
        for i = 1, 25 do
            minetest.add_particle({
                pos = pos,
                velocity = {
                    x = math.random(-3, 3),
                    y = math.random(0, 4),
                    z = math.random(-3, 3)
                },
                acceleration = {x=0, y=-6, z=0},
                expirationtime = math.random(1, 3),
                size = math.random(2, 5),
                collisiondetection = true,
                texture = "halloween_zombie_particle.png",
                glow = 10,
            })
        end

        -- Sonido de eliminación (sonido real)
        minetest.sound_play("mobs_mc_zombie_death", {
            pos = pos,
            gain = 0.7,
            max_hear_distance = 20,
        })

        minetest.chat_send_all("🎃 Un zombie ha sido derrotado en " .. minetest.pos_to_string(vector.round(pos)))

        active_zombies = math.max(0, active_zombies - 1)
        self.object:remove()
    end,

    on_death = function(self, killer)
        active_zombies = math.max(0, active_zombies - 1)
    end,
})

-- Función para spawn de zombie individual
local function spawn_zombie(pos)
    if active_zombies >= MAX_ZOMBIES then
        return false, "Límite de zombies alcanzado (" .. MAX_ZOMBIES .. ")"
    end

    -- Verificar que la posición sea válida
    local node = minetest.get_node(pos)
    if not node then
        return false, "Posición inválida"
    end

    -- Spawn con offset aleatorio
    local spawn_pos = {
        x = pos.x + math.random(-SPAWN_RADIUS, SPAWN_RADIUS),
        y = pos.y,
        z = pos.z + math.random(-SPAWN_RADIUS, SPAWN_RADIUS)
    }

    minetest.add_entity(spawn_pos, "halloween_zombies:friendly_zombie")
    return true
end

-- Sistema de spawn automático (solo en Octubre)
local spawn_timer = 0
minetest.register_globalstep(function(dtime)
    if not is_halloween_season() then
        return
    end

    spawn_timer = spawn_timer + dtime

    if spawn_timer >= SPAWN_INTERVAL then
        spawn_timer = 0

        if active_zombies < MAX_ZOMBIES then
            spawn_zombie(ZOMBIE_SPAWN_POS)
        end
    end
end)

-- Comando: Invocar zombie individual
minetest.register_chatcommand("invocar_zombie", {
    params = "",
    description = "Invoca un zombie amigable de Halloween",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end

        local pos = player:get_pos()
        pos.y = pos.y + 1

        local success = spawn_zombie(pos)
        if success then
            return true, "🧟 ¡Zombie invocado! Cuidado..."
        else
            return false, "No se pudo invocar el zombie (límite alcanzado: " .. MAX_ZOMBIES .. ")"
        end
    end,
})

-- Comando: Evento masivo de zombies
minetest.register_chatcommand("invasion_zombies", {
    params = "<cantidad>",
    description = "Inicia invasión de zombies de Halloween (1-" .. MAX_ZOMBIES .. ")",
    privs = {server = true},
    func = function(name, param)
        local cantidad = tonumber(param) or 5
        if cantidad < 1 then cantidad = 1 end
        if cantidad > MAX_ZOMBIES then cantidad = MAX_ZOMBIES end

        local spawned = 0
        for i = 1, cantidad do
            if active_zombies < MAX_ZOMBIES then
                spawn_zombie(ZOMBIE_SPAWN_POS)
                spawned = spawned + 1
            end
        end

        minetest.chat_send_all("🧟 ¡INVASIÓN ZOMBIE! " .. spawned .. " zombies han aparecido cerca de " .. minetest.pos_to_string(ZOMBIE_SPAWN_POS) .. "!")

        return true, "Invasión iniciada con " .. spawned .. " zombies"
    end,
})

-- Comando: Limpiar todos los zombies
minetest.register_chatcommand("limpiar_zombies", {
    params = "",
    description = "Elimina todos los zombies activos del servidor",
    privs = {server = true},
    func = function(name, param)
        local removed = 0

        for _, obj in pairs(minetest.luaentities) do
            if obj.name == "halloween_zombies:friendly_zombie" then
                obj.object:remove()
                removed = removed + 1
            end
        end

        active_zombies = 0

        return true, "🧟 Eliminados " .. removed .. " zombies del servidor"
    end,
})

-- Comando: Estado de zombies
minetest.register_chatcommand("estado_zombies", {
    params = "",
    description = "Muestra información sobre los zombies activos",
    privs = {},
    func = function(name, param)
        local info = {
            "🧟 === Estado de Zombies de Halloween ===",
            "Zombies activos: " .. active_zombies .. "/" .. MAX_ZOMBIES,
            "Zona de spawn: " .. minetest.pos_to_string(ZOMBIE_SPAWN_POS),
            "Radio de spawn: " .. SPAWN_RADIUS .. " bloques",
            "Temporada Halloween: " .. (is_halloween_season() and "ACTIVA (Octubre)" or "Inactiva"),
            "Tiempo entre spawns: " .. SPAWN_INTERVAL .. " segundos",
        }

        return true, table.concat(info, "\n")
    end,
})

-- Bloque decorativo: Tumba de Halloween
minetest.register_node("halloween_zombies:zombie_grave", {
    description = "Tumba Zombie (Decoración de Halloween)",
    tiles = {
        "halloween_grave_top.png",
        "halloween_grave_bottom.png",
        "halloween_grave_side.png",
        "halloween_grave_side.png",
        "halloween_grave_front.png",
        "halloween_grave_front.png"
    },
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {oddly_breakable_by_hand = 1},
    node_box = {
        type = "fixed",
        fixed = {
            {-0.3, -0.5, -0.1, 0.3, 0.5, 0.1},  -- Lápida
            {-0.4, -0.5, -0.2, 0.4, -0.3, 0.2}  -- Base
        }
    },
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if not clicker or not clicker:is_player() then return end

        local player_name = clicker:get_player_name()

        -- Chance de que salga un zombie de la tumba
        if math.random(1, 5) == 1 and active_zombies < MAX_ZOMBIES then
            local spawn_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
            spawn_zombie(spawn_pos)
            minetest.chat_send_player(player_name, "🧟 ¡Un zombie salió de la tumba! RIP...")

            -- Efecto de partículas
            for i = 1, 15 do
                minetest.add_particle({
                    pos = spawn_pos,
                    velocity = {x=math.random(-2, 2), y=math.random(0, 3), z=math.random(-2, 2)},
                    acceleration = {x=0, y=-3, z=0},
                    expirationtime = 2,
                    size = 4,
                    texture = "halloween_zombie_smoke.png",
                    glow = 5,
                })
            end
        else
            local messages = {
                "💀 R.I.P. ... *silencio espeluznante*",
                "💀 Aquí yace un zombie... o quizás no...",
                "💀 *escuchas gruñidos bajo tierra*",
            }
            minetest.chat_send_player(player_name, messages[math.random(1, #messages)])
        end
    end,
})

-- Registro en el log
if is_halloween_season() then
    minetest.log("action", "[Halloween Zombies] Mod cargado - TEMPORADA HALLOWEEN ACTIVA")
    minetest.log("action", "[Halloween Zombies] Zona de spawn: " .. minetest.pos_to_string(ZOMBIE_SPAWN_POS))
else
    minetest.log("action", "[Halloween Zombies] Mod cargado - Temporada inactiva (no es Octubre)")
end

minetest.log("action", "[Halloween Zombies] Configuración: MAX=" .. MAX_ZOMBIES .. ", Intervalo=" .. SPAWN_INTERVAL .. "s")
