local cobble = "vlf_deepslate:deepslate_cobbled"
local S = vlf_deepslate.translator

local function register_deepslate_variant(name, defs)
	vlf_deepslate.register_variants(name,table.update({
		basename = "deepslate",
		basetiles = "vlf_deepslate",
	}, defs))
end

minetest.register_node("vlf_deepslate:deepslate", {
	description = S("Deepslate"),
	_doc_items_longdesc = S("Deepslate is a stone type found deep underground in the Overworld that functions similar to regular stone but is harder than the stone."),
	_doc_items_hidden = false,
	tiles = { "vlf_deepslate_top.png", "vlf_deepslate_top.png", "vlf_deepslate.png" },
	paramtype2 = "facedir",
	on_place = vlf_util.rotate_axis,
	groups = { pickaxey = 1, stone = 1, building_block = 1, material_stone = 1, converts_to_moss = 1 },
	drop = cobble,
	sounds = vlf_sounds.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_3way,
	_vlf_blast_resistance = 6,
	_vlf_hardness = 3,
	_vlf_silk_touch_drop = true,
})

vlf_monster_eggs.register_infested_block("vlf_deepslate:deepslate", S("Infested Deepslate"))
minetest.register_alias("vlf_deepslate:infested_deepslate", "vlf_monster_eggs:monster_egg_deepslate")

minetest.register_node("vlf_deepslate:deepslate_reinforced", {
	description = S("Reinforced Deepslate"),
	_doc_items_longdesc = S("Reinforced deepslate is a very hard block undestructable by even wither explosions. It is unobtainable in survival mode."),
	_doc_items_hidden = false,
	tiles = {
		"vlf_deepslate_reinforced_top.png",
		"vlf_deepslate_reinforced_bottom.png",
		{name="vlf_deepslate_reinforced.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=7.25}}
	},
	is_ground_content = false,
	paramtype2 = "facedir",
	on_place = vlf_util.rotate_axis,
	groups = { stone = 1, building_block = 1, material_stone = 1 },
	drop = "",
	sounds = vlf_sounds.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_3way,
	_vlf_blast_resistance = 1200,
	_vlf_hardness = 55,
})

vlf_deepslate.register_deepslate_ore("coal", S("Deepslate Coal Ore"))
vlf_deepslate.register_deepslate_ore("iron", S("Deepslate Iron Ore"))
vlf_deepslate.register_deepslate_ore("gold", S("Deepslate Gold Ore"))
vlf_deepslate.register_deepslate_ore("emerald", S("Deepslate Emerald Ore"))
vlf_deepslate.register_deepslate_ore("diamond", S("Deepslate Diamond Ore"))
vlf_deepslate.register_deepslate_ore("lapis", S("Deepslate Lapis Lazuli Ore"))
vlf_deepslate.register_deepslate_ore("redstone", S("Deepslate Redstone Ore"), {
	_vlf_ore_lit = "vlf_deepslate:deepslate_with_redstone_lit",
	_vlf_ore_unlit = "vlf_deepslate:deepslate_with_redstone",
})
--[[vlf_deepslate.register_deepslate_ore("redstone_lit", S("Lit Deepslate Redstone Ore"), {
	tiles = { "vlf_deepslate_redstone_ore.png" },
	_vlf_ore_lit = "vlf_deepslate:deepslate_with_redstone_lit",
	_vlf_ore_unlit = "vlf_deepslate:deepslate_with_redstone",
	_vlf_silk_touch_drop = { "vlf_deepslate:deepslate_with_redstone" },
})]]
vlf_deepslate.register_deepslate_ore("copper", S("Deepslate Copper Ore"), nil, "vlf_copper:copper_ore")

register_deepslate_variant("cobbled", {
	node = {
		description = S("Cobbled Deepslate"),
		_doc_items_longdesc = S("Cobbled deepslate is a stone variant that functions similar to cobblestone or blackstone."),
		groups = { cobble = 1, stonecuttable = 1 },
	},
	stair = {
		description = S("Cobbled Deepslate Stairs"),
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled", },
	},
	slab = {
		description = S("Cobbled Deepslate Slab"),
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled", },
	},
	wall = {
		description = S("Cobbled Deepslate Wall"),
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled", },
	},
})

register_deepslate_variant("polished", {
	node = {
		description = S("Polished Deepslate"),
		_doc_items_longdesc = S("Polished deepslate is the stone-like polished version of deepslate."),
		groups = { stonecuttable = 1 },
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled",  },
	},
	stair = {
		description = S("Polished Deepslate Stairs"),
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled", "vlf_deepslate:deepslate_polished", },
	},
	slab = {
		description = S("Polished Deepslate Slab"),
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled", "vlf_deepslate:deepslate_polished", },
	},
	wall = {
		description = S("Polished Deepslate Wall"),
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled", "vlf_deepslate:deepslate_polished", },
	}
})

register_deepslate_variant("bricks", {
	node = {
		description = S("Deepslate Bricks"),
		_doc_items_longdesc = S("Deepslate bricks are the brick version of deepslate."),
		groups = { stonecuttable = 1 },
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled", "vlf_deepslate:deepslate_polished", "vlf_deepslate:deepslate_bricks", },
	},
	stair = {
		description = S("Deepslate Brick Stairs"),
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled", "vlf_deepslate:deepslate_polished", "vlf_deepslate:deepslate_bricks", },
	},
	slab = {
		description = S("Deepslate Brick Slab"),
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled", "vlf_deepslate:deepslate_polished", "vlf_deepslate:deepslate_bricks", },
	},
	wall = {
		description = S("Deepslate Brick Wall"),
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled", "vlf_deepslate:deepslate_polished", "vlf_deepslate:deepslate_bricks", },
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
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled", "vlf_deepslate:deepslate_polished", "vlf_deepslate:deepslate_bricks", },
	},
	stair = {
		description = S("Deepslate Tile Stairs"),
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled", "vlf_deepslate:deepslate_polished", "vlf_deepslate:deepslate_bricks", "vlf_deepslate:deepslate_tiles", },
	},
	slab = {
		description = S("Deepslate Tile Slab"),
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled", "vlf_deepslate:deepslate_polished", "vlf_deepslate:deepslate_bricks", "vlf_deepslate:deepslate_tiles", },
	},
	wall = {
		description = S("Deepslate Tiles Wall"),
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled", "vlf_deepslate:deepslate_polished", "vlf_deepslate:deepslate_bricks", "vlf_deepslate:deepslate_tiles", },
	},
	cracked = {
		description = S("Cracked Deepslate Tiles")
	}
})

register_deepslate_variant("chiseled", {
	node = {
		description = S("Chiseled Deepslate"),
		_doc_items_longdesc = S("Deepslate tiles are a decorative variant of deepslate."),
		_vlf_stonecutter_recipes = { "vlf_deepslate:deepslate_cobbled", }
	}
})

local deepslate_variants = {"cobbled", "polished", "bricks", "tiles"}
for i = 1, 3 do
	local s = "vlf_deepslate:deepslate_"..deepslate_variants[i]
	minetest.register_craft({
		output = "vlf_deepslate:deepslate_"..deepslate_variants[i+1].." 4",
		recipe = { { s, s }, { s, s } }
	})
end

for _, p in pairs({ "bricks", "tiles" }) do
	minetest.register_craft({
		type = "cooking",
		output = "vlf_deepslate:deepslate_"..p.."_cracked",
		recipe = "vlf_deepslate:deepslate_"..p,
		cooktime = 10,
	})
end

minetest.register_craft({
	type = "cooking",
	output = "vlf_deepslate:deepslate",
	recipe = cobble,
	cooktime = 10,
})

minetest.register_craft({
	output = "vlf_deepslate:deepslate_chiseled",
	recipe = {
		{ "vlf_stairs:slab_deepslate_cobbled" },
		{ "vlf_stairs:slab_deepslate_cobbled" },
	},
})
