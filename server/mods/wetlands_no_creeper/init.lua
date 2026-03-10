-- wetlands_no_creeper: Bloquea spawn de Creepers (stalkers) en Wetlands
-- VoxeLibre renombro "creeper" a "stalker" (mobs_mc:stalker)

local blocked = {
	["mobs_mc:stalker"] = true,
	["mobs_mc:stalker_overloaded"] = true,
	["mobs_mc:creeper"] = true,            -- alias legacy
	["mobs_mc:creeper_charged"] = true,    -- alias legacy
}

-- Sobrescribir on_activate para que se autodestruyan al spawnear
minetest.register_on_mods_loaded(function()
	for mob_name, _ in pairs(blocked) do
		local def = minetest.registered_entities[mob_name]
		if def then
			local original_activate = def.on_activate
			def.on_activate = function(self, staticdata, dtime_s)
				self.object:remove()
			end
			minetest.log("action", "[wetlands_no_creeper] Bloqueado: " .. mob_name)
		end
	end
end)

minetest.log("action", "[wetlands_no_creeper] Mod cargado - Creepers/Stalkers bloqueados")
