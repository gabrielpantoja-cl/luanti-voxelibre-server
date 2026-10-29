-- ============================================================
-- Trivia de Valdivia - por turnos, sobre formspec
-- Banco de 24 preguntas sobre Valdivia, el sur de Chile y su naturaleza.
-- Cada partida toma 8 al azar y mezcla las alternativas, asi que no se puede
-- memorizar "siempre la B".
-- ============================================================

local arcade = wetlands_snes

local PER_GAME = 8

-- q: pregunta | o: alternativas | a: indice de la correcta | e: explicacion
local BANK = {
    { q = "En que anio fue fundada Valdivia?",
      o = { "1552", "1620", "1810", "1450" }, a = 1,
      e = "Pedro de Valdivia fundo la ciudad en 1552." },
    { q = "Como se llama el rio principal que pasa por Valdivia?",
      o = { "Rio Bio-Bio", "Rio Calle-Calle", "Rio Maule", "Rio Baker" }, a = 2,
      e = "El Rio Calle-Calle (o Rio Valdivia) es el simbolo de la ciudad." },
    { q = "En que isla esta la Universidad Austral de Chile?",
      o = { "Isla Chiloe", "Isla Mocha", "Isla Teja", "Isla Robinson" }, a = 3,
      e = "La Universidad Austral esta en la hermosa Isla Teja." },
    { q = "De cuanto fue el terremoto de Valdivia de 1960?",
      o = { "9.5 Richter", "5.0 Richter", "7.0 Richter", "6.2 Richter" }, a = 1,
      e = "Fue el terremoto mas grande jamas registrado en el mundo: 9.5." },
    { q = "Que pais europeo dejo mas huella en Valdivia en el siglo XIX?",
      o = { "Francia", "Italia", "Alemania", "Portugal" }, a = 3,
      e = "Colonos alemanes llegaron en 1850 y cambiaron la ciudad." },
    { q = "Que lago fue clave en la catastrofe del terremoto de 1960?",
      o = { "Lago Llanquihue", "Lago Rinihue", "Lago Villarrica", "Lago Panguipulli" }, a = 2,
      e = "El Rinihuazo: el Lago Rinihue casi inunda la ciudad." },
    { q = "Que animal europeo abunda hoy en los bosques del sur de Chile?",
      o = { "Condor", "Jabali", "Llama", "Guanaco" }, a = 2,
      e = "El jabali fue traido por colonos y hoy vive suelto en el sur." },
    { q = "Cual es el ave nacional de Chile?",
      o = { "Condor andino", "Flamenco", "Pelicano", "Chucao" }, a = 1,
      e = "El condor andino aparece en el escudo de Chile." },
    { q = "Como se llama el mercado y paseo junto al rio en Valdivia?",
      o = { "Feria Fluvial", "Mercado Central", "La Vega", "Persa Bio-Bio" }, a = 1,
      e = "En la Feria Fluvial los lobos marinos esperan pescado." },
    { q = "Que animal marino se ve siempre en la Feria Fluvial?",
      o = { "Lobo marino", "Delfin rosado", "Orca", "Pinguino rey" }, a = 1,
      e = "Los lobos marinos son los vecinos mas famosos del muelle." },
    { q = "En que region de Chile esta Valdivia?",
      o = { "Region de Los Rios", "Region del Maule", "Region de Aysen", "Region de Coquimbo" }, a = 1,
      e = "Valdivia es la capital de la Region de Los Rios." },
    { q = "Que son los castillos de Niebla, Corral y Mancera?",
      o = { "Fuertes espanoles", "Castillos alemanes", "Hoteles antiguos", "Faros" }, a = 1,
      e = "Son fuertes espanoles del siglo XVII que defendian la bahia." },
    { q = "Que arbol gigante y milenario crece en el sur de Chile?",
      o = { "Alerce", "Palmera", "Eucalipto", "Cactus" }, a = 1,
      e = "El alerce puede vivir mas de 3000 anios. Esta protegido." },
    { q = "Que pajaro del bosque valdiviano canta fuerte y casi no vuela?",
      o = { "Chucao", "Tucan", "Loro barranquero", "Cisne negro" }, a = 1,
      e = "El chucao vive entre los helechos y su canto se oye lejisimo." },
    { q = "Que humedal cercano a Valdivia es santuario de cisnes?",
      o = { "Rio Cruces", "Salar de Atacama", "Laguna Verde", "Bahia Inutil" }, a = 1,
      e = "El Santuario del Rio Cruces protege al cisne de cuello negro." },
    { q = "Que animal es el cisne de cuello negro?",
      o = { "Un ave", "Un pez", "Un mamifero", "Un reptil" }, a = 1,
      e = "Es un ave acuatica y es el emblema natural de Valdivia." },
    { q = "Cual es la lluvia tipica de Valdivia?",
      o = { "Llueve mucho casi todo el anio", "Casi nunca llueve",
            "Solo llueve en verano", "Solo nieva" }, a = 1,
      e = "Valdivia es una de las ciudades mas lluviosas de Chile." },
    { q = "Que pueblo originario habita la zona de Valdivia?",
      o = { "Mapuche", "Aimara", "Rapa Nui", "Yagan" }, a = 1,
      e = "El pueblo mapuche habita la zona desde mucho antes de 1552." },
    { q = "Como se dice agua en mapudungun?",
      o = { "Ko", "Mapu", "Kuyen", "Antu" }, a = 1,
      e = "Ko es agua. Mapu es tierra, Antu es sol y Kuyen es luna." },
    { q = "Que significa Calle-Calle en mapudungun?",
      o = { "Lugar de la planta calle", "Dos calles", "Agua negra", "Rio grande" }, a = 1,
      e = "Viene de una planta parecida al iris que crece en la orilla." },
    { q = "Que puente cruza hacia la Isla Teja?",
      o = { "Puente Pedro de Valdivia", "Puente Chacao", "Puente Alto", "Puente Nuevo" }, a = 1,
      e = "El Puente Pedro de Valdivia conecta el centro con la Isla Teja." },
    { q = "Que animalito nativo y chiquitito vive en los bosques del sur?",
      o = { "Monito del monte", "Koala", "Mapache", "Ardilla gris" }, a = 1,
      e = "El monito del monte es un marsupial chileno, unico en el mundo." },
    { q = "Que se celebra en febrero en Valdivia sobre el rio?",
      o = { "Noche Valdiviana", "Ano Nuevo", "Fiesta de la Vendimia", "Carnaval de Verano" }, a = 1,
      e = "En la Noche Valdiviana desfilan barcos decorados y hay fuegos." },
    { q = "Por que no hay que alimentar a los animales silvestres?",
      o = { "Se enferman y pierden su forma de vivir", "Son muy caros",
            "Para que no engorden", "No pasa nada" }, a = 1,
      e = "La comida humana los enferma y los hace dependientes. Mejor mirar." },
}

local function pick_questions()
    local pool = {}
    for i = 1, #BANK do pool[i] = i end
    for i = #pool, 2, -1 do
        local j = math.random(i)
        pool[i], pool[j] = pool[j], pool[i]
    end

    local out = {}
    for k = 1, math.min(PER_GAME, #pool) do
        local src = BANK[pool[k]]
        -- Mezclar alternativas conservando cual es la correcta.
        local idx = { 1, 2, 3, 4 }
        for i = #idx, 2, -1 do
            local j = math.random(i)
            idx[i], idx[j] = idx[j], idx[i]
        end
        local opts, answer = {}, nil
        for pos, orig in ipairs(idx) do
            opts[pos] = src.o[orig]
            if orig == src.a then answer = pos end
        end
        out[k] = { q = src.q, o = opts, a = answer, e = src.e }
    end
    return out
end

local function question_formspec(s)
    local q  = s.qs[s.qi]
    local fs = {
        "formspec_version[4]",
        "size[11,9.2]",
        "bgcolor[#001a32;true]",
        "style_type[label;font=bold]",
        "label[3.6,0.6;TRIVIA DE VALDIVIA]",
        "style_type[label;font=normal]",
        "label[0.6,1.25;Pregunta " .. s.qi .. " de " .. #s.qs ..
            "     Correctas: " .. s.correct .. "     Puntos: " .. s.score .. "]",
        "style_type[label;font=bold;font_size=*1.1]",
        "label[0.6,2.1;" .. minetest.formspec_escape(q.q) .. "]",
        "style_type[label;font=normal;font_size=*1]",
    }
    for i, opt in ipairs(q.o) do
        local y = 2.8 + (i - 1) * 1.1
        fs[#fs + 1] = "button[0.6," .. y .. ";9.8,0.9;a" .. i .. ";" ..
            minetest.formspec_escape(opt) .. "]"
    end
    fs[#fs + 1] = "button_exit[4.3,8.1;2.4,0.8;quit;Salir]"
    return table.concat(fs)
end

local function feedback_formspec(s, ok, explanation)
    local header = ok and "CORRECTO!" or "INCORRECTO"
    local color  = ok and "#55dd77" or "#ee7755"
    local last   = s.qi > #s.qs
    return "formspec_version[4]" ..
        "size[11,5.8]" ..
        "bgcolor[#001a32;true]" ..
        "style_type[label;font=bold;font_size=*1.3]" ..
        "label[0.6,0.9;" .. header .. "]" ..
        "style_type[label;font=normal;font_size=*1]" ..
        "box[0.6,1.3;9.8,0.06;" .. color .. "]" ..
        "label[0.6,2.1;" .. minetest.formspec_escape(explanation) .. "]" ..
        "label[0.6,3.0;Puntos: " .. s.score .. "]" ..
        "button[4.3,4.6;2.4,0.8;next;" .. (last and "Resultado" or "Siguiente") .. "]"
end

local function final_formspec(s)
    local total = #s.qs
    local pct   = math.floor(s.correct / total * 100)
    local msg   = pct == 100 and "Experto total en Valdivia!" or
                  pct >= 70  and "Excelente conocimiento!" or
                  pct >= 40  and "Buen trabajo, sigue aprendiendo!" or
                  "Explora Valdivia y vuelve a intentarlo!"
    return "formspec_version[4]" ..
        "size[10,6]" ..
        "bgcolor[#001a32;true]" ..
        "style_type[label;font=bold]" ..
        "label[3.1,0.8;TRIVIA COMPLETADA]" ..
        "style_type[label;font=normal]" ..
        "label[0.6,2.0;Respondiste bien " .. s.correct .. " de " .. total ..
            " (" .. pct .. "%)   Puntos: " .. s.score .. "]" ..
        "label[0.6,2.7;" .. minetest.formspec_escape(msg) .. "]" ..
        "label[0.6,3.4;" .. minetest.formspec_escape(arcade.record_text(s)) .. "]" ..
        "button[0.6,4.8;4.2,0.8;new;Otra ronda]" ..
        "button_exit[5.2,4.8;4.2,0.8;quit;Cerrar]"
end

local function reset(s)
    s.qs      = pick_questions()
    s.qi      = 1
    s.correct = 0
    s.score   = 0
    s.over    = false
    s.rank    = nil
end

arcade.register_game({
    id       = "trivia",
    title    = "Trivia de Valdivia",
    desc     = "8 preguntas al azar de 24",
    realtime = false,

    on_start = function(s)
        reset(s)
        arcade.show(s, "q", question_formspec(s))
    end,

    on_fields = function(s, page, fields)
        if fields.new then
            reset(s)
            arcade.show(s, "q", question_formspec(s))
            return
        end
        if fields.quit then
            arcade.stop(s.pname, true)
            return
        end

        if page == "q" and not s.over then
            local q = s.qs[s.qi]
            for i = 1, #q.o do
                if fields["a" .. i] then
                    local ok = (i == q.a)
                    if ok then
                        s.correct = s.correct + 1
                        s.score   = s.score + 10
                    end
                    s.qi = s.qi + 1
                    arcade.show(s, "fb", feedback_formspec(s, ok, q.e))
                    return
                end
            end
            return
        end

        if page == "fb" and fields.next then
            if s.qi > #s.qs then
                if s.correct == #s.qs then s.score = s.score + 20 end
                arcade.game_over(s)
                arcade.show(s, "final", final_formspec(s))
            else
                arcade.show(s, "q", question_formspec(s))
            end
        end
    end,
})

-- Expuesto solo para los tests de tools/test_logic.py
arcade._trivia_bank = BANK
