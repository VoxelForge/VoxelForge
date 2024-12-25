local S = minetest.get_translator(minetest.get_current_modname())

vlf_bells = {}

function vlf_bells.ring_once(pos)
	local alarm_time = minetest.get_gametime ()

	minetest.sound_play( "vlf_bells_bell_stroke", { pos = pos, gain = 1.5, max_hear_distance = 150,})
	for o in minetest.objects_inside_radius(pos, 32) do
		local entity = o:get_luaentity()
		if entity and entity.name == "mobs_mc:villager" then
			entity._last_alarm_gmt = alarm_time
		end

		if entity and entity.is_mob and entity.raidmob then
			local distance = vector.distance (o:get_pos (), pos)
			if distance <= 48 then
				vlf_potions.give_effect ("glowing", o, o, 1, 3)
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
	groups = {pickaxey=2, deco_block=1, dig_by_piston=1, _vlf_partial = 2,},
	sounds = vlf_sounds.node_sound_metal_defaults(),
	_vlf_blast_resistance = 5,
	_vlf_hardness = 5,
	on_rightclick = vlf_bells.ring_once,
	use_texture_alpha = "clip",
	_vlf_redstone = {
		update = function(pos, node)
			local oldpowered = node.param2 ~= 0
			local powered = vlf_redstone.get_power(pos) ~= 0
			if powered and not oldpowered then
				vlf_bells.ring_once(pos)
			end

			minetest.swap_node(pos, {
				name = node.name,
				param2 = powered and 1 or 0,
			})
		end,
	},
})
