return {
    main_quests = {
        {
            id = "anakin_main_1",
            title = "Piezas de Droide",
            description = "Anakin necesita hierro para reparar a R2-D2",
            min_friendship = 0,
            objectives = {
                { type = "collect", item = "mcl_core:iron_ingot", count = 8,
                  description = "Conseguir 8 lingotes de hierro" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 5 } },
            },
            dialogue_on_accept = "R2-D2 necesita reparaciones urgentes! Necesito 8 lingotes de hierro.",
            dialogue_on_complete = "R2 ya esta como nuevo! Gracias, piloto!",
            next_quest = "anakin_main_2",
        },
        {
            id = "anakin_main_2",
            title = "Combustible para Podracing",
            description = "Anakin quiere preparar su podracer con materiales especiales",
            requires = "anakin_main_1",
            min_friendship = 1,
            objectives = {
                { type = "collect", item = "mcl_core:gold_ingot", count = 5,
                  description = "Conseguir 5 lingotes de oro" },
            },
            rewards = {
                items = { { name = "mcl_core:diamond", count = 2 } },
            },
            dialogue_on_accept = "Mi podracer necesita componentes de oro para los motores. 5 lingotes bastaran!",
            dialogue_on_complete = "Con esto mi podracer sera imparable! Ahora soy un podracer!",
            next_quest = "anakin_main_3",
        },
        {
            id = "anakin_main_3",
            title = "El Taller del Elegido",
            description = "Anakin necesita materiales raros para su taller definitivo",
            requires = "anakin_main_2",
            min_friendship = 3,
            objectives = {
                { type = "collect", item = "mcl_core:diamond", count = 3,
                  description = "Encontrar 3 diamantes para herramientas" },
                { type = "collect", item = "mcl_core:iron_ingot", count = 10,
                  description = "Conseguir 10 lingotes de hierro" },
            },
            rewards = {
                unique_item = true,
            },
            dialogue_on_accept = "He decidido construir el taller definitivo. Necesito diamantes y hierro. Mucho hierro.",
            dialogue_on_complete = "Este taller es digno de un Jedi mecanico! Toma esta herramienta, la hice especialmente para ti.",
        },
    },
    side_quests = {
        {
            id = "anakin_side_scrap",
            title = "Chatarra Util",
            description = "Anakin siempre necesita hierro extra para sus proyectos",
            repeatable = true,
            cooldown = 1800,
            objectives = {
                { type = "collect", item = "mcl_core:iron_ingot", count = 5,
                  description = "Traer 5 lingotes de hierro" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 3 } },
            },
            dialogue_on_accept = "Siempre necesito mas metal para mis proyectos. 5 lingotes de hierro?",
            dialogue_on_complete = "Perfecto, mas material para inventar!",
        },
    },
}
