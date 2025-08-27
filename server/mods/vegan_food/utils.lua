local utils = {}

function utils.add_to_group(itemname, groupname)
	if not core.registered_items[itemname] then
		return
	end
	local groups = core.registered_items[itemname].groups
	if not groups[groupname] then
		groups[groupname] = 1
		core.override_item(itemname, {
			groups = groups
		})
	end
end

function utils.shallow_copy(orig)
	local copy = {}
	for k, v in pairs(orig) do
		copy[k] = v
	end
	return copy
end

return utils
