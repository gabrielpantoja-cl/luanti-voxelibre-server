-- MCL Potions Hotfix Mod
-- Soluciona crash con pociones de invisibilidad en VoxeLibre 0.90.1
-- Bug: attempt to index local 'luaentity' (a nil value) en functions.lua:1717

minetest.log("action", "[mcl_potions_hotfix] Iniciando hotfix para bug de invisibilidad...")

-- 1. OCULTAR POCIONES DE INVISIBILIDAD DEL INVENTARIO CREATIVO
-- Esto previene que los jugadores obtengan estas pociones problemáticas

local invisibility_potions = {
    "mcl_potions:invisibility",
    "mcl_potions:invisibility_plus",
    "mcl_potions:invisibility_splash",
    "mcl_potions:invisibility_plus_splash",
    "mcl_potions:invisibility_lingering",
    "mcl_potions:invisibility_plus_lingering",
    "mcl_potions:invisibility_arrow",
}

-- Ocultar cada poción de invisibilidad del inventario creativo
for _, potion_name in ipairs(invisibility_potions) do
    if minetest.registered_items[potion_name] then
        local current_groups = minetest.registered_items[potion_name].groups or {}
        current_groups.not_in_creative_inventory = 1

        minetest.override_item(potion_name, {
            groups = current_groups,
            description = minetest.registered_items[potion_name].description .. " [DESHABILITADA - Bug conocido]"
        })

        minetest.log("action", "[mcl_potions_hotfix] Poción ocultada: " .. potion_name)
    end
end

-- 2. PARCHEAR FUNCIÓN make_invisible PARA EVITAR CRASH
-- Sobrescribir la función problemática con validación nil-safe

if mcl_potions and mcl_potions.make_invisible then
    -- Guardar función original
    local original_make_invisible = mcl_potions.make_invisible

    -- Función parcheada con validación nil
    mcl_potions.make_invisible = function(obj, factor)
        -- Validar que obj existe
        if not obj then
            minetest.log("warning", "[mcl_potions_hotfix] Attempted to make nil object invisible")
            return
        end

        -- Validar que obj tiene métodos necesarios
        if not obj.get_luaentity then
            minetest.log("warning", "[mcl_potions_hotfix] Object doesn't have get_luaentity method")
            return
        end

        -- Validar que luaentity existe
        local luaentity = obj:get_luaentity()
        if not luaentity then
            minetest.log("warning", "[mcl_potions_hotfix] Object luaentity is nil - skipping invisibility")
            return
        end

        -- Si todas las validaciones pasan, llamar función original
        return original_make_invisible(obj, factor)
    end

    minetest.log("action", "[mcl_potions_hotfix] Función make_invisible parcheada exitosamente")
else
    minetest.log("warning", "[mcl_potions_hotfix] No se encontró mcl_potions.make_invisible para parchear")
end

-- 3. REMOVER ENTIDADES DE POCIONES DE INVISIBILIDAD EXISTENTES
-- Limpiar entidades problemáticas que ya existen en el mundo

minetest.register_globalstep(function(dtime)
    for _, obj in ipairs(minetest.get_objects_inside_radius({x=0, y=0, z=0}, 32000)) do
        local luaentity = obj:get_luaentity()
        if luaentity and luaentity.name then
            -- Detectar entidades de pociones de invisibilidad
            if luaentity.name:match("invisibility") then
                minetest.log("warning", "[mcl_potions_hotfix] Removiendo entidad problemática: " .. luaentity.name)
                obj:remove()
            end
        end
    end
end)

-- 4. MENSAJE INFORMATIVO PARA ADMINS
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local privs = minetest.get_player_privs(name)

    if privs.server then
        minetest.after(3, function()
            minetest.chat_send_player(name,
                minetest.colorize("#FFA500", "⚠️ [Hotfix Activo] Pociones de invisibilidad deshabilitadas por bug conocido de VoxeLibre"))
        end)
    end
end)

minetest.log("action", "[mcl_potions_hotfix] Mod cargado exitosamente - " .. #invisibility_potions .. " pociones ocultadas y función parcheada")