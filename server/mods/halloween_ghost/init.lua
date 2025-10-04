-- Halloween Ghost Mod
-- Fantasma amigable para eventos de Halloween
-- Apropiado para servidor educativo y compasivo

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
    float_height = 1.5,

    on_activate = function(self, staticdata)
        self.object:set_armor_groups({immortal = 1})
        self.timer = 0
        -- Hacer que el fantasma flote suavemente
        self.object:set_velocity({x=0, y=0.5, z=0})
    end,

    on_step = function(self, dtime)
        self.timer = self.timer + dtime

        -- Movimiento flotante suave (sube y baja)
        local pos = self.object:get_pos()
        if not pos then return end

        local vel = self.object:get_velocity()
        local new_y = math.sin(self.timer * 2) * 0.5

        -- Movimiento aleatorio horizontal
        if self.timer > 3 then
            self.timer = 0
            local random_vel = {
                x = math.random(-1, 1) * 0.5,
                y = new_y,
                z = math.random(-1, 1) * 0.5
            }
            self.object:set_velocity(random_vel)
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
        self.object:remove()
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

-- Comando para evento de Halloween (spawns múltiples)
minetest.register_chatcommand("evento_halloween", {
    params = "<cantidad>",
    description = "Inicia evento de Halloween con fantasmas (1-20)",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end

        local cantidad = tonumber(param) or 5
        if cantidad < 1 then cantidad = 1 end
        if cantidad > 20 then cantidad = 20 end

        local pos = player:get_pos()

        for i = 1, cantidad do
            local spawn_pos = {
                x = pos.x + math.random(-10, 10),
                y = pos.y + math.random(1, 5),
                z = pos.z + math.random(-10, 10)
            }
            minetest.add_entity(spawn_pos, "halloween_ghost:ghost")
        end

        minetest.chat_send_all("🎃 ¡Evento de Halloween! " .. cantidad .. " fantasmas han aparecido!")

        return true, "Evento iniciado con " .. cantidad .. " fantasmas"
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

-- Registro en el log
minetest.log("action", "[Halloween Ghost] Mod cargado exitosamente - Evento de Halloween activado")