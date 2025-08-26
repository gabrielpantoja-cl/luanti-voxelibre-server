-- Vegan Replacements Mod
-- Elimina items no veganos y los reemplaza con alternativas veganas
-- Para el servidor Vegan Wetlands

local S = minetest.get_translator("vegan_replacements")

-- Lista de items no veganos que serán eliminados/reemplazados
local non_vegan_items = {
    -- Carnes crudas
    "mcl_mobitems:rotten_flesh",
    "mcl_mobitems:mutton",
    "mcl_mobitems:beef", 
    "mcl_mobitems:chicken",
    "mcl_mobitems:porkchop",
    "mcl_mobitems:rabbit",
    
    -- Carnes cocidas
    "mcl_mobitems:cooked_mutton",
    "mcl_mobitems:cooked_beef",
    "mcl_mobitems:cooked_chicken", 
    "mcl_mobitems:cooked_porkchop",
    "mcl_mobitems:cooked_rabbit",
    
    -- Derivados animales
    "mcl_mobitems:leather",
    "mcl_mobitems:leather_piece",
    
    -- Otros productos animales problemáticos
    "mcl_mobitems:rabbit_stew"
}

-- Función para eliminar un item completamente
local function disable_item(itemname)
    if minetest.registered_items[itemname] then
        -- Sobrescribe el item para hacerlo no disponible
        minetest.override_item(itemname, {
            groups = {},
            drop = "",
            on_drop = function() return nil end,
            on_place = function() return nil end,
            on_secondary_use = function() return nil end,
        })
        
        -- Elimina de creative inventory
        minetest.override_item(itemname, {
            groups = {not_in_creative_inventory = 1}
        })
        
        minetest.log("info", "[Vegan Replacements] Item eliminado: " .. itemname)
    end
end

-- Reemplazos veganos específicos
local vegan_replacements = {
    -- Reemplazar carne podrida con manzana podrida (menos dañina)
    ["mcl_mobitems:rotten_flesh"] = "mcl_core:apple", 
    
    -- Reemplazar carnes con alternativas vegetales
    ["mcl_mobitems:mutton"] = "mcl_farming:potato_item",
    ["mcl_mobitems:beef"] = "mcl_farming:carrot_item", 
    ["mcl_mobitems:chicken"] = "mcl_farming:beetroot_item",
    ["mcl_mobitems:porkchop"] = "mcl_farming:potato_item",
    ["mcl_mobitems:rabbit"] = "mcl_farming:carrot_item",
    
    -- Carnes cocidas -> versiones horneadas
    ["mcl_mobitems:cooked_mutton"] = "mcl_farming:potato_item_baked",
    ["mcl_mobitems:cooked_beef"] = "mcl_farming:carrot_item",
    ["mcl_mobitems:cooked_chicken"] = "mcl_farming:beetroot_soup", 
    ["mcl_mobitems:cooked_porkchop"] = "mcl_farming:potato_item_baked",
    ["mcl_mobitems:cooked_rabbit"] = "mcl_farming:carrot_item",
    
    -- Cuero -> material vegetal alternativo
    ["mcl_mobitems:leather"] = "mcl_core:paper",
    ["mcl_mobitems:leather_piece"] = "mcl_core:paper",
    
    -- Estofado de conejo -> sopa de vegetales
    ["mcl_mobitems:rabbit_stew"] = "mcl_farming:beetroot_soup"
}

-- Función para reemplazar drops de entidades
local function replace_entity_drops()
    -- Lista de entidades que podrían dropar items no veganos
    local entities_to_modify = {
        "mobs_mc:zombie",
        "mobs_mc:villager_zombie", 
        "mobs_mc:piglin",
        "mobs_mc:horse"
    }
    
    for _, entity_name in ipairs(entities_to_modify) do
        if minetest.registered_entities[entity_name] then
            local entity_def = minetest.registered_entities[entity_name]
            
            -- Reemplaza drops si existen
            if entity_def.drops then
                for i, drop in ipairs(entity_def.drops) do
                    if drop.name and vegan_replacements[drop.name] then
                        entity_def.drops[i].name = vegan_replacements[drop.name]
                        minetest.log("info", "[Vegan Replacements] Drop reemplazado en " .. entity_name .. ": " .. drop.name .. " -> " .. vegan_replacements[drop.name])
                    end
                end
            end
        end
    end
end

-- Función para interceptar cuando un jugador obtiene un item no vegano
minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, user, pointed_thing)
    local itemname = itemstack:get_name()
    
    -- Si el item está en nuestra lista de no veganos
    for _, non_vegan in ipairs(non_vegan_items) do
        if itemname == non_vegan then
            local player_name = user:get_player_name()
            minetest.chat_send_player(player_name, 
                minetest.colorize("#FF6B6B", "🌱 ¡Este servidor es vegano! No puedes consumir productos de origen animal.")
            )
            
            -- Reemplazar con alternativa vegana si existe
            if vegan_replacements[itemname] then
                local replacement = vegan_replacements[itemname]
                local replacement_stack = ItemStack(replacement .. " " .. itemstack:get_count())
                user:get_inventory():add_item("main", replacement_stack)
                
                minetest.chat_send_player(player_name,
                    minetest.colorize("#90EE90", "🥕 Reemplazado con alternativa vegana: " .. 
                    minetest.registered_items[replacement].description or replacement)
                )
            end
            
            return itemstack -- Prevenir el consumo
        end
    end
end)

-- Interceptar cuando alguien intenta obtener items mediante /give o creative
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "mcl_inventory:creative" or formname:find("creative") then
        -- Verificar si está intentando obtener items no veganos
        -- Esta es una verificación básica, se puede expandir
        for field_name, _ in pairs(fields) do
            for _, non_vegan in ipairs(non_vegan_items) do
                if field_name:find(non_vegan) then
                    minetest.chat_send_player(player:get_player_name(),
                        minetest.colorize("#FF6B6B", "🌱 Item no vegano no disponible en este servidor.")
                    )
                end
            end
        end
    end
end)

-- Eliminar items no veganos al cargar el mod
minetest.register_on_mods_loaded(function()
    -- Eliminar todos los items no veganos
    for _, itemname in ipairs(non_vegan_items) do
        disable_item(itemname)
    end
    
    -- Modificar drops de entidades
    replace_entity_drops()
    
    minetest.log("info", "[Vegan Replacements] Mod cargado exitosamente. Items no veganos eliminados.")
end)

-- Comando para administradores para verificar items veganos
minetest.register_chatcommand("vegancheck", {
    params = "<item_name>",
    description = "Verifica si un item es vegano",
    privs = {server = true},
    func = function(name, param)
        if param == "" then
            return false, "Uso: /vegancheck <nombre_del_item>"
        end
        
        for _, non_vegan in ipairs(non_vegan_items) do
            if param == non_vegan then
                return true, "❌ " .. param .. " NO es vegano (eliminado del servidor)"
            end
        end
        
        return true, "✅ " .. param .. " es vegano (disponible)"
    end,
})

-- Comando para listar todos los items no veganos eliminados
minetest.register_chatcommand("listveganbans", {
    description = "Lista todos los items no veganos eliminados",
    privs = {server = true}, 
    func = function(name, param)
        local msg = "🚫 Items no veganos eliminados del servidor:\n"
        for i, item in ipairs(non_vegan_items) do
            local item_desc = minetest.registered_items[item] and 
                            minetest.registered_items[item].description or item
            msg = msg .. "• " .. item_desc .. " (" .. item .. ")\n"
        end
        return true, msg
    end,
})

minetest.log("info", "[Vegan Replacements] Mod inicializado - Eliminando " .. #non_vegan_items .. " items no veganos")