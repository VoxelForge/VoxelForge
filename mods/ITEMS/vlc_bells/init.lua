local S = minetest.get_translator(minetest.get_current_modname())

vlc_bells = {}

local has_vlc_wip = minetest.get_modpath("vlc_wip")

function vlc_bells.ring_once(pos)
	local alarm_time = (minetest.get_timeofday() * 24000) % 24000

	minetest.sound_play( "vlc_bells_bell_stroke", { pos = pos, gain = 1.5, max_hear_distance = 150,})
	local vv=minetest.get_objects_inside_radius(pos,150)
	for _,o in pairs(vv) do
		local entity = o:get_luaentity()
		if entity and entity.type and entity.type == "npc" then
			entity._last_alarm = alarm_time
		end
	end
end

minetest.register_node("vlc_bells:bell", {
	description = S("Bell"),
	inventory_image = "vlc_bells_bell.png",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -8/16,  8/16, -6/16,  8/16 },
			{ -6/16, -6/16, -6/16,  6/16,  6/16,  6/16 },
			{ -2/16,  6/16, -2/16,  2/16,  8/16,  2/16 },
		}
	},
	--tiles = { "blank.png" },
	tiles = {
		"vlc_bells_bell_top.png",
		"vlc_bells_bell_bottom.png",
		"vlc_bells_bell_side.png",
	},
	is_ground_content = false,
	groups = {pickaxey=2, deco_block=1, dig_by_piston=1 },
	sounds = vlc_sounds.node_sound_metal_defaults(),
	_vlc_blast_resistance = 5,
	_vlc_hardness = 5,
	on_rightclick = vlc_bells.ring_once,
	use_texture_alpha = "clip",
	mesecons = {effector = {
		action_on = vlc_bells.ring_once,
		rules = mesecon.rules.flat,
	}},
})

if has_vlc_wip then
	vlc_wip.register_wip_item("vlc_bells:bell")
end
