local S = minetest.get_translator("vlc_target")

local mod_farming = minetest.get_modpath("vlc_farming")

vlc_target = {}

function vlc_target.hit(pos, time)
	minetest.set_node(pos, {name="vlc_target:target_on"})
	mesecon.receptor_on(pos, mesecon.rules.alldirs)

	local timer = minetest.get_node_timer(pos)
	timer:start(time)
end

minetest.register_node("vlc_target:target_off", {
	description = S("Target"),
	_doc_items_longdesc = S("A target is a block that provides a temporary redstone charge when hit by a projectile."),
	_doc_items_usagehelp = S("Throw a projectile on the target to activate it."),
	tiles = {"vlc_target_target_top.png", "vlc_target_target_top.png", "vlc_target_target_side.png"},
	groups = {hoey = 1},
	sounds = vlc_sounds.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.1},
	}),
	mesecons = {
		receptor = {
			state = mesecon.state.off,
			rules = mesecon.rules.alldirs,
		},
	},
	_on_arrow_hit = function(pos, arrowent)
		vlc_target.hit(pos, 1) --10 redstone ticks
	end,
	_vlc_blast_resistance = 0.5,
	_vlc_hardness = 0.5,
})

minetest.register_node("vlc_target:target_on", {
	description = S("Target"),
	_doc_items_create_entry = false,
	tiles = {"vlc_target_target_top.png", "vlc_target_target_top.png", "vlc_target_target_side.png"},
	groups = {hoey = 1, not_in_creative_inventory = 1},
	drop = "vlc_target:target_off",
	sounds = vlc_sounds.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.1},
	}),
	on_timer = function(pos, elapsed)
		local node = minetest.get_node(pos)
		if node.name == "vlc_target:target_on" then --has not been dug
			minetest.set_node(pos, {name="vlc_target:target_off"})
			mesecon.receptor_off(pos, mesecon.rules.alldirs)
		end
	end,
	mesecons = {
		receptor = {
			state = mesecon.state.on,
			rules = mesecon.rules.alldirs,
		},
	},
	_vlc_blast_resistance = 0.5,
	_vlc_hardness = 0.5,
})


if mod_farming then
	minetest.register_craft({
		output = "vlc_target:target_off",
		recipe = {
			{"",                  "mesecons:redstone",     ""},
			{"mesecons:redstone", "vlc_farming:hay_block", "mesecons:redstone"},
			{"",                  "mesecons:redstone",     ""},
		},
	})
end
