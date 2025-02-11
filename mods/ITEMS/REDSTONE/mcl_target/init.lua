mcl_target = {}

local S = core.get_translator("mcl_target")

function mcl_target.hit(pos, _)
	core.set_node(pos, {name = "mcl_target:target_on"})
end

local commdef = {
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	_mcl_redstone = {
		connects_to = function() return true end
	},
	description = S("Target"),
	groups = {hoey = 1},
	sounds = mcl_sounds.node_sound_dirt_defaults({
		footstep = {gain = 0.1, name = "default_grass_footstep"}
	}),
	tiles = {
		"mcl_target_target_top.png", "mcl_target_target_top.png", "mcl_target_target_side.png"
	}
}

core.register_node("mcl_target:target_off", table.merge(commdef, {
	_doc_items_longdesc = S("A target is a block that provides a temporary redstone charge when hit by a projectile."),
	_doc_items_usagehelp = S("Throw a projectile on the target to activate it."),
	_on_arrow_hit = function(pos, _) mcl_target.hit(pos, 1) end
}))

core.register_node("mcl_target:target_on", table.merge(commdef, {
	_doc_items_create_entry = false,
	_mcl_redstone = table.merge(commdef._mcl_redstone, {
		get_power = function(_, _) return 15, false end
	}),
	drop = "mcl_target:target_off",
	groups = table.merge(commdef.groups, {not_in_creative_inventory = 1}),
	on_construct = function(pos)
		local timer = core.get_node_timer(pos)
		timer:start(0.4)
	end,
	on_timer = function(pos, _)
		local node = core.get_node(pos)
		if node.name == "mcl_target:target_on" then
			core.set_node(pos, {name = "mcl_target:target_off"})
		end
	end
}))

core.register_craft({
	output = "mcl_target:target_off",
	recipe = {
		{"", "mcl_redstone:redstone", ""},
		{"mcl_redstone:redstone", "mcl_farming:hay_block", "mcl_redstone:redstone"},
		{"", "mcl_redstone:redstone", ""}
	}
})
