minetest.register_craftitem("mcl_farming:wheat_seeds", {
	-- Original Minecraft name: “Seeds”
	description = "Wheat Seeds",
	_doc_items_longdesc = "Grows into a wheat plant. Chickens like wheat seeds.",
	_doc_items_usagehelp = "Place the wheat seeds on farmland (which can be created with a hoe) to plant a wheat plant. They grow in sunlight and grow faster on hydrated farmland. Rightclick an animal to feed it wheat seeds.",
	groups = { craftitem=1 },
	inventory_image = "farming_wheat_seed.png",
	on_place = function(itemstack, placer, pointed_thing)
		return mcl_farming:place_seed(itemstack, placer, pointed_thing, "mcl_farming:wheat_1")
	end
})

minetest.register_node("mcl_farming:wheat_1", {
	description = "Premature Wheat Plant (First Stage)",
	_doc_items_entry_name = "Premature Wheat Plant",
	_doc_items_longdesc = "Premature wheat plants grow on farmland under sunlight in 4 stages. On hydrated farmland, they grow faster. They can be harvested at any time but will only yield a profit when mature.",
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	drop = "mcl_farming:wheat_seeds",
	tiles = {"farming_wheat_1.png"},
	inventory_image = "farming_wheat_1.png",
	wield_image = "farming_wheat_1.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1, dig_by_water=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_farming:wheat_2", {
	description = "Premature Wheat Plant (Second Stage)",
	_doc_items_create_entry = false,
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	drop = "mcl_farming:wheat_seeds",
	tiles = {"farming_wheat_2.png"},
	inventory_image = "farming_wheat_2.png",
	wield_image = "farming_wheat_2.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1, dig_by_water=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_farming:wheat_3", {
	description = "Premature Wheat Plant (Third Stage)",
	_doc_items_create_entry = false,
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	drop = "mcl_farming:wheat_seeds",
	tiles = {"farming_wheat_3.png"},
	inventory_image = "farming_wheat_3.png",
	wield_image = "farming_wheat_3.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.25, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1, dig_by_water=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_farming:wheat", {
	description = "Mature Wheat Plant",
	_doc_items_longdesc = "Mature wheat plants are ready to be harvested for wheat and wheat seeds. They won't grow any further.",
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	tiles = {"farming_wheat.png"},
	inventory_image = "farming_wheat.png",
	wield_image = "farming_wheat.png",
	drop = {
		max_items = 4,
		items = {
			{ items = {'mcl_farming:wheat_seeds'} },
			{ items = {'mcl_farming:wheat_seeds'}, rarity = 2},
			{ items = {'mcl_farming:wheat_seeds'}, rarity = 5},
			{ items = {'mcl_farming:wheat_item'} }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.35, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1, dig_by_water=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

mcl_farming:add_plant("mcl_farming:wheat", {"mcl_farming:wheat_1", "mcl_farming:wheat_2", "mcl_farming:wheat_3"}, 50, 20)

minetest.register_craftitem("mcl_farming:wheat_item", {
	description = "Wheat",
	_doc_items_longdesc = "Wheat is used in crafting. Some animals like wheat.",
	_doc_items_usagehelp = "Rightclick an animal to try to feed it wheat.",
	inventory_image = "farming_wheat_harvested.png",
	groups = { craftitem = 1 },
})

minetest.register_craft({
	output = "mcl_farming:bread",
	recipe = {
		{'mcl_farming:wheat_item', 'mcl_farming:wheat_item', 'mcl_farming:wheat_item'},
	}
})

minetest.register_craft({
	output = "mcl_farming:cookie 8",
	recipe = {
		{'mcl_farming:wheat_item', 'mcl_dye:brown', 'mcl_farming:wheat_item'},
	}
})

minetest.register_craftitem("mcl_farming:cookie", {
	description = "Cookie",
	_doc_items_longdesc = "This is a food item which can be eaten for 2 hunger points.",
	inventory_image = "farming_cookie.png",
	groups = {food=2, eatable=2},
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
})


minetest.register_craftitem("mcl_farming:bread", {
	description = "Bread",
	_doc_items_longdesc = "This is a food item which can be eaten for 5 hunger points.",
	inventory_image = "farming_bread.png",
	groups = {food=2, eatable=5},
	on_place = minetest.item_eat(5),
	on_secondary_use = minetest.item_eat(5),
})

minetest.register_node("mcl_farming:hay_block", {
	description = "Hay Bale",
	_doc_items_longdesc = "Hay bales are decorative blocks made from wheat.",
	tiles = {"mcl_farming_hayblock_top.png", "mcl_farming_hayblock_top.png", "mcl_farming_hayblock_side.png"},
	is_ground_content = false,
	stack_max = 64,
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = mcl_util.rotate_axis,
	groups = {handy=1, flammable=2, building_block=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 0.5,
})

minetest.register_craft({
	output = 'mcl_farming:hay_block',
	recipe = {
		{'mcl_farming:wheat_item', 'mcl_farming:wheat_item', 'mcl_farming:wheat_item'},
		{'mcl_farming:wheat_item', 'mcl_farming:wheat_item', 'mcl_farming:wheat_item'},
		{'mcl_farming:wheat_item', 'mcl_farming:wheat_item', 'mcl_farming:wheat_item'},
	}
})

minetest.register_craft({
	output = 'mcl_farming:wheat_item 9',
	recipe = {
		{'mcl_farming:hay_block'},
	}
})

if minetest.get_modpath("doc") then
	for i=2,3 do
		doc.add_entry_alias("nodes", "mcl_farming:wheat_1", "nodes", "mcl_farming:wheat_"..i)
	end
end
