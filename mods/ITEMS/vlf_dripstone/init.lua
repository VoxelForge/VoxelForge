local S = minetest.get_translator("vlf_dripstone")

minetest.register_node("vlf_dripstone:dripstone_block", {
	description = S("Dripstone Block"),
	tiles = {"vlf_dripstone_dripstone_block.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 1,
	_vlf_hardness = 1.5,
})

minetest.register_node("vlf_dripstone:pointed_dripstone_down_tip", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_down_tip.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,		
})

minetest.register_node("vlf_dripstone:pointed_dripstone_up_tip", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_up_tip.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1, not_in_creative_inventory=1, fall_damage_add_percent=50},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,
})

minetest.register_node("vlf_dripstone:pointed_dripstone_down_frustum", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_down_frustum.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,		
})

minetest.register_node("vlf_dripstone:pointed_dripstone_up_frustum", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_up_frustum.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1, not_in_creative_inventory=1, fall_damage_add_percent=50},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,
})

minetest.register_node("vlf_dripstone:pointed_dripstone_down_middle", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_down_middle.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,		
})

minetest.register_node("vlf_dripstone:pointed_dripstone_up_middle", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_up_middle.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1, not_in_creative_inventory=1, fall_damage_add_percent=50},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,
})
minetest.register_node("vlf_dripstone:pointed_dripstone_down_base", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_down_base.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,		
})

minetest.register_node("vlf_dripstone:pointed_dripstone_up_base", {
	description = S("Pointed Dripstone"),
	drawtype = "plantlike",
	inventory_image = "vlf_dripstone_pointed_dripstone.png",
	tiles = {"vlf_dripstone_pointed_dripstone_up_base.png"},
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1, not_in_creative_inventory=1, fall_damage_add_percent=50},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	light_propagates = true,
	sunlight_propagates = true,
	_vlf_blast_resistance = 3,
	_vlf_hardness = 1.5,
})

--[[local vlf_dripstone = {}

-- Constants
local speed_factor = 60
local seconds_per_growth = 10 * speed_factor
local seconds_per_water_trickle = 1 * speed_factor
local seconds_per_lava_trickle = 6 * speed_factor

-- Dripstone Types
local dripstone_types = {
    dry = "dry",
    hardened = "hardened",
    molten = "molten",
    watered = "watered"
}

-- Nodes
local dripstone_nodes = {
    block = "block",
    huge = "huge",
    large = "large",
    great = "great",
    medium = "medium",
    small = "small",
    tiny = "tiny",
    spike = "spike"
}

-- Source Nodes
local internal = {
    water_nodes = {"default:river_water_source", "default:water_source", "mcl_core:water_source", "mclx_core:river_water_source"},
    lava_nodes = {"default:lava_source", "mcl_core:lava_source"},
    lava_cauldrons = {dry_dripstone_spike = "molten_dripstone_spike"},
    water_cauldrons = {dry_dripstone_spike = "watered_dripstone_spike"}
}

-- Functions to add sources and catchers
function vlf_dripstone.add_source(source_type, nodename)
    if source_type == "water" then
        table.insert(internal.water_nodes, nodename)
    elseif source_type == "lava" then
        table.insert(internal.lava_nodes, nodename)
    end
end

function vlf_dripstone.add_catcher(catcher_type, nodename, newnodename)
    if catcher_type == "water" then
        internal.water_cauldrons[nodename] = newnodename
    elseif catcher_type == "lava" then
        internal.lava_cauldrons[nodename] = newnodename
    end
end

-- Function to generate nodeboxes
local function get_nodebox(size)
    if size >= 8 then return nil end
    return {type = "fixed", fixed = {{-size / 16, -0.5, -size / 16, size / 16, 0.5, size / 16}}}
end

-- Dripstone Registration
for type, type_name in pairs(dripstone_types) do
    for node, node_name in pairs(dripstone_nodes) do
        local size = (node == "block") and 8 or (node == "huge" and 7 or (node == "large" and 6 or (node == "great" and 5 or (node == "medium" and 4 or (node == "small" and 3 or (node == "tiny" and 2 or 1))))))

        minetest.register_node("vlf_dripstone:" .. type_name .. "_" .. node_name, {
            description = type_name:gsub("^%l", string.upper) .. " " .. node_name:gsub("^%l", string.upper) .. " Dripstone",
            tiles = {type_name .. "_dripstone_top.png", type_name .. "_dripstone_top.png", type_name .. "_dripstone_side.png"},
            groups = {pickaxey = 2, material_stone = 1, fall_damage_add_percent = math.max(4 - size, 0) / 4 * 100},
            is_ground_content = true,
            drawtype = (size < 8 and "nodebox" or "normal"),
            paramtype = "light",
            sunlight_propagates = (size < 8),
            node_box = get_nodebox(size),
            sounds = dripstone_sounds,
            _mcl_hardness = 1.0 + size / 8,
            _mcl_blast_resistance = 1 + size / 2,
            _mcl_silk_touch_drop = true,
            drop = {
                max_items = math.floor((size + 1) / 2),
                items = {{rarity = 1, items = {"vlf_dripstone:dry_dripstone_spike"}}}
            }
        })
    end
end]]

