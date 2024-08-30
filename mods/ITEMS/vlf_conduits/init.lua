vlf_conduits = {}
local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

local check_interval = 5
local conduit_nodes = { "vlf_ocean:prismarine",  "vlf_ocean:prismarine_brick", "vlf_ocean:prismarine_dark", "vlf_ocean:sea_lantern" }

local frame_offsets = {
	vector.new(1, 2, 0),
	vector.new(2, 2, 0),
	vector.new(-1, 2, 0),
	vector.new(-2, 2, 0),
	vector.new(0, 2, 0),
	vector.new(0, 2, 1),
	vector.new(0, 2, 2),
	vector.new(0, 2, -1),
	vector.new(0, 2, -2),

	vector.new(2, 1, 0),
	vector.new(-2, 1, 0),
	vector.new(0, 1, 2),
	vector.new(0, 1, -2),

	vector.new(2, 0, 0),
	vector.new(2, 0, 1),
	vector.new(2, 0, 2),

	vector.new(-2, 0, 0),
	vector.new(-2, 0, 1),
	vector.new(-2, 0, 2),

	vector.new(2, 0, -1),
	vector.new(2, 0, -2),
	vector.new(-2, 0, -1),
	vector.new(-2, 0, -2),

	vector.new(0, 0, 2),
	vector.new(1, 0, 2),

	vector.new(0, 0, -2),
	vector.new(1, 0, -2),

	vector.new(-1, 0, 2),
	vector.new(-1, 0, -2),

	vector.new(2, -1, 0),
	vector.new(-2, -1, 0),
	vector.new(0, -1, 2),
	vector.new(0, -1, -2),

	vector.new(1, -2, 0),
	vector.new(2, -2, 0),
	vector.new(-1, -2, 0),
	vector.new(-2, -2, 0),
	vector.new(0, -2, 0),
	vector.new(0, -2, 1),
	vector.new(0, -2, 2),
	vector.new(0, -2, -1),
	vector.new(0, -2, -2),
}

local entity_pos_offset = vector.new(0, -1.25, 0)

local function check_conduit(pos)
	local water = minetest.find_nodes_in_area(vector.offset(pos, -1,-1,-1), vector.offset(pos, 1, 1, 1), {"group:water"})
	local cname = minetest.get_node(pos).name
	if #water < 26 or ( cname ~= "vlf_conduits:conduit" and #water < 27 ) then return false end
	local pn = 0
	for _, v in pairs(frame_offsets) do
		if table.indexof(conduit_nodes, minetest.get_node(vector.add(pos, v)).name) ~= -1 then
			pn = pn + 1
		end
	end
	if pn < 16 then return false end
	return math.floor(pn / 7) * 16
end

function vlf_conduits.player_entity_effect(player)
    if minetest.get_item_group(vlf_player.players[player].nodes.feet, "water") == 0 then return end
    vlf_entity_effects.give_entity_effect_by_level ("conduit_power", player, 1, 17)
end

function vlf_conduits.conduit_damage(ent)
	if minetest.get_item_group(minetest.get_node(ent.object:get_pos()).name, "water") == 0 then return end
	vlf_util.deal_damage(ent.object, 4, {type = "magic"})
end

minetest.register_entity("vlf_conduits:conduit", {
	initial_properties = {
		physical = true,
		visual = "mesh",
		visual_size = {x = 4, y = 4},
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		mesh = "vlf_end_crystal.b3d",
		textures = {"vlf_conduit_conduit.png"},
		collide_with_objects = false,
	},
	on_activate = function(self, staticdata)
		local d = minetest.deserialize(staticdata)
		if d then
			self._pos = d._pos
		end
		self.object:set_armor_groups({immortal = 1})
		self.object:set_animation({x = 0, y = 120}, 3)
	end,
	get_staticdata = function(self)
		return minetest.serialize({ _pos = self._pos })
	end,
	on_step = function(self, dtime)
		self._timer = (self._timer or check_interval) - dtime
		if self._timer > 0 then return end
		self._timer = check_interval
		if not self._pos then
			self.object:remove()
			return
		end
		local lvl = check_conduit(self._pos)
		if not lvl then
			minetest.set_node(self._pos, {name = "vlf_conduits:conduit"})
			self.object:remove()
			return
		end
		local dst = lvl * 2
		for _, pl in pairs(minetest.get_connected_players()) do
			if vector.distance(self._pos, pl:get_pos()) < dst then
				vlf_conduits.player_entity_effect(pl)
			end
		end
		for _, ent in pairs(minetest.luaentities) do
			if ent.is_mob and ent.type == "monster" and ent.object and ent.object:get_pos() and vector.distance(self._pos, ent.object:get_pos()) < 9 then
				vlf_conduits.conduit_damage(ent)
			end
		end
	end
})
local conduit_box = { -0.25, -0.25, -0.25, 0.25, 0.25, 0.25, }
minetest.register_node("vlf_conduits:conduit", {
	description = S("Conduit"),
	_doc_longdesc = S("A conduit provides certain status entity_effects to nearby players much like a beacon but under water"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = conduit_box,
	},
	collisionbox = conduit_box,
	selectionbox = conduit_box,
	groups = { pickaxey = 1, deco_block = 1},
	light_source = 14,
	tiles = { "vlf_conduit_conduit_node.png", },
	_vlf_hardness = 3,
	_vlf_blast_resistance = 3,
})

minetest.register_abm({
	label = "Conduit Activation",
	nodenames = { "vlf_conduits:conduit" },
	interval = check_interval,
	chance = 1,
	action = function(pos, _)
		for _, v in pairs(minetest.get_objects_inside_radius(vector.subtract(pos, entity_pos_offset), 0.5)) do
			if v.name == "vlf_conduits:conduit" then return end
		end
		if check_conduit(pos) then
			minetest.remove_node(pos)
			local o = minetest.add_entity(vector.add(pos, entity_pos_offset) , "vlf_conduits:conduit")
			if o then
				local l = o:get_luaentity()
				l._pos = pos
			end
		end
	end
})

minetest.register_craft({
	output = "vlf_conduits:conduit",
	recipe = {
		{"vlf_mobitems:nautilus_shell", "vlf_mobitems:nautilus_shell", "vlf_mobitems:nautilus_shell"},
		{"vlf_mobitems:nautilus_shell", "vlf_mobitems:heart_of_the_sea", "vlf_mobitems:nautilus_shell"},
		{"vlf_mobitems:nautilus_shell", "vlf_mobitems:nautilus_shell", "vlf_mobitems:nautilus_shell"},
	},
})
