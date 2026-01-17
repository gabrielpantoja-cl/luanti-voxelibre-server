-- Custom Villagers Mod - VERSIÓN 2.0 (mcl_mobs)
-- Sistema de NPCs interactivos usando el sistema de mobs de VoxeLibre
-- Con texturas profesionales de VoxeLibre y diálogos educativos
-- Apropiado para servidor educativo Wetlands (7+ años)

-- ============================================================================
-- 1. INICIALIZACIÓN Y VERIFICACIÓN
-- ============================================================================

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

-- Verificar dependencias
if not minetest.get_modpath("mcl_mobs") then
    minetest.log("error", "[" .. modname .. "] mcl_mobs es requerido!")
    return
end

if not minetest.get_modpath("mcl_core") then
    minetest.log("error", "[" .. modname .. "] mcl_core es requerido!")
    return
end

-- Namespace global
custom_villagers = {}
custom_villagers.version = "2.1.1"  -- Fix API deprecada hp_min/hp_max

-- Sistema de logging
local function log(level, message)
    minetest.log(level, "[" .. modname .. "] " .. message)
end

log("info", "Initializing Custom Villagers v" .. custom_villagers.version .. " (mcl_mobs + AI)")

-- ============================================================================
-- CARGAR MÓDULOS DEL SISTEMA AI
-- ============================================================================

-- Cargar configuración centralizada
dofile(modpath .. "/config.lua")
log("info", "Configuration system loaded")

-- Cargar sistema de comportamientos AI tradicional
dofile(modpath .. "/ai_behaviors.lua")
log("info", "AI Behaviors system loaded (v" .. custom_villagers.behaviors.version .. ")")

-- ============================================================================
-- 2. SISTEMA DE DIÁLOGOS EDUCATIVOS
-- ============================================================================

custom_villagers.dialogues = {
    farmer = {
        greetings = {
            "¡Hola! Cultivo vegetales frescos y saludables para la comunidad.",
            "¡Buenos días! ¿Te gustaría aprender sobre agricultura sostenible?",
            "¡Bienvenido! Cultivamos solo alimentos de origen vegetal.",
        },
        about_work = {
            "Trabajo la tierra cada día. Las plantas necesitan agua, luz y cuidado.",
            "La agricultura sostenible alimenta al mundo sin dañar el planeta.",
        },
        education = {
            "¿Sabías que las plantas necesitan nutrientes del suelo? Por eso rotamos cultivos.",
            "Los alimentos vegetales son nutritivos y respetuosos con el medio ambiente.",
        },
    },
    librarian = {
        greetings = {
            "¡Saludos! Guardo el conocimiento de nuestra comunidad.",
            "¡Hola! ¿Buscas aprender algo nuevo hoy?",
            "¡Bienvenido! Aquí encontrarás libros sobre compasión y ciencia.",
        },
        about_work = {
            "Los libros preservan el conocimiento de generaciones.",
            "La lectura expande tu mente y ayuda a entender el mundo.",
        },
        education = {
            "¿Sabías que leer 30 minutos al día mejora tu vocabulario?",
            "El conocimiento es poder, la sabiduría es usarlo con compasión.",
        },
    },
    teacher = {
        greetings = {
            "¡Hola! Me encanta enseñar sobre ciencia y naturaleza.",
            "¡Buenos días! ¿Listo para aprender algo fascinante?",
            "La educación es la herramienta más poderosa para cambiar el mundo.",
        },
        about_work = {
            "Enseño ciencia, matemáticas y compasión hacia todos los seres.",
            "Mi trabajo es despertar la curiosidad en las mentes jóvenes.",
        },
        education = {
            "¿Sabías que los animales sienten emociones como nosotros? Tratémoslos con respeto.",
            "La ciencia enseña que somos parte de la naturaleza, no sus dueños.",
        },
    },
    explorer = {
        greetings = {
            "¡Hola aventurero! He viajado por todos los biomas del mundo.",
            "¡Saludos! ¿Te gustaría escuchar historias de mis viajes?",
            "¡Bienvenido! Cada lugar tiene algo único que enseñarnos.",
        },
        about_work = {
            "Exploro el mundo y estudio diferentes ecosistemas.",
            "Cada bioma tiene plantas y animales únicos que merecen protección.",
        },
        education = {
            "¿Sabías que los bosques producen gran parte del oxígeno que respiramos?",
            "La biodiversidad es fundamental para el equilibrio del planeta.",
        },
    },
}

-- Función para obtener diálogo aleatorio
local function get_dialogue(villager_type, category)
    local dialogues = custom_villagers.dialogues[villager_type]
    if not dialogues or not dialogues[category] then
        return "..."
    end
    local options = dialogues[category]
    return options[math.random(1, #options)]
end

-- ============================================================================
-- 3. SISTEMA DE COMERCIO EDUCATIVO
-- ============================================================================

custom_villagers.trades = {
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

-- Mostrar formspec de interacción
local function show_interaction_formspec(player_name, villager_type, villager_name)
    -- DEFENSIVE: Validar parámetros críticos antes de procesar
    if not player_name or not villager_type then
        log("error", "show_interaction_formspec called with nil parameters")
        return
    end

    -- DEFENSIVE: Convertir villager_name a string seguro
    local name_str = "Aldeano"
    if villager_name then
        name_str = tostring(villager_name)
    elseif villager_type then
        -- Capitalizar primera letra del tipo
        name_str = villager_type:sub(1,1):upper() .. villager_type:sub(2)
    end

    -- DEFENSIVE: Escapar caracteres especiales para evitar inyección
    name_str = minetest.formspec_escape(name_str)

    -- FIX: Usar sintaxis moderna de formspec sin emojis (causa crashes en algunos clientes)
    local formspec = "formspec_version[4]" ..
        "size[10,7]" ..
        "label[0.5,0.5;" .. name_str .. "]" ..
        "button[0.5,1.5;9,0.8;dialogue_greeting;Saludar]" ..
        "button[0.5,2.5;9,0.8;dialogue_work;Sobre su trabajo]" ..
        "button[0.5,3.5;9,0.8;dialogue_education;Aprender algo nuevo]" ..
        "button[0.5,4.5;9,0.8;trade;Comerciar]" ..
        "button[0.5,5.5;9,0.8;close;Cerrar]"

    -- DEFENSIVE: Usar pcall para capturar posibles errores de formspec
    local success, err = pcall(function()
        minetest.show_formspec(player_name, "custom_villagers:interact_" .. villager_type, formspec)
    end)

    if not success then
        log("error", "Failed to show formspec: " .. tostring(err))
        minetest.chat_send_player(player_name, "[Aldeano] Error al mostrar diálogo. Intenta de nuevo.")
    end
end

-- Mostrar formspec de comercio
local function show_trade_formspec(player_name, villager_type)
    -- DEFENSIVE: Validar parámetros
    if not player_name or not villager_type then
        log("error", "show_trade_formspec called with nil parameters")
        return
    end

    local trades = custom_villagers.trades[villager_type]
    if not trades then
        minetest.chat_send_player(player_name, "[Aldeano] No tengo nada para comerciar ahora.")
        return
    end

    -- FIX: Usar sintaxis moderna de formspec
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

    minetest.show_formspec(player_name, "custom_villagers:trade_" .. villager_type, formspec)
end

-- Manejar clicks en formspecs
minetest.register_on_player_receive_fields(function(player, formname, fields)
    -- Formspec de interacción
    if formname:find("^custom_villagers:interact_") then
        local villager_type = formname:gsub("^custom_villagers:interact_", "")
        local player_name = player:get_player_name()

        if fields.dialogue_greeting then
            local msg = get_dialogue(villager_type, "greetings")
            minetest.chat_send_player(player_name, "[Aldeano] " .. msg)
        elseif fields.dialogue_work then
            local msg = get_dialogue(villager_type, "about_work")
            minetest.chat_send_player(player_name, "[Aldeano] " .. msg)
        elseif fields.dialogue_education then
            local msg = get_dialogue(villager_type, "education")
            minetest.chat_send_player(player_name, "[Aldeano] " .. msg)
        elseif fields.trade then
            show_trade_formspec(player_name, villager_type)
        end
    end

    -- Formspec de comercio
    if formname:find("^custom_villagers:trade_") then
        local villager_type = formname:gsub("^custom_villagers:trade_", "")
        local trades = custom_villagers.trades[villager_type]
        if not trades then return end

        for field, _ in pairs(fields) do
            if field:find("^trade_") then
                local trade_index = tonumber(field:gsub("^trade_", ""))
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
-- 4. REGISTRO DE ALDEANOS CON MCL_MOBS
-- ============================================================================

-- Función helper para registrar aldeanos
local function register_custom_villager(name, def)
    local full_name = modname .. ":" .. name

    -- Crear definición del mob
    local mob_def = {
        description = def.description or S(name:gsub("^%l", string.upper)),
        type = "npc",
        spawn_class = "passive",
        passive = true,

        -- FIX: Mover hp_min/hp_max a initial_properties (API moderna mcl_mobs)
        initial_properties = {
            hp_max = 20,
            collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
            visual = "mesh",
            mesh = "mobs_mc_villager.b3d",
            textures = def.textures or {"mobs_mc_villager.png", "mobs_mc_villager.png"},
            makes_footstep_sound = true,
        },

        walk_velocity = custom_villagers.config.movement.walk_velocity,
        run_velocity = custom_villagers.config.movement.run_velocity,
        drops = {},
        can_despawn = false,
        animation = {
            stand_start = 0, stand_end = 0,
            walk_start = 0, walk_end = 40, walk_speed = 25,
            run_start = 0, run_end = 40, run_speed = 25,
        },
        view_range = 16,
        fear_height = 4,
        jump = true,
        walk_chance = 33,

        -- Datos personalizados
        custom_villager_type = name,

        on_rightclick = function(self, clicker)
            -- DEFENSIVE: Validar que clicker existe y es un jugador
            if not clicker or not clicker:is_player() then
                return
            end

            -- DEFENSIVE: Validar que self existe
            if not self then
                log("error", "on_rightclick called on nil entity")
                return
            end

            -- AUTO-FIX: Si el aldeano no tiene custom_villager_type (aldeanos viejos/corruptos),
            -- extraerlo del nombre de la entidad (ej: "custom_villagers:explorer" -> "explorer")
            if not self.custom_villager_type and self.name then
                local entity_name = self.name
                local villager_type = entity_name:match("custom_villagers:(.+)")
                if villager_type then
                    self.custom_villager_type = villager_type
                    log("warning", "Auto-fixed corrupted villager: set type to " .. villager_type)
                else
                    log("error", "Could not extract villager type from entity name: " .. entity_name)
                    return
                end
            end

            -- Si aún no tiene tipo después del auto-fix, abortar
            if not self.custom_villager_type then
                log("error", "on_rightclick called on villager without type and auto-fix failed")
                return
            end

            -- DEFENSIVE: Obtener player_name de forma segura
            local player_name = clicker:get_player_name()
            if not player_name or player_name == "" then
                return
            end

            -- Generar nombre legible del aldeano (capitalizar tipo)
            local villager_name = self.custom_villager_type:sub(1,1):upper() .. self.custom_villager_type:sub(2)

            -- DEFENSIVE: Usar pcall para proteger contra crashes
            local success, err = pcall(function()
                show_interaction_formspec(player_name, self.custom_villager_type, villager_name)
            end)

            if not success then
                log("error", "on_rightclick failed: " .. tostring(err))
                minetest.chat_send_player(player_name, "[Servidor] Error al interactuar con aldeano. Intenta de nuevo.")
            else
                log("info", "Opened interaction menu for " .. player_name .. " with " .. self.custom_villager_type)
            end
        end,

        on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
            -- Protección: aldeanos no se pueden lastimar
            if puncher and puncher:is_player() then
                minetest.chat_send_player(puncher:get_player_name(),
                    "[Servidor] Los aldeanos son parte de nuestra comunidad. No debemos lastimarlos!")
            end
            return true -- Cancelar daño
        end,
    }

    -- NUEVO: Inyectar sistema de comportamientos AI
    custom_villagers.behaviors.inject_into_mob(mob_def)

    -- Registrar el mob con el sistema AI integrado
    mcl_mobs.register_mob(full_name, mob_def)

    log("info", "Registered custom villager with AI: " .. name)
end

-- ============================================================================
-- 5. DEFINICIÓN DE TIPOS DE ALDEANOS
-- ============================================================================

-- Agricultor - Usa textura de farmer de VoxeLibre
register_custom_villager("farmer", {
    description = S("Agricultor de Wetlands"),
    textures = {
        "mobs_mc_villager_farmer.png",
        "mobs_mc_villager_farmer.png", -- sombrero
    },
})

-- Bibliotecario - Usa textura de librarian de VoxeLibre
register_custom_villager("librarian", {
    description = S("Bibliotecario de Wetlands"),
    textures = {
        "mobs_mc_villager_librarian.png",
        "mobs_mc_villager_librarian.png",
    },
})

-- Maestro - Usa textura de priest (cleric) de VoxeLibre
register_custom_villager("teacher", {
    description = S("Maestro de Wetlands"),
    textures = {
        "mobs_mc_villager_priest.png",
        "mobs_mc_villager_priest.png",
    },
})

-- Explorador - Usa textura de cartographer de VoxeLibre
register_custom_villager("explorer", {
    description = S("Explorador de Wetlands"),
    textures = {
        "mobs_mc_villager_cartographer.png",
        "mobs_mc_villager_cartographer.png",
    },
})

-- ============================================================================
-- 6. COMANDOS DE ADMINISTRACIÓN
-- ============================================================================

-- Comando para spawnear aldeano
minetest.register_chatcommand("spawn_villager", {
    params = "<tipo>",
    description = "Spawea un aldeano (farmer, librarian, teacher, explorer)",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Jugador no encontrado" end

        local villager_type = param:lower()
        local valid_types = {"farmer", "librarian", "teacher", "explorer"}

        local is_valid = false
        for _, vtype in ipairs(valid_types) do
            if vtype == villager_type then
                is_valid = true
                break
            end
        end

        if not is_valid then
            return false, "Tipo inválido. Usa: farmer, librarian, teacher, explorer"
        end

        local pos = player:get_pos()
        pos.y = pos.y + 1

        local obj = minetest.add_entity(pos, modname .. ":" .. villager_type)

        if obj then
            return true, "✅ Aldeano " .. villager_type .. " spawneado"
        else
            return false, "❌ Error al spawnear aldeano"
        end
    end,
})

-- Comando de información
minetest.register_chatcommand("villager_info", {
    params = "",
    description = "Muestra información sobre aldeanos",
    privs = {},
    func = function(name, param)
        local info = {
            "🏘️ === Aldeanos de Wetlands v" .. custom_villagers.version .. " ===",
            "",
            "📋 Tipos disponibles:",
            "• Agricultor (farmer) - Cultiva vegetales",
            "• Bibliotecario (librarian) - Guarda libros",
            "• Maestro (teacher) - Enseña ciencia y compasión",
            "• Explorador (explorer) - Viaja por el mundo",
            "",
            "💬 Click derecho para interactuar",
            "🛒 Comercia items útiles por esmeraldas",
            "🚫 Los aldeanos no se pueden lastimar",
        }
        return true, table.concat(info, "\n")
    end,
})

-- ============================================================================
-- 7. FINALIZACIÓN
-- ============================================================================

log("info", "Custom Villagers v" .. custom_villagers.version .. " loaded successfully!")
log("info", "Using VoxeLibre textures and mcl_mobs system")
log("info", "Registered villagers: farmer, librarian, teacher, explorer")
