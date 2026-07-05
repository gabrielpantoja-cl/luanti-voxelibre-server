-- ============================================================================
-- valdivia_no_explosions
-- ============================================================================
-- Anti-grief para el mundo de Valdivia (puerto 30001), que NO tiene proteccion
-- de area. Queremos que la gente construya y embellezca la ciudad, no que la
-- destruya. Dos capas trabajan juntas:
--
--   1. mcl_explosions_griefing = false (en luanti-valdivia.conf) -- la GARANTIA:
--      ninguna explosion destruye nodos (TNT, creeper, ghast, vagoneta TNT,
--      cristal del End, camas en dimension equivocada, respawn anchor, wither).
--      Todo eso pasa por mcl_explosions.explode(), que respeta ese ajuste.
--
--   2. Este mod -- la POLITICA: esconde los items explosivos/incendiarios del
--      inventario creativo (los no-admin no tienen priv 'give', asi que quedan
--      fuera de alcance) y deja el TNT inerte para que ni siquiera destelle.
--
-- Idioma: espanol. Apropiado para ninos 7+.

local modname = minetest.get_current_modname()

-- ============================================================================
-- 1. OCULTAR ITEMS EXPLOSIVOS / INCENDIARIOS DEL INVENTARIO CREATIVO
-- ============================================================================
-- No los borramos del juego (romperia recetas/compatibilidad); solo los
-- marcamos not_in_creative_inventory. Preservamos el resto de groups.
local HIDE = {
    "mcl_tnt:tnt",                 -- TNT
    "mcl_minecarts:tnt_minecart",  -- vagoneta con TNT
    "mcl_end:crystal",             -- cristal del End (explota fuerte)
    "mcl_fire:fire_charge",        -- carga de fuego (incendia)
    "mcl_fire:flint_and_steel",    -- mechero (enciende TNT y fuego)
    "mcl_beds:respawn_anchor",     -- respawn anchor (explota fuera del End)
}

local function hide_from_creative(name)
    local def = minetest.registered_items[name]
    if not def then return end  -- item no existe en esta version: se omite
    local groups = table.copy(def.groups or {})
    groups.not_in_creative_inventory = 1
    minetest.override_item(name, {groups = groups})
    minetest.log("action", "[" .. modname .. "] Oculto del creativo: " .. name)
end

for _, name in ipairs(HIDE) do
    hide_from_creative(name)
end

-- ============================================================================
-- 2. DEJAR EL TNT INERTE
-- ============================================================================
-- Aunque alguien logre encender un TNT (mechero, fuego, redstone o cadena de
-- explosion), que no haga absolutamente nada. La capa 1 ya impide el dano a
-- nodos; esto ademas evita el destello/entidad molesta.
if minetest.registered_nodes["mcl_tnt:tnt"] then
    minetest.override_item("mcl_tnt:tnt", {
        on_blast   = function() end,            -- cadena de explosiones
        _on_ignite = function() return true end, -- mechero: "manejado", no hace nada
        _on_burn   = function() end,            -- fuego / entidad ardiendo
        mesecons   = { effector = { action_on = function() end } },  -- redstone
    })
    minetest.log("action", "[" .. modname .. "] TNT dejado inerte")
end

minetest.log("action", "[" .. modname .. "] Loaded successfully")
