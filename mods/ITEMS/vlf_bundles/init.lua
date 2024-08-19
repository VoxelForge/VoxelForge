if minetest.settings:get_bool('bundles', true) then
local max_storage = 64

local function on_rightclick(itemstack, placer, pointed_thing)
	-- Get the meta information from the itemstack
	local meta = itemstack:get_meta()
	local stored_items = meta:get_string("stored_items")

	if stored_items == "" then
		return itemstack
	end
	local items = minetest.deserialize(stored_items)
	--minetest.log("error", "" .. minetest.serialize(items) .. "")
	for _, item in ipairs(items) do
		local dropped_item = minetest.add_item(placer:get_pos(), item)
		if dropped_item then
			dropped_item:get_luaentity().itemstring = ItemStack(item):to_string()
		end
	end

	-- Clear the stored items
	meta:set_string("stored_items", "")
	itemstack:set_name("vlf_bundles:bundle")
	--itemstack:set_wear(0)
	return itemstack
end

-- Function to dynamically register storage cube items with suffixes
local function register_bundle_items()
	for i = 1, max_storage do
		local item_name = "vlf_bundles:bundle_" .. i
		minetest.register_craftitem(item_name, {
			description = "Bundle \n" ..core.colorize("#5B5B5B","".. i .."/64"),
			inventory_image = "vlf_bundles_bundle_filled.png^vlf_bundles_"..i..".png",
			wield_image = "vlf_bundles_bundle_filled.png",
			stack_max = 1,
			groups = {not_in_creative_inventory = 1},
			on_place = on_rightclick,
			on_secondary_use = on_rightclick,
		})
	end
end

-- Register the storage cube items
register_bundle_items()

-- Main storage cube item
minetest.register_craftitem("vlf_bundles:bundle", {
	description = "Bundle",
	inventory_image = "vlf_bundles_bundle.png",
	stack_max = 1,
})

local function update_bundle_item(bundle_stack)
	local meta = bundle_stack:get_meta()
	local stored_items = meta:get_string("stored_items")
	local items = stored_items ~= "" and minetest.deserialize(stored_items) or {}
	local item_count = #items
	local wear = math.floor((item_count / max_storage) * 65535)
	local new_name = item_count > 0 and "vlf_bundles:bundle_" .. item_count or "vlf_bundles:bundle"
	bundle_stack:set_name(new_name)
	bundle_stack:set_wear(wear)
end

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	if action == "move" or action == "put" then
		local from_list = inventory_info.from_list
		local from_index = inventory_info.from_index
		local to_list = inventory_info.to_list
		local to_index = inventory_info.to_index

		if to_list == "main" and inventory:get_stack(to_list, to_index):get_name():match("^vlf_bundles:bundle") then
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
