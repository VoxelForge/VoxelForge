--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local atann = math.atan
local atan = function(x)
	if not x or x ~= x then
		return 0
	else
		return atann(x)
	end
end

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
<<<<<<< HEAD
		{name = "vlc_fishing:fish_raw",
		chance = 1,
		min = 1,
		max = 1,},
		{name = "vlc_bone_meal:bone_meal",
=======
		{name = "vlf_fishing:fish_raw",
		chance = 1,
		min = 1,
		max = 1,},
		{name = "vlf_bone_meal:bone_meal",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 20,
		min = 1,
		max = 1,},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
    fly = true,
<<<<<<< HEAD
    fly_in = { "vlc_core:water_source", "vlcx_core:river_water_source" },
=======
    fly_in = { "vlf_core:water_source", "vlfx_core:river_water_source" },
>>>>>>> 3eb27be82 (change naming in mods)
	breathes_in_water = true,
	jump = false,
	view_range = 16,
	runaway = true,
	fear_height = 4,
	do_custom = function(self)
		--[[ this is supposed to make them jump out the water but doesn't appear to work very well
		self.object:set_bone_position("body", vector.new(0,1,0), vector.new(degrees(dir_to_pitch(self.object:get_velocity())) * -1 + 90,0,0))
		if minetest.get_item_group(self.standing_in, "water") ~= 0 then
			if self.object:get_velocity().y < 5 then
				self.object:add_velocity({ x = 0 , y = math.random(-.007, .007), z = 0 })
			end
		end
--]]
		for _,object in pairs(minetest.get_objects_inside_radius(self.object:get_pos(), 10)) do
			local lp = object:get_pos()
			local s = self.object:get_pos()
			local vec = {
				x = lp.x - s.x,
				y = lp.y - s.y,
				z = lp.z - s.z
			}
			if object and not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "mobs_mc:cod" then
				self.state = "runaway"
				self.object:set_rotation({x=0,y=(atan(vec.z / vec.x) + 3 * math.pi / 2) - self.rotate,z=0})
			end
		end
	end,
	on_rightclick = function(self, clicker)
		local bn = clicker:get_wielded_item():get_name()
<<<<<<< HEAD
		if bn == "vlc_buckets:bucket_water" or bn == "vlc_buckets:bucket_river_water" then
			self:safe_remove()
			clicker:set_wielded_item("vlc_buckets:bucket_cod")
			awards.unlock(clicker:get_player_name(), "vlc:tacticalFishing")
=======
		if bn == "vlf_buckets:bucket_water" or bn == "vlf_buckets:bucket_river_water" then
			self:safe_remove()
			clicker:set_wielded_item("vlf_buckets:bucket_cod")
			awards.unlock(clicker:get_player_name(), "vlf:tacticalFishing")
>>>>>>> 3eb27be82 (change naming in mods)
		end
	end
}

<<<<<<< HEAD
vlc_mobs.register_mob("mobs_mc:cod", cod)

vlc_mobs.spawn_setup({
=======
vlf_mobs.register_mob("mobs_mc:cod", cod)

vlf_mobs.spawn_setup({
>>>>>>> 3eb27be82 (change naming in mods)
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
<<<<<<< HEAD
vlc_mobs.register_egg("mobs_mc:cod", S("Cod"), "#c1a76a", "#e5c48b", 0)
=======
vlf_mobs.register_egg("mobs_mc:cod", S("Cod"), "#c1a76a", "#e5c48b", 0)
>>>>>>> 3eb27be82 (change naming in mods)
