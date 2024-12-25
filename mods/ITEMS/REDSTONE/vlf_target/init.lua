local S = minetest.get_translator("vlf_target")

local mod_farming = minetest.get_modpath("vlf_farming")

vlf_target = {}

function vlf_target.hit(pos, time)
	minetest.set_node(pos, {name="vlf_target:target_on"})
end

local commdef = {
	description = S("Target"),
	tiles = {"vlf_target_target_top.png", "vlf_target_target_top.png", "vlf_target_target_side.png"},
	groups = {hoey = 1},
	sounds = vlf_sounds.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.1},
	}),
	_vlf_blast_resistance = 0.5,
	_vlf_hardness = 0.5,
	_vlf_redstone = {
		connects_to = function()
			return true
		end,
	},
}

minetest.register_node("vlf_target:target_off", table.merge(commdef, {
	_doc_items_longdesc = S("A target is a block that provides a temporary redstone charge when hit by a projectile."),
	_doc_items_usagehelp = S("Throw a projectile on the target to activate it."),
	_on_arrow_hit = function(pos, arrowent)
		vlf_target.hit(pos, 1) --10 redstone ticks
	end,
	_vlf_blast_resistance = 0.5,
	_vlf_hardness = 0.5,
}))

minetest.register_node("vlf_target:target_on", table.merge(commdef, {
	_doc_items_create_entry = false,
	groups = table.merge(commdef.groups, {not_in_creative_inventory = 1}),
	drop = "vlf_target:target_off",
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(0.4)
	end,
	on_timer = function(pos, elapsed)
		local node = minetest.get_node(pos)
		if node.name == "vlf_target:target_on" then --has not been dug
			minetest.set_node(pos, {name="vlf_target:target_off"})
		end
	end,
	_vlf_redstone = table.merge(commdef._vlf_redstone, {
		get_power = function(node, dir)
			return 15, false
		end,
	}),
}))


if mod_farming then
	minetest.register_craft({
		output = "vlf_target:target_off",
		recipe = {
			{"",                  "vlf_redstone:redstone",     ""},
			{"vlf_redstone:redstone", "vlf_farming:hay_block", "vlf_redstone:redstone"},
			{"",                  "vlf_redstone:redstone",     ""},
		},
	})
end
