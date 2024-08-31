--[[
#!#!#!#Cake mod created by Jordan4ibanez#!#!#
#!#!#!#Released under CC Attribution-ShareAlike 3.0 Unported #!#!#
]]--

local CAKE_HUNGER_POINTS = 2

local S = minetest.get_translator(minetest.get_current_modname())

local cake_texture = {"cake_top.png","cake_bottom.png","cake_inner.png","cake_side.png","cake_side.png","cake_side.png"}
local slice_1 = { -7/16, -8/16, -7/16, -5/16, 0/16, 7/16}
local slice_2 = { -7/16, -8/16, -7/16, -3/16, 0/16, 7/16}
local slice_3 = { -7/16, -8/16, -7/16, -1/16, 0/16, 7/16}
local slice_4 = { -7/16, -8/16, -7/16, 1/16, 0/16, 7/16}
local slice_5 = { -7/16, -8/16, -7/16, 3/16, 0/16, 7/16}
local slice_6 = { -7/16, -8/16, -7/16, 5/16, 0/16, 7/16}

local full_cake = { -7/16, -8/16, -7/16, 7/16, 0/16, 7/16}

minetest.register_craft({
	output = "vlf_cake:cake",
	recipe = {
		{"vlf_mobitems:milk_bucket", "vlf_mobitems:milk_bucket", "vlf_mobitems:milk_bucket"},
		{"vlf_core:sugar", "vlf_throwing:egg", "vlf_core:sugar"},
		{"vlf_farming:wheat_item", "vlf_farming:wheat_item", "vlf_farming:wheat_item"},
	},
	replacements = {
		{"vlf_mobitems:milk_bucket", "vlf_buckets:bucket_empty"},
		{"vlf_mobitems:milk_bucket", "vlf_buckets:bucket_empty"},
		{"vlf_mobitems:milk_bucket", "vlf_buckets:bucket_empty"},
	},
})

minetest.register_node("vlf_cake:cake", {
	description = S("Cake"),
	_tt_help = S("With 7 tasty slices!").."\n"..S("Hunger points: +@1 per slice", CAKE_HUNGER_POINTS),
	_doc_items_longdesc = S("Cakes can be placed and eaten to restore hunger points. A cake has 7 slices. Each slice restores 2 hunger points and 0.4 saturation points. Cakes will be destroyed when dug or when the block below them is broken."),
	_doc_items_usagehelp = S("Place the cake anywhere, then rightclick it to eat a single slice. You can't eat from the cake when your hunger bar is full."),
	tiles = {"cake_top.png","cake_bottom.png","cake_side.png","cake_side.png","cake_side.png","cake_side.png"},
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	inventory_image = "cake.png",
	wield_image = "cake.png",
	paramtype = "light",
	is_ground_content = false,
	drawtype = "nodebox",
	selection_box = {
		type = "fixed",
		fixed = full_cake
	},
	node_box = {
		type = "fixed",
		fixed = full_cake
	},
	stack_max = 1,
	groups = {
		handy = 1, attached_node = 1, dig_by_piston = 1, comparator_signal = 14,
		cake = 7, food = 2, no_eat_delay = 1, compostability = 100
	},
	drop = "",
	on_rightclick = function(pos, node, clicker, _)
		-- Cake is subject to protection
		local name = clicker:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return
		end
		-- Check if we were allowed to eat
		if node.name == "vlf_cake:cake" or minetest.is_creative_enabled(clicker:get_player_name()) then
			minetest.add_node(pos,{type="node",name="vlf_cake:cake_6",param2=0})
		end
	end,
	sounds = vlf_sounds.node_sound_leaves_defaults(),

	_food_particles = false,
	_vlf_saturation = 0.4,
	_vlf_blast_resistance = 0.5,
	_vlf_hardness = 0.5,
})

local register_slice = function(level, nodebox, desc)
	local this = "vlf_cake:cake_"..level
	local after_eat = "vlf_cake:cake_"..(level-1)
	local on_rightclick
	if level > 1 then
		on_rightclick = function(pos, node, clicker, _)
			local name = clicker:get_player_name()
			if minetest.is_protected(pos, name) then
				minetest.record_protection_violation(pos, name)
				return
			end
			-- Check if we were allowed to eat
			if node.name == this or minetest.is_creative_enabled(clicker:get_player_name()) then
				minetest.add_node(pos,{type="node",name=after_eat,param2=0})
				minetest.do_item_eat(CAKE_HUNGER_POINTS, ItemStack(), ItemStack(this), clicker, {type="nothing"})
			end
		end
	else
		-- Last slice
		on_rightclick = function(pos, node, clicker, _)
			local name = clicker:get_player_name()
			if minetest.is_protected(pos, name) then
				minetest.record_protection_violation(pos, name)
				return
			end
			-- Check if we were allowed to eat
			if node.name == this or minetest.is_creative_enabled(clicker:get_player_name()) then
				minetest.remove_node(pos)
				minetest.check_for_falling(pos)
				minetest.do_item_eat(CAKE_HUNGER_POINTS, ItemStack(), ItemStack("vlf_cake:cake_1"), clicker, {type="nothing"})
			end
		end
	end

	minetest.register_node(this, {
		description = desc,
		_doc_items_create_entry = false,
		tiles = cake_texture,
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
		paramtype = "light",
		is_ground_content = false,
		drawtype = "nodebox",
		selection_box = {
			type = "fixed",
			fixed = nodebox,
		},
		node_box = {
			type = "fixed",
			fixed = nodebox,
			},
		groups = {
			handy = 1, attached_node = 1, not_in_creative_inventory = 1,
			dig_by_piston = 1, cake = level, comparator_signal = level * 2,
			food = 2, no_eat_delay = 1
		},
		drop = "",
		on_rightclick = on_rightclick,
		sounds = vlf_sounds.node_sound_leaves_defaults(),

		_food_particles = false,
		_vlf_saturation = 0.4,
		_vlf_blast_resistance = 0.5,
		_vlf_hardness = 0.5,
	})

	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", "vlf_cake:cake", "nodes", "vlf_cake:cake_"..level)
	end
end

register_slice(6, slice_6, S("Cake (6 Slices Left)"))
register_slice(5, slice_5, S("Cake (5 Slices Left)"))
register_slice(4, slice_4, S("Cake (4 Slices Left)"))
register_slice(3, slice_3, S("Cake (3 Slices Left)"))
register_slice(2, slice_2, S("Cake (2 Slices Left)"))
register_slice(1, slice_1, S("Cake (1 Slice Left)"))
