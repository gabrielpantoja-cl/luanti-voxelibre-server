--
-- fuel
--

function automobiles_lib.contains(table, val)
    for k,v in pairs(table) do
        if k == val then
            return v
        end
    end
    return false
end

function automobiles_lib.loadFuel(self, player_name, free, max_fuel)
    free = free or false
    local player = minetest.get_player_by_name(player_name)
    local inv = player:get_inventory()

    local itmstck=player:get_wielded_item()
    local item_name = ""
    if itmstck then item_name = itmstck:get_name() end

    local fuel = automobiles_lib.contains(automobiles_lib.fuel, item_name)
    --minetest.chat_send_all(dump(fuel))
    if fuel or free == true then
        local stack = ItemStack(item_name .. " 1")
        if self._energy < max_fuel then
            itmstck:set_count(1)

            if free == false then inv:remove_item("main", itmstck) end
            if fuel then
                self._energy = self._energy + fuel
                -- Wetlands Educational Message System
                if automobiles_lib.educational and automobiles_lib.educational.get_fuel_message then
                    local fuel_msg = automobiles_lib.educational.get_fuel_message(item_name)
                    minetest.chat_send_player(player_name, fuel_msg)
                end
            end
            if self._energy > max_fuel then self._energy = max_fuel end
            automobiles_lib.last_fuel_display = 0
            if self._energy == max_fuel then
                minetest.chat_send_player(player_name, "🔋 ¡Tanque lleno! Listo para la aventura")
            end
        end

        return true
    end

    return false
end

