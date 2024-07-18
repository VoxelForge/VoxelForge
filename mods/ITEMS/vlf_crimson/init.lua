local S = minetest.get_translator(modname)
local schempath = minetest.get_modpath("vlf_schematics")
-- Warped and Crimson fungus
-- by debiankaios
-- adapted for mcl by cora

local nether_plants = {
	["vlf_crimson:crimson_nylium"] = {
		"vlf_crimson:crimson_roots",
		"vlf_crimson:crimson_fungus",
		"vlf_crimson:warped_fungus",
	},
	["vlf_crimson:warped_nylium"] = {
		"vlf_crimson:warped_roots",
		"vlf_crimson:warped_fungus",
		"vlf_crimson:twisting_vines",
		"vlf_crimson:nether_sprouts",
	},
}

local place_fungus = vlf_util.generate_on_place_plant_function(function(pos, node)
	return minetest.get_item_group(minetest.get_node(vector.offset(pos,0,-1,0)).name, "soil_fungus") > 0
end)

local function spread_nether_plants(pos,node)
	local n = node.name
	local nn = minetest.find_nodes_in_area_under_air(vector.offset(pos,-5,-3,-5),vector.offset(pos,5,3,5),{n})
	table.shuffle(nn)
	nn[1] = pos
	for i=1,math.random(1,math.min(#nn,12)) do
		local p = vector.offset(nn[i],0,1,0)
		if minetest.get_node(p).name == "air" then
			minetest.set_node(p,{name=nether_plants[n][math.random(#nether_plants[n])]})
		end
	end
end

local function on_bone_meal(itemstack,user,pt,pos,node)
	if pt.type ~= "node" then return end
	if node.name == "vlf_crimson:warped_nylium" or node.name == "vlf_crimson:crimson_nylium" then
		spread_nether_plants(pt.under,node)
	end
end

local function check_for_bedrock(pos)
	local br = minetest.find_nodes_in_area(pos, vector.offset(pos, 0, 12, 0), {"vlf_core:bedrock"})
	return br and #br > 0
end

local function generate_fungus_tree(pos, typ)
	return minetest.place_schematic(pos,schempath.."/schems/"..typ.."_fungus_"..tostring(math.random(1,3))..".mts","random",nil,false,"place_center_x,place_center_z")
end

local max_vines_age = 25
local grow_vines_direction = {[1] = 1, [2] = -1}

function set_vines_age(pos, node)
	local dir = grow_vines_direction[minetest.get_item_group(node.name, "vinelike_node")]
	local vpos, i = vlf_util.traverse_tower(pos, -dir)
	for i = 1, i do
		minetest.swap_node(vpos, { name = node.name, param2 = i })
		vpos = vector.offset(vpos, 0, dir, 0)
	end
	return i
end

function get_vines_age(pos)
	local node = minetest.get_node(pos)
	return node.param2 > 0 and node.param2 or set_vines_age(pos, node)
end

function grow_vines(pos, amount, vine, dir, max_age)
	dir = dir or grow_vines_direction[minetest.get_item_group(vine, "vinelike_node")] or 1
	local tip, i = vlf_util.traverse_tower(pos, dir)
	local age = get_vines_age(pos) + i -1
	amount = math.min(amount, max_age and max_age - age or amount)
	for i=1, amount do
		local p = vector.offset(tip,0,dir*i,0)
		if minetest.get_node(p).name == "air" then
			minetest.set_node(p,{name=vine, param2=age +i})
		else
			return i-1
		end
	end
	return amount
end

local nether_wood_groups = { handy = 1, axey = 1, material_wood = 1, }

vlf_trees.register_wood("crimson",{
	readable_name=S("Crimson"),
	sign_color="#810000",
	boat=false,
	chest_boat=false,
	sapling=false,
	leaves=false,
	tree = {
		tiles = {"crimson_hyphae.png", "crimson_hyphae.png","crimson_hyphae_side.png" },
		groups = table.merge(nether_wood_groups,{tree = 1}),
	},
	bark = {
		tiles = {"crimson_hyphae_side.png"},
		groups = table.merge(nether_wood_groups,{tree = 1, bark = 1}),
	},
	wood = {
		tiles = {"crimson_hyphae_wood.png"},
		groups = table.merge(nether_wood_groups,{wood = 1}),
	},
	stripped = {
		tiles = {"stripped_crimson_stem_top.png", "stripped_crimson_stem_top.png","stripped_crimson_stem_side.png"},
		groups = table.merge(nether_wood_groups,{tree = 1}),
	},
	stripped_bark = {
		tiles = {"stripped_crimson_stem_side.png"},
		groups = table.merge(nether_wood_groups,{tree = 1, bark = 1}),
	},
	fence = {
		tiles = { "vlf_crimson_crimson_fence.png" },
	},
	fence_gate = {
		tiles = { "vlf_crimson_crimson_fence.png" },
	},
	door = {
		inventory_image = "vlf_crimson_crimson_door.png",
		tiles_bottom = {"vlf_crimson_crimson_door_bottom.png","vlf_doors_door_crimson_side_upper.png"},
		tiles_top = {"vlf_crimson_crimson_door_top.png","vlf_doors_door_crimson_side_upper.png"},
	},
	trapdoor = {
		tile_front = "vlf_crimson_crimson_trapdoor.png",
		tile_side = "vlf_crimson_crimson_trapdoor_side.png",
		wield_image = "vlf_crimson_crimson_trapdoor.png",
	},
})

vlf_trees.register_wood("warped",{
	readable_name=S("Warped"),
	sign_color="#0E4C4C",
	boat=false,
	chest_boat=false,
	sapling=false,
	leaves=false,
	tree = {
		tiles = {"warped_hyphae.png", "warped_hyphae.png","warped_hyphae_side.png" },
		groups = table.merge(nether_wood_groups,{tree = 1}),
	},
	bark = {
		tiles = {"warped_hyphae_side.png"},
		groups = table.merge(nether_wood_groups,{tree = 1, bark = 1}),
	},
	wood = {
		tiles = {"warped_hyphae_wood.png"},
		groups = table.merge(nether_wood_groups,{wood = 1}),
	},
	stripped = {
		tiles = {"stripped_warped_stem_top.png", "stripped_warped_stem_top.png","stripped_warped_stem_side.png"},
		groups = table.merge(nether_wood_groups,{tree = 1}),
	},
	stripped_bark = {
		tiles = {"stripped_warped_stem_side.png"},
		groups = table.merge(nether_wood_groups,{tree = 1, bark = 1}),
	},
	fence = {
		tiles = { "vlf_crimson_warped_fence.png" },
	},
	fence_gate = {
		tiles = { "vlf_crimson_warped_fence.png" },
	},
	door = {
		inventory_image = "vlf_crimson_warped_door.png",
		tiles_bottom = {"vlf_crimson_warped_door_bottom.png","vlf_doors_door_warped_side_upper.png"},
		tiles_top = {"vlf_crimson_warped_door_top.png","vlf_doors_door_warped_side_upper.png"},
	},
	trapdoor = {
		tile_front = "vlf_crimson_warped_trapdoor.png",
		tile_side = "vlf_crimson_warped_trapdoor_side.png",
		wield_image = "vlf_crimson_warped_trapdoor.png",
	},
})

minetest.register_node("vlf_crimson:warped_fungus", {
	description = S("Warped Fungus"),
	_tt_help = S("Warped fungus is a mushroom found in the nether's warped forest."),
	_doc_items_longdesc = S("Warped fungus is a mushroom found in the nether's warped forest."),
	drawtype = "plantlike",
	tiles = { "farming_warped_fungus.png" },
	inventory_image = "farming_warped_fungus.png",
	wield_image = "farming_warped_fungus.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3,mushroom=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,enderman_takable=1,deco_block=1,compostability=65},
	light_source = 1,
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, 7/16, 3/16 },
	},
	node_placement_prediction = "",
	on_place = place_fungus,
	_on_bone_meal = function(itemstack,placer,pointed_thing,pos,node)
		if minetest.get_node_or_nil(vector.offset(pos,0,-1,0)).name == "vlf_crimson:warped_nylium" then
			if math.random() > 0.40 then return end --fungus has a 40% chance to grow when bone mealing
			if check_for_bedrock(pos) then return false end
			minetest.remove_node(pos)
			return generate_fungus_tree(pos, "warped")
		end
	end,
	_vlf_blast_resistance = 0,
})

vlf_flowerpots.register_potted_flower("vlf_crimson:warped_fungus", {
	name = "warped_fungus",
	desc = S("Warped Fungus"),
	image = "farming_warped_fungus.png",
})

local call_on_place = function(itemstack, placer, pointed_thing)
	local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	local dir = vector.direction(pointed_thing.under, pointed_thing.above).y
	local node = minetest.get_node(pointed_thing.under)
	local idef = itemstack:get_definition()

	local grow_dir = grow_vines_direction[minetest.get_item_group(idef.name, "vinelike_node")]
	local pos = vector.offset(pointed_thing.under, 0, grow_dir, 0)
	if vlf_util.check_position_protection(pos, placer) then return itemstack end

	if node.name == idef.name then
		if grow_vines(pointed_thing.under, 1, node.name) == 0 then return end
	elseif grow_dir == dir and minetest.get_item_group(node.name, "solid") ~= 0 then
		minetest.item_place_node(itemstack, placer, pointed_thing, 1)
	else
		return itemstack
	end

	if idef.sounds and idef.sounds.place then
		minetest.sound_play(idef.sounds.place, {pos=pointed_thing.above, gain=1}, true)
	end
	if not minetest.is_creative_enabled(placer:get_player_name()) then
		itemstack:take_item(1)
	end
	return itemstack
end

local function register_vines(name, def, extra_groups)
	local groups = table.merge({
		dig_immediate=3, shearsy=1, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1, deco_block=1, compostability=50
	}, extra_groups or {})
	minetest.register_node(name, table.merge({
		drawtype = "plantlike",
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		climbable = true,
		buildable_to = true,
		groups = groups,
		sounds = vlf_sounds.node_sound_leaves_defaults(),
		node_placement_prediction = "",
		on_place = call_on_place,
		drop = {
			max_items = 1,
			items = {
				{items = {name}, rarity = 3},
			},
		},
		_vlf_shears_drop = true,
		_vlf_silk_touch_drop = true,
		_vlf_fortune_drop = {
			items = {
				{items = {name}, rarity = 3},
				{items = {name}, rarity = 1.8181818181818181},
			},
			name,
			name,
		},
		_vlf_blast_resistance = 0.2,
		_vlf_hardness = 0.2,
		_on_bone_meal = function(itemstack,placer,pointed_thing,pos,node)
			grow_vines(pos, math.random(1, 3), name, nil, max_vines_age)
		end
	}, def or {}))
end

register_vines("vlf_crimson:twisting_vines", {
	description = S("Twisting Vines"),
	tiles = { "twisting_vines_plant.png" },
	inventory_image = "twisting_vines.png",
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, 0.5, 3/16 },
	},
}, {vinelike_node=1})

register_vines("vlf_crimson:weeping_vines", {
	description = S("Weeping Vines"),
	tiles = { "vlf_crimson_weeping_vines.png" },
	inventory_image = "vlf_crimson_weeping_vines.png",

	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, 0.5, 3/16 },
	},
}, {vinelike_node=2})

minetest.register_node("vlf_crimson:nether_sprouts", {
	description = S("Nether Sprouts"),
	drawtype = "plantlike",
	tiles = { "nether_sprouts.png" },
	inventory_image = "nether_sprouts.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {dig_immediate=3, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1, deco_block=1, shearsy=1, compostability=50},
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -4/16, -0.5, -4/16, 4/16, 0, 4/16 },
	},
	node_placement_prediction = "",
	drop = "",
	_vlf_shears_drop = true,
	_vlf_silk_touch_drop = false,
	_vlf_blast_resistance = 0,
})

minetest.register_node("vlf_crimson:warped_roots", {
	description = S("Warped Roots"),
	drawtype = "plantlike",
	tiles = { "warped_roots.png" },
	inventory_image = "warped_roots.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {dig_immediate=3, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1, deco_block=1, shearsy = 1, compostability=65},
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -0.5, -6/16, 6/16, -4/16, 6/16 },
	},
	node_placement_prediction = "",
	_vlf_silk_touch_drop = false,
	_vlf_blast_resistance = 0,
})

vlf_flowerpots.register_potted_flower("vlf_crimson:warped_roots", {
	name = "warped_roots",
	desc = S("Warped Roots"),
	image = "warped_roots.png",
})


minetest.register_node("vlf_crimson:warped_wart_block", {
	description = S("Warped Wart Block"),
	tiles = {"warped_wart_block.png"},
	groups = {handy = 1, hoey = 7, swordy = 1, deco_block = 1, compostability = 85},
	_vlf_hardness = 1,
	sounds = vlf_sounds.node_sound_leaves_defaults({
			footstep={name="default_dirt_footstep", gain=0.7},
			dug={name="default_dirt_footstep", gain=1.5},
	}),
})

minetest.register_node("vlf_crimson:shroomlight", {
	description = S("Shroomlight"),
	tiles = {"shroomlight.png"},
	groups = {handy = 1, hoey = 7, swordy = 1, deco_block = 1, compostability = 65},
	light_source = minetest.LIGHT_MAX,
	_vlf_hardness = 1,
	sounds = vlf_sounds.node_sound_leaves_defaults({
			footstep={name="default_dirt_footstep", gain=0.7},
			dug={name="default_dirt_footstep", gain=1.5},
	}),
})

minetest.register_node("vlf_crimson:warped_nylium", {
	description = S("Warped Nylium"),
	tiles = {
		"warped_nylium.png",
		"vlf_nether_netherrack.png",
		"vlf_nether_netherrack.png^warped_nylium_side.png",
		"vlf_nether_netherrack.png^warped_nylium_side.png",
		"vlf_nether_netherrack.png^warped_nylium_side.png",
		"vlf_nether_netherrack.png^warped_nylium_side.png",
	},
	drop = "vlf_nether:netherrack",
	groups = {pickaxey=1, soil_fungus=1, building_block=1, material_stone=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_hardness = 0.4,
	_vlf_blast_resistance = 0.4,
	_vlf_silk_touch_drop = true,
	_on_bone_meal = on_bone_meal,
})

minetest.register_node("vlf_crimson:crimson_fungus", {
	description = S("Crimson Fungus"),
	_tt_help = S("Crimson fungus is a mushroom found in the nether's crimson forest."),
	_doc_items_longdesc = S("Crimson fungus is a mushroom found in the nether's crimson forest."),
	drawtype = "plantlike",
	tiles = { "farming_crimson_fungus.png" },
	inventory_image = "farming_crimson_fungus.png",
	wield_image = "farming_crimson_fungus.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3 ,mushroom=1 ,attached_node=1 ,dig_by_water=1 ,destroy_by_lava_flow=1 ,dig_by_piston=1 ,enderman_takable=1, deco_block=1, compostability=65},
	light_source = 1,
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, 7/16, 3/16 },
	},
	node_placement_prediction = "",
	on_place = place_fungus,
	_on_bone_meal = function(itemstack,placer,pointed_thing,pos,node)
		if minetest.get_node(vector.offset(pos,0,-1,0)).name == "vlf_crimson:crimson_nylium" then
			if math.random() > 0.40 then return end --fungus has a 40% chance to grow when bone mealing
			if check_for_bedrock(pos) then return false end
			minetest.remove_node(pos)
			return generate_fungus_tree(pos, "crimson")
		end
	end,
	_vlf_blast_resistance = 0,
})

vlf_flowerpots.register_potted_flower("vlf_crimson:crimson_fungus", {
	name = "crimson_fungus",
	desc = S("Crimson Fungus"),
	image = "farming_crimson_fungus.png",
})

minetest.register_node("vlf_crimson:crimson_roots", {
	description = S("Crimson Roots"),
	drawtype = "plantlike",
	tiles = { "crimson_roots.png" },
	inventory_image = "crimson_roots.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {dig_immediate=3 ,dig_by_water=1 ,destroy_by_lava_flow=1 ,dig_by_piston=1, deco_block=1, shearsy=1, compostability=65},
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -0.5, -6/16, 6/16, -4/16, 6/16 },
	},
	node_placement_prediction = "",
	_vlf_silk_touch_drop = false,
	_vlf_blast_resistance = 0,
})

vlf_flowerpots.register_potted_flower("vlf_crimson:crimson_roots", {
	name = "crimson_roots",
	desc = S("Crimson Roots"),
	image = "crimson_roots.png",
})

minetest.register_node("vlf_crimson:crimson_nylium", {
	description = S("Crimson Nylium"),
	tiles = {
		"crimson_nylium.png",
		"vlf_nether_netherrack.png",
		"vlf_nether_netherrack.png^crimson_nylium_side.png",
		"vlf_nether_netherrack.png^crimson_nylium_side.png",
		"vlf_nether_netherrack.png^crimson_nylium_side.png",
		"vlf_nether_netherrack.png^crimson_nylium_side.png",
	},
	groups = {pickaxey=1, soil_fungus=1, building_block=1, material_stone=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	drop = "vlf_nether:netherrack",
	_vlf_hardness = 0.4,
	_vlf_blast_resistance = 0.4,
	_vlf_silk_touch_drop = true,
	_on_bone_meal = on_bone_meal,
})

minetest.register_abm({
	label = "Turn Crimson Nylium and Warped Nylium below solid block into Netherrack",
	nodenames = {"vlf_crimson:crimson_nylium","vlf_crimson:warped_nylium"},
	neighbors = {"group:solid"},
	interval = 8,
	chance = 50,
	action = function(pos, node)
		if minetest.get_item_group(minetest.get_node(vector.offset(pos, 0, 1, 0)).name, "solid") > 0 then
			node.name = "vlf_nether:netherrack"
			minetest.set_node(pos, node)
		end
	end
})

minetest.register_abm({
	label = "Weeping Vines and Twisting Vines growth",
	nodenames = { "vlf_crimson:weeping_vines", "vlf_crimson:twisting_vines" },
	interval = 47 * 2.5,
	chance = 4,
	action = function(pos, node)
		if grow_vines_direction[minetest.get_item_group(node.name, "vinelike_node")] and node.param2 < max_vines_age then
			grow_vines(pos, 1, node.name, nil, max_vines_age)
		end
	end
})

-- Door, Trapdoor, and Fence/Gate Crafting
local crimson_wood = "vlf_crimson:crimson_hyphae_wood"
local warped_wood = "vlf_crimson:warped_hyphae_wood"

minetest.register_craft({
	output = "vlf_crimson:crimson_door 3",
	recipe = {
		{crimson_wood, crimson_wood},
		{crimson_wood, crimson_wood},
		{crimson_wood, crimson_wood}
	}
})

minetest.register_craft({
	output = "vlf_crimson:warped_door 3",
	recipe = {
		{warped_wood, warped_wood},
		{warped_wood, warped_wood},
		{warped_wood, warped_wood}
	}
})

minetest.register_craft({
	output = "vlf_crimson:crimson_trapdoor 2",
	recipe = {
		{crimson_wood, crimson_wood, crimson_wood},
		{crimson_wood, crimson_wood, crimson_wood},
	}
})

minetest.register_craft({
	output = "vlf_crimson:warped_trapdoor 2",
	recipe = {
		{warped_wood, warped_wood, warped_wood},
		{warped_wood, warped_wood, warped_wood},
	}
})

minetest.register_craft({
	output = "vlf_crimson:crimson_fence 3",
	recipe = {
		{crimson_wood, "vlf_core:stick", crimson_wood},
		{crimson_wood, "vlf_core:stick", crimson_wood},
	}
})

minetest.register_craft({
	output = "vlf_crimson:warped_fence 3",
	recipe = {
		{warped_wood, "vlf_core:stick", warped_wood},
		{warped_wood, "vlf_core:stick", warped_wood},
	}
})

minetest.register_craft({
	output = "vlf_crimson:crimson_fence_gate",
	recipe = {
		{"vlf_core:stick", crimson_wood, "vlf_core:stick"},
		{"vlf_core:stick", crimson_wood, "vlf_core:stick"},
	}
})

minetest.register_craft({
	output = "vlf_crimson:warped_fence_gate",
	recipe = {
		{"vlf_core:stick", warped_wood, "vlf_core:stick"},
		{"vlf_core:stick", warped_wood, "vlf_core:stick"},
	}
})
