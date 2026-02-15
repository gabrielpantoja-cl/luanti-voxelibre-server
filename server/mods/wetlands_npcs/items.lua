-- ============================================================================
-- items.lua - Items unicos como recompensas de misiones
-- ============================================================================
-- Los items se crean usando metadata de ItemStack (nombre custom, lore)
-- No se registran nuevos items para evitar conflictos con VoxeLibre

wetlands_npcs.items = {}

-- Definiciones de items unicos por NPC
local UNIQUE_ITEMS = {
    luke = {
        id = "luke_lightsaber",
        base_item = "mcl_tools:sword_diamond",
        name = minetest.colorize("#00FF00", "Sable de Luz de Luke"),
        lore = "Forjado con un cristal Kyber de Dagobah. Que la Fuerza te acompanie.",
    },
    anakin = {
        id = "anakin_mech_tool",
        base_item = "mcl_tools:pick_iron",
        name = minetest.colorize("#4488FF", "Herramienta Mecanica de Anakin"),
        lore = "Construida con piezas de droides. El mejor piloto merece la mejor herramienta.",
    },
    yoda = {
        id = "yoda_wisdom_book",
        base_item = "mcl_books:written_book",
        name = minetest.colorize("#88FF88", "Libro de Sabiduria de Yoda"),
        lore = "Hazlo o no lo hagas. No hay intentar. - Yoda, 900 anios de sabiduria.",
    },
    mandalorian = {
        id = "mandalorian_beskar_helm",
        base_item = "mcl_armor:helmet_iron",
        name = minetest.colorize("#CCCCCC", "Casco de Beskar"),
        lore = "Forjado por la Armera del clan. Este es el Camino.",
    },
    leia = {
        id = "leia_communicator",
        base_item = "mcl_core:gold_ingot",
        name = minetest.colorize("#FF88CC", "Comunicador Holografico de Leia"),
        lore = "Usado para enviar el mensaje a Obi-Wan. La esperanza nunca muere.",
    },
    farmer = {
        id = "farmer_golden_seeds",
        base_item = "mcl_farming:wheat_seeds",
        name = minetest.colorize("#FFD700", "Semillas Doradas del Agricultor"),
        lore = "Semillas especiales cultivadas con amor y dedicacion. La tierra agradece.",
    },
    librarian = {
        id = "librarian_encyclopedia",
        base_item = "mcl_books:written_book",
        name = minetest.colorize("#8866DD", "Enciclopedia de Wetlands"),
        lore = "Todo el conocimiento de Wetlands en un solo tomo. Saber es poder.",
    },
    teacher = {
        id = "teacher_diploma",
        base_item = "mcl_core:paper",
        name = minetest.colorize("#FFAA00", "Diploma de Honor de Wetlands"),
        lore = "Otorgado por completar todas las lecciones. La educacion transforma.",
    },
    explorer = {
        id = "explorer_treasure_map",
        base_item = "mcl_core:paper",
        name = minetest.colorize("#00CCFF", "Mapa del Tesoro del Explorador"),
        lore = "Marca un lugar secreto en Wetlands. Solo los verdaderos aventureros lo encontraran.",
    },
}

wetlands_npcs.items.definitions = UNIQUE_ITEMS

-- Crear un ItemStack con metadata unica
function wetlands_npcs.items.create_unique(npc_type, player_name)
    local def = UNIQUE_ITEMS[npc_type]
    if not def then return nil end

    local stack = ItemStack(def.base_item)
    local meta = stack:get_meta()

    meta:set_string("description",
        def.name .. "\n" ..
        minetest.colorize("#AAAAAA", def.lore) .. "\n" ..
        minetest.colorize("#666666", "Otorgado a " .. player_name))

    -- Marcar como item unico para tracking
    meta:set_string("wetlands_unique_item", def.id)
    meta:set_string("wetlands_awarded_to", player_name)
    meta:set_int("wetlands_awarded_at", os.time())

    return stack
end

-- Verificar si jugador ya tiene un item unico especifico
function wetlands_npcs.items.player_has_unique(player_name, item_id)
    local player = minetest.get_player_by_name(player_name)
    if not player then return false end

    local inv = player:get_inventory()
    for i = 1, inv:get_size("main") do
        local stack = inv:get_stack("main", i)
        if not stack:is_empty() then
            local meta = stack:get_meta()
            if meta:get_string("wetlands_unique_item") == item_id then
                return true
            end
        end
    end
    return false
end

-- Dar item unico a jugador (con verificacion de duplicados)
function wetlands_npcs.items.award_unique(npc_type, player_name)
    local def = UNIQUE_ITEMS[npc_type]
    if not def then return false, "Item no definido" end

    if wetlands_npcs.items.player_has_unique(player_name, def.id) then
        return false, "Ya tienes este item"
    end

    local stack = wetlands_npcs.items.create_unique(npc_type, player_name)
    if not stack then return false, "Error al crear item" end

    local player = minetest.get_player_by_name(player_name)
    if not player then return false, "Jugador no encontrado" end

    local inv = player:get_inventory()
    if inv:room_for_item("main", stack) then
        inv:add_item("main", stack)

        -- Actualizar stats
        local data = wetlands_npcs.persistence.load_player(player_name)
        data.stats.total_unique_items = data.stats.total_unique_items + 1
        wetlands_npcs.persistence.save_player(player_name, data)

        if data.stats.total_unique_items >= 5 then
            wetlands_npcs.persistence.grant_achievement(player_name, "collector")
        end

        return true, def.name
    else
        return false, "Inventario lleno"
    end
end

minetest.log("action", "[wetlands_npcs] Unique items system loaded (" .. 9 .. " items)")
