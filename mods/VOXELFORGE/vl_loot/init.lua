local modpath = minetest.get_modpath(minetest.get_current_modname())

vl_loot = {
}


dofile(modpath .. "/item_modifier.lua")
dofile(modpath .. "/predicate.lua")
dofile(modpath .. "/number_provider.lua")
dofile(modpath .. "/engine.lua")


-- Fisher-Yates shuffle
local function shuffle(to_shuffle)
    for i = #to_shuffle, 2, -1 do
        local j = math.random(i)
        to_shuffle[i], to_shuffle[j] = to_shuffle[j], to_shuffle[i]
    end
end

--[[
Puts items in an inventory list into random slots.
* inv: InvRef
* listname: Inventory list name
* items: table of itemstacks to add

- If there are fewer itemstacks than slots, random slots will be filled
- If there are too many itemstacks, a random selection will be inserted to fill the container
- If there are existing items in the inventory, they will be deleted
]]

-- TODO: Make this deterministic
-- TODO: Currently overwrites itemstacks, could reimplement so it only inserts into empty slots
local function disperse_in_inventory(inv, listname, items)
	local size = inv:get_size(listname)

    -- If there are more slots than items, should add empty itemstacks to fill container
    while size > #items do
        table.insert(items, ItemStack())
    end

    -- Shuffle the order of items in slots
    shuffle(items)

    -- If there are too many itemstacks, decrease to inventory size
    -- TODO: Is this needed or is it handled by set_list?
    items = {unpack(items, 1, size)}

    -- Write the items back into the inventory
    inv:set_list(listname, items)
end


-- loot_table: container loot table
-- pos: position of container node
-- opener: objectref of entity that opened container
local function get_container_loot(loot_table, pos, opener)
    -- TODO: Provide better context (there are implied fields)
    local context = {
        ["this"] = opener,
        ["origin"] = pos,
    }
    return vl_loot.engine.get_loot(loot_table, context)
end

-- pos: integer node position of container
-- opener: objectref of entity that opened container
-- inventory: InvRef to put loot into
-- listname: list to put loot into in inventory
local function generate_container_loot_if_exists(pos, opener, inventory, listname)
    local container_meta = minetest.get_meta(pos)
    local loot_table_name = container_meta:get_string("loot_table")
    -- Do nothing if this container is not a loot container/has already been looted
    if loot_table_name == "" then return end
    -- Remove loot table metadata from this container
    container_meta:set_string("loot_table", "")
    -- Generate loot to fill this container with
    minetest.debug("Using loot table: " .. loot_table_name)
    local loot_table = vl_datapacks.get_resource("loot_table", loot_table_name)
    -- If invalid loot table, don't populate
    if not loot_table then
        minetest.log("warning", "Container had invalid loot table metadata (" .. loot_table_name .. ") at " .. vector.to_string(pos))
        return
    end
    local loot_items = get_container_loot(loot_table, pos, opener)
    -- Fill inventory
    disperse_in_inventory(inventory, listname, loot_items)
end

vl_loot.generate_container_loot_if_exists = generate_container_loot_if_exists

local S = minetest.get_translator(minetest.get_current_modname())
tt.register_snippet(function(itemstring, tool_caps, itemstack)
    if not itemstack then return end
    local loot_table = itemstack:get_meta():get_string("loot_table")
    if loot_table ~= "" then
        return S("Loot table: @1", loot_table), "#FFAA00"
    end
end)

minetest.register_chatcommand("lootchest", {
    params = "<loot table resource location>",
    privs = {["give"] = true},
    description = "Give yourself a loot chest with a specified loot table",
    func = function(name, param)
        if vl_datapacks.get_resource("loot_table", param) then
            local itemstack = ItemStack({
                name = "mcl_chests:chest",
                meta = {["loot_table"] = param,
                }
            })
            tt.reload_itemstack_description(itemstack)
            local player = minetest.get_player_by_name(name)
            local leftover = player:get_inventory():add_item("main", itemstack)
            if leftover:is_empty() then
                return true, "Gave loot chest with table: " .. param
            else
                -- Could not add to inventory
                return false, "No space in inventory"
            end
        else
            return false, "Loot table resource does not exist: " .. param
        end
    end
})

minetest.register_chatcommand("lootdispenser", {
    params = "<loot table resource location>",
    privs = {["give"] = true},
    description = "Give yourself a loot chest with a specified loot table",
    func = function(name, param)
        if vl_datapacks.get_resource("loot_table", param) then
            local itemstack = ItemStack({
                name = "mcl_dispensers:dispenser",
                meta = {["loot_table"] = param,
                }
            })
            tt.reload_itemstack_description(itemstack)
            local player = minetest.get_player_by_name(name)
            local leftover = player:get_inventory():add_item("main", itemstack)
            if leftover:is_empty() then
                return true, "Gave loot chest with table: " .. param
            else
                -- Could not add to inventory
                return false, "No space in inventory"
            end
        else
            return false, "Loot table resource does not exist: " .. param
        end
    end
})

minetest.register_chatcommand("lootbarrel", {
    params = "<loot table resource location>",
    privs = {["give"] = true},
    description = "Give yourself a loot chest with a specified loot table",
    func = function(name, param)
        if vl_datapacks.get_resource("loot_table", param) then
            local itemstack = ItemStack({
                name = "mcl_barrels:barrel_closed",
                meta = {["loot_table"] = param,
                }
            })
            tt.reload_itemstack_description(itemstack)
            local player = minetest.get_player_by_name(name)
            local leftover = player:get_inventory():add_item("main", itemstack)
            if leftover:is_empty() then
                return true, "Gave loot chest with table: " .. param
            else
                -- Could not add to inventory
                return false, "No space in inventory"
            end
        else
            return false, "Loot table resource does not exist: " .. param
        end
    end
})

--load_loot_tables(default_loot_path, expected_loot_tables, true)

minetest.debug(dump(vl_loot))

minetest.register_chatcommand("loot", {
    params = "<loot table resource location>",
    privs = {["give"] = true},
    description = "Give yourself a loot chest with a specified loot table",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local pos = player:get_pos()
        local loot_table = vl_datapacks.get_resource("loot_table", param)
        --minetest.debug("testloot table:", dump(loot_table))
        local loot = get_container_loot(loot_table, pos, player)
        --[[ for _, stack in ipairs(loot) do
            minetest.debug(stack:to_string())
        end ]]
        local player_inv = player:get_inventory()
        local inv_list = player_inv:get_list("main")
        for i, itemstack in ipairs(inv_list) do
            if itemstack:is_empty() then
                inv_list[i] = table.remove(loot, 1)
            end
        end
        player_inv:set_list("main", inv_list)
        if #loot > 0 then
            minetest.debug("Too much loot for inventory!")
        end
        return true
    end
})
