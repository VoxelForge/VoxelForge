local S = minetest.get_translator(minetest.get_current_modname())

vlf_bells = {}

function vlf_bells.ring_once(pos)
	local alarm_time = (minetest.get_timeofday() * 24000) % 24000

	minetest.sound_play( "vlf_bells_bell_stroke", { pos = pos, gain = 1.5, max_hear_distance = 150,})
	local vv=minetest.get_objects_inside_radius(pos,150)
	for _,o in pairs(vv) do
		local entity = o:get_luaentity()
		if entity and entity.type and entity.type == "npc" then
		    entity._last_alarm = alarm_time
		end

		if entity and entity.is_mob and entity.raidmob then
		    local distance = vector.distance (o:get_pos (), pos)
		    if distance <= 48 then
			vlf_entity_effects.give_entity_effect ("glowing", o, o, 1, 3)
		    end
		end
	end
end

minetest.register_node("vlf_bells:bell", {
	description = S("Bell"),
	inventory_image = "vlf_bells_bell.png",
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
		"vlf_bells_bell_top.png",
		"vlf_bells_bell_bottom.png",
		"vlf_bells_bell_side.png",
	},
	is_ground_content = false,
	groups = {pickaxey=2, deco_block=1, dig_by_piston=1 },
	sounds = vlf_sounds.node_sound_metal_defaults(),
	_vlf_blast_resistance = 5,
	_vlf_hardness = 5,
	on_rightclick = vlf_bells.ring_once,
	use_texture_alpha = "clip",
	mesecons = {entity_effector = {
		action_on = vlf_bells.ring_once,
		rules = mesecon.rules.flat,
	}},
})
