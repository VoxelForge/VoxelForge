--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator(minetest.get_current_modname())

--###################
--################### cod
--###################

local cod = {
	description = S("Cod"),
	type = "animal",
	spawn_class = "water_ambient",
	can_despawn = true,
	passive = true,
	hp_min = 3,
	hp_max = 3,
	xp_min = 1,
	xp_max = 3,
	armor = 100,
	rotate = 180,
	spawn_in_group_min = 3,
	spawn_in_group = 8,
	tilt_swim = true,
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 0.79, 0.3},
	visual = "mesh",
	mesh = "extra_mobs_cod.b3d",
	textures = {
		{"extra_mobs_cod.png"}
	},
	sounds = {
	},
	animation = {
		stand_start = 1,
		stand_end = 20,
		walk_start = 1,
		walk_end = 20,
		run_start = 1,
		run_end = 20,
	},
	drops = {
		{name = "vlf_fishing:fish_raw",
		chance = 1,
		min = 1,
		max = 1,},
		{name = "vlf_bone_meal:bone_meal",
		chance = 20,
		min = 1,
		max = 1,},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
	swims = true,
	breathes_in_water = true,
	jump = false,
	view_range = 16,
	runaway = true,
	fear_height = 4,
	on_rightclick = function(self, clicker)
		local bn = clicker:get_wielded_item():get_name()
		if bn == "vlf_buckets:bucket_water" or bn == "vlf_buckets:bucket_river_water" then
			self:safe_remove()
			clicker:set_wielded_item("vlf_buckets:bucket_cod")
			awards.unlock(clicker:get_player_name(), "vlf:tacticalFishing")
		end
	end
}

vlf_mobs.register_mob("mobs_mc:cod", cod)

vlf_mobs.spawn_setup({
	name = "mobs_mc:cod",
	type_of_spawning = "water",
	dimension = "overworld",
	min_height = mobs_mc.water_level - 16,
	max_height = mobs_mc.water_level + 1,
	min_light = 0,
	max_light = minetest.LIGHT_MAX + 1,
	aoc = 7,
	chance = 750,
})

--spawn egg
vlf_mobs.register_egg("mobs_mc:cod", S("Cod"), "#c1a76a", "#e5c48b", 0)
