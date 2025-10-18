-- Halloween Ghost Mod
-- Fantasma amigable para eventos de Halloween
-- Apropiado para servidor educativo y compasivo
-- Spawn Location: 123, 25, -204 (misma ubicación que zombies)

-- Configuración del mod
local GHOST_SPAWN_POS = {x = 123, y = 25, z = -204}
local SPAWN_RADIUS = 15  -- Radio de spawn alrededor del punto central
local MAX_GHOSTS = 8   -- Máximo de fantasmas activos simultáneamente
local SPAWN_INTERVAL = 45  -- Segundos entre spawns automáticos (más lento que zombies)
local GHOST_LIFETIME = 240  -- 4 minutos antes de desaparecer automáticamente
local MAX_HEIGHT = 50  -- Altura máxima sobre el spawn (evita que suban infinitamente)

-- Contador de fantasmas activos
local active_ghosts = 0

-- Función para verificar si estamos en época de Halloween (Octubre)
local function is_halloween_season()
    local date = os.date("*t")
    return date.month == 10  -- Octubre
end

-- Registro del fantasma como entity
minetest.register_entity("halloween_ghost:ghost", {
    initial_properties = {
        hp_max = 10,
        physical = false,
        collide_with_objects = false,
        collisionbox = {-0.3, -0.5, -0.3, 0.3, 0.8, 0.3},
        visual = "cube",
        visual_size = {x=0.6, y=0.8},
        textures = {
            "halloween_ghost_top.png",
            "halloween_ghost_bottom.png",
            "halloween_ghost_side.png",
            "halloween_ghost_side.png",
            "halloween_ghost_front.png",
            "halloween_ghost_back.png"
        },
        is_visible = true,
        makes_footstep_sound = false,
        automatic_rotate = math.pi / 4,
        glow = 8,  -- Brilla en la oscuridad
    },

    timer = 0,
    lifetime = 0,
    float_height = 1.5,
    spawn_y = nil,  -- Altura inicial de spawn

    on_activate = function(self, staticdata)
        self.object:set_armor_groups({immortal = 1})
        self.timer = 0
        self.lifetime = 0

        -- Guardar altura de spawn para limitar altura máxima
        local pos = self.object:get_pos()
        if pos then
            self.spawn_y = pos.y
        end

        active_ghosts = active_ghosts + 1

        minetest.log("action", "[Halloween Ghost] Fantasma spawneado. Total activos: " .. active_ghosts)
    end,

    on_step = function(self, dtime)
        self.timer = self.timer + dtime
        self.lifetime = self.lifetime + dtime

        -- Movimiento flotante suave (sube y baja)
        local pos = self.object:get_pos()
        if not pos then return end

        -- Auto-despawn después del tiempo de vida
        if self.lifetime > GHOST_LIFETIME then
            -- Efecto de partículas al desaparecer
            for i = 1, 15 do
                minetest.add_particle({
                    pos = pos,
                    velocity = {
                        x = math.random(-1, 1),
                        y = math.random(0, 2),
                        z = math.random(-1, 1)
                    },
                    acceleration = {x=0, y=-3, z=0},
                    expirationtime = math.random(1, 2),
                    size = math.random(1, 3),
                    collisiondetection = true,
                    texture = "halloween_ghost_particle.png",
                    glow = 10,
                })
            end

            active_ghosts = math.max(0, active_ghosts - 1)
            self.object:remove()
            return
        end

        -- Limitar altura máxima (evitar que suban infinitamente)
        if self.spawn_y and pos.y > (self.spawn_y + MAX_HEIGHT) then
            -- Forzar descenso suave si superan altura máxima
            self.object:set_velocity({
                x = math.random(-1, 1) * 0.3,
                y = -0.8,  -- Descenso suave
                z = math.random(-1, 1) * 0.3
            })
        else
            -- Movimiento flotante normal con límite
            local vel = self.object:get_velocity()
            local new_y = math.sin(self.timer * 2) * 0.5

            -- Limitar velocidad ascendente si está cerca del límite
            local height_diff = self.spawn_y and (pos.y - self.spawn_y) or 0
            if height_diff > (MAX_HEIGHT * 0.8) then
                new_y = math.min(new_y, -0.2)  -- Forzar descenso gradual
            end

            -- Movimiento aleatorio horizontal cada 3 segundos
            if self.timer > 3 then
                self.timer = 0
                local random_vel = {
                    x = math.random(-1, 1) * 0.5,
                    y = new_y,
                    z = math.random(-1, 1) * 0.5
                }
                self.object:set_velocity(random_vel)
            end
        end

        -- Efecto de partículas místicas
        if math.random(1, 10) == 1 then
            minetest.add_particle({
                pos = pos,
                velocity = {x=0, y=0.5, z=0},
                acceleration = {x=0, y=0.2, z=0},
                expirationtime = 1,
                size = 2,
                collisiondetection = false,
                vertical = false,
                texture = "halloween_ghost_particle.png",
                glow = 5,
            })
        end
    end,

    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        if not puncher or not puncher:is_player() then return end

        local pos = self.object:get_pos()

        -- Suelta dulces/premios cuando lo tocas
        local rewards = {
            "mcl_core:apple",
            "mcl_farming:carrot_item",
            "mcl_farming:potato_item",
        }

        local reward = rewards[math.random(1, #rewards)]
        minetest.add_item(pos, reward)

        -- Mensaje amigable
        local player_name = puncher:get_player_name()
        minetest.chat_send_player(player_name, "👻 El fantasma te dejó un regalo! Buu!")

        -- Efecto de partículas al tocar
        for i = 1, 10 do
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
                texture = "halloween_ghost_particle.png",
                glow = 8,
            })
        end

        -- El fantasma desaparece con sonido
        active_ghosts = math.max(0, active_ghosts - 1)
        self.object:remove()
    end,

    on_death = function(self, killer)
        active_ghosts = math.max(0, active_ghosts - 1)
    end,
})

-- Comando para invocar fantasmas (solo admin)
minetest.register_chatcommand("invocar_fantasma", {
    params = "",
    description = "Invoca un fantasma amigable de Halloween",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end

        local pos = player:get_pos()
        pos.y = pos.y + 2

        minetest.add_entity(pos, "halloween_ghost:ghost")

        return true, "👻 ¡Fantasma invocado! Buu!"
    end,
})

-- Comando para evento de Halloween (spawns múltiples) - LEGACY con límite
minetest.register_chatcommand("evento_halloween", {
    params = "<cantidad>",
    description = "Inicia evento de Halloween con fantasmas cerca de jugador (1-" .. MAX_GHOSTS .. ")",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end

        local cantidad = tonumber(param) or 5
        if cantidad < 1 then cantidad = 1 end
        if cantidad > MAX_GHOSTS then cantidad = MAX_GHOSTS end

        local pos = player:get_pos()
        local spawned = 0

        for i = 1, cantidad do
            if active_ghosts >= MAX_GHOSTS then
                break  -- Respeta el límite global
            end

            local spawn_pos = {
                x = pos.x + math.random(-10, 10),
                y = pos.y + math.random(1, 5),
                z = pos.z + math.random(-10, 10)
            }
            minetest.add_entity(spawn_pos, "halloween_ghost:ghost")
            spawned = spawned + 1
        end

        if spawned > 0 then
            minetest.chat_send_all("🎃 ¡Evento de Halloween! " .. spawned .. " fantasmas han aparecido!")
            return true, "Evento iniciado con " .. spawned .. " fantasmas"
        else
            return false, "Límite de fantasmas alcanzado (" .. active_ghosts .. "/" .. MAX_GHOSTS .. ")"
        end
    end,
})

-- Item decorativo: Calabaza de Halloween
minetest.register_node("halloween_ghost:magic_pumpkin", {
    description = "Calabaza Mágica de Halloween",
    tiles = {"halloween_pumpkin.png"},
    groups = {oddly_breakable_by_hand = 1},
    light_source = 10,
    paramtype = "light",
    on_destruct = function(pos)
        -- Al romper la calabaza, puede salir un fantasma o dulces
        if math.random(1, 2) == 1 then
            minetest.add_entity(pos, "halloween_ghost:ghost")
            minetest.chat_send_all("👻 ¡Un fantasma salió de la calabaza en " .. minetest.pos_to_string(pos) .. "!")
        else
            for i = 1, 3 do
                minetest.add_item(pos, "mcl_core:apple")
            end
        end
    end,
})

-- Función para spawn de fantasma individual
local function spawn_ghost(pos)
    if active_ghosts >= MAX_GHOSTS then
        return false, "Límite de fantasmas alcanzado (" .. MAX_GHOSTS .. ")"
    end

    -- Verificar que la posición sea válida
    local node = minetest.get_node(pos)
    if not node then
        return false, "Posición inválida"
    end

    -- Spawn con offset aleatorio
    local spawn_pos = {
        x = pos.x + math.random(-SPAWN_RADIUS, SPAWN_RADIUS),
        y = pos.y + math.random(0, 3),  -- Un poco más alto para efecto fantasmal
        z = pos.z + math.random(-SPAWN_RADIUS, SPAWN_RADIUS)
    }

    minetest.add_entity(spawn_pos, "halloween_ghost:ghost")
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

        if active_ghosts < MAX_GHOSTS then
            spawn_ghost(GHOST_SPAWN_POS)
        end
    end
end)

-- Comando: Limpiar todos los fantasmas (GLOBAL - todo el mundo)
minetest.register_chatcommand("limpiar_fantasmas", {
    params = "",
    description = "Elimina TODOS los fantasmas del mundo entero (no solo área cargada)",
    privs = {server = true},
    func = function(name, param)
        local removed = 0

        -- Método 1: Limpiar entities en memoria (chunks cargados)
        for _, obj in pairs(minetest.luaentities) do
            if obj.name == "halloween_ghost:ghost" then
                obj.object:remove()
                removed = removed + 1
            end
        end

        -- Método 2: Buscar en radio gigante desde spawn de Halloween
        -- Esto fuerza la carga de chunks en un área enorme
        local search_radius = 5000  -- 5000 bloques de radio (10km de diámetro)
        local objects = minetest.get_objects_inside_radius(GHOST_SPAWN_POS, search_radius)

        for _, obj in ipairs(objects) do
            local entity = obj:get_luaentity()
            if entity and entity.name == "halloween_ghost:ghost" then
                obj:remove()
                removed = removed + 1
            end
        end

        -- Resetear contador global
        active_ghosts = 0

        minetest.chat_send_all("🧹 LIMPIEZA GLOBAL: Eliminados " .. removed .. " fantasmas del mundo")

        return true, "👻 Limpieza global completada: " .. removed .. " fantasmas eliminados en radio de " .. search_radius .. " bloques"
    end,
})

-- Comando: Limpiar fantasmas en área específica
minetest.register_chatcommand("limpiar_fantasmas_area", {
    params = "<radio>",
    description = "Elimina fantasmas en un radio específico desde tu posición (máx 1000 bloques)",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end

        local radius = tonumber(param) or 100
        if radius < 1 then radius = 1 end
        if radius > 1000 then radius = 1000 end

        local pos = player:get_pos()
        local removed = 0

        local objects = minetest.get_objects_inside_radius(pos, radius)
        for _, obj in ipairs(objects) do
            local entity = obj:get_luaentity()
            if entity and entity.name == "halloween_ghost:ghost" then
                obj:remove()
                removed = removed + 1
                active_ghosts = math.max(0, active_ghosts - 1)
            end
        end

        return true, "👻 Eliminados " .. removed .. " fantasmas en radio de " .. radius .. " bloques"
    end,
})

-- Comando: Estado de fantasmas
minetest.register_chatcommand("estado_fantasmas", {
    params = "",
    description = "Muestra información sobre los fantasmas activos",
    privs = {},
    func = function(name, param)
        local info = {
            "👻 === Estado de Fantasmas de Halloween ===",
            "Fantasmas activos: " .. active_ghosts .. "/" .. MAX_GHOSTS,
            "Zona de spawn: " .. minetest.pos_to_string(GHOST_SPAWN_POS),
            "Radio de spawn: " .. SPAWN_RADIUS .. " bloques",
            "Altura máxima: +" .. MAX_HEIGHT .. " bloques desde spawn",
            "Temporada Halloween: " .. (is_halloween_season() and "ACTIVA (Octubre)" or "Inactiva"),
            "Tiempo entre spawns: " .. SPAWN_INTERVAL .. " segundos",
            "Tiempo de vida: " .. GHOST_LIFETIME .. " segundos (4 minutos)",
        }

        return true, table.concat(info, "\n")
    end,
})

-- Comando: Invasión de fantasmas (en ubicación fija, no en jugador)
minetest.register_chatcommand("invasion_fantasmas", {
    params = "<cantidad>",
    description = "Inicia invasión de fantasmas en zona de spawn (1-" .. MAX_GHOSTS .. ")",
    privs = {server = true},
    func = function(name, param)
        local cantidad = tonumber(param) or 5
        if cantidad < 1 then cantidad = 1 end
        if cantidad > MAX_GHOSTS then cantidad = MAX_GHOSTS end

        local spawned = 0
        for i = 1, cantidad do
            if active_ghosts < MAX_GHOSTS then
                spawn_ghost(GHOST_SPAWN_POS)
                spawned = spawned + 1
            end
        end

        minetest.chat_send_all("👻 ¡INVASIÓN FANTASMAL! " .. spawned .. " fantasmas han aparecido cerca de " .. minetest.pos_to_string(GHOST_SPAWN_POS) .. "!")

        return true, "Invasión iniciada con " .. spawned .. " fantasmas"
    end,
})

-- Registro en el log
if is_halloween_season() then
    minetest.log("action", "[Halloween Ghost] Mod cargado - TEMPORADA HALLOWEEN ACTIVA")
    minetest.log("action", "[Halloween Ghost] Zona de spawn: " .. minetest.pos_to_string(GHOST_SPAWN_POS))
else
    minetest.log("action", "[Halloween Ghost] Mod cargado - Temporada inactiva (no es Octubre)")
end

minetest.log("action", "[Halloween Ghost] Configuración: MAX=" .. MAX_GHOSTS .. ", Intervalo=" .. SPAWN_INTERVAL .. "s, Altura máx=" .. MAX_HEIGHT .. "m")