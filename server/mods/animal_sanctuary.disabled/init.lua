-- ================================================
-- MOD: ANIMAL SANCTUARY - SANTUARIO DE ANIMALES 🌱
-- Servidor familiar amigable con los animales
-- ================================================

animal_sanctuary = {}

-- Mensaje de bienvenida del mod
minetest.log("action", "[Animal Sanctuary] 🌱 Cargando santuarios amigables...")

-- ==================
-- BLOQUES DEL SANTUARIO
-- ==================

-- Bloque de entrada del santuario
minetest.register_node("animal_sanctuary:sanctuary_gate", {
    description = "Puerta del Santuario Animal 🐮",
    tiles = {"default_wood.png^animal_sanctuary_gate_overlay.png"},
    groups = {cracky = 2, oddly_breakable_by_hand = 2},
    sounds = mcl_sounds.node_sound_wood_defaults(),
    
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        minetest.chat_send_player(player:get_player_name(), 
            "🌱 ¡Bienvenid@ al Santuario Animal! Aquí cuidamos y protegemos a nuestros amigos con amor.")
        -- Efecto de partículas de bienvenida
        minetest.add_particlespawner({
            amount = 10,
            time = 3,
            minpos = {x = pos.x - 1, y = pos.y, z = pos.z - 1},
            maxpos = {x = pos.x + 1, y = pos.y + 2, z = pos.z + 1},
            minvel = {x = -0.5, y = 1, z = -0.5},
            maxvel = {x = 0.5, y = 2, z = 0.5},
            minacc = {x = 0, y = -9.81, z = 0},
            maxacc = {x = 0, y = -9.81, z = 0},
            minexptime = 2,
            maxexptime = 4,
            minsize = 1,
            maxsize = 3,
            texture = "default_grass.png",
        })
    end,
})

-- Comedero para animales
minetest.register_node("animal_sanctuary:animal_feeder", {
    description = "Comedero Animal 🥕",
    tiles = {"default_wood.png", "default_wood.png", "animal_sanctuary_feeder_side.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 2, oddly_breakable_by_hand = 2},
    sounds = mcl_sounds.node_sound_wood_defaults(),
    
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, -0.2, 0.5}, -- Base
            {-0.4, -0.2, -0.4, 0.4, 0, 0.4}, -- Contenedor
        },
    },
    
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        minetest.chat_send_player(player:get_player_name(), 
            "🥕 Has alimentado a los animales con comida saludable. ¡Están muy contentos!")
        
        -- Sonido de animales felices (si hay sonidos disponibles)
        minetest.sound_play("animal_sanctuary_happy", {
            pos = pos,
            gain = 0.5,
            max_hear_distance = 10,
        })
    end,
})

-- Refugio para animales
minetest.register_node("animal_sanctuary:animal_shelter", {
    description = "Refugio Animal 🏠",
    tiles = {"default_wood.png^animal_sanctuary_roof.png", 
             "default_wood.png", 
             "default_wood.png^animal_sanctuary_shelter_side.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 2, oddly_breakable_by_hand = 2},
    sounds = mcl_sounds.node_sound_wood_defaults(),
    
    node_box = {
        type = "fixed",
        fixed = {
            -- Paredes
            {-0.5, -0.5, -0.5, -0.4, 0.5, 0.5},
            {0.4, -0.5, -0.5, 0.5, 0.5, 0.5},
            {-0.4, -0.5, 0.4, 0.4, 0.5, 0.5},
            -- Techo
            {-0.5, 0.4, -0.5, 0.5, 0.5, 0.5},
            -- Piso
            {-0.4, -0.5, -0.4, 0.4, -0.4, 0.4},
        },
    },
    
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        minetest.chat_send_player(player:get_player_name(), 
            "🏠 Este refugio mantiene a los animales seguros y cómodos.")
    end,
})

-- ==================
-- HERRAMIENTAS AMIGABLES
-- ==================

-- Cepillo para cuidar animales (reemplaza armas)
minetest.register_tool("animal_sanctuary:animal_brush", {
    description = "Cepillo para Animales 🧽\nUsa esto para cuidar y mimar a los animales",
    inventory_image = "animal_sanctuary_brush.png",
    range = 4.0,
    
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type == "object" then
            local obj = pointed_thing.ref
            if obj and obj:is_player() == false then
                minetest.chat_send_player(user:get_player_name(), 
                    "🧽 ¡Has cepillado y mimado al animal! Está muy feliz.")
                
                -- Efecto de corazones
                local pos = obj:get_pos()
                if pos then
                    minetest.add_particlespawner({
                        amount = 5,
                        time = 2,
                        minpos = {x = pos.x - 0.5, y = pos.y + 0.5, z = pos.z - 0.5},
                        maxpos = {x = pos.x + 0.5, y = pos.y + 1.5, z = pos.z + 0.5},
                        minvel = {x = -0.2, y = 1, z = -0.2},
                        maxvel = {x = 0.2, y = 2, z = 0.2},
                        minacc = {x = 0, y = -5, z = 0},
                        maxacc = {x = 0, y = -5, z = 0},
                        minexptime = 1,
                        maxexptime = 3,
                        minsize = 2,
                        maxsize = 4,
                        texture = "heart.png",
                    })
                end
            end
        else
            minetest.chat_send_player(user:get_player_name(), 
                "🐮 Busca un animal para cuidar y cepillar.")
        end
        return itemstack
    end,
})

-- Kit de primeros auxilios para animales
minetest.register_craftitem("animal_sanctuary:animal_medkit", {
    description = "Kit Médico Animal 🏥\nPara curar animales heridos",
    inventory_image = "animal_sanctuary_medkit.png",
    
    on_use = function(itemstack, user, pointed_thing)
        minetest.chat_send_player(user:get_player_name(), 
            "🏥 Has curado a un animal. ¡Ahora está sano y salvo!")
        return itemstack
    end,
})

-- ==================
-- COMIDA SALUDABLE PARA ANIMALES
-- ==================

minetest.register_craftitem("animal_sanctuary:vegan_animal_food", {
    description = "Comida Saludable para Animales 🌾\nNutritiva y deliciosa",
    inventory_image = "animal_sanctuary_vegan_food.png",
    stack_max = 64,
    
    on_use = function(itemstack, user, pointed_thing)
        minetest.chat_send_player(user:get_player_name(), 
            "🌾 Has dado comida saludable y nutritiva a los animales.")
        itemstack:take_item()
        return itemstack
    end,
})

-- ==================
-- RECETAS DE CRAFT
-- ==================

-- Receta para puerta del santuario
minetest.register_craft({
    output = "animal_sanctuary:sanctuary_gate",
    recipe = {
        {"default:wood", "default:wood", "default:wood"},
        {"default:wood", "default:sign_wall_wood", "default:wood"},
        {"default:wood", "default:wood", "default:wood"}
    }
})

-- Receta para comedero
minetest.register_craft({
    output = "animal_sanctuary:animal_feeder",
    recipe = {
        {"default:wood", "", "default:wood"},
        {"default:wood", "default:wood", "default:wood"},
        {"default:wood", "default:wood", "default:wood"}
    }
})

-- Receta para refugio
minetest.register_craft({
    output = "animal_sanctuary:animal_shelter",
    recipe = {
        {"default:wood", "default:wood", "default:wood"},
        {"default:wood", "", "default:wood"},
        {"default:wood", "default:wood", "default:wood"}
    }
})

-- Receta para cepillo
minetest.register_craft({
    output = "animal_sanctuary:animal_brush",
    recipe = {
        {"default:stick"},
        {"farming:wheat"},
        {"default:stick"}
    }
})

-- Receta para kit médico
minetest.register_craft({
    output = "animal_sanctuary:animal_medkit",
    recipe = {
        {"default:paper", "default:paper", "default:paper"},
        {"default:paper", "default:apple", "default:paper"},
        {"default:paper", "default:paper", "default:paper"}
    }
})

-- Receta para comida saludable
minetest.register_craft({
    output = "animal_sanctuary:vegan_animal_food 4",
    recipe = {
        {"farming:wheat", "farming:wheat"},
        {"default:apple", "default:apple"}
    }
})


-- ==================
-- EVENTOS Y FUNCIONES
-- ==================

-- Prevenir daño a animales
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    if hitter and hitter:is_player() then
        minetest.chat_send_player(hitter:get_player_name(), 
            "🚫 ¡Este es un servidor sin violencia! Usa el cepillo para mimar en su lugar.")
        return true -- Cancela el daño
    end
    return false
end)

-- Mensaje de bienvenida para nuevos jugadores
minetest.register_on_newplayer(function(player)
    local name = player:get_player_name()
    minetest.after(2, function()
        minetest.chat_send_player(name, 
            "🌱 ¡Bienvenid@ a Wetlands, " .. name .. "!")
        minetest.chat_send_player(name, 
            "💚 Aquí nos cuidamos con amor y respeto.")
        minetest.chat_send_player(name, 
            "🔧 Estamos en desarrollo activo.")
    end)
end)

-- Dar kit inicial a nuevos jugadores
minetest.register_on_newplayer(function(player)
    local inv = player:get_inventory()
    -- Comida vegana del mod vegan_food
    inv:add_item("main", "vegan_food:tofu 5")
    inv:add_item("main", "vegan_food:cooked_seitan 3")
    inv:add_item("main", "vegan_food:milk_bucket 2")
    -- Herramientas básicas para construcción y exploración
    inv:add_item("main", "mcl_tools:shovel_wood")
    inv:add_item("main", "mcl_farming:bread 5")
    inv:add_item("main", "mcl_farming:carrot_item 10")
    inv:add_item("main", "mcl_farming:beetroot_item 5")
end)

minetest.log("action", "[Animal Sanctuary] 🌱 ¡Santuarios amigables cargados exitosamente!")

print("🌱 Animal Sanctuary mod cargado - ¡Servidor familiar listo!")