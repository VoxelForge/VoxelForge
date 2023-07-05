local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
mcl_bamboo = {}
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/recipes.lua")

mcl_trees.register_wood("bamboo",{
	sign_color="#FCE6BC",
	sapling = {
		tiles = {"mcl_bamboo_bamboo_shoot.png"},
		inventory_image = "mcl_bamboo_bamboo_shoot.png",
		wield_image = "mcl_bamboo_bamboo_shoot.png",
		groups = {
			dig_immediate = 3, dig_by_water = 1, dig_by_piston = 1, destroy_by_lava_flow = 1,
			attached_node = 1, deco_block = 1, plant = 1, bamboo_sapling = 1, non_mycelium_plant = 1,
			compostability = 30
		},
		_on_bone_meal = function(itemstack,placer,pointed_thing,pos,node)
			minetest.set_node(pos,{name=mcl_bamboo.bamboo_itemstrings[math.random(#mcl_bamboo.bamboo_itemstrings)]})
			mcl_bamboo.grow(pos)
		end,
	},
	leaves = false,
	tree = { tiles = {"mcl_bamboo_bamboo_bottom.png", "mcl_bamboo_bamboo_bottom.png","mcl_bamboo_bamboo_block.png" }},
	stripped = { tiles = {"mcl_bamboo_bamboo_bottom_stripped.png", "mcl_bamboo_bamboo_bottom_stripped.png","mcl_bamboo_bamboo_block_stripped.png" }},
	bark = { tiles = {"mcl_bamboo_bamboo_block.png"}},
	planks = { tiles = {"mcl_bamboo_bamboo_plank.png"}},
	stripped_bark = { tiles = {"mcl_bamboo_bamboo_block_stripped.png"} },
	fence = { tiles = { "mcl_bamboo_fence_bamboo.png" },},
	fence_gate = { tiles = { "mcl_bamboo_fence_gate_bamboo.png" }, },
	door = {
		inventory_image = "mcl_bamboo_door_wield.png",
		tiles_bottom = {"mcl_bamboo_door_bottom.png","mcl_bamboo_door_bottom.png"},
		tiles_top = {"mcl_bamboo_door_top.png","mcl_bamboo_door_bottom.png"},
	},
	trapdoor = {
		tile_front = "mcl_bamboo_trapdoor_side.png",
		tile_side = "mcl_bamboo_trapdoor_side.png",
		wield_image = "mcl_bamboo_trapdoor_side.png",
	},
})

minetest.register_abm({
	label = "Bamboo growth",
	nodenames = {"group:bamboo_sapling","group:bamboo_tree"},
	neighbors = {"group:soil_sapling","group:soil_bamboo"},
	interval = 15,
	chance = 10,
	action = function(pos,node)
		if node.name == "mcl_trees:sapling_bamboo" then
			minetest.set_node(pos,{name=mcl_bamboo.bamboo_itemstrings[math.random(#mcl_bamboo.bamboo_itemstrings)]})
		end
		mcl_bamboo.grow(pos)
	end,
})
