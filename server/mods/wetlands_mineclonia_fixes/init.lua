-- wetlands_mineclonia_fixes: parches puntuales a bugs de Mineclonia sin tocar el juego.
--
-- Bug 1 (2026-11-09, Plano 30003): una explosion de TNT que alcanza una fogata
-- tumba el servidor. mcl_explosions llama core.dig_node(pos) sin digger; el motor
-- pasa un digger falso sin inventario, y en mundo creativo campfire_drops()
-- (mcl_campfires/api.lua:45) hace inv:room_for_item() con inv = nil ->
-- "attempt to index local 'inv' (a nil value)" -> AsyncErr -> shutdown.
-- Fix: envolver after_dig_node de las fogatas y, si el digger no es un jugador
-- real con inventario, pasar uno ficticio inofensivo (no agrega nada a nadie).

local modname = minetest.get_current_modname()

local EMPTY_INV = {
	room_for_item = function() return false end,
	contains_item = function() return true end,
	add_item = function(_, _, stack) return stack end,
}

local FAKE_DIGGER = {
	is_player = function() return false end,
	get_player_name = function() return "" end,
	get_wielded_item = function() return ItemStack("") end,
	get_inventory = function() return EMPTY_INV end,
}

local function has_inventory(digger)
	if not digger or type(digger.get_inventory) ~= "function" then
		return false
	end
	local ok, inv = pcall(digger.get_inventory, digger)
	return ok and inv ~= nil
end

local patched = 0
for name, def in pairs(minetest.registered_nodes) do
	if name:sub(1, 14) == "mcl_campfires:" and def.after_dig_node then
		local orig = def.after_dig_node
		minetest.override_item(name, {
			after_dig_node = function(pos, oldnode, oldmeta, digger)
				if not has_inventory(digger) then
					digger = FAKE_DIGGER
				end
				return orig(pos, oldnode, oldmeta, digger)
			end,
		})
		patched = patched + 1
	end
end

minetest.log("warning", "[" .. modname .. "] Loaded successfully (" .. patched .. " fogatas parchadas)")
