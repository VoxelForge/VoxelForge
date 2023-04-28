mcl_copper.registered_decaychains = {}
local decay_nodes = {}
local nodename_chains = {}

function mcl_copper.get_decayed(nodename)
	local dc = mcl_copper.registered_decaychains[nodename_chains[nodename]]
	if not dc then return end
	local ci = table.indexof(dc.nodes,nodename) + 1
	if ci < 1 then ci = 1 end
	if ci > #dc.nodes then ci = #dc.nodes end
	return dc.nodes[ci]
end

function mcl_copper.get_undecayed(nodename)
	local dc = mcl_copper.registered_decaychains[nodename_chains[nodename]]
	if not dc then return end
	local ci = table.indexof(dc.nodes,nodename) - 1
	if ci < 1 then ci = 1 end
	if ci > #dc.nodes then ci = #dc.nodes end
	return dc.nodes[ci]
end

local function anti_oxidation_particles(pointed_thing)
	local pos = pointed_thing.under
	minetest.add_particlespawner({
		amount = 8,
		time = 1,
		minpos = pos - 1,
		maxpos = pos + 1,
		minvel = vector.zero(),
		maxvel = vector.zero(),
		minacc = vector.zero(),
		maxacc = vector.zero(),
		minexptime = 0.5,
		maxexptime = 1,
		minsize = 1,
		maxsize = 2.5,
		collisiondetection = false,
		vertical = false,
		texture = "mcl_stone_copper_anti_oxidation_particle.png",
		glow = 5,
	})
end

local function unpreserve(itemstack, clicker, pointed_thing)
	local node = minetest.get_node(pointed_thing.under)
	local unpreserved = node.name:gsub("_preserved","")
	local def = mcl_copper.registered_decaychains[nodename_chains[unpreserved]]
	if minetest.registered_nodes[unpreserved] then
		node.name = unpreserved
		minetest.swap_node(pointed_thing.under,node)
		if not minetest.is_creative_enabled(clicker:get_player_name()) then
			itemstack:add_wear_by_uses(65536)
		end
	end
	return itemstack
end

local function undecay(itemstack, clicker, pointed_thing)
	local node = minetest.get_node(pointed_thing.under)
	node.name = mcl_copper.get_undecayed(node.name)
	minetest.swap_node(pointed_thing.under,node)
	if not minetest.is_creative_enabled(clicker:get_player_name()) then
		itemstack:add_wear_by_uses(65536)
	end
	return itemstack
end

function mcl_copper.register_decaychain(name,def)
	mcl_copper.registered_decaychains[name] = def
	assert(type(def.nodes) == "table","[mcl_stone] Failed to register decaychain "..tostring(name)..": field nodes is not a table.")
	for k,v in ipairs(def.nodes) do
		nodename_chains[v] = name
		if k <= #def.nodes then
			table.insert(decay_nodes,v)
			if k < #def.nodes and def.preserve_group then
				local od = minetest.registered_nodes[v]
				assert(type(od) == "table","[mcl_stone] Failed to register decaychain "..tostring(name)..": one of the nodes in the chain does not exist: "..tostring(v))
				local nd = table.copy(od)
				nd.description = (def.preserved_description or S("Preserved ") )..nd.description
				if def.unpreserve_group then
					nd._on_axe_place  = function(itemstack, clicker, pointed_thing)
						if minetest.get_item_group(itemstack:get_name(),def.unpreserve_group) == 0 then
							if od._on_axe_place  then return od._on_axe_place(itemstack, clicker, pointed_thing) end
							if minetest.item_place_node(itemstack, clicker, pointed_thing, minetest.dir_to_facedir(vector.direction(pos,vector.offset(clicker:get_pos(),0,1,0)))) and not minetest.is_creative_enabled(clicker:get_player_name()) then
								itemstack:take_item()
							end
						elseif pointed_thing and minetest.get_item_group(itemstack:get_name(),def.unpreserve_group) > 0 then
							return unpreserve(itemstack, clicker, pointed_thing)
						end
						return itemstack
					end
				end
				minetest.register_node(":"..v.."_preserved",nd)
			end
			if k > 1 and def.undecay_group then
				local old_os = minetest.registered_items[v]._on_axe_place
				minetest.override_item(v,{
					_on_axe_place  = function(itemstack, clicker, pointed_thing)
						if minetest.get_item_group(itemstack:get_name(),def.undecay_group) == 0 then
							if old_os  then return old_or(itemstack, clicker, pointed_thing) end
							if minetest.item_place_node(itemstack, clicker, pointed_thing) and not minetest.is_creative_enabled(clicker:get_player_name()) then
								itemstack:take_item()
							end
						elseif minetest.get_item_group(itemstack:get_name(),def.undecay_group) > 0 then
							return undecay(itemstack, clicker, pointed_thing)
						end
						return itemstack
					end
				})
			end
		end
	end
end

minetest.register_on_mods_loaded(function()
	minetest.register_abm({
		label = "Node Decay",
		nodenames = decay_nodes,
		interval = 500,
		chance = 3,
		action = function(pos, node)
			local dc = mcl_copper.get_decayed(node.name)
			if not dc then return end
			minetest.swap_node(pos, {name = dc, param2 = node.param2})
		end,
	})
	for k,v in pairs(mcl_copper.registered_decaychains) do
		if v.preserve_group then
			for it,def in pairs(minetest.registered_items) do
				if minetest.get_item_group(it,v.preserve_group) > 0 then
					local old_op = def.on_place
					minetest.override_item(it,{
						on_place =  function(itemstack, placer, pointed_thing)
							local node = minetest.get_node(pointed_thing.under)
							if table.indexof(v.nodes,node.name) == -1 then
								if old_op then return old_op(itemstack, placer, pointed_thing) end
							elseif table.indexof(v.nodes,node.name) < #v.nodes then
								node.name = node.name.."_preserved"
								minetest.swap_node(pointed_thing.under,node)
								if not minetest.is_creative_enabled(placer:get_player_name()) then
									itemstack:take_item()
								end
							end
							return itemstack
						end
					})
				end
			end
		end
	end
end)
