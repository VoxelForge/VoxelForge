local S = minetest.get_translator(minetest.get_current_modname())

local function on_bone_meal(itemstack,placer,pointed_thing,pos,node)
	return vlf_farming.on_bone_meal(itemstack,placer,pointed_thing,pos,node,"plant_potato")
end

-- Premature potato plants

for i=1, 7 do
	local texture, selbox
	if i < 3 then
		texture = "vlf_farming_potatoes_stage_0.png"
		selbox = { -5/16, -0.5 ,-5/16, 5/16, -0.5+(3/16) ,5/16 }
	elseif i < 5 then
		texture = "vlf_farming_potatoes_stage_1.png"
		selbox = { -6/16, -0.5 ,-6/16, 6/16, -0.5+(4/16) ,6/16 }
	else
		texture = "vlf_farming_potatoes_stage_2.png"
		selbox = { -6/16, -0.5 ,-6/16, 6/16, -0.5+(6/16) ,6/16 }
	end

	local create, name, longdesc
	if i==1 then
		create = true
		name = S("Premature Potato Plant")
		longdesc = S("Potato plants are plants which grow on farmland under sunlight in 8 stages, but only 4 stages can be visually told apart. On hydrated farmland, they grow a bit faster. They can be harvested at any time but will only yield a profit when mature.")
	else
		create = false
		if minetest.get_modpath("doc") then
			doc.add_entry_alias("nodes", "vlf_farming:potato_1", "nodes", "vlf_farming:potato_"..i)
		end
	end

	minetest.register_node("vlf_farming:potato_"..i, {
		description = S("Premature Potato Plant (Stage @1)", i),
		_doc_items_create_entry = create,
		_doc_items_entry_name = name,
		_doc_items_longdesc = longdesc,
		paramtype = "light",
		paramtype2 = "meshoptions",
		sunlight_propagates = true,
		place_param2 = 3,
		walkable = false,
		drawtype = "plantlike",
		drop = "vlf_farming:potato_item",
		tiles = { texture },
		inventory_image = texture,
		wield_image = texture,
		selection_box = {
			type = "fixed",
			fixed = { selbox },
		},
		groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1},
		sounds = vlf_sounds.node_sound_leaves_defaults(),
		_vlf_blast_resistance = 0,
		_on_bone_meal = on_bone_meal,
	})
end

-- Mature plant
minetest.register_node("vlf_farming:potato", {
	description = S("Mature Potato Plant"),
	_doc_items_longdesc = S("Mature potato plants are ready to be harvested for potatoes. They won't grow any further."),
	paramtype = "light",
	paramtype2 = "meshoptions",
	sunlight_propagates = true,
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	tiles = {"vlf_farming_potatoes_stage_3.png"},
	wield_image = "vlf_farming_potatoes_stage_3.png",
	inventory_image = "vlf_farming_potatoes_stage_3.png",
	drop = {
		items = {
			{ items = {"vlf_farming:potato_item 1"} },
			{ items = {"vlf_farming:potato_item 1"}, rarity = 2 },
			{ items = {"vlf_farming:potato_item 1"}, rarity = 2 },
			{ items = {"vlf_farming:potato_item 1"}, rarity = 2 },
			{ items = {"vlf_farming:potato_item_poison 1"}, rarity = 50 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -6/16, -0.5 ,-6/16, 6/16, -0.5+(8/16) ,6/16 }
		}
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1},
	sounds = vlf_sounds.node_sound_leaves_defaults(),
	_vlf_blast_resistance = 0,
	_vlf_fortune_drop = {
		discrete_uniform_distribution = true,
		items = {"vlf_farming:potato_item"},
		min_count = 2,
		max_count = 4,
		cap = 5
	}
})

minetest.register_craftitem("vlf_farming:potato_item", {
	description = S("Potato"),
	_tt_help = S("Grows on farmland"),
	_doc_items_longdesc = S("Potatoes are food items which can be eaten, cooked in the furnace and planted. Pigs like potatoes."),
	_doc_items_usagehelp = S("Hold it in your hand and rightclick to eat it. Place it on top of farmland to plant it. It grows in sunlight and grows faster on hydrated farmland. Rightclick an animal to feed it."),
	inventory_image = "farming_potato.png",
	groups = {food = 2, eatable = 1, compostability = 65, smoker_cookable = 1, campfire_cookable = 1},
	_vlf_saturation = 0.6,
	_vlf_cooking_output = "vlf_farming:potato_item_baked",
	on_secondary_use = minetest.item_eat(1),
	on_place = function(itemstack, placer, pointed_thing)
		local new = vlf_farming:place_seed(itemstack, placer, pointed_thing, "vlf_farming:potato_1")
		if new then
			return new
		else
			return minetest.do_item_eat(1, nil, itemstack, placer, pointed_thing)
		end
	end,
})

minetest.register_craftitem("vlf_farming:potato_item_baked", {
	description = S("Baked Potato"),
	_doc_items_longdesc = S("Baked potatoes are food items which are more filling than the unbaked ones."),
	inventory_image = "farming_potato_baked.png",
	on_place = minetest.item_eat(5),
	on_secondary_use = minetest.item_eat(5),
	groups = {food = 2, eatable = 5, compostability = 85},
	_vlf_saturation = 6.0,
})

minetest.register_craftitem("vlf_farming:potato_item_poison", {
	description = S("Poisonous Potato"),
	_tt_help = minetest.colorize(vlf_colors.YELLOW, S("60% chance of poisoning")),
	_doc_items_longdesc = S("This potato doesn't look too healthy. You can eat it to restore hunger points, but there's a 60% chance it will poison you briefly."),
	inventory_image = "farming_potato_poison.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { food = 2, eatable = 2 },
	_vlf_saturation = 1.2,
})

vlf_farming:add_plant("plant_potato", "vlf_farming:potato", {"vlf_farming:potato_1", "vlf_farming:potato_2", "vlf_farming:potato_3", "vlf_farming:potato_4", "vlf_farming:potato_5", "vlf_farming:potato_6", "vlf_farming:potato_7"}, 19.75, 20)

minetest.register_on_item_eat(function (_, _, itemstack, user)

	-- 60% chance of poisoning with poisonous potato
	if itemstack:get_name() == "vlf_farming:potato_item_poison" then
		if math.random(1,10) >= 6 then
			vlf_entity_effects.give_entity_effect_by_level("poison", user, 1, 5)
		end
	end

end )
