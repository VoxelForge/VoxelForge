-- License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

local default_walk_chance = 50

local function reduce_armor_durability(self, damage)
	if self.armor_name and self.armor_durability then
		-- Reduce durability based on the damage value
		local wear_reduction = 1024 * damage
		self.armor_durability = self.armor_durability + wear_reduction

		-- Function to overlay crack textures
		local function overlay_cracked_texture(crack_texture)
			if self._wolf_armor then
				-- Combine the base armor texture with the cracked overlay
				local new_texture = self.base_texture[1] .. "^" .. crack_texture
				self.object:set_properties({textures = {new_texture}})
			end
		end
		-- Check if armor reaches different crack levels and update texture
		if self.armor_durability >= 65535 then  -- 65535 is the max wear value for a tool
			-- Armor is broken
			self.armor_name = nil
			self.armor_durability = nil
			self._wearing_armor = false
			self._wolf_armor = nil
			local ogroups = self.object:get_armor_groups()
			ogroups.fleshy = 100
			self.object:set_armor_groups(ogroups)
			self.object:set_properties({textures = {self._naked_texture}})  -- Revert to default texture
			minetest.chat_send_all("The wolf's armor has broken!")  -- Optional: notify players
		elseif self.armor_durability >= 61440 then  -- Cracked level 3 (60 durability)
			overlay_cracked_texture("mobs_mc_wolf_armor_crackiness_high.png")
		elseif self.armor_durability >= 43008 then  -- Cracked level 2 (40 durability)
			overlay_cracked_texture("mobs_mc_wolf_armor_crackiness_medium.png")
		elseif self.armor_durability >= 28672 then  -- Cracked level 1 (22 durability)
			overlay_cracked_texture("mobs_mc_wolf_armor_crackiness_low.png")
		end
	end
end

local pr = PseudoRandom(os.time()*10)

local food = {} -- [item_name] = heal
food["vlf_fishing:pufferfish_raw"] = 1
food["vlf_fishing:clownfish_raw"] = 1
food["vlf_mobitems:chicken"] = 2
food["vlf_mobitems:mutton"] = 2
food["vlf_fishing:fish_raw"] = 2
food["vlf_fishing:salmon_raw"] = 2
food["vlf_mobitems:porkchop"] = 3
food["vlf_mobitems:beef"] = 3
food["vlf_mobitems:rabbit"] = 3
food["vlf_mobitems:rotten_flesh"] = 4
food["vlf_mobitems:cooked_rabbit"] = 5
food["vlf_fishing:fish_cooked"] = 5
food["vlf_mobitems:cooked_mutton"] = 6
food["vlf_mobitems:cooked_chicken"] = 6
food["vlf_fishing:salmon_cooked"] = 6
food["vlf_mobitems:cooked_porkchop"] = 8
food["vlf_mobitems:cooked_beef"] = 8
food["vlf_mobitems:rabbit_stew"] = 10

local biome_textures = {
	["flat"] = "mobs_mc_wolf.png",
	["ColdTaiga"] = "mobs_mc_wolf_ashen.png",
	["ColdTaiga_beach"] = "mobs_mc_wolf_ashen.png",
	["ColdTaiga_beach_water"] = "mobs_mc_wolf_ashen.png",
	["MegaTaiga"] = "mobs_mc_wolf_black.png",
	["MegaSpruceTaiga"] = "mobs_mc_wolf_chestnut.png",
	["Taiga"] = "mobs_mc_wolf_pale.png",
	["Taiga_beach"] = "mobs_mc_wolf_pale.png",
	["Grove"] = "mobs_mc_wolf_snowy.png",
	["SavannaM"] = "mobs_mc_wolf_spotted.png",
	["MesaPlateauF_grasstop"] = "mobs_mc_wolf_striped.png",
	["Forest"] = "mobs_mc_wolf_woods.png",
}

local wolf_spawn_groups = {
	["mobs_mc_wolf.png"] = {min = 1, max = 3},
	["mobs_mc_wolf_ashen.png"] = {min = 4, max = 4},
	["mobs_mc_wolf_black.png"] = {min = 2, max = 4},
	["mobs_mc_wolf_chestnut.png"] = {min = 2, max = 4},
	["mobs_mc_wolf_pale.png"] = {min = 4, max = 4},
	["mobs_mc_wolf_snowy.png"] = {min = 1, max = 1},
	["mobs_mc_wolf_spotted.png"] = {min = 4, max = 8},
	["mobs_mc_wolf_striped.png"] = {min = 4, max = 8},
	["mobs_mc_wolf_woods.png"] = {min = 4, max = 4},
}

local function get_wolf_texture(pos)
	local biome_data = minetest.get_biome_data(pos)
	if biome_data then
		local biome_name = minetest.get_biome_name(biome_data.biome)
		return biome_textures[biome_name] or "mobs_mc_wolf.png"
	else
		minetest.log("error", "Failed to get biome data for position: " .. minetest.pos_to_string(pos))
		return "mobs_mc_wolf.png"
	end
end

local function add_collar(self, color)
    -- Default collar color if none provided
    if not color then
        color = "#FF0000"
    end

    -- Attempt to retrieve the current texture from the entity's properties
    local properties = self.object:get_properties()
    local texture

    if properties and properties.textures and #properties.textures > 0 then
        texture = properties.textures[1]
    else
        -- Fallback to base_texture if it exists
        texture = (self.base_texture and type(self.base_texture) == "table" and #self.base_texture > 0) and self.base_texture[1]
    end

    -- Ensure texture is never nil
    if not texture then
        minetest.log("error", "Texture is nil, using fallback texture.")
        texture = "mobs_mc_wolf.png"  -- Fallback texture if all else fails
    end

    -- Return the modified texture with collar color overlay
    return texture .. "^(mobs_mc_wolf_collar.png^[colorize:" .. color .. ":192)"
end


local default_spawn_group = {min = 1, max = 3}

local function get_spawn_group_amount(texture)
    return wolf_spawn_groups[texture] or default_spawn_group
end

-- Wolf
local wolf = {
	description = S("Wolf"),
	type = "animal",
	spawn_class = "passive",
	can_despawn = true,
	hp_min = 8,
	hp_max = 8,
	xp_min = 1,
	xp_max = 3,
	passive = false,
	group_attack = true,
	spawn_in_group = 1,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 0.84, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_wolf.b3d",
	textures = {
		{"mobs_mc_wolf.png"}, {"mobs_mc_wolf_ashen.png"}, {"mobs_mc_wolf_black.png"},
		{"mobs_mc_wolf_chestnut.png"}, {"mobs_mc_wolf_rusty.png"}, {"mobs_mc_wolf_snowy.png"},
		{"mobs_mc_wolf_spotted.png"}, {"mobs_mc_wolf_striped.png"}, {"mobs_mc_wolf_woods.png"}
	},
	makes_footstep_sound = true,
	head_swivel = "head.control",
	bone_eye_height = 3.5,
	head_eye_height = 1.1,
	horizontal_head_height=0,
	curiosity = 3,
	head_yaw="z",
	sounds = {
		attack = "mobs_mc_wolf_bark",
		war_cry = "mobs_mc_wolf_growl",
		damage = {name = "mobs_mc_wolf_hurt", gain=0.6},
		death = {name = "mobs_mc_wolf_death", gain=0.6},
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	pathfinding = 1,
	floats = 1,
	view_range = 16,
	walk_chance = default_walk_chance,
	walk_velocity = 2,
	run_velocity = 2.5,
	damage = 3,
	reach = 2,
	attack_type = "dogfight",
	fear_height = 4,
	texture_holder = "",
	on_rightclick = function(self, clicker)
		-- Try to tame wolf (intentionally does NOT use vlf_mobs.feed_tame)
		local tool = clicker:get_wielded_item()

		local dog, ent
		if tool:get_name() == "vlf_mobitems:bone" then

			minetest.sound_play("mobs_mc_wolf_take_bone", {object=self.object, max_hear_distance=16}, true)
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				tool:take_item()
				clicker:set_wielded_item(tool)
			end
			-- 1/3 chance of getting tamed
			if pr:next(1, 3) == 1 then
				local yaw = self.object:get_yaw()
				self.texture_holder = self.object:get_properties().textures[1]
				dog = vlf_util.replace_mob(self.object, "mobs_mc:dog")
				if dog and dog:get_pos() then
					dog:set_yaw(yaw)
					self._color = "unicolor_red"
					dog:set_properties({textures = {add_collar(self)}})
					ent = dog:get_luaentity()
					ent.owner = clicker:get_player_name()
					ent.tamed = true
					ent:set_animation("sit")
					ent.walk_chance = 0
					ent.jump = false
					ent.health = self.health
					-- cornfirm taming
					minetest.sound_play("mobs_mc_wolf_bark", {object=dog, max_hear_distance=16}, true)
					-- Replace wolf
				end
			end
		end
	end,


	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 60,
		run_start = 0, run_end = 40, run_speed = 100,
		sit_start = 45, sit_end = 45,
	},
	_child_animations = {
		stand_start = 46, stand_end = 46,
		walk_start = 46, walk_end = 86, walk_speed = 75,
		run_start = 46, run_end = 86, run_speed = 150,
		sit_start = 91, sit_end = 91,
	},
	jump = true,
	attacks_monsters = true,
	attack_animals = true,
	specific_attack = {
		"player",
		"mobs_mc:sheep",
		"mobs_mc:rabbit",
		"mobs_mc:skeleton",
		"mobs_mc:stray",
		"mobs_mc:witherskeleton",
	},
	avoid_from = { "mobs_mc:llama" },
	on_spawn = function(self, pos)
		local pos = self.object:get_pos()
		if pos then
			self.base_texture = {get_wolf_texture(pos)}
			self.object:set_properties({textures = self.base_texture})
			self.texture_holder = self.base_texture[1]

			local spawn_group = get_spawn_group_amount(self.base_texture[1])
			self.spawn_in_group = pr:next(spawn_group.min, spawn_group.max)
		else
			minetest.log("error", "Position is nil in on_spawn function.")
		end
	end,
}

vlf_mobs.register_mob("mobs_mc:wolf", wolf)

-- Tamed wolf

-- Collar colors
local colors = {
	["unicolor_black"] = "#000000",
	["unicolor_blue"] = "#0000BB",
	["unicolor_dark_orange"] = "#663300", -- brown
	["unicolor_cyan"] = "#01FFD8",
	["unicolor_dark_green"] = "#005B00",
	["unicolor_grey"] = "#C0C0C0",
	["unicolor_darkgrey"] = "#303030",
	["unicolor_green"] = "#00FF01",
	["unicolor_red_violet"] = "#FF05BB", -- magenta
	["unicolor_orange"] = "#FF8401",
	["unicolor_light_red"] = "#FF65B5", -- pink
	["unicolor_red"] = "#FF0000",
	["unicolor_violet"] = "#5000CC",
	["unicolor_white"] = "#FFFFFF",
	["unicolor_yellow"] = "#FFFF00",
	["unicolor_light_blue"] = "#B0B0FF",
}

local get_dog_textures = function(self, color)
	if colors[color] then
		return {add_collar(self, colors[color])}
	else
		return nil
	end
end

local function wolf_extra_texture(self, cstring)
	local base = self._naked_texture
	local armor = self._wolf_armor
	local textures = {}

	-- Apply armor overlay if equipped
	if armor and minetest.get_item_group(armor, "wolf_armor") > 0 then
		if cstring then
			textures[1] = base .. "^(" .. minetest.registered_items[armor]._wolf_overlay_image:gsub(".png$", ".png") .. "^[multiply:" .. cstring .. ")"
		else
			textures[1] = base .. "^" .. minetest.registered_items[armor]._wolf_overlay_image
		end
	else
		textures[1] = base
	end
	return textures
end

-- Tamed wolf (aka “dog”)
local dog = table.copy(wolf)
dog.description = S("Dog")
dog.type = "npc"
dog.can_despawn = false
dog.passive = true
dog.hp_min = 20
dog.hp_max = 20
dog.owner = ""
dog.order = "sit"
dog.state = "stand"
dog.owner_loyal = true
dog.follow_velocity = 3.2
dog.do_custom = mobs_mc.make_owner_teleport_function(12)
dog.attack_animals = nil
dog.specific_attack = nil
dog._wearing_armor = "No"

dog.set_armor = function(self, clicker)
	local w = clicker:get_wielded_item()
	local iname = w:get_name()

	-- Check if the armor is different from the current one
	if iname ~= self._wolf_armor then
		local cstring
		if minetest.get_item_group(iname, "armor_leather") > 0 then
			local m = w:get_meta()
			local cs = m:get_string("vlf_armor:color")
			cstring = cs ~= "" and cs or nil
		end

		-- Handle inventory adjustments
		if not minetest.is_creative_enabled(clicker:get_player_name()) then
			w:take_item()
			clicker:set_wielded_item(w)
			if self._wolf_armor then
				minetest.add_item(self.object:get_pos(), self._wolf_armor)
			end
		end

		-- Update armor properties
		local armor = minetest.get_item_group(iname, "wolf_armor")
		self._wearing_armor = true
		self._wolf_armor = iname
		self.armor = armor

		-- Update wolf armor groups
		local agroups = self.object:get_armor_groups()
		agroups.fleshy = self.armor or 100 -- Default to 100 if no armor
		self.object:set_armor_groups(agroups)
		self.base_texture = self.object:get_properties().textures[1]

		-- Set textures
		if not self._naked_texture then
			self._naked_texture = self.base_texture
		end
		local tex = wolf_extra_texture(self, cstring)
		self.base_texture = tex
		self.object:set_properties({textures = self.base_texture})

		-- Play equip sound if defined
		local def = w:get_definition()
		if def.sounds and def.sounds._vlf_armor_equip then
			minetest.sound_play({name = def.sounds._vlf_armor_equip}, {gain = 0.5, max_hear_distance = 12, pos = self.object:get_pos()}, true)
		end
		return true
	end
end


dog.on_rightclick = function(self, clicker)
	local item = clicker:get_wielded_item()

	if item:get_name() == "vlf_mobitems:armadillo_scute" and self._wolf_armor and self.armor_durability and self.armor_durability > 0 then
		-- Repair the armor by 8 points, but not beyond 64 points
		local repair_points = 8
		local cap_max = 56
		local max_durability = 64 * 1024  -- Max 64 points, scaled for wear values

		if self.armor_durability >= max_durability then
			minetest.chat_send_player(clicker:get_player_name(), S("The wolf's armor is already fully repaired."))
		else
			-- Apply repair
			--self.armor_durability = math.min(self.armor_durability - repair_points * 1024, max_durability)
			if max_durability - self.armor_durability > cap_max * 1024 then
				self.armor_durability = 0
				if awards and awards.unlock and clicker then
					awards.unlock(clicker:get_player_name(), "vlf:repair_wolf_armor")
				end
			else
				self.armor_durability = math.min(self.armor_durability - repair_points * 1024, max_durability)
			end

			-- Remove one scute from the itemstack
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				item:take_item(1)
				clicker:set_wielded_item(item)
			end

			minetest.chat_send_player(clicker:get_player_name(), S("The wolf's armor has been repaired by 8 points."))
		end

		return
	end

	-- Remove armor with shears
	if item:get_name() == "vlf_tools:shears" and self.armor_name and clicker:is_player() then
		-- Create an ItemStack with the remaining durability
		local armor = ItemStack(self.armor_name)
		armor:set_wear(self.armor_durability)
		if awards and awards.unlock and clicker then
			awards.unlock(clicker:get_player_name(), "vlf:remove_wolf_armor")
		end

		-- Add armor back to the player's inventory
		if not clicker:get_inventory():add_item("main", armor):is_empty() then
			minetest.add_item(clicker:get_pos(), armor)  -- Drop if inventory full
		end

		self.armor_name = nil
		self.armor_durability = nil
		self._wearing_armor = false
		self._wolf_armor = nil
		local ogroups = self.object:get_armor_groups()
		ogroups.fleshy = 100
		self.object:set_armor_groups(ogroups)
		self.base_texture = self._naked_texture
		self.object:set_properties({textures = {self._naked_texture}})  -- Revert to default texture
		self._wearing_armor = "False"

		return
	end
	-- Equip armor if not already wearing any
	--if item:get_name() == "vlf_mobitems:wolf_armor" and not self.armor_name then
	if string.find(item:get_name(), "wolf_armor") and not self.armor_name then
		self.armor_name = item:get_name()  -- Set the armor name property
		self.armor_durability = item:get_wear()  -- Set initial durability
		self:set_armor(clicker)

		-- Remove armor from player's inventory
		if not minetest.is_creative_enabled(clicker:get_player_name()) then
			item:take_item()
			clicker:set_wielded_item(item)
		end
	else

	if food[item:get_name()] ~= nil and self:feed_tame(clicker, food[item:get_name()], true, false) then return end

	if minetest.get_item_group(item:get_name(), "dye") == 1 then
		-- Dye (if possible)
		local dyed = false  -- Flag to check if a dye was applied
		for group, _ in pairs(colors) do
			-- Check if color is supported
			if minetest.get_item_group(item:get_name(), group) == 1 then
				if self._color == group then
					-- If the resulting color is the same as the current one, go to the else block
					break
				end
				self._color = group
				-- Dye collar
				local tex = get_dog_textures(self, self._color)
				if tex then
					self.base_texture = tex
					self.object:set_properties({textures = self.base_texture})
					if not minetest.is_creative_enabled(clicker:get_player_name()) then
						item:take_item()
						clicker:set_wielded_item(item)
					end
					dyed = true  -- Mark dye as applied
					break
				end
			end
		end
		-- If no dye was applied and the colors match, proceed with else
		if not dyed then
			return
		end
	else
		if not self.owner or self.owner == "" then
		-- Huh? This dog has no owner? Let's fix this! This should never happen.
			self.owner = clicker:get_player_name()
		end
		if not minetest.settings:get_bool("vlf_extended_pet_control",false) then
			self:toggle_sit(clicker,-0.4)
		end
	end
	end
end

dog.deal_damage = function (self, damage, mcl_reason)
	reduce_armor_durability(self, damage)
end

vlf_mobs.register_mob("mobs_mc:dog", dog)

vlf_mobs.spawn_setup({
	name = "mobs_mc:wolf",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 7,
	min_height = mobs_mc.water_level + 3,
	biomes = {
		"flat",
		"Forest",
		"Forest_beach",
		"Taiga",
		"Taiga_beach",
		"MegaSpruceTaiga",
		"MegaTaiga",
		"SavannaM",
		"MesaPlateauF",
		"ColdTaiga",
		"ColdTaiga_beach",
		"ColdTaiga_beach_water",
		"Jungle",
		"Grove"
	},
	chance = 800,
})

vlf_mobs.register_egg("mobs_mc:wolf", S("Wolf"), "#d7d3d3", "#ceaf96", 0)

minetest.register_abm({
	label = "Armadillo Scute Generation in Biomes Containing 'Savanna', 'Badlands', or 'Mesa'",
	nodenames = {"group:soil", "group:sand"},  -- Nodes to check that are not air (like soil or sand)
	neighbors = {"air"},  -- Checks nodes adjacent to air
	interval = 40,  -- Time interval in seconds
	chance = 800,  -- Chance for the action to occur
	catch_up = false,  -- Prevents the ABM from catching up if it was inactive for a while
	action = function(pos, node)
		local biome_data = minetest.get_biome_data(pos)
		if biome_data then
			local biome_name = minetest.get_biome_name(biome_data.biome):lower()
			-- Check if 'savanna', 'badlands', or 'mesa' is in the biome name (case insensitive)
			if string.find(biome_name, "savanna") or string.find(biome_name, "badlands") or string.find(biome_name, "mesa") then
				-- Check for nodes besides air in allowed biomes
				local positions = minetest.find_nodes_in_area(
				vector.add(pos, {x = -1, y = -1, z = -1}),
				vector.add(pos, {x = 1, y = 1, z = 1}),
				{"group:soil", "group:sand"}  -- Ensure it's not air; soil and sand groups are used here
				)
				if #positions > 0 then
				-- Place the armadillo scute item
				minetest.add_item(pos, "vlf_mobitems:armadillo_scute")
				end
			end
		end
	end,
})

