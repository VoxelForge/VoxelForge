--###################
--################### SILVERFISH
--###################

local S = minetest.get_translator("mobs_mc")
local mob_griefing = minetest.settings:get_bool("mobs_griefing", true)
local mob_class = mcl_mobs.mob_class

------------------------------------------------------------------------
--- Silverfish.
------------------------------------------------------------------------

local function check_light (_, _, artificial_light, _)
	if artificial_light > 11 then
		return false, "Too bright"
	end
	return true, ""
end

local silverfish = {
	description = S("Silverfish"),
	type = "monster",
	spawn_class = "hostile",
	passive = false,
	group_attack = true,
	reach = 1,
	hp_min = 8,
	hp_max = 8,
	xp_min = 5,
	xp_max = 5,
	armor = {fleshy = 100, arthropod = 100},
	head_eye_height = 0.13,
	collisionbox = {-0.2, -0.0, -0.2, 0.2, 0.3, 0.2},
	visual = "mesh",
	mesh = "mobs_mc_silverfish.b3d",
	textures = {
		{"mobs_mc_silverfish.png"},
	},
	visual_size = {x=3, y=3},
	sounds = {
		random = "mobs_mc_silverfish_idle",
		death = "mobs_mc_silverfish_death",
		damage = "mobs_mc_silverfish_hurt",
		distance = 16,
	},
	makes_footstep_sound = false,
	movement_speed = 5.0,
	animation = {
		stand_start = 0, stand_end = 20, stand_speed = 15,
		walk_start = 0, walk_end = 20, walk_speed = 30,
		run_start = 0, run_end = 20, run_speed = 50,
	},
	attack_type = "melee",
	damage = 1,
	check_light = check_light,
	climb_powder_snow = true,
	_reinforcement_time = 0,
	pace_interval = 0,
}

------------------------------------------------------------------------
-- Silverfish AI.
------------------------------------------------------------------------

local pr = PcgRandom (os.time () - 1140)

function silverfish:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	local t = self._reinforcement_time - dtime
	if t > -dtime then
		local self_pos = self.object:get_pos ()
		local p0 = vector.offset (self_pos, -10, -5, -10)
		local p1 = vector.offset (self_pos, 10, 5, 10)
		local silverfish_nodes
			= minetest.find_nodes_in_area (p0, p1, {"group:spawns_silverfish"})
		for _, p in pairs (silverfish_nodes) do
			minetest.remove_node (p)
			minetest.add_entity (p, "mobs_mc:silverfish")
			mcl_mobs.effect (p, 32, "mcl_particles_smoke.png",
					0.5, 1.5, 1, 1, 0)
			-- Spread silverfish revival over a number of
			-- server steps.
			if pr:next (1, 2) == 1 then
				break
			end
		end
	end
	self._reinforcement_time = t
end

function silverfish:receive_damage (mcl_reason, damage)
	local result = mob_class.receive_damage (self, mcl_reason, damage)
	if self.health > 0 then
		-- Potentially summon friends from nearby infested
		-- blocks unless mob griefing is disabled.
		if mob_griefing and (mcl_reason.type == "magic" or mcl_reason.direct) then
			self._reinforcement_time = 1.0
		end
	end
	return result
end

local directions = {
	vector.new (0, 0, 1),
	vector.new (0, 0, -1),
	vector.new (0, 1, 0),
	vector.new (0, -1, 0),
	vector.new (1, 0, 0),
	vector.new (-1, 0, 0),
}

local replacements = {
	["mcl_core:stone"] = "mcl_monster_eggs:monster_egg_stone",
	["mcl_core:cobble"] = "mcl_monster_eggs:monster_egg_cobble",
	["mcl_core:stonebrick"] = "mcl_monster_eggs:monster_egg_stonebrick",
	["mcl_core:stonebrickmossy"] = "mcl_monster_eggs:monster_egg_stonebrickmossy",
	["mcl_core:stonebrickcracked"] = "mcl_monster_eggs:monster_egg_stonebrickcracked",
	["mcl_core:stonebrickcarved"] = "mcl_monster_eggs:monster_egg_stonebrickcarved",
}

local scale_chance = mcl_mobs.scale_chance

local function silverfish_return_to_block (self, self_pos, dtime)
	if not mob_griefing then
		return false
	end
	local chance = scale_chance (50, dtime)
	if pr:next (1, chance) == 1 then
		local dir = directions[pr:next (1, #directions)]
		local node_pos = mcl_util.get_nodepos (self_pos)
		node_pos.x = node_pos.x + dir.x
		node_pos.y = node_pos.y + dir.y
		node_pos.z = node_pos.z + dir.z

		local node = minetest.get_node (node_pos)
		local replacement = replacements[node.name]
		if replacement then
			minetest.set_node (node_pos, {name = replacement})
			mcl_mobs.effect (self_pos, 32, "mcl_particles_smoke.png",
					0.5, 1.5, 1, 1, 0)
			self:safe_remove ()
			return true
		end
	end
	return false
end

silverfish.ai_functions = {
	mob_class.ascend_in_powder_snow,
	mob_class.check_attack,
	silverfish_return_to_block,
	mob_class.check_pace,
}

mcl_mobs.register_mob ("mobs_mc:silverfish", silverfish)
mcl_mobs.register_egg ("mobs_mc:silverfish", S("Silverfish"), "#6d6d6d", "#313131", 0)
