---------------
---- Honey ----
---------------

vlf_honey = {}

function vlf_honey.particles(pos, texture)
	--local pos = pointed_thing.under
	minetest.add_particlespawner({
		amount = 8,
		time = 1,
		minpos = vector.subtract(pos, 1),
		maxpos = vector.add(pos,1),
		minvel = vector.zero(),
		maxvel = vector.zero(),
		minacc = vector.zero(),
		maxacc = vector.zero(),
		minexptime = 0.5,
		maxexptime = 1,
		minsize = 1,
		maxsize = 2.5,
		collisiondetection = false,
		vertical = false,
		texture = texture or "vlf_copper_anti_oxidation_particle.png",
		glow = 5,
	})
end

-- Variables
local S = minetest.get_translator(minetest.get_current_modname())

-- Honeycomb
minetest.register_craftitem("vlf_honey:honeycomb", {
	description = S("Honeycomb"),
	_doc_items_longdesc = S("Used to craft beehives and protect copper blocks from further oxidation."),
	_doc_items_usagehelp = S("Use on copper blocks to prevent further oxidation."),
	inventory_image = "vlf_honey_honeycomb.png",
	groups = { craftitem = 1, preserves_copper = 1 },
})

minetest.register_node("vlf_honey:honeycomb_block", {
	description = S("Honeycomb Block"),
	_doc_items_longdesc = S("Honeycomb Block. Used as a decoration."),
	tiles = {
		"vlf_honey_honeycomb_block.png"
	},
	is_ground_content = false,
	groups = { handy = 1, deco_block = 1 },
	_vlf_blast_resistance = 0.6,
	_vlf_hardness = 0.6,
})

-- Honey
minetest.register_craftitem("vlf_honey:honey_bottle", {
	description = S("Honey Bottle"),
	_doc_items_longdesc = S("Honey Bottle is used to craft honey blocks and to restore hunger points."),
	_doc_items_usagehelp = S("Drinking will restore 6 hunger points. Can also be used to craft honey blocks."),
	inventory_image = "vlf_honey_honey_bottle.png",
	groups = { craftitem = 1, food = 3, eatable = 6, can_eat_when_full=1 },
	on_place = minetest.item_eat(6, "vlf_potions:glass_bottle"),
	on_secondary_use = minetest.item_eat(6, "vlf_potions:glass_bottle"),
	_vlf_saturation = 1.2,
	stack_max = 16,
})

minetest.register_node("vlf_honey:honey_block", {
	description = S("Honey Block"),
	_doc_items_longdesc = S("Honey Block. Used as a decoration and in redstone. Is sticky on some sides."),
	tiles = {"vlf_honey_block_side.png"},
	is_ground_content = false,
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "blend" or true,
	groups = { handy = 1, deco_block = 1, fall_damage_add_percent = -80, _vlf_partial = 2, },
	paramtype = "light",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4, -0.4, -0.4, 0.4, 0.4, 0.4},
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		}
	},
	selection_box = {
		type = "regular",
	},
	_vlf_blast_resistance = 0,
	_vlf_hardness = 0,
	_vlf_pistons_sticky = function(node, node_to, dir)
		return node_to.name ~= "vlf_core:slimeblock"
	end,
})

-- Crafting
minetest.register_craft({
	output = "vlf_honey:honeycomb_block",
	recipe = {
		{ "vlf_honey:honeycomb", "vlf_honey:honeycomb" },
		{ "vlf_honey:honeycomb", "vlf_honey:honeycomb" },
	},
})

minetest.register_craft({
	output = "vlf_honey:honey_block",
	recipe = {
		{ "vlf_honey:honey_bottle", "vlf_honey:honey_bottle" },
		{ "vlf_honey:honey_bottle", "vlf_honey:honey_bottle" },
	},
	replacements = {
		{ "vlf_honey:honey_bottle", "vlf_potions:glass_bottle" },
		{ "vlf_honey:honey_bottle", "vlf_potions:glass_bottle" },
		{ "vlf_honey:honey_bottle", "vlf_potions:glass_bottle" },
		{ "vlf_honey:honey_bottle", "vlf_potions:glass_bottle" },
	},
})

minetest.register_craft({
	output = "vlf_honey:honey_bottle 4",
	recipe = {
		{ "vlf_potions:glass_bottle", "vlf_potions:glass_bottle", "vlf_honey:honey_block" },
		{ "vlf_potions:glass_bottle", "vlf_potions:glass_bottle", "" },
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_core:sugar 3",
	recipe = { "vlf_honey:honey_bottle" },
	replacements = {
		{ "vlf_honey:honey_bottle", "vlf_potions:glass_bottle" },
	},
})

function vlf_honey.wax_block(pos, node, player, itemstack, pointed_thing)
	-- prevent modification of protected nodes.
	if vlf_util.check_position_protection(pos, player) then
		return
	end
	local def = minetest.registered_nodes[node.name]

	if player:get_player_control().sneak then
		if def and def._vlf_waxed_variant then
			if def.groups.door == 1 then
				if node.name:find("_b_") then
					local top_pos = { x = pos.x, y = pos.y + 1, z = pos.z }
					minetest.swap_node(top_pos, { name = def._vlf_waxed_variant:gsub("_b_", "_t_"), param2 = node.param2 })
				elseif node.name:find("_t_") then
					local bot_pos = { x = pos.x,  y = pos.y - 1, z = pos.z }
					minetest.swap_node(bot_pos, { name = def._vlf_waxed_variant:gsub("_t_", "_b_"), param2 = node.param2 })
				end
			end
		else
			return
		end
	else
		if def and def.on_rightclick then
			return def.on_rightclick(pos, node, player, itemstack, pointed_thing)
		end
	end
	if def._vlf_waxed_variant then
		node.name = def._vlf_waxed_variant
		minetest.swap_node(pos, node)
		vlf_honey.particles(pos, "vlf_copper_anti_oxidation_particle.png^[colorize:#E58A14:125")
		awards.unlock(player:get_player_name(), "vlf:wax_on")
		if not minetest.is_creative_enabled(player:get_player_name()) then
			itemstack:take_item()
		end
		return itemstack
	end
end
