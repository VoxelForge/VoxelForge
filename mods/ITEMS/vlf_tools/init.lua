local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

vlf_tools = {}
vlf_tools.sets = {}

vlf_tools.commondefs = {
	["axe"] = {
		longdesc = S("An axe is your tool of choice to cut down trees, wood-based blocks and other blocks. Axes deal a lot of damage as well, but they are rather slow. Axes can be used to strip bark and hyphae from trunks. They can also be used to scrape blocks made of copper, reducing their oxidation stage or removing wax from waxed variants."),
		usagehelp = S("To strip bark from trunks and hyphae, use the ax by right-clicking on them. To reduce an oxidation stage from a block made of copper or remove wax from waxed variants, right-click on them. Doors and trapdoors also require you to hold down the sneak key while using the axe."),
		groups = { axe = 1, tool = 1 },
		diggroups = { axey = {} },
		craft_shapes = {
			{
				{ "material", "material" },
				{ "vlf_core:stick", "material" },
				{ "vlf_core:stick", "" }
			},
			{
				{ "material", "material" },
				{ "material", "vlf_core:stick" },
				{ "", "vlf_core:stick" }
			}
		}
	},
	["hoe"] = {
		longdesc = S("Hoes are essential tools for growing crops. They are used to create farmland in order to plant seeds on it. Hoes can also be used as very weak weapons in a pinch."),
		usagehelp = S("Use the hoe on a cultivatable block (by rightclicking it) to turn it into farmland. Dirt, grass blocks and grass paths are cultivatable blocks. Using a hoe on coarse dirt turns it into dirt."),
		groups = { hoe = 1, tool = 1 },
		diggroups = { hoey = {} },
		craft_shapes = {
			{
				{ "material", "material" },
				{ "vlf_core:stick", "" },
				{ "vlf_core:stick", "" }
			},
			{
				{ "material", "material" },
				{ "", "vlf_core:stick" },
				{ "", "vlf_core:stick" }
			}
		}
	},
	["pick"] = {
		longdesc = S("Pickaxes are mining tools to mine hard blocks, such as stone. A pickaxe can also be used as weapon, but it is rather inefficient."),
		groups = { pickaxe = 1, tool = 1 },
		diggroups = { pickaxey = {} },
		craft_shapes = {
			{
				{ "material", "material", "material" },
				{ "", "vlf_core:stick", "" },
				{ "", "vlf_core:stick", "" }
			}
		}
	},
	["shovel"] = {
		longdesc = S("Shovels are tools for digging coarse blocks, such as dirt, sand and gravel. They can also be used to turn grass blocks to grass paths. Shovels can be used as weapons, but they are very weak."),
		usagehelp = S("To turn a grass block into a grass path, hold the shovel in your hand, then use (rightclick) the top or side of a grass block. This only works when there's air above the grass block."),
		groups = { shovel = 1, tool = 1 },
		diggroups = { shovely = {} },
		craft_shapes = {
			{
				{ "material" },
				{ "vlf_core:stick" },
				{ "vlf_core:stick" }
			}
		}
	},
	["sword"] = {
		longdesc = S("Swords are great in melee combat, as they are fast, deal high damage and can endure countless battles. Swords can also be used to cut down a few particular blocks, such as cobwebs."),
		groups = { sword = 1, weapon = 1 },
		diggroups = { swordy = {}, swordy_cobweb = {} },
		craft_shapes = {
			{
				{ "material" },
				{ "material" },
				{ "vlf_core:stick" }
			}
		}
	}
}

local shears_longdesc = S("Shears are tools to shear sheep and to mine a few block types. Shears are a special mining tool and can be used to obtain the original item from grass, leaves and similar blocks that require cutting.")
local shears_use = S("To shear sheep or carve faceless pumpkins, use the “place” key on them. Faces can only be carved at the side of faceless pumpkins. Mining works as usual, but the drops are different for a few blocks.")

local wield_scale = vlf_vars.tool_wield_scale

local function on_tool_place(itemstack, placer, pointed_thing, tool)
	if pointed_thing.type ~= "node" then return end

	local node = minetest.get_node(pointed_thing.under)
	local ndef = minetest.registered_nodes[node.name]
	if not ndef then
		return
	end

	if not placer:get_player_control().sneak and ndef.on_rightclick then
		return minetest.item_place(itemstack, placer, pointed_thing)
	end
	if minetest.is_protected(pointed_thing.under, placer:get_player_name()) then
		minetest.record_protection_violation(pointed_thing.under, placer:get_player_name())
		return itemstack
	end

	if itemstack and type(ndef["_on_"..tool.."_place"]) == "function" then
		local itemstack, no_wear = ndef["_on_"..tool.."_place"](itemstack, placer, pointed_thing)
		if minetest.is_creative_enabled(placer:get_player_name()) or no_wear or not itemstack then
			return itemstack
		end

		-- Add wear using the usages of the tool defined in
		-- _vlf_diggroups. This assumes the tool only has one diggroups
		-- (which is the case in Mineclone).
		local tdef = minetest.registered_tools[itemstack:get_name()]
		if tdef and tdef._vlf_diggroups then
			for group, _ in pairs(tdef._vlf_diggroups) do
				itemstack:add_wear(vlf_autogroup.get_wear(itemstack:get_name(), group))
				return itemstack
			end
		end
		return itemstack
	end

	vlf_offhand.place(placer, pointed_thing)

	return itemstack
end

vlf_tools.tool_place_funcs = {}

for _,tool in pairs({"shovel","shears","sword","pick"}) do
	vlf_tools.tool_place_funcs[tool] = function(itemstack,placer,pointed_thing)
		return on_tool_place(itemstack,placer,pointed_thing,tool)
	end
end

local function get_tool_diggroups(materialdefs, toolname)
	local diggroups = vlf_tools.commondefs[toolname].diggroups

	for _, diggroup in pairs(diggroups) do
		diggroup.speed = materialdefs.speed
		diggroup.level = materialdefs.level
		diggroup.uses = materialdefs.uses
	end

	return diggroups
end

local function replace_material_tag(shape, material)
	local recipe = table.copy(shape)

	for _, line in ipairs(recipe) do
		for count, tag in ipairs(line) do
			if tag == "material" then
				line[count] = material
			end
		end
	end

	return recipe
end

local function register_tool(setname, materialdefs, toolname, tooldefs, overrides)
	local mod = minetest.get_current_modname()
	local itemstring = mod..":"..toolname.."_"..setname
	local commondefs = vlf_tools.commondefs[toolname]
	local tooldefs = table.merge({
		_doc_items_longdesc = commondefs.longdesc,
		_doc_items_usagehelp = commondefs.usagehelp,
		_vlf_diggroups = get_tool_diggroups(materialdefs, toolname),
		_vlf_toollike_wield = true,
		_repair_material = materialdefs.material,
		groups = table.merge(commondefs.groups, materialdefs.groups),
		on_place = vlf_tools.tool_place_funcs[toolname],
		sound = { breaks = "default_tool_breaks" },
		wield_scale = wield_scale
	}, tooldefs, overrides or {})

	minetest.register_tool(itemstring, tooldefs)

	if materialdefs.craftable then
		for _, shapes in ipairs(vlf_tools.commondefs[toolname].craft_shapes) do
			local recipe = replace_material_tag(shapes, materialdefs.material)

			minetest.register_craft({
				output = itemstring,
				recipe = recipe
			})
		end
	end
end

local function make_stripped_trunk(itemstack, placer, pointed_thing)
    if pointed_thing.type ~= "node" then return end

    local node = minetest.get_node(pointed_thing.under)
    local node_name = minetest.get_node(pointed_thing.under).name

    local noddef = minetest.registered_nodes[node_name]

    if not noddef then
        minetest.log("warning", "Trying to right click with an axe the unregistered node: " .. tostring(node_name))
        return
    end

    if not placer:get_player_control().sneak and noddef.on_rightclick then
        return minetest.item_place(itemstack, placer, pointed_thing)
    end
    if minetest.is_protected(pointed_thing.under, placer:get_player_name()) then
        minetest.record_protection_violation(pointed_thing.under, placer:get_player_name())
        return itemstack
    end

    if noddef._vlf_stripped_variant == nil then
		return itemstack
	else
	if noddef.groups.door == 1 then
			local pt_under = pointed_thing.under
			if node_name:find("_b_") then
				local top_pos = {x = pt_under.x, y = pt_under.y + 1, z = pt_under.z}
				minetest.swap_node(top_pos, {name=noddef._vlf_stripped_variant:gsub("_b_", "_t_"), param2=node.param2})
			elseif node_name:find("_t_") then
				local bot_pos = {x = pt_under.x, y = pt_under.y - 1, z = pt_under.z}
				minetest.swap_node(bot_pos, {name=noddef._vlf_stripped_variant:gsub("_t_", "_b_"), param2=node.param2})
			end
		end
		minetest.swap_node(pointed_thing.under, {name=noddef._vlf_stripped_variant, param2=node.param2})
		if minetest.get_item_group(node_name, "waxed") ~= 0 then
			awards.unlock(placer:get_player_name(), "vlf:wax_off")
			vlf_honey.particles(pos)
		end
		if node_name:find("vlf_copper") and node_name:find("bulb") then
			awards.unlock(placer:get_player_name(), "vlf:lighten_up")
		end
		if not minetest.is_creative_enabled(placer:get_player_name()) then
			-- Add wear (as if digging a axey node)
			local toolname = itemstack:get_name()
			local wear = vlf_autogroup.get_wear(toolname, "axey")
			if wear then
				itemstack:add_wear(wear)
				tt.reload_itemstack_description(itemstack) -- update tooltip
			end
		end
	end
    return itemstack
end

local function register_axes(setname, materialdefs, toolname, tooldefs, overrides)
	local mod = minetest.get_current_modname()
	local itemstring = mod..":"..toolname.."_"..setname
	local commondefs = vlf_tools.commondefs[toolname]
	local tooldefs = table.merge({
		_doc_items_longdesc = commondefs.longdesc,
		_doc_items_usagehelp = commondefs.usagehelp,
		_vlf_diggroups = get_tool_diggroups(materialdefs, toolname),
		_vlf_toollike_wield = true,
		_repair_material = materialdefs.material,
		groups = table.merge(commondefs.groups, materialdefs.groups),
		on_place = make_stripped_trunk,
		sound = { breaks = "default_tool_breaks" },
		wield_scale = wield_scale
	}, tooldefs, overrides or {})

	minetest.register_tool(itemstring, tooldefs)

	if materialdefs.craftable then
		for _, shapes in ipairs(vlf_tools.commondefs[toolname].craft_shapes) do
			local recipe = replace_material_tag(shapes, materialdefs.material)

			minetest.register_craft({
				output = itemstring,
				recipe = recipe
			})
		end
	end
end

---Used to add a new tool to all existing material sets. See [API.md](API.md) for more information.
---@param toolname string
---@param commondefs table
---@param tools table
---@param overrides table|nil
function vlf_tools.add_to_sets(toolname, commondefs, tools, overrides)
	if not vlf_tools.commondefs[toolname] then
		vlf_tools.commondefs[toolname] = commondefs
	end

	for setname, _ in pairs(vlf_tools.sets) do
		local materialdefs = vlf_tools.sets[setname]
		local tooldefs = tools[setname]

		register_tool(setname, materialdefs, toolname, tooldefs, overrides)
	end
end

---Used to add a set of tools to a material. See [API.md](API.md) for more information.
---@param setname string
---@param materialdefs table
---@param tools table
---@param overrides table|nil
function vlf_tools.register_set(setname, materialdefs, tools, overrides)
	if not vlf_tools.sets[setname] then
		vlf_tools.sets[setname] = materialdefs
	end

	for tool, defs in pairs(tools) do
		register_tool(setname, materialdefs, tool, defs, overrides)
	end
end

function vlf_tools.register_axe(setname, materialdefs, tools, overrides)
	if not vlf_tools.sets[setname] then
		vlf_tools.sets[setname] = materialdefs
	end

	for tool, defs in pairs(tools) do
		register_axes(setname, materialdefs, tool, defs, overrides)
	end
end

--Shears
minetest.register_tool("vlf_tools:shears", {
	description = S("Shears"),
	_doc_items_longdesc = shears_longdesc,
	_doc_items_usagehelp = shears_use,
	inventory_image = "default_tool_shears.png",
	wield_image = "default_tool_shears.png",
	stack_max = 1,
	groups = { tool=1, shears=1, dig_speed_class=4, enchantability=-1, },
	tool_capabilities = {
			full_punch_interval = 0.5,
			max_drop_level=1,
	},
	on_place = vlf_tools.tool_place_funcs.shears,
	sound = { breaks = "default_tool_breaks" },
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		shearsy = { speed = 1.5, level = 1, uses = 238 },
		shearsy_wool = { speed = 5, level = 1, uses = 238 },
		shearsy_cobweb = { speed = 15, level = 1, uses = 238 }
	},
})

minetest.register_craft({
	output = "vlf_tools:shears",
	recipe = {
		{ "vlf_core:iron_ingot", "" },
		{ "", "vlf_core:iron_ingot", },
	}
})

minetest.register_craft({
	output = "vlf_tools:shears",
	recipe = {
		{ "", "vlf_core:iron_ingot" },
		{ "vlf_core:iron_ingot", "" },
	}
})

dofile(modpath.."/mace.lua")
dofile(modpath.."/register.lua")
