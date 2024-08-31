local S = minetest.get_translator("vlf_blackstone")


local on_rotate
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.rotate_3way
end

--Blocks
minetest.register_node("vlf_blackstone:blackstone", {
	description = S("Blackstone"),
	tiles = {"vlf_blackstone_top.png", "vlf_blackstone_top.png", "vlf_blackstone_side.png"},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1, cobble=1, stonecuttable = 1},
	_vlf_blast_resistance = 6,
	_vlf_hardness = 1.5,
})
minetest.register_node("vlf_blackstone:blackstone_gilded", {
	description = S("Gilded Blackstone"),
	tiles = {"vlf_blackstone_gilded.png"},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1, xp=1},
	drop = {
		max_items = 1,
		items = {
			{items = {"vlf_core:gold_nugget 2"},rarity = 40},
			{items = {"vlf_core:gold_nugget 3"},rarity = 40},
			{items = {"vlf_core:gold_nugget 4"},rarity = 40},
			{items = {"vlf_core:gold_nugget 5"},rarity = 40},
			-- 4x 1 in 40 chance adds up to a 10% chance
			{items = {"vlf_blackstone:blackstone_gilded"}, rarity = 1},
		}
	},
	_vlf_blast_resistance = 2,
	_vlf_hardness = 2,
	_vlf_silk_touch_drop = true,
	_vlf_fortune_drop = {
		discrete_uniform_distribution = true,
		items = {"vlf_core:gold_nugget"},
		min_count = 2,
		max_count = 5,
		cap = 5,
	},
})
minetest.register_node("vlf_blackstone:nether_gold", {
	description = S("Nether Gold Ore"),
	tiles = {"vlf_nether_gold_ore.png"},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1, xp=1},
	drop = {
		max_items = 1,
		items = {
			{items = {"vlf_core:gold_nugget 6"},rarity = 5},
			{items = {"vlf_core:gold_nugget 5"},rarity = 5},
			{items = {"vlf_core:gold_nugget 4"},rarity = 5},
			{items = {"vlf_core:gold_nugget 3"},rarity = 5},
			{items = {"vlf_core:gold_nugget 2"},rarity = 1},
		}
	},
	_vlf_blast_resistance = 3,
	_vlf_hardness = 3,
	_vlf_silk_touch_drop = true,
	_vlf_fortune_drop = vlf_core.fortune_drop_ore,
})
minetest.register_node("vlf_blackstone:basalt_polished", {
	description = S("Polished Basalt"),
	tiles = {"vlf_blackstone_basalt_top_polished.png", "vlf_blackstone_basalt_top_polished.png", "vlf_blackstone_basalt_side_polished.png"},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	on_place = vlf_util.rotate_axis,
	on_rotate = on_rotate,
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1},
	_vlf_blast_resistance = 4.2,
	_vlf_hardness = 1.25,
})
minetest.register_node("vlf_blackstone:basalt", {
	description = S("Basalt"),
	tiles = {"vlf_blackstone_basalt_top.png", "vlf_blackstone_basalt_top.png", "vlf_blackstone_basalt_side.png"},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	on_place = vlf_util.rotate_axis,
	on_rotate = on_rotate,
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1, stonecuttable = 1},
	_vlf_blast_resistance = 4.2,
	_vlf_hardness = 1.25,
})
minetest.register_node("vlf_blackstone:basalt_smooth", {
	description = S("Smooth Basalt"),
	tiles = {"vlf_blackstone_basalt_smooth.png"},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1},
	_vlf_blast_resistance = 4.2,
	_vlf_hardness = 1.25,
	_vlf_stonecutter_recipes = {"vlf_blackstone:basalt"},
})
minetest.register_node("vlf_blackstone:blackstone_polished", {
	description = S("Polished Blackstone"),
	tiles = {"vlf_blackstone_polished.png"},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1, stonecuttable = 1},
	_vlf_blast_resistance = 6,
	_vlf_hardness = 2,
	_vlf_stonecutter_recipes = {"vlf_blackstone:blackstone"},
})
minetest.register_node("vlf_blackstone:blackstone_chiseled_polished", {
	description = S("Chiseled Polished Blackstone"),
	tiles = {"vlf_blackstone_chiseled_polished.png"},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1},
	_vlf_blast_resistance = 6,
	_vlf_hardness = 1.5,
	_vlf_stonecutter_recipes = {"vlf_blackstone:blackstone", "vlf_blackstone:blackstone_polished"},
})
minetest.register_node("vlf_blackstone:blackstone_brick_polished", {
	description = S("Polished Blackstone Bricks"),
	tiles = {"vlf_blackstone_polished_bricks.png"},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	groups = {cracky = 3, pickaxey=1, material_stone=1},
	_vlf_blast_resistance = 6,
	_vlf_hardness = 1.5,
	_vlf_stonecutter_recipes = {"vlf_blackstone:blackstone", "vlf_blackstone:blackstone_polished"},
})
minetest.register_node("vlf_blackstone:quartz_brick", {
	description = S("Quartz Bricks"),
	tiles = {"vlf_backstone_quartz_bricks.png"},
	is_ground_content = false,
	sounds = vlf_sounds.node_sound_stone_defaults(),
	groups = {cracky = 3, pickaxey=1, material_stone=1},
	_vlf_blast_resistance = 0.8,
	_vlf_hardness = 0.8,
})
minetest.register_node("vlf_blackstone:soul_soil", {
	description = S("Soul Soil"),
	tiles = {"vlf_blackstone_soul_soil.png"},
	is_ground_content = false,
	sounds = vlf_sounds.node_sound_sand_defaults(),
	groups = { cracky=3, handy=1, shovely=1, soul_block=1, soil_fungus=1 },
	_vlf_blast_resistance = 0.5,
	_vlf_hardness = 0.5,
})
minetest.register_node("vlf_blackstone:soul_fire", {
	description = S("Eternal Soul Fire"),
	_doc_items_longdesc = minetest.registered_nodes["vlf_fire:eternal_fire"]._doc_items_longdesc ,
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
	_vlf_node_death_message = minetest.registered_nodes["vlf_fire:fire"]._vlf_node_death_message,
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

local old_onconstruct=minetest.registered_nodes["vlf_fire:fire"].on_construct
minetest.registered_nodes["vlf_fire:fire"].on_construct=function(pos)
	local under = minetest.get_node(vector.offset(pos,0,-1,0)).name
	if minetest.get_item_group(under, "soul_block") > 0 then
		minetest.swap_node(pos, {name = "vlf_blackstone:soul_fire"})
	end
	old_onconstruct(pos)
end

--slabs/stairs
vlf_stairs.register_stair_and_slab("blackstone", {
	baseitem = "vlf_blackstone:blackstone",
	description_stair = S("Blackstone Stairs"),
	description_slab = S("Blackstone Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_blackstone:blackstone"}}, {_vlf_stonecutter_recipes = {"vlf_blackstone:blackstone"}}
})
vlf_stairs.register_stair_and_slab("blackstone_polished", {
	baseitem = "vlf_blackstone:blackstone_polished",
	description_stair = S("Polished Blackstone Stairs"),
	description_slab = S("Polished Blackstone Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_blackstone:blackstone", "vlf_blackstone:blackstone_polished"}}, {_vlf_stonecutter_recipes = {"vlf_blackstone:blackstone", "vlf_blackstone:blackstone_polished"}}
})
vlf_stairs.register_stair_and_slab("blackstone_brick_polished", {
	baseitem = "vlf_blackstone:blackstone_brick_polished",
	description_stair = S("Blackstone Brick Stairs"),
	description_slab = S("Blackstone Brick Slab"),
	overrides = {_vlf_stonecutter_recipes = {"vlf_blackstone:blackstone", "vlf_blackstone:blackstone_polished"}}, {_vlf_stonecutter_recipes = {"vlf_blackstone:blackstone", "vlf_blackstone:blackstone_polished"}}
})
minetest.register_alias("vlf_stairs:slab_blackstone_chiseled_polished_top", "vlf_stairs:slab_blackstone_polished_top")
minetest.register_alias("vlf_stairs:slab_blackstone_chiseled_polished", "vlf_stairs:slab_blackstone_polished")
minetest.register_alias("vlf_stairs:slab_blackstone_chiseled_polished_double", "vlf_stairs:slab_blackstone_polished_double")
minetest.register_alias("vlf_stairs:stair_blackstone_chiseled_polished", "vlf_stairs:stair_blackstone_polished")
minetest.register_alias("vlf_stairs:stair_blackstone_chiseled_polished_inner", "vlf_stairs:stair_blackstone_polished_inner")
minetest.register_alias("vlf_stairs:stair_blackstone_chiseled_polished_outer", "vlf_stairs:stair_blackstone_polished_outer")

--Wall
vlf_walls.register_wall_def("vlf_blackstone:wall", {
	description = S("Blackstone Wall"),
	source = "vlf_blackstone:blackstone",
	_vlf_stonecutter_recipes = {"vlf_blackstone:blackstone"},
})

--lavacooling

minetest.register_abm({
	label = "Lava cooling (basalt)",
	nodenames = {"group:lava"},
	neighbors = {"vlf_core:ice"},
	interval = 1,
	chance = 1,
	min_y = vlf_vars.mg_end_min,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local water = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+1, z=pos.z+1}, "vlf_core:ice")
		local lavatype = minetest.registered_nodes[node.name].liquidtype
		for w=1, #water do
			if water[w].y < pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(water[w], {name="vlf_blackstone:basalt"})
			elseif lavatype == "flowing" and water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z) then
				minetest.set_node(pos, {name="vlf_blackstone:basalt"})
			elseif lavatype == "flowing" and water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(pos, {name="vlf_blackstone:basalt"})
			end
		end
	end,
})

minetest.register_abm({
	label = "Lava cooling (blackstone)",
	nodenames = {"group:lava"},
	neighbors = {"vlf_core:packed_ice"},
	interval = 1,
	chance = 1,
	min_y = vlf_vars.mg_end_min,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local water = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+1, z=pos.z+1}, "vlf_core:packed_ice")
		local lavatype = minetest.registered_nodes[node.name].liquidtype
		for w=1, #water do
			if water[w].y < pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(water[w], {name="vlf_blackstone:blackstone"})
			elseif lavatype == "flowing" and water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z) then
				minetest.set_node(pos, {name="vlf_blackstone:blackstone"})
			elseif lavatype == "flowing" and water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(pos, {name="vlf_blackstone:blackstone"})
			end
		end
	end,
})

--crafting
minetest.register_craft({
	output = "vlf_blackstone:blackstone_polished 4",
	recipe = {
		{"vlf_blackstone:blackstone", "vlf_blackstone:blackstone"},
		{"vlf_blackstone:blackstone", "vlf_blackstone:blackstone"},
	}
})
minetest.register_craft({
	output = "vlf_blackstone:basalt_polished 4",
	recipe = {
		{"vlf_blackstone:basalt", "vlf_blackstone:basalt"},
		{"vlf_blackstone:basalt", "vlf_blackstone:basalt"},
	}
})
minetest.register_craft({
	output = "vlf_blackstone:blackstone_chiseled_polished 2",
	recipe = {
		{"vlf_blackstone:blackstone_polished"},
		{"vlf_blackstone:blackstone_polished"},
	}
})
minetest.register_craft({
	output = "vlf_blackstone:blackstone_brick_polished 4",
	recipe = {
		{"vlf_blackstone:blackstone_polished", "vlf_blackstone:blackstone_polished"},
		{"vlf_blackstone:blackstone_polished", "vlf_blackstone:blackstone_polished"},
	}
})
minetest.register_craft({
	output = "vlf_blackstone:quartz_brick 4",
	recipe = {
		{"vlf_nether:quartz_block", "vlf_nether:quartz_block"},
		{"vlf_nether:quartz_block", "vlf_nether:quartz_block"},
	}
})
minetest.register_craft({
	type = "cooking",
	output = "vlf_core:gold_ingot",
	recipe = "vlf_blackstone:nether_gold",
	cooktime = 10,
})
minetest.register_craft({
	type = "cooking",
	output = "vlf_core:gold_ingot",
	recipe = "vlf_blackstone:blackstone_gilded",
	cooktime = 10,
})
minetest.register_craft({
	type = "cooking",
	output = "vlf_nether:quartz_smooth",
	recipe = "vlf_nether:quartz_block",
	cooktime = 10,
})
--[[ Commented out for now because there the discussion how to handle this is ongoing]
--Generating
local specialstones = { "vlf_blackstone:blackstone", "vlf_blackstone:basalt", "vlf_blackstone:soul_soil" }
for s=1, #specialstones do
	local node = specialstones[s]
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"vlf_nether:netherrack"},
		clust_scarcity = 830,
		clust_num_ores = 28,
		clust_size     = 3,
		y_min          = vlf_vars.mg_nether_min,
		y_max          = vlf_vars.mg_nether_max,
	})
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"vlf_nether:netherrack"},
		clust_scarcity = 8*8*8,
		clust_num_ores = 40,
		clust_size     = 5,
		y_min          = vlf_vars.mg_nether_min,
		y_max          = vlf_vars.mg_nether_max,
	})
end

if minetest.settings:get_bool("vlf_generate_ores", true) then

end
--]]
--soul torch
vlf_torches.register_torch({
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
	sounds = vlf_sounds.node_sound_wood_defaults(),
	particles = true,
	flame_type = 2,
})

minetest.register_craft({
	output = "vlf_blackstone:soul_torch 4",
	recipe = {
		{"group:coal"},
		{ "vlf_core:stick" },
		{ "group:soul_block" },
	}
})
