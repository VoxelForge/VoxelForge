local S = minetest.get_translator(minetest.get_current_modname())

local mod_screwdriver = minetest.get_modpath("screwdriver")
local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_3way
end

minetest.register_node("vlf_nether:glowstone", {
	description = S("Glowstone"),
	_doc_items_longdesc = S("Glowstone is a naturally-glowing block which is home to the Nether."),
	tiles = {"vlf_nether_glowstone.png"},
	groups = {handy=1,building_block=1, material_glass=1},
	drop = {
	max_items = 1,
	items = {
			{items = {"vlf_nether:glowstone_dust 4"}, rarity = 3},
			{items = {"vlf_nether:glowstone_dust 3"}, rarity = 3},
			{items = {"vlf_nether:glowstone_dust 2"}},
		}
	},
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	sounds = vlf_sounds.node_sound_glass_defaults(),
	_vlf_blast_resistance = 0.3,
	_vlf_hardness = 0.3,
	_vlf_silk_touch_drop = true,
	_vlf_fortune_drop = {
		discrete_uniform_distribution = true,
		items = {"vlf_nether:glowstone_dust"},
		min_count = 2,
		max_count = 4,
		cap = 4,
	}
})

minetest.register_node("vlf_nether:quartz_ore", {
	description = S("Nether Quartz Ore"),
	_doc_items_longdesc = S("Nether quartz ore is an ore containing nether quartz. It is commonly found around netherrack in the Nether."),
	tiles = {"vlf_nether_quartz_ore.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, xp=3},
	drop = "vlf_nether:quartz",
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 3,
	_vlf_hardness = 3,
	_vlf_silk_touch_drop = true,
	_vlf_fortune_drop = vlf_core.fortune_drop_ore
})

minetest.register_node("vlf_nether:ancient_debris", {
	description = S("Ancient Debris"),
	_doc_items_longdesc = S("Ancient debris can be found in the nether and is very very rare."),
	tiles = {"vlf_nether_ancient_debris_top.png", "vlf_nether_ancient_debris_side.png"},
	groups = {pickaxey=4, building_block=1, material_stone=1, xp=0, blast_furnace_smeltable = 1},
	drop = "vlf_nether:ancient_debris",
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 1200,
	_vlf_hardness = 30,
	_vlf_silk_touch_drop = true
})

minetest.register_node("vlf_nether:netheriteblock", {
	description = S("Netherite Block"),
	_doc_items_longdesc = S("Netherite block is very hard and can be made of 9 netherite ingots."),
	tiles = {"vlf_nether_netheriteblock.png"},
	is_ground_content = false,
	groups = { pickaxey=4, building_block=1, material_stone=1, xp = 0, fire_immune=1 },
	drop = "vlf_nether:netheriteblock",
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 1200,
	_vlf_hardness = 50,
	_vlf_silk_touch_drop = true,
})

-- For eternal fire on top of netherrack and magma blocks
-- (this code does not require a dependency on vlf_fire)
local function eternal_after_destruct(pos, oldnode)
	pos.y = pos.y + 1
	if minetest.get_node(pos).name == "vlf_fire:eternal_fire" then
		minetest.remove_node(pos)
	end
end

local function eternal_on_ignite(player, pointed_thing)
	local pos = pointed_thing.under
	local flame_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
	local fn = minetest.get_node(flame_pos)
	local pname = player:get_player_name()
	if minetest.is_protected(flame_pos, pname) then
		minetest.record_protection_violation(flame_pos, pname)
		return
	end
	if fn.name == "air" and pointed_thing.under.y < pointed_thing.above.y then
		minetest.set_node(flame_pos, {name = "vlf_fire:eternal_fire"})
		return true
	else
		return false
	end
end

minetest.register_node("vlf_nether:netherrack", {
	description = S("Netherrack"),
	_doc_items_longdesc = S("Netherrack is a stone-like block home to the Nether. Starting a fire on this block will create an eternal fire."),
	tiles = {"vlf_nether_netherrack.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, enderman_takable=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 0.4,
	_vlf_hardness = 0.4,

	-- Eternal fire on top
	after_destruct = eternal_after_destruct,
	_on_ignite = eternal_on_ignite,
	_on_bone_meal = function(itemstack,placer,pt,pos,node)
		local n = minetest.find_node_near(pos,1,{"vlf_crimson:warped_nylium","vlf_crimson:crimson_nylium"})
		if n then
			minetest.set_node(pos,minetest.get_node(n))
		end
	end,
})

minetest.register_node("vlf_nether:magma", {
	description = S("Magma Block"),
	_tt_help = minetest.colorize(vlf_colors.YELLOW, S("Burns your feet")),
	_doc_items_longdesc = S("Magma blocks are hot solid blocks which hurt anyone standing on it, unless they have fire resistance. Starting a fire on this block will create an eternal fire."),
	tiles = {{name="vlf_nether_magma.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=1.5}}},
	light_source = 3,
	groups = {pickaxey=1, building_block=1, material_stone=1, fire=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	-- From walkover mod
	on_walk_over = function(loc, nodeiamon, player)
		local armor_feet = player:get_inventory():get_stack("armor", 5)
		if player and player:get_player_control().sneak or (minetest.global_exists("mcl_enchanting") and mcl_enchanting.has_enchantment(armor_feet, "frost_walker")) or (minetest.global_exists("mcl_potions") and mcl_potions.has_effect(player, "fire_resistance")) then
			return
		end
		-- Hurt players standing on top of this block
		if player:get_hp() > 0 then
			vlf_util.deal_damage(player, 1, {type = "hot_floor"})
		end
	end,
	_vlf_blast_resistance = 0.5,
	_vlf_hardness = 0.5,

	-- Eternal fire on top
	after_destruct = eternal_after_destruct,
	_on_ignite = eternal_on_ignite,
})

minetest.register_node("vlf_nether:soul_sand", {
	description = S("Soul Sand"),
	_tt_help = S("Reduces walking speed"),
	_doc_items_longdesc = S("Soul sand is a block from the Nether. One can only slowly walk on soul sand. The slowing effect is amplified when the soul sand is on top of ice, packed ice or a slime block."),
	tiles = {"vlf_nether_soul_sand.png"},
	groups = {handy = 1, shovely = 1, building_block = 1, soil_nether_wart = 1, material_sand = 1, soul_block = 1 },
	collision_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, 0.5 - 2/16, 0.5 },
	},
	sounds = vlf_sounds.node_sound_sand_defaults(),
	_vlf_blast_resistance = 0.5,
	_vlf_hardness = 0.5,
})

vlf_player.register_globalstep_slow(function(player, dtime)
	-- Standing on soul sand or soul soil?
	if minetest.get_item_group(vlf_player.players[player].nodes.stand, "soul_block") > 0 then
		-- TODO: Tweak walk speed
		-- TODO: Also slow down mobs
		local boots = player:get_inventory():get_stack("armor", 5)
		local soul_speed = vlf_enchanting.get_enchantment(boots, "soul_speed")
		-- If player wears Soul Speed boots, increase speed
		if soul_speed > 0 then
			playerphysics.add_physics_factor(player, "speed", "vlf_playerplus:soul_sand", soul_speed * 0.105 + 1.3)
		-- otherwise walk slower on soul sand
		elseif vlf_player.players[player].nodes.stand == "vlf_nether:soul_sand" then
			playerphysics.add_physics_factor(player, "speed", "vlf_playerplus:soul_sand", 0.4)
		else
			playerphysics.remove_physics_factor(player, "speed", "vlf_playerplus:soul_sand")
		end
	else
		playerphysics.remove_physics_factor(player, "speed", "vlf_playerplus:soul_sand")
	end
end)

local nether_brick = {
	description = S("Nether Brick Block"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"vlf_nether_nether_brick.png"},
	is_ground_content = false,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 6,
	_vlf_hardness = 2,
}

minetest.register_node("vlf_nether:nether_brick", table.merge(nether_brick,{
	groups = {pickaxey=1, building_block=1, material_stone=1, stonecuttable = 1},
}))

minetest.register_node("vlf_nether:red_nether_brick", table.merge(nether_brick,{
	description = S("Red Nether Brick Block"),
	tiles = {"vlf_nether_red_nether_brick.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, stonecuttable = 1},
}))

local chiseled_nether_brick = table.copy(nether_brick)
chiseled_nether_brick.description = S("Chiseled Nether Brick Block")
chiseled_nether_brick.tiles = {"vlf_nether_chiseled_nether_bricks.png"}
minetest.register_node("vlf_nether:chiseled_nether_brick", chiseled_nether_brick)

local cracked_nether_brick = table.copy(nether_brick)
cracked_nether_brick.description = S("Cracked Nether Bricks")
cracked_nether_brick.tiles = {"vlf_nether_cracked_nether_bricks.png"}
minetest.register_node("vlf_nether:cracked_nether_brick", cracked_nether_brick)

minetest.register_node("vlf_nether:nether_wart_block", {
	description = S("Nether Wart Block"),
	_doc_items_longdesc = S("A nether wart block is a purely decorative block made from nether wart."),
	tiles = {"vlf_nether_nether_wart_block.png"},
	is_ground_content = false,
	groups = {handy=1, hoey=7, swordy=1, building_block=1, compostability = 85},
	sounds = vlf_sounds.node_sound_leaves_defaults(
		{
			footstep={name="default_dirt_footstep", gain=0.7},
			dug={name="default_dirt_footstep", gain=1.5},
		}
	),
	_vlf_blast_resistance = 1,
	_vlf_hardness = 1,
})

minetest.register_node("vlf_nether:quartz_block", {
	description = S("Block of Quartz"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	is_ground_content = false,
	tiles = {"vlf_nether_quartz_block_top.png", "vlf_nether_quartz_block_bottom.png", "vlf_nether_quartz_block_side.png"},
	groups = {pickaxey=1, quartz_block=1,building_block=1, material_stone=1, stonecuttable = 1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 0.8,
	_vlf_hardness = 0.8,
})

minetest.register_node("vlf_nether:quartz_chiseled", {
	description = S("Chiseled Quartz Block"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	is_ground_content = false,
	tiles = {"vlf_nether_quartz_chiseled_top.png", "vlf_nether_quartz_chiseled_top.png", "vlf_nether_quartz_chiseled_side.png"},
	groups = {pickaxey=1, quartz_block=1,building_block=1, material_stone=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 0.8,
	_vlf_hardness = 0.8,
	_vlf_stonecutter_recipes = { "vlf_nether:quartz_block" },
})

minetest.register_node("vlf_nether:quartz_pillar", {
	description = S("Pillar Quartz Block"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = vlf_util.rotate_axis,
	tiles = {"vlf_nether_quartz_pillar_top.png", "vlf_nether_quartz_pillar_top.png", "vlf_nether_quartz_pillar_side.png"},
	groups = {pickaxey=1, quartz_block=1,building_block=1, material_stone=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	on_rotate = on_rotate,
	_vlf_blast_resistance = 0.8,
	_vlf_hardness = 0.8,
	_vlf_stonecutter_recipes = { "vlf_nether:quartz_block" },
})
minetest.register_node("vlf_nether:quartz_smooth", {
	description = S("Smooth Quartz"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	is_ground_content = false,
	tiles = {"vlf_nether_quartz_block_bottom.png"},
	groups = {pickaxey=1, quartz_block=1,building_block=1, material_stone=1, stonecuttable = 1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 0.8,
	_vlf_hardness = 0.8,
	_vlf_stonecutter_recipes = { "vlf_nether:quartz_block" },
})


vlf_stairs.register_stair_and_slab("quartzblock", {
	baseitem = "vlf_nether:quartz_block",
	description_stair = S("Quartz Stairs"),
	description_slab = S("Quartz Slab"),
	recipeitem = "group:quartz_block",
	overrides = {_vlf_stonecutter_recipes = {"vlf_nether:quartz_block"}},
})

vlf_stairs.register_stair_and_slab("quartz_smooth", {
	baseitem = "vlf_nether:quartz_smooth",
	description_stair = S("Smooth Quartz Stairs"),
	description_slab = S("Smooth Quartz Slab"),
	recipeitem = "vlf_nether:quartz_smooth",
	overrides = {_vlf_stonecutter_recipes = {"vlf_nether:quartz_smooth"}},
})

vlf_stairs.register_stair_and_slab("nether_brick", {
	baseitem = "vlf_nether:nether_brick",
	description_stair = S("Nether Brick Stairs"),
	description_slab = S("Nether Brick Slab"),
	overrides = {_vlf_stonecutter_recipes = { "vlf_nether:nether_brick" }},{_vlf_stonecutter_recipes = { "vlf_nether:nether_brick" }},
})
vlf_stairs.register_stair_and_slab("red_nether_brick", {
	baseitem = "vlf_nether:red_nether_brick",
	description_stair = S("Red Nether Brick Stairs"),
	description_slab = S("Red Nether Brick Slab"),
	overrides = {_vlf_stonecutter_recipes = { "vlf_nether:red_nether_brick" }},{_vlf_stonecutter_recipes = { "vlf_nether:red_nether_brick" }},
})

-- Nether Brick Fence (without fence gate!)
vlf_fences.register_fence("nether_brick_fence", S("Nether Brick Fence"), "vlf_fences_fence_nether_brick.png", {pickaxey=1, deco_block=1, fence_nether_brick=1}, 2, 30, {"group:fence_nether_brick"}, vlf_sounds.node_sound_stone_defaults())


minetest.register_craftitem("vlf_nether:glowstone_dust", {
	description = S("Glowstone Dust"),
	_doc_items_longdesc = S("Glowstone dust is the dust which comes out of broken glowstones. It is mainly used in crafting."),
	inventory_image = "vlf_nether_glowstone_dust.png",
	groups = { craftitem=1, brewitem=1 },
})

minetest.register_craftitem("vlf_nether:quartz", {
	description = S("Nether Quartz"),
	_doc_items_longdesc = S("Nether quartz is a versatile crafting ingredient."),
	inventory_image = "vlf_nether_quartz.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("vlf_nether:netherite_scrap", {
	description = S("Netherite Scrap"),
	_doc_items_longdesc = S("Netherite scrap is a crafting ingredient for netherite ingots."),
	inventory_image = "vlf_nether_netherite_scrap.png",
	groups = { craftitem = 1, fire_immune=1 },
})

minetest.register_craftitem("vlf_nether:netherite_ingot", {
	description = S("Netherite Ingot"),
	_doc_items_longdesc = S("Netherite ingots can be used with a smithing table to upgrade items to netherite."),
	inventory_image = "vlf_nether_netherite_ingot.png",
	groups = { craftitem = 1, fire_immune=1 },
})

minetest.register_craftitem("vlf_nether:netherbrick", {
	description = S("Nether Brick"),
	_doc_items_longdesc = S("Nether bricks are the main crafting ingredient for crafting nether brick blocks and nether fences."),
	inventory_image = "vlf_nether_netherbrick.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("vlf_nether:netherite_upgrade_template", {
	description	  = S("Netherite Upgrade Template"),
	--_tt_help = S("Netherite Upgrade Template").."\n\n"..
	minetest.colorize(vlf_colors.GRAY, S("Applies to:")).."\n"..minetest.colorize(vlf_colors.BLUE, " "..S("Diamond Armor")).."\n"..
	minetest.colorize(vlf_colors.BLUE, " "..S("Diamond Tools")).."\n"..
	minetest.colorize(vlf_colors.GRAY, S("Ingredients:")).."\n"..minetest.colorize(vlf_colors.BLUE, " "..S("Netherite Ingot")),
	inventory_image  = "vlf_nether_netherite_ugrade_template.png",
	groups = { upgrade_template  = 1 },
})

minetest.register_craft({
    output = "vlf_nether:netherite_upgrade_template 2",
    recipe = {
        {"vlf_core:diamond", "vlf_nether:netherite_upgrade_template","vlf_core:diamond"},
        {"vlf_core:diamond", "vlf_nether:netherrack","vlf_core:diamond"},
        {"vlf_core:diamond","vlf_core:diamond","vlf_core:diamond"},
    }
})

minetest.register_craft({
	output = "vlf_fences:nether_brick_fence 6",
	recipe = {
		{"vlf_nether:nether_brick", "vlf_nether:netherbrick", "vlf_nether:nether_brick"},
		{"vlf_nether:nether_brick", "vlf_nether:netherbrick", "vlf_nether:nether_brick"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:fence_wood",
	burntime = 15,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_nether:quartz",
	recipe = "vlf_nether:quartz_ore",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_nether:netherite_scrap",
	recipe = "vlf_nether:ancient_debris",
	cooktime = 10,
})

minetest.register_craft({
	output = "vlf_nether:quartz_block",
	recipe = {
		{"vlf_nether:quartz", "vlf_nether:quartz"},
		{"vlf_nether:quartz", "vlf_nether:quartz"},
	}
})

minetest.register_craft({
	output = "vlf_nether:quartz_pillar 2",
	recipe = {
		{"vlf_nether:quartz_block"},
		{"vlf_nether:quartz_block"},
	}
})

minetest.register_craft({
	output = "vlf_nether:glowstone",
	recipe = {
		{"vlf_nether:glowstone_dust", "vlf_nether:glowstone_dust"},
		{"vlf_nether:glowstone_dust", "vlf_nether:glowstone_dust"},
	}
})

minetest.register_craft({
	output = "vlf_nether:magma",
	recipe = {
		{"vlf_mobitems:magma_cream", "vlf_mobitems:magma_cream"},
		{"vlf_mobitems:magma_cream", "vlf_mobitems:magma_cream"},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_nether:netherbrick",
	recipe = "vlf_nether:netherrack",
	cooktime = 10,
})

minetest.register_craft({
	output = "vlf_nether:nether_brick",
	recipe = {
		{"vlf_nether:netherbrick", "vlf_nether:netherbrick"},
		{"vlf_nether:netherbrick", "vlf_nether:netherbrick"},
	}
})

minetest.register_craft({
	output = "vlf_nether:red_nether_brick",
	recipe = {
		{"vlf_nether:nether_wart_item", "vlf_nether:netherbrick"},
		{"vlf_nether:netherbrick", "vlf_nether:nether_wart_item"},
	}
})
minetest.register_craft({
	output = "vlf_nether:red_nether_brick",
	recipe = {
		{"vlf_nether:netherbrick", "vlf_nether:nether_wart_item"},
		{"vlf_nether:nether_wart_item", "vlf_nether:netherbrick"},
	}
})

minetest.register_craft({
	output = "vlf_nether:chiseled_nether_brick",
	recipe = {
		{"vlf_stairs:netherbrick_slab"},
		{"vlf_stairs:netherbrick_slab"},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:cracked_nether_brick",
	recipe = "vlf_core:netherbrick",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_nether:quartz_smooth",
	recipe = "vlf_nether:quartz_block",
	cooktime = 10,
})

minetest.register_craft({
	output = "vlf_nether:nether_wart_block",
	recipe = {
		{"vlf_nether:nether_wart_item", "vlf_nether:nether_wart_item", "vlf_nether:nether_wart_item"},
		{"vlf_nether:nether_wart_item", "vlf_nether:nether_wart_item", "vlf_nether:nether_wart_item"},
		{"vlf_nether:nether_wart_item", "vlf_nether:nether_wart_item", "vlf_nether:nether_wart_item"},
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_nether:netherite_ingot",
	recipe = {
		"vlf_nether:netherite_scrap", "vlf_nether:netherite_scrap", "vlf_nether:netherite_scrap",
		"vlf_nether:netherite_scrap", "vlf_core:gold_ingot", "vlf_core:gold_ingot",
		"vlf_core:gold_ingot", "vlf_core:gold_ingot", },
})

minetest.register_craft({
	output = "vlf_nether:netheriteblock",
	recipe = {
		{"vlf_nether:netherite_ingot", "vlf_nether:netherite_ingot", "vlf_nether:netherite_ingot"},
		{"vlf_nether:netherite_ingot", "vlf_nether:netherite_ingot", "vlf_nether:netherite_ingot"},
		{"vlf_nether:netherite_ingot", "vlf_nether:netherite_ingot", "vlf_nether:netherite_ingot"}
	}
})

minetest.register_craft({
	output = "vlf_nether:netherite_ingot 9",
	recipe = {
		{"vlf_nether:netheriteblock", "", ""},
		{"", "", ""},
		{"", "", ""}
	}
})

dofile(minetest.get_modpath(minetest.get_current_modname()).."/nether_wart.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lava.lua")
