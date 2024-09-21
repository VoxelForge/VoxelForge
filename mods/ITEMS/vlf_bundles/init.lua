if minetest.settings:get_bool('bundles', true) then

local max_storage = 64 -- Define the maximum number of items the bundle can hold

local function update_bundle_item(stack)
	local meta = stack:get_meta()
	local stored_items = minetest.deserialize(meta:get_string("stored_items")) or {}
	local item_count = #stored_items
	local item_def = stack:get_definition().inventory_image
	local inventory_image

	if item_count > 0 then
		if item_def and item_def ~= "" then
			inventory_image = item_def .. "^vlf_bundles_" .. item_count .. ".png"
		end
	else
		inventory_image = item_def
	end

	-- Update item description and image
	meta:set_string("description", "Bundle \n" .. core.colorize("#5B5B5B", item_count .. "/64"))
	meta:set_string("inventory_image", inventory_image)
	meta:set_string("wield_image", inventory_image)
end

local function on_leftclick(itemstack)
	local meta = itemstack:get_meta()
	local stored_items = minetest.deserialize(meta:get_string("stored_items")) or {}
	local item_count = #stored_items

	-- Create a table to group items by name
	local item_groups = {}
	for _, item in ipairs(stored_items) do
		local item_name = item:match("^[^:]+") -- Get item name without metadata
		if not item_groups[item_name] then
			item_groups[item_name] = {}
		end
		table.insert(item_groups[item_name], item)
	end

	-- Create a list of unique group names
	local group_names = {}
	for name in pairs(item_groups) do
		table.insert(group_names, name)
	end

	-- Ensure we have groups to cycle through
	local group_count = #group_names
	local stack_def = itemstack:get_definition().inventory_image

	if group_count == 0 then
		-- No items to cycle through
		meta:set_string("inventory_image", stack_def)
		meta:set_string("wield_image", stack_def)
		meta:set_int("selected_index", 0)
		return itemstack
	end

	-- Get the current selected index
	local selected_index = meta:get_int("selected_index")

	-- If selected_index is invalid, set it to 1
	if selected_index < 1 or selected_index > group_count then
		selected_index = 1
	else
		-- Otherwise, cycle to the next group
		selected_index = selected_index + 1
	end

	-- If selected_index exceeds the number of groups, reset it to 1
	if selected_index > group_count then
		selected_index = 1
	end

	-- Get the selected group and its first item
	local selected_item_name = group_names[selected_index]
	local selected_item = item_groups[selected_item_name][1] -- Select the first item from the group
	local item_def = minetest.registered_items[selected_item] or minetest.registered_nodes[selected_item]
	local inventory_image

	if item_def then
		local is_node = minetest.registered_nodes[selected_item] ~= nil
		if is_node then
			local node_def = minetest.registered_nodes[selected_item]
			if node_def.inventory_image and node_def.inventory_image ~= "" then
				-- Use the node's inventory image if available
				inventory_image = stack_def:gsub(".png", "") .. "_open_back.png" ..
							"^" .. node_def.inventory_image ..
							"^" .. stack_def:gsub(".png", "") .. "_open_front.png" ..
							"^vlf_bundles_" .. item_count .. ".png"
			else
				inventory_image = stack_def:gsub(".png", "") .. "_open_back.png" ..
							"^" .. stack_def:gsub(".png", "") .. "_open_front.png" ..
							"^vlf_bundles_" .. item_count .. ".png"
				--[[ We would need to have volumetric images of every block that didn't have an inventory image.
				--Due to the fact that we'll be changing textures, it makes little sense to do it yet.
				local texture_name = selected_item:gsub(":", "_") .. "_volumetric.png"
				inventory_image = stack_def:gsub(".png", "") .. "_open_back.png" ..
							"^" .. texture_name ..
							"^" .. stack_def:gsub(".png", "") .. "_open_front.png" ..
							"^vlf_bundles_" .. item_count .. ".png"]]
			end
		else
			-- Use item's inventory image
			if item_def.inventory_image and item_def.inventory_image ~= "" then
				inventory_image = stack_def:gsub(".png", "") .. "_open_back.png" ..
							"^" .. item_def.inventory_image ..
							"^" .. stack_def:gsub(".png", "") .. "_open_front.png" ..
							"^vlf_bundles_" .. item_count .. ".png"
			else
				inventory_image = stack_def .. "^vlf_bundles_" .. item_count .. ".png"
			end
		end
	else
		inventory_image = stack_def .. "^vlf_bundles_" .. item_count .. ".png"
	end

	-- Update metadata with the new selected index and inventory image
	meta:set_string("inventory_image", inventory_image)
	meta:set_string("wield_image", inventory_image)
	meta:set_int("selected_index", selected_index)

	return itemstack
end

local function on_rightclick(itemstack, placer, pointed_thing)
	local meta = itemstack:get_meta()
	local stored_items = minetest.deserialize(meta:get_string("stored_items")) or {}
	local item_count = #stored_items

	if item_count == 0 then
		-- No items to drop
		return itemstack
	end

	-- Get the selected item index, or use the most recent item if none is selected
	local selected_index = meta:get_int("selected_index") or 0
	local item_to_drop

	if selected_index > 0 and selected_index <= item_count then
		-- If an item is selected, drop all items of the selected type
		item_to_drop = stored_items[selected_index]
	else
		-- Drop all items of the most recently added type (if no item is selected)
		item_to_drop = stored_items[item_count]
	end

	-- Collect all items of the same type to drop
	local items_to_drop = {}
	local remaining_items = {}

	for _, item in ipairs(stored_items) do
		if item == item_to_drop then
			table.insert(items_to_drop, item)
		else
			table.insert(remaining_items, item)
		end
	end

	-- Drop all matching items
	local drop_pos = placer:get_pos()
	for _, item in ipairs(items_to_drop) do
		if drop_pos then
			local dropped_item = minetest.add_item(drop_pos, item)
			if dropped_item then
				dropped_item:get_luaentity().itemstring = ItemStack(item):to_string()
			end
		end
	end

	-- Update the stored items after dropping
	meta:set_string("stored_items", minetest.serialize(remaining_items))
	meta:set_int("selected_index", 0) -- Reset the selected index after dropping
	update_bundle_item(itemstack) -- Update the bundle's texture after dropping

	return itemstack
end

-- Color definitions for the bundles
local colordefs = {
	-- {name, dye}
	{"black", "Black"},
	{"blue", "Blue"},
	{"brown", "Brown"},
	{"cyan", "Cyan"},
	{"green", "Green"},
	{"gray", "Gray"},
	{"light_blue", "Light Blue"},
	{"light_gray", "Light Gray"},
	{"lime", "Lime"},
	{"magenta", "Magenta"},
	{"orange", "Orange"},
	{"pink", "Pink"},
	{"purple", "Purple"},
	{"red", "Red"},
	{"white", "White"},
	{"yellow", "Yellow"}
}

local function register_colored_bundles()
	for i = 1, max_storage do
		for _, color in ipairs(colordefs) do
			local item_name = "vlf_bundles:"..color[1].."_bundle"
			local inventory_image = "vlf_bundles_"..color[1].."_bundle.png"
			minetest.register_craftitem(item_name, {
				description = color[2] .. " Bundle",
				inventory_image = inventory_image,
				wield_image = inventory_image,
				stack_max = 1,
				groups = {dyed_bundle=1},
				on_place = on_rightclick,
				on_secondary_use = on_rightclick,
				on_use = on_leftclick,
			})
		end
	end
end

register_colored_bundles()

-- Function to copy metadata from the old bundle to the new one
local function transfer_bundle_metadata(old_stack, new_stack)
	-- Copy metadata from old to new stack
	local old_meta = old_stack:get_meta()
	local new_meta = new_stack:get_meta()

	-- Transfer all metadata fields
	local fields = old_meta:to_table().fields
	for key, value in pairs(fields) do
		new_meta:set_string(key, value)
	end

	return new_stack
end

-- Function to register crafts for colored bundles
local function register_bundle_craft(color_name, dye_item)
	if not color_name or not dye_item then
		return
	end

	minetest.register_craft({
		type = "shapeless",
		output = "vlf_bundles:"..color_name.."_bundle",
		--recipe = {"vlf_bundles:bundle", "vlf_dyes:" .. dye_item},
		recipe = {"group:dyed_bundle", "vlf_dyes:" .. dye_item},
	})
end
-- Callback for crafting to handle metadata transfer
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	-- Check if the crafted item is a colored bundle
	if itemstack:get_name():find("vlf_bundles:") then
		-- Iterate over the crafting grid to find the old bundle
		for i = 1, #old_craft_grid do
			local old_item = old_craft_grid[i]
			if old_item:get_name():find("vlf_bundles:") then
				-- Transfer the metadata from the old bundle to the new one
				transfer_bundle_metadata(old_item, itemstack)
				break
			end
		end
	end
	return itemstack
end)

-- Register crafts for all colors defined in colordefs
for _, color_def in ipairs(colordefs) do
	local color_name = color_def[1]
	local dye_item = color_def[1]
	if color_name and dye_item then
		register_bundle_craft(color_name, dye_item)
	end
end

-- Register the base bundle item
minetest.register_craftitem("vlf_bundles:bundle", {
    description = "Bundle",
    inventory_image = "vlf_bundles_bundle.png",
    wield_image = "vlf_bundles_bundle.png",
    stack_max = 1,
    groups = {dyed_bundle=1},
    on_place = on_rightclick,
    on_secondary_use = on_rightclick,
    on_use = on_leftclick,
})

minetest.register_craft({
	output = "vlf_bundles:bundle",
	recipe = {
		{"", "vlf_mobitems:string", ""},
		{"", "vlf_mobitems:leather", ""},
		{"", "", ""},
	},
})

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
    if action == "move" or action == "put" then
        local from_list = inventory_info.from_list
        local from_index = inventory_info.from_index
        local to_list = inventory_info.to_list
        local to_index = inventory_info.to_index

        if to_list == "main" and inventory:get_stack(to_list, to_index):get_name():match("^vlf_bundles:") then
            local bundle_stack = inventory:get_stack(to_list, to_index)
            local meta = bundle_stack:get_meta()
            local stored_items = meta:get_string("stored_items")
            local items = stored_items ~= "" and minetest.deserialize(stored_items) or {}

            if #items >= max_storage then
                return
            end

            local stack = inventory:get_stack(from_list, from_index)
            local count_to_add = math.min(stack:get_count(), max_storage - #items)
            for _ = 1, count_to_add do
                table.insert(items, stack:take_item(1):to_string())
            end

            meta:set_string("stored_items", minetest.serialize(items))
            update_bundle_item(bundle_stack)
            inventory:set_stack(from_list, from_index, stack)
            inventory:set_stack(to_list, to_index, bundle_stack)
        end
    end
end)
end

for i = 1, 64 do
	minetest.register_alias("vlf_bundles:bundle_"..i.."", "vlf_bundles:bundle")
end
