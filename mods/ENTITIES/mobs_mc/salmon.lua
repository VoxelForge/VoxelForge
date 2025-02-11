--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator(minetest.get_current_modname())
local mob_class = mcl_mobs.mob_class

--###################
--################### salmon
--###################

local salmon = {
	description = S("Salmon"),
	type = "animal",
	spawn_class = "water_ambient",
	can_despawn = true,
	passive = true,
	hp_min = 3,
	hp_max = 3,
	xp_min = 1,
	xp_max = 3,
	armor = 100,
	spawn_in_group = 5,
	tilt_swim = true,
	head_eye_height = 0.26,
	collisionbox = {-0.35, 0.0, -0.35, 0.35, 0.4, 0.35},
	visual = "mesh",
	mesh = "extra_mobs_salmon.b3d",
	textures = {
		{"extra_mobs_salmon.png"}
	},
	sounds = {
	},
	animation = {
		stand_start = 1, stand_end = 20,
		walk_start = 1, walk_end = 20,
		run_start = 1, run_end = 20,
	},
	drops = {
		{name = "mcl_fishing:salmon_raw",
		chance = 1,
		min = 1,
		max = 1,},
		{name = "mcl_bone_meal:bone_meal",
		chance = 20,
		min = 1,
		max = 1,},
	},
	runaway_from = {"players"},
	runaway_bonus_near = 1.6,
	runaway_bonus_far = 1.4,
	runaway_view_range = 8,
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
	swims = true,
	pace_height = 1.0,
	do_go_pos = mob_class.fish_do_go_pos,
	initialize_group = mob_class.school_init_group,
	_school_size = 5,
	breathes_in_water = true,
	flops = true,
	runaway = true,
	movement_speed = 14,
	pace_chance = 40,
}

------------------------------------------------------------------------
-- Salmon interaction.
------------------------------------------------------------------------

function salmon:on_rightclick (clicker)
	local bn = clicker:get_wielded_item():get_name()
	if bn == "mcl_buckets:bucket_water" or bn == "mcl_buckets:bucket_river_water" then
		self:safe_remove()
		clicker:set_wielded_item("mcl_buckets:bucket_salmon")
		awards.unlock(clicker:get_player_name(), "mcl:tacticalFishing")
	end
end

------------------------------------------------------------------------
-- Salmon AI.
------------------------------------------------------------------------

salmon.ai_functions = {
	mob_class.check_frightened,
	mob_class.check_avoid,
	mob_class.check_schooling,
	mob_class.check_pace,
}

mcl_mobs.register_mob ("mobs_mc:salmon", salmon)

------------------------------------------------------------------------
-- Salmon spawning.
------------------------------------------------------------------------

mcl_mobs.spawn_setup({
	name = "mobs_mc:salmon",
	type_of_spawning = "water",
	dimension = "overworld",
	min_height = mobs_mc.water_level - 16,
	max_height = mobs_mc.water_level + 1,
	min_light = 0,
	max_light = minetest.LIGHT_MAX + 1,
	aoc = 7,
	chance = 260,
})

--spawn egg
mcl_mobs.register_egg("mobs_mc:salmon", S("Salmon"), "#a00f10", "#0e8474", 0)
