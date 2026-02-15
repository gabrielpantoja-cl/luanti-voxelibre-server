-- ============================================================================
-- npc_registry.lua - Registro unificado de NPCs
-- ============================================================================
-- Unifica register_npc (Star Wars) y register_classic_npc (clasicos)
-- en un solo sistema parametrizado

local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

wetlands_npcs.registry = {}

-- ============================================================================
-- CONFIGURACION DE MODELOS
-- ============================================================================

local MODELS = {
    human = {
        mesh = "wetlands_npc_human.b3d",
        collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
        -- mcl_armor_character.b3d requiere 3 capas: {skin, armor, cape}
        texture_layers = 3,
        animation = {
            stand_start = 0, stand_end = 79,
            walk_start = 168, walk_end = 187, walk_speed = 30,
            run_start = 440, run_end = 459, run_speed = 30,
            sit_start = 81, sit_end = 160,
        },
    },
    villager = {
        mesh = "mobs_mc_villager.b3d",
        collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
        texture_layers = 1,
        animation = {
            stand_start = 0, stand_end = 0,
            walk_start = 0, walk_end = 40, walk_speed = 25,
            run_start = 0, run_end = 40, run_speed = 25,
        },
    },
}

-- ============================================================================
-- FUNCION DE REGISTRO UNIFICADA
-- ============================================================================

function wetlands_npcs.registry.register(name, def)
    local full_name = modname .. ":" .. name
    local model_type = def.model or "human"
    local model = MODELS[model_type]

    if not model then
        minetest.log("error", "[wetlands_npcs] Unknown model type: " .. model_type)
        return
    end

    -- Preparar texturas segun modelo
    local skin_tex = def.texture or ("wetlands_npc_" .. name .. ".png")
    local validated_textures
    if model.texture_layers == 3 then
        validated_textures = {{skin_tex, "blank.png", "blank.png"}}
    else
        validated_textures = {{skin_tex}}
    end

    local mob_def = {
        description = def.description or S(name),
        type = "npc",
        spawn_class = "passive",
        passive = true,
        xp_min = 0,
        xp_max = 0,
        initial_properties = {
            hp_min = 10000,
            hp_max = 10000,
        },
        collisionbox = model.collisionbox,
        visual = "mesh",
        mesh = model.mesh,
        textures = validated_textures,
        makes_footstep_sound = true,
        walk_velocity = wetlands_npcs.config.movement.walk_velocity,
        run_velocity = wetlands_npcs.config.movement.run_velocity,
        drops = {},
        can_despawn = false,
        animation = model.animation,
        view_range = 16,
        fear_height = 4,
        jump = (def.jump ~= false),  -- default true, override con def.jump = false
        walk_chance = def.walk_chance or 33,
        custom_villager_type = name,
        armor_groups = {immortal = 1, fleshy = 0},

        -- Activacion: restaurar inmortalidad + inicializar persistencia
        on_activate = function(self, staticdata, dtime_s)
            self.object:set_armor_groups({immortal = 1, fleshy = 0})
            self.object:set_hp(self.object:get_properties().hp_max or 10000)

            -- Inicializar persistencia (usa posicion+tipo como ID unico)
            local pos = self.object:get_pos()
            local npc_id, npc_state = wetlands_npcs.persistence.init_npc(name, pos)
            self._npc_id = npc_id
        end,

        -- Custom tick: mantener inmortalidad (siempre, sin excepciones)
        do_custom = function(self, dtime)
            local hp = self.object:get_hp()
            local max_hp = self.object:get_properties().hp_max or 10000
            if hp < max_hp then
                self.object:set_hp(max_hp)
                self.object:set_armor_groups({immortal = 1, fleshy = 0})
            end

            self._immortal_check = (self._immortal_check or 0) + dtime
            if self._immortal_check > 3 then
                self._immortal_check = 0
                local armor = self.object:get_armor_groups()
                if not armor.immortal or armor.immortal ~= 1
                   or (armor.fleshy or 0) ~= 0 then
                    self.object:set_armor_groups({immortal = 1, fleshy = 0})
                end
            end
        end,

        -- Click derecho: abrir formspec
        on_rightclick = function(self, clicker)
            if not clicker or not clicker:is_player() then return end

            -- Auto-fix tipo NPC
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

            -- Registrar interaccion en persistencia
            if self._npc_id then
                wetlands_npcs.persistence.record_interaction(
                    self._npc_id, player_name)
            end

            local pos = self.object:get_pos()
            if pos then
                wetlands_npcs.play_npc_voice(self.custom_villager_type, pos)
            end

            pcall(function()
                wetlands_npcs.formspecs.show_interaction(
                    player_name, self.custom_villager_type,
                    display_name, self._npc_id)
            end)
        end,

        -- Punch: bloquear danio para TODOS (incluido admin)
        -- Para eliminar NPCs usar /npc_remove
        do_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
            -- Restaurar inmortalidad y HP siempre
            self.object:set_armor_groups({immortal = 1, fleshy = 0})
            self.object:set_hp(self.object:get_properties().hp_max or 10000)
            self.health = 10000

            if puncher and puncher:is_player() then
                local player_name = puncher:get_player_name()
                local npc_display = wetlands_npcs.display_names[name] or name
                if minetest.check_player_privs(player_name, {server = true}) then
                    minetest.chat_send_player(player_name,
                        minetest.colorize("#FFAA00",
                        S("[Admin] @1 es inmortal. Usa /npc_remove para eliminar NPCs.", npc_display)))
                else
                    minetest.chat_send_player(player_name,
                        minetest.colorize("#FF6B6B",
                        S("[Servidor] Los NPCs de Wetlands son tus amigos. No puedes hacerles dano!")))
                end
            end
            return false
        end,
    }

    -- Inyectar sistema AI
    wetlands_npcs.behaviors.inject_into_mob(mob_def)

    mcl_mobs.register_mob(full_name, mob_def)
    minetest.log("info", "[wetlands_npcs] Registered NPC: " .. name ..
        " (model=" .. model_type .. ")")
end

-- ============================================================================
-- REGISTRAR TODOS LOS NPCs
-- ============================================================================

-- Star Wars NPCs (modelo humano 64x32)
wetlands_npcs.registry.register("luke", {
    description = S("Luke Skywalker"),
    model = "human",
})

wetlands_npcs.registry.register("anakin", {
    description = S("Anakin Skywalker"),
    model = "human",
})

wetlands_npcs.registry.register("yoda", {
    description = S("Baby Yoda"),
    model = "human",
})

wetlands_npcs.registry.register("mandalorian", {
    description = S("Mandalorian"),
    model = "human",
})

wetlands_npcs.registry.register("leia", {
    description = S("Princesa Leia"),
    model = "human",
})

wetlands_npcs.registry.register("splinter", {
    description = S("Maestro Splinter"),
    model = "human",
    walk_chance = 0,  -- Casi estatico: mcl_mobs no lo mueve por su cuenta
    jump = false,     -- No salta
})

wetlands_npcs.registry.register("sensei_wu", {
    description = S("Sensei Wu"),
    model = "human",
    walk_chance = 0,  -- Casi estatico: mcl_mobs no lo mueve por su cuenta
    jump = false,     -- No salta
})

-- Classic NPCs (modelo villager 64x64)
wetlands_npcs.registry.register("farmer", {
    description = S("Agricultor de Wetlands"),
    model = "villager",
})

wetlands_npcs.registry.register("librarian", {
    description = S("Bibliotecario de Wetlands"),
    model = "villager",
})

wetlands_npcs.registry.register("teacher", {
    description = S("Maestro de Wetlands"),
    model = "villager",
})

wetlands_npcs.registry.register("explorer", {
    description = S("Explorador de Wetlands"),
    model = "villager",
})

-- ============================================================================
-- MIGRACION DE ENTIDADES LEGACY
-- ============================================================================

for _, vtype in ipairs({"farmer", "librarian", "teacher", "explorer"}) do
    minetest.register_entity(":custom_villagers:" .. vtype, {
        on_activate = function(self, staticdata, dtime_s)
            local pos = self.object:get_pos()
            self.object:remove()
            if pos then
                minetest.add_entity(pos, "wetlands_npcs:" .. vtype)
                minetest.log("info", "[wetlands_npcs] Migrated custom_villagers:" ..
                    vtype .. " -> wetlands_npcs:" .. vtype)
            end
        end,
    })
end

minetest.log("action", "[wetlands_npcs] NPC registry loaded (11 NPCs, legacy migration active)")
