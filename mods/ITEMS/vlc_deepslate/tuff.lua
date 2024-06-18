local S = vlc_deepslate.translator

local function register_tuff_variant(name, defs)
	vlc_deepslate.register_variants(name,table.update({
		basename = "tuff",
		basetiles = "vlc_deepslate_tuff",
		basedef = {
			_vlc_hardness = 1.5,
		},
	}, defs))
end
local function register_tuff_polished_variant(name, defs)
	vlc_deepslate.register_polished_variant(name,table.update({
		basename = "polished_tuff",
		basetiles = "vlc_deepslate_tuff",
		basedef = {
			_vlc_hardness = 1.5,
		},
	}, defs))
end

minetest.register_node("vlc_deepslate:tuff", {
	description = S("Tuff"),
	_doc_items_longdesc = S("Tuff is an ornamental rock formed from volcanic ash, occurring in underground blobs below Y=16."),
	_doc_items_hidden = false,
	tiles = { "vlc_deepslate_tuff.png" },
	groups = { pickaxey = 1, building_block = 1, converts_to_moss = 1 },
	sounds = vlc_sounds.node_sound_stone_defaults(),
	_vlc_blast_resistance = 6,
	_vlc_hardness = 1.5,
})

minetest.register_node("vlc_deepslate:chiseled_tuff", {
    description = S("Chiseled Tuff"),
    _doc_items_longdesc = S("Chiseled tuff is a chiseled variant of tuff."),
    _doc_items_hidden = false,
    tiles = { "vlc_deepslate_tuff_chiseled_top.png", "vlc_deepslate_tuff_chiseled_top.png", "vlc_deepslate_tuff_chiseled.png" },
    groups = { pickaxey = 1, building_block = 1 },
    sounds = vlc_sounds.node_sound_stone_defaults(),
    _vlc_blast_resistance = 6,
    _vlc_hardness = 1.5,
    _vlc_stonecutter_recipes = { "vlc_deepslate:tuff", },
})

minetest.register_node("vlc_deepslate:chiseled_tuff_bricks", {
    description = S("Chiseled Tuff Bricks"),
    _doc_items_longdesc = S("Chiseled tuff bricks are a variant of tuff bricks, featuring a large brick in the center of the block, with geometric design above and below."),
    _doc_items_hidden = false,
    tiles = { "vlc_deepslate_tuff_chiseled_bricks_top.png", "vlc_deepslate_tuff_chiseled_bricks_top.png", "vlc_deepslate_tuff_chiseled_bricks.png"},
    groups = { pickaxey = 1, building_block = 1 },
    sounds = vlc_sounds.node_sound_stone_defaults(),
    _vlc_blast_resistance = 6,
    _vlc_hardness = 1.5,
    _vlc_stonecutter_recipes = { "vlc_deepslate:tuff", "vlc_deepslate:polished_tuff", "vlc_deepslate:tuff_bricks", },
})

register_tuff_variant("", {
    stair = {
        description = S("Tuff Stairs"),
        _vlc_stonecutter_recipes = { "vlc_deepslate:tuff", },
    },
    slab = {
        description = S("Tuff Slab"),
        _vlc_stonecutter_recipes = { "vlc_deepslate:tuff", },
    },
    wall = {
        description = S("Tuff Wall"),
        _vlc_stonecutter_recipes = { "vlc_deepslate:tuff", },
    },
})

register_tuff_polished_variant("polished", {
    node = {
        description = S("Polished Tuff"),
        _doc_items_longdesc = S("Polished tuff is a polished variant of the tuff block."),
        groups = { stonecuttable = 1 },
        _vlc_stonecutter_recipes = { "vlc_deepslate:tuff", },
    },
    stair = {
        description = S("Polished Tuff Stairs"),
        _vlc_stonecutter_recipes = { "vlc_deepslate:tuff", "vlc_deepslate:tuff_polished", },
    },
    slab = {
        description = S("Polished Tuff Slab"),
        _vlc_stonecutter_recipes = { "vlc_deepslate:tuff", "vlc_deepslate:tuff_polished", },
    },
    wall = {
        description = S("Polished Tuff Wall"),
        _vlc_stonecutter_recipes = { "vlc_deepslate:tuff", "vlc_deepslate:tuff_polished", },
    },
})

register_tuff_variant("bricks", {
    node = {
        description = S("Tuff Bricks"),
        _doc_items_longdesc = S("Tuff bricks are a brick variant of tuff."),
        groups = { stonecuttable = 1 },
        _vlc_stonecutter_recipes = { "vlc_deepslate:tuff_polished", },
    },
    stair = {
        description = S("Tuff Bricks Stairs"),
        _vlc_stonecutter_recipes = { "vlc_deepslate:tuff", "vlc_deepslate:tuff_polished", "vlc_deepslate:tuff_polished", },
    },
    slab = {
        description = S("Tuff Bricks Slab"),
        _vlc_stonecutter_recipes = { "vlc_deepslate:tuff", "vlc_deepslate:tuff_polished", "vlc_deepslate:tuff_polished", },
    },
    wall = {
        description = S("Tuff Bricks Wall"),
        _vlc_stonecutter_recipes = { "vlc_deepslate:tuff", "vlc_deepslate:tuff_polished", "vlc_deepslate:tuff_polished", },
    },
})

local tuff_variants = {"tuff", "polished", "bricks"}
for i = 1, 2 do
    local s = "vlc_deepslate:tuff_"..tuff_variants[i]
    minetest.register_craft({
        output = "vlc_deepslate:tuff_"..tuff_variants[i+1].." 4",
		recipe = { { s, s }, { s, s } }
    })
end

minetest.register_craft({
	output = "vlc_deepslate:tuff_chiseled",
	recipe = {
		{ "vlc_stairs:slab_tuff" },
		{ "vlc_stairs:slab_tuff" },
	},
})

minetest.register_craft({
	output = "vlc_deepslate:tuff_chiseled_bricks",
	recipe = {
		{ "vlc_stairs:slab_tuff_bricks" },
		{ "vlc_stairs:slab_tuff_bricks" },
	},
})
