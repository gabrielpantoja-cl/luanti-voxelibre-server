-- Wetlands NPCs v1.0.0 - Sistema Completo con Voces y Texturas Unicas
-- NPCs interactivos educativos para servidor Wetlands (7+ anios)
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
wetlands_npcs.version = "1.0.0"

local function log(level, message)
    minetest.log(level, "[" .. modname .. "] " .. message)
end

log("info", "Initializing Wetlands NPCs v" .. wetlands_npcs.version)

-- ============================================================================
-- 2. SISTEMA DE SONIDO (debe cargarse ANTES de ai_behaviors.lua)
-- ============================================================================

function wetlands_npcs.play_npc_voice(villager_type, pos)
    -- Verificar que sonidos estan habilitados (config se carga despues,
    -- asi que usamos fallback defensivo)
    local sound_config = wetlands_npcs.config and wetlands_npcs.config.sounds
    if sound_config and not sound_config.enabled then
        return
    end

    local variant = math.random(1, 3)
    local sound_name = "wetlands_npc_talk_" .. villager_type .. variant
    local gain = (sound_config and sound_config.gain) or 0.8
    local max_dist = (sound_config and sound_config.max_hear_distance) or 20

    minetest.sound_play(sound_name, {
        pos = pos,
        gain = gain,
        max_hear_distance = max_dist,
    })
end

function wetlands_npcs.play_npc_greeting(villager_type, pos)
    local sound_config = wetlands_npcs.config and wetlands_npcs.config.sounds
    if sound_config and not sound_config.enabled then
        return
    end

    local variant = math.random(1, 2)
    local sound_name = "wetlands_npc_greet_" .. villager_type .. variant
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
-- 3. SISTEMA DE DIALOGOS EDUCATIVOS
-- ============================================================================

wetlands_npcs.dialogues = {
    farmer = {
        greetings = {
            "Hola! Cultivo vegetales frescos y saludables para la comunidad.",
            "Buenos dias! Te gustaria aprender sobre agricultura sostenible?",
            "Bienvenido! Cultivamos solo alimentos de origen vegetal.",
            "Que gusto verte! Hoy las zanahorias estan creciendo muy bien.",
            "Hola amigo! Ven a ver mi huerto, esta lleno de colores.",
        },
        about_work = {
            "Trabajo la tierra cada dia. Las plantas necesitan agua, luz y cuidado.",
            "La agricultura sostenible alimenta al mundo sin daniar el planeta.",
            "Roto los cultivos para mantener la tierra fertil. Trigo, zanahorias, papas...",
            "Las abejas polinizan mis cultivos. Sin ellas no habria cosecha!",
            "Compostar los restos de comida crea el mejor fertilizante natural.",
        },
        education = {
            "Sabias que las plantas necesitan nutrientes del suelo? Por eso rotamos cultivos.",
            "Los alimentos vegetales son nutritivos y respetuosos con el medio ambiente.",
            "Una semilla de trigo puede producir cientos de granos. La naturaleza es generosa!",
            "Las plantas liberan oxigeno durante el dia. Los arboles son los pulmones del planeta.",
            "El agua subterranea alimenta las raices. Por eso cuidar los rios es tan importante.",
        },
    },
    librarian = {
        greetings = {
            "Saludos! Guardo el conocimiento de nuestra comunidad.",
            "Hola! Buscas aprender algo nuevo hoy?",
            "Bienvenido! Aqui encontraras libros sobre compasion y ciencia.",
            "Que alegria ver a alguien interesado en los libros!",
            "Pasa, pasa! Tengo historias maravillosas que compartir.",
        },
        about_work = {
            "Los libros preservan el conocimiento de generaciones.",
            "La lectura expande tu mente y ayuda a entender el mundo.",
            "Organizo los libros por tema: ciencia, naturaleza, arte y compasion.",
            "Cada libro es una ventana a un mundo diferente. Cual quieres abrir?",
            "Cuido estos libros como tesoros. El conocimiento es invaluable.",
        },
        education = {
            "Sabias que leer 30 minutos al dia mejora tu vocabulario?",
            "El conocimiento es poder, la sabiduria es usarlo con compasion.",
            "Los primeros libros se escribian a mano. Tardaban meses en completarse!",
            "La biblioteca mas grande del mundo tiene millones de libros.",
            "Leer nos permite vivir mil vidas diferentes sin movernos de lugar.",
        },
    },
    teacher = {
        greetings = {
            "Que la Fuerza te acompanie, joven aprendiz.",
            "Bienvenido. La paciencia es el camino de la sabiduria.",
            "Hola! Hay mucho que aprender sobre la Fuerza y la compasion.",
            "Saludos, joven Padawan. Sientes la Fuerza a tu alrededor?",
            "El camino del conocimiento comienza con un solo paso.",
        },
        about_work = {
            "Ensenioo el camino de la Fuerza: compasion, paciencia y sabiduria.",
            "Un verdadero maestro nunca deja de aprender de sus alumnos.",
            "La Fuerza nos conecta a todos. Cada ser vivo es parte de ella.",
            "Mi trabajo es guiar, no controlar. La sabiduria viene de adentro.",
            "La compasion es la forma mas poderosa de la Fuerza.",
        },
        education = {
            "La Fuerza es lo que nos conecta. Esta en todas las cosas vivas.",
            "Un Jedi usa la Fuerza para el conocimiento y la defensa, nunca para atacar.",
            "La paciencia es la mayor virtud. Todo llega a su tiempo.",
            "El miedo lleva al enojo, el enojo al odio. Elige siempre la compasion.",
            "Las estrellas que ves en el cielo son sistemas solares con mundos increibles.",
        },
    },
    explorer = {
        greetings = {
            "Hey! Acabo de descubrir algo increible!",
            "Saludos, aventurero! Listo para una nueva mision?",
            "Hola! Hay un planeta entero por explorar!",
            "Bienvenido! Quieres escuchar sobre mi ultima aventura?",
            "Viajero! Ven, tengo historias de galaxias lejanas.",
        },
        about_work = {
            "Exploro mundos desconocidos y descubro sus secretos.",
            "Cada bioma es como un planeta diferente. Todos merecen proteccion.",
            "He volado por canyones y cruzado desiertos. La aventura nunca termina!",
            "Mi nave y mi brujula son mis mejores aliados en las misiones.",
            "Documento cada descubrimiento para que todos puedan aprender.",
        },
        education = {
            "Sabias que los bosques producen gran parte del oxigeno que respiramos?",
            "En la galaxia hay billones de estrellas, y cada una podria tener planetas!",
            "La biodiversidad es como la Fuerza: conecta todo el ecosistema.",
            "Los oceanos son tan vastos como el espacio. Guardan misterios increibles.",
            "El coraje no es no tener miedo, es actuar a pesar de el.",
        },
    },
}

local function get_dialogue(villager_type, category)
    local dialogues = wetlands_npcs.dialogues[villager_type]
    if not dialogues or not dialogues[category] then
        return "..."
    end
    local options = dialogues[category]
    return options[math.random(1, #options)]
end

-- ============================================================================
-- 4. SISTEMA DE COMERCIO EDUCATIVO
-- ============================================================================

wetlands_npcs.trades = {
    farmer = {
        {give = "mcl_farming:carrot_item 5", wants = "mcl_core:emerald 1"},
        {give = "mcl_farming:potato_item 5", wants = "mcl_core:emerald 1"},
        {give = "mcl_farming:beetroot_item 5", wants = "mcl_core:emerald 1"},
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
local function show_interaction_formspec(player_name, villager_type, villager_name)
    if not player_name or not villager_type then
        log("error", "show_interaction_formspec called with nil parameters")
        return
    end

    local name_str = "Aldeano"
    if villager_name then
        name_str = tostring(villager_name)
    elseif villager_type then
        name_str = villager_type:sub(1,1):upper() .. villager_type:sub(2)
    end
    name_str = minetest.formspec_escape(name_str)

    local formspec = "formspec_version[4]" ..
        "size[10,7]" ..
        "label[0.5,0.5;" .. name_str .. "]" ..
        "button[0.5,1.5;9,0.8;dialogue_greeting;Saludar]" ..
        "button[0.5,2.5;9,0.8;dialogue_work;Sobre su trabajo]" ..
        "button[0.5,3.5;9,0.8;dialogue_education;Aprender algo nuevo]" ..
        "button[0.5,4.5;9,0.8;trade;Comerciar]" ..
        "button[0.5,5.5;9,0.8;close;Cerrar]"

    local success, err = pcall(function()
        minetest.show_formspec(player_name, "wetlands_npcs:interact_" .. villager_type, formspec)
    end)

    if not success then
        log("error", "Failed to show formspec: " .. tostring(err))
        minetest.chat_send_player(player_name, "[Aldeano] Error al mostrar dialogo. Intenta de nuevo.")
    end
end

-- Mostrar formspec de comercio
local function show_trade_formspec(player_name, villager_type)
    if not player_name or not villager_type then
        log("error", "show_trade_formspec called with nil parameters")
        return
    end

    local trades = wetlands_npcs.trades[villager_type]
    if not trades then
        minetest.chat_send_player(player_name, "[Aldeano] No tengo nada para comerciar ahora.")
        return
    end

    local formspec = "formspec_version[4]" ..
        "size[12,11]" ..
        "label[0.5,0.5;Comercio - " .. minetest.formspec_escape(villager_type) .. "]" ..
        "label[0.5,1;Ofrece esmeraldas por items utiles:]" ..
        "list[current_player;main;0.5,6;8,4;]"

    local y = 2
    for i, trade in ipairs(trades) do
        formspec = formspec .. "label[0.5," .. y .. ";" .. i .. ". " ..
                   minetest.formspec_escape(trade.give) .. " <- " ..
                   minetest.formspec_escape(trade.wants) .. "]"
        formspec = formspec .. "button[7," .. (y-0.2) .. ";3,0.8;trade_" .. i .. ";Comerciar]"
        y = y + 1
    end

    minetest.show_formspec(player_name, "wetlands_npcs:trade_" .. villager_type, formspec)
end

-- Manejar clicks en formspecs
minetest.register_on_player_receive_fields(function(player, formname, fields)
    -- Formspec de interaccion
    if formname:find("^wetlands_npcs:interact_") then
        local villager_type = formname:gsub("^wetlands_npcs:interact_", "")
        local player_name = player:get_player_name()
        local player_pos = player:get_pos()

        if fields.dialogue_greeting then
            local msg = get_dialogue(villager_type, "greetings")
            minetest.chat_send_player(player_name, "[Aldeano] " .. msg)
            wetlands_npcs.play_npc_voice(villager_type, player_pos)
        elseif fields.dialogue_work then
            local msg = get_dialogue(villager_type, "about_work")
            minetest.chat_send_player(player_name, "[Aldeano] " .. msg)
            wetlands_npcs.play_npc_voice(villager_type, player_pos)
        elseif fields.dialogue_education then
            local msg = get_dialogue(villager_type, "education")
            minetest.chat_send_player(player_name, "[Aldeano] " .. msg)
            wetlands_npcs.play_npc_voice(villager_type, player_pos)
        elseif fields.trade then
            show_trade_formspec(player_name, villager_type)
        end
    end

    -- Formspec de comercio
    if formname:find("^wetlands_npcs:trade_") then
        local villager_type = formname:gsub("^wetlands_npcs:trade_", "")
        local trades = wetlands_npcs.trades[villager_type]
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
-- 5. REGISTRO DE ALDEANOS CON MCL_MOBS
-- ============================================================================

local function register_custom_villager(name, def)
    local full_name = modname .. ":" .. name

    local validated_textures = def.textures
    if not validated_textures or type(validated_textures) ~= "table" or #validated_textures == 0 then
        validated_textures = {{"mobs_mc_villager.png"}}
        log("warning", "Missing or invalid textures for " .. name .. ", using default")
    end

    if type(validated_textures[1]) ~= "table" then
        validated_textures = {validated_textures}
    end

    -- Modelo y animaciones: usar los del def o defaults de villager
    local mesh = def.mesh or "mobs_mc_villager.b3d"
    local animation = def.animation or {
        stand_start = 0, stand_end = 0,
        walk_start = 0, walk_end = 40, walk_speed = 25,
        run_start = 0, run_end = 40, run_speed = 25,
    }

    local mob_def = {
        description = def.description or S(name:gsub("^%l", string.upper)),
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
        mesh = mesh,
        textures = validated_textures,
        makes_footstep_sound = true,

        walk_velocity = wetlands_npcs.config.movement.walk_velocity,
        run_velocity = wetlands_npcs.config.movement.run_velocity,

        drops = {},
        can_despawn = false,

        animation = animation,

        view_range = 16,
        fear_height = 4,
        jump = true,
        walk_chance = 33,

        custom_villager_type = name,

        -- FIX: Multiples capas de inmortalidad (mcl_mobs puede resetear armor_groups)
        armor_groups = {immortal = 1},

        on_activate = function(self, staticdata, dtime_s)
            self.object:set_armor_groups({immortal = 1})
        end,

        do_custom = function(self, dtime)
            -- Verificar periodicamente que la inmortalidad persiste
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
            if not clicker or not clicker:is_player() then
                return
            end
            if not self then
                log("error", "on_rightclick called on nil entity")
                return
            end

            -- Auto-fix para aldeanos sin tipo
            if not self.custom_villager_type and self.name then
                local entity_name = self.name
                local villager_type = entity_name:match("wetlands_npcs:(.+)") or
                                     entity_name:match("custom_villagers:(.+)")
                if villager_type then
                    self.custom_villager_type = villager_type
                    log("warning", "Auto-fixed corrupted villager: set type to " .. villager_type)
                else
                    log("error", "Could not extract villager type from entity name: " .. entity_name)
                    return
                end
            end

            if not self.custom_villager_type then
                log("error", "on_rightclick: villager without type, auto-fix failed")
                return
            end

            local player_name = clicker:get_player_name()
            if not player_name or player_name == "" then
                return
            end

            local villager_name = self.custom_villager_type:sub(1,1):upper() .. self.custom_villager_type:sub(2)

            -- Reproducir voz al interactuar
            local pos = self.object:get_pos()
            if pos then
                wetlands_npcs.play_npc_voice(self.custom_villager_type, pos)
            end

            local success, err = pcall(function()
                show_interaction_formspec(player_name, self.custom_villager_type, villager_name)
            end)

            if not success then
                log("error", "on_rightclick failed: " .. tostring(err))
                minetest.chat_send_player(player_name, "[Servidor] Error al interactuar con aldeano.")
            end
        end,

        on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
            -- Re-forzar inmortalidad en cada golpe (por si mcl_mobs la reseteo)
            self.object:set_armor_groups({immortal = 1})
            -- Restaurar HP completa
            self.object:set_hp(self.object:get_properties().hp_max or 20)
            if puncher and puncher:is_player() then
                minetest.chat_send_player(puncher:get_player_name(),
                    "[Servidor] Los aldeanos son parte de nuestra comunidad. No debemos lastimarlos!")
            end
            return true
        end,
    }

    -- Inyectar sistema de comportamientos AI
    wetlands_npcs.behaviors.inject_into_mob(mob_def)

    mcl_mobs.register_mob(full_name, mob_def)
    log("info", "Registered villager with AI: " .. name)
end

-- ============================================================================
-- 6. DEFINICION DE TIPOS DE ALDEANOS (texturas unicas)
-- ============================================================================

register_custom_villager("farmer", {
    description = S("Agricultor de Wetlands"),
    textures = {
        {"wetlands_npc_farmer.png"}
    },
})

register_custom_villager("librarian", {
    description = S("Bibliotecario de Wetlands"),
    textures = {
        {"wetlands_npc_librarian.png"}
    },
})

register_custom_villager("teacher", {
    description = S("Maestro Jedi de Wetlands"),
    textures = {
        {"wetlands_npc_teacher.png"}
    },
    mesh = "wetlands_npc_human.b3d",
    animation = {
        stand_start = 40, stand_end = 49,
        walk_start = 0, walk_end = 39, walk_speed = 25,
        run_start = 0, run_end = 39, run_speed = 35,
    },
})

register_custom_villager("explorer", {
    description = S("Explorador Galactico de Wetlands"),
    textures = {
        {"wetlands_npc_explorer.png"}
    },
    mesh = "wetlands_npc_human.b3d",
    animation = {
        stand_start = 40, stand_end = 49,
        walk_start = 0, walk_end = 39, walk_speed = 25,
        run_start = 0, run_end = 39, run_speed = 35,
    },
})

-- ============================================================================
-- 6B. MIGRACION DE ENTIDADES LEGACY (custom_villagers -> wetlands_npcs)
-- ============================================================================
-- Los NPCs viejos del mod eliminado custom_villagers siguen en el mundo.
-- Registramos entidades legacy que se auto-reemplazan por las nuevas.

for _, vtype in ipairs({"farmer", "librarian", "teacher", "explorer"}) do
    minetest.register_entity(":custom_villagers:" .. vtype, {
        on_activate = function(self, staticdata, dtime_s)
            local pos = self.object:get_pos()
            self.object:remove()
            if pos then
                minetest.add_entity(pos, "wetlands_npcs:" .. vtype)
                log("info", "Migrated legacy entity custom_villagers:" .. vtype .. " -> wetlands_npcs:" .. vtype)
            end
        end,
    })
end

log("info", "Legacy custom_villagers entity migration registered")

-- ============================================================================
-- 7. COMANDOS DE ADMINISTRACION
-- ============================================================================

minetest.register_chatcommand("spawn_villager", {
    params = "<tipo: farmer | librarian | teacher | explorer>",
    description = "Spawnea un NPC. Tipos: farmer (aldeano agricultor), librarian (aldeano bibliotecario), teacher (Obi-Wan, modelo humano), explorer (Luke, modelo humano)",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end

        local villager_types = {
            farmer    = "Agricultor - cultiva vegetales y cuida la tierra (aldeano)",
            librarian = "Bibliotecario - guarda libros y conocimiento (aldeano)",
            teacher   = "Maestro Jedi (Obi-Wan) - ensenia la Fuerza y compasion (humano)",
            explorer  = "Explorador Galactico (Luke) - aventura entre galaxias (humano)",
        }

        local villager_type = param:lower():gsub("^%s+", ""):gsub("%s+$", "")

        if villager_type == "" then
            local lines = {"=== Tipos de NPC disponibles ==="}
            for vtype, desc in pairs(villager_types) do
                table.insert(lines, "  /spawn_villager " .. vtype .. " - " .. desc)
            end
            table.insert(lines, "")
            table.insert(lines, "Ejemplo: /spawn_villager farmer")
            return true, table.concat(lines, "\n")
        end

        if not villager_types[villager_type] then
            local lines = {"Tipo '" .. villager_type .. "' no existe. Tipos disponibles:"}
            for vtype, desc in pairs(villager_types) do
                table.insert(lines, "  " .. vtype .. " - " .. desc)
            end
            return false, table.concat(lines, "\n")
        end

        local pos = player:get_pos()
        pos.y = pos.y + 1

        local obj = minetest.add_entity(pos, modname .. ":" .. villager_type)

        if obj then
            return true, "Aldeano " .. villager_types[villager_type]:match("^(%S+)") .. " (" .. villager_type .. ") spawneado exitosamente"
        else
            return false, "Error al spawnear aldeano"
        end
    end,
})

minetest.register_chatcommand("villager_info", {
    params = "",
    description = "Muestra informacion sobre aldeanos",
    privs = {},
    func = function(name, param)
        local info = {
            "=== NPCs de Wetlands v" .. wetlands_npcs.version .. " ===",
            "",
            "Tipos disponibles:",
            "- Agricultor (farmer) - Cultiva vegetales [modelo aldeano]",
            "- Bibliotecario (librarian) - Guarda libros [modelo aldeano]",
            "- Maestro Jedi (teacher) - Obi-Wan, la Fuerza [modelo humano]",
            "- Explorador Galactico (explorer) - Luke, aventuras [modelo humano]",
            "",
            "Click derecho para interactuar",
            "Se acercan y te saludan por tu nombre!",
            "Comercia items utiles por esmeraldas",
        }
        return true, table.concat(info, "\n")
    end,
})

-- ============================================================================
-- 8. FINALIZACION
-- ============================================================================

log("info", "Wetlands NPCs v" .. wetlands_npcs.version .. " loaded successfully!")
log("info", "Dual-model NPCs: villager (farmer/librarian) + human (teacher/explorer)")
log("info", "Voice system: 12 talk + 8 greeting OGG sounds")
log("info", "Registered NPCs: farmer, librarian, teacher (Obi-Wan), explorer (Luke)")
