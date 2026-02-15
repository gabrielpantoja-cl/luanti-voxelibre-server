return {
    main_quests = {
        {
            id = "farmer_main_1",
            title = "Primera Cosecha",
            description = "El Agricultor necesita ayuda para recoger trigo",
            min_friendship = 0,
            objectives = {
                { type = "collect", item = "mcl_farming:wheat_item", count = 10,
                  description = "Recoger 10 trigos" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 5 } },
            },
            dialogue_on_accept = "Necesito ayuda con la cosecha. Puedes traerme 10 trigos?",
            dialogue_on_complete = "Excelente cosecha! Aqui tienes tu pago. La tierra agradece.",
            next_quest = "farmer_main_2",
        },
        {
            id = "farmer_main_2",
            title = "Diversificando Cultivos",
            description = "El Agricultor quiere expandir su huerto con diferentes vegetales",
            requires = "farmer_main_1",
            min_friendship = 1,
            objectives = {
                { type = "collect", item = "mcl_farming:carrot_item", count = 10,
                  description = "Traer 10 zanahorias" },
                { type = "collect", item = "mcl_farming:potato_item", count = 10,
                  description = "Traer 10 papas" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 8 } },
            },
            dialogue_on_accept = "Quiero expandir el huerto. Necesito zanahorias y papas para plantar nuevas parcelas.",
            dialogue_on_complete = "Con esta variedad, la comunidad comera mucho mejor! Gracias, amigo.",
            next_quest = "farmer_main_3",
        },
        {
            id = "farmer_main_3",
            title = "El Huerto Perfecto",
            description = "El Agricultor suenia con un huerto autosustentable",
            requires = "farmer_main_2",
            min_friendship = 3,
            objectives = {
                { type = "collect", item = "mcl_farming:wheat_item", count = 20,
                  description = "Cosechar 20 trigos" },
                { type = "collect", item = "mcl_farming:carrot_item", count = 15,
                  description = "Recoger 15 zanahorias" },
                { type = "collect", item = "mcl_books:book", count = 3,
                  description = "Conseguir 3 libros (manuales de agricultura)" },
            },
            rewards = {
                unique_item = true,
            },
            dialogue_on_accept = "Mi suenio es un huerto que alimente a toda la comunidad. Necesito muchos cultivos y libros para documentar las tecnicas.",
            dialogue_on_complete = "El huerto perfecto es una realidad! Toma estas semillas especiales, las cultive con todo mi carinio.",
        },
    },
    side_quests = {
        {
            id = "farmer_side_harvest",
            title = "Cosecha del Dia",
            description = "El Agricultor siempre necesita ayuda extra",
            repeatable = true,
            cooldown = 1200,
            objectives = {
                { type = "collect", item = "mcl_farming:wheat_item", count = 5,
                  description = "Recoger 5 trigos" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 2 } },
            },
            dialogue_on_accept = "Hoy hay mucho trabajo en el campo. Me ayudas con 5 trigos?",
            dialogue_on_complete = "Buen trabajo! La cosecha de hoy fue excelente.",
        },
    },
}
