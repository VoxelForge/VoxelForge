local S = minetest.get_translator(minetest.get_current_modname())

local dripstone_directions =
{
	[-1] = "bottom",
	[1] = "top",
}

local dripstone_stages =
{
	"tip_merge",
	"tip",
	"frustum",
	"middle",
	"base",
}

local function dripstone_hit_func(self, object)
	-- the number 1.125 comes from: (nodes fallen / timer increase) * damage per node fallen
	-- which comes out to be: (1.5 / 8) * 6 = 1.125
	vlf_util.deal_damage(object, math.min(40, self.timer * 1.125), {type = "falling_node"})
end

vlf_mobs.register_arrow("vlf_dripstone:vengeful_dripstone",
{
	visual = "upright_sprite",
	textures = {"pointed_dripstone_tip.png"},
	visual_size = {x = 1, y = 1},
	velocity = 20,
	hit_player = dripstone_hit_func,
	hit_mob = dripstone_hit_func,
	hit_object = dripstone_hit_func,
	hit_node = function(self, pos)
		minetest.add_item(pos, ItemStack("vlf_dripstone:pointed_dripstone"))
	end,
	drop = "vlf_dripstone:pointed_dripstone",
})

local function spawn_dripstone_entity(pos)
	local vengeful_dripstone = minetest.add_entity(pos, "vlf_dripstone:vengeful_dripstone")
	vengeful_dripstone:add_velocity(vector.new(0, -12, 0))
	local ent = vengeful_dripstone:get_luaentity()
	ent.switch = 1
end

minetest.register_node("vlf_dripstone:dripstone_block", {
	description = S("Dripstone block"),
	_doc_items_longdesc = S("Dripstone is type of stone that allows stalagmites and stalagtites to grow on it"),
	_doc_items_hidden = false,
	tiles = {"dripstone_block.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1, stonecuttable = 1, converts_to_moss = 1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 6,
	_vlf_hardness = 1.5,
})


-- returns the name of pointed dripstone node with that stage and direction
local function get_dripstone_node(stage, direction)
	return "vlf_dripstone:dripstone_" .. dripstone_directions[direction] .. "_" .. dripstone_stages[stage]
end

-- extracts the direction from dripstone's name
local function extract_direction(name)
	return string.sub(name, 26, 31) == "bottom" and -1 or 1
end

-- it is assumed pos is at the tip of the dripstone
local function get_dripstone_length(pos, direction)
	local offset_pos = vector.copy(pos)
	local stage
	local length = 0
	repeat
		length = length + 1
		offset_pos = vector.offset(offset_pos, 0, direction, 0)
		stage = minetest.get_item_group(minetest.get_node(offset_pos).name, "dripstone_stage")
	until(stage == 0)
	return length
end

function place_dripstone(pos, length, direction)
	if length == 0 then return end
	-- create the base
	if length >= 3 then
		minetest.swap_node(vector.offset(pos, 0, 0, 0), {name = get_dripstone_node(5, direction)})
	end

	-- create the middle
	if length >= 4 then
		for i = 0, length - 4 do
			minetest.swap_node(vector.offset(pos, 0, (i + 1) * -direction, 0), {name = get_dripstone_node(4, direction)})
		end
	end

	-- create the frustum
	if length >= 2 then
		minetest.swap_node(vector.offset(pos, 0, (length - 2)  * -direction, 0), {name = get_dripstone_node(3, direction)})
	end

	-- if a dripstone column should be created
	-- ".[^l]" is in the pattern to prevent dripstone blocks from being matched
	if string.find(minetest.get_node(vector.offset(pos, 0, length * -direction, 0)).name, "^vlf_dripstone:dripstone_.[^l]") then
		minetest.swap_node(vector.offset(pos, 0, (length - 1) * -direction, 0), {name = "vlf_dripstone:dripstone_" .. dripstone_directions[direction] .. "_tip_merge"})
		minetest.swap_node(vector.offset(pos, 0, length * -direction, 0), {name = "vlf_dripstone:dripstone_" .. dripstone_directions[-direction] .. "_tip_merge"})
	else
		minetest.swap_node(vector.offset(pos, 0, (length - 1) * -direction, 0), {name = get_dripstone_node(2, direction)})
	end
end

local function break_dripstone(pos, direction)
	local offset_pos = vector.copy(pos)
	while true do
		offset_pos = vector.offset(offset_pos, 0, -direction, 0)
		local stage = minetest.get_item_group(minetest.get_node(offset_pos).name, "dripstone_stage")
		if stage == 1 and extract_direction(minetest.get_node(offset_pos).name) == -direction then
			minetest.swap_node(offset_pos, {name = get_dripstone_node(2, -direction)})
			break
		elseif stage == 0 then
			break
		else
			if direction == -1 then
				minetest.add_item(offset_pos, ItemStack("vlf_dripstone:pointed_dripstone"))
			else
				spawn_dripstone_entity(offset_pos)
			end
			minetest.swap_node(offset_pos, {name = "air"})
		end
	end
end

local function update_dripstone(pos, direction)
	-- if a dripstone column should be created
	-- ".[^l]" is in the pattern to prevent dripstone blocks from being matched
	if string.find(minetest.get_node(vector.offset(pos, 0, -direction, 0)).name, "^vlf_dripstone:dripstone_.[^l]") then
		minetest.swap_node(pos, {name = "vlf_dripstone:dripstone_" .. dripstone_directions[direction] .. "_tip_merge"})
		minetest.swap_node(vector.offset(pos, 0, -direction, 0), {name = "vlf_dripstone:dripstone_" .. dripstone_directions[-direction] .. "_tip_merge"})
	end

	local stage
	local previous_stage
	while true do
		pos = vector.offset(pos, 0, direction, 0)
		previous_stage = stage
		stage = minetest.get_item_group(minetest.get_node(pos).name, "dripstone_stage")
		if stage == 4 or stage == 5 then
			break
		elseif stage == 0 then
			if previous_stage == 3 then
				minetest.swap_node(vector.offset(pos, 0, -direction, 0), {name = "vlf_dripstone:dripstone_" .. dripstone_directions[direction] .. "_base"})
			end
			break
		end
		minetest.swap_node(pos, {name = get_dripstone_node(stage + 1, direction)})
	end
end

local function on_dripstone_place(itemstack, player, pointed_thing)
	if pointed_thing.type ~= "node" then return itemstack end
	if minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "solid") == 0 then return itemstack end
	if pointed_thing.above.x ~= pointed_thing.under.x or pointed_thing.above.z ~= pointed_thing.under.z then return itemstack end

	local direction = pointed_thing.under.y - pointed_thing.above.y
	if direction == 0 then
		return
	end

	if not minetest.is_creative_enabled(player:get_player_name()) then
		itemstack:take_item()
	end
	minetest.set_node(pointed_thing.above, {name = get_dripstone_node(2, direction)})
	update_dripstone(pointed_thing.above, direction)
	return itemstack
end

local on_dripstone_destruct = function(pos)
	local direction = extract_direction(minetest.get_node(pos).name)
	break_dripstone(pos, direction)

	local offset_pos = vector.copy(vector.offset(pos, 0, direction, 0))
	if minetest.get_item_group(minetest.get_node(offset_pos).name, "dripstone_stage") ~= 0 then
		minetest.swap_node(offset_pos, {name = get_dripstone_node(2, direction)})

		while true do
			offset_pos = vector.offset(offset_pos, 0, direction, 0)
			local stage = minetest.get_item_group(minetest.get_node(offset_pos).name, "dripstone_stage")
			if stage == 3 then
				minetest.swap_node(offset_pos, {name = get_dripstone_node(2, direction)})
			elseif stage == 4 or stage == 5 then
				minetest.swap_node(offset_pos, {name = get_dripstone_node(3, direction)})
				break
			else
				break
			end
		end
	end
end

minetest.register_craft({
	output = "vlf_dripstone:dripstone_block",
	recipe = {
		{ "vlf_dripstone:pointed_dripstone", "vlf_dripstone:pointed_dripstone"},
		{ "vlf_dripstone:pointed_dripstone", "vlf_dripstone:pointed_dripstone"},
	}
})

minetest.register_craftitem("vlf_dripstone:pointed_dripstone", {
	description = S("Pointed dripstone"),
	_doc_items_longdesc = S("Pointed dripstone is what stalagmites and stalagtites are made of"),
	_doc_items_hidden = false,
	inventory_image = "pointed_dripstone_tip.png",
	on_place = on_dripstone_place,
	on_secondary_use = on_dripstone_place,
})

for i = 1, #dripstone_stages do
	local stage = dripstone_stages[i]
	minetest.register_node("vlf_dripstone:dripstone_top_" .. stage, {
		description = S("Pointed dripstone (@1/@2)", i, #dripstone_stages),
		_doc_items_longdesc = S("Pointed dripstone is what stalagmites and stalagtites are made of"),
		_doc_items_hidden = true,
		drawtype = "plantlike",
		tiles = {"pointed_dripstone_" .. stage .. ".png"},
		drop = "vlf_dripstone:pointed_dripstone",
		groups = {pickaxey=1, not_in_creative_inventory=1, dripstone_stage = i, _vlf_partial = 2,},
		sunlight_propagates = true,
		paramtype = "light",
		is_ground_content = false,
		sounds = vlf_sounds.node_sound_stone_defaults(),
		on_destruct = on_dripstone_destruct,
		_vlf_blast_resistance = 3,
		_vlf_hardness = 1.5,
	})

	minetest.register_node("vlf_dripstone:dripstone_bottom_" .. stage, {
		description = S("Pointed dripstone (@1/@2)", i, #dripstone_stages),
		_doc_items_longdesc = S("Pointed dripstone is what stalagmites and stalagtites are made of"),
		_doc_items_hidden = true,
		drawtype = "plantlike",
		tiles = {"pointed_dripstone_" .. stage .. ".png^[transform6"},
		drop = "vlf_dripstone:pointed_dripstone",
		groups = {pickaxey=1, not_in_creative_inventory=1, fall_damage_add_percent = 100, dripstone_stage = i, _vlf_partial = 2},
		sunlight_propagates = true,
		paramtype = "light",
		is_ground_content = false,
		sounds = vlf_sounds.node_sound_stone_defaults(),
		on_destruct = on_dripstone_destruct,
		_vlf_blast_resistance = 3,
		_vlf_hardness = 1.5,
	})
end

minetest.register_on_dignode(function(pos)
	local offset_pos = vector.copy(vector.offset(pos, 0, -1, 0))
	local nn = minetest.get_node(offset_pos).name
	if minetest.get_item_group(nn, "dripstone_stage") ~= 0 and extract_direction(nn) == 1 then
		if minetest.get_item_group(minetest.get_node(offset_pos).name, "dripstone_stage") ~= 0 then
			break_dripstone(offset_pos, 1)
			spawn_dripstone_entity(offset_pos)
			minetest.swap_node(offset_pos, {name = "air"})
		end
	end
end)

minetest.register_abm({
	label = "Dripstone growth",
	nodenames = {"vlf_dripstone:dripstone_top_tip"},
	interval = 69,
	chance = 88,
	action = function(pos)
		-- checking if can grow
		local stalagtite_length = get_dripstone_length(pos, 1)
		if minetest.get_node(vector.offset(pos, 0, stalagtite_length, 0)).name ~= "vlf_dripstone:dripstone_block"
		or minetest.get_item_group(minetest.get_node(vector.offset(pos, 0, stalagtite_length + 1, 0)).name, "water") == 0 then
			return
		end

		-- randomly chose to either grow the stalagmite or stalagtites
		if math.random(2) == 1 then
			-- stalagmite growth
			local groups
			local node
			local length
			for i = 1, 10 do
				node = minetest.get_node(vector.offset(pos, 0, -i, 0))
				groups = minetest.registered_nodes[node.name].groups
				if (groups["solid"] or 0) > 0 or (groups["dripstone_stage"] or 0) > 0 then
					length = get_dripstone_length(pos, 1)

					if length < 7 then
						minetest.set_node(vector.offset(pos, 0, -i + 1, 0), {name = get_dripstone_node(2, -1)})
						update_dripstone(vector.offset(pos, 0, -i + 1, 0), -1)
					end
					return
				elseif node.name ~= "air" then
					return
				end
			end
		else
			-- stalagtite growth
			if stalagtite_length > 7 then return end

			if minetest.get_node(vector.offset(pos, 0, -1, 0)).name == "air" then
				minetest.set_node(vector.offset(pos, 0, -1, 0), {name = get_dripstone_node(2, 1)})
				update_dripstone(vector.offset(pos, 0, -1, 0), 1)
			end
		end
	end,
})

minetest.register_abm({
	label = "Dripstone filling water cauldrons, conversion from mud to clay",
	nodenames = {"vlf_dripstone:dripstone_top_tip"},
	interval = 69,
	chance = 5.5,
	action = function(pos)
		local stalagtite_length = get_dripstone_length(pos, 1)
		local wpos = vector.offset(pos, 0, stalagtite_length + 1, 0)
		local wnode = core.get_node(wpos)

		if minetest.get_item_group(minetest.get_node(wpos).name, "water") == 0
		or stalagtite_length > 10 then
			-- reusing the ABM for converting mud to clay, since the chances are the same
			if wnode.name == "vlf_mud:mud"
			and vlf_worlds.pos_to_dimension(wpos) ~= "nether" then
				minetest.set_node(wpos, {name = "vlf_core:clay"})
			end
			return
		end

		local water_type = "water"
		if minetest.get_item_group(wnode.name, "river_water") > 0 then
			water_type = "river_water"
		end
		for i = 1, 10 do
			local cpos = vector.offset(pos, 0, -i, 0)
			local node = minetest.get_node(cpos)
			if minetest.get_item_group(node.name, "cauldron") == 1 or minetest.get_item_group(node.name, "cauldron_water") > 0 then
				vlf_cauldrons.add_level(cpos, 1, water_type)
				return
			elseif node.name ~= "air" then
				return
			end
		end
	end,
})

minetest.register_abm({
	label = "Dripstone filling lava cauldrons",
	nodenames = {"vlf_dripstone:dripstone_top_tip"},
	interval = 69,
	chance = 17,
	action = function(pos)
		local stalagtite_length = get_dripstone_length(pos, 1)

		if minetest.get_item_group(minetest.get_node(vector.offset(pos, 0, stalagtite_length + 1, 0)).name, "lava") == 0
		or stalagtite_length > 10 then
			return
		end

		for i = 1, 10 do
			local cpos = vector.offset(pos, 0, -i, 0)
			local node = minetest.get_node(cpos)
			if node.name == "vlf_cauldrons:cauldron" then
				vlf_cauldrons.add_level(cpos, 3, "lava")
			elseif node.name ~= "air" then
				return
			end
		end
	end,
})

vlf_structures.register_structure("dripstone_stalagmite", {
	place_on = {"vlf_dripstone:dripstone_block"},
	spawn_by = "air",
	check_offset = 1,
	num_spawn_by = 5,
	biomes = {"DripstoneCave"},
	fill_ratio = 0.8,
	y_min = vlf_vars.mg_overworld_min,
	y_max = 0,
	place_offset_y = 1,
	terrain_feature = true,
	place_func = function(pos)
		local max_length = 0
		local offset_pos = vector.copy(pos)
		while true do
			offset_pos = vector.offset(offset_pos, 0, 1, 0)
			if minetest.get_node(offset_pos).name ~= "air" then
				break
			end
			max_length = max_length + 1
		end
		place_dripstone(pos, math.min(math.random(2, 5), max_length), -1)
		return true
	end,
})

vlf_structures.register_structure("dripstone_stalagtite", {
	place_on = {"vlf_dripstone:dripstone_block"},
	spawn_by = "air",
	check_offset = 1,
	num_spawn_by = 5,
	biomes = {"DripstoneCave"},
	fill_ratio = 0.8,
	y_min = vlf_vars.mg_overworld_min + 1,
	y_max = 0,
	flags = "all_ceilings",
	terrain_feature = true,
	place_func = function(pos)
		pos = vector.offset(pos, 0, -2, 0)
		local max_length = 0
		local offset_pos = vector.copy(pos)
		while true do
			offset_pos = vector.offset(offset_pos, 0, -1, 0)
			if minetest.get_node(offset_pos).name ~= "air" then
				break
			end
			max_length = max_length + 1
		end

		place_dripstone(pos, math.min(math.random(2, 5), max_length), 1)
		return true
	end,
})
