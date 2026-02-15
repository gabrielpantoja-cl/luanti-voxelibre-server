return {
    main_quests = {
        {
            id = "librarian_main_1",
            title = "Nuevos Libros para la Biblioteca",
            description = "El Bibliotecario necesita libros para expandir la coleccion",
            min_friendship = 0,
            objectives = {
                { type = "collect", item = "mcl_books:book", count = 5,
                  description = "Conseguir 5 libros" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 5 } },
            },
            dialogue_on_accept = "La biblioteca necesita mas libros! Puedes conseguir 5?",
            dialogue_on_complete = "Maravilloso! Estos libros enriqueceran a toda la comunidad.",
            next_quest = "librarian_main_2",
        },
        {
            id = "librarian_main_2",
            title = "Papel para Copias",
            description = "El Bibliotecario quiere hacer copias de textos antiguos",
            requires = "librarian_main_1",
            min_friendship = 1,
            objectives = {
                { type = "collect", item = "mcl_core:paper", count = 20,
                  description = "Reunir 20 papeles" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 6 } },
            },
            dialogue_on_accept = "Necesito papel para copiar textos antiguos antes de que se deterioren. 20 papeles, por favor.",
            dialogue_on_complete = "Ahora puedo preservar el conocimiento para las futuras generaciones!",
            next_quest = "librarian_main_3",
        },
        {
            id = "librarian_main_3",
            title = "La Gran Enciclopedia",
            description = "El Bibliotecario quiere crear la enciclopedia definitiva de Wetlands",
            requires = "librarian_main_2",
            min_friendship = 3,
            objectives = {
                { type = "collect", item = "mcl_books:book", count = 10,
                  description = "Reunir 10 libros" },
                { type = "collect", item = "mcl_core:paper", count = 15,
                  description = "Conseguir 15 papeles" },
            },
            rewards = {
                unique_item = true,
            },
            dialogue_on_accept = "Mi obra maestra: la Enciclopedia de Wetlands. Necesito muchos libros y papel. Es un proyecto ambicioso!",
            dialogue_on_complete = "La Enciclopedia esta lista! Toma una copia. El conocimiento es el mayor tesoro.",
        },
    },
    side_quests = {
        {
            id = "librarian_side_paper",
            title = "Suministro de Papel",
            description = "La biblioteca siempre necesita papel",
            repeatable = true,
            cooldown = 1200,
            objectives = {
                { type = "collect", item = "mcl_core:paper", count = 8,
                  description = "Traer 8 papeles" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 2 } },
            },
            dialogue_on_accept = "El papel se acaba rapido! Me traes 8?",
            dialogue_on_complete = "Gracias! Los libros no se escriben solos.",
        },
    },
}
