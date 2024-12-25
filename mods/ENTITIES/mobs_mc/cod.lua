--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator(minetest.get_current_modname())
local mob_class = vlf_mobs.mob_class

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
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 0.79, 0.3},
	head_eye_height = 0.195,
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
		{
			name = "vlf_fishing:fish_raw",
			chance = 1,
			min = 1,
			max = 1,
		},
		{
			name = "vlf_bone_meal:bone_meal",
			chance = 20,
			min = 1,
			max = 1,
		},
	},
	initialize_group = mob_class.school_init_group,
	runaway_from = {"players"},
	runaway_bonus_near = 1.6,
	runaway_bonus_far = 1.4,
	runaway_view_range = 8,
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
	swims = true,
	pace_height = 1.0,
	do_go_pos = vlf_mobs.mob_class.fish_do_go_pos,
	flops = true,
	breathes_in_water = true,
	movement_speed = 14.0,
	runaway = true,
	pace_chance = 40,
}

------------------------------------------------------------------------
-- Cod interaction.
------------------------------------------------------------------------

function cod:on_rightclick (clicker)
	local bn = clicker:get_wielded_item():get_name()
	if bn == "vlf_buckets:bucket_water" or bn == "vlf_buckets:bucket_river_water" then
		self:safe_remove()
		clicker:set_wielded_item("vlf_buckets:bucket_cod")
		awards.unlock(clicker:get_player_name(), "vlf:tacticalFishing")
	end
end

------------------------------------------------------------------------
-- Cod AI.
------------------------------------------------------------------------

cod.ai_functions = {
	mob_class.check_frightened,
	mob_class.check_avoid,
	mob_class.check_schooling,
	mob_class.check_pace,
}

vlf_mobs.register_mob ("mobs_mc:cod", cod)

------------------------------------------------------------------------
-- Cod spawning.
------------------------------------------------------------------------

vlf_mobs.spawn_setup ({
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
