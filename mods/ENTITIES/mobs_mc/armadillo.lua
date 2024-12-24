local S = minetest.get_translator(minetest.get_current_modname())
local mob_class = vlf_mobs.mob_class
local blacklisted_entities = {"mobs_mc:zombie", "mobs_mc:baby_zombie", --[["mobs_mc:drowned", ]]"mobs_mc:phantom", "mobs_mc:husk", "mobs_mc:baby_husk", "mobs_mc:skeleton_horse",
				"mobs_mc:skeleton_horse_trap", "mobs_mc:stray", "mobs_mc:wither", "mobs_mc:witherskeleton", "mobs_mc:zombie_horse", "mobs_mc:villager_zombie",
				"mobs_mc:zombified_piglin", "mobs_mc:zoglin"}
local speed_threshold = 5.0
local revert_delay = 6
local check_delay = 3

local armadillo = {
	description = S("Armadillo"),
	type = "animal",
	can_despawn = false,
	passive = true,
	hp_min = 6,
	hp_max = 6,
	collisionbox = {-0.5, -0.0, -0.5, 0.5, 0.7, 0.5},
	visual = "mesh",
	mesh = "armadillo.b3d",
	textures = {"mobs_mc_armadillo.png"},
	visual_size = {x = 6.5, y = 7},
	animation = {
		stand_start = 220, stand_end = 221, stand_speed = 2,
		walk_start = 0, walk_end = 35, speed_normal = 50,
		--run_start = 0, run_end = 39, speed_run = 50,
		--punch_start = 50, punch_end = 59, punch_speed = 20,
	},
	sounds = {},
	--walk_velocity = 0.14,
	--run_velocity = 0.14,
	movement_speed = 1.4,
	walk_chance = 80,
	fall_damage = 10,
	view_range = 8,
	fear_height = 4,
	pathfinding = 1,
	jump = false,
	fly = false,
	makes_footstep_sound = false,
	scared = false,
	egg_timer = nil,
	on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local item_name = item:get_name()
		if item_name == "vlf_sus_nodes:brush" then
			minetest.add_item(self.object:get_pos(), "vlf_mobitems:armadillo_scute")
			if awards and awards.unlock and clicker then
				awards.unlock(clicker:get_player_name(), "vlf:brush_armadillo")
			end

			item:add_wear(65535 / 100 * 13)
			clicker:set_wielded_item(item)
		end
	end,
}

function armadillo:do_custom(dtime)
		local pos = self.object:get_pos()
		local objs = minetest.get_objects_inside_radius(pos, self.view_range)
		local changed_to_tb = false

		-- Function to check if a table contains a value
		local function table_contains(tbl, value)
			for _, v in ipairs(tbl) do
				if v == value then
					return true
				end
			end
			return false
		end


		for _, obj in ipairs(objs) do
			local lua_entity = obj:get_luaentity()

			if (obj:is_player() or (lua_entity and table_contains(blacklisted_entities, lua_entity.name))) then
				local velocity = obj:get_velocity()
				local speed = vector.length(velocity)

				if obj:is_player() and speed > speed_threshold then
					local dir_to_armadillo = vector.direction(obj:get_pos(), pos)
					local dot_product = vector.dot(velocity, dir_to_armadillo)

					if dot_product > 0 then
						self.scared = true
						changed_to_tb = true
						--self.walk_velocity = 0.0
						--self.run_velocity = 0.0
						self.movement_speed = 0.0
						self.object:set_animation({x = 60, y = 72}, 10, 0, false)
						minetest.after(0.25, function()
							self.object:set_properties({textures = {"mobs_mc_armadillo-hiding.png"}})
						end)
						break
					end
				elseif lua_entity then
					self.scared = true
					changed_to_tb = true
					--self.walk_velocity = 0.0
					--self.run_velocity = 0.0
					self.movement_speed = 0.0
					break
				end
			end
		end

		if not changed_to_tb and self.scared then
			--self.object:set_animation({x = 76, y = 78}, 10, 0, false)
			minetest.after(check_delay, function()
				self.scared = false
				--self.walk_velocity = 0.0
				--self.run_velocity = 0.0
				self.movement_speed = 0.0
				self.object:set_animation({x = 96, y = 156}, 10, 0, false)
			end)
			minetest.after(revert_delay, function()
				if not self.scared then
					self.animation = {
						stand_start = 180, stand_end = 216, stand_speed = 10,
						walk_start = 180, walk_end = 216, speed_normal = 10
					}
					self.object:set_animation({x = 180, y = 216}, 10, 0, false)
					--self.state = "walk"
					minetest.after(1, function()
						self.object:set_properties({textures = {"mobs_mc_armadillo.png"}})
						--self.walk_velocity = 0.14
						--self.run_velocity = 0.14
						self.movement_speed = 1.4
						self.state = "walk"
						self.animation = {
							stand_start = 220, stand_end = 221, stand_speed = 0,
							walk_start = 0, walk_end = 35, speed_normal = 50
						}
					end)
				end
			end)
		end
		self.egg_timer = (self.egg_timer or math.random(300, 600)) - dtime
		if self.egg_timer > 0 then
			return
		end
		self.egg_timer = nil
		local pos = self.object:get_pos()
		minetest.add_item(pos, "vlf_mobitems:armadillo_scute")
end

function armadillo:receive_damage(damage, vlf_reason)
		self.health = self.health - damage
		local changed_to_tb
		-- Blacklisted entity detected
		--self.object:set_properties({textures = {"mobs_mc_armadillo-hiding.png"}})
		self.scared = true
		changed_to_tb = true
		self:set_velocity(0.0)

		-- If no threats are detected, change back to t-c.png, then to t.png
		if not changed_to_tb and self.scared then
			minetest.after(check_delay, function()
				self.scared = false
				--self.object:set_properties({textures = {"mobs_mc_armadillo-peaking.png"}})
				self:set_velocity(0.0)
			end)
			minetest.after(revert_delay, function()
				-- Check if the armadillo is still not scared
				self.scared = false
				if not self.scared then
					--self.object:set_properties({textures = {"mobs_mc_armadillo.png"}})
					self:set_velocity(0.14)
				end
			end)
		end
end

armadillo.ai_functions = {
	scare,
	mob_class.check_pace
}

vlf_mobs.register_mob("mobs_mc:armadillo", armadillo)

vlf_mobs.spawn_setup({
	name = "mobs_mc:armadillo",
	dimension = "overworld",
	type_of_spawning = "ground",
	min_height = 1,
	min_light = 4,
	max_light = 15,
	aoc = 80,
	chance = 2400,
	biomes = {
		"Savanna",
		"SavannaM",
		"Savanna_beach",
		"Mesa",
		"MesaPlateauF",
		"MesaPlateauFM",
		"MesaPlateauF_grasstop",
		"MesaPlateauFM_grasstop",
		"MesaBryce",
	},
})

-- spawn eggs
vlf_mobs.register_egg("mobs_mc:armadillo", S("Armadillo"), "#A56C68", "#663939", 0)
