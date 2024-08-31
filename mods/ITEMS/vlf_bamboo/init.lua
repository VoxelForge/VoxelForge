vlf_bamboo = {}
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator("vlf_bamboo")

dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/recipes.lua")

local place_bamboosap = vlf_util.generate_on_place_plant_function(function(pos, node)
	local node_below = minetest.get_node(vector.offset(pos,0,-1,0))
	return minetest.get_item_group(node_below.name, "soil_bamboo") > 0
end)

vlf_trees.register_wood("bamboo",{
	readable_name = S("Bamboo"),
	sign_color="#FCE6BC",
	sapling = {
		tiles = {"vlf_bamboo_bamboo_shoot.png"},
		inventory_image = "vlf_bamboo_bamboo_shoot.png",
		wield_image = "vlf_bamboo_bamboo_shoot.png",
		groups = {
			dig_immediate = 3, dig_by_water = 1, dig_by_piston = 1, destroy_by_lava_flow = 1,
			attached_node = 1, deco_block = 1, plant = 1, bamboo_sapling = 1, non_mycelium_plant = 1,
			compostability = 30
		},
		on_place = place_bamboosap,
		_on_bone_meal = function(itemstack,placer,pointed_thing,pos,node)
			minetest.set_node(pos,{name=vlf_bamboo.bamboo_itemstrings[math.random(#vlf_bamboo.bamboo_itemstrings)]})
			vlf_bamboo.grow(pos)
		end,
	},
	potted_sapling = false,
	leaves = false,
	tree = { tiles = {"vlf_bamboo_bamboo_bottom.png", "vlf_bamboo_bamboo_bottom.png","vlf_bamboo_bamboo_block.png" }},
	stripped = { tiles = {"vlf_bamboo_bamboo_bottom_stripped.png", "vlf_bamboo_bamboo_bottom_stripped.png","vlf_bamboo_bamboo_block_stripped.png" }},
	bark = { tiles = {"vlf_bamboo_bamboo_block.png"}},
	wood = { tiles = {"vlf_bamboo_bamboo_plank.png"}},
	stripped_bark = { tiles = {"vlf_bamboo_bamboo_block_stripped.png"} },
	fence = { tiles = { "vlf_bamboo_fence_bamboo.png" },},
	fence_gate = { tiles = { "vlf_bamboo_fence_gate_bamboo.png" }, },
	door = {
		inventory_image = "vlf_bamboo_door_wield.png",
		tiles_bottom = {"vlf_bamboo_door_bottom.png","vlf_bamboo_door_bottom.png"},
		tiles_top = {"vlf_bamboo_door_top.png","vlf_bamboo_door_bottom.png"},
	},
	trapdoor = {
		tile_front = "vlf_bamboo_trapdoor_side.png",
		tile_side = "vlf_bamboo_trapdoor_side.png",
		wield_image = "vlf_bamboo_trapdoor_side.png",
	},
	boat = {
		item = {
			description = S("Bamboo Raft"),
		},
		object = {
			collisionbox = {-0.5, -0.15, -0.5, 0.5, 0.25, 0.5},
			selectionbox = {-0.7, -0.15, -0.7, 0.7, 0.25, 0.7},
		},
	}, --needs different model
	chest_boat = {
		item = {
			description = S("Chest Bamboo Raft"),
		},
		object = {
			collisionbox = {-0.5, -0.15, -0.5, 0.5, 0.25, 0.5},
			selectionbox = {-0.7, -0.15, -0.7, 0.7, 0.25, 0.7},
		},
	},
})

minetest.register_abm({
	label = "Bamboo growth",
	nodenames = {"group:bamboo_sapling","group:bamboo_tree"},
	neighbors = {"group:soil_sapling","group:soil_bamboo"},
	interval = 15,
	chance = 10,
	action = function(pos,node)
		if node.name == "vlf_trees:sapling_bamboo" then
			minetest.set_node(pos,{name=vlf_bamboo.bamboo_itemstrings[math.random(#vlf_bamboo.bamboo_itemstrings)]})
		end
		vlf_bamboo.grow(pos)
	end,
})
