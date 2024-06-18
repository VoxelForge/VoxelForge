-- mods/default/crafting.lua

--
-- Crafting definition
--

local function craft_planks(output, input)
	minetest.register_craft({
		output = "vlf_core:"..output.."wood 4",
		recipe = {
			{"vlf_core:"..input},
		}
	})
end

local planks = {
	{"", "oak"},
	{"dark", "dark_oak"},
	{"jungle", "jungle"},
	{"acacia", "acacia"},
	{"spruce", "spruce"},
	{"birch", "birch"}
}

for _, p in pairs(planks) do
	craft_planks(p[1], p[1].."tree")
	craft_planks(p[1], p[1].."tree_bark")
	craft_planks(p[1], "stripped_"..p[2])
	craft_planks(p[1], "stripped_"..p[2].."_bark")
end

minetest.register_craft({
	type = "shapeless",
	output = "vlf_core:mossycobble",
	recipe = { "vlf_core:cobble", "vlf_core:vine" },
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_core:stonebrickmossy",
	recipe = { "vlf_core:stonebrick", "vlf_core:vine" },
})

minetest.register_craft({
	output = "vlf_core:coarse_dirt 4",
	recipe = {
		{"vlf_core:dirt", "vlf_core:gravel"},
		{"vlf_core:gravel", "vlf_core:dirt"},
	}
})
minetest.register_craft({
	output = "vlf_core:coarse_dirt 4",
	recipe = {
		{"vlf_core:gravel", "vlf_core:dirt"},
		{"vlf_core:dirt", "vlf_core:gravel"},
	}
})

minetest.register_craft({
	output = "vlf_core:sandstonesmooth 4",
	recipe = {
		{"vlf_core:sandstone","vlf_core:sandstone"},
		{"vlf_core:sandstone","vlf_core:sandstone"},
	}
})

minetest.register_craft({
	output = "vlf_core:redsandstonesmooth 4",
	recipe = {
		{"vlf_core:redsandstone","vlf_core:redsandstone"},
		{"vlf_core:redsandstone","vlf_core:redsandstone"},
	}
})

minetest.register_craft({
	output = "vlf_core:granite_smooth 4",
	recipe = {
		{"vlf_core:granite", "vlf_core:granite"},
		{"vlf_core:granite", "vlf_core:granite"}
	},
})

minetest.register_craft({
	output = "vlf_core:andesite_smooth 4",
	recipe = {
		{"vlf_core:andesite", "vlf_core:andesite"},
		{"vlf_core:andesite", "vlf_core:andesite"}
	},
})

minetest.register_craft({
	output = "vlf_core:diorite_smooth 4",
	recipe = {
		{"vlf_core:diorite", "vlf_core:diorite"},
		{"vlf_core:diorite", "vlf_core:diorite"}
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_core:granite",
	recipe = {"vlf_core:diorite", "vlf_nether:quartz"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlf_core:andesite 2",
	recipe = {"vlf_core:diorite", "vlf_core:cobble"},
})

minetest.register_craft({
	output = "vlf_core:diorite 2",
	recipe = {
		{"vlf_core:cobble", "vlf_nether:quartz"},
		{"vlf_nether:quartz", "vlf_core:cobble"},
	}
})
minetest.register_craft({
	output = "vlf_core:diorite 2",
	recipe = {
		{"vlf_nether:quartz", "vlf_core:cobble"},
		{"vlf_core:cobble", "vlf_nether:quartz"},
	}
})

minetest.register_craft({
	output = "vlf_core:bone_block",
	recipe = {
		{ "vlf_bone_meal:bone_meal", "vlf_bone_meal:bone_meal", "vlf_bone_meal:bone_meal" },
		{ "vlf_bone_meal:bone_meal", "vlf_bone_meal:bone_meal", "vlf_bone_meal:bone_meal" },
		{ "vlf_bone_meal:bone_meal", "vlf_bone_meal:bone_meal", "vlf_bone_meal:bone_meal" },
	},
})

minetest.register_craft({
	output = "vlf_bone_meal:bone_meal 9",
	recipe = {
		{ "vlf_core:bone_block" },
	},
})

minetest.register_craft({
	output = "vlf_core:stick 4",
	recipe = {
		{"group:wood"},
		{"group:wood"},
	}
})



minetest.register_craft({
	output = "vlf_core:coalblock",
	recipe = {
		{"vlf_core:coal_lump", "vlf_core:coal_lump", "vlf_core:coal_lump"},
		{"vlf_core:coal_lump", "vlf_core:coal_lump", "vlf_core:coal_lump"},
		{"vlf_core:coal_lump", "vlf_core:coal_lump", "vlf_core:coal_lump"},
	}
})

minetest.register_craft({
	output = "vlf_core:coal_lump 9",
	recipe = {
		{"vlf_core:coalblock"},
	}
})

minetest.register_craft({
	output = "vlf_core:ironblock",
	recipe = {
		{"vlf_core:iron_ingot", "vlf_core:iron_ingot", "vlf_core:iron_ingot"},
		{"vlf_core:iron_ingot", "vlf_core:iron_ingot", "vlf_core:iron_ingot"},
		{"vlf_core:iron_ingot", "vlf_core:iron_ingot", "vlf_core:iron_ingot"},
	}
})

minetest.register_craft({
	output = "vlf_core:iron_ingot 9",
	recipe = {
		{"vlf_core:ironblock"},
	}
})

minetest.register_craft({
	output = "vlf_core:goldblock",
	recipe = {
		{"vlf_core:gold_ingot", "vlf_core:gold_ingot", "vlf_core:gold_ingot"},
		{"vlf_core:gold_ingot", "vlf_core:gold_ingot", "vlf_core:gold_ingot"},
		{"vlf_core:gold_ingot", "vlf_core:gold_ingot", "vlf_core:gold_ingot"},
	}
})

minetest.register_craft({
	output = "vlf_core:gold_ingot 9",
	recipe = {
		{"vlf_core:goldblock"},
	}
})

minetest.register_craft({
	output = "vlf_core:gold_nugget 9",
	recipe = {{"vlf_core:gold_ingot"}},
})

minetest.register_craft({
	output = "vlf_core:iron_nugget 9",
	recipe = {{"vlf_core:iron_ingot"}},
})

minetest.register_craft({
	output = "vlf_core:gold_ingot",
	recipe = {
		{"vlf_core:gold_nugget", "vlf_core:gold_nugget", "vlf_core:gold_nugget"},
		{"vlf_core:gold_nugget", "vlf_core:gold_nugget", "vlf_core:gold_nugget"},
		{"vlf_core:gold_nugget", "vlf_core:gold_nugget", "vlf_core:gold_nugget"},
	}
})

minetest.register_craft({
	output = "vlf_core:iron_ingot",
	recipe = {
		{"vlf_core:iron_nugget", "vlf_core:iron_nugget", "vlf_core:iron_nugget"},
		{"vlf_core:iron_nugget", "vlf_core:iron_nugget", "vlf_core:iron_nugget"},
		{"vlf_core:iron_nugget", "vlf_core:iron_nugget", "vlf_core:iron_nugget"},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:iron_nugget",
	recipe = "vlf_mobitems:iron_horse_armor",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:gold_nugget",
	recipe = "vlf_mobitems:gold_horse_armor",
	cooktime = 10,
})

minetest.register_craft({
	output = "vlf_core:sandstone",
	recipe = {
		{"vlf_core:sand", "vlf_core:sand"},
		{"vlf_core:sand", "vlf_core:sand"},
	}
})

minetest.register_craft({
	output = "vlf_core:redsandstone",
	recipe = {
		{"vlf_core:redsand", "vlf_core:redsand"},
		{"vlf_core:redsand", "vlf_core:redsand"},
	}
})

minetest.register_craft({
	output = "vlf_core:clay",
	recipe = {
		{"vlf_core:clay_lump", "vlf_core:clay_lump"},
		{"vlf_core:clay_lump", "vlf_core:clay_lump"},
	}
})

minetest.register_craft({
	output = "vlf_core:brick_block",
	recipe = {
		{"vlf_core:brick", "vlf_core:brick"},
		{"vlf_core:brick", "vlf_core:brick"},
	}
})

minetest.register_craft({
	output = "vlf_core:paper 3",
	recipe = {
		{"vlf_core:reeds", "vlf_core:reeds", "vlf_core:reeds"},
	}
})

minetest.register_craft({
	output = "vlf_core:ladder 3",
	recipe = {
		{"vlf_core:stick", "", "vlf_core:stick"},
		{"vlf_core:stick", "vlf_core:stick", "vlf_core:stick"},
		{"vlf_core:stick", "", "vlf_core:stick"},
	}
})

minetest.register_craft({
	output = "vlf_core:stonebrick 4",
	recipe = {
		{"vlf_core:stone", "vlf_core:stone"},
		{"vlf_core:stone", "vlf_core:stone"},
	}
})

minetest.register_craft({
	output = "vlf_core:lapisblock",
	recipe = {
		{"vlf_core:lapis", "vlf_core:lapis", "vlf_core:lapis"},
		{"vlf_core:lapis", "vlf_core:lapis", "vlf_core:lapis"},
		{"vlf_core:lapis", "vlf_core:lapis", "vlf_core:lapis"},
	}
})

minetest.register_craft({
	output = "vlf_core:lapis 9",
	recipe = {
		{"vlf_core:lapisblock"},
	}
})

minetest.register_craft({
	output = "vlf_core:emeraldblock",
	recipe = {
		{"vlf_core:emerald", "vlf_core:emerald", "vlf_core:emerald"},
		{"vlf_core:emerald", "vlf_core:emerald", "vlf_core:emerald"},
		{"vlf_core:emerald", "vlf_core:emerald", "vlf_core:emerald"},
	}
})

minetest.register_craft({
	output = "vlf_core:emerald 9",
	recipe = {
		{"vlf_core:emeraldblock"},
	}
})

minetest.register_craft({
	output = "vlf_core:diamondblock",
	recipe = {
		{"vlf_core:diamond", "vlf_core:diamond", "vlf_core:diamond"},
		{"vlf_core:diamond", "vlf_core:diamond", "vlf_core:diamond"},
		{"vlf_core:diamond", "vlf_core:diamond", "vlf_core:diamond"},
	}
})

minetest.register_craft({
	output = "vlf_core:diamond 9",
	recipe = {
		{"vlf_core:diamondblock"},
	}
})

minetest.register_craft({
	output = "vlf_core:apple_gold",
	recipe = {
		{"vlf_core:gold_ingot", "vlf_core:gold_ingot", "vlf_core:gold_ingot"},
		{"vlf_core:gold_ingot", "vlf_core:apple", "vlf_core:gold_ingot"},
		{"vlf_core:gold_ingot", "vlf_core:gold_ingot", "vlf_core:gold_ingot"},
	}
})

minetest.register_craft({
	output = "vlf_core:sugar",
	recipe = {
		{"vlf_core:reeds"},
	}
})

minetest.register_craft({
	output = "vlf_core:bowl 4",
	recipe = {
		{"group:wood", "", "group:wood"},
		{"", "group:wood", ""},
	}
})

minetest.register_craft({
	output = "vlf_core:snowblock",
	recipe = {
		{"vlf_throwing:snowball", "vlf_throwing:snowball"},
		{"vlf_throwing:snowball", "vlf_throwing:snowball"},
	}
})

minetest.register_craft({
	output = "vlf_core:snow 6",
	recipe = {
		{"vlf_core:snowblock", "vlf_core:snowblock", "vlf_core:snowblock"},
	}
})

minetest.register_craft({
	output = 'vlf_core:packed_ice 1',
	recipe = {
		{'vlf_core:ice', 'vlf_core:ice', 'vlf_core:ice'},
		{'vlf_core:ice', 'vlf_core:ice', 'vlf_core:ice'},
		{'vlf_core:ice', 'vlf_core:ice', 'vlf_core:ice'},
	}
})

--
-- Crafting (tool repair)
--
minetest.register_craft({
	type = "toolrepair",
	additional_wear = -vlf_core.repair,
})

--
-- Cooking recipes
--

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:glass",
	recipe = "group:sand",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:stone",
	recipe = "vlf_core:cobble",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:stone_smooth",
	recipe = "vlf_core:stone",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:stonebrickcracked",
	recipe = "vlf_core:stonebrick",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:iron_ingot",
	recipe = "vlf_core:stone_with_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:gold_ingot",
	recipe = "vlf_core:stone_with_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:brick",
	recipe = "vlf_core:clay_lump",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:charcoal_lump",
	recipe = "group:tree",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:coal_lump",
	recipe = "vlf_core:stone_with_coal",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:diamond",
	recipe = "vlf_core:stone_with_diamond",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:emerald",
	recipe = "vlf_core:stone_with_emerald",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_core:lapis",
	recipe = "vlf_core:stone_with_lapis",
	cooktime = 10,
})

--
-- Fuels
--

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_core:coalblock",
	burntime = 800,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_core:coal_lump",
	burntime = 80,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_core:charcoal_lump",
	burntime = 80,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_core:ladder",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_core:bowl",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlf_core:stick",
	burntime = 5,
})
