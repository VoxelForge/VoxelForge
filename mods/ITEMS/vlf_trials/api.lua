local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local SHOWITEM_INTERVAL = 2

local function can_open(pos, player)
	local m = minetest.get_meta(pos)
	if m:get(player:get_player_name()) == "looted" then
		return false
	end
	return true
end

local function set_visited(pos, player)
	local m = minetest.get_meta(pos)
	m:set_string(player:get_player_name(), "looted")
	m:mark_as_private(player:get_player_name())
end

local function eject_items(pos, name, list)
	if not list or #list == 0 then
		local node = minetest.get_node(pos)
		node.name = "vlf_trials:"..name
		minetest.swap_node(pos, node)
		return
	end
	minetest.add_item(vector.offset(pos, 0, 1, 0), table.remove(list))
	minetest.after(0.5, eject_items, pos, name, list)
end

local tpl = {
	drawtype = "allfaces_optional",
	paramtype2 = "facedir",
	paramtype = "light",
	description = S("Vault"),
	_tt_help = S("Ejects loot when opened with the key"),
	_doc_items_longdesc = S("A vault ejects loot when opened with the right key. It can only be opened once by each player."),
	_doc_items_usagehelp = S("A vault ejects loot when opened with the right key. It can only be opened once by each player."),
	groups = {pickaxey=1, material_stone=1, deco_block=1, vault = 1},
	is_ground_content = false,
	drop = "",
	_vlf_hardness = 50,
	_vlf_blast_resistance = 50,
}

minetest.register_entity("vlf_trials:item_entity", {
	initial_properties = {
		physical = false,
		visual = "wielditem",
		visual_size = {x=0.26, y=0.26},
		collisionbox = {0,0,0,0,0,0},
		pointable = true,
		static_save = false,
	},
	_next_item = function(self)
		local itemstack = vlf_loot.get_multi_loot(self._loot, PseudoRandom(os.time()))[1]
		local item_name = itemstack:get_name()
		self.object:set_properties({
			wield_item = item_name,
		})

		-- Adjust the visual size based on the inventory image size
		local item_def = minetest.registered_items[item_name]
		if item_def and item_def.inventory_image then
			-- Here we are assuming image is square and using a fixed scale factor
			local scale_factor = 0.15 -- Adjust as necessary
			self.object:set_properties({
				visual_size = {x=scale_factor, y=scale_factor},
			})
		end
	end,
	_check_players_near = function(self)
		for _, v in pairs(minetest.get_objects_inside_radius(self._pos, 5)) do
			if v:is_player() and can_open(self._pos, v) then return true end
		end
	end,
	on_step = function(self, dtime)
		self._timer = (self._timer or SHOWITEM_INTERVAL) - dtime
		self._rotate_timer = (self._rotate_timer or 0) + dtime

		if self._rotate_timer > 0.1 then  -- Adjust the rotation speed here
			self._rotate_timer = 0
			local yaw = self.object:get_yaw() or 0
			self.object:set_yaw(yaw + math.rad(30))  -- Rotate by 10 degrees each step
		end

		if self._timer < 0 then
			if minetest.get_item_group(minetest.get_node(self.object:get_pos()).name, "vault") <= 1 then
				self.object:remove()
				return
			end
			self._timer = SHOWITEM_INTERVAL
			self:_next_item()
			if not self:_check_players_near() then
				local node = minetest.get_node(self._pos)
				node.name = "vlf_trials:"..self._vault_name
				minetest.swap_node(self._pos, node)
				self.object:remove()
			end
		end
	end,
	on_activate = function(self, staticdata, dtime_s)
		local s = minetest.deserialize(staticdata)
		if s and s.loot then
			self._pos = s.pos
			self._vault_name = s.name
			self._loot = s.loot
			self:_next_item()
			self.object:set_armor_groups({ immortal = 1 })
		else
			self.object:remove()
			return
		end
	end,
})

local function create_display_item(pos, def)
	return minetest.add_entity(pos, "vlf_trials:item_entity", minetest.serialize({loot = def.loot, name = def.name, pos = pos}))
end

function vlf_trials.activate(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	if def and def._vlf_vault_name and minetest.get_item_group(node.name, "vault") == 1 then
		node.name = "vlf_trials:"..def._vlf_vault_name.."_on"
		minetest.swap_node(pos, node)
		create_display_item(pos, vlf_trials.registered_vaults[def._vlf_vault_name])
	end
end

function vlf_trials.register_vault(name, def)
	assert(type(name) == "string", "[vlf_trials] trying to register vault without a valid (string) name")
	assert(def.loot, "[vlf_trials] vault "..tostring(name).." does not define a loot table.")
	def.name = name
	vlf_trials.registered_vaults[name] = def

	minetest.register_node("vlf_trials:"..name, table.merge(tpl, {
		_vlf_vault_name = name,
		--[[on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			if itemstack:get_name() == def.key and can_open(pos, clicker) then
				vlf_trials.activate(pos)
			end
		end]]
	}, def.node_off))
	minetest.register_node("vlf_trials:"..name.."_ejecting", table.merge(tpl, {
		_vlf_vault_name = name,
		groups = table.merge(tpl.groups, { vault = 3 }),
	}, def.node_ejecting))

	minetest.register_node("vlf_trials:"..name.."_on", table.merge(tpl, {
		_vlf_vault_name = name,
		groups = table.merge(tpl.groups, { vault = 2 }),
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			if itemstack:get_name() == def.key and can_open(pos, clicker) then
				set_visited(pos, clicker)
				eject_items(pos, name, vlf_loot.get_multi_loot(def.loot, PcgRandom(os.time())))
				node.name = "vlf_trials:"..name.."_ejecting"
				minetest.swap_node(pos, node)
				if not minetest.is_creative_enabled(clicker:get_player_name()) then
					itemstack:take_item()
				end
				return itemstack
			end
		end
	}, def.node_on))
end

-- Globalstep function to detect players near vaults
minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local pos = player:get_pos()
		local nodes = minetest.find_nodes_in_area(vector.subtract(pos, 4), vector.add(pos, 4), {"group:vault"})
		for _, node_pos in ipairs(nodes) do
			local node = minetest.get_node(node_pos)
			if minetest.get_item_group(node.name, "vault") == 1 then
				if can_open(node_pos, player) then
					vlf_trials.activate(node_pos)
				end
			end
		end
	end
end)

