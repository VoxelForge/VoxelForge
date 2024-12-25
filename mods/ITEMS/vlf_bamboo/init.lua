vlf_bamboo = {}
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator("vlf_bamboo")

dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/recipes.lua")

vlf_util.generate_on_place_plant_function(function(pos)
	local node_below = minetest.get_node(vector.offset(pos,0,-1,0))
	return minetest.get_item_group(node_below.name, "soil_bamboo") > 0
end)

local block_doc = S("A Block made of Bamboo stalks. Can be crafted into Bamboo Planks.")

vlf_trees.register_wood("bamboo",{
	readable_name = "Bamboo",
	sign_color="#FCE6BC",
	sapling = false,
	potted_sapling = false,
	leaves = false,
	tree = {
		description = S("Block of Bamboo"),
		_doc_items_longdesc = block_doc,
		tiles = {"vlf_bamboo_bamboo_bottom.png", "vlf_bamboo_bamboo_bottom.png","vlf_bamboo_bamboo_block.png" }
	},
	stripped = {
		description = S("Block of Stripped Bamboo"),
		_doc_items_longdesc = block_doc,
		tiles = {"vlf_bamboo_bamboo_bottom_stripped.png", "vlf_bamboo_bamboo_bottom_stripped.png","vlf_bamboo_bamboo_block_stripped.png" }
	},
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
	nodenames = {"group:bamboo_tree"},
	neighbors = {"group:soil_sapling","group:soil_bamboo"},
	interval = 15,
	chance = 10,
	action = function(pos,node)
		vlf_bamboo.grow(pos)
	end,
})
