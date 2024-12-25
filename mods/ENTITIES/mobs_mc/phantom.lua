local MAX_SLEEP_INTERVAL = 3600
local S = minetest.get_translator(minetest.get_current_modname())
local mob_class = vlf_mobs.mob_class

local phantom = {
	description = S("Phantom"),
	type = "monster",
	spawn_class = "hostile",
	passive = false,
	damage = 1,
	hp_min = 20,
	hp_max = 20,
	xp_min = 5,
	xp_max = 5,
	attack_players = true,
	fly = true,
	fly_in = { "air" },
	fly_velocity = 7,
	reach = 3,
	armor = 10,
	collisionbox = { -0.4, -0.5, -0.4, 0.4, 0.5, 0.4 },
	visual = "mesh",
	mesh = "mobs_mc_phantom.b3d",
	visual_size = {x=3, y=3},
	textures = {
		{"mobs_mc_phantom.png"},
	},
	attack_type = "melee",
	gravity_drag = 0.0,
	floats = 1,
	physical = true,
	movement_speed = 14,
	ignited_by_sunlight = true,
	harmed_by_heal = true,
	airborne = true,
	sounds = {
	   -- random = "",
	},
	drops = {
		{name = "vlf_mobitems:phantom_membrane", chance = 2, min = 0, max = 1, looting = "common"},
	},
	view_range = 16,
	stepheight = 1.1,
	motion_step = mob_class.flying_step,
	fall_damage = false,
   --[[animation = {
				-- Dacing = 110,185
				-- Holding Item = 200,220
		stand_start = 0, stand_end = 0, stand_speed = 50,
		walk_start = 0, walk_end = 30, speed_normal = 50,
		run_start = 0, run_end = 30, speed_run = 50,
		punch_start = 0, punch_end = 30, punch_speed = 50,
	},]]
	animation = {
		stand_speed = 50,
		walk_speed = 50,
		fly_speed = 50,
		stand_start = 0,
		stand_end = 0,
		fly_start = 0,
		fly_end = 30,
		walk_start = 0,
		walk_end = 30,
	},
}

phantom.ai_functions = {
	mob_class.check_attack,
	mob_class.check_pace,
}

vlf_mobs.register_mob("mobs_mc:phantom", phantom)

vlf_mobs.register_egg("mobs_mc:phantom", "Phantom", "#162328", "#a078db", 0)

if minetest.settings:get_bool("vlf_phantoms_spawn", true) then
	local next_spawn_attempt = {}
	vlf_player.register_globalstep_slow(function (player)
		local tod = minetest.get_timeofday()
		if tod > 0.25 and tod < 0.75 then return end
		local gt = minetest.get_gametime()
		if next_spawn_attempt[player] and next_spawn_attempt[player] - gt > 0 then return end

		local pos = player:get_pos()

		local light = minetest.get_natural_light(pos, 0.5)
		if light and light < minetest.LIGHT_MAX then return end

		if vlf_worlds.pos_to_dimension(pos) ~= "overworld" then return end

		local m = player:get_meta()
		if gt - m:get_int("vlf_beds:last_sleep") < MAX_SLEEP_INTERVAL then return end

		vlf_mobs.spawn(vector.offset(pos, 0, math.random(13,25), 0), "mobs_mc:phantom")
		next_spawn_attempt[player] = gt + math.random(60,120)
	end)
end
