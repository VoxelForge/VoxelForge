local S = minetest.get_translator(minetest.get_current_modname())

local sounds = vlf_sounds.node_sound_glass_defaults({
	footstep = {name = "vlf_amethyst_amethyst_walk",  gain = 0.4},
	dug      = {name = "vlf_amethyst_amethyst_break", gain = 0.44},
})

-- Amethyst block
minetest.register_node("vlf_amethyst:amethyst_block",{
	description = S("Block of Amethyst"),
	_doc_items_longdesc = S("The Block of Amethyst is a decoration block crafted from amethyst shards."),
	tiles = {"vlf_amethyst_amethyst_block.png"},
	groups = {pickaxey = 1, building_block = 1},
	sounds = sounds,
	_vlf_hardness = 1.5,
	_vlf_blast_resistance = 1.5,
})

minetest.register_node("vlf_amethyst:budding_amethyst_block",{
	description = S("Budding Amethyst"),
	_doc_items_longdesc = S("The Budding Amethyst can grow amethyst"),
	tiles = {"vlf_amethyst_budding_amethyst.png"},
	drop = "",
	groups = {
		pickaxey = 1,
		building_block = 1,
		dig_by_piston = 1,
		unsticky = 1,
	},
	sounds = sounds,
	_vlf_hardness = 1.5,
	_vlf_blast_resistance = 1.5,
})

minetest.register_craftitem("vlf_amethyst:amethyst_shard",{
	description = S("Amethyst Shard"),
	_doc_items_longdesc = S("An amethyst shard is a crystalline mineral."),
	inventory_image = "vlf_amethyst_amethyst_shard.png",
	groups = {craftitem = 1},
})

-- Calcite
minetest.register_node("vlf_amethyst:calcite",{
	description = S("Calcite"),
	_doc_items_longdesc = S("Calcite can be found as part of amethyst geodes."),
	tiles = {"vlf_amethyst_calcite_block.png"},
	groups = {pickaxey = 1, building_block = 1},
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_hardness = 0.75,
	_vlf_blast_resistance = 0.75,
})

-- Tinted Glass
minetest.register_node("vlf_amethyst:tinted_glass",{
	description = S("Tinted Glass"),
	_doc_items_longdesc = S("Tinted Glass is a type of glass which blocks lights while it is visually transparent."),
	tiles = {"vlf_amethyst_tinted_glass.png"},
	_vlf_hardness = 0.3,
	_vlf_blast_resistance = 0.3,
	drawtype = "glasslike",
	use_texture_alpha = "blend",
	sunlight_propagates = false,
	groups = {handy = 1, building_block = 1, deco_block = 1},
	sounds = vlf_sounds.node_sound_glass_defaults(),
	is_ground_content = false,
})

-- Amethyst Cluster
local bud_def = {
	small = {
		description   = S("Small Amethyst Bud"),
		_doc_items_longdesc = S("Small Amethyst Bud is the first growth of amethyst bud."),
		light_source  = 1,
		_vlf_amethyst_next_grade = "vlf_amethyst:medium_amethyst_bud",
		selection_box = {
			type = "fixed",
			fixed = { -4/16, -7/16, -4/16, 4/16, -3/16, 4/16 },
		}
	},
	medium = {
		description   = S("Medium Amethyst Bud"),
		_doc_items_longdesc = S("Medium Amethyst Bud is the second growth of amethyst bud."),
		light_source  = 2,
		_vlf_amethyst_next_grade = "vlf_amethyst:large_amethyst_bud",
		selection_box = {
			type = "fixed",
			fixed = { -4.5/16, -8/16, -4.5/16, 4.5/16, -2/16, 4.5/16 },
		}
	},
	large = {
		description   = S("Large Amethyst Bud"),
		_doc_items_longdesc = S("Large Amethyst Bud is the third growth of amethyst bud."),
		light_source  = 4,
		_vlf_amethyst_next_grade = "vlf_amethyst:amethyst_cluster",
		selection_box = {
			type = "fixed",
			fixed = { -4.5/16, -8/16, -4.5/16, 4.5/16, -1/16, 4.5/16 },
		},
	},
}

for size, def in pairs(bud_def) do
	minetest.register_node("vlf_amethyst:" .. size .. "_amethyst_bud", table.merge(def, {
		drop = "",
		tiles = { 	"vlf_amethyst_amethyst_bud_" .. size .. ".png" },
		inventory_image = "vlf_amethyst_amethyst_bud_" .. size .. ".png",
		paramtype1 = "light",
		paramtype2 = "wallmounted",
		drawtype = "plantlike",
		use_texture_alpha = "clip",
		sunlight_propagates = true,
		walkable = false,
		groups = {
			destroy_by_lava_flow = 1,
			dig_by_piston = 1,
			unsticky = 1,
			pickaxey = 1,
			deco_block = 1,
			amethyst_buds = 1,
			attached_node = 1,
		},
		sounds = sounds,
		_vlf_hardness = 1.5,
		_vlf_blast_resistance = 1.5,
		_vlf_silk_touch_drop = true,
	}))
end

minetest.register_node("vlf_amethyst:amethyst_cluster",{
	description = S("Amethyst Cluster"),
	_doc_items_longdesc = S("Amethyst Cluster is the final growth of amethyst bud."),
	drop = {
		max_items = 1,
		items = {
			{
				tools = {"~vlf_tools:pick_"},
				items = {"vlf_amethyst:amethyst_shard 4"},
			},
			{
				items = {"vlf_amethyst:amethyst_shard 2"},
			},
		}
	},
	tiles = {"vlf_amethyst_amethyst_cluster.png",},
	inventory_image = "vlf_amethyst_amethyst_cluster.png",
	paramtype2 = "wallmounted",
	drawtype = "plantlike",
	paramtype1 = "light",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	walkable = false,
	light_source = 5,
	groups = {
		destroy_by_lava_flow = 1,
		dig_by_piston = 1,
		unsticky = 1,
		pickaxey = 1,
		deco_block = 1,
		attached_node = 1,
	},
	sounds = sounds,
	selection_box = {
		type = "fixed",
		fixed = { -4.8/16, -8/16, -4.8/16, 4.8/16, 3.9/16, 4.8/16 },
	},
	_vlf_hardness = 1.5,
	_vlf_blast_resistance = 1.5,
	_vlf_silk_touch_drop = true,
})

-- Register Crafts
minetest.register_craft({
	output = "vlf_amethyst:amethyst_block",
	recipe = {
		{"vlf_amethyst:amethyst_shard", "vlf_amethyst:amethyst_shard"},
		{"vlf_amethyst:amethyst_shard", "vlf_amethyst:amethyst_shard"},
	},
})

minetest.register_craft({
	output = "vlf_amethyst:tinted_glass 2",
	recipe = {
		{"",                            "vlf_amethyst:amethyst_shard", ""},
		{"vlf_amethyst:amethyst_shard", "vlf_core:glass",              "vlf_amethyst:amethyst_shard",},
		{"",                            "vlf_amethyst:amethyst_shard", ""},
	},
})

if minetest.get_modpath("vlf_spyglass") then
	minetest.clear_craft({output = "vlf_spyglass:spyglass",})
	local function craft_spyglass(ingot)
		minetest.register_craft({
			output = "vlf_spyglass:spyglass",
			recipe = {
				{"vlf_amethyst:amethyst_shard"},
				{ingot},
				{ingot},
			}
		})
	end
	if minetest.get_modpath("vlf_copper") then
		craft_spyglass("vlf_copper:copper_ingot")
	else
		craft_spyglass("vlf_core:iron_ingot")
	end
end

-- Amethyst Growing
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/grow.lua")
