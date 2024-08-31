--
-- Lava vs water interactions
--
minetest.register_abm({
	label = "Lava cooling",
	nodenames = {"group:lava"},
	neighbors = {"group:water"},
	interval = 1,
	chance = 1,
	min_y = vlf_vars.mg_end_min,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local water = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+1, z=pos.z+1}, "group:water")

		local lavatype = minetest.registered_nodes[node.name].liquidtype

		for w=1, #water do
			--local waternode = minetest.get_node(water[w])
			--local watertype = minetest.registered_nodes[waternode.name].liquidtype
			-- Lava on top of water: Water turns into stone
			if water[w].y < pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(water[w], {name="vlf_core:stone"})
				minetest.sound_play("fire_extinguish_flame", {pos = water[w], gain = 0.25, max_hear_distance = 16}, true)
			-- Flowing lava vs water on same level: Lava turns into cobblestone
			elseif lavatype == "flowing" and water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z) then
				minetest.set_node(pos, {name="vlf_core:cobble"})
				minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			-- Lava source vs flowing water above or horizontally neighbored: Lava turns into obsidian
			elseif lavatype == "source" and
					((water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z) or
					(water[w].y == pos.y and (water[w].x == pos.x or water[w].z == pos.z))) then
				minetest.set_node(pos, {name="vlf_core:obsidian"})
				minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			-- water above flowing lava: Lava turns into cobblestone
			elseif lavatype == "flowing" and water[w].y > pos.y and water[w].x == pos.x and water[w].z == pos.z then
				minetest.set_node(pos, {name="vlf_core:cobble"})
				minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			end
		end
	end,
})

--
-- Papyrus and cactus growing
--

-- Functions
function vlf_core.grow_cactus(pos, node)
	pos.y = pos.y-1
	local name = minetest.get_node(pos).name
	if minetest.get_item_group(name, "sand") ~= 0 then
		pos.y = pos.y+1
		local height = 0
		while minetest.get_node(pos).name == "vlf_core:cactus" and height < 4 do
			height = height+1
			pos.y = pos.y+1
		end
		if height < 3 then
			if minetest.get_node(pos).name == "air" then
				minetest.set_node(pos, {name="vlf_core:cactus"})
			end
		end
	end
end

function vlf_core.grow_reeds(pos, node)
	pos.y = pos.y-1
	local name = minetest.get_node(pos).name
	if minetest.get_item_group(name, "soil_sugarcane") ~= 0 then
		if minetest.find_node_near(pos, 1, {"group:water"}) == nil and minetest.find_node_near(pos, 1, {"group:frosted_ice"}) == nil then
			return
		end
		pos.y = pos.y+1
		local height = 0
		while minetest.get_node(pos).name == "vlf_core:reeds" and height < 3 do
			height = height+1
			pos.y = pos.y+1
		end
		if height < 3 then
			if minetest.get_node(pos).name == "air" then
				minetest.set_node(pos, {name="vlf_core:reeds"})
			end
		end
	end
end

-- ABMs


local function drop_attached_node(p)
	local nn = minetest.get_node(p).name
	if nn == "air" or nn == "ignore" then
		return
	end
	minetest.remove_node(p)
	for _, item in pairs(minetest.get_node_drops(nn, "")) do
		local pos = {
			x = p.x + math.random()/2 - 0.25,
			y = p.y + math.random()/2 - 0.25,
			z = p.z + math.random()/2 - 0.25,
		}
		if item ~= "" then
			minetest.add_item(pos, item)
		end
	end
end

-- Helper function for node actions for liquid flow
local function liquid_flow_action(pos, group, action)
	local function check_detach(pos, xp, yp, zp)
		local p = {x=pos.x+xp, y=pos.y+yp, z=pos.z+zp}
		local n = minetest.get_node_or_nil(p)
		if not n then
			return false
		end
		local d = minetest.registered_nodes[n.name]
		if not d then
			return false
		end
		--[[ Check if we want to perform the liquid action.
		* 1: Item must be in liquid group
		* 2a: If target node is below liquid, always succeed
		* 2b: If target node is horizontal to liquid: succeed if source, otherwise check param2 for horizontal flow direction ]]
		local range = d.liquid_range or 8
		if (minetest.get_item_group(n.name, group) ~= 0) and
				((yp > 0) or
				(yp == 0 and ((d.liquidtype == "source") or (n.param2 > (8-range) and n.param2 < 9)))) then
			action(pos)
		end
	end
	local posses = {
		{ x=-1, y=0, z=0 },
		{ x=1, y=0, z=0 },
		{ x=0, y=0, z=-1 },
		{ x=0, y=0, z=1 },
		{ x=0, y=1, z=0 },
	}
	for p=1,#posses do
		check_detach(pos, posses[p].x, posses[p].y, posses[p].z)
	end
end

-- Drop some nodes next to flowing water, if it would flow into the node
minetest.register_abm({
	label = "Wash away dig_by_water nodes by water flow",
	nodenames = {"group:dig_by_water"},
	neighbors = {"group:water"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		liquid_flow_action(pos, "water", function(pos)
			drop_attached_node(pos)
			minetest.dig_node(pos)
		end)
	end,
})

-- Destroy some nodes next to flowing lava, if it would flow into the node
minetest.register_abm({
	label = "Destroy destroy_by_lava_flow nodes by lava flow",
	nodenames = {"group:destroy_by_lava_flow"},
	neighbors = {"group:lava"},
	interval = 1,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		liquid_flow_action(pos, "lava", function(pos)
			minetest.remove_node(pos)
			minetest.sound_play("builtin_item_lava", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			minetest.check_for_falling(pos)
		end)
	end,
})

-- Cactus mechanisms
minetest.register_abm({
	label = "Cactus growth",
	nodenames = {"vlf_core:cactus"},
	neighbors = {"group:sand"},
	interval = 25,
	chance = 10,
	action = function(pos)
		vlf_core.grow_cactus(pos)
	end,
})

minetest.register_abm({
	label = "Cactus mechanisms",
	nodenames = {"vlf_core:cactus"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _, object in pairs(minetest.get_objects_inside_radius(pos, 1.1)) do
			local entity = object:get_luaentity()
			local dst = vector.distance(object:get_pos(), pos)
			if entity and entity.name == "__builtin:item" and dst <= 0.9 then
				object:remove()
			elseif entity and entity.is_mob then
				vlf_util.deal_damage(object, 1, {type = "cactus"})
			end
		end
		local posses = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
		for _, p in pairs(posses) do
			local ndef = minetest.registered_nodes[minetest.get_node(vector.new(pos.x + p[1], pos.y, pos.z + p[2])).name]
			if ndef and ndef.walkable then
				local posy = pos.y
				while minetest.get_node(vector.new(pos.x, posy, pos.z)).name == "vlf_core:cactus" do
					local pos = vector.new(pos.x, posy, pos.z)
					minetest.remove_node(pos)
					minetest.add_item(vector.offset(pos, math.random(-0.5, 0.5), 0, math.random(-0.5, 0.5)), "vlf_core:cactus")
					posy = posy + 1
				end
				break
			end
		end
	end,
})


minetest.register_abm({
	label = "Sugar canes growth",
	nodenames = {"vlf_core:reeds"},
	neighbors = {"group:soil_sugarcane"},
	interval = 25,
	chance = 10,
	action = function(pos)
		vlf_core.grow_reeds(pos)
	end,
})

local grass_spread_randomizer = PseudoRandom(minetest.get_mapgen_setting("seed"))

function vlf_core.get_grass_palette_index(pos)
	local biome_data = minetest.get_biome_data(pos)
	local index = 0
	if biome_data then
		local biome = biome_data.biome
		local biome_name = minetest.get_biome_name(biome)
		local reg_biome = minetest.registered_biomes[biome_name]
		if reg_biome then
			index = reg_biome._vlf_palette_index
		end
	end
	return index
end

-- Return appropriate grass block node for pos
function vlf_core.get_grass_block_type(pos)
	return {name = "vlf_core:dirt_with_grass", param2 = vlf_core.get_grass_palette_index(pos)}
end

------------------------------
-- Spread grass blocks and mycelium on neighbor dirt
------------------------------
minetest.register_abm({
	label = "Grass Block and Mycelium spread",
	nodenames = {"vlf_core:dirt"},
	neighbors = {"air", "group:grass_block_no_snow", "vlf_core:mycelium"},
	interval = 30,
	chance = 20,
	catch_up = false,
	action = function(pos)
		if pos == nil then
			return
		end
		local above = {x=pos.x, y=pos.y+1, z=pos.z}
		local abovenode = minetest.get_node(above)
		if minetest.get_item_group(abovenode.name, "liquid") ~= 0 or minetest.get_item_group(abovenode.name, "opaque") == 1 then
			-- Never grow directly below liquids or opaque blocks
			return
		end
		local light_self = minetest.get_node_light(above)
		if not light_self then return end
		--[[ Try to find a spreading dirt-type block (e.g. grass block or mycelium)
		within a 3×5×3 area, with the source block being on the 2nd-topmost layer. ]]
		local nodes = minetest.find_nodes_in_area({x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+3, z=pos.z+1}, "group:spreading_dirt_type")
		local p2
		-- Nothing found ? Bail out!
		if #nodes <= 0 then
			return
		else
			p2 = nodes[grass_spread_randomizer:next(1, #nodes)]
		end

		-- Found it! Now check light levels!
		local source_above = {x=p2.x, y=p2.y+1, z=p2.z}
		local light_source = minetest.get_node_light(source_above)
		if not light_source then return end

		if light_self >= 4 and light_source >= 9 then
			-- All checks passed! Let's spread the grass/mycelium!
			local n2 = minetest.get_node(p2)
			if minetest.get_item_group(n2.name, "grass_block") ~= 0 then
				n2 = vlf_core.get_grass_block_type(pos)
			end
			minetest.set_node(pos, {name=n2.name})

			-- If this was mycelium, uproot plant above
			if n2.name == "vlf_core:mycelium" then
				local tad = minetest.registered_nodes[minetest.get_node(above).name]
				if tad and tad.groups and tad.groups.non_mycelium_plant then
					minetest.dig_node(above)
				end
			end
		end
	end
})

-- Grass/mycelium death in darkness
minetest.register_abm({
	label = "Grass Block / Mycelium in darkness",
	nodenames = {"group:spreading_dirt_type"},
	interval = 8,
	chance = 50,
	catch_up = false,
	action = function(pos, node)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		local name = minetest.get_node(above).name
		-- Kill grass/mycelium when below opaque block or liquid
		if name ~= "ignore" and (minetest.get_item_group(name, "opaque") == 1 or minetest.get_item_group(name, "liquid") ~= 0) then
			minetest.set_node(pos, {name = "vlf_core:dirt"})
		end
	end
})

-- Turn Grass Path and similar nodes to Dirt if a solid node is placed above it
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if minetest.get_item_group(newnode.name, "solid") ~= 0 or
			minetest.get_item_group(newnode.name, "dirtifier") ~= 0 then
		local below = {x=pos.x, y=pos.y-1, z=pos.z}
		local belownode = minetest.get_node(below)
		if minetest.get_item_group(belownode.name, "dirtifies_below_solid") == 1 then
			minetest.set_node(below, {name="vlf_core:dirt"})
		end
	end
end)

minetest.register_abm({
	label = "Turn Grass Path below solid block into Dirt",
	nodenames = {"vlf_core:grass_path"},
	neighbors = {"group:solid"},
	interval = 8,
	chance = 50,
	action = function(pos, node)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		local name = minetest.get_node(above).name
		local nodedef = minetest.registered_nodes[name]
		if name ~= "ignore" and nodedef and (nodedef.groups and nodedef.groups.solid) then
			minetest.set_node(pos, {name = "vlf_core:dirt"})
		end
	end,
})

local SAVANNA_INDEX = 1
minetest.register_lbm({
	label = "Replace legacy dry grass",
	name = "vlf_core:replace_legacy_dry_grass_0_65_0",
	nodenames = {"vlf_core:dirt_with_dry_grass", "vlf_core:dirt_with_dry_grass_snow"},
	action = function(pos, node)
		local biome_data = minetest.get_biome_data(pos)
		if biome_data then
			local biome = biome_data.biome
			local biome_name = minetest.get_biome_name(biome)
			local reg_biome = minetest.registered_biomes[biome_name]
			if reg_biome then
				if node.name == "vlf_core:dirt_with_dry_grass_snow" then
					node.name = "vlf_core:dirt_with_grass_snow"
				else
					node.name = "vlf_core:dirt_with_grass"
				end
				node.param2 = reg_biome._vlf_palette_index
				-- Fall back to savanna palette index
				if not node.param2 then
					node.param2 = SAVANNA_INDEX
				end
				minetest.set_node(pos, node)
				return
			end
		end
		node.param2 = SAVANNA_INDEX
		minetest.set_node(pos, node)
		return
	end,
})

---------------------
-- Vine generating --
---------------------
minetest.register_abm({
	label = "Vines growth",
	nodenames = {"vlf_core:vine"},
	interval = 47,
	chance = 4,
	action = function(pos, node, active_object_count, active_object_count_wider)

		-- Add vines below pos (if empty)
		local function spread_down(origin, target, dir, node)
			if math.random(1, 2) == 1 then
				if minetest.get_node(target).name == "air" then
					minetest.add_node(target, {name = "vlf_core:vine", param2 = node.param2})
				end
			end
		end

		-- Add vines above pos if it is backed up
		local function spread_up(origin, target, dir, node)
			local vines_in_area = minetest.find_nodes_in_area({x=origin.x-4, y=origin.y-1, z=origin.z-4}, {x=origin.x+4, y=origin.y+1, z=origin.z+4}, "vlf_core:vine")
			-- Less then 4 vines blocks around the ticked vines block (remember the ticked block is counted by above function as well)
			if #vines_in_area < 5 then
				if math.random(1, 2) == 1 then
					if minetest.get_node(target).name == "air" then
						local backup_dir = minetest.wallmounted_to_dir(node.param2)
						local backup = vector.subtract(target, backup_dir)
						local backupnodename = minetest.get_node(backup).name

						-- Check if the block above is supported
						if vlf_core.supports_vines(backupnodename) then
							minetest.add_node(target, {name = "vlf_core:vine", param2 = node.param2})
						end
					end
				end
			end
		end

		local function spread_horizontal(origin, target, dir, node)
			local vines_in_area = minetest.find_nodes_in_area({x=origin.x-4, y=origin.y-1, z=origin.z-4}, {x=origin.x+4, y=origin.y+1, z=origin.z+4}, "vlf_core:vine")
			-- Less then 4 vines blocks around the ticked vines block (remember the ticked block is counted by above function as well)
			if #vines_in_area < 5 then
				-- Spread horizontally
				local backup_dir = minetest.wallmounted_to_dir(node.param2)
				if not vector.equals(backup_dir, dir) then
					local target_node = minetest.get_node(target)
					if target_node.name == "air" then
						local backup = vector.add(target, backup_dir)
						local backupnodename = minetest.get_node(backup).name
						if vlf_core.supports_vines(backupnodename) then
							minetest.add_node(target, {name = "vlf_core:vine", param2 = node.param2})
						end
					end
				end
			end
		end

		local directions = {
			{ { x= 1, y= 0, z= 0 }, spread_horizontal },
			{ { x=-1, y= 0, z= 0 }, spread_horizontal },
			{ { x= 0, y= 1, z= 0 }, spread_up },
			{ { x= 0, y=-1, z= 0 }, spread_down },
			{ { x= 0, y= 0, z= 1 }, spread_horizontal },
			{ { x= 0, y= 0, z=-1 }, spread_horizontal },
		}

		local d = math.random(1, #directions)
		local dir = directions[d][1]
		local spread = directions[d][2]

		spread(pos, vector.add(pos, dir), dir, node)
	end
})

-- Returns true of the node supports vines
function vlf_core.supports_vines(nodename)
	local def = minetest.registered_nodes[nodename]
	-- Rules: 1) walkable 2) full cube
	return def and def.walkable and
			(def.node_box == nil or def.node_box.type == "regular") and
			(def.collision_box == nil or def.collision_box.type == "regular")
end

-- Melt snow
minetest.register_abm({
	label = "Top snow and ice melting",
	nodenames = {"vlf_core:snow", "vlf_core:ice"},
	interval = 16,
	chance = 8,
	action = function(pos, node)
		if minetest.get_node_light(pos, 0) >= 12 then
			if node.name == "vlf_core:ice" then
				vlf_core.melt_ice(pos)
			else
				minetest.remove_node(pos)
			end
		end
	end
})

-- Freeze water
minetest.register_abm({
	label = "Freeze water in cold areas",
	nodenames = {"vlf_core:water_source", "vlfx_core:river_water_source"},
	interval = 32,
	chance = 8,
	action = function(pos, node)
		if vlf_weather.has_snow(pos) and minetest.get_natural_light(vector.offset(pos,0,1,0), 0.5) == minetest.LIGHT_MAX + 1 and minetest.get_node_light(pos) < 10 then
			node.name = "vlf_core:ice"
			minetest.swap_node(pos, node)
		end
	end
})

-- Melt ice at pos. vlf_core:ice MUST be at pos if you call this!
function vlf_core.melt_ice(pos)
	-- Create a water source if ice is destroyed and there was something below it
	local below = {x=pos.x, y=pos.y-1, z=pos.z}
	local belownode = minetest.get_node(below)
	local dim = vlf_worlds.pos_to_dimension(below)
	if dim ~= "nether" and belownode.name ~= "air" and belownode.name ~= "ignore" and belownode.name ~= "vlf_core:void" then
		minetest.set_node(pos, {name="vlf_core:water_source"})
	else
		minetest.remove_node(pos)
	end
	local neighbors = {
		{x=-1, y=0, z=0},
		{x=1, y=0, z=0},
		{x=0, y=-1, z=0},
		{x=0, y=1, z=0},
		{x=0, y=0, z=-1},
		{x=0, y=0, z=1},
	}
	for n=1, #neighbors do
		minetest.check_single_for_falling(vector.add(pos, neighbors[n]))
	end
end

---- FUNCTIONS FOR SNOWED NODES ----
-- These are nodes which change their appearence when they are below a snow cover
-- and turn back into “normal” when the snow cover is removed.

-- Registers a snowed variant of a node (e.g. grass block, podzol, mycelium).
-- * itemstring_snowed: Itemstring of the snowed node to add
-- * itemstring_clear: Itemstring of the original “clear” node without snow
-- * tiles: Optional custom tiles
-- * sounds: Optional custom sounds
-- * clear_colorization: Optional. If true, will clear all paramtype2="color" related node def. fields
-- * desc: Item description
--
-- The snowable nodes also MUST have _vlf_snowed defined to contain the name
-- of the snowed node.
function vlf_core.register_snowed_node(itemstring_snowed, itemstring_clear, tiles, sounds, clear_colorization, desc)
	local def = table.copy(minetest.registered_nodes[itemstring_clear])
	local create_doc_alias
	if def.description then
		create_doc_alias = true
	else
		create_doc_alias = false
	end
	-- Just some group clearing
	def.description = desc
	def._doc_items_longdesc = nil
	def._doc_items_usagehelp = nil
	def._doc_items_create_entry = false
	def.groups.not_in_creative_inventory = 1
	if def.groups.grass_block == 1 then
		def.groups.grass_block_no_snow = nil
		def.groups.grass_block_snow = 1
	end

	-- Enderman must never take this because this block is supposed to be always buried below snow.
	def.groups.enderman_takable = nil

	-- Snowed blocks never spread
	def.groups.spreading_dirt_type = nil

	-- Add the clear node to the item definition for easy lookup
	def._vlf_snowless = itemstring_clear

	-- Note: _vlf_snowed must be added to the clear node manually!

	if not tiles then
		def.tiles = {"default_snow.png", "default_dirt.png", {name="vlf_core_grass_side_snowed.png", tileable_vertical=false}}
	else
		def.tiles = tiles
	end
	if clear_colorization then
		def.paramtype2 = nil
		def.palette = nil
		def.palette_index = nil
		def.color = nil
		def.overlay_tiles = nil
	end
	if not sounds then
		def.sounds = vlf_sounds.node_sound_dirt_defaults({
			footstep = vlf_sounds.node_sound_snow_defaults().footstep,
		})
	else
		def.sounds = sounds
	end

	def._vlf_silk_touch_drop = {itemstring_clear}

	-- Register stuff
	minetest.register_node(itemstring_snowed, def)

	if create_doc_alias and minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", itemstring_clear, "nodes", itemstring_snowed)
	end
end

-- Reverts a snowed dirtlike node at pos to its original snow-less form.
-- This function assumes there is no snow cover node above. This function
-- MUST NOT be called if there is a snow cover node above pos.
function vlf_core.clear_snow_dirt(pos, node)
	local def = minetest.registered_nodes[node.name]
	if def and def._vlf_snowless then
		minetest.swap_node(pos, {name = def._vlf_snowless, param2=node.param2})
	end
end

---- [[[[[ Functions for snowable nodes (nodes that can become snowed). ]]]]] ----
-- Always add these for snowable nodes.

-- on_construct
-- Makes constructed snowable node snowed if placed below a snow cover node.
function vlf_core.on_snowable_construct(pos)
	-- Myself
	local node = minetest.get_node(pos)

	-- Above
	local apos = {x=pos.x, y=pos.y+1, z=pos.z}
	local anode = minetest.get_node(apos)

	-- Make snowed if needed
	if minetest.get_item_group(anode.name, "snow_cover") == 1 then
		local def = minetest.registered_nodes[node.name]
		if def and def._vlf_snowed then
			minetest.swap_node(pos, {name = def._vlf_snowed, param2=node.param2})
		end
	end
end


---- [[[[[ Functions for snow cover nodes. ]]]]] ----

-- A snow cover node is a node which turns a snowed dirtlike --
-- node into its snowed form while it is placed above.
-- vlf's snow cover nodes are Top Snow (vlf_core:snow) and Snow (vlf_core:snowblock).

-- Always add the following functions to snow cover nodes:

-- on_construct
-- Makes snowable node below snowed.
function vlf_core.on_snow_construct(pos)
	local npos = {x=pos.x, y=pos.y-1, z=pos.z}
	local node = minetest.get_node(npos)
	local def = minetest.registered_nodes[node.name]
	if def and def._vlf_snowed then
		minetest.swap_node(npos, {name = def._vlf_snowed, param2=node.param2})
	end
end
-- after_destruct
-- Clears snowed dirtlike node below.
function vlf_core.after_snow_destruct(pos)
	local nn = minetest.get_node(pos).name
	-- No-op if snow was replaced with snow
	if minetest.get_item_group(nn, "snow_cover") == 1 then
		return
	end
	local npos = {x=pos.x, y=pos.y-1, z=pos.z}
	local node = minetest.get_node(npos)
	vlf_core.clear_snow_dirt(npos, node)
end


-- Obsidian crying

local crobby_particle = {
	velocity = vector.new(0,0,0),
	size = math.random(1.3,2.5),
	texture = "vlf_core_crying_obsidian_tear.png",
	collision_removal = false,
}


minetest.register_abm({
	label = "Obsidian cries",
	nodenames = {"vlf_core:crying_obsidian"},
	interval = 5,
	chance = 10,
	action = function(pos, node)
		minetest.after(math.random(0.1,1.5),function()
			local pt = table.copy(crobby_particle)
			pt.acceleration = vector.new(0,0,0)
			pt.collisiondetection = false
			pt.expirationtime = math.random(0.5,1.5)
			pt.pos = vector.offset(pos,math.random(-0.5,0.5),-0.51,math.random(-0.5,0.5))
			minetest.add_particle(pt)
			minetest.after(pt.expirationtime,function()
				pt.acceleration = vector.new(0,-9,0)
				pt.collisiondetection = true
				pt.expirationtime = math.random(1.2,4.5)
				minetest.add_particle(pt)
			end)
		end)
	end
})

function vlf_core.make_dirtpath(itemstack, placer, pointed_thing)
	-- Only make grass path if tool used on side or top of target node
	if pointed_thing.above.y < pointed_thing.under.y then
		return itemstack
	end

	local above = table.copy(pointed_thing.under)
	above.y = above.y + 1
	if minetest.get_node(above).name == "air" then
		if not minetest.is_creative_enabled(placer:get_player_name()) then
			-- Add wear (as if digging a shovely node)
			local toolname = itemstack:get_name()
			local wear = vlf_autogroup.get_wear(toolname, "shovely")
			itemstack:add_wear(wear)
		end
		minetest.sound_play({name="default_grass_footstep", gain=1}, {pos = above}, true)
		minetest.swap_node(pointed_thing.under, {name="vlf_core:grass_path"})
	end
	return itemstack,true
end

function vlf_core.strip_tree(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then return end

	local node = minetest.get_node(pointed_thing.under)
	local noddef = minetest.registered_nodes[node.name]

	if noddef._vlf_stripped_variant and minetest.registered_nodes[noddef._vlf_stripped_variant] then
		minetest.swap_node(pointed_thing.under, {name=noddef._vlf_stripped_variant, param2=node.param2})
		if not minetest.is_creative_enabled(placer:get_player_name()) then
			-- Add wear (as if digging a axey node)
			local toolname = itemstack:get_name()
			local wear = vlf_autogroup.get_wear(toolname, "axey")
			itemstack:add_wear(wear)
		end
	end
	return itemstack,true
end

function vlf_core.bone_meal_grass(itemstack,placer,pointed_thing)
	local flowers_table_plains = {
		"vlf_flowers:dandelion",
		"vlf_flowers:dandelion",
		"vlf_flowers:poppy",

		"vlf_flowers:oxeye_daisy",
		"vlf_flowers:tulip_orange",
		"vlf_flowers:tulip_red",
		"vlf_flowers:tulip_white",
		"vlf_flowers:tulip_pink",
		"vlf_flowers:azure_bluet",
	}
	local flowers_table_simple = {
		"vlf_flowers:dandelion",
		"vlf_flowers:poppy",
	}
	local flowers_table_swampland = {
		"vlf_flowers:blue_orchid",
	}
	local flowers_table_flower_forest = {
		"vlf_flowers:dandelion",
		"vlf_flowers:poppy",
		"vlf_flowers:oxeye_daisy",
		"vlf_flowers:tulip_orange",
		"vlf_flowers:tulip_red",
		"vlf_flowers:tulip_white",
		"vlf_flowers:tulip_pink",
		"vlf_flowers:azure_bluet",
		"vlf_flowers:allium",
	}

	for i = -7, 7 do
		for j = -7, 7 do
			for y = -1, 1 do
				local pos = vector.offset(pointed_thing.above, i, y, j)
				local n = minetest.get_node(pos)
				local n2 = minetest.get_node(vector.offset(pos, 0, -1, 0))

				if n.name ~= "" and n.name == "air" and (minetest.get_item_group(n2.name, "grass_block_no_snow") == 1) then
					-- Randomly generate flowers, tall grass or nothing
					if math.random(1, 100) <= 90 / ((math.abs(i) + math.abs(j)) / 2)then
						-- 90% tall grass, 10% flower
						if math.random(1,100) <= 90 then
							local col = n2.param2
							minetest.add_node(pos, {name="vlf_flowers:tallgrass", param2=col})
						else
							local flowers_table
							local biome = minetest.get_biome_name(minetest.get_biome_data(pos).biome)
							if biome == "Swampland" or biome == "Swampland_shore" or biome == "Swampland_ocean" or biome == "Swampland_deep_ocean" or biome == "Swampland_underground" then
								flowers_table = flowers_table_swampland
							elseif biome == "FlowerForest" or biome == "FlowerForest_beach" or biome == "FlowerForest_ocean" or biome == "FlowerForest_deep_ocean" or biome == "FlowerForest_underground" then
								flowers_table = flowers_table_flower_forest
							elseif biome == "Plains" or biome == "Plains_beach" or biome == "Plains_ocean" or biome == "Plains_deep_ocean" or biome == "Plains_underground" or biome == "SunflowerPlains" or biome == "SunflowerPlains_ocean" or biome == "SunflowerPlains_deep_ocean" or biome == "SunflowerPlains_underground" then
								flowers_table = flowers_table_plains
							else
								flowers_table = flowers_table_simple
							end
							minetest.add_node(pos, {name=flowers_table[math.random(1, #flowers_table)]})
						end
					end
				end
			end
		end
	end
	return true
end

-- Show positions of barriers when player is wielding a barrier
vlf_player.register_globalstep_slow(function(player, dtime)
	local wi = player:get_wielded_item():get_name()
	if wi == "vlf_core:barrier" or wi == "vlf_core:realm_barrier" or minetest.get_item_group(wi, "light_block") ~= 0 then
		local pos = vector.round(player:get_pos())
		local r = 8
		local vm = minetest.get_voxel_manip()
		local emin, emax = vm:read_from_map({x=pos.x-r, y=pos.y-r, z=pos.z-r}, {x=pos.x+r, y=pos.y+r, z=pos.z+r})
		local area = VoxelArea:new{
			MinEdge = emin,
			MaxEdge = emax,
		}
		local data = vm:get_data()
		for x=pos.x-r, pos.x+r do
		for y=pos.y-r, pos.y+r do
		for z=pos.z-r, pos.z+r do
			local vi = area:indexp({x=x, y=y, z=z})
			local nodename = minetest.get_name_from_content_id(data[vi])
			local light_block_group = minetest.get_item_group(nodename, "light_block")

			local tex
			if nodename == "vlf_core:barrier" then
				tex = "vlf_core_barrier.png"
			elseif nodename == "vlf_core:realm_barrier" then
				tex = "vlf_core_barrier.png^[colorize:#FF00FF:127^[transformFX"
			elseif light_block_group ~= 0 then
				tex = "vlf_core_light_" .. (light_block_group - 1) .. ".png"
			end
			if tex then
				minetest.add_particle({
					pos = {x=x, y=y, z=z},
					expirationtime = 1,
					size = 8,
					texture = tex,
					glow = 14,
					playername = player:get_player_name()
				})
			end
		end
		end
		end
	end
end)
