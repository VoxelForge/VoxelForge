local S = minetest.get_translator(minetest.get_current_modname())

local light = minetest.LIGHT_MAX

minetest.register_node("mesecons_lightstone:lightstone_off", {
	tiles = {"jeija_lightstone_gray_off.png"},
	groups = {handy=1, mesecon_effector_off = 1, mesecon = 2},
	is_ground_content = false,
	description= S("Redstone Lamp"),
	_tt_help = S("Glows when powered by redstone power"),
	_doc_items_longdesc = S("Redstone lamps are simple redstone components which glow brightly (light level @1) when they receive redstone power.", light),
<<<<<<< HEAD
	sounds = vlc_sounds.node_sound_glass_defaults(),
=======
	sounds = vlf_sounds.node_sound_glass_defaults(),
>>>>>>> 3eb27be82 (change naming in mods)
	mesecons = {effector = {
		action_on = function(pos, node)
			minetest.swap_node(pos, {name="mesecons_lightstone:lightstone_on", param2 = node.param2})
		end,
		rules = mesecon.rules.alldirs,
	}},
<<<<<<< HEAD
	_vlc_blast_resistance = 0.3,
	_vlc_hardness = 0.3,
=======
	_vlf_blast_resistance = 0.3,
	_vlf_hardness = 0.3,
>>>>>>> 3eb27be82 (change naming in mods)
})

minetest.register_node("mesecons_lightstone:lightstone_on", {
	tiles = {"jeija_lightstone_gray_on.png"},
	groups = {handy=1, not_in_creative_inventory=1, mesecon = 2, opaque = 1},
	drop = "node mesecons_lightstone:lightstone_off",
	is_ground_content = false,
	paramtype = "light",
	light_source = light,
<<<<<<< HEAD
	sounds = vlc_sounds.node_sound_glass_defaults(),
=======
	sounds = vlf_sounds.node_sound_glass_defaults(),
>>>>>>> 3eb27be82 (change naming in mods)
	mesecons = {effector = {
		action_off = function(pos)
			local timer = minetest.get_node_timer(pos)
			timer:start(0.2)
		end,
		rules = mesecon.rules.alldirs,
	}},
	on_timer = function (pos)
		minetest.swap_node(pos, { name = "mesecons_lightstone:lightstone_off", param2 = minetest.get_node(pos).param2 })
		return false
	end,
<<<<<<< HEAD
	_vlc_blast_resistance = 0.3,
	_vlc_hardness = 0.3,
=======
	_vlf_blast_resistance = 0.3,
	_vlf_hardness = 0.3,
>>>>>>> 3eb27be82 (change naming in mods)
})

minetest.register_craft({
    output = "mesecons_lightstone:lightstone_off",
    recipe = {
	    {"","mesecons:redstone",""},
<<<<<<< HEAD
	    {"mesecons:redstone","vlc_nether:glowstone","mesecons:redstone"},
=======
	    {"mesecons:redstone","vlf_nether:glowstone","mesecons:redstone"},
>>>>>>> 3eb27be82 (change naming in mods)
	    {"","mesecons:redstone",""},
    }
})

-- Add entry alias for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_lightstone:lightstone_off", "nodes", "mesecons_lightstone:lightstone_on")
end

