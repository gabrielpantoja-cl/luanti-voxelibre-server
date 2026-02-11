-- Wetlands NPCs v2.0.0 - Star Wars Edition
-- NPCs interactivos Star Wars para servidor Wetlands (7+ anios)
-- Compatible con VoxeLibre v0.90.1 (mcl_mobs)

-- ============================================================================
-- 1. INICIALIZACION Y VERIFICACION
-- ============================================================================

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

-- Verificar dependencias criticas
if not minetest.get_modpath("mcl_mobs") then
    minetest.log("error", "[" .. modname .. "] mcl_mobs es requerido!")
    return
end

if not minetest.get_modpath("mcl_core") then
    minetest.log("error", "[" .. modname .. "] mcl_core es requerido!")
    return
end

if not mcl_mobs.register_mob then
    minetest.log("error", "[" .. modname .. "] mcl_mobs.register_mob no disponible!")
    return
end

-- Namespace global
wetlands_npcs = {}
wetlands_npcs.version = "2.0.0"

local function log(level, message)
    minetest.log(level, "[" .. modname .. "] " .. message)
end

log("info", "Initializing Wetlands NPCs v" .. wetlands_npcs.version .. " (Star Wars Edition)")

-- ============================================================================
-- 2. SISTEMA DE SONIDO (debe cargarse ANTES de ai_behaviors.lua)
-- ============================================================================

function wetlands_npcs.play_npc_voice(npc_type, pos)
    local sound_config = wetlands_npcs.config and wetlands_npcs.config.sounds
    if sound_config and not sound_config.enabled then
        return
    end

    local variant = math.random(1, 3)
    local sound_name = "wetlands_npc_talk_" .. npc_type .. variant
    local gain = (sound_config and sound_config.gain) or 0.8
    local max_dist = (sound_config and sound_config.max_hear_distance) or 20

    minetest.sound_play(sound_name, {
        pos = pos,
        gain = gain,
        max_hear_distance = max_dist,
    })
end

-- Tabla de NPCs Star Wars (para logica condicional)
local STAR_WARS_NPCS = {luke = true, anakin = true, yoda = true, mandalorian = true}
wetlands_npcs.STAR_WARS_NPCS = STAR_WARS_NPCS

-- Reproducir audio iconico de Star Wars (1 clip unico por personaje)
function wetlands_npcs.play_npc_iconic(npc_type, pos)
    if not STAR_WARS_NPCS[npc_type] then return end
    local sound_config = wetlands_npcs.config and wetlands_npcs.config.sounds
    if sound_config and not sound_config.enabled then return end

    local sound_name = "wetlands_npc_iconic_" .. npc_type
    local gain = (sound_config and sound_config.gain) or 0.8
    local max_dist = (sound_config and sound_config.max_hear_distance) or 20

    minetest.sound_play(sound_name, {
        pos = pos,
        gain = gain,
        max_hear_distance = max_dist,
    })
end

function wetlands_npcs.play_npc_greeting(npc_type, pos)
    local sound_config = wetlands_npcs.config and wetlands_npcs.config.sounds
    if sound_config and not sound_config.enabled then
        return
    end

    local variant = math.random(1, 2)
    local sound_name = "wetlands_npc_greet_" .. npc_type .. variant
    local gain = (sound_config and sound_config.gain) or 0.8
    local max_dist = (sound_config and sound_config.max_hear_distance) or 20

    minetest.sound_play(sound_name, {
        pos = pos,
        gain = gain,
        max_hear_distance = max_dist,
    })
end

-- ============================================================================
-- CARGAR MODULOS
-- ============================================================================

dofile(modpath .. "/config.lua")
log("info", "Configuration system loaded")

dofile(modpath .. "/ai_behaviors.lua")
log("info", "AI Behaviors system loaded (v" .. wetlands_npcs.behaviors.version .. ")")

-- ============================================================================
-- 3. NOMBRES DE DISPLAY PARA CADA NPC
-- ============================================================================

wetlands_npcs.display_names = {
    -- Star Wars
    luke = "Luke Skywalker",
    anakin = "Anakin Skywalker",
    yoda = "Baby Yoda",
    mandalorian = "Mandalorian",
    -- Clasicos
    farmer = "Agricultor",
    librarian = "Bibliotecario",
    teacher = "Maestro",
    explorer = "Explorador",
}

-- ============================================================================
-- 4. SISTEMA DE DIALOGOS - STAR WARS FRIKI
-- ============================================================================

wetlands_npcs.dialogues = {
    luke = {
        greetings = {
            "Que la Fuerza te acompanie, amigo!",
            "Hey! Soy Luke. Alguna vez has volado un X-Wing? Tiene 4 alas que se abren en forma de X!",
            "Bienvenido! La galaxia necesita heroes como tu.",
            "Saludos! Sabias que creci en Tatooine? Tiene DOS soles, los atardeceres son dobles!",
            "Hola! Mi padre fue Darth Vader, pero al final volvio al lado luminoso.",
            "Hey! Sabias que la Estrella de la Muerte media 160 km de diametro? Mas grande que muchas lunas!",
            "Hola! Han Solo hizo el recorrido Kessel en menos de 12 parsecs con el Halcon Milenario!",
        },
        about_work = {
            "Soy un Caballero Jedi. Mi maestro fue Yoda, el mas sabio de todos. Vivio 900 anios!",
            "Destrui la primera Estrella de la Muerte con un disparo imposible!",
            "Mi sable laser es verde. Lo construi con un cristal Kyber que encontre en una cueva en Dagobah.",
            "Entreno nuevos Jedi. La Fuerza tiene un lado luminoso y uno oscuro, el equilibrio es la clave.",
            "Mi mejor amigo es Han Solo. Juntos salvamos la galaxia mas de una vez.",
            "Los sables laser funcionan con cristales Kyber. Cada Jedi encuentra el suyo en una cueva especial.",
        },
    },
    anakin = {
        greetings = {
            "Saludos! Soy Anakin, el mejor piloto de la galaxia.",
            "Hey! Quieres ver mis habilidades con el sable laser? Puede cortar casi cualquier material!",
            "Bienvenido! Construi a C-3PO con piezas recicladas a los 9 anios. Habla 6 millones de idiomas!",
            "Hola! La Fuerza es fuerte en ti, puedo sentirlo. Los midi-clorianos no mienten.",
            "Que bueno verte! Acabamos de ganar una batalla en las Guerras Clon.",
            "Hey! Sabias que las carreras de vainas alcanzan 900 km/h? Los motores son como cohetes gemelos!",
        },
        about_work = {
            "Soy Caballero Jedi y General en las Guerras Clon. Mi maestro es Obi-Wan.",
            "Cuando era ninio gane una carrera de vainas en Tatooine. Fui el primer humano en hacerlo!",
            "R2-D2 me ha salvado la vida como 100 veces. Es un droide astromecanoico que puede hackear cualquier computadora!",
            "Lucho para proteger a los inocentes. Esa es la mision de un Jedi.",
            "Mi sable laser es azul, el color de los Jedi Guardianes. Solo el beskar puede resistir un corte.",
            "Los Clones fueron creados en Kamino, un planeta oceano con tormentas constantes. Increible, no?",
            "El Templo Jedi en Coruscant tiene miles de anios de antiguedad y 5 torres enormes.",
        },
    },
    yoda = {
        greetings = {
            "Hmm! Visitante tenemos. Bienvenido eres.",
            "La Fuerza, en ti siento. Fuerte es.",
            "Hola! Cosas magicas, mostrarte puedo.",
            "Pequenio soy, pero poderoso. Juzgar por tamano, no debes.",
            "Gu gu! ...digo, bienvenido! Mi especie, un misterio es. Solo 3 hemos aparecido!",
            "Hmm! Los Jawas de Tatooine, droides viejos reciclan. Los mejores recicladores, son!",
        },
        about_work = {
            "Con la Fuerza, cosas mover puedo. Pesadas o ligeras, igual da.",
            "Maestros Jedi me cuidan. Din Djarin, mi protector es. Su beskar, sables laser bloquea!",
            "Ranas me gustan mucho. Deliciosas son! ...no me juzgues.",
            "50 anios tengo, pero un bebe aun soy. Mi especie, lenta crece.",
            "La Fuerza, usarla sin pensar puedo. Los midi-clorianos de Anakin, mas de 20.000 por celula eran!",
            "El Halcon Milenario, chatarra parece, pero la nave mas rapida del universo es.",
            "Los Jedi mas viejos, en fantasmas de la Fuerza convertirse podian. Increible, si.",
        },
    },
    mandalorian = {
        greetings = {
            "Este es el Camino.",
            "Saludos. No me quito el casco. Es la tradicion.",
            "Bienvenido. Si necesitas proteccion, estoy aqui.",
            "Hola. Tengo una mision, pero puedo hablar un momento.",
            "Soy Mandaloriano. Mi honor es mi armadura.",
        },
        about_work = {
            "Soy cazarrecompensas. Pero ahora mi mision es proteger al Ninio.",
            "Mi armadura es de beskar puro. Fue forjada por la Armera de mi clan.",
            "El Darksaber es la espada mas importante de Mandalore. Quien la porta, lidera.",
            "He viajado por toda la galaxia. Cada planeta tiene sus peligros y maravillas.",
            "Mi nave se llamaba Razor Crest. Era vieja pero confiable. La extranio.",
        },
        education = {
            "Dato friki: El beskar se mina solo en Mandalore. Es tan raro que vale mas que el oro.",
            "Dato friki: El Darksaber fue creado por Tarre Vizsla, el primer Mandaloriano Jedi. Tiene 1000 anios!",
            "Dato friki: Los Mandalorianos tienen un codigo de honor estricto. Nunca se quitan el casco frente a otros.",
            "Dato friki: Boba Fett es el clon mas famoso de Jango Fett. Su armadura tambien es de beskar.",
            "Dato friki: El Halcon Milenario gano el record Kessel en 12 parsecs. Un parsec son 3.26 anios luz!",
            "Dato friki: Los jetpacks Mandalorianos usan combustible de propulsion ionica. Alcanzan 145 km/h!",
            "Dato friki: La Tribu Mandaloriana vive escondida. Solo un guerrero sale a la vez para conseguir recursos.",
        },
    },
    -- NPCs Clasicos
    farmer = {
        greetings = {
            "Hola! Cultivo vegetales frescos y saludables para la comunidad.",
            "Buenos dias! Te gustaria aprender sobre agricultura sostenible?",
            "Bienvenido! Cultivamos solo alimentos de origen vegetal.",
            "Que gusto verte! Hoy las zanahorias estan creciendo muy bien.",
        },
        about_work = {
            "Trabajo la tierra cada dia. Las plantas necesitan agua, luz y cuidado.",
            "La agricultura sostenible alimenta al mundo sin daniar el planeta.",
            "Las abejas polinizan mis cultivos. Sin ellas no habria cosecha!",
            "Compostar los restos de comida crea el mejor fertilizante natural.",
        },
        education = {
            "Las plantas liberan oxigeno durante el dia. Los arboles son los pulmones del planeta.",
            "Una semilla de trigo puede producir cientos de granos. La naturaleza es generosa!",
            "El agua subterranea alimenta las raices. Por eso cuidar los rios es tan importante.",
        },
    },
    librarian = {
        greetings = {
            "Saludos! Guardo el conocimiento de nuestra comunidad.",
            "Hola! Buscas aprender algo nuevo hoy?",
            "Bienvenido! Aqui encontraras libros sobre compasion y ciencia.",
            "Pasa, pasa! Tengo historias maravillosas que compartir.",
        },
        about_work = {
            "Los libros preservan el conocimiento de generaciones.",
            "La lectura expande tu mente y ayuda a entender el mundo.",
            "Cada libro es una ventana a un mundo diferente. Cual quieres abrir?",
        },
        education = {
            "Sabias que leer 30 minutos al dia mejora tu vocabulario?",
            "Los primeros libros se escribian a mano. Tardaban meses en completarse!",
            "La biblioteca mas grande del mundo tiene millones de libros.",
        },
    },
    teacher = {
        greetings = {
            "Hola! Me encanta enseniar sobre ciencia y naturaleza.",
            "Buenos dias! Listo para aprender algo fascinante?",
            "La educacion es la herramienta mas poderosa para cambiar el mundo.",
        },
        about_work = {
            "Ensenio ciencia, matematicas y compasion hacia todos los seres.",
            "Mi trabajo es despertar la curiosidad en las mentes jovenes.",
            "Ensenio que todos los seres merecen respeto y cuidado.",
        },
        education = {
            "Sabias que los animales sienten emociones como nosotros?",
            "Tu cerebro tiene mas conexiones que estrellas hay en la galaxia!",
            "El agua cubre el 70% de la Tierra, pero solo el 3% es agua dulce.",
        },
    },
    explorer = {
        greetings = {
            "Hola aventurero! He viajado por todos los biomas del mundo.",
            "Saludos! Te gustaria escuchar historias de mis viajes?",
            "Hola! Acabo de volver de explorar unas cuevas increibles.",
        },
        about_work = {
            "Exploro el mundo y estudio diferentes ecosistemas.",
            "Cada bioma tiene plantas y animales unicos que merecen proteccion.",
            "Mi brujula y mi mapa son mis mejores amigos en las expediciones.",
        },
        education = {
            "Sabias que los bosques producen gran parte del oxigeno que respiramos?",
            "La biodiversidad es fundamental para el equilibrio del planeta.",
            "Cada gota de agua que bebes ha existido desde que se formo la Tierra!",
        },
    },
}

local function get_dialogue(npc_type, category)
    local dialogues = wetlands_npcs.dialogues[npc_type]
    if not dialogues or not dialogues[category] then
        return "..."
    end
    local options = dialogues[category]
    return options[math.random(1, #options)]
end

-- ============================================================================
-- 5. SISTEMA DE COMERCIO TEMATICO
-- ============================================================================

wetlands_npcs.trades = {
    luke = {
        {give = "mcl_core:stick 2", wants = "mcl_core:emerald 1"},       -- "Sable laser" (palos)
        {give = "mcl_books:book 1", wants = "mcl_core:emerald 2"},       -- Textos Jedi
        {give = "mcl_core:apple 10", wants = "mcl_core:emerald 1"},      -- Raciones
    },
    anakin = {
        {give = "mcl_core:iron_ingot 3", wants = "mcl_core:emerald 2"},  -- Piezas mecanicas
        {give = "mcl_core:stick 2", wants = "mcl_core:emerald 1"},       -- Sable laser
        {give = "mcl_core:gold_ingot 1", wants = "mcl_core:emerald 3"},  -- Piezas de droide
    },
    yoda = {
        {give = "mcl_core:emerald 3", wants = "mcl_core:emerald 1"},     -- Multiplicador de Fuerza
        {give = "mcl_books:book 2", wants = "mcl_core:emerald 3"},       -- Sabiduria antigua
        {give = "mcl_farming:carrot_item 10", wants = "mcl_core:emerald 1"}, -- Snacks (le gustan)
    },
    mandalorian = {
        {give = "mcl_core:iron_ingot 5", wants = "mcl_core:emerald 2"},  -- Beskar (hierro)
        {give = "mcl_core:diamond 1", wants = "mcl_core:emerald 5"},     -- Equipo raro
        {give = "mcl_core:apple 10", wants = "mcl_core:emerald 1"},      -- Provisiones
    },
    -- Clasicos
    farmer = {
        {give = "mcl_farming:carrot_item 5", wants = "mcl_core:emerald 1"},
        {give = "mcl_farming:potato_item 5", wants = "mcl_core:emerald 1"},
        {give = "mcl_farming:wheat_item 10", wants = "mcl_core:emerald 2"},
    },
    librarian = {
        {give = "mcl_books:book 1", wants = "mcl_core:emerald 3"},
        {give = "mcl_core:paper 10", wants = "mcl_core:emerald 1"},
    },
    teacher = {
        {give = "mcl_books:book 2", wants = "mcl_core:emerald 5"},
        {give = "mcl_core:paper 15", wants = "mcl_core:emerald 2"},
    },
    explorer = {
        {give = "mcl_core:apple 10", wants = "mcl_core:emerald 2"},
        {give = "mcl_core:stick 20", wants = "mcl_core:emerald 1"},
    },
}

-- Mostrar formspec de interaccion
local function show_interaction_formspec(player_name, npc_type, display_name)
    if not player_name or not npc_type then
        log("error", "show_interaction_formspec called with nil parameters")
        return
    end

    local name_str = display_name or wetlands_npcs.display_names[npc_type] or npc_type
    name_str = minetest.formspec_escape(name_str)

    -- Tercer boton depende del tipo de NPC
    local third_button
    if STAR_WARS_NPCS[npc_type] then
        third_button = "button[0.5,3.5;9,0.8;play_iconic;Probar audio]"
    else
        third_button = "button[0.5,3.5;9,0.8;dialogue_education;Dato educativo]"
    end

    local formspec = "formspec_version[4]" ..
        "size[10,7]" ..
        "label[0.5,0.5;" .. name_str .. "]" ..
        "button[0.5,1.5;9,0.8;dialogue_greeting;Saludar]" ..
        "button[0.5,2.5;9,0.8;dialogue_work;Sobre su historia]" ..
        third_button ..
        "button[0.5,4.5;9,0.8;trade;Comerciar]" ..
        "button[0.5,5.5;9,0.8;close;Cerrar]"

    local success, err = pcall(function()
        minetest.show_formspec(player_name, "wetlands_npcs:interact_" .. npc_type, formspec)
    end)

    if not success then
        log("error", "Failed to show formspec: " .. tostring(err))
        minetest.chat_send_player(player_name, "[NPC] Error al mostrar dialogo. Intenta de nuevo.")
    end
end

-- Mostrar formspec de comercio
local function show_trade_formspec(player_name, npc_type)
    if not player_name or not npc_type then
        log("error", "show_trade_formspec called with nil parameters")
        return
    end

    local trades = wetlands_npcs.trades[npc_type]
    if not trades then
        minetest.chat_send_player(player_name, "[NPC] No tengo nada para comerciar ahora.")
        return
    end

    local display = wetlands_npcs.display_names[npc_type] or npc_type
    local formspec = "formspec_version[4]" ..
        "size[12,11]" ..
        "label[0.5,0.5;Comercio - " .. minetest.formspec_escape(display) .. "]" ..
        "label[0.5,1;Ofrece esmeraldas por items:]" ..
        "list[current_player;main;0.5,6;8,4;]"

    local y = 2
    for i, trade in ipairs(trades) do
        formspec = formspec .. "label[0.5," .. y .. ";" .. i .. ". " ..
                   minetest.formspec_escape(trade.give) .. " <- " ..
                   minetest.formspec_escape(trade.wants) .. "]"
        formspec = formspec .. "button[7," .. (y-0.2) .. ";3,0.8;trade_" .. i .. ";Comerciar]"
        y = y + 1
    end

    minetest.show_formspec(player_name, "wetlands_npcs:trade_" .. npc_type, formspec)
end

-- Manejar clicks en formspecs
minetest.register_on_player_receive_fields(function(player, formname, fields)
    -- Formspec de interaccion
    if formname:find("^wetlands_npcs:interact_") then
        local npc_type = formname:gsub("^wetlands_npcs:interact_", "")
        local player_name = player:get_player_name()
        local player_pos = player:get_pos()
        local display = wetlands_npcs.display_names[npc_type] or npc_type

        if fields.dialogue_greeting then
            local msg = get_dialogue(npc_type, "greetings")
            minetest.chat_send_player(player_name, "[" .. display .. "] " .. msg)
            wetlands_npcs.play_npc_voice(npc_type, player_pos)
        elseif fields.dialogue_work then
            local msg = get_dialogue(npc_type, "about_work")
            minetest.chat_send_player(player_name, "[" .. display .. "] " .. msg)
            wetlands_npcs.play_npc_voice(npc_type, player_pos)
        elseif fields.play_iconic then
            -- Boton "Probar audio" - reproduce clip iconico de Star Wars
            wetlands_npcs.play_npc_iconic(npc_type, player_pos)
            local iconic_phrases = {
                luke = "May the Force be with you...",
                anakin = "This is where the fun begins!",
                yoda = "Do or do not... there is no try.",
                mandalorian = "This is the way.",
            }
            local phrase = iconic_phrases[npc_type] or "..."
            minetest.chat_send_player(player_name, "[" .. display .. "] " .. phrase)
        elseif fields.dialogue_education then
            -- Boton "Dato educativo" (solo NPCs clasicos)
            local msg = get_dialogue(npc_type, "education")
            minetest.chat_send_player(player_name, "[" .. display .. "] " .. msg)
            wetlands_npcs.play_npc_voice(npc_type, player_pos)
        elseif fields.trade then
            show_trade_formspec(player_name, npc_type)
        end
    end

    -- Formspec de comercio
    if formname:find("^wetlands_npcs:trade_") then
        local npc_type = formname:gsub("^wetlands_npcs:trade_", "")
        local trades = wetlands_npcs.trades[npc_type]
        if not trades then return end

        for field, _ in pairs(fields) do
            if field:find("^trade_") then
                local index_str = field:gsub("^trade_", "")
                local trade_index = tonumber(index_str)
                if not trade_index then break end
                local trade = trades[trade_index]

                if trade then
                    local player_name = player:get_player_name()
                    local inv = player:get_inventory()

                    local wants_item, wants_count = trade.wants:match("(%S+)%s+(%d+)")
                    wants_count = tonumber(wants_count) or 1

                    if inv:contains_item("main", wants_item .. " " .. wants_count) then
                        inv:remove_item("main", wants_item .. " " .. wants_count)
                        inv:add_item("main", trade.give)
                        minetest.chat_send_player(player_name, "[Comercio exitoso] Gracias por tu intercambio!")
                    else
                        minetest.chat_send_player(player_name, "[Comercio fallido] No tienes suficientes items.")
                    end
                end
            end
        end
    end
end)

-- ============================================================================
-- 6. REGISTRO DE NPCs CON MCL_MOBS
-- ============================================================================

-- Animaciones del modelo humano (mcl_armor_character.b3d)
local HUMAN_ANIMATION = {
    stand_start = 0, stand_end = 79,
    walk_start = 168, walk_end = 187, walk_speed = 30,
    run_start = 440, run_end = 459, run_speed = 30,
    sit_start = 81, sit_end = 160,
}

local function register_npc(name, def)
    local full_name = modname .. ":" .. name

    -- mcl_armor_character.b3d expects 3 texture layers: {skin, armor, cape}
    local skin_tex = "wetlands_npc_luke.png"
    if def.textures and type(def.textures) == "table" then
        if type(def.textures[1]) == "table" then
            skin_tex = def.textures[1][1] or skin_tex
        elseif type(def.textures[1]) == "string" then
            skin_tex = def.textures[1]
        end
    else
        log("warning", "Missing textures for " .. name .. ", using default")
    end
    local validated_textures = {{skin_tex, "blank.png", "blank.png"}}

    local mob_def = {
        description = def.description or S(name),
        type = "npc",
        spawn_class = "passive",
        passive = true,

        xp_min = 0,
        xp_max = 0,

        initial_properties = {
            hp_min = 20,
            hp_max = 20,
        },

        collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
        visual = "mesh",
        mesh = "wetlands_npc_human.b3d",
        textures = validated_textures,
        makes_footstep_sound = true,

        walk_velocity = wetlands_npcs.config.movement.walk_velocity,
        run_velocity = wetlands_npcs.config.movement.run_velocity,

        drops = {},
        can_despawn = false,

        animation = HUMAN_ANIMATION,

        view_range = 16,
        fear_height = 4,
        jump = true,
        walk_chance = 33,

        custom_villager_type = name,

        armor_groups = {immortal = 1},

        on_activate = function(self, staticdata, dtime_s)
            self.object:set_armor_groups({immortal = 1})
        end,

        do_custom = function(self, dtime)
            self._immortal_check = (self._immortal_check or 0) + dtime
            if self._immortal_check > 3 then
                self._immortal_check = 0
                local armor = self.object:get_armor_groups()
                if not armor.immortal or armor.immortal ~= 1 then
                    self.object:set_armor_groups({immortal = 1})
                    log("warning", "Re-applied immortal armor to " .. (self.custom_villager_type or "unknown"))
                end
            end
        end,

        on_rightclick = function(self, clicker)
            if not clicker or not clicker:is_player() then return end

            -- Auto-fix para NPCs sin tipo
            if not self.custom_villager_type and self.name then
                local npc_type = self.name:match("wetlands_npcs:(.+)")
                if npc_type then
                    self.custom_villager_type = npc_type
                    log("warning", "Auto-fixed NPC type: " .. npc_type)
                else
                    log("error", "Could not extract NPC type from: " .. self.name)
                    return
                end
            end

            if not self.custom_villager_type then
                log("error", "on_rightclick: NPC without type")
                return
            end

            local player_name = clicker:get_player_name()
            if not player_name or player_name == "" then return end

            local display_name = wetlands_npcs.display_names[self.custom_villager_type]
                or self.custom_villager_type

            local pos = self.object:get_pos()
            if pos then
                wetlands_npcs.play_npc_voice(self.custom_villager_type, pos)
            end

            local success, err = pcall(function()
                show_interaction_formspec(player_name, self.custom_villager_type, display_name)
            end)

            if not success then
                log("error", "on_rightclick failed: " .. tostring(err))
                minetest.chat_send_player(player_name, "[Servidor] Error al interactuar.")
            end
        end,

        on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
            self.object:set_armor_groups({immortal = 1})
            self.object:set_hp(self.object:get_properties().hp_max or 20)
            if puncher and puncher:is_player() then
                minetest.chat_send_player(puncher:get_player_name(),
                    "[Servidor] Los NPCs de Wetlands son tus amigos. No puedes hacerles danio!")
            end
            return true
        end,
    }

    -- Inyectar sistema de comportamientos AI
    wetlands_npcs.behaviors.inject_into_mob(mob_def)

    mcl_mobs.register_mob(full_name, mob_def)
    log("info", "Registered Star Wars NPC: " .. name)
end

-- ============================================================================
-- 6A. DEFINICION DE LOS 4 NPCs STAR WARS
-- ============================================================================

register_npc("luke", {
    description = S("Luke Skywalker"),
    textures = {{"wetlands_npc_luke.png"}},
})

register_npc("anakin", {
    description = S("Anakin Skywalker"),
    textures = {{"wetlands_npc_anakin.png"}},
})

register_npc("yoda", {
    description = S("Baby Yoda"),
    textures = {{"wetlands_npc_yoda.png"}},
})

register_npc("mandalorian", {
    description = S("Mandalorian"),
    textures = {{"wetlands_npc_mandalorian.png"}},
})

-- ============================================================================
-- 6B. NPCs CLASICOS (modelo villager)
-- ============================================================================

-- Animaciones del modelo villager
local VILLAGER_ANIMATION = {
    stand_start = 0, stand_end = 0,
    walk_start = 0, walk_end = 40, walk_speed = 25,
    run_start = 0, run_end = 40, run_speed = 25,
}

local function register_classic_npc(name, def)
    local full_name = modname .. ":" .. name

    local validated_textures = def.textures
    if type(validated_textures[1]) ~= "table" then
        validated_textures = {validated_textures}
    end

    local mob_def = {
        description = def.description or S(name),
        type = "npc",
        spawn_class = "passive",
        passive = true,
        xp_min = 0, xp_max = 0,
        initial_properties = { hp_min = 20, hp_max = 20 },
        collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
        visual = "mesh",
        mesh = "mobs_mc_villager.b3d",
        textures = validated_textures,
        makes_footstep_sound = true,
        walk_velocity = wetlands_npcs.config.movement.walk_velocity,
        run_velocity = wetlands_npcs.config.movement.run_velocity,
        drops = {},
        can_despawn = false,
        animation = VILLAGER_ANIMATION,
        view_range = 16,
        fear_height = 4,
        jump = true,
        walk_chance = 33,
        custom_villager_type = name,
        armor_groups = {immortal = 1},

        on_activate = function(self, staticdata, dtime_s)
            self.object:set_armor_groups({immortal = 1})
        end,

        do_custom = function(self, dtime)
            self._immortal_check = (self._immortal_check or 0) + dtime
            if self._immortal_check > 3 then
                self._immortal_check = 0
                local armor = self.object:get_armor_groups()
                if not armor.immortal or armor.immortal ~= 1 then
                    self.object:set_armor_groups({immortal = 1})
                end
            end
        end,

        on_rightclick = function(self, clicker)
            if not clicker or not clicker:is_player() then return end
            if not self.custom_villager_type and self.name then
                local npc_type = self.name:match("wetlands_npcs:(.+)")
                if npc_type then
                    self.custom_villager_type = npc_type
                end
            end
            if not self.custom_villager_type then return end
            local player_name = clicker:get_player_name()
            if not player_name or player_name == "" then return end
            local display_name = wetlands_npcs.display_names[self.custom_villager_type]
                or self.custom_villager_type
            local pos = self.object:get_pos()
            if pos then
                wetlands_npcs.play_npc_voice(self.custom_villager_type, pos)
            end
            pcall(function()
                show_interaction_formspec(player_name, self.custom_villager_type, display_name)
            end)
        end,

        on_punch = function(self, puncher)
            self.object:set_armor_groups({immortal = 1})
            self.object:set_hp(self.object:get_properties().hp_max or 20)
            if puncher and puncher:is_player() then
                minetest.chat_send_player(puncher:get_player_name(),
                    "[Servidor] Los NPCs de Wetlands son tus amigos. No puedes hacerles danio!")
            end
            return true
        end,
    }

    wetlands_npcs.behaviors.inject_into_mob(mob_def)
    mcl_mobs.register_mob(full_name, mob_def)
    log("info", "Registered classic NPC: " .. name)
end

register_classic_npc("farmer", {
    description = S("Agricultor de Wetlands"),
    textures = {{"wetlands_npc_farmer.png"}},
})

register_classic_npc("librarian", {
    description = S("Bibliotecario de Wetlands"),
    textures = {{"wetlands_npc_librarian.png"}},
})

register_classic_npc("teacher", {
    description = S("Maestro de Wetlands"),
    textures = {{"wetlands_npc_teacher.png"}},
})

register_classic_npc("explorer", {
    description = S("Explorador de Wetlands"),
    textures = {{"wetlands_npc_explorer.png"}},
})

-- ============================================================================
-- 6C. MIGRACION DE ENTIDADES LEGACY (solo custom_villagers -> wetlands_npcs)
-- ============================================================================

for _, vtype in ipairs({"farmer", "librarian", "teacher", "explorer"}) do
    minetest.register_entity(":custom_villagers:" .. vtype, {
        on_activate = function(self, staticdata, dtime_s)
            local pos = self.object:get_pos()
            self.object:remove()
            if pos then
                minetest.add_entity(pos, "wetlands_npcs:" .. vtype)
                log("info", "Migrated custom_villagers:" .. vtype .. " -> wetlands_npcs:" .. vtype)
            end
        end,
    })
end

log("info", "Legacy entity migration registered")

-- ============================================================================
-- 7. COMANDOS DE ADMINISTRACION
-- ============================================================================

local NPC_TYPES = {
    -- Star Wars
    luke        = "Luke Skywalker - Caballero Jedi, heroe de la Rebelion",
    anakin      = "Anakin Skywalker - Jedi de las Guerras Clon, piloto legendario",
    yoda        = "Baby Yoda (Grogu) - Pequenio pero poderoso en la Fuerza",
    mandalorian = "Mandalorian (Din Djarin) - Cazarrecompensas con armadura beskar",
    -- Clasicos
    farmer      = "Agricultor - cultiva vegetales y cuida la tierra",
    librarian   = "Bibliotecario - guarda libros y conocimiento",
    teacher     = "Maestro - ensenia ciencia y compasion",
    explorer    = "Explorador - viaja por el mundo descubriendo secretos",
}

minetest.register_chatcommand("spawn_npc", {
    params = "<luke | anakin | yoda | mandalorian | farmer | librarian | teacher | explorer>",
    description = "Spawnea un NPC de Wetlands",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end

        local npc_type = param:lower():gsub("^%s+", ""):gsub("%s+$", "")

        if npc_type == "" then
            local lines = {"=== NPCs Star Wars disponibles ==="}
            for ntype, desc in pairs(NPC_TYPES) do
                table.insert(lines, "  /spawn_npc " .. ntype .. " - " .. desc)
            end
            table.insert(lines, "")
            table.insert(lines, "Ejemplo: /spawn_npc luke")
            return true, table.concat(lines, "\n")
        end

        if not NPC_TYPES[npc_type] then
            local lines = {"'" .. npc_type .. "' no existe. NPCs disponibles:"}
            for ntype, desc in pairs(NPC_TYPES) do
                table.insert(lines, "  " .. ntype .. " - " .. desc)
            end
            return false, table.concat(lines, "\n")
        end

        local pos = player:get_pos()
        pos.y = pos.y + 1

        local obj = minetest.add_entity(pos, modname .. ":" .. npc_type)

        if obj then
            local display = wetlands_npcs.display_names[npc_type] or npc_type
            return true, display .. " spawneado exitosamente!"
        else
            return false, "Error al spawnear NPC"
        end
    end,
})

-- Mantener /spawn_villager como alias por compatibilidad
minetest.register_chatcommand("spawn_villager", {
    params = "<luke | anakin | yoda | mandalorian | farmer | librarian | teacher | explorer>",
    description = "Alias de /spawn_npc",
    privs = {server = true},
    func = function(name, param)
        return minetest.registered_chatcommands["spawn_npc"].func(name, param)
    end,
})

minetest.register_chatcommand("npc_info", {
    params = "",
    description = "Muestra info sobre los NPCs Star Wars",
    privs = {},
    func = function(name, param)
        local info = {
            "=== NPCs de Wetlands v" .. wetlands_npcs.version .. " ===",
            "",
            "Star Wars:",
            "- Luke Skywalker (/spawn_npc luke)",
            "- Anakin Skywalker (/spawn_npc anakin)",
            "- Baby Yoda (/spawn_npc yoda)",
            "- Mandalorian (/spawn_npc mandalorian)",
            "",
            "Clasicos:",
            "- Agricultor (/spawn_npc farmer)",
            "- Bibliotecario (/spawn_npc librarian)",
            "- Maestro (/spawn_npc teacher)",
            "- Explorador (/spawn_npc explorer)",
            "",
            "Click derecho para interactuar!",
        }
        return true, table.concat(info, "\n")
    end,
})

-- ============================================================================
-- 8. FINALIZACION
-- ============================================================================

log("info", "Wetlands NPCs v" .. wetlands_npcs.version .. " loaded successfully!")
log("info", "8 NPCs: Luke, Anakin, Yoda, Mandalorian + Farmer, Librarian, Teacher, Explorer")
log("info", "Voice system: talk + greeting OGG sounds")
log("info", "Star Wars = player character model (64x32), Classics = villager model (64x64)")
