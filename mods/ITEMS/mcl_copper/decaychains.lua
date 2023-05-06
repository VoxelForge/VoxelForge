mcl_copper.registered_decaychains = {}
local decay_nodes = {}
local nodename_chains = {}
local S = minetest.get_translator("mcl_copper")

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
		minpos = vector.subtract(pos, 1),
		maxpos = vector.add(pos,1),
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
		texture = "mcl_copper_anti_oxidation_particle.png",
		glow = 5,
	})
end

local function unpreserve(itemstack, clicker, pointed_thing)
	local node = minetest.get_node(pointed_thing.under)
	local unpreserved = node.name:gsub("_preserved","")
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
	anti_oxidation_particles(pointed_thing)
	if not minetest.is_creative_enabled(clicker:get_player_name()) then
		itemstack:add_wear_by_uses(65536)
	end
	return itemstack
end

local function register_unpreserve(nodename,od,def)
	local nd = table.copy(od)
	nd.description = (def.preserved_description or S("Preserved ") )..nd.description
	nd["_on_"..def.unpreserve_tool.."_place"]  = function(itemstack, clicker, pointed_thing)
		if pointed_thing then
			return unpreserve(itemstack, clicker, pointed_thing)
		end
		return itemstack
	end
	minetest.register_node(":"..nodename.."_preserved",nd)
end

local function register_undecay(nodename,def)
	local old_os = minetest.registered_items[nodename]["_on_"..def.undecay_tool.."_place"]
	minetest.override_item(nodename,{
		["_on_"..def.undecay_tool.."_place"] = function(itemstack, clicker, pointed_thing)
			if old_os  then itemstack = old_os(itemstack, clicker, pointed_thing) end
			if pointed_thing then
				return undecay(itemstack, clicker, pointed_thing)
			end
			return itemstack
		end
	})
end

local function register_preserve(nodename,def,chaindef)
	local old_op = def.on_place
	minetest.override_item(nodename,{
		on_place =  function(itemstack, placer, pointed_thing)
			local node = minetest.get_node(pointed_thing.under)
			if table.indexof(chaindef.nodes,node.name) == -1 then
				if old_op then return old_op(itemstack, placer, pointed_thing) end
			elseif table.indexof(chaindef.nodes,node.name) < #chaindef.nodes then
				node.name = node.name.."_preserved"
				if minetest.registered_nodes[node.name] then
					minetest.swap_node(pointed_thing.under,node)
					if not minetest.is_creative_enabled(placer:get_player_name()) then
						itemstack:take_item()
					end
				end
			end
			return itemstack
		end
	})
end

-- mcl_copper.register_decaychain(name,def)
-- name: short string that describes the decaychain; will be used as index of the registration table
-- def: decaychain definition:
--{
--	preserved_description = "Waxed",
--		--optional: description of the preserved variant will be prepended with this. Default: "Preserved"
--	preserve_group = "preserves_copper",
--		--optional: item group that when used on the node will preserve this state
--	unpreserve_tool = "axe",
--		--optional: tool that when used on the node will unpreserve a preserved node. (axe|shovel|sword|shears|pick)
--	undecay_tool = "axe",
--		--optional: tool that when used on the node will undecay the node to the previous stage. (axe|shovel|sword|shears|pick)
--	nodes = { --order is significant
--		"mcl_copper:block",
--		"mcl_copper:block_exposed",
--		"mcl_copper:block_weathered",
--		"mcl_copper:block_oxidized",
--	}
--		--mandatory: table defining the decaychain with the undecayed state first and the most decayed state last. The order is significant here.
--}

function mcl_copper.register_decaychain(name,def)
	mcl_copper.registered_decaychains[name] = def
	assert(type(def.nodes) == "table","[mcl_copper] Failed to register decaychain "..tostring(name)..": field nodes is not a table.")
	for k,v in ipairs(def.nodes) do
		local od = minetest.registered_nodes[v]
		assert(od,"[mcl_copper] Error registereing decaychain: The node '"..tostring(v).." in the decaychain "..tostring(name).." does not exist.")

		nodename_chains[v] = name
		table.insert(decay_nodes,v)

		if k < #def.nodes and def.unpreserve_tool then --exclude last entry in chain - can't decay further, hence no preservation
			register_unpreserve(v,od,def)
		end

		if k > 1 and def.undecay_tool then --exclude first entry in chain - can't be undecayed further
			register_undecay(v,def)
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
	for _,v in pairs(mcl_copper.registered_decaychains) do
		if v.preserve_group then
			for it,def in pairs(minetest.registered_items) do
				if minetest.get_item_group(it,v.preserve_group) > 0 then
					register_preserve(it,def,v)
				end
			end
		end
	end
end)
