-- ================================================
-- MOD: ANIMAL SANCTUARY - SANTUARIO DE ANIMALES 🌱
-- Para el servidor Vegan Wetlands
-- ================================================

animal_sanctuary = {}

-- Mensaje de bienvenida del mod
minetest.log("action", "[Animal Sanctuary] 🌱 Cargando santuarios veganos...")

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
            "🌱 ¡Bienvenid@ al Santuario Animal! Aquí cuidamos y protegemos a nuestros amigos.")
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
            "🥕 Has alimentado a los animales con comida vegana. ¡Están muy contentos!")
        
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
-- HERRAMIENTAS VEGANAS
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
-- COMIDA VEGANA PARA ANIMALES
-- ==================

minetest.register_craftitem("animal_sanctuary:vegan_animal_food", {
    description = "Comida Vegana para Animales 🌾\nNutritiva y deliciosa",
    inventory_image = "animal_sanctuary_vegan_food.png",
    stack_max = 64,
    
    on_use = function(itemstack, user, pointed_thing)
        minetest.chat_send_player(user:get_player_name(), 
            "🌾 Has dado comida vegana nutritiva a los animales.")
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

-- Receta para comida vegana
minetest.register_craft({
    output = "animal_sanctuary:vegan_animal_food 4",
    recipe = {
        {"farming:wheat", "farming:wheat"},
        {"default:apple", "default:apple"}
    }
})

-- ==================
-- COMANDOS DEL CHAT
-- ==================

-- Comando para obtener información sobre el santuario
minetest.register_chatcommand("santuario", {
    description = "Información sobre cómo funciona el santuario animal",
    func = function(name, param)
        local info = {
            "🌱 === SANTUARIO DE ANIMALES VEGANO ===",
            "🐮 Aquí cuidamos y protegemos a todos los animales",
            "🧽 Usa el cepillo para mimar a los animales",
            "🥕 Alimenta a los animales con comida vegana",
            "🏠 Construye refugios para mantenerlos seguros",
            "🏥 Cura animales heridos con el kit médico",
            "💚 ¡Juntos creamos un mundo más compasivo!"
        }
        
        for _, line in ipairs(info) do
            minetest.chat_send_player(name, line)
        end
        
        return true
    end,
})

-- Comando de ayuda vegana
minetest.register_chatcommand("veganismo", {
    description = "Aprende sobre el veganismo",
    func = function(name, param)
        local vegan_info = {
            "🌱 === ¿QUÉ ES EL VEGANISMO? ===",
            "💚 El veganismo es una forma de vida que evita lastimar animales",
            "🐮 Los animales son nuestros amigos, no comida",
            "🌾 Podemos estar sanos comiendo solo plantas",
            "🌍 Ayudamos al planeta siendo veganos",
            "🤗 ¡En Vegan Wetlands celebramos la compasión!"
        }
        
        for _, line in ipairs(vegan_info) do
            minetest.chat_send_player(name, line)
        end
        
        return true
    end,
})

-- ==================
-- EVENTOS Y FUNCIONES
-- ==================

-- Prevenir daño a animales
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    if hitter and hitter:is_player() then
        minetest.chat_send_player(hitter:get_player_name(), 
            "🚫 ¡En Vegan Wetlands no lastimamos a nadie! Usa el cepillo para mimar instead.")
        return true -- Cancela el daño
    end
    return false
end)

-- Mensaje de bienvenida para nuevos jugadores
minetest.register_on_newplayer(function(player)
    local name = player:get_player_name()
    minetest.after(2, function()
        minetest.chat_send_player(name, 
            "🌱 ¡Bienvenid@ a Vegan Wetlands, " .. name .. "!")
        minetest.chat_send_player(name, 
            "🐮 Aquí cuidamos animales en santuarios veganos.")
        minetest.chat_send_player(name, 
            "💚 Usa /santuario para aprender cómo funciona.")
        minetest.chat_send_player(name, 
            "🌾 Usa /veganismo para aprender sobre compasión.")
    end)
end)

-- Dar kit inicial a nuevos jugadores
minetest.register_on_newplayer(function(player)
    local inv = player:get_inventory()
    inv:add_item("main", "animal_sanctuary:animal_brush")
    inv:add_item("main", "animal_sanctuary:vegan_animal_food 10")
    inv:add_item("main", "animal_sanctuary:animal_medkit")
end)

minetest.log("action", "[Animal Sanctuary] 🌱 ¡Santuarios veganos cargados exitosamente!")

print("🌱 Animal Sanctuary mod cargado - ¡Vegan Wetlands listo!")