mcl_copper.registered_decaychains = {}
local decay_nodes = {}
local nodename_chains = {}
local D = mcl_util.get_dynamic_translator()

local ESCAPE_CHAR = string.char(0x1b)
local function untranslate(s, ...)
	if type(s) ~= "string" then return "", {} end
	local str, esc, nest, args = s, 1, 0, {}
	local start, arg
	while esc < #str do
		esc = str:find(ESCAPE_CHAR, esc)
		if not esc then
			-- suffix, abort
			start = nil
			break
		end
		local char = str:sub(esc + 1, esc + 1)
		if esc == 1 then
			if char == "(" then
				local _, i = str:find(ESCAPE_CHAR .. "%(T@[^%)]-%)")
				start = i + 1
			elseif char == "T" then
				start = esc + 2
			else
				-- unknown code, abort (everything still has initial values)
				break
			end
			nest = 1
		elseif not start then
			-- prefix, abort (everything still has initial values)
			break
		elseif char == "(" or char == "T" then
			nest = nest + 1
		elseif char == "F" then
			if nest == 1 then
				arg = esc
			end
			nest = nest + 1
		elseif char == "E" then
			nest = nest - 1
			if nest == 1 and arg then
				args[#args + 1] = str:sub(arg + 2, esc - 1)
				str = str:sub(1, arg - 1) .. "@" .. (#args) .. str:sub(esc + 2)
				esc = arg
				arg = nil
			end
		else
			-- unknown code, abort
			start = nil
			break
		end
		esc = esc + 2
	end
	if start and nest == 0 then
		return str:sub(start, -3), args
	else
		return s, {}
	end
end

function mcl_copper.get_decayed(nodename, amount)
	amount = amount or 1
	local dc = mcl_copper.registered_decaychains[nodename_chains[nodename]]
	if not dc then return end
	local ci = table.indexof(dc.nodes,nodename) + amount
	if ci < 1 then ci = 1 end
	if ci > #dc.nodes then ci = #dc.nodes end
	return dc.nodes[ci]
end

function mcl_copper.get_undecayed(nodename, amount)
	amount = amount or 1
	local dc = mcl_copper.registered_decaychains[nodename_chains[nodename]]
	if not dc then return end
	local ci = table.indexof(dc.nodes,nodename) - amount
	if ci < 1 then ci = 1 end
	if ci > #dc.nodes then ci = #dc.nodes end
	return dc.nodes[ci]
end

function mcl_copper.particles(pointed_thing, texture)
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
		texture = texture or "mcl_copper_anti_oxidation_particle.png",
		glow = 5,
	})
end
local particles = mcl_copper.particles
local function unpreserve(itemstack, _, pointed_thing)
	local node = minetest.get_node(pointed_thing.under)
	local unpreserved = node.name:gsub("waxed_","")
	if minetest.registered_nodes[unpreserved] then
		node.name = unpreserved
		minetest.swap_node(pointed_thing.under,node)
	end
	return itemstack
end

local function undecay(itemstack, _, pointed_thing)
	local node = minetest.get_node(pointed_thing.under)
	node.name = mcl_copper.get_undecayed(node.name)
	minetest.swap_node(pointed_thing.under,node)
	particles(pointed_thing)
	if minetest.get_item_group(node.name, "copper_bulb") > 0 then
		awards.unlock(_:get_player_name(), "mcl:lighten_up")
	end
	return itemstack
end

local function register_unpreserve(nodename, od, def)
    local nd = table.copy(od)
    if nd.description then
        local description, args = untranslate(nd.description)
        nd.description = D("Waxed " .. description, unpack(args))
    end
    nd[def.unpreserve_callback] = function(itemstack, clicker, pointed_thing)
        if pointed_thing then
            awards.unlock(clicker:get_player_name(), "mcl:wax_off")
            return unpreserve(itemstack, clicker, pointed_thing)
        end
        return itemstack
    end
    -- Update appropriate stonecutter recipes for the preserved variant
    if nd._mcl_stonecutter_recipes then
        local new_recipes = {}
        for _, v in ipairs(nd._mcl_stonecutter_recipes) do
            if type(v) == "string" then
                if v:find("stair_") then
                    table.insert(new_recipes, (v:gsub("(.-):(stair_.*)", "%1:stair%2_waxed")))
                elseif v:find("slab_") then
                    table.insert(new_recipes, (v:gsub("(.-):(slab_.*)", "%1:stair%2_waxed")))
                else
                    table.insert(new_recipes, (v:gsub("(.-):(.*)", "%1:waxed_%2")))
                end
            end
        end
        nd._mcl_stonecutter_recipes = new_recipes
    end
    nd.groups = table.merge(nd.groups, { affected_by_lightning = 0 })
    nd._on_lightning_strike = nil
    if od._mcl_other_slab_half then
        nd._mcl_other_slab_half = tostring(od._mcl_other_slab_half):gsub("(.-):(slab_.*)", "%1:%2_waxed")
    end
    if od.stairs then
        nd.stairs = {
            tostring(od.stairs[1]):gsub("(.-):(stair_.*)", "%1:%2_waxed"),
            tostring(od.stairs[1]):gsub("(.-):(stair_.*)", "%1:%2_waxed") .. "_outer",
            tostring(od.stairs[1]):gsub("(.-):(stair_.*)", "%1:%2_waxed") .. "_inner"
        }
        nd.drop = tostring(mcl_stairs.get_base_itemstring(nodename)):gsub("(.-):(stair_.*)", "%1:%2_waxed")
    end
    if nd._mcl_copper_bulb_switch_to then
        nd.drop = nd.drop and tostring(nd.drop):gsub("(.-):(.*)", "%1:waxed_%2")
        nd._mcl_copper_bulb_switch_to = tostring(od._mcl_copper_bulb_switch_to):gsub("(.-):(.*)", "%1:waxed_%2")
    end
    if minetest.get_item_group(nodename, "double_slab") > 0 then
        nd.drop = tostring(mcl_stairs.get_base_itemstring(nodename)):gsub("(.-):(slab_.*)", "%1:%2_waxed") .. " 2"
    elseif minetest.get_item_group(nodename, "slab_top") > 0 then
        nd.drop = tostring(mcl_stairs.get_base_itemstring(nodename)):gsub("(.-):(slab_.*)", "%1:%2_waxed")
    elseif minetest.get_item_group(nodename, "slab") > 0 then
        nd._mcl_stairs_double_slab = tostring(nodename):gsub("(.-):(slab_.*)", "%1:%2_waxed") .. "_double"
    end
    --minetest.register_node(":" .. tostring(nodename):gsub("(.-):(.*)", "%1:waxed_%2"), nd)
    if nodename:find("stair_") then
        minetest.register_node(":" .. tostring(nodename):gsub("(.-):(stair_)(.*)", "%1:%2waxed_%3"), nd)
    elseif nodename:find("slab_") then
        minetest.register_node(":" .. tostring(nodename):gsub("(.-):(slab_)(.*)", "%1:%2waxed_%3"), nd)
    else
        minetest.register_node(":" .. tostring(nodename):gsub("(.-):(.*)", "%1:waxed_%2"), nd)
    end
end

local function register_undecay(nodename, def)
    local old_os = minetest.registered_items[nodename][def.undecay_callback]
    minetest.override_item(nodename, {
        [def.undecay_callback] = function(itemstack, clicker, pointed_thing)
            if old_os then itemstack = old_os(itemstack, clicker, pointed_thing) end
            if pointed_thing then
                return undecay(itemstack, clicker, pointed_thing)
            end
            return itemstack
        end
    })
end

local function register_preserve(nodename, def, chaindef)
    local old_op = def.on_place
    minetest.override_item(nodename, {
        on_place = function(itemstack, placer, pointed_thing)
            local node = minetest.get_node(pointed_thing.under)
            if table.indexof(chaindef.nodes, node.name) == -1 then
                if old_op then return old_op(itemstack, placer, pointed_thing) end
            elseif table.indexof(chaindef.nodes, node.name) <= #chaindef.nodes then
                if node.name:find("stair_") then
                    node.name = tostring(node.name):gsub("(.-):(stair_.*)", "%1:%2_waxed")
                elseif node.name:find("slab_") then
                    node.name = tostring(node.name):gsub("(.-):(slab_.*)", "%1:%2_waxed")
                else
                    node.name = tostring(node.name):gsub("(.-):(.*)", "%1:waxed_%2")
                end
                if minetest.registered_nodes[node.name] then
                    minetest.swap_node(pointed_thing.under, node)
                    particles(pointed_thing, "mcl_copper_anti_oxidation_particle.png^[colorize:#d1d553:125")
                    if not minetest.is_creative_enabled(placer and placer:get_player_name() or "") then
                        itemstack:take_item()
                    end
                end
                awards.unlock(placer:get_player_name(), "mcl:wax_on")
            end
            return itemstack
        end
    })
end



-- mcl_copper.register_decaychain(name,def)
-- name: short string that describes the decaychain; will be used as index of the registration table
-- def: decaychain definition:
--{
--	preserve_group = "preserves_copper",
--		--optional: item group that when used on the node will preserve this state
--	unpreserve_callback = "_on_axe_place",
--		--optional: callback to use for unpreservation (scraping)
--	undecay_callback = "_on_axe_place",
--		--optional: callback to use for undecay (deoxidation)
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

		if k <= #def.nodes and def.unpreserve_callback then
			register_unpreserve(v,od,def)
		end

		if k > 1 and def.undecay_callback then --exclude first entry in chain - can't be undecayed further
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
	mcl_stonecutter.refresh_recipes()
end)

