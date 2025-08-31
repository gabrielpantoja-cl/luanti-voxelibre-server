-- ========================================
-- MOD: EDUCATION BLOCKS 📚
-- Bloques educativos sobre compasión y sostenibilidad
-- ========================================

-- Comando de filosofía
core.register_chatcommand("filosofia", {
    description = "Muestra la filosofía del juego",
    func = function(name, param)
        core.chat_send_player(name, "Nuestra filosofía es simple: aprender, crear y explorar con respeto por todos los seres vivos y nuestro planeta. Fomentamos la compasión, la curiosidad y la colaboración. ¡Construyamos un mundo mejor juntos!")
    end,
})

-- Cartel educativo
core.register_node("education_blocks:sign", {
    description = "Cartel Educativo 📋\nInformación sobre nuestro mundo",
    tiles = {"mcl_core_planks_oak.png^education_sign.png"},
    drawtype = "signlike",
    paramtype = "light",
    paramtype2 = "wallmounted",
    groups = {cracky = 2, oddly_breakable_by_hand = 2, attached_node = 1},
    -- sounds = mcl_sounds.node_sound_wood_defaults(), -- This was causing a crash
    selection_box = {type = "wallmounted"},

    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local facts = {
            "🌱 Los animales son seres sintientes que merecen nuestro respeto.",
            "💚 Una alimentación consciente y basada en plantas es saludable y sostenible.",
            "🌍 Cuidar el planeta es responsabilidad de todos.",
            "🐮 En este mundo, los animales viven libres y en paz.",
            "🌾 Las plantas nos dan todo lo que necesitamos para estar sanos."
        }

        local random_fact = facts[math.random(#facts)]
        core.chat_send_player(player:get_player_name(), random_fact)
    end,
})

-- Bloque de datos nutricionales
core.register_node("education_blocks:nutrition_block", {
    description = "Bloque Nutricional 🥗\nDatos sobre nutrición",
    tiles = {"education_nutrition_top.png", "education_nutrition_bottom.png", "education_nutrition_side.png"},
    groups = {cracky = 2, oddly_breakable_by_hand = 2},
    -- sounds = mcl_sounds.node_sound_stone_defaults(), -- This was causing a crash

    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local nutrition_facts = {
            "🥬 Las verduras de hoja verde son una gran fuente de hierro.",
            "🥜 Los frutos secos son ricos en proteínas y grasas saludables.",
            "🌾 Los cereales integrales nos dan energía duradera.",
            "🍓 Las frutas están llenas de vitaminas y antioxidantes.",
            "🫘 Las legumbres son una base nutritiva y versátil para muchas comidas."
        }

        local fact = nutrition_facts[math.random(#nutrition_facts)]
        core.chat_send_player(player:get_player_name(), fact)
    end,
})

-- Bloque de datos sobre animales
core.register_node("education_blocks:animal_facts", {
    description = "Datos de Animales 🐰\nDatos curiosos sobre animales",
    tiles = {"education_animal_facts.png"},
    groups = {cracky = 2, oddly_breakable_by_hand = 2},
    -- sounds = mcl_sounds.node_sound_stone_defaults(), -- This was causing a crash

    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local animal_facts = {
            "🐮 Las vacas tienen mejores amigas y se estresan si las separan.",
            "🐷 Los cerdos son considerados uno de los animales más inteligentes.",
            "🐔 Las gallinas tienen complejas estructuras sociales y pueden reconocer más de 100 caras.",
            "🐰 Los conejos expresan felicidad saltando y girando en el aire.",
            "🐐 Las cabras tienen diferentes 'acentos' en sus balidos según su grupo social."
        }

        local fact = animal_facts[math.random(#animal_facts)]
        core.chat_send_player(player:get_player_name(), fact)
    end,
})

-- Recetas para bloques educativos
core.register_craft({
    output = "education_blocks:sign",
    recipe = {
        {"group:wood", "group:wood", "group:wood"},
        {"group:wood", "default:book", "group:wood"},
        {"", "default:stick", ""}
    }
})

core.register_craft({
    output = "education_blocks:nutrition_block",
    recipe = {
        {"group:stone", "default:apple", "group:stone"},
        {"farming:wheat", "default:book", "farming:wheat"},
        {"group:stone", "default:apple", "group:stone"}
    }
})

core.register_craft({
    output = "education_blocks:animal_facts",
    recipe = {
        {"group:stone", "group:stone", "group:stone"},
        {"group:stone", "default:book", "group:stone"},
        {"group:stone", "group:stone", "group:stone"}
    }
})

print("📚 Education Blocks mod cargado exitosamente!")
