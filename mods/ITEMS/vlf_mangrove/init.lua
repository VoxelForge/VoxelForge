local S = minetest.get_translator("vlf_mangrove")
local schempath = minetest.get_modpath("vlf_schematics")

vlf_trees.register_wood("mangrove",{
	readable_name=S("Mangrove"),
	sign_color="#8E3731",
	sapling=false,
	tree_schems = {
		{file = schempath.."/schems/vlf_mangrove_tree_1.mts", offset = vector.new(1,0,1)},
		{file = schempath.."/schems/vlf_mangrove_tree_2.mts",},
		{file = schempath.."/schems/vlf_mangrove_tree_3.mts",},
		{file = schempath.."/schems/vlf_mangrove_tree_4.mts",},
		{file = schempath.."/schems/vlf_mangrove_tree_5.mts", offset = vector.new(1,0,1)},
		{file = schempath.."/schems/vlf_mangrove_bee_nest.mts", offset = vector.new(0,0,1)},
	},
	tree = { tiles = {"vlf_mangrove_log_top.png", "vlf_mangrove_log_top.png","vlf_mangrove_log.png" }},
	bark = { tiles = {"vlf_mangrove_log.png"}},
	leaves = {
		tiles = { "vlf_mangrove_leaves.png" },
		color = "#6a7039",
		_on_bone_meal = function(itemstack,placer,pointed_thing,pos,node)
			local upos = vector.offset(pos, 0,-1,0)
			return minetest.get_node(upos).name == "air" and minetest.set_node(upos, {name="vlf_mangrove:hanging_propagule_1"})
		end,
	},
	wood = { tiles = {"vlf_mangrove_planks.png"}},
	stripped = {
		tiles = {"vlf_stripped_mangrove_log_top.png", "vlf_stripped_mangrove_log_top.png","vlf_stripped_mangrove_log_side.png"}
	},
	stripped_bark = {
		tiles = {"vlf_stripped_mangrove_log_side.png"}
	},
	fence = {
		tiles = { "vlf_mangrove_fence.png" },
	},
	fence_gate = {
		tiles = { "vlf_mangrove_fence_gate.png" },
	},
	door = {
		inventory_image = "vlf_mangrove_doors.png",
		tiles_bottom = {"vlf_mangrove_door_bottom.png", "vlf_mangrove_door_bottom.png"},
		tiles_top = {"vlf_mangrove_door_top.png", "vlf_mangrove_door_top.png"}
	},
	trapdoor = {
		tile_front = "vlf_mangrove_trapdoor.png",
		tile_side = "vlf_mangrove_trapdoor_side.png",
		wield_image = "vlf_mangrove_trapdoor.png",
	},
})

local propagule_allowed_nodes = {
	"vlf_core:dirt",
	"vlf_core:coarse_dirt",
	"vlf_core:dirt_with_grass",
	"vlf_core:podzol",
	"vlf_core:mycelium",
	"vlf_lush_caves:rooted_dirt",
	"vlf_lush_caves:moss",
	"vlf_farming:soil",
	"vlf_farming:soil_wet",
	"vlf_core:clay",
	"vlf_mud:mud",
}
local propagule_water_nodes = {"vlf_mud:mud","vlf_core:dirt","vlf_core:coarse_dirt","vlf_core:clay"}
 --"vlf_lush_caves:moss","vlf_lush_caves:rooted_dirt

local propagule_rooted_nodes = {}
for _,root in pairs(propagule_water_nodes) do
	local r = root:split(":")[2]
	local def = minetest.registered_nodes[root]
	local tx = def.tiles
	local n = "vlf_mangrove:propagule_"..r
	table.insert(propagule_rooted_nodes,n)
	minetest.register_node(n, {
		drawtype = "plantlike_rooted",
		paramtype = "light",
		place_param2 = 1,
		tiles = tx,
		special_tiles = { { name = "vlf_mangrove_propagule_item.png" } },
		inventory_image = "vlf_mangrove_propagule_item.png",
		wield_image = "vlf_mangrove_propagule.png",
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
				{ -0.5, 0.5, -0.5, 0.5, 1.0, 0.5 },
			}
		},
		groups = {
			plant = 1, sapling = 1, non_mycelium_plant = 1, attached_node = 1,not_in_creative_inventory=1,
			deco_block = 1, dig_immediate = 3, dig_by_piston = 1,
			destroy_by_lava_flow = 1, compostability = 30
		},
		sounds = vlf_sounds.node_sound_leaves_defaults(),
		drop = "vlf_mangrove:propagule",
		node_placement_prediction = "",
		node_dig_prediction = "",
		after_dig_node = function(pos)
			minetest.set_node(pos, {name=root})
		end,
		_vlf_hardness = 0,
		_vlf_blast_resistance = 0,
		_vlf_silk_touch_drop = true,
	})

end

minetest.register_node("vlf_mangrove:mangrove_roots", {
	description = S("Mangrove Roots"),
	_doc_items_longdesc = S("Mangrove roots are decorative blocks that form as part of mangrove trees."),
	_doc_items_hidden = false,
	waving = 0,
	place_param2 = 1, -- Prevent leafdecay for placed nodes
	tiles = {
		"vlf_mangrove_roots_top.png",
		"vlf_mangrove_roots_side.png",
		"vlf_mangrove_roots_side.png",
	},
	paramtype = "light",
	drawtype = "allfaces_optional",
	groups = {
		handy = 1, hoey = 1, shearsy = 1, axey = 1, swordy = 1, dig_by_piston = 0,
		flammable = 10, fire_encouragement = 30, fire_flammability = 60,
		deco_block = 1, compostability = 30
	},
	drop = "vlf_mangrove:mangrove_roots",
	_vlf_shears_drop = true,
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	_vlf_blast_resistance = 0.7,
	_vlf_hardness = 0.7,
	_vlf_silk_touch_drop = true,
	_vlf_fortune_drop = { "vlf_mangrove:mangrove_roots 1", "vlf_mangrove:mangrove_roots 2", "vlf_mangrove:mangrove_roots 3", "vlf_mangrove:mangrove_roots 4" },
	_on_bucket_place = function(itemstack,placer,pointed_thing)
		local dim = vlf_worlds.pos_to_dimension(pointed_thing.under)
		if dim == "nether" then return itemstack end
		local n = itemstack:get_name():gsub("vlf_buckets:bucket_","")
		n = "vlf_mangrove:"..n.."_logged_roots"
		if minetest.registered_nodes[n] then
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack:take_item()
				local inv = placer:get_inventory()
				inv:add_item("main","vlf_buckets:bucket_empty")
			end
			minetest.swap_node(pointed_thing.under,{name=n})
		end
		return itemstack
	end
})

minetest.register_node("vlf_mangrove:propagule", {
	description = S("Mangrove Propagule"),
	_tt_help = S("Needs soil and light to grow"),
	_doc_items_longdesc = S("When placed on soil (such as dirt) and exposed to light, an propagule will grow into an mangrove after some time."),
	_doc_items_hidden = false,
	drawtype = "plantlike",
	waving = 1,
	tiles = {"vlf_mangrove_propagule_item.png"},
	inventory_image = "vlf_mangrove_propagule_item.png",
	wield_image = "vlf_mangrove_propagule_item.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-5/16, -0.5, -5/16, 5/16, 0.5, 5/16}
	},
	groups = {
		plant = 1, sapling = 1, non_mycelium_plant = 1, attached_node = 1,
		deco_block = 1, dig_immediate = 3, dig_by_water = 0, dig_by_piston = 1,
		destroy_by_lava_flow = 1, compostability = 30
	},
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("stage", 0)
	end,
	node_placement_prediction = "",
	_vlf_blast_resistance = 0,
	_vlf_hardness = 0,
	_on_bone_meal = function(itemstack,placer,pointed_thing,pos,node)
		return vlf_trees.grow_tree(pos, node)
	end,
	on_place = vlf_util.generate_on_place_plant_function(function(place_pos, place_node,stack)
		local under = vector.offset(place_pos,0,-1,0)
		local snn = minetest.get_node_or_nil(under).name
		if not snn then return false end
		if table.indexof(propagule_allowed_nodes,snn) ~= -1 then
			local n = minetest.get_node(place_pos)
			if minetest.get_item_group(n.name,"water") > 0 and table.indexof(propagule_water_nodes,snn) ~= -1 then
					minetest.set_node(under,{name="vlf_mangrove:propagule_"..snn:split(":")[2]})
					stack:take_item()
					return stack
			end
			return true
		end
	end)
})

minetest.register_node("vlf_mangrove:hanging_propagule_1", {
	description = S("Hanging Propagule"),
	_tt_help = S("Grows on Mangrove leaves"),
	_doc_items_longdesc = "",
	_doc_items_usagehelp = "",
	groups = {
			plant = 1, not_in_creative_inventory=1, non_mycelium_plant = 1,
			deco_block = 1, dig_immediate = 3, dig_by_water = 0, dig_by_piston = 1,
			destroy_by_lava_flow = 1, compostability = 30
		},
	paramtype = "light",
	paramtype2 = "",
	on_rotate = false,
	walkable = false,
	drop = "vlf_mangrove:propagule",
	use_texture_alpha = "clip",
	drawtype = 'mesh',
	mesh = 'propagule_hanging.obj',
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- Base
		},
	},
	tiles = {"vlf_mangrove_propagule_hanging.png"},
	inventory_image = "vlf_mangrove_propagule.png",
	wield_image = "vlf_mangrove_propagule.png",
})



vlf_flowerpots.register_potted_flower("vlf_mangrove:propagule", {
	name = "propagule",
	desc = S("Mangrove Propagule"),
	image = "vlf_mangrove_propagule.png",
})

local wlroots = {
	description = S("water logged mangrove roots"),
	_doc_items_entry_name = S("water logged mangrove roots"),
	_doc_items_longdesc =
		S("Mangrove roots are decorative blocks that form as part of mangrove trees.").."\n\n"..
		S("Mangrove roots, despite being a full block, can be waterlogged and do not flow water out").."\n\n"..
		S("These cannot be crafted yet only occure when get in contact of water."),
	_doc_items_hidden = false,
	tiles = {
		{name="default_water_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0}}
	},
	special_tiles = {
		-- New-style water source material (mostly unused)
		{
			name="default_water_source_animated.png",
			animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0},
			backface_culling = false,
		}
	},
	overlay_tiles = {
		"vlf_mangrove_roots_top.png",
		"vlf_mangrove_roots_side.png",
		"vlf_mangrove_roots_side.png",
	},
	sounds = vlf_sounds.node_sound_water_defaults(),
	drawtype = "allfaces_optional",
	use_texture_alpha = "blend",
	is_ground_content = false,
	paramtype = "light",
	liquids_pointable = true,
	drop = "vlf_mangrove:mangrove_roots",
	groups = {
		handy = 1, hoey = 1, water=4, liquid=3, puts_out_fire=1, dig_by_piston = 1, deco_block = 1,  not_in_creative_inventory=1 },
	_vlf_blast_resistance = 100,
	_vlf_hardness = -1, -- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	on_construct = function(pos)
		local dim = vlf_worlds.pos_to_dimension(pos)
		if dim == "nether" then
			minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			minetest.set_node(pos, {name="vlf_mangrove:mangrove_roots"})
		end
	end,
	after_dig_node = function(pos)
		local node = minetest.get_node(pos)
		local dim = vlf_worlds.pos_to_dimension(pos)
		if minetest.get_item_group(node.name, "water") == 0 and dim ~= "nether" then
			minetest.set_node(pos, {name="vlf_core:water_source"})
		else
			minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
	_on_bucket_place_empty = function(itemstack,placer,pointed_thing)
		local n = minetest.get_node(pointed_thing.under).name:gsub("vlf_mangrove:","")
		n = "vlf_buckets:bucket_"..n:gsub("_logged_roots","")
		if minetest.registered_items[n] then
			minetest.swap_node(pointed_thing.under,{name="vlf_mangrove:mangrove_roots"})
			itemstack:take_item()
			local inv = placer:get_inventory()
			inv:add_item("main",ItemStack(n))
		end
		return itemstack
	end
}
local rwlroots = table.copy(wlroots)

rwlroots.tiles = {
	{name="default_river_water_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0}}
}
rwlroots.after_dig_node = function(pos)
	local node = minetest.get_node(pos)
	local dim = vlf_worlds.pos_to_dimension(pos)
	if minetest.get_item_group(node.name, "water") == 0 and dim ~= "nether" then
		minetest.set_node(pos, {name="vlfx_core:river_water_source"})
	else
		minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
	end
end

minetest.register_node("vlf_mangrove:water_logged_roots", wlroots)
minetest.register_node("vlf_mangrove:river_water_logged_roots",rwlroots)

minetest.register_node("vlf_mangrove:mangrove_mud_roots", {
	description = S("Muddy Mangrove Roots"),
	_tt_help = S("crafted with Mud and Mangrove roots"),
	_doc_items_longdesc = S("Muddy Mangrove Roots is a block from mangrove swamp.It drowns player a bit inside it."),
	tiles = {
		"vlf_mud.png^vlf_mangrove_roots_top.png",
		"vlf_mud.png^vlf_mangrove_roots_side.png",
		"vlf_mud.png^vlf_mangrove_roots_side.png",
	},
	groups = {handy=1, shovely=1, axey=1, soil_fungus=1, building_block=1},
	sounds = vlf_sounds.node_sound_sand_defaults(),
	_vlf_blast_resistance = 0.7,
	_vlf_hardness = 0.7,
})

minetest.register_craft({
	output = "vlf_mangrove:mangrove_mud_roots",
	recipe = {
		{"vlf_mangrove:mangrove_roots", "vlf_mud:mud",},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_mangrove:mangrove_roots",
	burntime = 15,
})

local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
}

minetest.register_abm({
	label = "Waterlog mangrove roots",
	nodenames = {"vlf_mangrove:mangrove_roots"},
	neighbors = {"group:water"},
	interval = 5,
	chance = 5,
	action = function(pos,value)
		for _,v in pairs(adjacents) do
			local n = minetest.get_node(vector.add(pos,v)).name
			if minetest.get_item_group(n,"water") > 0 then
				if n:find("river") then
					minetest.swap_node(pos,{name="vlf_mangrove:river_water_logged_roots"})
					return
				else
					minetest.swap_node(pos,{name="vlf_mangrove:water_logged_roots"})
					return
				end
			end
		end
	end
})
