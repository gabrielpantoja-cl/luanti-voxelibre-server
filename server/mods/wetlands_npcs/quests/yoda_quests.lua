return {
    main_quests = {
        {
            id = "yoda_main_1",
            title = "Bocadillos para Grogu",
            description = "Yoda tiene hambre y quiere zanahorias",
            min_friendship = 0,
            objectives = {
                { type = "collect", item = "mcl_farming:carrot_item", count = 15,
                  description = "Recoger 15 zanahorias" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 5 } },
            },
            dialogue_on_accept = "Hambre tengo! Zanahorias, 15 necesito. Deliciosas son!",
            dialogue_on_complete = "Mmmm! Deliciosas, estas zanahorias son! Agradecido estoy.",
            next_quest = "yoda_main_2",
        },
        {
            id = "yoda_main_2",
            title = "Meditacion de la Fuerza",
            description = "Yoda necesita flores para un jardin de meditacion",
            requires = "yoda_main_1",
            min_friendship = 1,
            objectives = {
                { type = "collect", item = "mcl_flowers:dandelion", count = 10,
                  description = "Recoger 10 dientes de leon" },
                { type = "collect", item = "mcl_flowers:poppy", count = 5,
                  description = "Recoger 5 amapolas" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 8 } },
            },
            dialogue_on_accept = "Un jardin de meditacion, crear quiero. Flores, necesito. Dientes de leon y amapolas.",
            dialogue_on_complete = "Hermoso, este jardin sera. La Fuerza, aqui fluye mejor.",
            next_quest = "yoda_main_3",
        },
        {
            id = "yoda_main_3",
            title = "La Sabiduria Antigua",
            description = "Yoda quiere crear una coleccion de libros de sabiduria",
            requires = "yoda_main_2",
            min_friendship = 3,
            objectives = {
                { type = "collect", item = "mcl_books:book", count = 8,
                  description = "Reunir 8 libros" },
            },
            rewards = {
                unique_item = true,
            },
            dialogue_on_accept = "900 anios de sabiduria, preservar debo. 8 libros, llenarlos puedo con conocimiento.",
            dialogue_on_complete = "Escrita queda, la sabiduria. Compartirla contigo, debo. Toma este libro, especial es.",
        },
    },
    side_quests = {
        {
            id = "yoda_side_snacks",
            title = "Mas Bocadillos",
            description = "Grogu siempre tiene hambre",
            repeatable = true,
            cooldown = 1200,
            objectives = {
                { type = "collect", item = "mcl_farming:carrot_item", count = 8,
                  description = "Traer 8 zanahorias" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 4 } },
            },
            dialogue_on_accept = "Hambre otra vez tengo. Zanahorias, mas necesito!",
            dialogue_on_complete = "Satisfecho estoy. Generoso eres!",
        },
    },
}
