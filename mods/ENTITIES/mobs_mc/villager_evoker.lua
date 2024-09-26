local S = minetest.get_translator("mobs_mc")
local trname = S("Evoker")

local function get_points_on_circle(pos,r,n)
	local rt = {}
	for i=1, n do
		table.insert(rt,vector.offset(pos,r * math.cos(((i-1)/n) * (2*math.pi)),0,  r* math.sin(((i-1)/n) * (2*math.pi)) ))
	end
	return rt
end

local function fangs_line(p, d)
	local r = {}
	for i = 1, 7 do
		table.insert(r, vector.round(vector.add(p, d * i)))
	end
	return r
end

local function fangs_circles(p)
	local r = get_points_on_circle(p, 1, 5)
	for _, k in pairs(get_points_on_circle(p, 2, 8)) do
		table.insert(r, k)
	end
	return r
end

vlf_mobs.register_mob("mobs_mc:evoker", {
	description = trname,
	type = "monster",
	spawn_class = "hostile",
	can_despawn = false,
	physical = true,
	pathfinding = 1,
	hp_min = 24,
	hp_max = 24,
	xp_min = 10,
	xp_max = 10,
	head_swivel = "head.control",
	bone_eye_height = 6.3,
	head_eye_height = 2.2,
	curiosity = 10,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.95, 0.4},
	visual = "mesh",
	mesh = "mobs_mc_villager.b3d",
	textures = { {
		"mobs_mc_evoker.png",
		"blank.png",
		-- TODO: Attack glow
	} },
	makes_footstep_sound = true,
	damage = 6,
	walk_velocity = 1.2,
	run_velocity = 1.5,
	group_attack = true,
	attack_type = "dogfight",
	custom_attack_interval = 15,
	active_vexes = {},
	custom_attack = function(self, _)
		--self:fangs_attack()
		if #self.active_vexes >= 7 then return end
		for k,v in pairs(self.active_vexes) do
			if not v or v.health <= 0 then table.remove(self.active_vexes,k) end
		end
		local r = math.random(4)
		local basepos = self.object:get_pos()
		basepos.y = basepos.y + 1
		for _ = 1, r do
			local spawnpos = vector.add(basepos, minetest.yaw_to_dir(math.random(0,360)))
			local vex = minetest.add_entity(spawnpos, "mobs_mc:vex")
			if vex and vex:get_pos() then
				local ent = vex:get_luaentity()

				-- Mark vexes as summoned and start their life clock (they take damage it reaches 0)
				ent._summoned = true
				ent._lifetimer = math.random(33, 108)

				table.insert(self.active_vexes,ent)
			end
		end
	end,
	vex_attack = function(self)
		if #self.active_vexes >= 7 then return end
		for k,v in pairs(self.active_vexes) do
			if not v or v.health <= 0 then table.remove(self.active_vexes,k) end
		end
		local r = math.random(4)
		local basepos = self.object:get_pos()
		basepos.y = basepos.y + 1
		for _ = 1, r do
			local spawnpos = vector.add(basepos, minetest.yaw_to_dir(math.random(0,360)))
			local vex = minetest.add_entity(spawnpos, "mobs_mc:vex")
			if vex and vex:get_pos() then
				local ent = vex:get_luaentity()

				-- Mark vexes as summoned and start their life clock (they take damage it reaches 0)
				ent._summoned = true
				ent._lifetimer = math.random(33, 108)

				table.insert(self.active_vexes,ent)
			end
		end
	end,
	fangs_attack = function(self, type)
		if self.attack and self.attack:get_pos() then
			local p = self.object:get_pos()
			local ap = self.attack:get_pos()
			local pp =fangs_circles(p)
			if type ~= "circle" and vector.distance(p, ap) > 3 then
				pp = fangs_line(p, vector.direction(p, ap))
			end
			for _, fp in pairs(pp) do
				if minetest.get_item_group(minetest.get_node(fp).name, "solid") <= 0 then
					minetest.add_entity(fp, "mobs_mc:evoker_fangs")
				end
			end
		end
	end,
	passive = false,
	drops = {
		{name = "vlf_core:emerald", chance = 1, min = 0, max = 1, looting = "common",},
		{name = "vlf_totems:totem", chance = 1, min = 1, max = 1 },
	},
	-- TODO: sounds
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 50,
		run_start = 0, run_end = 40, run_speed = 25,
		shoot_start = 120, shoot_end = 130,
	},
	view_range = 16,
	fear_height = 4,

	on_spawn = function(self)
		self.timer = 15
		return true
	end,
})

vlf_mobs.register_egg("mobs_mc:evoker", trname, "#959b9b", "#1e1c1a", 0)

minetest.register_entity("mobs_mc:evoker_fangs", {
	initial_properties = {
		physical = false,
		visual = "mesh",
		mesh = "mobs_mc_evoker_fangs.b3d",
		textures = { "mobs_mc_evoker_fangs.png" },
		static_save = false,
	},
	_timer = 2,
	on_activate = function(self)
		self.object:set_animation({x = 1, y = 35}, 15, 0, false)
		for o in minetest.objects_inside_radius(self.object:get_pos(), 0.4) do
			vlf_util.deal_damage(o, 6, { type = "magic" })
		end
	end,
	on_step = function(self, dtime)
		self._timer = self._timer - dtime
		if self._timer < 0 then
			self.object:remove()
		end
	end
})
