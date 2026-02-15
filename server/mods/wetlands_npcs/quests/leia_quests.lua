return {
    main_quests = {
        {
            id = "leia_main_1",
            title = "Documentos de la Alianza",
            description = "Leia necesita papel para documentos diplomaticos",
            min_friendship = 0,
            objectives = {
                { type = "collect", item = "mcl_core:paper", count = 15,
                  description = "Conseguir 15 papeles" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 5 } },
            },
            dialogue_on_accept = "La Alianza Rebelde necesita documentos diplomaticos. Puedes conseguir 15 papeles?",
            dialogue_on_complete = "Estos documentos ayudaran a unir mas sistemas contra el Imperio. Gracias!",
            next_quest = "leia_main_2",
        },
        {
            id = "leia_main_2",
            title = "Tesoros de Alderaan",
            description = "Leia quiere preservar reliquias de su planeta destruido",
            requires = "leia_main_1",
            min_friendship = 1,
            objectives = {
                { type = "collect", item = "mcl_core:gold_ingot", count = 5,
                  description = "Reunir 5 lingotes de oro (reliquias)" },
                { type = "collect", item = "mcl_books:book", count = 3,
                  description = "Encontrar 3 libros (archivos)" },
            },
            rewards = {
                items = { { name = "mcl_core:diamond", count = 2 } },
            },
            dialogue_on_accept = "Quiero preservar la memoria de Alderaan. Necesito oro para reliquias y libros para los archivos.",
            dialogue_on_complete = "Alderaan vivira en nuestra memoria para siempre. Gracias por ayudar.",
            next_quest = "leia_main_3",
        },
        {
            id = "leia_main_3",
            title = "La Esperanza de la Galaxia",
            description = "Leia necesita construir un comunicador holografico para la causa rebelde",
            requires = "leia_main_2",
            min_friendship = 3,
            objectives = {
                { type = "collect", item = "mcl_core:diamond", count = 2,
                  description = "Encontrar 2 diamantes (componentes)" },
                { type = "collect", item = "mcl_core:gold_ingot", count = 3,
                  description = "Conseguir 3 lingotes de oro (circuitos)" },
                { type = "collect", item = "mcl_core:iron_ingot", count = 5,
                  description = "Reunir 5 lingotes de hierro (carcasa)" },
            },
            rewards = {
                unique_item = true,
            },
            dialogue_on_accept = "Voy a construir un comunicador holografico. Necesito diamantes, oro y hierro. Es nuestra unica esperanza.",
            dialogue_on_complete = "El comunicador esta listo. Toma una copia, ahora somos aliados para siempre.",
        },
    },
    side_quests = {
        {
            id = "leia_side_supplies",
            title = "Suministros Rebeldes",
            description = "La Rebelion siempre necesita comida",
            repeatable = true,
            cooldown = 1800,
            objectives = {
                { type = "collect", item = "mcl_core:apple", count = 12,
                  description = "Recolectar 12 manzanas" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 3 } },
            },
            dialogue_on_accept = "Las tropas rebeldes necesitan comida. 12 manzanas ayudarian mucho.",
            dialogue_on_complete = "La Rebelion te lo agradece!",
        },
    },
}
