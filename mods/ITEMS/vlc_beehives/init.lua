------------------
---- Beehives ----
------------------

-- Variables
local S = minetest.get_translator(minetest.get_current_modname())
local abm_nodes = { "vlc_beehives:beehive", "vlc_beehives:bee_nest" }

-- Function to allow harvesting honey and honeycomb from the beehive and bee nest.
local honey_harvest = function(pos, node, player, itemstack, pointed_thing)
	local inv = player:get_inventory()
	local shears = minetest.get_item_group(player:get_wielded_item():get_name(), "shears") > 0
	local bottle = player:get_wielded_item():get_name() == "vlc_potions:glass_bottle"
	local original_block = "vlc_beehives:bee_nest"
	local is_creative = minetest.is_creative_enabled(player:get_player_name())
	if node.name == "vlc_beehives:beehive_5" then
		original_block = "vlc_beehives:beehive"
	end

	local campfire_area = vector.offset(pos, 0, -5, 0)
	local campfire = minetest.find_nodes_in_area(pos, campfire_area, "group:lit_campfire")

	if bottle or shears then
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then
			minetest.record_protection_violation(pos, name)
			return itemstack
		end
		if bottle then
			local honey = "vlc_honey:honey_bottle"
			if inv:room_for_item("main", honey) then
				inv:add_item("main", "vlc_honey:honey_bottle")
				if not is_creative then
					itemstack:take_item()
				end
				if campfire[1] then
					awards.unlock(player:get_player_name(), "vlc:bee_our_guest")
				end
			end
		else --Must be shears
			minetest.add_item(pos, "vlc_honey:honeycomb 3")
		end
		--TODO: damage type = "mob" since this is supposed to be done by bee mobs which aren't a thing yet
		--Once bees exist this branch should spawn them and/or make them aggro
		if not campfire[1] then vlc_util.deal_damage(player, 10, {type = "mob"}) end
		node.name = original_block
		minetest.swap_node(pos, node)
	end
end

-- Dig Function for Beehives
local dig_hive = function(pos, node, oldmetadata, digger)
	local wield_item = digger:get_wielded_item()
	local beehive = string.find(node.name, "vlc_beehives:beehive")
	local beenest = string.find(node.name, "vlc_beehives:bee_nest")
	local silk_touch = vlc_enchanting.has_enchantment(wield_item, "silk_touch")
	local is_creative = minetest.is_creative_enabled(digger:get_player_name())
	local inv = digger:get_inventory()

	if beehive then
		if not is_creative then
			minetest.add_item(pos, "vlc_beehives:beehive")
			if not silk_touch then vlc_util.deal_damage(digger, 10, {type = "mob"}) end
		elseif is_creative and inv:room_for_item("main", "vlc_beehives:beehive") and not inv:contains_item("main", "vlc_beehives:beehive") then
			inv:add_item("main", "vlc_beehives:beehive")
		end
	elseif beenest then
		if not is_creative then
			if silk_touch then
				minetest.add_item(pos, "vlc_beehives:bee_nest")
				awards.unlock(digger:get_player_name(), "vlc:total_beelocation")
			else
				vlc_util.deal_damage(digger, 10, {type = "mob"})
			end
		elseif is_creative and inv:room_for_item("main", "vlc_beehives:bee_nest") and not inv:contains_item("main", "vlc_beehives:bee_nest") then
			inv:add_item("main", "vlc_beehives:bee_nest")
		end
	end
end

-- Beehive
minetest.register_node("vlc_beehives:beehive", {
	description = S("Beehive"),
	_doc_items_longdesc = S("Artificial bee nest."),
	tiles = {
		"vlc_beehives_beehive_end.png", "vlc_beehives_beehive_end.png",
		"vlc_beehives_beehive_side.png", "vlc_beehives_beehive_side.png",
		"vlc_beehives_beehive_side.png", "vlc_beehives_beehive_front.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 5, material_wood = 1, beehive = 1 },
	sounds = vlc_sounds.node_sound_wood_defaults(),
	_vlc_blast_resistance = 0.6,
	_vlc_hardness = 0.6,
	drop = "",
	after_dig_node = dig_hive,
})

for l = 1, 4 do
	local name = "vlc_beehives:beehive_" .. l
	table.insert(abm_nodes, name)
	minetest.register_node(name, {
		description = S("Beehive"),
		_doc_items_longdesc = S("Artificial bee nest."),
		tiles = {
			"vlc_beehives_beehive_end.png", "vlc_beehives_beehive_end.png",
			"vlc_beehives_beehive_side.png", "vlc_beehives_beehive_side.png",
			"vlc_beehives_beehive_side.png", "vlc_beehives_beehive_front.png",
		},
		paramtype2 = "facedir",
		groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 5, material_wood = 1, not_in_creative_inventory = 1, beehive = 1, honey_level = l },
		sounds = vlc_sounds.node_sound_wood_defaults(),
		_vlc_blast_resistance = 0.6,
		_vlc_hardness = 0.6,
		drop = "",
		after_dig_node = dig_hive,
	})
end

minetest.register_node("vlc_beehives:beehive_5", {
	description = S("Beehive"),
	_doc_items_longdesc = S("Artificial bee nest."),
	tiles = {
		"vlc_beehives_beehive_end.png", "vlc_beehives_beehive_end.png",
		"vlc_beehives_beehive_side.png", "vlc_beehives_beehive_side.png",
		"vlc_beehives_beehive_side.png", "vlc_beehives_beehive_front_honey.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 5, material_wood = 1, not_in_creative_inventory = 1, beehive = 1, honey_level = 5 },
	sounds = vlc_sounds.node_sound_wood_defaults(),
	_vlc_blast_resistance = 0.6,
	_vlc_hardness = 0.6,
	on_rightclick = honey_harvest,
	drop = "",
	after_dig_node = dig_hive,
})

-- Bee Nest
minetest.register_node("vlc_beehives:bee_nest", {
	description = S("Bee Nest"),
	_doc_items_longdesc = S("A naturally generating block that houses bees and a tasty treat...if you can get it."),
	tiles = {
		"vlc_beehives_bee_nest_top.png", "vlc_beehives_bee_nest_bottom.png",
		"vlc_beehives_bee_nest_side.png", "vlc_beehives_bee_nest_side.png",
		"vlc_beehives_bee_nest_side.png", "vlc_beehives_bee_nest_front.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 30, bee_nest = 1 },
	sounds = vlc_sounds.node_sound_wood_defaults(),
	_vlc_blast_resistance = 0.3,
	_vlc_hardness = 0.3,
	drop = "",
	after_dig_node = dig_hive,
})

for i = 1, 4 do
	local name = "vlc_beehives:bee_nest_"..i
	table.insert(abm_nodes, name)
	minetest.register_node(name, {
		description = S("Bee Nest"),
		_doc_items_longdesc = S("A naturally generating block that houses bees and a tasty treat...if you can get it."),
		tiles = {
			"vlc_beehives_bee_nest_top.png", "vlc_beehives_bee_nest_bottom.png",
			"vlc_beehives_bee_nest_side.png", "vlc_beehives_bee_nest_side.png",
			"vlc_beehives_bee_nest_side.png", "vlc_beehives_bee_nest_front.png",
		},
		paramtype2 = "facedir",
		groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 30, not_in_creative_inventory = 1, bee_nest = 1, honey_level = i },
		sounds = vlc_sounds.node_sound_wood_defaults(),
		_vlc_blast_resistance = 0.3,
		_vlc_hardness = 0.3,
		drop = "",
		after_dig_node = dig_hive,
	})
end

minetest.register_node("vlc_beehives:bee_nest_5", {
	description = S("Bee Nest"),
	_doc_items_longdesc = S("A naturally generating block that houses bees and a tasty treat...if you can get it."),
	tiles = {
		"vlc_beehives_bee_nest_top.png", "vlc_beehives_bee_nest_bottom.png",
		"vlc_beehives_bee_nest_side.png", "vlc_beehives_bee_nest_side.png",
		"vlc_beehives_bee_nest_side.png", "vlc_beehives_bee_nest_front_honey.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 30, not_in_creative_inventory = 1, bee_nest = 1, honey_level = 5 },
	sounds = vlc_sounds.node_sound_wood_defaults(),
	_vlc_blast_resistance = 0.3,
	_vlc_hardness = 0.3,
	_vlc_honey_level = 5,
	on_rightclick = honey_harvest,
	drop = "",
	after_dig_node = dig_hive,
})

-- Crafting
minetest.register_craft({
	output = "vlc_beehives:beehive",
	recipe = {
		{ "group:wood", "group:wood", "group:wood" },
		{ "vlc_honey:honeycomb", "vlc_honey:honeycomb", "vlc_honey:honeycomb" },
		{ "group:wood", "group:wood", "group:wood" },
	},
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:bee_nest",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:beehive",
	burntime = 15,
})

-- Temporary ABM to update honey levels
minetest.register_abm({
	label = "Update Beehive or Beenest Honey Levels",
	nodenames = abm_nodes, --Register for all levels but 5 so honeyed hives aren't constantly updating themselves
	interval = 75, --This is similar to what the situation would be for 2 bees (~5 to reach flower, 20 to harvest pollen, ~5 to return, 120 to process).
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local flower = minetest.find_node_near(pos, 5, "group:flower")
		local tod = minetest.get_timeofday() * 24000 --Bees need to sleep (note in Minecraft, they don't in the Nether/End, which is ridiculous)
		if tod > 6000 and tod < 18000 and flower and vlc_weather.get_weather() ~= "rain" then
			local node_name = node.name
			local original_block = "vlc_beehives:bee_nest"
			if minetest.get_item_group(node_name, "beehive") == 1 then
				original_block = "vlc_beehives:beehive"
			end
			local honey_level = minetest.get_item_group(node_name, "honey_level")
			honey_level = math.min(honey_level + (math.random(100) == 100 and 2 or 1), 5)
			node.name = original_block.."_"..honey_level
			minetest.swap_node(pos, node)
		end
	end,
})
