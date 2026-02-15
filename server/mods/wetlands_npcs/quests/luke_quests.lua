return {
    main_quests = {
        {
            id = "luke_main_1",
            title = "El Camino del Jedi",
            description = "Luke necesita palos para fabricar sables de entrenamiento",
            min_friendship = 0,
            objectives = {
                { type = "collect", item = "mcl_core:stick", count = 10,
                  description = "Recoger 10 palos" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 5 } },
            },
            dialogue_on_accept = "Necesito palos para fabricar sables de entrenamiento. Trae 10!",
            dialogue_on_progress = "Ya llevas %d de %d palos. Sigue asi!",
            dialogue_on_complete = "Excelente! Estos sables ayudaran a muchos aprendices. Toma estas esmeraldas.",
            next_quest = "luke_main_2",
        },
        {
            id = "luke_main_2",
            title = "Textos Jedi Antiguos",
            description = "Luke quiere preservar la sabiduria Jedi en libros",
            requires = "luke_main_1",
            min_friendship = 1,
            objectives = {
                { type = "collect", item = "mcl_books:book", count = 5,
                  description = "Conseguir 5 libros" },
            },
            rewards = {
                items = { { name = "mcl_core:diamond", count = 2 } },
            },
            dialogue_on_accept = "Los textos Jedi deben preservarse. Necesito 5 libros para escribir la sabiduria antigua.",
            dialogue_on_complete = "Estos libros guardaran la sabiduria de generaciones de Jedi. Gracias, amigo.",
            next_quest = "luke_main_3",
        },
        {
            id = "luke_main_3",
            title = "La Fuerza Interior",
            description = "Luke te pide reunir cristales (diamantes) para un sable real",
            requires = "luke_main_2",
            min_friendship = 3,
            objectives = {
                { type = "collect", item = "mcl_core:diamond", count = 3,
                  description = "Encontrar 3 diamantes (cristales Kyber)" },
            },
            rewards = {
                unique_item = true,
            },
            dialogue_on_accept = "Has demostrado ser un verdadero aliado. Necesito cristales Kyber... bueno, diamantes. 3 bastaran para forjar un verdadero sable de luz.",
            dialogue_on_complete = "La Fuerza fluye a traves de ti. Toma este sable, te lo has ganado. Que la Fuerza te acompanie, siempre.",
        },
    },
    side_quests = {
        {
            id = "luke_side_food",
            title = "Raciones para la Rebelion",
            description = "Luke necesita manzanas para las tropas rebeldes",
            repeatable = true,
            cooldown = 1800,
            objectives = {
                { type = "collect", item = "mcl_core:apple", count = 10,
                  description = "Recolectar 10 manzanas" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 3 } },
            },
            dialogue_on_accept = "La Rebelion necesita provisiones. Puedes conseguir 10 manzanas?",
            dialogue_on_complete = "Las tropas agradecen tu generosidad!",
        },
    },
}
