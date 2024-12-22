local S = minetest.get_translator(minetest.get_current_modname())
local function on_bone_meal(itemstack,placer,pointed_thing,pos,node)
	return vlf_farming.on_bone_meal(itemstack,placer,pointed_thing,pos,node,"plant_melon_stem")
end
--_on_bone_meal = on_bone_meal,
-- Seeds
minetest.register_craftitem("vlf_farming:melon_seeds", {
	description = S("Melon Seeds"),
	_tt_help = S("Grows on farmland"),
	_doc_items_longdesc = S("Grows into a melon stem which in turn grows melons. Chickens like melon seeds."),
	_doc_items_usagehelp = S("Place the melon seeds on farmland (which can be created with a hoe) to plant a melon stem. Melon stems grow in sunlight and grow faster on hydrated farmland. When mature, the stem will attempt to grow a melon at the side. Rightclick an animal to feed it melon seeds."),
	groups = {craftitem = 1, compostability = 30},
	inventory_image = "vlf_farming_melon_seeds.png",
	_vlf_places_plant = "vlf_farming:melontige_1",
	on_place = function(itemstack, placer, pointed_thing)
		return vlf_farming:place_seed(itemstack, placer, pointed_thing, "vlf_farming:melontige_1")
	end,
})

-- Melon template (will be fed into vlf_farming.register_gourd

local melon_base_def = {
	description = S("Melon"),
	_doc_items_longdesc = S("A melon is a block which can be grown from melon stems, which in turn are grown from melon seeds. It can be harvested for melon slices."),
	tiles = {"farming_melon_top.png", "farming_melon_top.png", "farming_melon_side.png", "farming_melon_side.png", "farming_melon_side.png", "farming_melon_side.png"},
	groups = {
		handy = 1, axey = 1, plant = 1, building_block = 1, dig_by_piston = 1,
		enderman_takable = 1, compostability = 65, unsticky = 1
	},
	drop = {
		max_items = 1,
		items = {
			{ items = {"vlf_farming:melon_item 7"}, rarity = 14 },
			{ items = {"vlf_farming:melon_item 6"}, rarity = 10 },
			{ items = {"vlf_farming:melon_item 5"}, rarity = 5 },
			{ items = {"vlf_farming:melon_item 4"}, rarity = 2 },
			{ items = {"vlf_farming:melon_item 3"} },
		}
	},
	sounds = vlf_sounds.node_sound_wood_defaults(),
	_vlf_blast_resistance = 1,
	_vlf_hardness = 1,
	_vlf_silk_touch_drop = true,
	_vlf_fortune_drop = {
		discrete_uniform_distribution = true,
		items = {"vlf_farming:melon_item"},
		min_count = 3,
		max_count = 7,
		cap = 9,
	}
}

-- Drop proabilities for melon stem
local stem_drop = {
	max_items = 1,
	-- The probabilities are slightly off from the original.
	-- Update this drop list when the Minetest drop probability system
	-- is more powerful.
	items = {
		-- 1 seed: Approximation to 20/125 chance
		-- 20/125 = 0.16
		-- Approximation: 1/6 = ca. 0.166666666666667
		{ items = {"vlf_farming:melon_seeds 1"}, rarity = 6 },

		-- 2 seeds: Approximation to 4/125 chance
		-- 4/125 = 0.032
		-- Approximation: 1/31 = ca. 0.032258064516129
		{ items = {"vlf_farming:melon_seeds 2"}, rarity = 31 },

		-- 3 seeds: 1/125 chance
		{ items = {"vlf_farming:melon_seeds 3"}, rarity = 125 },
	},
}

-- Growing unconnected stems


local startcolor = { r = 0x2E , g = 0x9D, b = 0x2E }
local endcolor = { r = 0xFF , g = 0xA8, b = 0x00 }


for s=1,7 do
	local h = s / 8
	local doc = s == 1
	local longdesc, entry_name
	if doc then
		entry_name = S("Premature Melon Stem")
		longdesc = S("Melon stems grow on farmland in 8 stages. On hydrated farmland, the growth is a bit quicker. Mature melon stems are able to grow melons.")
	end
	local colorstring = vlf_farming:stem_color(startcolor, endcolor, s, 8)
	local texture = "([combine:16x16:0,"..((8-s)*2).."=vlf_farming_melon_stem_disconnected.png)^[colorize:"..colorstring..":127"
	minetest.register_node("vlf_farming:melontige_"..s, {
		description = S("Premature Melon Stem (Stage @1)", s),
		_doc_items_create_entry = doc,
		_doc_items_entry_name = entry_name,
		_doc_items_longdesc = longdesc,
		paramtype = "light",
		walkable = false,
		drawtype = "plantlike",
		sunlight_propagates = true,
		drop = stem_drop,
		tiles = {texture},
		wield_image = texture,
		inventory_image = texture,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.15, -0.5, -0.15, 0.15, -0.5+h, 0.15}
			},
		},
		groups = {dig_immediate=3, not_in_creative_inventory=1, plant=1,attached_node=1, dig_by_water=1,destroy_by_lava_flow=1, plant_melon_stem=s},
		sounds = vlf_sounds.node_sound_leaves_defaults(),
		_vlf_blast_resistance = 0,
		_on_bone_meal = on_bone_meal,
		_vlf_baseitem = "vlf_farming:melon_seeds",
	})
end

-- Full melon stem, able to spawn melons
local stem_def = {
	description = S("Mature Melon Stem"),
	_doc_items_create_entry = true,
	_doc_items_longdesc = S("A mature melon stem attempts to grow a melon at one of its four adjacent blocks. A melon can only grow on top of farmland, dirt, or a grass block. When a melon is next to a melon stem, the melon stem immediately bends and connects to the melon. While connected, a melon stem can't grow another melon. As soon all melons around the stem have been removed, it loses the connection and is ready to grow another melon."),
	tiles = {"vlf_farming_melon_stem_disconnected.png^[colorize:#FFA800:127"},
	wield_image = "vlf_farming_melon_stem_disconnected.png^[colorize:#FFA800:127",
	inventory_image = "vlf_farming_melon_stem_disconnected.png^[colorize:#FFA800:127",
	_vlf_baseitem = "vlf_farming:melon_seeds",
}

-- Register stem growth
vlf_farming:add_plant("plant_melon_stem", "vlf_farming:melontige_unconnect", {"vlf_farming:melontige_1", "vlf_farming:melontige_2", "vlf_farming:melontige_3", "vlf_farming:melontige_4", "vlf_farming:melontige_5", "vlf_farming:melontige_6", "vlf_farming:melontige_7"}, 30, 5)

-- Register actual melon, connected stems and stem-to-melon growth
vlf_farming:add_gourd("vlf_farming:melontige_unconnect", "vlf_farming:melontige_linked", "vlf_farming:melontige_unconnect", stem_def, stem_drop, "vlf_farming:melon", melon_base_def, 25, 15, "vlf_farming_melon_stem_connected.png^[colorize:#FFA800:127")

-- Items and crafting
minetest.register_craftitem("vlf_farming:melon_item", {
	-- Original name: “Melon”
	description = S("Melon Slice"),
	_doc_items_longdesc = S("This is a food item which can be eaten."),
	inventory_image = "farming_melon.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = {food = 2, eatable = 2, compostability = 50},
	_vlf_saturation = 1.2,
})

minetest.register_craft({
	output = "vlf_farming:melon_seeds",
	recipe = {{"vlf_farming:melon_item"}}
})

minetest.register_craft({
	output = "vlf_farming:melon",
	recipe = {
		{"vlf_farming:melon_item", "vlf_farming:melon_item", "vlf_farming:melon_item"},
		{"vlf_farming:melon_item", "vlf_farming:melon_item", "vlf_farming:melon_item"},
		{"vlf_farming:melon_item", "vlf_farming:melon_item", "vlf_farming:melon_item"},
	}
})

if minetest.get_modpath("doc") then
	for i=2,8 do
		doc.add_entry_alias("nodes", "vlf_farming:melontige_1", "nodes", "vlf_farming:melontige_"..i)
	end
end
