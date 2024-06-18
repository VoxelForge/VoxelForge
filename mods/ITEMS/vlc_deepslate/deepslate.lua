local cobble = "vlc_deepslate:deepslate_cobbled"
local S = vlc_deepslate.translator

local function register_deepslate_variant(name, defs)
	vlc_deepslate.register_variants(name,table.update({
		basename = "deepslate",
		basetiles = "vlc_deepslate",
	}, defs))
end

minetest.register_node("vlc_deepslate:deepslate", {
	description = S("Deepslate"),
	_doc_items_longdesc = S("Deepslate is a stone type found deep underground in the Overworld that functions similar to regular stone but is harder than the stone."),
	_doc_items_hidden = false,
	tiles = { "vlc_deepslate_top.png", "vlc_deepslate_top.png", "vlc_deepslate.png" },
	paramtype2 = "facedir",
	on_place = vlc_util.rotate_axis,
	groups = { pickaxey = 1, stone = 1, building_block = 1, material_stone = 1, converts_to_moss = 1 },
	drop = cobble,
	sounds = vlc_sounds.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_3way,
	_vlc_blast_resistance = 6,
	_vlc_hardness = 3,
	_vlc_silk_touch_drop = true,
})

vlc_monster_eggs.register_infested_block("vlc_deepslate:deepslate", S("Infested Deepslate"))
minetest.register_alias("vlc_deepslate:infested_deepslate", "vlc_monster_eggs:monster_egg_deepslate")

minetest.register_node("vlc_deepslate:deepslate_reinforced", {
	description = S("Reinforced Deepslate"),
	_doc_items_longdesc = S("Reinforced deepslate is a very hard block undestructable by even wither explosions. It is unobtainable in survival mode."),
	_doc_items_hidden = false,
	tiles = {
		"vlc_deepslate_reinforced_top.png",
		"vlc_deepslate_reinforced_bottom.png",
		{name="vlc_deepslate_reinforced.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=7.25}}
	},
	is_ground_content = false,
	paramtype2 = "facedir",
	on_place = vlc_util.rotate_axis,
	groups = { stone = 1, building_block = 1, material_stone = 1 },
	drop = "",
	sounds = vlc_sounds.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_3way,
	_vlc_blast_resistance = 1200,
	_vlc_hardness = 55,
})

vlc_deepslate.register_deepslate_ore("coal", S("Deepslate Coal Ore"), nil, "vlc_core:coal_ore")
vlc_deepslate.register_deepslate_ore("iron", S("Deepslate Iron Ore"), nil, "vlc_core:iron_ore")
vlc_deepslate.register_deepslate_ore("gold", S("Deepslate Gold Ore"), nil, "vlc_core:gold_ore")
vlc_deepslate.register_deepslate_ore("emerald", S("Deepslate Emerald Ore"), nil, "vlc_core:emerald_ore")
vlc_deepslate.register_deepslate_ore("diamond", S("Deepslate Diamond Ore"), nil, "vlc_core:diamond_ore")
vlc_deepslate.register_deepslate_ore("lapis", S("Deepslate Lapis Lazuli Ore"), nil, "vlc_core:lapis_ore")
vlc_deepslate.register_deepslate_ore("redstone", S("Deepslate Redstone Ore"), {
	_vlc_ore_lit = "vlc_deepslate:redstone_ore_lit",
	_vlc_ore_unlit = "vlc_deepslate:redstone_ore",
}, "vlc_core:redstone_ore")
vlc_deepslate.register_deepslate_ore("redstone_ore_lit", S("Lit Deepslate Redstone Ore"), {
	tiles = { "vlc_deepslate_redstone_ore.png" },
	_vlc_ore_lit = "vlc_deepslate:deepslate_with_redstone_lit",
	_vlc_ore_unlit = "vlc_deepslate:deepslate_with_redstone",
	_vlc_silk_touch_drop = { "vlc_deepslate:deepslate_with_redstone" },
}, "vlc_core:redstone_ore_lit")
vlc_deepslate.register_deepslate_ore("copper", S("Deepslate Copper Ore"), nil, "vlc_copper:copper_ore")

register_deepslate_variant("cobbled", {
	node = {
		description = S("Cobbled Deepslate"),
		_doc_items_longdesc = S("Cobbled deepslate is a stone variant that functions similar to cobblestone or blackstone."),
		groups = { cobble = 1, stonecuttable = 1 },
	},
	stair = {
		description = S("Cobbled Deepslate Stairs"),
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled", },
	},
	slab = {
		description = S("Cobbled Deepslate Slab"),
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled", },
	},
	wall = {
		description = S("Cobbled Deepslate Wall"),
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled", },
	},
})

register_deepslate_variant("polished", {
	node = {
		description = S("Polished Deepslate"),
		_doc_items_longdesc = S("Polished deepslate is the stone-like polished version of deepslate."),
		groups = { stonecuttable = 1 },
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled",  },
	},
	stair = {
		description = S("Polished Deepslate Stairs"),
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled", "vlc_deepslate:deepslate_polished", },
	},
	slab = {
		description = S("Polished Deepslate Slab"),
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled", "vlc_deepslate:deepslate_polished", },
	},
	wall = {
		description = S("Polished Deepslate Wall"),
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled", "vlc_deepslate:deepslate_polished", },
	}
})

register_deepslate_variant("bricks", {
	node = {
		description = S("Deepslate Bricks"),
		_doc_items_longdesc = S("Deepslate bricks are the brick version of deepslate."),
		groups = { stonecuttable = 1 },
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled", "vlc_deepslate:deepslate_polished", "vlc_deepslate:deepslate_bricks", },
	},
	stair = {
		description = S("Deepslate Brick Stairs"),
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled", "vlc_deepslate:deepslate_polished", "vlc_deepslate:deepslate_bricks", },
	},
	slab = {
		description = S("Deepslate Brick Slab"),
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled", "vlc_deepslate:deepslate_polished", "vlc_deepslate:deepslate_bricks", },
	},
	wall = {
		description = S("Deepslate Brick Wall"),
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled", "vlc_deepslate:deepslate_polished", "vlc_deepslate:deepslate_bricks", },
	},
	cracked = {
		description = S("Cracked Deepslate Bricks"),
	}
})

register_deepslate_variant("tiles", {
	node = {
		description = S("Deepslate Tiles"),
		_doc_items_longdesc = S("Deepslate tiles are a decorative variant of deepslate."),
		groups = { stonecuttable = 1 },
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled", "vlc_deepslate:deepslate_polished", "vlc_deepslate:deepslate_bricks", },
	},
	stair = {
		description = S("Deepslate Tile Stairs"),
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled", "vlc_deepslate:deepslate_polished", "vlc_deepslate:deepslate_bricks", "vlc_deepslate:deepslate_tiles", },
	},
	slab = {
		description = S("Deepslate Tile Slab"),
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled", "vlc_deepslate:deepslate_polished", "vlc_deepslate:deepslate_bricks", "vlc_deepslate:deepslate_tiles", },
	},
	wall = {
		description = S("Deepslate Tiles Wall"),
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled", "vlc_deepslate:deepslate_polished", "vlc_deepslate:deepslate_bricks", "vlc_deepslate:deepslate_tiles", },
	},
	cracked = {
		description = S("Cracked Deepslate Tiles")
	}
})

register_deepslate_variant("chiseled", {
	node = {
		description = S("Chiseled Deepslate"),
		_doc_items_longdesc = S("Deepslate tiles are a decorative variant of deepslate."),
		_vlc_stonecutter_recipes = { "vlc_deepslate:deepslate_cobbled", }
	}
})

local deepslate_variants = {"cobbled", "polished", "bricks", "tiles"}
for i = 1, 3 do
	local s = "vlc_deepslate:deepslate_"..deepslate_variants[i]
	minetest.register_craft({
		output = "vlc_deepslate:deepslate_"..deepslate_variants[i+1].." 4",
		recipe = { { s, s }, { s, s } }
	})
end

for _, p in pairs({ "bricks", "tiles" }) do
	minetest.register_craft({
		type = "cooking",
		output = "vlc_deepslate:deepslate_"..p.."_cracked",
		recipe = "vlc_deepslate:deepslate_"..p,
		cooktime = 10,
	})
end

minetest.register_craft({
	type = "cooking",
	output = "vlc_deepslate:deepslate",
	recipe = cobble,
	cooktime = 10,
})

minetest.register_craft({
	output = "vlc_deepslate:deepslate_chiseled",
	recipe = {
		{ "vlc_stairs:slab_deepslate_cobbled" },
		{ "vlc_stairs:slab_deepslate_cobbled" },
	},
})
