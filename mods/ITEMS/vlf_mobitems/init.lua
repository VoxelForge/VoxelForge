local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_craftitem("vlf_mobitems:rotten_flesh", {
	description = S("Rotten Flesh"),
	_tt_help = minetest.colorize(vlf_colors.YELLOW, S("80% chance of food poisoning")),
	_doc_items_longdesc = S("Yuck! This piece of flesh clearly has seen better days. If you're really desperate, you can eat it to restore a few hunger points, but there's a 80% chance it causes food poisoning, which increases your hunger for a while."),
	inventory_image = "vlf_mobitems_rotten_flesh.png",
	wield_image = "vlf_mobitems_rotten_flesh.png",
	on_place = minetest.item_eat(4),
	on_secondary_use = minetest.item_eat(4),
	groups = { food = 2, eatable = 4 },
	_vlf_saturation = 0.8,
})

minetest.register_craftitem("vlf_mobitems:mutton", {
	description = S("Raw Mutton"),
	_doc_items_longdesc = S("Raw mutton is the flesh from a sheep and can be eaten safely. Cooking it will greatly increase its nutritional value."),
	inventory_image = "vlf_mobitems_mutton_raw.png",
	wield_image = "vlf_mobitems_mutton_raw.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { food = 2, eatable = 2, smoker_cookable = 1, campfire_cookable = 1 },
	_vlf_saturation = 1.2,
})

minetest.register_craftitem("vlf_mobitems:cooked_mutton", {
	description = S("Cooked Mutton"),
	_doc_items_longdesc = S("Cooked mutton is the cooked flesh from a sheep and is used as food."),
	inventory_image = "vlf_mobitems_mutton_cooked.png",
	wield_image = "vlf_mobitems_mutton_cooked.png",
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
	groups = { food = 2, eatable = 6 },
	_vlf_saturation = 9.6,
})

minetest.register_craftitem("vlf_mobitems:beef", {
	description = S("Raw Beef"),
	_doc_items_longdesc = S("Raw beef is the flesh from cows and can be eaten safely. Cooking it will greatly increase its nutritional value."),
	inventory_image = "vlf_mobitems_beef_raw.png",
	wield_image = "vlf_mobitems_beef_raw.png",
	on_place = minetest.item_eat(3),
	on_secondary_use = minetest.item_eat(3),
	groups = { food = 2, eatable = 3, smoker_cookable = 1, campfire_cookable = 1 },
	_vlf_saturation = 1.8,
})

minetest.register_craftitem("vlf_mobitems:cooked_beef", {
	description = S("Steak"),
	_doc_items_longdesc = S("Steak is cooked beef from cows and can be eaten."),
	inventory_image = "vlf_mobitems_beef_cooked.png",
	wield_image = "vlf_mobitems_beef_cooked.png",
	on_place = minetest.item_eat(8),
	on_secondary_use = minetest.item_eat(8),
	groups = { food = 2, eatable = 8 },
	_vlf_saturation = 12.8,
})

minetest.register_craftitem("vlf_mobitems:chicken", {
	description = S("Raw Chicken"),
	_tt_help = minetest.colorize(vlf_colors.YELLOW, S("30% chance of food poisoning")),
	_doc_items_longdesc = S("Raw chicken is a food item which is not safe to consume. You can eat it to restore a few hunger points, but there's a 30% chance to suffer from food poisoning, which increases your hunger rate for a while. Cooking raw chicken will make it safe to eat and increases its nutritional value."),
	inventory_image = "vlf_mobitems_chicken_raw.png",
	wield_image = "vlf_mobitems_chicken_raw.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { food = 2, eatable = 2, smoker_cookable = 1, campfire_cookable = 1 },
	_vlf_saturation = 1.2,
})

minetest.register_craftitem("vlf_mobitems:cooked_chicken", {
	description = S("Cooked Chicken"),
	_doc_items_longdesc = S("A cooked chicken is a healthy food item which can be eaten."),
	inventory_image = "vlf_mobitems_chicken_cooked.png",
	wield_image = "vlf_mobitems_chicken_cooked.png",
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
	groups = { food = 2, eatable = 6 },
	_vlf_saturation = 7.2,
})

minetest.register_craftitem("vlf_mobitems:porkchop", {
	description = S("Raw Porkchop"),
	_doc_items_longdesc = S("A raw porkchop is the flesh from a pig and can be eaten safely. Cooking it will greatly increase its nutritional value."),
	inventory_image = "vlf_mobitems_porkchop_raw.png",
	wield_image = "vlf_mobitems_porkchop_raw.png",
	on_place = minetest.item_eat(3),
	on_secondary_use = minetest.item_eat(3),
	groups = { food = 2, eatable = 3, smoker_cookable = 1, campfire_cookable = 1 },
	_vlf_saturation = 1.8,
})

minetest.register_craftitem("vlf_mobitems:cooked_porkchop", {
	description = S("Cooked Porkchop"),
	_doc_items_longdesc = S("Cooked porkchop is the cooked flesh of a pig and is used as food."),
	inventory_image = "vlf_mobitems_porkchop_cooked.png",
	wield_image = "vlf_mobitems_porkchop_cooked.png",
	on_place = minetest.item_eat(8),
	on_secondary_use = minetest.item_eat(8),
	groups = { food = 2, eatable = 8 },
	_vlf_saturation = 12.8,
})

minetest.register_craftitem("vlf_mobitems:rabbit", {
	description = S("Raw Rabbit"),
	_doc_items_longdesc = S("Raw rabbit is a food item from a dead rabbit. It can be eaten safely. Cooking it will increase its nutritional value."),
	inventory_image = "vlf_mobitems_rabbit_raw.png",
	wield_image = "vlf_mobitems_rabbit_raw.png",
	on_place = minetest.item_eat(3),
	on_secondary_use = minetest.item_eat(3),
	groups = { food = 2, eatable = 3, smoker_cookable = 1, campfire_cookable = 1 },
	_vlf_saturation = 1.8,
})

minetest.register_craftitem("vlf_mobitems:cooked_rabbit", {
	description = S("Cooked Rabbit"),
	_doc_items_longdesc = S("This is a food item which can be eaten."),
	inventory_image = "vlf_mobitems_rabbit_cooked.png",
	wield_image = "vlf_mobitems_rabbit_cooked.png",
	on_place = minetest.item_eat(5),
	on_secondary_use = minetest.item_eat(5),
	groups = { food = 2, eatable = 5 },
	_vlf_saturation = 6.0,
})

-- Reset food poisoning and status entity_effects
local function drink_milk(itemstack, player, pointed_thing)
	local bucket = minetest.do_item_eat(0, "vlf_buckets:bucket_empty", itemstack, player, pointed_thing)
	-- Check if we were allowed to drink this (eat delay check)
	if vlf_hunger.active and (bucket:get_name() ~= "vlf_mobitems:milk_bucket" or minetest.is_creative_enabled(player:get_player_name())) then
		vlf_hunger.stop_poison(player)
	end
	vlf_entity_effects._reset_entity_effects(player)
	return bucket
end

minetest.register_craftitem("vlf_mobitems:milk_bucket", {
	description = S("Milk"),
	_tt_help = minetest.colorize(vlf_colors.GREEN, S("Removes all status entity_effects")),
	_doc_items_longdesc = S("Milk is very refreshing and can be obtained by using a bucket on a cow. Drinking it will remove all status entity_effects, but restores no hunger points."),
	_doc_items_usagehelp = S("Use the placement key to drink the milk."),
	inventory_image = "vlf_mobitems_bucket_milk.png",
	wield_image = "vlf_mobitems_bucket_milk.png",
	on_place = drink_milk,
	on_secondary_use = drink_milk,
	stack_max = 1,
	groups = { food = 3, can_eat_when_full = 1 },
})

minetest.register_craftitem("vlf_mobitems:spider_eye", {
	description = S("Spider Eye"),
	_tt_help = minetest.colorize(vlf_colors.YELLOW, S("Poisonous")),
	_doc_items_longdesc = S("Spider eyes are used mainly in crafting. If you're really desperate, you can eat a spider eye, but it will poison you briefly."),
	inventory_image = "vlf_mobitems_spider_eye.png",
	wield_image = "vlf_mobitems_spider_eye.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { food = 2, eatable = 2, brewitem = 1 },
	_vlf_saturation = 3.2,
})

minetest.register_craftitem("vlf_mobitems:bone", {
	description = S("Bone"),
	_doc_items_longdesc = S("Bones can be used to tame wolves so they will protect you. They are also useful as a crafting ingredient."),
	_doc_items_usagehelp = S("Wield the bone near wolves to attract them. Use the “Place” key on the wolf to give it a bone and tame it. You can then give commands to the tamed wolf by using the “Place” key on it."),
	inventory_image = "vlf_mobitems_bone.png",
	groups = { craftitem=1 },
	_vlf_toollike_wield = true,
})

minetest.register_craftitem("vlf_mobitems:ink_sac", {
	description = S("Squid Ink Sac"),
	_doc_items_longdesc = S("This item is dropped by dead squids. Squid ink can be used to as an ingredient to craft book and quill or black dye."),
	inventory_image = "vlf_mobitems_ink_sac.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("vlf_mobitems:string", {
	description = S("String"),
	_doc_items_longdesc = S("Strings are used in crafting."),
	inventory_image = "vlf_mobitems_string.png",
	groups = { craftitem = 1 },
	on_place = function(itemstack, placer, pointed_thing)
		-- Check if the pointed thing is a node
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local pos = pointed_thing.above
		local player_name = placer:get_player_name()

		-- Check if the position is protected
		if minetest.is_protected(pos, player_name) then
			minetest.record_protection_violation(pos, player_name)
			return itemstack
		end

		-- Place the tripwire block at the pointed position
		minetest.set_node(pos, {name = "vlf_tripwire:tripwire"})

		-- Reduce the item stack by one unless the player is in creative mode
		if not minetest.is_creative_enabled(player_name) then
			itemstack:take_item()
		end

		return itemstack
	end,
})
minetest.register_craftitem("vlf_mobitems:blaze_rod", {
	description = S("Blaze Rod"),
	_doc_items_longdesc = S("This is a crafting component dropped from dead blazes."),
	wield_image = "vlf_mobitems_blaze_rod.png",
	inventory_image = "vlf_mobitems_blaze_rod.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("vlf_mobitems:breeze_rod", {
	description = S("Breeze Rod"),
	_doc_items_longdesc = S("This is a crafting item dropped from breezes."),
	wield_image = "vlf_mobitems_breeze_rod.png",
	inventory_image = "vlf_mobitems_breeze_rod.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("vlf_mobitems:blaze_powder", {
	description = S("Blaze Powder"),
	_doc_items_longdesc = S("This item is mainly used for crafting."),
	wield_image = "vlf_mobitems_blaze_powder.png",
	inventory_image = "vlf_mobitems_blaze_powder.png",
	groups = { craftitem = 1, brewitem = 1 },
})

minetest.register_craftitem("vlf_mobitems:magma_cream", {
	description = S("Magma Cream"),
	_doc_items_longdesc = S("Magma cream is a crafting component."),
	wield_image = "vlf_mobitems_magma_cream.png",
	inventory_image = "vlf_mobitems_magma_cream.png",
	groups = { craftitem = 1, brewitem = 1 },
})

minetest.register_craftitem("vlf_mobitems:ghast_tear", {
	description = S("Ghast Tear"),
	_doc_items_longdesc = S("Place this item in an item frame as decoration."),
	wield_image = "vlf_mobitems_ghast_tear.png",
	inventory_image = "vlf_mobitems_ghast_tear.png",
	groups = { brewitem = 1 },
})

minetest.register_craftitem("vlf_mobitems:nether_star", {
	description = S("Nether Star"),
	_doc_items_longdesc = S("A nether star is dropped when the Wither dies. Place it in an item frame to show the world how hardcore you are! Or just as decoration."),
	wield_image = "vlf_mobitems_nether_star.png",
	inventory_image = "vlf_mobitems_nether_star.png",
	-- TODO: Reveal item when it's useful
	groups = { craftitem = 1, not_in_creative_inventory = 1 },
})

minetest.register_craftitem("vlf_mobitems:leather", {
	description = S("Leather"),
	_doc_items_longdesc = S("Leather is a versatile crafting component."),
	wield_image = "vlf_mobitems_leather.png",
	inventory_image = "vlf_mobitems_leather.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("vlf_mobitems:feather", {
	description = S("Feather"),
	_doc_items_longdesc = S("Feathers are used in crafting and are dropped from chickens."),
	wield_image = "vlf_mobitems_feather.png",
	inventory_image = "vlf_mobitems_feather.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("vlf_mobitems:rabbit_hide", {
	description = S("Rabbit Hide"),
	_doc_items_longdesc = S("Rabbit hide is used to create leather."),
	wield_image = "vlf_mobitems_rabbit_hide.png",
	inventory_image = "vlf_mobitems_rabbit_hide.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("vlf_mobitems:rabbit_foot", {
	description = S("Rabbit's Foot"),
	_doc_items_longdesc = S("Must be your lucky day! Place this item in an item frame for decoration."),
	wield_image = "vlf_mobitems_rabbit_foot.png",
	inventory_image = "vlf_mobitems_rabbit_foot.png",
	groups = { brewitem = 1 },
})

minetest.register_craftitem("vlf_mobitems:saddle", {
	description = S("Saddle"),
	_tt_help = S("Can be placed on animals to ride them"),
	_doc_items_longdesc = S("Saddles can be put on some animals in order to mount them."),
	_doc_items_usagehelp = S("Use the placement key with the saddle in your hand to try to put on the saddle. Saddles fit on horses, mules, donkeys and pigs. Horses, mules and donkeys need to be tamed first, otherwise they'll reject the saddle. Saddled animals can be mounted by using the placement key on them again."),
	wield_image = "vlf_mobitems_saddle.png",
	inventory_image = "vlf_mobitems_saddle.png",
	groups = { transport = 1 },
	stack_max = 1,
})

minetest.register_craftitem("vlf_mobitems:rabbit_stew", {
	description = S("Rabbit Stew"),
	_doc_items_longdesc = S("Rabbit stew is a very nutricious food item."),
	wield_image = "vlf_mobitems_rabbit_stew.png",
	inventory_image = "vlf_mobitems_rabbit_stew.png",
	stack_max = 1,
	on_place = minetest.item_eat(10, "vlf_core:bowl"),
	on_secondary_use = minetest.item_eat(10, "vlf_core:bowl"),
	groups = { food = 3, eatable = 10 },
	_vlf_saturation = 12.0,
})

minetest.register_craftitem("vlf_mobitems:shulker_shell", {
	description = S("Shulker Shell"),
	_doc_items_longdesc = S("Shulker shells are used in crafting. They are dropped from dead shulkers."),
	inventory_image = "vlf_mobitems_shulker_shell.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("vlf_mobitems:slimeball", {
	description = S("Slimeball"),
	_doc_items_longdesc = S("Slimeballs are used in crafting. They are dropped from slimes."),
	inventory_image = "vlf_mobitems_slimeball.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("vlf_mobitems:gunpowder", {
	description = S("Gunpowder"),
	_doc_items_longdesc = doc.sub.items.temp.craftitem,
	inventory_image = "default_gunpowder.png",
	groups = { craftitem=1, brewitem = 1 },
})

minetest.register_tool("vlf_mobitems:carrot_on_a_stick", {
	description = S("Carrot on a Stick"),
	_tt_help = S("Lets you ride a saddled pig"),
	_doc_items_longdesc = S("A carrot on a stick can be used on saddled pigs to ride them."),
	_doc_items_usagehelp = S("Place it on a saddled pig to mount it. You can now ride the pig like a horse. Pigs will also walk towards you when you just wield the carrot on a stick."),
	wield_image = "vlf_mobitems_carrot_on_a_stick.png^[transformFY^[transformR90",
	inventory_image = "vlf_mobitems_carrot_on_a_stick.png",
	groups = { transport = 1 },
	_vlf_toollike_wield = true,
})

minetest.register_tool("vlf_mobitems:warped_fungus_on_a_stick", {
	description = S("Warped Fungus on a Stick"),
	_tt_help = S("Lets you ride a strider"),
	_doc_items_longdesc = S("A warped fungus on a stick can be used on saddled striders to ride them."),
	_doc_items_usagehelp = S("Place it on a saddled strider to mount it. You can now ride the strider like a horse. Striders will also walk towards you when you just wield the fungus on a stick."),
	wield_image = "vlf_mobitems_warped_fungus_on_a_stick.png^[transformFY^[transformR90",
	inventory_image = "vlf_mobitems_warped_fungus_on_a_stick.png",
	groups = { transport = 1 },
	_vlf_toollike_wield = true,
})

minetest.register_craftitem("vlf_mobitems:nautilus_shell", {
	description = S("Nautilus Shell"),
	_tt_help = S("Used to craft a conduit"),
	_doc_items_longdesc = S("The Nautilus Shell is used to craft a conduit. They can be obtained by fishing or killing a drowned that is wielding a shell."),
	inventory_image = "vlf_mobitems_nautilus_shell.png",
	groups = { craftitem=1 },
})

minetest.register_craftitem("vlf_mobitems:heart_of_the_sea", {
	description = S("Heart of the Sea"),
	_tt_help = S("Used to craft a conduit"),
	_doc_items_longdesc = S("The Heart of the Sea is used to craft a conduit. They can be obtained by finding them in a buried treasure chest."),
	inventory_image = "vlf_mobitems_heart_of_the_sea.png",
	groups = { craftitem=1 },
})

local horse_armor_use = S("Place it on a horse to put on the horse armor. Donkeys and mules can't wear horse armor.")

minetest.register_craftitem("vlf_mobitems:iron_horse_armor", {
	description = S("Iron Horse Armor"),
	_doc_items_longdesc = S("Iron horse armor can be worn by horses to increase their protection from harm a bit."),
	_doc_items_usagehelp = horse_armor_use,
	inventory_image = "vlf_mobitems_iron_horse_armor.png",
	_horse_overlay_image = "vlf_mobitems_horse_armor_iron.png",
	sounds = {
		_vlf_armor_equip = "vlf_armor_equip_iron",
	},
	stack_max = 1,
	groups = { horse_armor = 85 },
})

minetest.register_craftitem("vlf_mobitems:gold_horse_armor", {
	description = S("Golden Horse Armor"),
	_doc_items_longdesc = S("Golden horse armor can be worn by horses to increase their protection from harm."),
	_doc_items_usagehelp = horse_armor_use,
	inventory_image = "vlf_mobitems_gold_horse_armor.png",
	_horse_overlay_image = "vlf_mobitems_horse_armor_gold.png",
	sounds = {
		_vlf_armor_equip = "vlf_armor_equip_iron",
	},
	stack_max = 1,
	groups = { horse_armor = 60 },
})

minetest.register_craftitem("vlf_mobitems:diamond_horse_armor", {
	description = S("Diamond Horse Armor"),
	_doc_items_longdesc = S("Diamond horse armor can be worn by horses to greatly increase their protection from harm."),
	_doc_items_usagehelp = horse_armor_use,
	inventory_image = "vlf_mobitems_diamond_horse_armor.png",
	_horse_overlay_image = "vlf_mobitems_horse_armor_diamond.png",
	sounds = {
		_vlf_armor_equip = "vlf_armor_equip_diamond",
	},
	stack_max = 1,
	groups = { horse_armor = 45 },
})

minetest.register_alias("mobs_mc:iron_horse_armor", "vlf_mobitems:iron_horse_armor")
minetest.register_alias("mobs_mc:gold_horse_armor", "vlf_mobitems:gold_horse_armor")
minetest.register_alias("mobs_mc:diamond_horse_armor", "vlf_mobitems:diamond_horse_armor")

minetest.register_craftitem("vlf_mobitems:glow_ink_sac", {
	description = S("Glow Ink Sac"),
	_doc_items_longdesc = S("Use it to craft the Glow Item Frame."),
	_doc_items_usagehelp = S("Use the Glow Ink Sac and the normal Item Frame to craft the Glow Item Frame."),
	inventory_image = "extra_mobs_glow_ink_sac.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("vlf_mobitems:nametag", {
	description = S("Name Tag"),
	_tt_help = S("Give names to mobs").."\n"..S("Set name at anvil"),
	_doc_items_longdesc = S("A name tag is an item to name a mob."),
	_doc_items_usagehelp = S("Before you use the name tag, you need to set a name at an anvil. Then you can use the name tag to name a mob. This uses up the name tag."),
	inventory_image = "vlf_mobitems_nametag.png",
	wield_image = "vlf_mobitems_nametag.png",
	groups = { tool=1 },
})

minetest.register_alias("mobs:nametag", "vlf_mobitems:nametag")
minetest.register_alias("vlf_mobs:nametag", "vlf_mobitems:nametag")

-----------
-- Crafting
-----------

minetest.register_craft({
	output = "vlf_mobitems:leather",
	recipe = {
		{ "vlf_mobitems:rabbit_hide", "vlf_mobitems:rabbit_hide" },
		{ "vlf_mobitems:rabbit_hide", "vlf_mobitems:rabbit_hide" },
	}
})

minetest.register_craft({
	output = "vlf_mobitems:blaze_powder 2",
	recipe = {{"vlf_mobitems:blaze_rod"}},
})

minetest.register_craft({
	output = "vlf_mobitems:rabbit_stew",
	recipe = {
		{ "", "vlf_mobitems:cooked_rabbit", "", },
		{ "group:mushroom", "vlf_farming:potato_item_baked", "vlf_farming:carrot_item", },
		{ "", "vlf_core:bowl", "", },
	},
})

minetest.register_craft({
	output = "vlf_mobitems:rabbit_stew",
	recipe = {
		{ "", "vlf_mobitems:cooked_rabbit", "", },
		{ "vlf_farming:carrot_item", "vlf_farming:potato_item_baked", "group:mushroom", },
		{ "", "vlf_core:bowl", "", },
	},
})

minetest.register_craft({
	output = "vlf_mobitems:carrot_on_a_stick",
	recipe = {
		{ "vlf_fishing:fishing_rod", "", },
		{ "", "vlf_farming:carrot_item" },
	},
})

minetest.register_craft({
	output = "vlf_mobitems:carrot_on_a_stick",
	recipe = {
		{ "", "vlf_fishing:fishing_rod", },
		{ "vlf_farming:carrot_item", "" },
	},
})

minetest.register_craft({
	output = "vlf_mobitems:warped_fungus_on_a_stick",
	recipe = {
		{ "vlf_fishing:fishing_rod", "", },
		{ "", "vlf_crimson:warped_fungus" },
	},
})

minetest.register_craft({
	output = "vlf_mobitems:warped_fungus_on_a_stick",
	recipe = {
		{ "","vlf_fishing:fishing_rod", },
		{ "vlf_crimson:warped_fungus", "" },
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_mobitems:magma_cream",
	recipe = {"vlf_mobitems:blaze_powder", "vlf_mobitems:slimeball"},
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_mobitems:cooked_mutton",
	recipe = "vlf_mobitems:mutton",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_mobitems:cooked_rabbit",
	recipe = "vlf_mobitems:rabbit",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_mobitems:cooked_chicken",
	recipe = "vlf_mobitems:chicken",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_mobitems:cooked_beef",
	recipe = "vlf_mobitems:beef",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_mobitems:cooked_porkchop",
	recipe = "vlf_mobitems:porkchop",
	cooktime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_mobitems:blaze_rod",
	burntime = 120,
})

minetest.register_craft({
	output = "vlf_mobitems:slimeball 9",
	recipe = {{"vlf_core:slimeblock"}},
})

minetest.register_craft({
	output = "vlf_core:slimeblock",
	recipe = {{"vlf_mobitems:slimeball","vlf_mobitems:slimeball","vlf_mobitems:slimeball",},
		{"vlf_mobitems:slimeball","vlf_mobitems:slimeball","vlf_mobitems:slimeball",},
		{"vlf_mobitems:slimeball","vlf_mobitems:slimeball","vlf_mobitems:slimeball",}},
})

minetest.register_on_item_eat(function (hp_change, replace_with_item, itemstack, user, pointed_thing)	-- poisoning with spider eye
	if itemstack:get_name() == "vlf_mobitems:spider_eye" then
		vlf_entity_effects.give_entity_effect_by_level("poison", user, 1, 4)
	end
end)
