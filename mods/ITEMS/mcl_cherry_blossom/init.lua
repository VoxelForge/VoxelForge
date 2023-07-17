mcl_cherry_blossom = {}
local modpath = minetest.get_modpath(minetest.get_current_modname())

mcl_trees.register_wood("cherry_blossom",{
	sign_color="#E1A7A1",
	tree_schems= {
		{ file=modpath.."/schematics/mcl_cherry_blossom_tree_1.mts",width=7,height=11 },
		{ file=modpath.."/schematics/mcl_cherry_blossom_tree_2.mts",width=7,height=11 },
		{ file=modpath.."/schematics/mcl_cherry_blossom_tree_3.mts",width=7,height=11 },
		{ file=modpath.."/schematics/mcl_cherry_blossom_tree_beehive_1.mts",width=7,height=11 },
		{ file=modpath.."/schematics/mcl_cherry_blossom_tree_beehive_2.mts",width=7,height=11 },
		{ file=modpath.."/schematics/mcl_cherry_blossom_tree_beehive_3.mts",width=7,height=11 },
	},
	tree = { tiles = {"mcl_cherry_blossom_log_top.png", "mcl_cherry_blossom_log_top.png","mcl_cherry_blossom_log.png"} },
	leaves = { tiles = { "mcl_cherry_blossom_leaves.png" } },
	wood = { tiles = {"mcl_cherry_blossom_planks.png"}},
	sapling = {
		tiles = {"mcl_cherry_blossom_sapling.png"},
		inventory_image = "mcl_cherry_blossom_sapling.png",
		wield_image = "mcl_cherry_blossom_sapling.png",
	},
	potted_sapling = {
		image = "mcl_cherry_blossom_sapling.png",
	},
	stripped = {
		tiles = {"mcl_cherry_blossom_log_top_stripped.png", "mcl_cherry_blossom_log_top_stripped.png","mcl_cherry_blossom_log_stripped.png"}
	},
	stripped_bark = {
		tiles = {"mcl_cherry_blossom_log_stripped.png"}
	},
	fence = { tiles = {"mcl_cherry_blossom_planks.png"},},
	fence_gate = { tiles = {"mcl_cherry_blossom_planks.png"},},
	door = {
		inventory_image = "mcl_cherry_blossom_door_inv.png",
		tiles_bottom = {"mcl_cherry_blossom_door_bottom.png", "mcl_cherry_blossom_door_bottom_side.png"},
		tiles_top = {"mcl_cherry_blossom_door_top.png", "mcl_cherry_blossom_door_top_side.png"},
	},
	trapdoor = {
		tile_front = "mcl_cherry_blossom_trapdoor.png",
		tile_side = "mcl_cherry_blossom_trapdoor_side.png",
		wield_image = "mcl_cherry_blossom_trapdoor.png",
	},
})

local cherry_particle = {
	velocity = vector.zero(),
	acceleration = vector.new(0,-1,0),
	size = math.random(1.3,2.5),
	texture = "mcl_cherry_blossom_particle.png",
	collision_removal = false,
	collisiondetection = false,
}

minetest.register_abm({
	label = "Cherry Blossom Particles",
	nodenames = {"mcl_cherry_blossom:cherryleaves"},
	interval = 5,
	chance = 10,
	action = function(pos, node)
		minetest.after(math.random(0.1,1.5),function()
			local pt = table.copy(cherry_particle)
			pt.pos = vector.offset(pos,math.random(-0.5,0.5),-0.51,math.random(-0.5,0.5))
			pt.expirationtime = math.random(1.2,4.5)
			minetest.add_particle(pt)
		end)
	end
})
