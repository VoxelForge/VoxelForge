local S = vlf_deepslate.translator

local function register_tuff_variant(name, defs)
	vlf_deepslate.register_variants(name,table.update({
		basename = "tuff",
		basetiles = "vlf_deepslate_tuff",
		basedef = {
			_vlf_hardness = 1.5,
		},
	}, defs))
end
local function register_tuff_polished_variant(name, defs)
	vlf_deepslate.register_polished_variant(name,table.update({
		basename = "polished_tuff",
		basetiles = "vlf_deepslate_tuff",
		basedef = {
			_vlf_hardness = 1.5,
		},
	}, defs))
end

minetest.register_node("vlf_deepslate:tuff", {
	description = S("Tuff"),
	_doc_items_longdesc = S("Tuff is an ornamental rock formed from volcanic ash, occurring in underground blobs below Y=16."),
	_doc_items_hidden = false,
	tiles = { "vlf_deepslate_tuff.png" },
	groups = { pickaxey = 1, building_block = 1, converts_to_moss = 1 },
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = 6,
	_vlf_hardness = 1.5,
})

minetest.register_node("vlf_deepslate:chiseled_tuff", {
    description = S("Chiseled Tuff"),
    _doc_items_longdesc = S("Chiseled tuff is a chiseled variant of tuff."),
    _doc_items_hidden = false,
    tiles = { "vlf_deepslate_tuff_chiseled_top.png", "vlf_deepslate_tuff_chiseled_top.png", "vlf_deepslate_tuff_chiseled.png" },
    groups = { pickaxey = 1, building_block = 1 },
    sounds = vlf_sounds.node_sound_stone_defaults(),
    _vlf_blast_resistance = 6,
    _vlf_hardness = 1.5,
    _vlf_stonecutter_recipes = { "vlf_deepslate:tuff", },
})

minetest.register_node("vlf_deepslate:chiseled_tuff_bricks", {
    description = S("Chiseled Tuff Bricks"),
    _doc_items_longdesc = S("Chiseled tuff bricks are a variant of tuff bricks, featuring a large brick in the center of the block, with geometric design above and below."),
    _doc_items_hidden = false,
    tiles = { "vlf_deepslate_tuff_chiseled_bricks_top.png", "vlf_deepslate_tuff_chiseled_bricks_top.png", "vlf_deepslate_tuff_chiseled_bricks.png"},
    groups = { pickaxey = 1, building_block = 1 },
    sounds = vlf_sounds.node_sound_stone_defaults(),
    _vlf_blast_resistance = 6,
    _vlf_hardness = 1.5,
    _vlf_stonecutter_recipes = { "vlf_deepslate:tuff", "vlf_deepslate:polished_tuff", "vlf_deepslate:tuff_bricks", },
})

register_tuff_variant("", {
    stair = {
        description = S("Tuff Stairs"),
        _vlf_stonecutter_recipes = { "vlf_deepslate:tuff", },
    },
    slab = {
        description = S("Tuff Slab"),
        _vlf_stonecutter_recipes = { "vlf_deepslate:tuff", },
    },
    wall = {
        description = S("Tuff Wall"),
        _vlf_stonecutter_recipes = { "vlf_deepslate:tuff", },
    },
})

register_tuff_polished_variant("polished", {
    node = {
        description = S("Polished Tuff"),
        _doc_items_longdesc = S("Polished tuff is a polished variant of the tuff block."),
        groups = { stonecuttable = 1 },
        _vlf_stonecutter_recipes = { "vlf_deepslate:tuff", },
    },
    stair = {
        description = S("Polished Tuff Stairs"),
        _vlf_stonecutter_recipes = { "vlf_deepslate:tuff", "vlf_deepslate:tuff_polished", },
    },
    slab = {
        description = S("Polished Tuff Slab"),
        _vlf_stonecutter_recipes = { "vlf_deepslate:tuff", "vlf_deepslate:tuff_polished", },
    },
    wall = {
        description = S("Polished Tuff Wall"),
        _vlf_stonecutter_recipes = { "vlf_deepslate:tuff", "vlf_deepslate:tuff_polished", },
    },
})

register_tuff_variant("bricks", {
    node = {
        description = S("Tuff Bricks"),
        _doc_items_longdesc = S("Tuff bricks are a brick variant of tuff."),
        groups = { stonecuttable = 1 },
        _vlf_stonecutter_recipes = { "vlf_deepslate:tuff_polished", },
    },
    stair = {
        description = S("Tuff Bricks Stairs"),
        _vlf_stonecutter_recipes = { "vlf_deepslate:tuff", "vlf_deepslate:tuff_polished", "vlf_deepslate:tuff_polished", },
    },
    slab = {
        description = S("Tuff Bricks Slab"),
        _vlf_stonecutter_recipes = { "vlf_deepslate:tuff", "vlf_deepslate:tuff_polished", "vlf_deepslate:tuff_polished", },
    },
    wall = {
        description = S("Tuff Bricks Wall"),
        _vlf_stonecutter_recipes = { "vlf_deepslate:tuff", "vlf_deepslate:tuff_polished", "vlf_deepslate:tuff_polished", },
    },
})

local tuff_variants = {"tuff", "polished", "bricks"}
for i = 1, 2 do
    local s = "vlf_deepslate:tuff_"..tuff_variants[i]
    minetest.register_craft({
        output = "vlf_deepslate:tuff_"..tuff_variants[i+1].." 4",
		recipe = { { s, s }, { s, s } }
    })
end

minetest.register_craft({
	output = "vlf_deepslate:tuff_chiseled",
	recipe = {
		{ "vlf_stairs:slab_tuff" },
		{ "vlf_stairs:slab_tuff" },
	},
})

minetest.register_craft({
	output = "vlf_deepslate:tuff_chiseled_bricks",
	recipe = {
		{ "vlf_stairs:slab_tuff_bricks" },
		{ "vlf_stairs:slab_tuff_bricks" },
	},
})
