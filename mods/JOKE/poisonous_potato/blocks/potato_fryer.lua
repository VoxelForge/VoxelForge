local S = minetest.get_translator(minetest.get_current_modname())
vlf_frying_tables = {}

local PARTICLE_DISTANCE = 75

local player_particlespawners = {}
local food_entities = {}

local frying_table_spots = {
	vector.new(-0.21, 0.24, -0.21),
	vector.new( 0.21, 0.24, -0.21),
	vector.new( 0.21, 0.24,  0.21),
	vector.new(-0.21, 0.24,  0.21),
}

local function count_table(tbl)
	local count = 0
	if type(tbl) == "table" then for _,_ in pairs(tbl) do count = count + 1 end end
	return count
end

local function drop_items(pos)
	local ph = minetest.hash_node_position(vector.round(pos))
	if food_entities[ph] then
		for _, v in pairs(food_entities[ph]) do
			if v and v.object and v.object:get_pos() then
				v.object:remove()
				minetest.add_item(pos, v._item)
			end
		end
		food_entities[ph] = nil
	end
end

local function frying_table_drops(pos, digger, drops, nodename)
	local wield_item = digger:get_wielded_item()
	local inv = digger:get_inventory()
	if not minetest.is_creative_enabled(digger:get_player_name()) then
		local is_book = wield_item:get_name() == "vlf_enchanting:book_enchanted"
		if vlf_enchanting.has_enchantment(wield_item, "silk_touch") and not is_book then
			minetest.add_item(pos, nodename)
		else
			minetest.add_item(pos, drops)
		end
	elseif inv:room_for_item("main", nodename) and not inv:contains_item("main", nodename) then
		inv:add_item("main", nodename)
	end
end

local function on_blast(pos)
	drop_items(pos)
	minetest.remove_node(pos)
end

function vlf_frying_tables.light_frying_table(pos)
	local frying_table = minetest.get_node(pos)
	local name = frying_table.name .. "_lit"
	minetest.set_node(pos, {name = name, param2 = frying_table.param2})
end

local function delete_entities(ph)
	if not food_entities[ph] then return end
	for _, v in pairs(food_entities[ph]) do
		if v and v.object then
			v:remove()
		end
	end
	food_entities[ph] = nil
end

local function get_free_spot(ph)
	if not food_entities[ph] then
		food_entities[ph] = {}
		return 1
	end
	for i = 1,4 do
		local v = food_entities[ph][i]
		if not v or not v.object or not v.object:get_pos() then
			food_entities[ph][i] = nil
			return i
		end
	end
end

-- on_rightclick function to take items that are cookable in a frying_table, and put them in the frying_table inventory
function vlf_frying_tables.take_item(pos, _, player, itemstack)
	if minetest.get_item_group(itemstack:get_name(), "fryable") ~= 0 then
		local cookable = minetest.get_craft_result({method = "cooking", width = 1, items = {itemstack}})
		if cookable then
			local ph = minetest.hash_node_position(vector.round(pos))
			local spot = get_free_spot(ph)
			if not spot then return end

			local o = minetest.add_entity(pos + frying_table_spots[spot], "voxelforge:food_entity")
			o:set_properties({
				wield_item = itemstack:get_name(),
			})
			local l = o:get_luaentity()
			l._frying_table_poshash = ph
			l._start_time = minetest.get_gametime()
			l._cook_time = cookable.time * 3 --apparently it always takes 30 secs in mc?
			l._item = itemstack:get_name()
			l._drop = cookable.item:get_name()
			l._spot = spot
			food_entities[ph][spot] = l
			if not minetest.is_creative_enabled(player:get_player_name()) then
				itemstack:take_item()
			end
			return itemstack
		end
	end
end

function vlf_frying_tables.register_frying_table(name, def)
	-- Define frying_table
	minetest.register_node(name, {
		description = def.description,
		_tt_help = S("Cooks food and keeps bees happy."),
		_doc_items_longdesc = S("frying_tables have multiple uses, including keeping bees happy, cooking raw meat and fish, and as a trap."),
		inventory_image = def.inv_texture,
		wield_image = def.inv_texture,
		drawtype = "mesh",
		mesh = "frying_table.obj",
		tiles = {{name="frying_table.png"},},
		use_texture_alpha = "clip",
		groups = table.merge (def.groups or {}, {
			handy = 1,
			axey = 1,
			material_wood = 1,
			not_in_creative_inventory = 1,
			frying_table = 1,
			unmovable_by_piston = 1,
		}),
		paramtype = "light",
		paramtype2 = "4dir",
		_on_ignite = function(_, node)
			vlf_frying_tables.light_frying_table(node.under)
			return true
		end,
		_on_arrow_hit = function(pos, arrowent)
			if vlf_burning.is_burning(arrowent.object) then
				vlf_frying_tables.light_frying_table(pos)
			end
		end,
		drop = "",
		sounds = vlf_sounds.node_sound_wood_defaults(),
		selection_box = {
			type = 'fixed',
			fixed = {-.5, -.5, -.5, .5, -.05, .5}, --left, bottom, front, right, top
		},
		collision_box = {
			type = 'fixed',
			fixed = {-.5, -.5, -.5, .5, -.05, .5},
		},
		_vlf_blast_resistance = 2,
		_vlf_hardness = 2,
		after_dig_node = function(pos, _, _, digger)
			frying_table_drops(pos, digger, def.drops, name.."_lit")
		end,
	})

	--Define Lit frying_table
	minetest.register_node(name.."_lit", {
		description = def.description,
		_tt_help = S("Cooks food and keeps bees happy."),
		_doc_items_longdesc = S("frying_tables have multiple uses, including keeping bees happy, cooking raw meat and fish, and as a trap."),
		inventory_image = def.inv_texture,
		wield_image = def.inv_texture,
		drawtype = "mesh",
		mesh = "frying_table.obj",
		tiles = {
			"frying_table.png",
		},
		use_texture_alpha = "clip",
		groups = table.merge (def.groups or {}, {
			handy = 1,
			axey = 1,
			material_wood = 1,
			lit_frying_table = 1,
			deco_block = 1,
			unmovable_by_piston = 1,
		}),
		paramtype = "light",
		paramtype2 = "4dir",
		on_destruct = function(pos)
			local ph = minetest.hash_node_position(vector.round(pos))
			for k,v in pairs(player_particlespawners) do
				if v[ph] then
					minetest.delete_particlespawner(v[ph])
					player_particlespawners[k][ph] = nil
				end
			end
		end,
		on_rightclick = function (pos, node, player, itemstack, pointed_thing)
			if minetest.get_item_group(itemstack:get_name(), "shovel") ~= 0 then
				local protected = vlf_util.check_position_protection(pos, player)
				if not protected then
					if not minetest.is_creative_enabled(player:get_player_name()) then
						-- Add wear (as if digging a shovely node)
						local toolname = itemstack:get_name()
						local wear = vlf_autogroup.get_wear(toolname, "shovely")
						if wear then
							itemstack:add_wear(wear)
						end
					end
					node.name = name
					minetest.set_node(pos, node)
					minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
				end
			elseif minetest.get_item_group(itemstack:get_name(), "fryable") ~= 0 then
				vlf_frying_tables.take_item(pos, node, player, itemstack)
			elseif itemstack and player and pointed_thing then
				minetest.item_place_node(itemstack, player, pointed_thing)
			end

			return itemstack
		end,
		drop = "",
		light_source = def.lightlevel,
		sounds = vlf_sounds.node_sound_wood_defaults(),
		selection_box = {
			type = "fixed",
			fixed = {-.5, -.5, -.5, .5, -.05, .5}, --left, bottom, front, right, top
		},
		collision_box = {
			type = "fixed",
			fixed = {-.5, -.5, -.5, .5, -.05, .5},
		},
		_vlf_blast_resistance = 2,
		_vlf_hardness = 2,
		on_blast = on_blast,
		after_dig_node = function(pos, _, _, digger)
			drop_items(pos)
			frying_table_drops(pos, digger, def.drops, name.."_lit")
		end,
		_vlf_frying_tables_smothered_form = name,
		_pathfinding_class = "DAMAGE_FIRE",
	})
end

function vlf_frying_tables.generate_smoke(pos)
	local smoke_timer

	if minetest.get_node(vector.offset(pos, 0, -1, 0)).name == "vlf_farming:hay_block" then
		smoke_timer = 8
	else
		smoke_timer = 4.75
	end

	local ph = minetest.hash_node_position(pos)
	for pl in vlf_util.connected_players() do
		if not player_particlespawners[pl] then player_particlespawners[pl] = {} end
		if not player_particlespawners[pl][ph] and vector.distance(pos, pl:get_pos()) < PARTICLE_DISTANCE then
			player_particlespawners[pl][ph] = minetest.add_particlespawner({
				amount = 2,
				time = 0,
				minpos = vector.offset(pos,-0.25,0.25,-0.25),
				maxpos = vector.offset(pos,0.25,0.25,0.25),
				minvel = vector.new(-0.1,0.5,-0.1),
				maxvel = vector.new(0.1,1.2,0.1),
				minacc = vector.new(-0.1,0.2,-0.1),
				maxacc = vector.new(0.1,0.5,0.1),
				minexptime = smoke_timer - 2,
				maxexptime = smoke_timer,
				minsize = 3,
				maxsize = 5,
				collisiondetection = true,
				vertical = true,
				texture = "vlf_campfires_particle_9.png",
				playername = pl:get_player_name(),
				texpool = {
					{ name = "vlf_campfires_particle_1.png" },
					{ name = "vlf_campfires_particle_2.png" },
					{ name = "vlf_campfires_particle_3.png" },
					{ name = "vlf_campfires_particle_4.png" },
					{ name = "vlf_campfires_particle_5.png" },
					{ name = "vlf_campfires_particle_6.png" },
					{ name = "vlf_campfires_particle_7.png" },
					{ name = "vlf_campfires_particle_8.png" },
					{ name = "vlf_campfires_particle_9.png" },
					{ name = "vlf_campfires_particle_10.png" },
					{ name = "vlf_campfires_particle_11.png" },
					{ name = "vlf_campfires_particle_11.png" },
					{ name = "vlf_campfires_particle_12.png" },
				}
			})
		end
	end

	for pl,pt in pairs(player_particlespawners) do
		for _,sp in pairs(pt) do
			if not pl or not pl:get_pos() then
				minetest.delete_particlespawner(sp)
			elseif player_particlespawners[pl][ph] and vector.distance(pos, pl:get_pos()) > PARTICLE_DISTANCE then
				minetest.delete_particlespawner(player_particlespawners[pl][ph])
				player_particlespawners[pl][ph] = nil
			end
		end
		if not pl or not pl:get_pos() then
			player_particlespawners[pl] = nil
		end
	end
end

minetest.register_on_leaveplayer(function(player)
	if player_particlespawners[player] then
		for _,v in pairs(player_particlespawners[player]) do
			minetest.delete_particlespawner(v)
		end
		player_particlespawners[player] = nil
	end
end)

-- Register Visual Food Entity
minetest.register_entity(":voxelforge:food_entity", {
	initial_properties = {
		physical = false,
		visual = "wielditem",
		visual_size = {x=0.25, y=0.25},
		collisionbox = {0,0,0,0,0,0},
		pointable = false,
	},
	on_step = function(self,dtime)
		self._timer = (self._timer or 1) - dtime
		if self._timer > 0 then return end
		if not self._start_time or not self._frying_table_poshash then
			--if self._poshash isn't set that essentially means this frying_table entity was migrated. Remove it to let a new one spawn.
			self.object:remove()
		end
		if minetest.get_gametime() - self._start_time > (self._cook_time or 1) then
			if food_entities[self._frying_table_poshash] then
				food_entities[self._frying_table_poshash][self._spot] = nil
			end
			if count_table(food_entities[self._frying_table_poshash]) == 0 then
				delete_entities(self._frying_table_poshash or "")
			end
			minetest.add_item(self.object:get_pos() + frying_table_spots[self._spot], self._drop)
			self.object:remove()
		end
	end,
	get_staticdata = function(self)
		local d = {}
		for k,v in pairs(self) do
			local t = type(v)
			if  t ~= "function"	and t ~= "nil" and t ~= "userdata" then
				d[k] = self[k]
			end
		end
		return minetest.serialize(d)
	end,
	on_activate = function(self, staticdata)
		if type(staticdata) == "userdata" then return end
		local s = minetest.deserialize(staticdata)
		if type(s) == "table" then
			for k,v in pairs(s) do self[k] = v end
			self.object:set_properties({ wield_item = self._item })
			if self._frying_table_poshash and ( not food_entities[self._frying_table_poshash] or not food_entities[self._frying_table_poshash][self._spot] ) then
				local spot = self._spot or get_free_spot(self._frying_table_poshash)
				if spot and self._frying_table_poshash then
					food_entities[self._frying_table_poshash] = food_entities[self._frying_table_poshash] or {}
					food_entities[self._frying_table_poshash][spot] = self
					self._spot = spot
				else
					self.object:remove()
					return
				end
			else
				self.object:remove()
				return
			end
		end
		self._start_time = self._start_time or minetest.get_gametime()
		self.object:set_rotation({x = math.pi / -2, y = 0, z = 0})
		self.object:set_armor_groups({ immortal = 1 })
	end,
})

minetest.register_abm({
	label = "frying_table Smoke",
	nodenames = {"group:lit_frying_table"},
	interval = 2,
	chance = 2,
	action = vlf_frying_tables.generate_smoke,
})

vlf_frying_tables.register_frying_table(":voxelforge:frying_table", {
	description = S("Frying Table"),
	inv_texture = "frying_table.png",
	drops = "vlf_core:charcoal_lump 2",
	mesh = "frying_table.obj",
	lightlevel = minetest.LIGHT_MAX,
	--damage = 0,
})

