local S = minetest.get_translator(minetest.get_current_modname())

local function on_bone_meal(itemstack,placer,pointed_thing,pos,node)
	if math.random(1, 100) <= 75 then
		return vlf_farming.on_bone_meal(itemstack,placer,pointed_thing,pos,node,"plant_beetroot",1)
	end
end

minetest.register_craftitem("vlf_farming:beetroot_seeds", {
	description = S("Beetroot Seeds"),
	_tt_help = S("Grows on farmland"),
	_doc_items_longdesc = S("Grows into a beetroot plant. Chickens like beetroot seeds."),
	_doc_items_usagehelp = S("Place the beetroot seeds on farmland (which can be created with a hoe) to plant a beetroot plant. They grow in sunlight and grow faster on hydrated farmland. Rightclick an animal to feed it beetroot seeds."),
	groups = {craftitem = 1, compostability = 30},
	inventory_image = "vlf_farming_beetroot_seeds.png",
	wield_image = "vlf_farming_beetroot_seeds.png",
	on_place = function(itemstack, placer, pointed_thing)
		return vlf_farming:place_seed(itemstack, placer, pointed_thing, "vlf_farming:beetroot_0")
	end
})

minetest.register_node("vlf_farming:beetroot_0", {
	description = S("Premature Beetroot Plant (Stage 1)"),
	_doc_items_longdesc = S("Beetroot plants are plants which grow on farmland under sunlight in 4 stages. On hydrated farmland, they grow a bit faster. They can be harvested at any time but will only yield a profit when mature."),
	_doc_items_entry_name = S("Premature Beetroot Plant"),
	paramtype = "light",
	paramtype2 = "meshoptions",
	sunlight_propagates = true,
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	drop = "vlf_farming:beetroot_seeds",
	tiles = {"vlf_farming_beetroot_0.png"},
	inventory_image = "vlf_farming_beetroot_0.png",
	wield_image = "vlf_farming_beetroot_0.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-5/16, -0.5 ,-5/16, 5/16, -0.5+(2/16) ,5/16}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1},
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	_vlf_blast_resistance = 0,
	_on_bone_meal = on_bone_meal,
})

minetest.register_node("vlf_farming:beetroot_1", {
	description = S("Premature Beetroot Plant (Stage 2)"),
	_doc_items_create_entry = false,
	paramtype = "light",
	paramtype2 = "meshoptions",
	sunlight_propagates = true,
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	drop = "vlf_farming:beetroot_seeds",
	tiles = {"vlf_farming_beetroot_1.png"},
	inventory_image = "vlf_farming_beetroot_1.png",
	wield_image = "vlf_farming_beetroot_1.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-6/16, -0.5 ,-6/16, 6/16, -0.5+(5/16) ,6/16}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1},
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	_vlf_blast_resistance = 0,
	_on_bone_meal = on_bone_meal,
})

minetest.register_node("vlf_farming:beetroot_2", {
	description = S("Premature Beetroot Plant (Stage 3)"),
	_doc_items_create_entry = false,
	paramtype = "light",
	paramtype2 = "meshoptions",
	sunlight_propagates = true,
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	drop = "vlf_farming:beetroot_seeds",
	tiles = {"vlf_farming_beetroot_2.png"},
	inventory_image = "vlf_farming_beetroot_2.png",
	wield_image = "vlf_farming_beetroot_2.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-7/16, -0.5 ,-7/16, 7/16, -0.5+(6/16) ,7/16}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1},
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	_vlf_blast_resistance = 0,
	_on_bone_meal = on_bone_meal,
})

minetest.register_node("vlf_farming:beetroot", {
	description = S("Mature Beetroot Plant"),
	_doc_items_longdesc = S("A mature beetroot plant is a farming plant which is ready to be harvested for a beetroot and some beetroot seeds. It won't grow any further."),
	_doc_items_create_entry = true,
	paramtype = "light",
	paramtype2 = "meshoptions",
	sunlight_propagates = true,
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	drop = {
		--[[ drops 1 beetroot guaranteed.
		drops 0-3 beetroot seeds:
		0 seeds: 42.18%
		1 seed:  14.06%
		2 seeds: 18.75%
		3 seeds: 25%

		correction: should always drop at least 1 seed. (1-4 seeds, per the minecraft wiki)
		--]]
		max_items = 2,
		items = {
			{items = {"vlf_farming:beetroot_item"}},
			{items = {"vlf_farming:beetroot_seeds 4"}, rarity = 6},
			{items = {"vlf_farming:beetroot_seeds 3"}, rarity = 4},
			{items = {"vlf_farming:beetroot_seeds 2"}, rarity = 3},
			{items = {"vlf_farming:beetroot_seeds"}, rarity = 1},
		},
	},

	_vlf_fortune_drop = {
		discrete_uniform_distribution = true,
		items = {"vlf_farming:beetroot_seeds"},
		min_count = 1,
		max_count = 3,
		cap = 5,
	},
	tiles = {"vlf_farming_beetroot_3.png"},
	inventory_image = "vlf_farming_beetroot_3.png",
	wield_image = "vlf_farming_beetroot_3.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-8/16, -0.5 ,-8/16, 8/16, -0.5+(8/16) ,8/16}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,beetroot=4},
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	_vlf_blast_resistance = 0,
	_on_bone_meal = on_bone_meal,
})

minetest.register_craftitem("vlf_farming:beetroot_item", {
	description = S("Beetroot"),
	_doc_items_longdesc = S("Beetroots are both used as food item and a dye ingredient. Pigs like beetroots, too."),
	_doc_items_usagehelp = S("Hold it in your hand and right-click to eat it. Rightclick an animal to feed it."),
	inventory_image = "vlf_farming_beetroot.png",
	wield_image = "vlf_farming_beetroot.png",
	on_place = minetest.item_eat(1),
	on_secondary_use = minetest.item_eat(1),
	groups = {food = 2, eatable = 1, compostability = 65},
	_vlf_saturation = 1.2,
})

minetest.register_craftitem("vlf_farming:beetroot_soup", {
	description = S("Beetroot Soup"),
	_doc_items_longdesc = S("Beetroot soup is a food item."),
	stack_max = 1,
	inventory_image = "vlf_farming_beetroot_soup.png",
	wield_image = "vlf_farming_beetroot_soup.png",
	on_place = minetest.item_eat(6, "vlf_core:bowl"),
	on_secondary_use = minetest.item_eat(6, "vlf_core:bowl"),
	groups = { food = 3, eatable = 6 },
	_vlf_saturation = 7.2,
})

minetest.register_craft({
	output = "vlf_farming:beetroot_soup",
	recipe = {
		{ "vlf_farming:beetroot_item","vlf_farming:beetroot_item","vlf_farming:beetroot_item", },
		{ "vlf_farming:beetroot_item","vlf_farming:beetroot_item","vlf_farming:beetroot_item", },
		{ "", "vlf_core:bowl", "" },
	},
})

vlf_farming:add_plant("plant_beetroot", "vlf_farming:beetroot", {"vlf_farming:beetroot_0", "vlf_farming:beetroot_1", "vlf_farming:beetroot_2"}, 68, 3)

if minetest.get_modpath("doc") then
	for i = 1, 2 do
		doc.add_entry_alias("nodes", "vlf_farming:beetroot_0", "nodes", "vlf_farming:beetroot_" .. i)
	end
end

minetest.register_alias("beetroot_seeds", "vlf_farming:beetroot_seeds")
minetest.register_alias("beetroot", "vlf_farming:beetroot_item")
