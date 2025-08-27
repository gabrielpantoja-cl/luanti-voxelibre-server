-- ===============================
-- MOD: VEGAN FOODS 🥕
-- Comidas veganas para Vegan Wetlands
-- ===============================

-- Hamburguesa vegana
minetest.register_craftitem("vegan_foods:vegan_burger", {
    description = "Hamburguesa Vegana 🍔\nDeliciosa y sin crueldad animal",
    inventory_image = "vegan_foods_burger.png",
    on_use = minetest.item_eat(8),
    groups = {food_burger = 1, vegan = 1},
})

-- Leche de avena
minetest.register_craftitem("vegan_foods:oat_milk", {
    description = "Leche de Avena 🥛\nCremosa y nutritiva",
    inventory_image = "vegan_foods_oat_milk.png",
    on_use = minetest.item_eat(4),
    groups = {food_milk = 1, vegan = 1},
})

-- Queso vegano
minetest.register_craftitem("vegan_foods:vegan_cheese", {
    description = "Queso Vegano 🧀\nHecho con amor y plantas",
    inventory_image = "vegan_foods_cheese.png", 
    on_use = minetest.item_eat(6),
    groups = {food_cheese = 1, vegan = 1},
})

-- Pizza vegana
minetest.register_craftitem("vegan_foods:vegan_pizza", {
    description = "Pizza Vegana 🍕\nCon queso vegano y vegetales",
    inventory_image = "vegan_foods_pizza.png",
    on_use = minetest.item_eat(12),
    groups = {food_pizza = 1, vegan = 1},
})

-- Recetas
minetest.register_craft({
    output = "vegan_foods:vegan_burger",
    recipe = {
        {"mcl_farming:bread"},
        {"mcl_core:apple"},
        {"mcl_farming:bread"}
    }
})

minetest.register_craft({
    output = "vegan_foods:oat_milk",
    recipe = {
        {"mcl_farming:wheat", "mcl_farming:wheat", "mcl_farming:wheat"},
        {"", "mcl_buckets:bucket_water", ""},
        {"", "", ""}
    }
})

print("🥕 Vegan Foods mod cargado exitosamente!")