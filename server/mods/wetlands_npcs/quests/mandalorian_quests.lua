return {
    main_quests = {
        {
            id = "mando_main_1",
            title = "Beskar para la Armadura",
            description = "El Mandalorian necesita hierro (beskar) para reparar su armadura",
            min_friendship = 0,
            objectives = {
                { type = "collect", item = "mcl_core:iron_ingot", count = 12,
                  description = "Conseguir 12 lingotes de hierro (beskar)" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 6 } },
            },
            dialogue_on_accept = "Mi armadura necesita reparaciones. Necesito 12 lingotes de beskar... digo, hierro.",
            dialogue_on_complete = "Buen trabajo. La Armera estaria orgullosa. Este es el Camino.",
            next_quest = "mando_main_2",
        },
        {
            id = "mando_main_2",
            title = "Provisiones para el Viaje",
            description = "Mando necesita preparar suministros para una expedicion larga",
            requires = "mando_main_1",
            min_friendship = 1,
            objectives = {
                { type = "collect", item = "mcl_core:apple", count = 20,
                  description = "Reunir 20 manzanas" },
                { type = "collect", item = "mcl_core:stick", count = 15,
                  description = "Conseguir 15 palos (para antorchas)" },
            },
            rewards = {
                items = { { name = "mcl_core:diamond", count = 2 } },
            },
            dialogue_on_accept = "Tengo una mision larga por delante. Necesito provisiones: manzanas y palos para antorchas.",
            dialogue_on_complete = "Bien equipado estoy ahora. Puedo proteger al Ninio por mas tiempo.",
            next_quest = "mando_main_3",
        },
        {
            id = "mando_main_3",
            title = "El Casco Legendario",
            description = "Mando necesita materiales raros para forjar un casco ceremonial",
            requires = "mando_main_2",
            min_friendship = 3,
            objectives = {
                { type = "collect", item = "mcl_core:diamond", count = 3,
                  description = "Encontrar 3 diamantes" },
                { type = "collect", item = "mcl_core:gold_ingot", count = 5,
                  description = "Conseguir 5 lingotes de oro" },
            },
            rewards = {
                unique_item = true,
            },
            dialogue_on_accept = "Has demostrado ser un aliado leal. Necesito materiales para forjar un casco ceremonial. Diamantes y oro.",
            dialogue_on_complete = "Este casco honra a nuestro clan. Toma uno igual. Ahora eres parte del Camino.",
        },
    },
    side_quests = {
        {
            id = "mando_side_bounty",
            title = "Contrato de Cazarrecompensas",
            description = "Mando necesita hierro para municion",
            repeatable = true,
            cooldown = 1800,
            objectives = {
                { type = "collect", item = "mcl_core:iron_ingot", count = 6,
                  description = "Traer 6 lingotes de hierro" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 4 } },
            },
            dialogue_on_accept = "Necesito hierro para completar un contrato. 6 lingotes.",
            dialogue_on_complete = "Contrato cumplido. Aqui tienes tu parte.",
        },
    },
}
