local S = minetest.get_translator(minetest.get_current_modname())

local mod_screwdriver = minetest.get_modpath("screwdriver")
local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_3way
end

minetest.register_node("vlc_nether:glowstone", {
	description = S("Glowstone"),
	_doc_items_longdesc = S("Glowstone is a naturally-glowing block which is home to the Nether."),
	tiles = {"vlc_nether_glowstone.png"},
	groups = {handy=1,building_block=1, material_glass=1},
	drop = {
	max_items = 1,
	items = {
			{items = {"vlc_nether:glowstone_dust 4"}, rarity = 3},
			{items = {"vlc_nether:glowstone_dust 3"}, rarity = 3},
			{items = {"vlc_nether:glowstone_dust 2"}},
		}
	},
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	sounds = vlc_sounds.node_sound_glass_defaults(),
	_vlc_blast_resistance = 0.3,
	_vlc_hardness = 0.3,
	_vlc_silk_touch_drop = true,
	_vlc_fortune_drop = {
		discrete_uniform_distribution = true,
		items = {"vlc_nether:glowstone_dust"},
		min_count = 2,
		max_count = 4,
		cap = 4,
	}
})

minetest.register_node("vlc_nether:quartz_ore", {
	description = S("Nether Quartz Ore"),
	_doc_items_longdesc = S("Nether quartz ore is an ore containing nether quartz. It is commonly found around netherrack in the Nether."),
	tiles = {"vlc_nether_quartz_ore.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, xp=3},
	drop = "vlc_nether:quartz",
	sounds = vlc_sounds.node_sound_stone_defaults(),
	_vlc_blast_resistance = 3,
	_vlc_hardness = 3,
	_vlc_silk_touch_drop = true,
	_vlc_fortune_drop = vlc_core.fortune_drop_ore
})

minetest.register_node("vlc_nether:ancient_debris", {
	description = S("Ancient Debris"),
	_doc_items_longdesc = S("Ancient debris can be found in the nether and is very very rare."),
	tiles = {"vlc_nether_ancient_debris_top.png", "vlc_nether_ancient_debris_side.png"},
	groups = {pickaxey=4, building_block=1, material_stone=1, xp=0, blast_furnace_smeltable = 1},
	drop = "vlc_nether:ancient_debris",
	sounds = vlc_sounds.node_sound_stone_defaults(),
	_vlc_blast_resistance = 1200,
	_vlc_hardness = 30,
	_vlc_silk_touch_drop = true
})

minetest.register_node("vlc_nether:netheriteblock", {
	description = S("Netherite Block"),
	_doc_items_longdesc = S("Netherite block is very hard and can be made of 9 netherite ingots."),
	tiles = {"vlc_nether_netheriteblock.png"},
	is_ground_content = false,
	groups = { pickaxey=4, building_block=1, material_stone=1, xp = 0, fire_immune=1 },
	drop = "vlc_nether:netheriteblock",
	sounds = vlc_sounds.node_sound_stone_defaults(),
	_vlc_blast_resistance = 1200,
	_vlc_hardness = 50,
	_vlc_silk_touch_drop = true,
})

-- For eternal fire on top of netherrack and magma blocks
-- (this code does not require a dependency on vlc_fire)
local function eternal_after_destruct(pos, oldnode)
	pos.y = pos.y + 1
	if minetest.get_node(pos).name == "vlc_fire:eternal_fire" then
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
		minetest.set_node(flame_pos, {name = "vlc_fire:eternal_fire"})
		return true
	else
		return false
	end
end

minetest.register_node("vlc_nether:netherrack", {
	description = S("Netherrack"),
	_doc_items_longdesc = S("Netherrack is a stone-like block home to the Nether. Starting a fire on this block will create an eternal fire."),
	tiles = {"vlc_nether_netherrack.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, enderman_takable=1},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	_vlc_blast_resistance = 0.4,
	_vlc_hardness = 0.4,

	-- Eternal fire on top
	after_destruct = eternal_after_destruct,
	_on_ignite = eternal_on_ignite,
	_on_bone_meal = function(itemstack,placer,pt,pos,node)
		local n = minetest.find_node_near(pos,1,{"vlc_crimson:warped_nylium","vlc_crimson:crimson_nylium"})
		if n then
			minetest.set_node(pos,minetest.get_node(n))
		end
	end,
})

minetest.register_node("vlc_nether:magma", {
	description = S("Magma Block"),
	_tt_help = minetest.colorize(vlc_colors.YELLOW, S("Burns your feet")),
	_doc_items_longdesc = S("Magma blocks are hot solid blocks which hurt anyone standing on it, unless they have fire resistance. Starting a fire on this block will create an eternal fire."),
	tiles = {{name="vlc_nether_magma.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=1.5}}},
	light_source = 3,
	groups = {pickaxey=1, building_block=1, material_stone=1, fire=1},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	-- From walkover mod
	on_walk_over = function(loc, nodeiamon, player)
		local armor_feet = player:get_inventory():get_stack("armor", 5)
		if player and player:get_player_control().sneak or (minetest.global_exists("vlc_enchanting") and vlc_enchanting.has_enchantment(armor_feet, "frost_walker")) or (minetest.global_exists("vlc_potions") and vlc_potions.player_has_effect(player, "fire_proof")) then
			return
		end
		-- Hurt players standing on top of this block
		if player:get_hp() > 0 then
			vlc_util.deal_damage(player, 1, {type = "hot_floor"})
		end
	end,
	_vlc_blast_resistance = 0.5,
	_vlc_hardness = 0.5,

	-- Eternal fire on top
	after_destruct = eternal_after_destruct,
	_on_ignite = eternal_on_ignite,
})

minetest.register_node("vlc_nether:soul_sand", {
	description = S("Soul Sand"),
	_tt_help = S("Reduces walking speed"),
	_doc_items_longdesc = S("Soul sand is a block from the Nether. One can only slowly walk on soul sand. The slowing effect is amplified when the soul sand is on top of ice, packed ice or a slime block."),
	tiles = {"vlc_nether_soul_sand.png"},
	groups = {handy = 1, shovely = 1, building_block = 1, soil_nether_wart = 1, material_sand = 1, soul_block = 1 },
	collision_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, 0.5 - 2/16, 0.5 },
	},
	sounds = vlc_sounds.node_sound_sand_defaults(),
	_vlc_blast_resistance = 0.5,
	_vlc_hardness = 0.5,
})

vlc_player.register_globalstep_slow(function(player, dtime)
	-- Standing on soul sand or soul soil?
	if minetest.get_item_group(vlc_player.players[player].nodes.stand, "soul_block") > 0 then
		-- TODO: Tweak walk speed
		-- TODO: Also slow down mobs
		local boots = player:get_inventory():get_stack("armor", 5)
		local soul_speed = vlc_enchanting.get_enchantment(boots, "soul_speed")
		-- If player wears Soul Speed boots, increase speed
		if soul_speed > 0 then
			playerphysics.add_physics_factor(player, "speed", "vlc_playerplus:soul_sand", soul_speed * 0.105 + 1.3)
		-- otherwise walk slower on soul sand
		elseif vlc_player.players[player].nodes.stand == "vlc_nether:soul_sand" then
			playerphysics.add_physics_factor(player, "speed", "vlc_playerplus:soul_sand", 0.4)
		else
			playerphysics.remove_physics_factor(player, "speed", "vlc_playerplus:soul_sand")
		end
	else
		playerphysics.remove_physics_factor(player, "speed", "vlc_playerplus:soul_sand")
	end
end)

local nether_brick = {
	description = S("Nether Brick Block"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"vlc_nether_nether_brick.png"},
	is_ground_content = false,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	_vlc_blast_resistance = 6,
	_vlc_hardness = 2,
}

minetest.register_node("vlc_nether:nether_brick", table.merge(nether_brick,{
	groups = {pickaxey=1, building_block=1, material_stone=1, stonecuttable = 1},
}))

minetest.register_node("vlc_nether:red_nether_brick", table.merge(nether_brick,{
	description = S("Red Nether Brick Block"),
	tiles = {"vlc_nether_red_nether_brick.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1, stonecuttable = 1},
}))

local chiseled_nether_brick = table.copy(nether_brick)
chiseled_nether_brick.description = S("Chiseled Nether Brick Block")
chiseled_nether_brick.tiles = {"vlc_nether_chiseled_nether_bricks.png"}
minetest.register_node("vlc_nether:chiseled_nether_brick", chiseled_nether_brick)

local cracked_nether_brick = table.copy(nether_brick)
cracked_nether_brick.description = S("Cracked Nether Bricks")
cracked_nether_brick.tiles = {"vlc_nether_cracked_nether_bricks.png"}
minetest.register_node("vlc_nether:cracked_nether_brick", cracked_nether_brick)

minetest.register_node("vlc_nether:nether_wart_block", {
	description = S("Nether Wart Block"),
	_doc_items_longdesc = S("A nether wart block is a purely decorative block made from nether wart."),
	tiles = {"vlc_nether_nether_wart_block.png"},
	is_ground_content = false,
	groups = {handy=1, hoey=7, swordy=1, building_block=1, compostability = 85},
	sounds = vlc_sounds.node_sound_leaves_defaults(
		{
			footstep={name="default_dirt_footstep", gain=0.7},
			dug={name="default_dirt_footstep", gain=1.5},
		}
	),
	_vlc_blast_resistance = 1,
	_vlc_hardness = 1,
})

minetest.register_node("vlc_nether:quartz_block", {
	description = S("Block of Quartz"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	is_ground_content = false,
	tiles = {"vlc_nether_quartz_block_top.png", "vlc_nether_quartz_block_bottom.png", "vlc_nether_quartz_block_side.png"},
	groups = {pickaxey=1, quartz_block=1,building_block=1, material_stone=1, stonecuttable = 1},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	_vlc_blast_resistance = 0.8,
	_vlc_hardness = 0.8,
})

minetest.register_node("vlc_nether:quartz_chiseled", {
	description = S("Chiseled Quartz Block"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	is_ground_content = false,
	tiles = {"vlc_nether_quartz_chiseled_top.png", "vlc_nether_quartz_chiseled_top.png", "vlc_nether_quartz_chiseled_side.png"},
	groups = {pickaxey=1, quartz_block=1,building_block=1, material_stone=1},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	_vlc_blast_resistance = 0.8,
	_vlc_hardness = 0.8,
	_vlc_stonecutter_recipes = { "vlc_nether:quartz_block" },
})

minetest.register_node("vlc_nether:quartz_pillar", {
	description = S("Pillar Quartz Block"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = vlc_util.rotate_axis,
	tiles = {"vlc_nether_quartz_pillar_top.png", "vlc_nether_quartz_pillar_top.png", "vlc_nether_quartz_pillar_side.png"},
	groups = {pickaxey=1, quartz_block=1,building_block=1, material_stone=1},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	on_rotate = on_rotate,
	_vlc_blast_resistance = 0.8,
	_vlc_hardness = 0.8,
	_vlc_stonecutter_recipes = { "vlc_nether:quartz_block" },
})
minetest.register_node("vlc_nether:quartz_smooth", {
	description = S("Smooth Quartz"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	is_ground_content = false,
	tiles = {"vlc_nether_quartz_block_bottom.png"},
	groups = {pickaxey=1, quartz_block=1,building_block=1, material_stone=1, stonecuttable = 1},
	sounds = vlc_sounds.node_sound_stone_defaults(),
	_vlc_blast_resistance = 0.8,
	_vlc_hardness = 0.8,
	_vlc_stonecutter_recipes = { "vlc_nether:quartz_block" },
})


vlc_stairs.register_stair_and_slab("quartzblock", {
	baseitem = "vlc_nether:quartz_block",
	description_stair = S("Quartz Stairs"),
	description_slab = S("Quartz Slab"),
	recipeitem = "group:quartz_block",
	overrides = {_vlc_stonecutter_recipes = {"vlc_nether:quartz_block"}},
})

vlc_stairs.register_stair_and_slab("quartz_smooth", {
	baseitem = "vlc_nether:quartz_smooth",
	description_stair = S("Smooth Quartz Stairs"),
	description_slab = S("Smooth Quartz Slab"),
	recipeitem = "vlc_nether:quartz_smooth",
	overrides = {_vlc_stonecutter_recipes = {"vlc_nether:quartz_smooth"}},
})

vlc_stairs.register_stair_and_slab("nether_brick", {
	baseitem = "vlc_nether:nether_brick",
	description_stair = S("Nether Brick Stairs"),
	description_slab = S("Nether Brick Slab"),
	overrides = {_vlc_stonecutter_recipes = { "vlc_nether:nether_brick" }},{_vlc_stonecutter_recipes = { "vlc_nether:nether_brick" }},
})
vlc_stairs.register_stair_and_slab("red_nether_brick", {
	baseitem = "vlc_nether:red_nether_brick",
	description_stair = S("Red Nether Brick Stairs"),
	description_slab = S("Red Nether Brick Slab"),
	overrides = {_vlc_stonecutter_recipes = { "vlc_nether:red_nether_brick" }},{_vlc_stonecutter_recipes = { "vlc_nether:red_nether_brick" }},
})

-- Nether Brick Fence (without fence gate!)
vlc_fences.register_fence("nether_brick_fence", S("Nether Brick Fence"), "vlc_fences_fence_nether_brick.png", {pickaxey=1, deco_block=1, fence_nether_brick=1}, 2, 30, {"group:fence_nether_brick"}, vlc_sounds.node_sound_stone_defaults())


minetest.register_craftitem("vlc_nether:glowstone_dust", {
	description = S("Glowstone Dust"),
	_doc_items_longdesc = S("Glowstone dust is the dust which comes out of broken glowstones. It is mainly used in crafting."),
	inventory_image = "vlc_nether_glowstone_dust.png",
	groups = { craftitem=1, brewitem=1 },
})

minetest.register_craftitem("vlc_nether:quartz", {
	description = S("Nether Quartz"),
	_doc_items_longdesc = S("Nether quartz is a versatile crafting ingredient."),
	inventory_image = "vlc_nether_quartz.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("vlc_nether:netherite_scrap", {
	description = S("Netherite Scrap"),
	_doc_items_longdesc = S("Netherite scrap is a crafting ingredient for netherite ingots."),
	inventory_image = "vlc_nether_netherite_scrap.png",
	groups = { craftitem = 1, fire_immune=1 },
})

minetest.register_craftitem("vlc_nether:netherite_ingot", {
	description = S("Netherite Ingot"),
	_doc_items_longdesc = S("Netherite ingots can be used with a smithing table to upgrade items to netherite."),
	inventory_image = "vlc_nether_netherite_ingot.png",
	groups = { craftitem = 1, fire_immune=1 },
})

minetest.register_craftitem("vlc_nether:netherbrick", {
	description = S("Nether Brick"),
	_doc_items_longdesc = S("Nether bricks are the main crafting ingredient for crafting nether brick blocks and nether fences."),
	inventory_image = "vlc_nether_netherbrick.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("vlc_nether:netherite_upgrade_template", {
	description	  = S("Netherite Upgrade Template"),
	--_tt_help = S("Netherite Upgrade Template").."\n\n"..
	minetest.colorize(vlc_colors.GRAY, S("Applies to:")).."\n"..minetest.colorize(vlc_colors.BLUE, " "..S("Diamond Armor")).."\n"..
	minetest.colorize(vlc_colors.BLUE, " "..S("Diamond Tools")).."\n"..
	minetest.colorize(vlc_colors.GRAY, S("Ingredients:")).."\n"..minetest.colorize(vlc_colors.BLUE, " "..S("Netherite Ingot")),
	inventory_image  = "vlc_nether_netherite_ugrade_template.png",
	groups = { upgrade_template  = 1 },
})

minetest.register_craft({
    output = "vlc_nether:netherite_upgrade_template 2",
    recipe = {
        {"vlc_core:diamond", "vlc_nether:netherite_upgrade_template","vlc_core:diamond"},
        {"vlc_core:diamond", "vlc_nether:netherrack","vlc_core:diamond"},
        {"vlc_core:diamond","vlc_core:diamond","vlc_core:diamond"},
    }
})

minetest.register_craft({
	output = "vlc_fences:nether_brick_fence 6",
	recipe = {
		{"vlc_nether:nether_brick", "vlc_nether:netherbrick", "vlc_nether:nether_brick"},
		{"vlc_nether:nether_brick", "vlc_nether:netherbrick", "vlc_nether:nether_brick"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:fence_wood",
	burntime = 15,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_nether:quartz",
	recipe = "vlc_nether:quartz_ore",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_nether:netherite_scrap",
	recipe = "vlc_nether:ancient_debris",
	cooktime = 10,
})

minetest.register_craft({
	output = "vlc_nether:quartz_block",
	recipe = {
		{"vlc_nether:quartz", "vlc_nether:quartz"},
		{"vlc_nether:quartz", "vlc_nether:quartz"},
	}
})

minetest.register_craft({
	output = "vlc_nether:quartz_pillar 2",
	recipe = {
		{"vlc_nether:quartz_block"},
		{"vlc_nether:quartz_block"},
	}
})

minetest.register_craft({
	output = "vlc_nether:glowstone",
	recipe = {
		{"vlc_nether:glowstone_dust", "vlc_nether:glowstone_dust"},
		{"vlc_nether:glowstone_dust", "vlc_nether:glowstone_dust"},
	}
})

minetest.register_craft({
	output = "vlc_nether:magma",
	recipe = {
		{"vlc_mobitems:magma_cream", "vlc_mobitems:magma_cream"},
		{"vlc_mobitems:magma_cream", "vlc_mobitems:magma_cream"},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_nether:netherbrick",
	recipe = "vlc_nether:netherrack",
	cooktime = 10,
})

minetest.register_craft({
	output = "vlc_nether:nether_brick",
	recipe = {
		{"vlc_nether:netherbrick", "vlc_nether:netherbrick"},
		{"vlc_nether:netherbrick", "vlc_nether:netherbrick"},
	}
})

minetest.register_craft({
	output = "vlc_nether:red_nether_brick",
	recipe = {
		{"vlc_nether:nether_wart_item", "vlc_nether:netherbrick"},
		{"vlc_nether:netherbrick", "vlc_nether:nether_wart_item"},
	}
})
minetest.register_craft({
	output = "vlc_nether:red_nether_brick",
	recipe = {
		{"vlc_nether:netherbrick", "vlc_nether:nether_wart_item"},
		{"vlc_nether:nether_wart_item", "vlc_nether:netherbrick"},
	}
})

minetest.register_craft({
	output = "vlc_nether:chiseled_nether_brick",
	recipe = {
		{"vlc_stairs:netherbrick_slab"},
		{"vlc_stairs:netherbrick_slab"},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:cracked_nether_brick",
	recipe = "vlc_core:netherbrick",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_nether:quartz_smooth",
	recipe = "vlc_nether:quartz_block",
	cooktime = 10,
})

minetest.register_craft({
	output = "vlc_nether:nether_wart_block",
	recipe = {
		{"vlc_nether:nether_wart_item", "vlc_nether:nether_wart_item", "vlc_nether:nether_wart_item"},
		{"vlc_nether:nether_wart_item", "vlc_nether:nether_wart_item", "vlc_nether:nether_wart_item"},
		{"vlc_nether:nether_wart_item", "vlc_nether:nether_wart_item", "vlc_nether:nether_wart_item"},
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "vlc_nether:netherite_ingot",
	recipe = {
		"vlc_nether:netherite_scrap", "vlc_nether:netherite_scrap", "vlc_nether:netherite_scrap",
		"vlc_nether:netherite_scrap", "vlc_core:gold_ingot", "vlc_core:gold_ingot",
		"vlc_core:gold_ingot", "vlc_core:gold_ingot", },
})

minetest.register_craft({
	output = "vlc_nether:netheriteblock",
	recipe = {
		{"vlc_nether:netherite_ingot", "vlc_nether:netherite_ingot", "vlc_nether:netherite_ingot"},
		{"vlc_nether:netherite_ingot", "vlc_nether:netherite_ingot", "vlc_nether:netherite_ingot"},
		{"vlc_nether:netherite_ingot", "vlc_nether:netherite_ingot", "vlc_nether:netherite_ingot"}
	}
})

minetest.register_craft({
	output = "vlc_nether:netherite_ingot 9",
	recipe = {
		{"vlc_nether:netheriteblock", "", ""},
		{"", "", ""},
		{"", "", ""}
	}
})

dofile(minetest.get_modpath(minetest.get_current_modname()).."/nether_wart.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lava.lua")
