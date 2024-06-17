local S = minetest.get_translator("vlc_blackstone")


local on_rotate
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.rotate_3way
end

--Blocks
minetest.register_node("vlc_blackstone:blackstone", {
	description = S("Blackstone"),
	tiles = {"vlc_blackstone_top.png", "vlc_blackstone_top.png", "vlc_blackstone_side.png"},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1, cobble=1, stonecuttable = 1},
	_vlc_blast_resistance = 6,
	_vlc_hardness = 1.5,
})
minetest.register_node("vlc_blackstone:blackstone_gilded", {
	description = S("Gilded Blackstone"),
	tiles = {"vlc_blackstone_gilded.png"},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1, xp=1},
	drop = {
		max_items = 1,
		items = {
			{items = {"vlc_core:gold_nugget 2"},rarity = 40},
			{items = {"vlc_core:gold_nugget 3"},rarity = 40},
			{items = {"vlc_core:gold_nugget 4"},rarity = 40},
			{items = {"vlc_core:gold_nugget 5"},rarity = 40},
			-- 4x 1 in 40 chance adds up to a 10% chance
			{items = {"vlc_blackstone:blackstone_gilded"}, rarity = 1},
		}
	},
	_vlc_blast_resistance = 2,
	_vlc_hardness = 2,
	_vlc_silk_touch_drop = true,
	_vlc_fortune_drop = {
		discrete_uniform_distribution = true,
		items = {"vlc_core:gold_nugget"},
		min_count = 2,
		max_count = 5,
		cap = 5,
	},
})
minetest.register_node("vlc_blackstone:nether_gold", {
	description = S("Nether Gold Ore"),
	tiles = {"vlc_nether_gold_ore.png"},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1, xp=1},
	drop = {
		max_items = 1,
		items = {
			{items = {"vlc_core:gold_nugget 6"},rarity = 5},
			{items = {"vlc_core:gold_nugget 5"},rarity = 5},
			{items = {"vlc_core:gold_nugget 4"},rarity = 5},
			{items = {"vlc_core:gold_nugget 3"},rarity = 5},
			{items = {"vlc_core:gold_nugget 2"},rarity = 1},
		}
	},
	_vlc_blast_resistance = 3,
	_vlc_hardness = 3,
	_vlc_silk_touch_drop = true,
	_vlc_fortune_drop = vlc_core.fortune_drop_ore,
})
minetest.register_node("vlc_blackstone:basalt_polished", {
	description = S("Polished Basalt"),
	tiles = {"vlc_blackstone_basalt_top_polished.png", "vlc_blackstone_basalt_top_polished.png", "vlc_blackstone_basalt_side_polished.png"},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	on_place = vlc_util.rotate_axis,
	on_rotate = on_rotate,
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1},
	_vlc_blast_resistance = 4.2,
	_vlc_hardness = 1.25,
})
minetest.register_node("vlc_blackstone:basalt", {
	description = S("Basalt"),
	tiles = {"vlc_blackstone_basalt_top.png", "vlc_blackstone_basalt_top.png", "vlc_blackstone_basalt_side.png"},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	on_place = vlc_util.rotate_axis,
	on_rotate = on_rotate,
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1, stonecuttable = 1},
	_vlc_blast_resistance = 4.2,
	_vlc_hardness = 1.25,
})
minetest.register_node("vlc_blackstone:basalt_smooth", {
	description = S("Smooth Basalt"),
	tiles = {"vlc_blackstone_basalt_smooth.png"},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1},
	_vlc_blast_resistance = 4.2,
	_vlc_hardness = 1.25,
	_vlc_stonecutter_recipes = {"vlc_blackstone:basalt"},
})
minetest.register_node("vlc_blackstone:blackstone_polished", {
	description = S("Polished Blackstone"),
	tiles = {"vlc_blackstone_polished.png"},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1, stonecuttable = 1},
	_vlc_blast_resistance = 6,
	_vlc_hardness = 2,
	_vlc_stonecutter_recipes = {"vlc_blackstone:blackstone"},
})
minetest.register_node("vlc_blackstone:blackstone_chiseled_polished", {
	description = S("Chiseled Polished Blackstone"),
	tiles = {"vlc_blackstone_chiseled_polished.png"},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1},
	_vlc_blast_resistance = 6,
	_vlc_hardness = 1.5,
	_vlc_stonecutter_recipes = {"vlc_blackstone:blackstone", "vlc_blackstone:blackstone_polished"},
})
minetest.register_node("vlc_blackstone:blackstone_brick_polished", {
	description = S("Polished Blackstone Bricks"),
	tiles = {"vlc_blackstone_polished_bricks.png"},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1},
	_vlc_blast_resistance = 6,
	_vlc_hardness = 1.5,
	_vlc_stonecutter_recipes = {"vlc_blackstone:blackstone", "vlc_blackstone:blackstone_polished"},
})
minetest.register_node("vlc_blackstone:quartz_brick", {
	description = S("Quartz Bricks"),
	tiles = {"vlc_backstone_quartz_bricks.png"},
	is_ground_content = false,
	sounds = vlc_sounds.node_sound_stone_defaults(),
	groups = {cracky = 3, pickaxey=1, material_stone=1},
	_vlc_blast_resistance = 0.8,
	_vlc_hardness = 0.8,
})
minetest.register_node("vlc_blackstone:soul_soil", {
	description = S("Soul Soil"),
	tiles = {"vlc_blackstone_soul_soil.png"},
	is_ground_content = false,
	sounds = vlc_sounds.node_sound_sand_defaults(),
	groups = { cracky=3, handy=1, shovely=1, soul_block=1, soil_fungus=1 },
	_vlc_blast_resistance = 0.5,
	_vlc_hardness = 0.5,
})
minetest.register_node("vlc_blackstone:soul_fire", {
	description = S("Eternal Soul Fire"),
	_doc_items_longdesc = minetest.registered_nodes["vlc_fire:eternal_fire"]._doc_items_longdesc ,
	drawtype = "firelike",
	tiles = {
		{
			name = "soul_fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	inventory_image = "soul_fire_basic_flame.png",
	paramtype = "light",
	light_source = 10,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 2,
	_vlc_node_death_message = minetest.registered_nodes["vlc_fire:fire"]._vlc_node_death_message,
	groups = {fire = 1, dig_immediate = 3, not_in_creative_inventory = 1, dig_by_piston = 1, destroys_items = 1, set_on_fire=8},
	floodable = true,
	drop = "",
	on_flood = function(pos, oldnode, newnode)
		if minetest.get_item_group(newnode.name, "water") > 0 then
			minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
		end
	end,
	on_construct=function(pos)
		local under = minetest.get_node(vector.offset(pos,0,-1,0)).name
		if minetest.get_item_group(under, "soul_block") > 0 then
			minetest.swap_node(pos, {name = "air"})
		end
	end
})

local old_onconstruct=minetest.registered_nodes["vlc_fire:fire"].on_construct
minetest.registered_nodes["vlc_fire:fire"].on_construct=function(pos)
	local under = minetest.get_node(vector.offset(pos,0,-1,0)).name
	if minetest.get_item_group(under, "soul_block") > 0 then
		minetest.swap_node(pos, {name = "vlc_blackstone:soul_fire"})
	end
	old_onconstruct(pos)
end

--slabs/stairs
vlc_stairs.register_stair_and_slab("blackstone", {
	baseitem = "vlc_blackstone:blackstone",
	description_stair = S("Blackstone Stairs"),
	description_slab = S("Blackstone Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_blackstone:blackstone"}}, {_vlc_stonecutter_recipes = {"vlc_blackstone:blackstone"}}
})
vlc_stairs.register_stair_and_slab("blackstone_polished", {
	baseitem = "vlc_blackstone:blackstone_polished",
	description_stair = S("Polished Blackstone Stairs"),
	description_slab = S("Polished Blackstone Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_blackstone:blackstone", "vlc_blackstone:blackstone_polished"}}, {_vlc_stonecutter_recipes = {"vlc_blackstone:blackstone", "vlc_blackstone:blackstone_polished"}}
})
vlc_stairs.register_stair_and_slab("blackstone_brick_polished", {
	baseitem = "vlc_blackstone:blackstone_brick_polished",
	description_stair = S("Blackstone Brick Stairs"),
	description_slab = S("Blackstone Brick Slab"),
	overrides = {_vlc_stonecutter_recipes = {"vlc_blackstone:blackstone", "vlc_blackstone:blackstone_polished"}}, {_vlc_stonecutter_recipes = {"vlc_blackstone:blackstone", "vlc_blackstone:blackstone_polished"}}
})
minetest.register_alias("vlc_stairs:slab_blackstone_chiseled_polished_top", "vlc_stairs:slab_blackstone_polished_top")
minetest.register_alias("vlc_stairs:slab_blackstone_chiseled_polished", "vlc_stairs:slab_blackstone_polished")
minetest.register_alias("vlc_stairs:slab_blackstone_chiseled_polished_double", "vlc_stairs:slab_blackstone_polished_double")
minetest.register_alias("vlc_stairs:stair_blackstone_chiseled_polished", "vlc_stairs:stair_blackstone_polished")
minetest.register_alias("vlc_stairs:stair_blackstone_chiseled_polished_inner", "vlc_stairs:stair_blackstone_polished_inner")
minetest.register_alias("vlc_stairs:stair_blackstone_chiseled_polished_outer", "vlc_stairs:stair_blackstone_polished_outer")

--Wall
vlc_walls.register_wall_def("vlc_blackstone:wall", {
	description = S("Blackstone Wall"),
	source = "vlc_blackstone:blackstone",
	_vlc_stonecutter_recipes = {"vlc_blackstone:blackstone"},
})

--lavacooling

minetest.register_abm({
	label = "Lava cooling (basalt)",
	nodenames = {"group:lava"},
	neighbors = {"vlc_core:ice"},
	interval = 1,
	chance = 1,
	min_y = vlc_vars.mg_end_min,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local water = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+1, z=pos.z+1}, "vlc_core:ice")
		local lavatype = minetest.registered_nodes[node.name].liquidtype
		for w=1, #water do
			if water[w].y < pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(water[w], {name="vlc_blackstone:basalt"})
			elseif lavatype == "flowing" and water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z) then
				minetest.set_node(pos, {name="vlc_blackstone:basalt"})
			elseif lavatype == "flowing" and water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(pos, {name="vlc_blackstone:basalt"})
			end
		end
	end,
})

minetest.register_abm({
	label = "Lava cooling (blackstone)",
	nodenames = {"group:lava"},
	neighbors = {"vlc_core:packed_ice"},
	interval = 1,
	chance = 1,
	min_y = vlc_vars.mg_end_min,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local water = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+1, z=pos.z+1}, "vlc_core:packed_ice")
		local lavatype = minetest.registered_nodes[node.name].liquidtype
		for w=1, #water do
			if water[w].y < pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(water[w], {name="vlc_blackstone:blackstone"})
			elseif lavatype == "flowing" and water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z) then
				minetest.set_node(pos, {name="vlc_blackstone:blackstone"})
			elseif lavatype == "flowing" and water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(pos, {name="vlc_blackstone:blackstone"})
			end
		end
	end,
})

--crafting
minetest.register_craft({
	output = "vlc_blackstone:blackstone_polished 4",
	recipe = {
		{"vlc_blackstone:blackstone", "vlc_blackstone:blackstone"},
		{"vlc_blackstone:blackstone", "vlc_blackstone:blackstone"},
	}
})
minetest.register_craft({
	output = "vlc_blackstone:basalt_polished 4",
	recipe = {
		{"vlc_blackstone:basalt", "vlc_blackstone:basalt"},
		{"vlc_blackstone:basalt", "vlc_blackstone:basalt"},
	}
})
minetest.register_craft({
	output = "vlc_blackstone:blackstone_chiseled_polished 2",
	recipe = {
		{"vlc_blackstone:blackstone_polished"},
		{"vlc_blackstone:blackstone_polished"},
	}
})
minetest.register_craft({
	output = "vlc_blackstone:blackstone_brick_polished 4",
	recipe = {
		{"vlc_blackstone:blackstone_polished", "vlc_blackstone:blackstone_polished"},
		{"vlc_blackstone:blackstone_polished", "vlc_blackstone:blackstone_polished"},
	}
})
minetest.register_craft({
	output = "vlc_blackstone:quartz_brick 4",
	recipe = {
		{"vlc_nether:quartz_block", "vlc_nether:quartz_block"},
		{"vlc_nether:quartz_block", "vlc_nether:quartz_block"},
	}
})
minetest.register_craft({
	type = "cooking",
	output = "vlc_core:gold_ingot",
	recipe = "vlc_blackstone:nether_gold",
	cooktime = 10,
})
minetest.register_craft({
	type = "cooking",
	output = "vlc_core:gold_ingot",
	recipe = "vlc_blackstone:blackstone_gilded",
	cooktime = 10,
})
minetest.register_craft({
	type = "cooking",
	output = "vlc_nether:quartz_smooth",
	recipe = "vlc_nether:quartz_block",
	cooktime = 10,
})
--[[ Commented out for now because there the discussion how to handle this is ongoing]
--Generating
local specialstones = { "vlc_blackstone:blackstone", "vlc_blackstone:basalt", "vlc_blackstone:soul_soil" }
for s=1, #specialstones do
	local node = specialstones[s]
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"vlc_nether:netherrack"},
		clust_scarcity = 830,
		clust_num_ores = 28,
		clust_size     = 3,
		y_min          = vlc_vars.mg_nether_min,
		y_max          = vlc_vars.mg_nether_max,
	})
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"vlc_nether:netherrack"},
		clust_scarcity = 8*8*8,
		clust_num_ores = 40,
		clust_size     = 5,
		y_min          = vlc_vars.mg_nether_min,
		y_max          = vlc_vars.mg_nether_max,
	})
end

if minetest.settings:get_bool("vlc_generate_ores", true) then

end
--]]
--soul torch
vlc_torches.register_torch({
	name="soul_torch",
	description=S("Soul Torch"),
	doc_items_longdesc = S("Torches are light sources which can be placed at the side or on the top of most blocks."),
	doc_items_hidden = false,
	icon="soul_torch_on_floor.png",
	tiles = {{
		name = "soul_torch_on_floor_animated.png",
		animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
	}},
	light = 12, --soul torches are a bit dimmer than normal torches
	groups = {dig_immediate = 3, deco_block = 1},
	sounds = vlc_sounds.node_sound_wood_defaults(),
	particles = true,
	flame_type = 2,
})

minetest.register_craft({
	output = "vlc_blackstone:soul_torch 4",
	recipe = {
		{"group:coal"},
		{ "vlc_core:stick" },
		{ "group:soul_block" },
	}
})
