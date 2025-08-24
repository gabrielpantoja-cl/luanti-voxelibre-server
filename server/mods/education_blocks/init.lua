-- ========================================
-- MOD: EDUCATION BLOCKS 📚
-- Bloques educativos sobre veganismo
-- ========================================

-- Cartel educativo sobre veganismo
minetest.register_node("education_blocks:vegan_sign", {
    description = "Cartel Vegano 📋\nInformación sobre veganismo",
    tiles = {"default_wood.png^education_vegan_sign.png"},
    drawtype = "signlike",
    paramtype = "light",
    paramtype2 = "wallmounted",
    groups = {cracky = 2, oddly_breakable_by_hand = 2, attached_node = 1},
    sounds = default.node_sound_wood_defaults(),
    selection_box = {type = "wallmounted"},
    
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local facts = {
            "🌱 Los animales son seres sintientes que sienten dolor y alegría",
            "💚 Una dieta vegana es saludable y completa",
            "🌍 El veganismo ayuda a proteger nuestro planeta",
            "🐮 Los animales prefieren vivir libres en santuarios",
            "🌾 Las plantas nos dan todo lo que necesitamos para estar sanos"
        }
        
        local random_fact = facts[math.random(#facts)]
        minetest.chat_send_player(player:get_player_name(), random_fact)
    end,
})

-- Bloque de datos nutricionales
minetest.register_node("education_blocks:nutrition_block", {
    description = "Bloque Nutricional 🥗\nDatos sobre nutrición vegana",
    tiles = {"education_nutrition_top.png", "education_nutrition_bottom.png", "education_nutrition_side.png"},
    groups = {cracky = 2, oddly_breakable_by_hand = 2},
    sounds = default.node_sound_stone_defaults(),
    
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local nutrition_facts = {
            "🥬 Las verduras de hoja verde tienen mucho hierro",
            "🥜 Los frutos secos son ricos en proteína",
            "🌾 Los cereales integrales dan energía duradera",
            "🍓 Las frutas tienen vitaminas y antioxidantes",
            "🫘 Las legumbres son súper nutritivas"
        }
        
        local fact = nutrition_facts[math.random(#nutrition_facts)]
        minetest.chat_send_player(player:get_player_name(), fact)
    end,
})

-- Bloque de historia animal
minetest.register_node("education_blocks:animal_facts", {
    description = "Datos de Animales 🐰\nDatos curiosos sobre animales",
    tiles = {"education_animal_facts.png"},
    groups = {cracky = 2, oddly_breakable_by_hand = 2},
    sounds = default.node_sound_stone_defaults(),
    
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local animal_facts = {
            "🐮 Las vacas tienen mejores amigas y se ponen tristes si las separan",
            "🐷 Los cerdos son más inteligentes que los perros",
            "🐔 Las gallinas pueden reconocer más de 100 caras diferentes",
            "🐰 Los conejos saltan de alegría cuando están felices",
            "🐐 Las cabras tienen acentos diferentes según dónde viven"
        }
        
        local fact = animal_facts[math.random(#animal_facts)]
        minetest.chat_send_player(player:get_player_name(), fact)
    end,
})

-- Recetas para bloques educativos
minetest.register_craft({
    output = "education_blocks:vegan_sign",
    recipe = {
        {"default:wood", "default:wood", "default:wood"},
        {"default:wood", "default:book", "default:wood"},
        {"", "default:stick", ""}
    }
})

minetest.register_craft({
    output = "education_blocks:nutrition_block", 
    recipe = {
        {"default:stone", "default:apple", "default:stone"},
        {"farming:wheat", "default:book", "farming:wheat"},
        {"default:stone", "default:apple", "default:stone"}
    }
})

minetest.register_craft({
    output = "education_blocks:animal_facts",
    recipe = {
        {"default:stone", "default:stone", "default:stone"},
        {"default:stone", "default:book", "default:stone"},
        {"default:stone", "default:stone", "default:stone"}
    }
})

print("📚 Education Blocks mod cargado exitosamente!")