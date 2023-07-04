local S = minetest.get_translator("mcl_trees")
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local propagule_allowed_nodes = {
	"mcl_core:dirt",
	"mcl_core:coarse_dirt",
	"mcl_core:dirt_with_grass",
	"mcl_core:podzol",
	"mcl_core:mycelium",
	"mcl_core:dirt_rooted",
	--"mcl_moss:moss",
	"mcl_farming:soil",
	"mcl_farming:soil_wet",
	"mcl_core:clay",
	"mcl_mud:mud",
}
local propagule_water_nodes = {"mcl_mud:mud","mcl_core:dirt","mcl_core:coarse_dirt","mcl_stone:clay"}

local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
}

minetest.register_node("mcl_trees:mangrove_roots", {
	description = S("Mangrove_Roots"),
	_doc_items_longdesc = S("Mangrove roots are decorative blocks that form as part of mangrove trees."),
	_doc_items_hidden = false,
	waving = 0,
	place_param2 = 1, -- Prevent leafdecay for placed nodes
	tiles = {
		"mcl_mangrove_roots_top.png",
		"mcl_mangrove_roots_side.png",
		"mcl_mangrove_roots_side.png",
	},
	paramtype = "light",
	drawtype = "allfaces_optional",
	groups = {
		handy = 1, hoey = 1, shearsy = 1, axey = 1, swordy = 1, dig_by_piston = 0,
		flammable = 10, fire_encouragement = 30, fire_flammability = 60,
		deco_block = 1, compostability = 30
	},
	drop = "mcl_trees:mangrove_roots",
	_mcl_shears_drop = true,
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0.7,
	_mcl_hardness = 0.7,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = { "mcl_trees:mangrove_roots 1", "mcl_trees:mangrove_roots 2", "mcl_trees:mangrove_roots 3", "mcl_trees:mangrove_roots 4" },
})

minetest.register_node("mcl_trees:mangrove_propagule", {
	description = S("Mangrove Propagule"),
	_tt_help = S("Needs soil and light to grow"),
	_doc_items_longdesc = S("When placed on soil (such as dirt) and exposed to light, an propagule will grow into an mangrove after some time."),
	_doc_items_hidden = false,
	drawtype = "plantlike",
	waving = 1,
	visual_scale = 1.0,
	tiles = {"mcl_mangrove_propagule_item.png"},
	inventory_image = "mcl_mangrove_propagule_item.png",
	wield_image = "mcl_mangrove_propagule_item.png",
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
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("stage", 0)
	end,
	node_placement_prediction = "",
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
	on_place = mcl_util.generate_on_place_plant_function(function(place_pos, place_node,stack)
		local under = vector.offset(place_pos,0,-1,0)
		local snn = minetest.get_node_or_nil(under).name
		if not snn then return false end
		if table.indexof(propagule_allowed_nodes,snn) ~= -1 then
			local n = minetest.get_node(place_pos)
			if minetest.get_item_group(n.name,"water") > 0 and table.indexof(propagule_water_nodes,snn) ~= -1 then
					minetest.set_node(under,{name="mcl_trees:propagule_"..snn:split(":")[2]})
					stack:take_item()
					return stack
			end
			return true
		end
	end)
})

minetest.register_node("mcl_trees:mangrove_propagule_hanging", {
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
	drop = "mcl_trees:propagule",
	use_texture_alpha = "clip",
	drawtype = 'mesh',
	mesh = 'propagule_hanging.obj',
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- Base
		},
	},
	tiles = {"mcl_mangrove_propagule_hanging.png"},
	inventory_image = "mcl_mangrove_propagule.png",
	wield_image = "mcl_mangrove_propagule.png",
})

local propagule_rooted_nodes = {}
for _,root in pairs(propagule_water_nodes) do
	local r = root:split(":")[2]
	local def = minetest.registered_nodes[root]
	if def then
		local tx = def.tiles
		local n = "mcl_trees:propagule_"..r
		table.insert(propagule_rooted_nodes,n)
		minetest.register_node(n, {
			drawtype = "plantlike_rooted",
			paramtype = "light",
			place_param2 = 1,
			tiles = tx,
			special_tiles = { { name = "mcl_mangrove_propagule_item.png" } },
			inventory_image = "mcl_mangrove_propagule_item.png",
			wield_image = "mcl_mangrove_propagule.png",
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
			sounds = mcl_sounds.node_sound_leaves_defaults(),
			drop = "mcl_trees:propagule",
			node_placement_prediction = "",
			node_dig_prediction = "",
			after_dig_node = function(pos)
				minetest.set_node(pos, {name=root})
			end,
			_mcl_hardness = 0,
			_mcl_blast_resistance = 0,
			_mcl_silk_touch_drop = true,
		})
	end
end


mcl_flowerpots.register_potted_flower("mcl_trees:propagule", {
	name = "propagule",
	desc = S("Mangrove Propagule"),
	image = "mcl_mangrove_propagule.png",
})

local wltexture = {
	name="default_water_source_animated.png",
	animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0}
}

local wlroots = {
	description = S("water logged mangrove roots"),
	_doc_items_entry_name = S("water logged mangrove roots"),
	_doc_items_longdesc =
		S("Mangrove roots are decorative blocks that form as part of mangrove trees.").."\n\n"..
		S("Mangrove roots, despite being a full block, can be waterlogged and do not flow water out").."\n\n"..
		S("These cannot be crafted yet only occure when get in contact of water."),
	_doc_items_hidden = false,
	drawtype = "allfaces_optional",
	paramtype = "light",
	use_texture_alpha = "blend",
	tiles = {wltexture},
	special_tiles = {wltexture},
	overlay_tiles = {
		"mcl_mangrove_roots_top.png",
		"mcl_mangrove_roots_side.png",
		"mcl_mangrove_roots_side.png",
	},
	sounds = mcl_sounds.node_sound_water_defaults(),
	is_ground_content = false,
	walkable = true,
	pointable = true,
	diggable = true,
	buildable_to = false,
	liquids_pointable = true,
	drop = "mcl_trees:mangrove_roots",
	groups = {
		handy = 1, hoey = 1, water=3, liquid=3, puts_out_fire=1, dig_by_piston = 1, deco_block = 1,  not_in_creative_inventory=1 },
	_mcl_blast_resistance = 100,
	_mcl_hardness = -1, -- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	after_dig_node = function(pos)
		local node = minetest.get_node(pos)
		if minetest.get_item_group(node.name, "water") == 0 then
			minetest.set_node(pos, {name="mcl_core:water_source"})
		end
	end,
}

minetest.register_node("mcl_trees:mangrove_roots_water_logged", wlroots)

local rwltexture = {
	name = "default_river_water_source_animated.png",
	animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=5.0}
}

local rwlroots = table.copy(wlroots)
rwlroots.tiles = {rwltexture}
rwlroots.special_tiles = {rwltexture}

minetest.register_node("mcl_trees:mangrove_roots_river_water_logged", rwlroots)

minetest.register_node("mcl_trees:mangrove_roots_mud", {
	description = S("Muddy Mangrove Roots"),
	_tt_help = S("crafted with Mud and Mangrove roots"),
	_doc_items_longdesc = S("Muddy Mangrove Roots is a block from mangrove swamp.It drowns player a bit inside it."),
	tiles = {
		"mcl_mud.png^mcl_mangrove_roots_top.png",
		"mcl_mud.png^mcl_mangrove_roots_side.png",
		"mcl_mud.png^mcl_mangrove_roots_side.png",
	},
	is_ground_content = true,
	groups = {handy = 1, shovely = 1, axey = 1, building_block = 1},
	sounds = mcl_sounds.node_sound_sand_defaults(),
	_mcl_blast_resistance = 0.7,
	_mcl_hardness = 0.7,
})

minetest.register_abm({
	label = "Waterlog mangrove roots",
	nodenames = {"mcl_trees:mangrove_roots"},
	neighbors = {"group:water"},
	interval = 5,
	chance = 5,
	action = function(pos,value)
		for _,v in pairs(adjacents) do
			local n = minetest.get_node(vector.add(pos,v)).name
			if minetest.get_item_group(n,"water") > 0 then
				if n:find("river") then
					minetest.swap_node(pos,{name="mcl_trees:mangrove_roots_river_water_logged"})
					return
				else
					minetest.swap_node(pos,{name="mcl_trees:mangrove_roots_water_logged"})
					return
				end
			end
		end
	end
})

local abm_nodes = table.copy(propagule_rooted_nodes)
table.insert(abm_nodes,"mcl_trees:propagule")
minetest.register_abm({
	label = "Mangrove_tree_growth",
	nodenames = abm_nodes,
	interval = 30,
	chance = 5,
	action = function(pos,node)
		local pr = PseudoRandom(pos.x+pos.y+pos.z)
		local r = pr:next(1,5)
		local path = modpath .."/schematics/mcl_mangrove_tree_"..tostring(r)..".mts"
		local w = 5
		local h = 10
		local fp = true
		pos.y = pos.y - 1
		if table.indexof(propagule_rooted_nodes,node.name) ~= -1 then
			local nn = minetest.find_nodes_in_area(vector.offset(pos,0,-1,0),vector.offset(pos,0,h,0),{"group:water","air"})
			if #nn >= h then
				minetest.place_schematic(pos, path, "random", function()
					local nnv = minetest.find_nodes_in_area(vector.offset(pos,-5,-1,-5),vector.offset(pos,5,h/2,5),{"mcl_core:vine"})
					minetest.bulk_set_node(nnv,{"air"})
				end, true, "place_center_x, place_center_z")
			end
			return
		end
		if r > 3 then h = 18 end
		if mcl_trees.check_growth(pos, w, h) then
			minetest.place_schematic(pos, path, "random", nil, true, "place_center_x, place_center_z")
		end
end
})
