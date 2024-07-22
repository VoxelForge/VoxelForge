local cooldown_time = 2
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)
vlf_tools = {}
vlf_tools.mace_cooldown = {}

-- mods/default/tools.lua

--
-- Tool definition
--

--[[
dig_speed_class group:
- 1: Painfully slow
- 2: Very slow
- 3: Slow
- 4: Fast
- 5: Very fast
- 6: Extremely fast
- 7: Instantaneous
]]

-- Help texts
local pickaxe_longdesc = S("Pickaxes are mining tools to mine hard blocks, such as stone. A pickaxe can also be used as weapon, but it is rather inefficient.")
local axe_longdesc = S("An axe is your tool of choice to cut down trees, wood-based blocks and other blocks. Axes deal a lot of damage as well, but they are rather slow.")
local sword_longdesc = S("Swords are great in melee combat, as they are fast, deal high damage and can endure countless battles. Swords can also be used to cut down a few particular blocks, such as cobwebs.")
local shovel_longdesc = S("Shovels are tools for digging coarse blocks, such as dirt, sand and gravel. They can also be used to turn grass blocks to grass paths. Shovels can be used as weapons, but they are very weak.")
local shovel_use = S("To turn a grass block into a grass path, hold the shovel in your hand, then use (rightclick) the top or side of a grass block. This only works when there's air above the grass block.")
local shears_longdesc = S("Shears are tools to shear sheep and to mine a few block types. Shears are a special mining tool and can be used to obtain the original item from grass, leaves and similar blocks that require cutting.")
local shears_use = S("To shear sheep or carve faceless pumpkins, use the “place” key on them. Faces can only be carved at the side of faceless pumpkins. Mining works as usual, but the drops are different for a few blocks.")
local mace_longdesc = S("The mace is a slow melee weapon that deals incredible damage. “dig” key to use it. This weapon has a cooldown of 1.6 seconds, but if you fall the mace will deal more damage than if you are on the ground. The further you fall the more damage done. If you hit a mob or player then you will receive no fall damage, but beware. If you miss you will die. ")

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

for _,tool in pairs({"shovel","shears","axe","sword","pick"}) do
	vlf_tools.tool_place_funcs[tool] = function(itemstack,placer,pointed_thing)
		return on_tool_place(itemstack,placer,pointed_thing,tool)
	end
end

-- Picks
minetest.register_tool("vlf_tools:pick_wood", {
	description = S("Wooden Pickaxe"),
	_doc_items_longdesc = pickaxe_longdesc,
	_doc_items_hidden = false,
	inventory_image = "default_tool_woodpick.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=2, enchantability=15 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=1,
		damage_groups = {fleshy=2},
		punch_attack_uses = 30,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = vlf_tools.tool_place_funcs.pick,
	_repair_material = "group:wood",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		pickaxey = { speed = 2, level = 1, uses = 60 }
	},
})
minetest.register_tool("vlf_tools:pick_stone", {
	description = S("Stone Pickaxe"),
	_doc_items_longdesc = pickaxe_longdesc,
	inventory_image = "default_tool_stonepick.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=3, enchantability=5 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=3,
		damage_groups = {fleshy=3},
		punch_attack_uses = 66,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = vlf_tools.tool_place_funcs.pick,
	_repair_material = "group:cobble",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		pickaxey = { speed = 4, level = 3, uses = 132 }
	},
})
minetest.register_tool("vlf_tools:pick_iron", {
	description = S("Iron Pickaxe"),
	_doc_items_longdesc = pickaxe_longdesc,
	inventory_image = "default_tool_steelpick.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=4, enchantability=14 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=4,
		damage_groups = {fleshy=4},
		punch_attack_uses = 126,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = vlf_tools.tool_place_funcs.pick,
	_repair_material = "vlf_core:iron_ingot",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		pickaxey = { speed = 6, level = 4, uses = 251 }
	},
})
minetest.register_tool("vlf_tools:pick_gold", {
	description = S("Golden Pickaxe"),
	_doc_items_longdesc = pickaxe_longdesc,
	inventory_image = "default_tool_goldpick.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=6, enchantability=22 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=2,
		damage_groups = {fleshy=2},
		punch_attack_uses = 17,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = vlf_tools.tool_place_funcs.pick,
	_repair_material = "vlf_core:gold_ingot",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		pickaxey = { speed = 12, level = 2, uses = 33 }
	},
})
minetest.register_tool("vlf_tools:pick_diamond", {
	description = S("Diamond Pickaxe"),
	_doc_items_longdesc = pickaxe_longdesc,
	inventory_image = "default_tool_diamondpick.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=5, enchantability=10 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=5,
		damage_groups = {fleshy=5},
		punch_attack_uses = 781,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = vlf_tools.tool_place_funcs.pick,
	_repair_material = "vlf_core:diamond",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		pickaxey = { speed = 8, level = 5, uses = 1562 }
	},
	_vlf_upgradable = true,
	_vlf_upgrade_item = "vlf_tools:pick_netherite"
})

minetest.register_tool("vlf_tools:pick_netherite", {
	description = S("Netherite Pickaxe"),
	_doc_items_longdesc = pickaxe_longdesc,
	inventory_image = "default_tool_netheritepick.png",
	wield_scale = wield_scale,
	groups = { tool=1, pickaxe=1, dig_speed_class=6, enchantability=10, fire_immune=1 },
	tool_capabilities = {
		-- 1/1.2
		full_punch_interval = 0.83333333,
		max_drop_level=5,
		damage_groups = {fleshy=6},
		punch_attack_uses = 1016,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = vlf_tools.tool_place_funcs.pick,
	_repair_material = "vlf_nether:netherite_ingot",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		pickaxey = { speed = 9.5, level = 6, uses = 2031 }
	},
})

-- Shovels
minetest.register_tool("vlf_tools:shovel_wood", {
	description = S("Wooden Shovel"),
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	_doc_items_hidden = false,
	inventory_image = "default_tool_woodshovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=2, enchantability=15 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=1,
		damage_groups = {fleshy=2},
		punch_attack_uses = 30,
	},
	on_place = vlf_tools.tool_place_funcs.shovel,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:wood",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		shovely = { speed = 2, level = 2, uses = 60 }
	},
})
minetest.register_tool("vlf_tools:shovel_stone", {
	description = S("Stone Shovel"),
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	inventory_image = "default_tool_stoneshovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=3, enchantability=5 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=3,
		damage_groups = {fleshy=3},
		punch_attack_uses = 66,
	},
	on_place = vlf_tools.tool_place_funcs.shovel,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:cobble",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		shovely = { speed = 4, level = 3, uses = 132 }
	},
})
minetest.register_tool("vlf_tools:shovel_iron", {
	description = S("Iron Shovel"),
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	inventory_image = "default_tool_steelshovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=4, enchantability=14 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=4,
		damage_groups = {fleshy=4},
		punch_attack_uses = 126,
	},
	on_place = vlf_tools.tool_place_funcs.shovel,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "vlf_core:iron_ingot",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		shovely = { speed = 6, level = 4, uses = 251 }
	},
})
minetest.register_tool("vlf_tools:shovel_gold", {
	description = S("Golden Shovel"),
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	inventory_image = "default_tool_goldshovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=6, enchantability=22 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=2,
		damage_groups = {fleshy=2},
		punch_attack_uses = 17,
	},
	on_place = vlf_tools.tool_place_funcs.shovel,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "vlf_core:gold_ingot",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		shovely = { speed = 12, level = 2, uses = 33 }
	},
})
minetest.register_tool("vlf_tools:shovel_diamond", {
	description = S("Diamond Shovel"),
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	inventory_image = "default_tool_diamondshovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=5, enchantability=10 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=5,
		damage_groups = {fleshy=5},
		punch_attack_uses = 781,
	},
	on_place = vlf_tools.tool_place_funcs.shovel,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "vlf_core:diamond",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		shovely = { speed = 8, level = 5, uses = 1562 }
	},
	_vlf_upgradable = true,
	_vlf_upgrade_item = "vlf_tools:shovel_netherite"
})

minetest.register_tool("vlf_tools:shovel_netherite", {
	description = S("Netherite Shovel"),
	_doc_items_longdesc = shovel_longdesc,
	_doc_items_usagehelp = shovel_use,
	inventory_image = "default_tool_netheriteshovel.png",
	wield_scale = wield_scale,
	groups = { tool=1, shovel=1, dig_speed_class=6, enchantability=10, fire_immune=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level=5,
		damage_groups = {fleshy=5},
		punch_attack_uses = 1016,
	},
	on_place = vlf_tools.tool_place_funcs.shovel,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "vlf_nether:netherite_ingot",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		shovely = { speed = 9, level = 6, uses = 2031 }
	},
})

-- Axes
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

minetest.register_tool("vlf_tools:axe_wood", {
	description = S("Wooden Axe"),
	_doc_items_longdesc = axe_longdesc,
	_doc_items_hidden = false,
	inventory_image = "default_tool_woodaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=2, enchantability=15 },
	tool_capabilities = {
		full_punch_interval = 1.25,
		max_drop_level=1,
		damage_groups = {fleshy=7},
		punch_attack_uses = 30,
	},
	on_place = make_stripped_trunk,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:wood",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		axey = { speed = 2, level = 1, uses = 60 }
	},
})
minetest.register_tool("vlf_tools:axe_stone", {
	description = S("Stone Axe"),
	_doc_items_longdesc = axe_longdesc,
	inventory_image = "default_tool_stoneaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=3, enchantability=5 },
	tool_capabilities = {
		full_punch_interval = 1.25,
		max_drop_level=3,
		damage_groups = {fleshy=9},
		punch_attack_uses = 66,
	},
	on_place = make_stripped_trunk,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:cobble",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		axey = { speed = 4, level = 3, uses = 132 }
	},
})
minetest.register_tool("vlf_tools:axe_iron", {
	description = S("Iron Axe"),
	_doc_items_longdesc = axe_longdesc,
	inventory_image = "default_tool_steelaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=4, enchantability=14 },
	tool_capabilities = {
		-- 1/0.9
		full_punch_interval = 1.11111111,
		max_drop_level=4,
		damage_groups = {fleshy=9},
		punch_attack_uses = 126,
	},
	on_place = make_stripped_trunk,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "vlf_core:iron_ingot",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		axey = { speed = 6, level = 4, uses = 251 }
	},
})
minetest.register_tool("vlf_tools:axe_gold", {
	description = S("Golden Axe"),
	_doc_items_longdesc = axe_longdesc,
	inventory_image = "default_tool_goldaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=6, enchantability=22 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=2,
		damage_groups = {fleshy=7},
		punch_attack_uses = 17,
	},
	on_place = make_stripped_trunk,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "vlf_core:gold_ingot",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		axey = { speed = 12, level = 2, uses = 33 }
	},
})
minetest.register_tool("vlf_tools:axe_diamond", {
	description = S("Diamond Axe"),
	_doc_items_longdesc = axe_longdesc,
	inventory_image = "default_tool_diamondaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=5, enchantability=10 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=5,
		damage_groups = {fleshy=9},
		punch_attack_uses = 781,
	},
	on_place = make_stripped_trunk,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "vlf_core:diamond",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		axey = { speed = 8, level = 5, uses = 1562 }
	},
	_vlf_upgradable = true,
	_vlf_upgrade_item = "vlf_tools:axe_netherite"
})

minetest.register_tool("vlf_tools:axe_netherite", {
	description = S("Netherite Axe"),
	_doc_items_longdesc = axe_longdesc,
	inventory_image = "default_tool_netheriteaxe.png",
	wield_scale = wield_scale,
	groups = { tool=1, axe=1, dig_speed_class=6, enchantability=10, fire_immune=1 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=5,
		damage_groups = {fleshy=10},
		punch_attack_uses = 1016,
	},
	on_place = make_stripped_trunk,
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "vlf_nether:netherite_ingot",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		axey = { speed = 9, level = 6, uses = 2031 }
	},
})

-- Swords
minetest.register_tool("vlf_tools:sword_wood", {
	description = S("Wooden Sword"),
	_doc_items_longdesc = sword_longdesc,
	_doc_items_hidden = false,
	inventory_image = "default_tool_woodsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=2, enchantability=15 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=1,
		damage_groups = {fleshy=4},
		punch_attack_uses = 60,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = vlf_tools.tool_place_funcs.sword,
	_repair_material = "group:wood",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		swordy = { speed = 2, level = 1, uses = 60 },
		swordy_cobweb = { speed = 2, level = 1, uses = 60 }
	},
})
minetest.register_tool("vlf_tools:sword_stone", {
	description = S("Stone Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_stonesword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=3, enchantability=5 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=3,
		damage_groups = {fleshy=5},
		punch_attack_uses = 132,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = vlf_tools.tool_place_funcs.sword,
	_repair_material = "group:cobble",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		swordy = { speed = 4, level = 3, uses = 132 },
		swordy_cobweb = { speed = 4, level = 3, uses = 132 }
	},
})
minetest.register_tool("vlf_tools:sword_iron", {
	description = S("Iron Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_steelsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=4, enchantability=14 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=4,
		damage_groups = {fleshy=6},
		punch_attack_uses = 251,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = vlf_tools.tool_place_funcs.sword,
	_repair_material = "vlf_core:iron_ingot",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		swordy = { speed = 6, level = 4, uses = 251 },
		swordy_cobweb = { speed = 6, level = 4, uses = 251 }
	},
})
minetest.register_tool("vlf_tools:sword_gold", {
	description = S("Golden Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_goldsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=6, enchantability=22 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=2,
		damage_groups = {fleshy=4},
		punch_attack_uses = 33,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = vlf_tools.tool_place_funcs.sword,
	_repair_material = "vlf_core:gold_ingot",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		swordy = { speed = 12, level = 2, uses = 33 },
		swordy_cobweb = { speed = 12, level = 2, uses = 33 }
	},
})
minetest.register_tool("vlf_tools:sword_diamond", {
	description = S("Diamond Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_diamondsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=5, enchantability=10 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=5,
		damage_groups = {fleshy=7},
		punch_attack_uses = 1562,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = vlf_tools.tool_place_funcs.sword,
	_repair_material = "vlf_core:diamond",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		swordy = { speed = 8, level = 5, uses = 1562 },
		swordy_cobweb = { speed = 8, level = 5, uses = 1562 }
	},
	_vlf_upgradable = true,
	_vlf_upgrade_item = "vlf_tools:sword_netherite"
})
minetest.register_tool("vlf_tools:sword_netherite", {
	description = S("Netherite Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_netheritesword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=5, enchantability=10, fire_immune=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=5,
		damage_groups = {fleshy=9},
		punch_attack_uses = 2031,
	},
	sound = { breaks = "default_tool_breaks" },
	on_place = vlf_tools.tool_place_funcs.sword,
	_repair_material = "vlf_nether:netherite_ingot",
	_vlf_toollike_wield = true,
	_vlf_diggroups = {
		swordy = { speed = 8, level = 5, uses = 2031 },
		swordy_cobweb = { speed = 8, level = 5, uses = 2031 }
	},
})

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
 -- Mace
 minetest.register_tool("vlf_tools:mace", {
	description = "" ..minetest.colorize(vlf_colors.DARK_PURPLE, S("Mace")),--S("Mace"),
	_doc_items_longdesc = mace_longdesc,
	inventory_image = "vlf_tools_mace.png",
	groups = { weapon=1, mace=1, dig_speed_class=1, enchantability=10, sword=1 },
	tool_capabilities = {
		full_punch_interval = 1.6,
		max_drop_level = 1,
		groupcaps = {
			snappy = {times = {1.5, 0.9, 0.4}, uses = 50, maxlevel = 3},
		},
		damage_groups = {fleshy = 0},
	},
	_repair_material = "vlf_mobitems:breeze_rod",
	_vlf_toollike_wield = true,

	on_use = function(itemstack, user, pointed_thing)
		local fall_distance = user:get_velocity().y
		local obj = pointed_thing.ref
		if pointed_thing.type == "object" then
			if vlf_tools.mace_cooldown[user] == nil then
				vlf_tools.mace_cooldown[user] = vlf_tools.mace_cooldown[user] or 0
			end
			local current_time = minetest.get_gametime()
			if current_time - vlf_tools.mace_cooldown[user] >= cooldown_time then
				local wind_burst = vlf_enchanting.get_enchantment(itemstack, "wind_burst")
				local density_add = (vlf_enchanting.get_enchantment(itemstack, "density") or 0) * 0.5 * fall_distance
				vlf_tools.mace_cooldown[user] = current_time
				if fall_distance < 0 then
					if obj:is_player() or obj:get_luaentity() then
						obj:punch(user, 1.6, {
						full_punch_interval = 1.6,
						damage_groups = {fleshy = -6 * fall_distance / 5.5 + density_add},
						}, nil)
					end
					if wind_burst >= 1 then
						local v = user:get_velocity()
						user:set_velocity(vector.new(v.x, 0, v.z))
						local pos = user:get_pos()
						-- set vertical V to 0  first otherwise this is highly dependent on falling speed
						user:add_velocity(vector.new(0, 30 + (wind_burst * 5), 0))
						local pr = PseudoRandom(math.ceil(os.time() / 60 / 10))
						local vr = vector.new(pr:next(-2, 2)/10, 0, pr:next(-2, 2)/10)
						local amount = 20
						vr.y = pr:next(-9, -4) / 10
						minetest.add_particlespawner(table.merge(wind_burst_spawner, {
							amount = amount,
							minacc = vr,
							maxacc = vr,
							minpos = vector.offset(pos, -2, 3, -2),
							maxpos = vector.offset(pos, 2, 0.3, 2),
						}))
					end
				else
					if obj:is_player() or obj:get_luaentity() then
						obj:punch(user, 1.6, {
						full_punch_interval = 1.6,
						damage_groups = {fleshy = 6},
						}, nil)
					end
				end
			end
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:add_wear(65535 / 500)
				return itemstack
			end
		end
	end,
})

dofile(modpath.."/heavy_core.lua")
dofile(modpath.."/crafting.lua")

minetest.register_on_leaveplayer(function(player)
	vlf_tools.mace_cooldown[player] = nil
end)

-- By Cora
vlf_damage.register_modifier(function(obj, damage, reason)
	if reason.type == "fall" and vlf_tools.mace_cooldown[obj] and minetest.get_gametime() - vlf_tools.mace_cooldown[obj] < 2 then
			return 0
	end
end)
