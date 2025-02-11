local S = minetest.get_translator(minetest.get_current_modname())
local D = mcl_util.get_dynamic_translator()


local function on_lightning_strike(pos, _, pos2)
	local node = minetest.get_node(pos)
	if vector.distance(pos, pos2) <= 1 then
		node.name = mcl_copper.get_undecayed(node.name, 4)
	else
		node.name = mcl_copper.get_undecayed(node.name, math.random(4))
	end
	minetest.swap_node(pos, node)
end

minetest.register_alias("vlf_copper:copper_ore", "mcl_copper:stone_with_copper")

minetest.register_node("mcl_copper:stone_with_copper", {
	description = S("Copper Ore"),
	_doc_items_longdesc = S("Some copper contained in stone, it is pretty common and can be found below sea level."),
	tiles = {"default_stone.png^mcl_copper_ore.png"},
	groups = {pickaxey = 3, building_block = 1, material_stone = 1, blast_furnace_smeltable=1},
	drop = {
		max_items = 1,
		items = {
			{items = {"mcl_copper:raw_copper 5"},rarity = 5},
			{items = {"mcl_copper:raw_copper 4"},rarity = 5},
			{items = {"mcl_copper:raw_copper 3"},rarity = 5},
			{items = {"mcl_copper:raw_copper 2"}},
		}
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
	_mcl_cooking_output = "mcl_copper:copper_ingot"
})

minetest.register_node("mcl_copper:block_raw", {
	description = S("Block of Raw Copper"),
	_doc_items_longdesc = S("A block used for compact raw copper storage."),
	tiles = {"mcl_copper_block_raw.png"},
	is_ground_content = false,
	groups = {pickaxey = 2, building_block = 1, blast_furnace_smeltable = 1 },
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
	_mcl_crafting_output = {single = {output = "mcl_copper:raw_copper 9"}}
})

local n_desc = {
	[""] = "",
	["exposed_"] = "Exposed ",
	["weathered_"] = "Weathered ",
	["oxidized_"] = "Oxidized ",
}

local bulb_light = {
	[""] = minetest.LIGHT_MAX,
	["exposed_"] = 12,
	["weathered_"] = 8,
	["oxidized_"] = 4,
}

for n, desc in pairs(n_desc) do
	local bdesc = desc
	if n == "" then
		bdesc = "Block of "
	end
	minetest.register_node("mcl_copper:"..n.."copper", {
		description = D(bdesc .. "Copper"),
		_doc_items_longdesc = D(bdesc .. "Copper is mostly a decorative block."),
		tiles = {"mcl_copper"..((string.sub(n, -1) == "_" and "_" .. string.sub(n, 1, -2) or n) == "" and "_block" or (string.sub(n, -1) == "_" and "_" .. string.sub(n, 1, -2) or n)) ..".png"},
		is_ground_content = false,
		groups = {pickaxey = 2, building_block = 1, stonecuttable = 1},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
		_mcl_crafting_output = {
			single = {
				output = n == "" and "mcl_copper:copper_ingot 9" or ""
			}
		}
	})

	minetest.register_node("mcl_copper:"..n.."cut_copper", {
		description = D(desc .. "Cut Copper"),
		_doc_items_longdesc = D(desc .. "Cut Copper is mostly a decorative block."),
		tiles = {"mcl_copper"..((string.sub(n, -1) == "_" and "_" .. string.sub(n, 1, -2) or n) == "" and "_block" or (string.sub(n, -1) == "_" and "_" .. string.sub(n, 1, -2) or n)) .."_cut.png"},
		is_ground_content = false,
		groups = {pickaxey = 2, building_block = 1, stonecuttable = 1},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
		_mcl_stonecutter_recipes = { "mcl_copper:"..n.."copper" }
	})

	minetest.register_node("mcl_copper:"..n.."chiseled_copper", {
		description = D(desc .. "Chiseled Copper"),
		_doc_items_longdesc = D(desc .. "Chiseled Copper is mostly a decorative block."),
		tiles = {"mcl_copper"..((string.sub(n, -1) == "_" and "_" .. string.sub(n, 1, -2) or n) == "" and "_block" or (string.sub(n, -1) == "_" and "_" .. string.sub(n, 1, -2) or n)) .."_chiseled.png"},
		is_ground_content = false,
		groups = {pickaxey = 2, building_block = 1, stonecuttable = 1},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
		_mcl_stonecutter_recipes = { "mcl_copper:"..n.."copper", "mcl_copper:"..n.."cut_copper" }
	})
	minetest.register_node("mcl_copper:"..n.."copper_grate", {
		description = D(desc .. "Copper Grate"),
		_doc_items_longdesc = D(desc .. "Copper Grate is mostly a decorative block."),
		drawtype = "allfaces_optional",
		paramtype = "light",
		tiles = {"mcl_copper"..((string.sub(n, -1) == "_" and "_" .. string.sub(n, 1, -2) or n) == "" and "_block" or (string.sub(n, -1) == "_" and "_" .. string.sub(n, 1, -2) or n)) .."_grate.png"},
		use_texture_alpha = "blend",
		is_ground_content = false,
		groups = {pickaxey = 2, building_block = 1, copper_grate = 1, },
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
		_mcl_stonecutter_recipes = { "mcl_copper:"..n.."copper" }
	})

minetest.register_node("mcl_copper:"..n.."copper_bulb_lit_powered", {
		description = D(desc .. "Copper Bulb On"),
		_doc_items_longdesc = D(desc .. "Copper Bulb is mostly a decorative block."),
		tiles = { "mcl_copper_"..n.."copper_bulb_lit_powered.png"},
		is_ground_content = false,
		light_source = bulb_light[n],
		groups = {pickaxey = 2, building_block = 1, not_in_creative_inventory = 1, not_opaque = 1, comparator_signal = 15},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
		drop = "mcl_copper:"..n.."copper_bulb",
        _mcl_copper_bulb_switch_to = "mcl_copper:"..n.."copper_bulb_lit",
		_mcl_redstone = {
		connects_to = function(node, dir)
			return true
		end,
		update = function(pos, node)
			if mcl_redstone.get_power(pos) == 0 then
				return {priority = 1, name = node.name:gsub("copper_bulb_lit_powered", "copper_bulb_lit")}
			end
		end,
	},
	})
	minetest.register_node("mcl_copper:"..n.."copper_bulb_lit", {
		description = D(desc .. "Copper Bulb"),
		_doc_items_longdesc = D(desc .. "Copper Bulb is mostly a decorative block."),
		tiles = { "mcl_copper_"..n.."copper_bulb_lit.png"},
		is_ground_content = false,
        light_source = bulb_light[n],
		groups = {pickaxey = 2, building_block = 1, comparator_signal = 15 },
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
        _mcl_copper_bulb_switch_to = "mcl_copper:"..n.."copper_bulb_powered",
        _mcl_redstone = {
			connects_to = function(node, dir)
		    	return true
		    end,
		    update = function(pos, node)
				if mcl_redstone.get_power(pos) ~= 0 then
					return {priority = 1, name = node.name:gsub("copper_bulb_lit", "copper_bulb_powered")}
				end
			end,
		},
	})

minetest.register_node("mcl_copper:"..n.."copper_bulb_powered", {
		description = D(desc .. "Copper Bulb On"),
		_doc_items_longdesc = D(desc .. "Copper Bulb is mostly a decorative block."),
		tiles = { "mcl_copper_"..n.."copper_bulb_powered.png"},
		is_ground_content = false,
		groups = {pickaxey = 2, building_block = 1, not_in_creative_inventory = 1, not_opaque = 1, comparator_signal = 15},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
		drop = "mcl_copper:"..n.."copper_bulb",
        _mcl_copper_bulb_switch_to = "mcl_copper:"..n.."copper_bulb",
		_mcl_redstone = {
		connects_to = function(node, dir)
			return true
		end,
		update = function(pos, node)
			if mcl_redstone.get_power(pos) == 0 then
				return {priority = 1, name = node.name:gsub("copper_bulb_powered", "copper_bulb")}
			end
		end,
	},
	})
	minetest.register_node("mcl_copper:"..n.."copper_bulb", {
		description = D(desc .. "Copper Bulb"),
		_doc_items_longdesc = D(desc .. "Copper Bulb is mostly a decorative block."),
		tiles = { "mcl_copper_"..n.."copper_bulb.png"},
		is_ground_content = false,
		groups = {pickaxey = 2, building_block = 1, comparator_signal = 0 },
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3,
        _mcl_copper_bulb_switch_to = "mcl_copper:"..n.."copper_bulb_lit_powered",
        _mcl_redstone = {
			connects_to = function(node, dir)
				return true
		    end,
		    update = function(pos, node)
			    if mcl_redstone.get_power(pos) ~= 0 then
					return {priority = 1, name = node.name:gsub("copper_bulb", "copper_bulb_lit_powered")}
			    end
		    end,
	    },	
	})


	mcl_doors:register_trapdoor("mcl_copper:"..n.."trapdoor", {
		description = D(desc .. "Copper Trapdoor"),
		groups = { copper = 1, pickaxey = 2, deco_block = 1 },
		sounds = mcl_sounds.node_sound_metal_defaults(),
		sound_close = "doors_steel_door_close",
		sound_open = "doors_steel_door_open",
		tile_front = "mcl_copper_trapdoor"..(string.sub(n, -1) == "_" and "_" .. string.sub(n, 1, -2) or n)..".png",
		tile_side = "mcl_copper_trapdoor"..(string.sub(n, -1) == "_" and "_" .. string.sub(n, 1, -2) or n).."_side.png",
		wield_image = "mcl_copper_trapdoor"..(string.sub(n, -1) == "_" and "_" .. string.sub(n, 1, -2) or n)..".png",
		_mcl_blast_resistance = 3,
		_mcl_hardness = 3
	})
	mcl_doors:register_door("mcl_copper:"..n.."copper_door", {
		description = D(desc .. "Copper Door"),
		groups = { door = 1, copper = 1, pickaxey = 2, building_block = 1, door_iron = 1,},
        inventory_image = "mcl_copper_door" .. (string.sub(n, -1) == "_" and "_" .. string.sub(n, 1, -2) or n) .. ".png",
		sounds = mcl_sounds.node_sound_metal_defaults(),
		sound_close = "doors_steel_door_close",
		sound_open = "doors_steel_door_open",
		tiles_bottom = { "mcl_copper_door_"..n.."bottom.png^[transformFX", "mcl_copper_door_"..n.."bottom.png" },
		tiles_top = { "mcl_copper_door_"..n.."top.png^[transformFX", "mcl_copper_door_"..n.."top.png" },
		_mcl_blast_resistance = 3,
		_mcl_hardness = 3
	})
    mcl_doors:register_door("mcl_copper:waxed_"..n.."copper_door", {
		description = D("Waxed ".. desc .. "Copper Door"),
		groups = { door = 1, copper = 1, pickaxey = 2, building_block = 1, door_iron = 1,},
        inventory_image = "mcl_copper_door" .. (string.sub(n, -1) == "_" and "_" .. string.sub(n, 1, -2) or n) .. ".png",
		sounds = mcl_sounds.node_sound_metal_defaults(),
		sound_close = "doors_steel_door_close",
		sound_open = "doors_steel_door_open",
		tiles_bottom = { "mcl_copper_door_"..n.."bottom.png^[transformFX", "mcl_copper_door_"..n.."bottom.png" },
		tiles_top = { "mcl_copper_door_"..n.."top.png^[transformFX", "mcl_copper_door_"..n.."top.png" },
		_mcl_blast_resistance = 3,
		_mcl_hardness = 3
	})
end

-- These are static translation strings, but use D instead of S, anyway, to get
-- them sorted with their 'parent' cut copper blocks in the tr and po files
mcl_stairs.register_stair_and_slab("copper_cut", {
	baseitem = "mcl_copper:cut_copper",
	description_stair = D("Cut Copper Stairs"),
	description_slab = D("Cut Copper Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_copper:copper", "mcl_copper:cut_copper"}}
})

mcl_stairs.register_stair_and_slab("copper_exposed_cut", {
	baseitem = "mcl_copper:exposed_cut_copper",
	description_stair = D("Exposed Cut Copper Stairs"),
	description_slab = D("Exposed Cut Copper Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_copper:exposed_copper", "mcl_copper:exposed_cut_copper"}, _on_lightning_strike = on_lightning_strike}
})

mcl_stairs.register_stair_and_slab("copper_weathered_cut", {
	baseitem = "mcl_copper:weathered_cut_copper",
	description_stair = D("Weathered Cut Copper Stairs"),
	description_slab = D("Weathered Cut Copper Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_copper:weathered_copper", "mcl_copper:weathered_cut_copper"}, _on_lightning_strike = on_lightning_strike}
})

mcl_stairs.register_stair_and_slab("copper_oxidized_cut", {
	baseitem = "mcl_copper:oxidized_cut_copper",
	description_stair = D("Oxidized Cut Copper Stairs"),
	description_slab = D("Oxidized Cut Copper Slab"),
	overrides = {_mcl_stonecutter_recipes = {"mcl_copper:oxidized_copper", "mcl_copper:oxidized_cut_copper"}, _on_lightning_strike = on_lightning_strike}
})
