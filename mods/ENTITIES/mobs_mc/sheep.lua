local S = minetest.get_translator ("mobs_mc")
local mob_griefing = minetest.settings:get_bool ("mobs_griefing", true)
local mob_class = vlf_mobs.mob_class

local sheared_textures = { "blank.png", "mobs_mc_sheep.png" }

local function unicolor_to_wool(unicolor_group)
	local d = vlf_dyes.unicolor_to_dye(unicolor_group)
	if d then
		return "vlf_wool:"..d:gsub("^vlf_dyes:","")
	end
	return "vlf_wool:white"
end

local function sheep_texture(unicolor_group)
	local color = vlf_dyes.colors["white"].rgb.."00"
	local d = vlf_dyes.unicolor_to_dye(unicolor_group)
	if d then
		color = vlf_dyes.colors[d:gsub("^vlf_dyes:","")].rgb.."D0"
	end
	return {
		"mobs_mc_sheep_fur.png^[colorize:"..color,
		"mobs_mc_sheep.png",
	}
end

local function get_sheep_drops(unicolor_group)
	local wool = unicolor_to_wool(unicolor_group)
	return {
		{
			name = "vlf_mobitems:mutton",
			 chance = 1,
			 min = 1,
			 max = 2,
			 looting = "common",
		},
		{
			name = wool,
			chance = 1,
			min = 1,
			max = 1,
			looting = "common",
		 },
	}
end

local sheep = {
	description = S("Sheep"),
	type = "animal",
	spawn_class = "passive",
	passive = true,
	hp_min = 8,
	hp_max = 8,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.45, -0.01, -0.45, 0.45, 1.29, 0.45},
	head_swivel = "head.control",
	bone_eye_height = 3.3,
	head_eye_height = 1.235,
	horizontal_head_height = -.7,
	curiosity = 6,
	head_yaw = "z",
	visual = "mesh",
	mesh = "mobs_mc_sheepfur.b3d",
	textures = {
		sheep_texture ("unicolor_white"),
	},
	color = "unicolor_white",
	makes_footstep_sound = true,
	movement_speed = 4.6,
	runaway = true,
	drops = get_sheep_drops (),
	sounds = {
		random = "mobs_sheep",
		death = "mobs_sheep",
		damage = "mobs_sheep",
		sounds = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 40,
		run_start = 0, run_end = 40, run_speed = 40,
		eat_start = 40, eat_end = 80, eat_loop = false,
		eat_speed = 10,
	},
	_child_animations = {
		stand_start = 81, stand_end = 81,
		walk_start = 81, walk_end = 121, walk_speed = 80,
		run_start = 81, run_end = 121, run_speed = 80,
		eat_start = 121, eat_end = 161, eat_loop = false,
		eat_speed = 10,
	},
	follow = {
		"vlf_farming:wheat_item",
	},
	follow_bonus = 1.1,
	follow_herd_bonus = 1.1,
}

------------------------------------------------------------------------
-- Sheep mechanics.
------------------------------------------------------------------------

function sheep:set_color (color)
	self.base_texture = sheep_texture (color)
	self:set_textures (self.base_texture)
	self.drops = get_sheep_drops (color)
	self.color = color
end

function sheep:on_spawn ()
	local r = math.random (0,100000)
	local color
	if r <= 81836 then -- 81.836%
		color = "unicolor_white"
	elseif r <= 81836 + 5000 then -- 5%
		color = "unicolor_grey"
	elseif r <= 81836 + 5000 + 5000 then-- 5%
		color = "unicolor_darkgrey"
	elseif r <= 81836 + 5000 + 5000 + 5000 then -- 5%
		color = "unicolor_black"
	elseif r <= 81836 + 5000 + 5000 + 5000 + 3000 then -- 3%
		color = "unicolor_dark_orange"
	else-- 0.164%
		color = "unicolor_light_red"
	end
	self:set_color (color)
end

function sheep:on_rightclick (clicker)
	if self:follow_holding(clicker)
		and self:feed_tame(clicker, 4, true, false) then
		return
	end

	local item = clicker:get_wielded_item()
	-- Dye sheep
	if minetest.get_item_group(item:get_name(), "dye") == 1 and not self.gotten then
		local idef = item:get_definition()
		if not minetest.is_creative_enabled(clicker:get_player_name()) then
			item:take_item()
			clicker:set_wielded_item(item)
		end
		local cgroup = "unicolor_"..vlf_dyes.colors[idef._color].unicolor
		self.color = cgroup
		self.base_texture = sheep_texture(cgroup)
		self:set_textures (self.base_texture)
		self.drops = get_sheep_drops(cgroup)
		return
	end
	if self.child then return end
	if minetest.get_item_group(item:get_name(), "shears") > 0 and not self.gotten then
		self.gotten = true
		local pos = self.object:get_pos()
		minetest.sound_play("vlf_tools_shears_cut", {pos = pos}, true)
		pos.y = pos.y + 0.5
		self.color = self.color or "unicolor_white"
		minetest.add_item(pos, ItemStack(unicolor_to_wool(self.color).." "..math.random(1,3)))
		self.base_texture = sheared_textures
		self:set_textures (self.base_texture)
		self.drops = {{ name = "vlf_mobitems:mutton", chance = 1, min = 1, max = 2 },}
		if not minetest.is_creative_enabled(clicker:get_player_name()) then
			item:add_wear(mobs_mc.shears_wear)
			clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
		end
		return
	end
end

function sheep:on_breed (parent1, parent2)
	local pos = parent1.object:get_pos()
	local child = vlf_mobs.spawn_child(pos, parent1.name)
	if child then
		local ent_c = child:get_luaentity()
		local color = { parent1.color, parent2.color }

		local dye1 = vlf_dyes.unicolor_to_dye(color[1])
		local dye2 = vlf_dyes.unicolor_to_dye(color[2])
		local output
		if dye1 and dye2 then
			output = minetest.get_craft_result({items = {dye1, dye2}, method="normal"})
		end
		if output and not output.item:is_empty() then
			local ndef = output.item:get_definition()
			local cgroup = "unicolor_"..vlf_dyes.colors[ndef._color].unicolor
			ent_c.color = cgroup
			ent_c.base_texture = sheep_texture(cgroup)
		else
			ent_c.color = color[math.random(2)]
		end

		ent_c.base_texture = sheep_texture(ent_c.color)
		ent_c.initial_color_set = true
		ent_c.tamed = true
		ent_c.owner = parent1.owner
		ent_c:set_textures (ent_c.base_texture)
		return false
	end
end

function sheep:_on_dispense (dropitem, pos, droppos, dropnode, dropdir)
	if minetest.get_item_group(dropitem:get_name(), "shears") > 0 then
		local pos = self.object:get_pos()
		self.base_texture = { "blank.png", "mobs_mc_sheep.png" }
		dropitem = self:use_shears({ "blank.png", "mobs_mc_sheep.png" }, dropitem)

		self.color = self.color or "unicolor_white"
		if self.drops[2] then
			minetest.add_item(pos, unicolor_to_wool(self.color) .. " " .. math.random(1, 3))
		end
		self.drops = {{ name = "vlf_mobitems:mutton", chance = 1, min = 1, max = 2 },}
		return dropitem
	end
	return mob_class._on_dispense (self, dropitem, pos, droppos, dropnode, dropdir)
end

------------------------------------------------------------------------
-- Sheep AI.
------------------------------------------------------------------------

function sheep:who_are_you_looking_at ()
	if self._grazing then
		self._locked_object = nil
	else
		mob_class.who_are_you_looking_at (self)
	end
end

local scale_chance = vlf_mobs.scale_chance

local function sheep_graze (self, self_pos, dtime)
	if not mob_griefing then
		return false
	end
	local base_chance = self.child and 50 or 1000
	if self._grazing then
		self._grazing = self._grazing - dtime
		if self._grazing <= 0.4
			and not self._node_destroyed then

			local node = minetest.get_node (self_pos)
			local consumed = false
			if node.name == "vlf_flowers:tallgrass" then
				minetest.remove_node (self_pos)
				consumed = true
			else
				local offset = vector.offset (self_pos, 0, -1, 0)
				local below = minetest.get_node (offset)
				if below.name == "vlf_core:dirt_with_grass" then
					minetest.set_node (offset, {
						name = "vlf_core:dirt",
					})
					consumed = true
				end
			end
			self._node_destroyed = true

			if consumed then
				if self.child then
					self.hornytimer
						= self.hornytimer + 1200
				end

				-- Reset textures.
				self.gotten = false
				self:set_color (self.color)
			end
		end
		if self._grazing <= 0 then
			self._grazing = nil
			return false
		end
		return true
	elseif math.random (scale_chance (base_chance, dtime)) == 1 then
		local node_valid = false
		local node = minetest.get_node (self_pos)
		if node.name == "vlf_flowers:tallgrass" then
			node_valid = true
		else
			local offset = vector.offset (self_pos, 0, -1, 0)
			local below = minetest.get_node (offset)
			if below.name == "vlf_core:dirt_with_grass" then
				node_valid = true
			end
		end

		if node_valid then
			self:cancel_navigation ()
			self:halt_in_tracks ()
			self._grazing = 2.0
			self._node_destroyed = false
			self:set_animation ("eat")
			return "_grazing"
		end
	end
	return false
end

sheep.ai_functions = {
	mob_class.check_frightened,
	mob_class.check_breeding,
	mob_class.check_following,
	mob_class.follow_herd,
	sheep_graze,
	mob_class.check_pace,
}

vlf_mobs.register_mob ("mobs_mc:sheep", sheep)

------------------------------------------------------------------------
-- Sheep spawning.
------------------------------------------------------------------------

vlf_mobs.spawn_setup ({
	name = "mobs_mc:sheep",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 9,
	min_height = mobs_mc.water_level + 3,
	biomes = {
		"flat",
		"IcePlainsSpikes",
		"ColdTaiga",
		"ColdTaiga_beach",
		"ColdTaiga_beach_water",
		"MegaTaiga",
		"MegaSpruceTaiga",
		"ExtremeHills",
		"ExtremeHills_beach",
		"ExtremeHillsM",
		"ExtremeHills+",
		"ExtremeHills+_snowtop",
		"StoneBeach",
		"Plains",
		"Plains_beach",
		"SunflowerPlains",
		"Taiga",
		"Taiga_beach",
		"Forest",
		"Forest_beach",
		"FlowerForest",
		"FlowerForest_beach",
		"BirchForest",
		"BirchForestM",
		"RoofedForest",
		"Savanna",
		"Savanna_beach",
		"SavannaM",
		"Jungle",
		"BambooJungle",
		"Jungle_shore",
		"JungleM",
		"JungleM_shore",
		"JungleEdge",
		"JungleEdgeM",
		"Swampland",
		"Swampland_shore",
		"CherryGrove",
	},
	chance = 120,
})

vlf_mobs.register_egg ("mobs_mc:sheep", S("Sheep"), "#e7e7e7", "#ffb5b5", 0)
