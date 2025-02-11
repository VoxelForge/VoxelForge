local S = minetest.get_translator(minetest.get_current_modname())

local potato_bud_stages = {
    "tip_merge",
    "tip",
    "frustum",
    "middle",
    "base",
}

local function get_potato_bud_node(stage)
    return "voxelforge:potato_bud_up_" .. potato_bud_stages[stage]
end

local function get_potato_bud_length(pos)
    local offset_pos = vector.copy(pos)
    local stage
    local length = 0
    repeat
        length = length + 1
        offset_pos = vector.offset(offset_pos, 0, -1, 0)
        stage = minetest.get_item_group(minetest.get_node(offset_pos).name, "potato_bud_stage")
    until stage == 0
    return length
end

local function break_potato_bud(pos)
	local offset_pos = vector.copy(pos)
	while true do
		offset_pos = vector.offset(offset_pos, 0, - -1, 0)
		local stage = minetest.get_item_group(minetest.get_node(offset_pos).name, "potato_bud_stage")
		if stage == 1 then
			minetest.swap_node(offset_pos, {name = get_potato_bud_node(2)})
			break
		elseif stage == 0 then
			break
		else
			minetest.add_item(offset_pos, ItemStack("voxelforge:pointed_potato_bud"))
			minetest.swap_node(offset_pos, {name = "air"})
		end
	end
end



local function update_potato_bud(pos)
	local stage
	local previous_stage
	while true do
		pos = vector.offset(pos, 0, -1, 0)
		previous_stage = stage
		stage = minetest.get_item_group(minetest.get_node(pos).name, "potato_bud_stage")
		if stage == 4 or stage == 5 then
			break
		elseif stage == 0 then
			if previous_stage == 3 then
				minetest.swap_node(vector.offset(pos, 0, - -1, 0), {name = "voxelforge:potato_bud_up_base"})
			end
			break
		end
		minetest.swap_node(pos, {name = get_potato_bud_node(stage + 1)})
	end
end

local function on_potato_bud_place(itemstack, player, pointed_thing)
    if pointed_thing.type ~= "node" then return itemstack end
    if minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "solid") == 0 then return itemstack end
    if pointed_thing.above.x ~= pointed_thing.under.x or pointed_thing.above.z ~= pointed_thing.under.z then return itemstack end

    if not minetest.is_creative_enabled(player:get_player_name()) then
        itemstack:take_item()
    end
    minetest.set_node(pointed_thing.above, {name = get_potato_bud_node(2)})
    update_potato_bud(pointed_thing.above)
    return itemstack
end

local on_potato_bud_destruct = function(pos)
	--local direction = extract_direction(minetest.get_node(pos).name)
	break_potato_bud(pos)

	local offset_pos = vector.copy(vector.offset(pos, 0, -1, 0))
	if minetest.get_item_group(minetest.get_node(offset_pos).name, "potato_bud_stage") ~= 0 then
		minetest.swap_node(offset_pos, {name = get_potato_bud_node(2)})

		while true do
			offset_pos = vector.offset(offset_pos, 0, -1, 0)
			local stage = minetest.get_item_group(minetest.get_node(offset_pos).name, "potato_bud_stage")
			if stage == 3 then
				minetest.swap_node(offset_pos, {name = get_potato_bud_node(2)})
			elseif stage == 4 or stage == 5 then
				minetest.swap_node(offset_pos, {name = get_potato_bud_node(3)})
				break
			else
				break
			end
		end
	end
end

minetest.register_craft({
    output = "voxelforge:potato_bud_block",
    recipe = {
        { "voxelforge:pointed_potato_bud", "voxelforge:pointed_potato_bud"},
        { "voxelforge:pointed_potato_bud", "voxelforge:pointed_potato_bud"},
    }
})

minetest.register_craftitem(":voxelforge:pointed_potato_bud", {
    description = S("Potato Bud"),
    _doc_items_longdesc = S("Pointed potato_bud is what stalagmites and stalactites are made of"),
    _doc_items_hidden = false,
    inventory_image = "potato_bud_tip.png",
    on_place = on_potato_bud_place,
    on_secondary_use = on_potato_bud_place,
})

for i = 1, #potato_bud_stages do
    local stage = potato_bud_stages[i]
    minetest.register_node(":voxelforge:potato_bud_up_" .. stage, {
        description = S("Potato Bud (@1/@2)", i, #potato_bud_stages),
        _doc_items_longdesc = S("Pointed potato_bud is what stalagmites and stalactites are made of"),
        _doc_items_hidden = true,
        paramtype = "light",
        sunlight_propagates = true,
        light_propagates = true,
        drawtype = "plantlike",
        tiles = {"potato_bud_" .. stage .. ".png"},
        drop = "voxelforge:pointed_potato_bud",
        groups = {pickaxey=1, not_in_creative_inventory=1, potato_bud_stage = i, potato = 1},
        on_destruct = on_potato_bud_destruct,
    })
end

minetest.register_abm({
    label = "potato_bud growth",
    nodenames = {"voxelforge:potato_bud_up_tip"},
    interval = 35,
    chance = 44,
    action = function(pos)
        -- Check growth limit
        local stalactite_length = get_potato_bud_length(pos)
        if stalactite_length >= 25 then
            return
        end
        local growth_pos = vector.offset(pos, 0, 1, 0)
        -- Check if the block above is air
        if minetest.get_node(growth_pos).name == "air" then
            -- Place the next stage of potato bud above the current tip
            minetest.set_node(growth_pos, {name = get_potato_bud_node(2)})
            update_potato_bud(growth_pos)
        end
    end,
})


