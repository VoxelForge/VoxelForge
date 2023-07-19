mcl_cherry_blossom = {}
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

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
	wood = { tiles = {"mcl_cherry_blossom_planks.png"}},
	sapling = {
		tiles = {"mcl_cherry_blossom_sapling.png"},
		inventory_image = "mcl_cherry_blossom_sapling.png",
		wield_image = "mcl_cherry_blossom_sapling.png",
	},
	potted_sapling = {
		image = "mcl_cherry_blossom_sapling.png",
	},
	leaves = {
		tiles = { "mcl_cherry_blossom_leaves.png" },
		palette = "", --no biome coloring
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

minetest.register_node("mcl_cherry_blossom:pink_petals",{
	description = S("Pink Petals"),
	doc_items_longdesc = S("Pink Petals are ground decoration of cherry grove biomes"),
	doc_items_hidden = false,
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	sunlight_propagates = true,
	buildable_to = true,
	floodable = true,
	pointable = true,
	drawtype = "nodebox",
	node_box = {type = "fixed", fixed = {-1/2, -1/2, -1/2, 1/2, -7.9/16, 1/2}},
	collision_box = {type = "fixed", fixed = {-1/2, -1/2, -1/2, 1/2, -7.9/16, 1/2}},
	groups = {
		shearsy=1,
		handy=1,
		flammable=3,
		attached_node=1,
		dig_by_piston=1,
		--not_in_creative_inventory=1,
	},
	use_texture_alpha = "clip",
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	tiles = {
		"mcl_cherry_blossom_pink_petals.png",
		"mcl_cherry_blossom_pink_petals.png^[transformFY", -- mirror
		"blank.png" -- empty
	},
	_mcl_hardness = 0,
	_mcl_blast_resistance = 0,
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
	nodenames = {"mcl_trees:leaves_cherry_blossom"},
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
