-- LICENSE FOR CODE: GPL 3.0
local S = minetest.get_translator(minetest.get_current_modname())

vlf_mobs.register_mob("mobs_mc:firefly", {
	description = S("Firefly"),
	type = "animal",
	--spawn_class = "ambient",
	can_despawn = true,
	lifetimer = 660, -- 11 minutes of lifetime. Or just shy of one full night.
	passive = true,
	hp_min = 1,
	hp_max = 1,
	collisionbox = {-0.01, -0.01, -0.01, 0.01, 0.01, 0.01},
	visual = "sprite",
	textures = {"mobs_mc_firefly_frame_1.png"},
	glow = 10,
	visual_size = {x = 0.125, y = 0.0625},
	walk_velocity = 0.3,
	run_velocity = 0.3,
	walk_chance = 100,
	fall_damage = 0,
	sunlight_damage = 2,
	view_range = 8,
	fear_height = 0,
	jump = false,
	fly = true,
	do_custom = mobs_mc.firefly_animation()
})

-- spawn eggs
vlf_mobs.register_egg("mobs_mc:firefly", S("Firefly"), "#113151", "#ddbfa2", 0)

minetest.register_node("mobs_mc:firefly_spawner", {
	description = "Firefly Spawner",
	drawtype = "airlike",
	tiles = {"blank.png"},
	groups = {not_in_creative_inventory=1},
	is_ground_content = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	floodable = false,
	use_texture_alpha = "clip",
	light_propagates = true,
	sunlight_propagates = true,
	post_effect_color = {a=0},
})

minetest.register_lbm({
	name = "mobs_mc:firefly_spawn_lbm",
	nodenames = {"mobs_mc:firefly_spawner"},
	run_at_every_load = true,
	action = function(pos, node, metadata, run_at_every_load)
		local biomes = {
			"SwampLand",
			"MangroveSwamp",
			"JungleEdge",
			"Jungle",
		}
		local light = minetest.get_node_light(pos)
		local biome_data = minetest.get_biome_data(pos)
		local biome_name = minetest.get_biome_name(biome_data.biome)
		local biome_match = false
		for _, biome in ipairs(biomes) do
			if biome_name == biome then
				biome_match = true
				break
			end
		end
		if light <= 4 then
			if biome_match then
				local pos_below = {x=pos.x, y=pos.y-1, z=pos.z}
				if minetest.get_node(pos_below).name == "air" or minetest.get_node(pos_below).name == "mobs_mc:firefly_spawner" then
					vlf_mobs.spawn(pos, "mobs_mc:firefly")
				else
					minetest.remove_node(pos)
					vlf_mobs.spawn(pos, "mobs_mc:firefly")
				end
			else
				minetest.remove_node(pos) --Not in a biome that fireflies can spawn in, so no need to keep. Though technically the blocks should never be placed in any biome that isn't in the above table, however strange things can happen.
			end
		end
	end,
})
