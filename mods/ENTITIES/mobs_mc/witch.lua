--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### WITCH
--###################

local entity_effect_props = {
    visual = "wielditem",
    visual_size = { x = 0.3 / 5, y = 0.3 / 5, },
    physical = false,
    pointable = false,
    wield_item = "vlf_entity_effects:water",
}

local witch_entity_effect_entity = {
    initial_properties = entity_effect_props,
    on_step = function (self, dtime)
	local parent = self.object:get_attach ()
	if not parent then
	    self.object:remove ()
	    return
	end
    end,
}

local witch_base_drops = {
    {name = "vlf_entity_effects:glass_bottle", chance = 8, min = 0, max = 2, looting = "common",},
    {name = "vlf_nether:glowstone_dust", chance = 8, min = 0, max = 2, looting = "common",},
    {name = "vlf_mobitems:gunpowder", chance = 8, min = 0, max = 2, looting = "common",},
    {name = "mesecons:redstone", chance = 8, min = 0, max = 2, looting = "common",},
    {name = "vlf_mobitems:spider_eye", chance = 8, min = 0, max = 2, looting = "common",},
    {name = "vlf_core:sugar", chance = 8, min = 0, max = 2, looting = "common",},
    {name = "vlf_core:stick", chance = 4, min = 0, max = 2, looting = "common",},
}

minetest.register_entity ("mobs_mc:witch_entity_effect", witch_entity_effect_entity)

local function witch_equip_entity_effect (self, entity_effect)
    self:add_physics_factor ("walk_velocity", "mobs_mc:witch_entity_effect_penalty", 0.75)
    self:add_physics_factor ("run_velocity", "mobs_mc:witch_entity_effect_penalty", 0.75)

    self._held_entity_effect = entity_effect
    local object = minetest.add_entity (self.object:get_pos (),
					"mobs_mc:witch_entity_effect")
    if object then
	object:set_properties ({ wield_item = entity_effect, })
	object:set_attach (self.object, "body",
			   { x = 0, y = 1.65, z = 1.2, },
			   vector.zero ())
	self._held_entity_effect_object = object
    end
    -- Must wait 1.5 seconds before consuming this entity_effect.
    self._witch_entity_effect_check = 0
    -- Arrange that there be a chance of the entity_effect being dropped with
    -- this witch.
    local copy = table.copy (witch_base_drops)
    copy[#copy] = { name = entity_effect, chance = 11, min = 1, max = 1, }
    self.drops = copy
end

local function witch_consume_entity_effect (self, entity_effect)
    self:remove_physics_factor ("walk_velocity", "mobs_mc:witch_entity_effect_penalty")
    self:remove_physics_factor ("run_velocity", "mobs_mc:witch_entity_effect_penalty")
    vlf_entity_effects.consume_entity_effect (self.object, entity_effect, 0, 0)
    if self._held_entity_effect_object then
	self._held_entity_effect_object:remove ()
	self._held_entity_effect_object = nil
    end
    -- Reset the timer.
    self._witch_entity_effect_check = 0
    self._held_entity_effect = nil
    -- Play a sound.
    local sound = {
	max_hear_distance = 12,
	gain = 1.0,
	pitch = 1 + math.random (-10, 10) * 0.005,
	object = self.object,
    }
    minetest.sound_play ("survival_thirst_drink", sound, true)
    self.drops = witch_base_drops
end

local witch_entity_effect_items = {
    {
	entity_effect = "vlf_entity_effects:water_breathing",
	test = function (self)
	    local head_nodedef = minetest.registered_nodes[self.head_in]
	    return (not vlf_entity_effects.has_effect (self.object,
						"water_breathing")
		    and head_nodedef and head_nodedef.drowning > 0)
	end,
	chance = 15,
    },
    {
	entity_effect = "vlf_entity_effects:fire_resistance",
	test = function (self)
	    return (vlf_burning.is_burning (self.object)
		    and not vlf_entity_effects.has_effect (self.object,
						    "fire_resistance"))
	end,
	chance = 15,
    },
    {
	entity_effect = "vlf_entity_effects:healing",
	test = function (self)
	    return self.health < self.object:get_properties ().hp_max
	end,
	chance = 5,
    },
    {
	entity_effect = "vlf_entity_effects:swiftness",
	test = function (self)
	    if self.attack then
		if vlf_entity_effects.has_effect (self.object, "swiftness") then
		    return false
		end
		local pos = self.attack:get_pos ()
		local dist
		    = pos and vector.distance (pos, self.object:get_pos ())
		if pos and dist > 11 then
		    return true
		end
		return false
	    end
	end,
	chance = 50,
    },
}

local function check_behind (self, obj_pos, target_pos)
    local look_dir = self.object:get_yaw ()
    local v = { z = math.cos (look_dir), y = 0, x = -math.sin (look_dir), }
    v = vector.normalize (v)
    local x = vector.direction (obj_pos, target_pos)

    -- Dot product.
    return vector.dot (v, x) <= 0
end

vlf_mobs.register_mob("mobs_mc:witch", {
	description = S("Witch"),
	type = "monster",
	spawn_class = "hostile",
	can_despawn = true,
	hp_min = 26,
	hp_max = 26,
	xp_min = 5,
	xp_max = 5,
	spawn_in_group = 1,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	doll_size_override = { x = 0.95, y = 0.95 },
	visual = "mesh",
	mesh = "mobs_mc_witch.b3d",
	textures = {
		{"mobs_mc_witch.png"},
	},
	visual_size = {x=2.75, y=2.75},
	makes_footstep_sound = true,
	damage = 2,
	reach = 2,
	walk_velocity = 1,
	run_velocity = 1.4,
	pathfinding = 1,
	group_attack = true,
	attack_type = "dogshoot",
	shoot_interval = 2.5,
	shoot_offset = 1,
	dogshoot_switch = 1,
	dogshoot_count_max = 1.8,
	shooter_avoid_enemy = true,
	strafes = true,
	_shoot_while_strafing = false,
	max_drops = 3,
	drops = witch_base_drops,
	-- TODO: sounds
	animation = {
		speed_normal = 30,
		speed_run = 60,
		stand_start = 0,
		stand_end = 0,
		walk_start = 0,
		walk_end = 40,
		run_start = 0,
		run_end = 40,
		hurt_start = 85,
		hurt_end = 115,
		death_start = 117,
		death_end = 145,
		shoot_start = 50,
		shoot_end = 82,
	},
	view_range = 16,
	fear_height = 4,
	avoid_distance = 6,
	_witch_entity_effect_check = 0,
	do_attack = function (self, obj)
	    local l = obj:get_luaentity ()
	    -- Raid participants should never attack comrades in arms.
	    if self.raidmob and l and l.raidmob then
		return
	    end
	    vlf_mobs.mob_class.do_attack (self, obj)
	end,
	attack_players_and_npcs = function (self)
	end,
	attack_specific = function (self)
	    local attack_players = self:attack_players_allowed ()
	    if self.state == "attack" then
		-- A target has already been selected.
		return
	    end

	    -- Ordinary witches only attack players, but witches
	    -- spawned in raids also seek out nearby illagers
	    -- participating in raids to heal them.

	    local pos = self.object:get_pos ()
	    local objs
		= minetest.get_objects_inside_radius (pos, self.view_range)
	    table.shuffle (objs)
	    for _, obj in pairs (objs) do
		if self:line_of_sight (pos, obj:get_pos(), 2) then
		    local l = obj:get_luaentity ()
		    if attack_players and obj:is_player ()
			and (not self._player_cooldown or not self.raidmob) then
			self:do_attack (obj)
			break
		    elseif self.raidmob and l and l.raidmob
			and (l.name == "mobs_mc:pillager"
			     or l.name == "mobs_mc:vindicator"
			     or l.name == "mobs_mc:evoker") then
			if not self._illager_cooldown then
			    -- Prohibit selecting illager targets
			    -- again for a period of 5 seconds.
			    self._illager_cooldown = 0
			    self:do_attack (obj)
			    break
			end
		    end
		end
	    end
	end,
	deal_damage = function(self, damage, vlf_reason)
		local factor = 1
		if vlf_reason.type == "magic" then factor = 0.15 end
		self.health = self.health - factor*damage
	end,
	do_custom = function (self, dtime)
	    -- Increment illager cooldown period and ascertain whether
	    -- it has elapsed.  Minecraft's period appears to be 200
	    -- ticks divided by two, i.e., 5 seconds.
	    if self._illager_cooldown then
		self._illager_cooldown = self._illager_cooldown + dtime
		if self._illager_cooldown >= 5 then
		    self._illager_cooldown = nil
		end
	    end
	    -- Check for entity_effects to consume every minecraft tick.
	    if self._held_entity_effect then
		self._witch_entity_effect_check = self._witch_entity_effect_check + dtime
		if self._witch_entity_effect_check < 1.5 then
		    return
		end
		-- Finish consuming this entity_effect.
		witch_consume_entity_effect (self, self._held_entity_effect)
	    end
	    self._witch_entity_effect_check = self._witch_entity_effect_check + dtime
	    if self._witch_entity_effect_check < 0.05 then
		return
	    end
	    self._witch_entity_effect_check = 0
	    for _, item in ipairs (witch_entity_effect_items) do
		local random = math.random (1, 100)
		if item.chance >= random and item.test (self) then
		    witch_equip_entity_effect (self, item.entity_effect)
		    break
		end
	    end
	end,
	shoot_arrow = function(self, p, vec)
	    local entity_effect_entity_effect = "vlf_entity_effects:harming_splash"
	    local target_hp, target_pos

	    if not self.attack or self._held_entity_effect then
		return
	    end

	    -- Throw splash entity_effects of harming at players by default.
	    -- If they've yet to receive poison and are at 4 hearts or
	    -- better, throw poison, and if they are beyond 8 blocks,
	    -- try to slow them with slowness entity_effect.  If players
	    -- approach too near, disable them with weakness 25% of
	    -- the time.
	    local entity
	    target_hp = self.attack:is_player () and self.attack:get_hp ()
	    target_pos = self.attack:get_pos ()
	    if not target_hp then
		entity = self.attack:get_luaentity ()
		target_hp = entity.is_mob and entity.health or 0
	    end

	    -- Ref: https://minecraft.fandom.com/wiki/Witch#Behavior
	    local pos = self.object:get_pos ()
	    local dist = vector.distance (target_pos, pos)
	    if entity
		and (entity.name == "mobs_mc:pillager"
		     or entity.name == "mobs_mc:vindicator"
		     or entity.name == "mobs_mc:evoker") then
		-- If it's a raid mob who is being attacked, give it
		-- either regeneration or instant health subject to
		-- its remaining health.
		if target_hp and target_hp <= 4.0 then
		    entity_effect_entity_effect = "vlf_entity_effects:healing_splash"
		else
		    entity_effect_entity_effect = "vlf_entity_effects:regeneration_splash"
		end
	    elseif dist >= 8
		and not vlf_entity_effects.has_effect (self.attack, "slowness") then
		entity_effect_entity_effect = "vlf_entity_effects:slowness_splash"
	    elseif target_hp >= 8 and not vlf_entity_effects.has_effect (self.attack,
								  "poison") then
		entity_effect_entity_effect = "vlf_entity_effects:poison_splash"
	    elseif dist <= 3
		and not vlf_entity_effects.has_effect (self.attack, "weakness")
		and math.random (1, 4) == 1 then
		entity_effect_entity_effect = "vlf_entity_effects:weakness_splash"
	    end

	    -- Adjust for deceleration and entity movement.
	    local eye_height = self.attack:get_properties ().eye_height or 0
	    local movement = self.attack:get_velocity ()
	    movement.y = 0 -- But don't compensate for vertical movement.
	    local pos_adj = target_pos + movement

	    -- But never throw entity_effects behind oneself.
	    if not check_behind (self, pos, pos_adj) then
		target_pos = pos_adj
	    end

	    target_pos.y = target_pos.y + eye_height
	    local d = vector.subtract (target_pos, p)
	    d.y = d.y + vector.length (d) * 0.2
	    vlf_entity_effects.throw_splash (entity_effect_entity_effect, vector.normalize (d), p,
				      self.object, 0, 0)
	end,
})

vlf_mobs.spawn_setup({
	name = "mobs_mc:witch",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 9,
	biomes_except = {
		"MushroomIslandShore",
		"MushroomIsland",
		"DeepDark",
	},
	chance = 200,
})

-- spawn eggs
vlf_mobs.register_egg("mobs_mc:witch", S("Witch"), "#340000", "#51a03e", 0, true)
