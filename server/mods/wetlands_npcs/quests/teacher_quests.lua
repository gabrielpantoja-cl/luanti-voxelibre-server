return {
    main_quests = {
        {
            id = "teacher_main_1",
            title = "Material Escolar",
            description = "El Maestro necesita libros y papel para sus clases",
            min_friendship = 0,
            objectives = {
                { type = "collect", item = "mcl_books:book", count = 3,
                  description = "Conseguir 3 libros de texto" },
                { type = "collect", item = "mcl_core:paper", count = 10,
                  description = "Reunir 10 papeles para apuntes" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 5 } },
            },
            dialogue_on_accept = "Mis estudiantes necesitan material! 3 libros y 10 papeles, por favor.",
            dialogue_on_complete = "Ahora mis estudiantes podran aprender mucho mas. Gracias!",
            next_quest = "teacher_main_2",
        },
        {
            id = "teacher_main_2",
            title = "Experimento de Ciencias",
            description = "El Maestro quiere hacer un experimento con materiales naturales",
            requires = "teacher_main_1",
            min_friendship = 1,
            objectives = {
                { type = "collect", item = "mcl_flowers:dandelion", count = 8,
                  description = "Recoger 8 dientes de leon" },
                { type = "collect", item = "mcl_core:sand", count = 10,
                  description = "Conseguir 10 bloques de arena" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 6 } },
            },
            dialogue_on_accept = "Vamos a estudiar la botanica y la geologia! Necesito flores y arena para los experimentos.",
            dialogue_on_complete = "El experimento fue un exito! Los estudiantes aprendieron mucho sobre la naturaleza.",
            next_quest = "teacher_main_3",
        },
        {
            id = "teacher_main_3",
            title = "La Leccion Final",
            description = "El Maestro prepara una leccion especial sobre compasion",
            requires = "teacher_main_2",
            min_friendship = 3,
            objectives = {
                { type = "collect", item = "mcl_books:book", count = 5,
                  description = "Reunir 5 libros (material de estudio)" },
                { type = "collect", item = "mcl_farming:wheat_item", count = 10,
                  description = "Cosechar 10 trigos (para demostrar el ciclo de la vida)" },
                { type = "collect", item = "mcl_flowers:poppy", count = 5,
                  description = "Recoger 5 amapolas (decoracion para la ceremonia)" },
            },
            rewards = {
                unique_item = true,
            },
            dialogue_on_accept = "Voy a dar la leccion mas importante: sobre la compasion hacia todos los seres. Necesito materiales para la ceremonia.",
            dialogue_on_complete = "Has aprendido la leccion mas valiosa: cuidar a todos los seres. Mereces este diploma de honor.",
        },
    },
    side_quests = {
        {
            id = "teacher_side_supplies",
            title = "Utiles Escolares",
            description = "El Maestro necesita papel para las tareas",
            repeatable = true,
            cooldown = 1200,
            objectives = {
                { type = "collect", item = "mcl_core:paper", count = 6,
                  description = "Traer 6 papeles" },
            },
            rewards = {
                items = { { name = "mcl_core:emerald", count = 2 } },
            },
            dialogue_on_accept = "Necesito papel para las tareas de hoy. 6 papeles me vendrian bien!",
            dialogue_on_complete = "Perfecto! Ahora los estudiantes pueden hacer sus ejercicios.",
        },
    },
}
