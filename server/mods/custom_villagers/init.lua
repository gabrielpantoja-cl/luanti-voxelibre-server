-- Custom Villagers Mod
-- Sistema de NPCs interactivos con diálogos, comercio y rutinas
-- Apropiado para servidor educativo Wetlands (7+ años)
-- Versión 1.0.0

-- ============================================================================
-- 1. INICIALIZACIÓN Y CONFIGURACIÓN
-- ============================================================================

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

-- Verificar compatibilidad VoxeLibre
if not minetest.get_modpath("mcl_core") then
    minetest.log("error", "[" .. modname .. "] VoxeLibre (mcl_core) es requerido!")
    return
end

-- Namespace global del mod
custom_villagers = {}
custom_villagers.version = "1.0.0"

-- Configuración del mod
custom_villagers.settings = {
    max_villagers_per_area = tonumber(minetest.settings:get(modname .. "_max_villagers") or "5"),
    spawn_radius = tonumber(minetest.settings:get(modname .. "_spawn_radius") or "20"),
    debug_mode = minetest.settings:get_bool(modname .. "_debug", false),
    enable_trading = minetest.settings:get_bool(modname .. "_enable_trading", true),
    enable_schedules = minetest.settings:get_bool(modname .. "_enable_schedules", true),
}

-- Sistema de logging
local function log(level, message)
    minetest.log(level, "[" .. modname .. "] " .. message)
end

local function debug(message)
    if custom_villagers.settings.debug_mode then
        log("info", "DEBUG: " .. message)
    end
end

log("info", "Initializing Custom Villagers v" .. custom_villagers.version)

-- ============================================================================
-- 2. SISTEMA DE DIÁLOGOS
-- ============================================================================

-- Base de datos de diálogos por tipo de aldeano
custom_villagers.dialogues = {
    farmer = {
        greetings = {
            "¡Hola! Soy agricultor. Cultivo vegetales frescos y saludables para toda la comunidad.",
            "¡Buenos días! ¿Te gustaría aprender sobre agricultura sostenible?",
            "¡Bienvenido! En mi granja cultivamos solo alimentos de origen vegetal.",
        },
        about_work = {
            "Trabajo la tierra todos los días. Las plantas necesitan agua, luz solar y cuidado para crecer fuertes.",
            "La agricultura sostenible es clave para alimentar al mundo sin dañar el planeta.",
        },
        education = {
            "¿Sabías que las plantas necesitan nutrientes del suelo? Por eso es importante rotar cultivos.",
            "Los alimentos de origen vegetal son nutritivos y respetuosos con el medio ambiente.",
        },
    },
    librarian = {
        greetings = {
            "¡Saludos! Soy el bibliotecario. Guardo el conocimiento de nuestra comunidad.",
            "¡Hola! ¿Buscas aprender algo nuevo hoy?",
            "¡Bienvenido a la biblioteca! Aquí encontrarás libros sobre compasión y ciencia.",
        },
        about_work = {
            "Los libros contienen el conocimiento de generaciones. Es importante preservarlos y compartirlos.",
            "La lectura expande tu mente y te ayuda a entender mejor el mundo.",
        },
        education = {
            "¿Sabías que leer 30 minutos al día mejora tu comprensión y vocabulario?",
            "El conocimiento es poder, pero la sabiduría es saber usarlo con compasión.",
        },
    },
    teacher = {
        greetings = {
            "¡Hola estudiante! Soy el maestro. Me encanta enseñar sobre ciencia y naturaleza.",
            "¡Buenos días! ¿Listo para aprender algo fascinante?",
            "¡Bienvenido! La educación es la herramienta más poderosa para cambiar el mundo.",
        },
        about_work = {
            "Enseño a los niños sobre ciencia, matemáticas y, sobre todo, sobre compasión hacia todos los seres.",
            "Mi trabajo es despertar la curiosidad y el pensamiento crítico en las mentes jóvenes.",
        },
        education = {
            "¿Sabías que todos los animales sienten emociones como nosotros? Por eso debemos tratarlos con respeto.",
            "La ciencia nos enseña que somos parte de la naturaleza, no sus dueños.",
        },
    },
    explorer = {
        greetings = {
            "¡Hola aventurero! Soy un explorador. He viajado por todos los biomas del mundo.",
            "¡Saludos! ¿Te gustaría escuchar historias de mis viajes?",
            "¡Bienvenido! Cada lugar tiene algo único que enseñarnos.",
        },
        about_work = {
            "Exploro el mundo, estudio diferentes ecosistemas y aprendo de la naturaleza.",
            "Cada bioma tiene plantas y animales únicos que merecen ser protegidos.",
        },
        education = {
            "¿Sabías que los bosques producen gran parte del oxígeno que respiramos?",
            "La biodiversidad es fundamental para mantener el equilibrio del planeta.",
        },
    },
}

-- Función para obtener diálogo aleatorio
local function get_dialogue(villager_type, category)
    local dialogues = custom_villagers.dialogues[villager_type]
    if not dialogues or not dialogues[category] then
        return "..." -- Silencio si no hay diálogos definidos
    end

    local options = dialogues[category]
    return options[math.random(1, #options)]
end

-- ============================================================================
-- 3. SISTEMA DE COMERCIO (TRADING)
-- ============================================================================

-- Ofertas de comercio por tipo de aldeano
custom_villagers.trades = {
    farmer = {
        -- El aldeano ofrece estos items
        offers = {
            {give = "mcl_farming:carrot_item 5", wants = "mcl_core:emerald 1"},
            {give = "mcl_farming:potato_item 5", wants = "mcl_core:emerald 1"},
            {give = "mcl_farming:beetroot_item 5", wants = "mcl_core:emerald 1"},
            {give = "mcl_farming:wheat_item 10", wants = "mcl_core:emerald 2"},
        },
    },
    librarian = {
        offers = {
            {give = "mcl_books:book 1", wants = "mcl_core:emerald 3"},
            {give = "mcl_core:paper 10", wants = "mcl_core:emerald 1"},
        },
    },
    teacher = {
        offers = {
            {give = "mcl_books:book 2", wants = "mcl_core:emerald 5"},
            {give = "mcl_core:paper 15", wants = "mcl_core:emerald 2"},
        },
    },
    explorer = {
        offers = {
            {give = "mcl_core:apple 10", wants = "mcl_core:emerald 2"},
            {give = "mcl_core:stick 20", wants = "mcl_core:emerald 1"},
        },
    },
}

-- Mostrar formspec de comercio
local function show_trade_formspec(player_name, villager_type)
    if not custom_villagers.settings.enable_trading then
        minetest.chat_send_player(player_name, "🚫 El comercio está deshabilitado en este servidor.")
        return
    end

    local trades = custom_villagers.trades[villager_type]
    if not trades or not trades.offers then
        minetest.chat_send_player(player_name, "💬 Este aldeano no tiene nada para comerciar ahora.")
        return
    end

    -- Construir formspec simple
    local formspec = "size[8,9]" ..
        "label[0,0;🛒 Comercio con Aldeano - " .. villager_type .. "]" ..
        "label[0,0.5;Ofrece tus esmeraldas por items útiles:]" ..
        "list[current_player;main;0,5;8,4;]"

    -- Agregar ofertas (simplificado - formspec básico)
    local y = 1.5
    for i, trade in ipairs(trades.offers) do
        formspec = formspec .. "label[0," .. y .. ";" .. i .. ". " .. trade.give .. " ← " .. trade.wants .. "]"
        formspec = formspec .. "button[5," .. (y-0.2) .. ";2,0.5;trade_" .. i .. ";Comerciar]"
        y = y + 0.8
    end

    minetest.show_formspec(player_name, "custom_villagers:trade_" .. villager_type, formspec)
end

-- Manejar clicks en formspec de comercio
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if not formname:find("^custom_villagers:trade_") then
        return
    end

    local villager_type = formname:gsub("^custom_villagers:trade_", "")
    local trades = custom_villagers.trades[villager_type]
    if not trades then return end

    for field, _ in pairs(fields) do
        if field:find("^trade_") then
            local trade_index = tonumber(field:gsub("^trade_", ""))
            local trade = trades.offers[trade_index]

            if trade then
                local player_name = player:get_player_name()
                local inv = player:get_inventory()

                -- Parsear items wanted
                local wants_item, wants_count = trade.wants:match("(%S+)%s+(%d+)")
                wants_count = tonumber(wants_count) or 1

                -- Verificar si el jugador tiene los items
                if inv:contains_item("main", wants_item .. " " .. wants_count) then
                    -- Quitar items del jugador
                    inv:remove_item("main", wants_item .. " " .. wants_count)

                    -- Dar items al jugador
                    inv:add_item("main", trade.give)

                    minetest.chat_send_player(player_name, "✅ ¡Comercio exitoso! Gracias por tu intercambio.")
                else
                    minetest.chat_send_player(player_name, "❌ No tienes suficientes items para este comercio.")
                end
            end
        end
    end
end)

-- ============================================================================
-- 4. REGISTRO DE ENTIDADES ALDEANAS
-- ============================================================================

-- Función helper para registrar aldeanos
local function register_villager(villager_type, def)
    local full_name = modname .. ":" .. villager_type

    -- Usar minetest.register_entity para mayor control
    -- (mcl_mobs requeriría modelos y animaciones específicas de VoxeLibre)
    minetest.register_entity(full_name, {
        initial_properties = {
            hp_max = def.hp_max or 20,
            physical = true,
            collide_with_objects = true,
            collisionbox = def.collisionbox or {-0.3, -1.0, -0.3, 0.3, 0.9, 0.3},
            visual = "cube",  -- Usar cubo simple (puedes cambiarlo a "mesh" con modelo)
            visual_size = {x = 0.8, y = 1.8},
            textures = def.textures or {
                "custom_villagers_" .. villager_type .. "_top.png",
                "custom_villagers_" .. villager_type .. "_bottom.png",
                "custom_villagers_" .. villager_type .. "_side.png",
                "custom_villagers_" .. villager_type .. "_side.png",
                "custom_villagers_" .. villager_type .. "_front.png",
                "custom_villagers_" .. villager_type .. "_back.png",
            },
            is_visible = true,
            makes_footstep_sound = true,
            automatic_rotate = 0,
            stepheight = 1.1,
        },

        -- Propiedades personalizadas
        villager_type = villager_type,
        timer = 0,
        walk_timer = 0,
        direction = 0,
        state = "idle", -- idle, walking, sleeping
        home_pos = nil,

        on_activate = function(self, staticdata)
            self.object:set_armor_groups({fleshy = 100})
            self.timer = 0
            self.walk_timer = 0
            self.direction = math.random(0, 360) * (math.pi / 180)
            self.state = "idle"

            -- Guardar posición inicial como hogar
            local pos = self.object:get_pos()
            if pos then
                self.home_pos = vector.round(pos)
            end

            debug(villager_type .. " aldeano activado en " .. minetest.pos_to_string(self.home_pos or pos))
        end,

        on_step = function(self, dtime)
            self.timer = self.timer + dtime
            self.walk_timer = self.walk_timer + dtime

            local pos = self.object:get_pos()
            if not pos then return end

            -- Sistema de horarios (dormir de noche)
            if custom_villagers.settings.enable_schedules then
                local time_of_day = minetest.get_timeofday()

                -- Noche (0.8 - 0.2) = dormir
                if time_of_day > 0.8 or time_of_day < 0.2 then
                    if self.state ~= "sleeping" then
                        self.state = "sleeping"
                        self.object:set_velocity({x=0, y=0, z=0})
                        debug(villager_type .. " se fue a dormir")
                    end
                    return -- No hacer nada más si está durmiendo
                else
                    if self.state == "sleeping" then
                        self.state = "idle"
                        debug(villager_type .. " se despertó")
                    end
                end
            end

            -- Comportamiento de caminata aleatoria
            if self.walk_timer > math.random(3, 6) then
                self.walk_timer = 0

                -- 50% de probabilidad de caminar
                if math.random(1, 2) == 1 then
                    self.state = "walking"
                    self.direction = math.random(0, 360) * (math.pi / 180)
                else
                    self.state = "idle"
                end
            end

            -- Aplicar movimiento
            if self.state == "walking" then
                local speed = 0.8
                local vel = {
                    x = math.sin(self.direction) * speed,
                    y = -5, -- Gravedad
                    z = math.cos(self.direction) * speed
                }

                self.object:set_velocity(vel)
                self.object:set_yaw(self.direction)

                -- Limitar distancia del hogar (radio de 20 bloques)
                if self.home_pos then
                    local dist = vector.distance(pos, self.home_pos)
                    if dist > 20 then
                        -- Regresar hacia casa
                        local dir_to_home = vector.direction(pos, self.home_pos)
                        self.direction = math.atan2(dir_to_home.x, dir_to_home.z)
                    end
                end
            else
                self.object:set_velocity({x=0, y=-5, z=0})
            end
        end,

        on_rightclick = function(self, clicker)
            if not clicker or not clicker:is_player() then return end

            local player_name = clicker:get_player_name()

            -- Menú de interacción simple
            local formspec = "size[6,4]" ..
                "label[0,0;💬 Conversación con " .. (def.title or villager_type) .. "]" ..
                "button[0,1;6,1;dialogue_greeting;👋 Saludar]" ..
                "button[0,2;6,1;dialogue_work;💼 Preguntarle sobre su trabajo]" ..
                "button[0,3;6,1;dialogue_education;📚 Aprender algo nuevo]"

            if custom_villagers.settings.enable_trading then
                formspec = formspec .. "button[0,3.5;6,1;trade;🛒 Comerciar]"
            end

            minetest.show_formspec(player_name, "custom_villagers:interact_" .. self.villager_type, formspec)
        end,

        on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
            -- Aldeanos pacíficos - no se pueden matar
            if puncher and puncher:is_player() then
                minetest.chat_send_player(puncher:get_player_name(),
                    "🚫 Los aldeanos son parte de nuestra comunidad. ¡No debemos lastimarlos!")
            end
        end,
    })

    log("info", "Registered villager type: " .. villager_type)
end

-- Manejar interacciones de diálogo
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if not formname:find("^custom_villagers:interact_") then
        return
    end

    local villager_type = formname:gsub("^custom_villagers:interact_", "")
    local player_name = player:get_player_name()

    if fields.dialogue_greeting then
        local msg = get_dialogue(villager_type, "greetings")
        minetest.chat_send_player(player_name, "💬 Aldeano: " .. msg)

    elseif fields.dialogue_work then
        local msg = get_dialogue(villager_type, "about_work")
        minetest.chat_send_player(player_name, "💼 Aldeano: " .. msg)

    elseif fields.dialogue_education then
        local msg = get_dialogue(villager_type, "education")
        minetest.chat_send_player(player_name, "📚 Aldeano: " .. msg)

    elseif fields.trade then
        show_trade_formspec(player_name, villager_type)
    end
end)

-- ============================================================================
-- 5. DEFINICIÓN DE TIPOS DE ALDEANOS
-- ============================================================================

-- Agricultor
register_villager("farmer", {
    title = "Agricultor",
    hp_max = 20,
    textures = {
        "custom_villagers_farmer_top.png",
        "custom_villagers_farmer_bottom.png",
        "custom_villagers_farmer_side.png",
        "custom_villagers_farmer_side.png",
        "custom_villagers_farmer_front.png",
        "custom_villagers_farmer_back.png",
    },
})

-- Bibliotecario
register_villager("librarian", {
    title = "Bibliotecario",
    hp_max = 20,
})

-- Maestro
register_villager("teacher", {
    title = "Maestro",
    hp_max = 20,
})

-- Explorador
register_villager("explorer", {
    title = "Explorador",
    hp_max = 25,
})

-- ============================================================================
-- 6. COMANDOS DE ADMINISTRACIÓN
-- ============================================================================

-- Comando para spawnear aldeano
minetest.register_chatcommand("spawn_villager", {
    params = "<tipo>",
    description = "Spawea un aldeano interactivo (farmer, librarian, teacher, explorer)",
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
            return true, "✅ Aldeano " .. villager_type .. " spawneado en " .. minetest.pos_to_string(vector.round(pos))
        else
            return false, "❌ Error al spawnear aldeano"
        end
    end,
})

-- Comando de información
minetest.register_chatcommand("villager_info", {
    params = "",
    description = "Muestra información sobre el sistema de aldeanos",
    privs = {},
    func = function(name, param)
        local info = {
            "🏘️ === Sistema de Aldeanos de Wetlands ===",
            "Versión: " .. custom_villagers.version,
            "",
            "📋 Tipos de aldeanos disponibles:",
            "• Agricultor (farmer) - Cultiva vegetales",
            "• Bibliotecario (librarian) - Guarda libros",
            "• Maestro (teacher) - Enseña ciencia",
            "• Explorador (explorer) - Viaja por el mundo",
            "",
            "💬 Interacciones:",
            "• Click derecho para hablar",
            "• Aprende sobre sus trabajos",
            "• Comercia items útiles",
            "",
            "⏰ Rutinas:",
            "• Activos de día",
            "• Duermen de noche",
            "• Caminan cerca de su hogar",
        }

        return true, table.concat(info, "\n")
    end,
})

-- ============================================================================
-- 7. INICIALIZACIÓN FINAL
-- ============================================================================

log("info", "Custom Villagers v" .. custom_villagers.version .. " loaded successfully!")
log("info", "Registered villager types: farmer, librarian, teacher, explorer")
