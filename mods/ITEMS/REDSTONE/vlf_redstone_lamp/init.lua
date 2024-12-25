local S = minetest.get_translator(minetest.get_current_modname())

local light = minetest.LIGHT_MAX

local commdef = {
	groups = {handy=1},
	is_ground_content = false,
	description = S("Redstone Lamp"),
	sounds = vlf_sounds.node_sound_glass_defaults(),
	_vlf_blast_resistance = 0.3,
	_vlf_hardness = 0.3,
	_vlf_redstone = {
		connects_to = function(node, dir)
			return true
		end,
		update = function(pos, node)
			if vlf_redstone.get_power(pos) ~= 0 then
				return {priority = 1, name = "vlf_redstone_lamp:lamp_on"}
			else
				return {delay = 2, name = "vlf_redstone_lamp:lamp_off"}
			end
		end,
	},
}

minetest.register_node("vlf_redstone_lamp:lamp_off", table.merge(commdef, {
	tiles = {"jeija_lightstone_gray_off.png"},
	_tt_help = S("Glows when powered by redstone power"),
	_doc_items_longdesc = S("Redstone lamps are simple redstone components which glow brightly (light level @1) when they receive redstone power.", light),
}))

minetest.register_node("vlf_redstone_lamp:lamp_on", table.merge(commdef, {
	tiles = {"jeija_lightstone_gray_on.png"},
	groups = table.merge(commdef.groups, {not_in_creative_inventory=1}),
	drop = "node vlf_redstone_lamp:lamp_off",
	light_source = light,
}))

minetest.register_craft({
	output = "vlf_redstone_lamp:lamp_off",
	recipe = {
		{"","vlf_redstone:redstone",""},
		{"vlf_redstone:redstone","vlf_nether:glowstone","vlf_redstone:redstone"},
		{"","vlf_redstone:redstone",""},
	}
})

-- Add entry alias for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "vlf_redstone_lamp:lamp_off", "nodes", "vlf_redstone_lamp:lamp_on")
end

