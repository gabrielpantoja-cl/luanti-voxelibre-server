-- Broom Racing Mod
-- Sistema de escobas voladoras y carreras para Halloween
-- Apropiado para servidor educativo y compasivo

broom_racing = {}

-- Almacenamiento de datos de carreras
broom_racing.races = {}
broom_racing.checkpoints = {}
broom_racing.best_times = {}
broom_racing.active_racers = {}

-- Configuración
broom_racing.config = {
    max_speed = 15,  -- Velocidad máxima
    acceleration = 0.5,
    drag = 0.95,  -- Fricción del aire
    particle_interval = 0.1,
}

-- ==========================================
-- ESCOBAS VOLADORAS (3 NIVELES)
-- ==========================================

-- Función auxiliar para manejar el vuelo de escobas
local function broom_physics(player, speed_multiplier)
    if not player or not player:is_player() then return end

    local player_name = player:get_player_name()
    local ctrl = player:get_player_control()
    local vel = player:get_velocity()
    local look_dir = player:get_look_dir()
    local pos = player:get_pos()

    -- Inicializar datos del jugador si no existen
    if not broom_racing.active_racers[player_name] then
        broom_racing.active_racers[player_name] = {
            speed = 0,
            altitude = pos.y,
            particle_timer = 0,
        }
    end

    local racer_data = broom_racing.active_racers[player_name]

    -- Control de velocidad
    if ctrl.up then
        racer_data.speed = math.min(racer_data.speed + broom_racing.config.acceleration,
                                      broom_racing.config.max_speed * speed_multiplier)
    else
        racer_data.speed = racer_data.speed * broom_racing.config.drag
    end

    -- Control de dirección
    local new_vel = {x = 0, y = 0, z = 0}

    if racer_data.speed > 0.1 then
        -- Movimiento hacia adelante en la dirección de la mirada
        new_vel.x = look_dir.x * racer_data.speed
        new_vel.z = look_dir.z * racer_data.speed

        -- Control de altura
        if ctrl.jump then
            new_vel.y = 3  -- Subir
        elseif ctrl.sneak then
            new_vel.y = -3  -- Bajar
        else
            new_vel.y = look_dir.y * racer_data.speed * 0.5  -- Seguir la mirada suavemente
        end

        player:set_velocity(new_vel)

        -- Efectos de partículas
        racer_data.particle_timer = racer_data.particle_timer + 0.05
        if racer_data.particle_timer > broom_racing.config.particle_interval then
            racer_data.particle_timer = 0

            -- Partículas mágicas detrás de la escoba
            minetest.add_particle({
                pos = {x = pos.x, y = pos.y - 0.5, z = pos.z},
                velocity = {x = -look_dir.x * 2, y = 0, z = -look_dir.z * 2},
                acceleration = {x = 0, y = -2, z = 0},
                expirationtime = 1,
                size = 2 + math.random() * 2,
                collisiondetection = false,
                texture = "broom_particle_trail.png",
                glow = 8,
            })
        end
    end
end

-- Registro de escobas como items
minetest.register_tool("broom_racing:broom_basic", {
    description = "Escoba Voladora Básica\nVelocidad: Baja\nClick derecho para montar",
    inventory_image = "broom_basic.png",
    wield_image = "broom_basic.png",
    wield_scale = {x = 1.5, y = 1.5, z = 1},

    on_use = function(itemstack, user, pointed_thing)
        if not user or not user:is_player() then return end

        local player_name = user:get_player_name()

        -- Verificar si ya está montado
        if broom_racing.active_racers[player_name] and
           broom_racing.active_racers[player_name].mounted then
            -- Desmontar
            broom_racing.active_racers[player_name].mounted = false
            broom_racing.active_racers[player_name] = nil
            minetest.chat_send_player(player_name, "🧹 Has desmontado de la escoba")

            -- Restaurar física normal
            user:set_physics_override({
                gravity = 1,
                speed = 1,
            })
        else
            -- Montar
            if not broom_racing.active_racers[player_name] then
                broom_racing.active_racers[player_name] = {}
            end
            broom_racing.active_racers[player_name].mounted = true
            broom_racing.active_racers[player_name].broom_type = "basic"
            broom_racing.active_racers[player_name].speed_mult = 0.6

            minetest.chat_send_player(player_name, "🧹 ¡Montado en escoba básica! Arriba=acelerar, Salto=subir, Agacharse=bajar")

            -- Modificar física
            user:set_physics_override({
                gravity = 0.3,
                speed = 1.2,
            })
        end

        return itemstack
    end,
})

minetest.register_tool("broom_racing:broom_fast", {
    description = "Escoba Voladora Rápida\nVelocidad: Media\nClick derecho para montar",
    inventory_image = "broom_fast.png",
    wield_image = "broom_fast.png",
    wield_scale = {x = 1.5, y = 1.5, z = 1},

    on_use = function(itemstack, user, pointed_thing)
        if not user or not user:is_player() then return end

        local player_name = user:get_player_name()

        if broom_racing.active_racers[player_name] and
           broom_racing.active_racers[player_name].mounted then
            broom_racing.active_racers[player_name].mounted = false
            broom_racing.active_racers[player_name] = nil
            minetest.chat_send_player(player_name, "🧹 Has desmontado de la escoba")

            user:set_physics_override({
                gravity = 1,
                speed = 1,
            })
        else
            if not broom_racing.active_racers[player_name] then
                broom_racing.active_racers[player_name] = {}
            end
            broom_racing.active_racers[player_name].mounted = true
            broom_racing.active_racers[player_name].broom_type = "fast"
            broom_racing.active_racers[player_name].speed_mult = 0.8

            minetest.chat_send_player(player_name, "🧹 ¡Montado en escoba rápida! Arriba=acelerar, Salto=subir, Agacharse=bajar")

            user:set_physics_override({
                gravity = 0.2,
                speed = 1.4,
            })
        end

        return itemstack
    end,
})

minetest.register_tool("broom_racing:broom_magic", {
    description = "Escoba Mágica Suprema\nVelocidad: Máxima\nClick derecho para montar",
    inventory_image = "broom_magic.png",
    wield_image = "broom_magic.png",
    wield_scale = {x = 1.5, y = 1.5, z = 1},

    on_use = function(itemstack, user, pointed_thing)
        if not user or not user:is_player() then return end

        local player_name = user:get_player_name()

        if broom_racing.active_racers[player_name] and
           broom_racing.active_racers[player_name].mounted then
            broom_racing.active_racers[player_name].mounted = false
            broom_racing.active_racers[player_name] = nil
            minetest.chat_send_player(player_name, "🧹 Has desmontado de la escoba")

            user:set_physics_override({
                gravity = 1,
                speed = 1,
            })
        else
            if not broom_racing.active_racers[player_name] then
                broom_racing.active_racers[player_name] = {}
            end
            broom_racing.active_racers[player_name].mounted = true
            broom_racing.active_racers[player_name].broom_type = "magic"
            broom_racing.active_racers[player_name].speed_mult = 1.0

            minetest.chat_send_player(player_name, "🧹✨ ¡Montado en escoba mágica! Velocidad máxima desbloqueada!")

            user:set_physics_override({
                gravity = 0.1,
                speed = 1.6,
            })
        end

        return itemstack
    end,
})

-- ==========================================
-- SISTEMA DE CHECKPOINTS
-- ==========================================

-- Nodo de checkpoint
minetest.register_node("broom_racing:checkpoint", {
    description = "Checkpoint de Carrera\nColoca varios para crear un circuito",
    tiles = {
        "checkpoint_top.png",
        "checkpoint_bottom.png",
        "checkpoint_side.png"
    },
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    light_source = 12,
    groups = {oddly_breakable_by_hand = 2},
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.1, 0.5, 0.5, 0.1},
        },
    },

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec",
            "size[6,4]" ..
            "label[0.5,0.5;Configuración de Checkpoint]" ..
            "field[0.8,1.5;5,1;checkpoint_number;Número de Checkpoint (1-20):;1]" ..
            "field[0.8,2.5;5,1;race_name;Nombre de la Carrera:;Carrera 1]" ..
            "button_exit[2,3;2,1;save;Guardar]"
        )
        meta:set_int("checkpoint_number", 1)
        meta:set_string("race_name", "Carrera 1")
    end,

    on_receive_fields = function(pos, formname, fields, sender)
        if fields.save then
            local meta = minetest.get_meta(pos)
            local checkpoint_num = tonumber(fields.checkpoint_number) or 1
            local race_name = fields.race_name or "Carrera 1"

            if checkpoint_num < 1 then checkpoint_num = 1 end
            if checkpoint_num > 20 then checkpoint_num = 20 end

            meta:set_int("checkpoint_number", checkpoint_num)
            meta:set_string("race_name", race_name)
            meta:set_string("infotext", race_name .. " - Checkpoint #" .. checkpoint_num)

            -- Registrar checkpoint en sistema global
            if not broom_racing.checkpoints[race_name] then
                broom_racing.checkpoints[race_name] = {}
            end

            broom_racing.checkpoints[race_name][checkpoint_num] = {
                pos = pos,
                number = checkpoint_num
            }

            minetest.chat_send_player(sender:get_player_name(),
                "✅ Checkpoint #" .. checkpoint_num .. " configurado para '" .. race_name .. "'")
        end
    end,
})

-- ==========================================
-- SISTEMA DE CARRERAS Y CRONOMETRAJE
-- ==========================================

-- GlobalStep para física de escobas y detección de checkpoints
minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local player_name = player:get_player_name()
        local racer_data = broom_racing.active_racers[player_name]

        if racer_data and racer_data.mounted then
            -- Aplicar física de vuelo
            broom_physics(player, racer_data.speed_mult or 1.0)

            -- Detectar checkpoints cercanos
            local pos = player:get_pos()
            local nearby_nodes = minetest.find_nodes_in_area(
                {x = pos.x - 2, y = pos.y - 2, z = pos.z - 2},
                {x = pos.x + 2, y = pos.y + 2, z = pos.z + 2},
                {"broom_racing:checkpoint"}
            )

            for _, checkpoint_pos in ipairs(nearby_nodes) do
                local meta = minetest.get_meta(checkpoint_pos)
                local race_name = meta:get_string("race_name")
                local checkpoint_num = meta:get_int("checkpoint_number")

                -- Inicializar datos de carrera si no existen
                if not racer_data.current_race then
                    racer_data.current_race = race_name
                    racer_data.last_checkpoint = 0
                    racer_data.start_time = minetest.get_us_time()
                    racer_data.checkpoints_passed = {}
                end

                -- Verificar si es el siguiente checkpoint
                if race_name == racer_data.current_race and
                   checkpoint_num == racer_data.last_checkpoint + 1 and
                   not racer_data.checkpoints_passed[checkpoint_num] then

                    racer_data.last_checkpoint = checkpoint_num
                    racer_data.checkpoints_passed[checkpoint_num] = true

                    -- Efectos visuales de checkpoint alcanzado
                    minetest.add_particlespawner({
                        amount = 50,
                        time = 0.5,
                        minpos = {x = checkpoint_pos.x - 1, y = checkpoint_pos.y, z = checkpoint_pos.z - 1},
                        maxpos = {x = checkpoint_pos.x + 1, y = checkpoint_pos.y + 2, z = checkpoint_pos.z + 1},
                        minvel = {x = -2, y = 2, z = -2},
                        maxvel = {x = 2, y = 4, z = 2},
                        minacc = {x = 0, y = -5, z = 0},
                        maxacc = {x = 0, y = -3, z = 0},
                        minexptime = 1,
                        maxexptime = 2,
                        minsize = 2,
                        maxsize = 4,
                        texture = "checkpoint_particle.png",
                        glow = 10,
                    })

                    minetest.chat_send_player(player_name,
                        "✨ Checkpoint " .. checkpoint_num .. " alcanzado!")

                    -- Verificar si es el último checkpoint (finish)
                    local total_checkpoints = 0
                    if broom_racing.checkpoints[race_name] then
                        for _ in pairs(broom_racing.checkpoints[race_name]) do
                            total_checkpoints = total_checkpoints + 1
                        end
                    end

                    if checkpoint_num == total_checkpoints then
                        -- ¡Carrera completada!
                        local finish_time = (minetest.get_us_time() - racer_data.start_time) / 1000000
                        local time_str = string.format("%.2f segundos", finish_time)

                        minetest.chat_send_all("🏁 " .. player_name .. " completó '" .. race_name ..
                                                "' en " .. time_str .. "!")

                        -- Guardar mejor tiempo
                        if not broom_racing.best_times[race_name] then
                            broom_racing.best_times[race_name] = {}
                        end

                        table.insert(broom_racing.best_times[race_name], {
                            player = player_name,
                            time = finish_time,
                            date = os.date("%Y-%m-%d %H:%M")
                        })

                        -- Ordenar por tiempo
                        table.sort(broom_racing.best_times[race_name], function(a, b)
                            return a.time < b.time
                        end)

                        -- Mantener solo top 10
                        while #broom_racing.best_times[race_name] > 10 do
                            table.remove(broom_racing.best_times[race_name])
                        end

                        -- Reset datos de carrera
                        racer_data.current_race = nil
                        racer_data.last_checkpoint = 0
                        racer_data.checkpoints_passed = {}
                    end
                end
            end
        end
    end
end)

-- Comando para ver mejores tiempos
minetest.register_chatcommand("mejores_tiempos", {
    params = "[nombre_carrera]",
    description = "Ver los mejores tiempos de una carrera",
    func = function(name, param)
        local race_name = param
        if race_name == "" then
            -- Listar carreras disponibles
            local races = {}
            for race, _ in pairs(broom_racing.checkpoints) do
                table.insert(races, race)
            end

            if #races == 0 then
                return true, "No hay carreras configuradas aún"
            end

            return true, "Carreras disponibles: " .. table.concat(races, ", ")
        end

        -- Mostrar mejores tiempos de la carrera especificada
        if not broom_racing.best_times[race_name] then
            return true, "No hay tiempos registrados para '" .. race_name .. "'"
        end

        local msg = "🏆 Mejores Tiempos - " .. race_name .. ":\n"
        for i, record in ipairs(broom_racing.best_times[race_name]) do
            msg = msg .. string.format("%d. %s - %.2fs (%s)\n",
                                        i, record.player, record.time, record.date)
        end

        return true, msg
    end,
})

-- Comando para resetear carrera actual
minetest.register_chatcommand("reset_carrera", {
    params = "",
    description = "Reinicia tu carrera actual",
    func = function(name, param)
        local racer_data = broom_racing.active_racers[name]

        if racer_data then
            racer_data.current_race = nil
            racer_data.last_checkpoint = 0
            racer_data.checkpoints_passed = {}
            return true, "✅ Carrera reiniciada. Pasa por el primer checkpoint para comenzar de nuevo."
        else
            return false, "No estás en una carrera actualmente"
        end
    end,
})

-- ==========================================
-- RECETAS DE CRAFTEO
-- ==========================================

-- Escoba básica: palos + paja (wheat)
minetest.register_craft({
    output = "broom_racing:broom_basic",
    recipe = {
        {"", "", "mcl_core:stick"},
        {"", "mcl_core:stick", ""},
        {"mcl_farming:wheat_item", "", ""},
    }
})

-- Escoba rápida: escoba básica + plumas + oro
minetest.register_craft({
    output = "broom_racing:broom_fast",
    recipe = {
        {"mcl_mobitems:feather", "mcl_core:gold_ingot", "mcl_mobitems:feather"},
        {"", "broom_racing:broom_basic", ""},
        {"", "", ""},
    }
})

-- Escoba mágica: escoba rápida + diamantes + ender pearl
minetest.register_craft({
    output = "broom_racing:broom_magic",
    recipe = {
        {"mcl_core:diamond", "mcl_end:ender_pearl", "mcl_core:diamond"},
        {"", "broom_racing:broom_fast", ""},
        {"", "", ""},
    }
})

-- Checkpoint: palos + oro + redstone
minetest.register_craft({
    output = "broom_racing:checkpoint 2",
    recipe = {
        {"mcl_core:stick", "mcl_core:gold_ingot", "mcl_core:stick"},
        {"mcl_core:gold_ingot", "mcl_core:goldblock", "mcl_core:gold_ingot"},
        {"mcl_core:stick", "mcl_core:gold_ingot", "mcl_core:stick"},
    }
})

-- ==========================================
-- COMANDOS DE ADMIN
-- ==========================================

-- Dar escoba a jugador
minetest.register_chatcommand("dar_escoba", {
    params = "<jugador> <tipo>",
    description = "Da una escoba a un jugador (basic/fast/magic)",
    privs = {server = true},
    func = function(name, param)
        local args = {}
        for word in param:gmatch("%S+") do
            table.insert(args, word)
        end

        if #args < 2 then
            return false, "Uso: /dar_escoba <jugador> <tipo>"
        end

        local player_name = args[1]
        local broom_type = args[2]

        local player = minetest.get_player_by_name(player_name)
        if not player then
            return false, "Jugador no encontrado"
        end

        local item_name = "broom_racing:broom_" .. broom_type
        local inv = player:get_inventory()

        if inv:room_for_item("main", item_name) then
            inv:add_item("main", item_name)
            return true, "✅ Escoba '" .. broom_type .. "' entregada a " .. player_name
        else
            return false, "Inventario lleno"
        end
    end,
})

-- Crear evento de carreras
minetest.register_chatcommand("evento_carreras", {
    params = "",
    description = "Anuncia evento de carreras de escobas",
    privs = {server = true},
    func = function(name, param)
        minetest.chat_send_all("🧹🏁 ¡EVENTO DE CARRERAS DE ESCOBAS MÁGICAS! 🏁🧹")
        minetest.chat_send_all("✨ ¡Usa /mejores_tiempos para ver los récords!")
        minetest.chat_send_all("🎃 ¡Participa y conviértete en el mejor piloto de escobas!")

        return true, "Evento anunciado"
    end,
})

-- ==========================================
-- CLEANUP AL DESCONECTAR
-- ==========================================

minetest.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()

    -- Restaurar física normal
    player:set_physics_override({
        gravity = 1,
        speed = 1,
    })

    -- Limpiar datos
    broom_racing.active_racers[player_name] = nil
end)

-- Log de carga
minetest.log("action", "[Broom Racing] Mod cargado exitosamente - Sistema de carreras de escobas activado")
minetest.log("action", "[Broom Racing] Comandos disponibles: /mejores_tiempos, /reset_carrera, /dar_escoba, /evento_carreras")
