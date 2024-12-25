local S = minetest.get_translator(minetest.get_current_modname())

local firefly = {
	description = S("Firefly"),
	--type = "animal",
	spawn_class = "monster",
	can_despawn = true,
	lifetimer = 660,
	passive = false,
	hp_min = 1,
	hp_max = 1,
	collisionbox = {-0.01, -0.01, -0.01, 0.01, 0.01, 0.01},
	visual = "sprite",
	textures = {"mobs_mc_firefly_frame_1.png"},
	glow = 10,
	visual_size = {x = 0.125, y = 0.0625},
	damage = 0,
	walk_velocity = 0.3,
	run_velocity = 0.3,
	walk_chance = 100,
	pathfinding = 1,
	fall_damage = 0,
	sunlight_damage = 2,
	view_range = 8,
	fear_height = 0,
	movement_speed = 1.0,
	jump = false,
	fall_damage = 0,
	fly = true,
	floats = 2,
	airborne = true,
	gravity_drag = 0.1,
	timer = nil,
	pushable = false,
}

local frames = {}
for i = 0, 17 do
    frames[i] = "mobs_mc_firefly_frame_" .. i .. ".png"
end

function firefly:do_custom(dtime)
		self.timer = (self.timer or 0) + dtime
		local pos = self.object:get_pos()
		local light = minetest.get_node_light(pos)
		if self.timer > 0.1 and light <= 4 then  -- Change frame every 0.1 seconds
			self.timer = 0
			local frame = (self.frame or 0) + 1
			if frame > 17 then  -- Number of frames - 1
				frame = 0
			end
			self.object:set_properties({textures={frames[frame]}})
			self.frame = frame
			self:set_velocity(0.3)
		elseif self.timer > 0.1 and light >= 5 then
			self.object:set_properties({textures={"blank.png"}})
			self:set_velocity(0.0)
		else
			return
		end
	end

-- spawn eggs
vlf_mobs.register_egg("vlf_mob_rejects:firefly", S("Firefly"), "#113151", "#ddbfa2", 0)
vlf_mobs.register_mob("vlf_mob_rejects:firefly", firefly)

minetest.register_node(":mobs_mc:firefly_spawner", {
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

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mobs_mc:firefly_spawner",
	wherein         = {"air"},
	clust_scarcity = 28*28*28,
	clust_num_ores = 1,
	clust_size     = 2,
	y_min          = 3,
	y_max          = 300,
	biomes = {
            "SwampLand",
            "MangroveSwamp",
            "JungleEdge",
            "Jungle",
        }
})

minetest.register_lbm({
	name = "vlf_mob_rejects:firefly_spawn_lbm",
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
					vlf_mobs.spawn(pos, "vlf_mob_rejects:firefly")
				else
					minetest.remove_node(pos)
					vlf_mobs.spawn(pos, "vlf_mob_rejects:firefly")
				end
			else
				minetest.remove_node(pos) --Not in a biome that fireflies can spawn in, so no need to keep. Though technically the blocks should never be placed in any biome that isn't in the above table, however strange things can happen.
			end
		end
	end,
})
