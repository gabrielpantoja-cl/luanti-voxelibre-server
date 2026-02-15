return {
    main_quests = {
        {
            id = "explorer_main_1",
            title = "Equipo de Expedicion",
            description = "El Explorador necesita palos y manzanas para una expedicion",
            min_friendship = 0,
            objectives = {
                { type = "collect", item = "mcl_core:stick", count = 15,
                  description = "Conseguir 15 palos (para antorchas y herramientas)" },
                { type = "collect", item = "mcl_core:apple", count = 10,
                  description = "Recolectar 10 manzanas (provisiones)" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 5 } },
            },
            dialogue_on_accept = "Voy a explorar cuevas profundas! Necesito palos para antorchas y manzanas para el camino.",
            dialogue_on_complete = "Perfecto! Con este equipo puedo explorar durante dias. Gracias, aventurero!",
            next_quest = "explorer_main_2",
        },
        {
            id = "explorer_main_2",
            title = "Muestras de Biomas",
            description = "El Explorador quiere catalogar los biomas con muestras de plantas",
            requires = "explorer_main_1",
            min_friendship = 1,
            objectives = {
                { type = "collect", item = "mcl_flowers:dandelion", count = 5,
                  description = "Recoger 5 dientes de leon (pradera)" },
                { type = "collect", item = "mcl_flowers:poppy", count = 5,
                  description = "Recoger 5 amapolas (bosque)" },
                { type = "collect", item = "mcl_core:cactus", count = 3,
                  description = "Encontrar 3 cactus (desierto)" },
            },
            rewards = {
                items = { { name = "mcl_core:diamond", count = 2 } },
            },
            dialogue_on_accept = "Quiero catalogar los biomas de Wetlands. Necesito muestras de diferentes plantas!",
            dialogue_on_complete = "Increible coleccion! Cada planta cuenta la historia de su bioma.",
            next_quest = "explorer_main_3",
        },
        {
            id = "explorer_main_3",
            title = "El Mapa Definitivo",
            description = "El Explorador quiere crear el mapa mas completo de Wetlands",
            requires = "explorer_main_2",
            min_friendship = 3,
            objectives = {
                { type = "collect", item = "mcl_core:paper", count = 15,
                  description = "Reunir 15 papeles (para el mapa)" },
                { type = "collect", item = "mcl_core:iron_ingot", count = 5,
                  description = "Conseguir 5 lingotes de hierro (brujula)" },
                { type = "collect", item = "mcl_core:gold_ingot", count = 3,
                  description = "Encontrar 3 lingotes de oro (decoracion del mapa)" },
            },
            rewards = {
                unique_item = true,
            },
            dialogue_on_accept = "Mi obra maestra: el mapa definitivo de Wetlands. Necesito papel, hierro para la brujula y oro para los detalles.",
            dialogue_on_complete = "El mapa esta completo! Toma una copia. Solo los verdaderos exploradores tienen uno de estos.",
        },
    },
    side_quests = {
        {
            id = "explorer_side_wood",
            title = "Madera para el Campamento",
            description = "El Explorador necesita palos para su campamento",
            repeatable = true,
            cooldown = 1200,
            objectives = {
                { type = "collect", item = "mcl_core:stick", count = 10,
                  description = "Traer 10 palos" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 2 } },
            },
            dialogue_on_accept = "Mi campamento necesita reparaciones. 10 palos bastaran!",
            dialogue_on_complete = "El campamento quedo perfecto! Gracias, companiero.",
        },
    },
}
