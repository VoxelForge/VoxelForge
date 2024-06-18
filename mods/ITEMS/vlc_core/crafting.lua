-- mods/default/crafting.lua

--
-- Crafting definition
--

local function craft_planks(output, input)
	minetest.register_craft({
		output = "vlc_core:"..output.."wood 4",
		recipe = {
			{"vlc_core:"..input},
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
	output = "vlc_core:mossycobble",
	recipe = { "vlc_core:cobble", "vlc_core:vine" },
})

minetest.register_craft({
	type = "shapeless",
	output = "vlc_core:stonebrickmossy",
	recipe = { "vlc_core:stonebrick", "vlc_core:vine" },
})

minetest.register_craft({
	output = "vlc_core:coarse_dirt 4",
	recipe = {
		{"vlc_core:dirt", "vlc_core:gravel"},
		{"vlc_core:gravel", "vlc_core:dirt"},
	}
})
minetest.register_craft({
	output = "vlc_core:coarse_dirt 4",
	recipe = {
		{"vlc_core:gravel", "vlc_core:dirt"},
		{"vlc_core:dirt", "vlc_core:gravel"},
	}
})

minetest.register_craft({
	output = "vlc_core:sandstonesmooth 4",
	recipe = {
		{"vlc_core:sandstone","vlc_core:sandstone"},
		{"vlc_core:sandstone","vlc_core:sandstone"},
	}
})

minetest.register_craft({
	output = "vlc_core:redsandstonesmooth 4",
	recipe = {
		{"vlc_core:redsandstone","vlc_core:redsandstone"},
		{"vlc_core:redsandstone","vlc_core:redsandstone"},
	}
})

minetest.register_craft({
	output = "vlc_core:granite_smooth 4",
	recipe = {
		{"vlc_core:granite", "vlc_core:granite"},
		{"vlc_core:granite", "vlc_core:granite"}
	},
})

minetest.register_craft({
	output = "vlc_core:andesite_smooth 4",
	recipe = {
		{"vlc_core:andesite", "vlc_core:andesite"},
		{"vlc_core:andesite", "vlc_core:andesite"}
	},
})

minetest.register_craft({
	output = "vlc_core:diorite_smooth 4",
	recipe = {
		{"vlc_core:diorite", "vlc_core:diorite"},
		{"vlc_core:diorite", "vlc_core:diorite"}
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlc_core:granite",
	recipe = {"vlc_core:diorite", "vlc_nether:quartz"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlc_core:andesite 2",
	recipe = {"vlc_core:diorite", "vlc_core:cobble"},
})

minetest.register_craft({
	output = "vlc_core:diorite 2",
	recipe = {
		{"vlc_core:cobble", "vlc_nether:quartz"},
		{"vlc_nether:quartz", "vlc_core:cobble"},
	}
})
minetest.register_craft({
	output = "vlc_core:diorite 2",
	recipe = {
		{"vlc_nether:quartz", "vlc_core:cobble"},
		{"vlc_core:cobble", "vlc_nether:quartz"},
	}
})

minetest.register_craft({
	output = "vlc_core:bone_block",
	recipe = {
		{ "vlc_bone_meal:bone_meal", "vlc_bone_meal:bone_meal", "vlc_bone_meal:bone_meal" },
		{ "vlc_bone_meal:bone_meal", "vlc_bone_meal:bone_meal", "vlc_bone_meal:bone_meal" },
		{ "vlc_bone_meal:bone_meal", "vlc_bone_meal:bone_meal", "vlc_bone_meal:bone_meal" },
	},
})

minetest.register_craft({
	output = "vlc_bone_meal:bone_meal 9",
	recipe = {
		{ "vlc_core:bone_block" },
	},
})

minetest.register_craft({
	output = "vlc_core:stick 4",
	recipe = {
		{"group:wood"},
		{"group:wood"},
	}
})



minetest.register_craft({
	output = "vlc_core:coalblock",
	recipe = {
		{"vlc_core:coal_lump", "vlc_core:coal_lump", "vlc_core:coal_lump"},
		{"vlc_core:coal_lump", "vlc_core:coal_lump", "vlc_core:coal_lump"},
		{"vlc_core:coal_lump", "vlc_core:coal_lump", "vlc_core:coal_lump"},
	}
})

minetest.register_craft({
	output = "vlc_core:coal_lump 9",
	recipe = {
		{"vlc_core:coalblock"},
	}
})

minetest.register_craft({
	output = "vlc_core:ironblock",
	recipe = {
		{"vlc_core:iron_ingot", "vlc_core:iron_ingot", "vlc_core:iron_ingot"},
		{"vlc_core:iron_ingot", "vlc_core:iron_ingot", "vlc_core:iron_ingot"},
		{"vlc_core:iron_ingot", "vlc_core:iron_ingot", "vlc_core:iron_ingot"},
	}
})

minetest.register_craft({
	output = "vlc_core:iron_ingot 9",
	recipe = {
		{"vlc_core:ironblock"},
	}
})

minetest.register_craft({
	output = "vlc_core:goldblock",
	recipe = {
		{"vlc_core:gold_ingot", "vlc_core:gold_ingot", "vlc_core:gold_ingot"},
		{"vlc_core:gold_ingot", "vlc_core:gold_ingot", "vlc_core:gold_ingot"},
		{"vlc_core:gold_ingot", "vlc_core:gold_ingot", "vlc_core:gold_ingot"},
	}
})

minetest.register_craft({
	output = "vlc_core:gold_ingot 9",
	recipe = {
		{"vlc_core:goldblock"},
	}
})

minetest.register_craft({
	output = "vlc_core:gold_nugget 9",
	recipe = {{"vlc_core:gold_ingot"}},
})

minetest.register_craft({
	output = "vlc_core:iron_nugget 9",
	recipe = {{"vlc_core:iron_ingot"}},
})

minetest.register_craft({
	output = "vlc_core:gold_ingot",
	recipe = {
		{"vlc_core:gold_nugget", "vlc_core:gold_nugget", "vlc_core:gold_nugget"},
		{"vlc_core:gold_nugget", "vlc_core:gold_nugget", "vlc_core:gold_nugget"},
		{"vlc_core:gold_nugget", "vlc_core:gold_nugget", "vlc_core:gold_nugget"},
	}
})

minetest.register_craft({
	output = "vlc_core:iron_ingot",
	recipe = {
		{"vlc_core:iron_nugget", "vlc_core:iron_nugget", "vlc_core:iron_nugget"},
		{"vlc_core:iron_nugget", "vlc_core:iron_nugget", "vlc_core:iron_nugget"},
		{"vlc_core:iron_nugget", "vlc_core:iron_nugget", "vlc_core:iron_nugget"},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:iron_nugget",
	recipe = "vlc_mobitems:iron_horse_armor",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:gold_nugget",
	recipe = "vlc_mobitems:gold_horse_armor",
	cooktime = 10,
})

minetest.register_craft({
	output = "vlc_core:sandstone",
	recipe = {
		{"vlc_core:sand", "vlc_core:sand"},
		{"vlc_core:sand", "vlc_core:sand"},
	}
})

minetest.register_craft({
	output = "vlc_core:redsandstone",
	recipe = {
		{"vlc_core:redsand", "vlc_core:redsand"},
		{"vlc_core:redsand", "vlc_core:redsand"},
	}
})

minetest.register_craft({
	output = "vlc_core:clay",
	recipe = {
		{"vlc_core:clay_lump", "vlc_core:clay_lump"},
		{"vlc_core:clay_lump", "vlc_core:clay_lump"},
	}
})

minetest.register_craft({
	output = "vlc_core:brick_block",
	recipe = {
		{"vlc_core:brick", "vlc_core:brick"},
		{"vlc_core:brick", "vlc_core:brick"},
	}
})

minetest.register_craft({
	output = "vlc_core:paper 3",
	recipe = {
		{"vlc_core:reeds", "vlc_core:reeds", "vlc_core:reeds"},
	}
})

minetest.register_craft({
	output = "vlc_core:ladder 3",
	recipe = {
		{"vlc_core:stick", "", "vlc_core:stick"},
		{"vlc_core:stick", "vlc_core:stick", "vlc_core:stick"},
		{"vlc_core:stick", "", "vlc_core:stick"},
	}
})

minetest.register_craft({
	output = "vlc_core:stonebrick 4",
	recipe = {
		{"vlc_core:stone", "vlc_core:stone"},
		{"vlc_core:stone", "vlc_core:stone"},
	}
})

minetest.register_craft({
	output = "vlc_core:lapisblock",
	recipe = {
		{"vlc_core:lapis", "vlc_core:lapis", "vlc_core:lapis"},
		{"vlc_core:lapis", "vlc_core:lapis", "vlc_core:lapis"},
		{"vlc_core:lapis", "vlc_core:lapis", "vlc_core:lapis"},
	}
})

minetest.register_craft({
	output = "vlc_core:lapis 9",
	recipe = {
		{"vlc_core:lapisblock"},
	}
})

minetest.register_craft({
	output = "vlc_core:emeraldblock",
	recipe = {
		{"vlc_core:emerald", "vlc_core:emerald", "vlc_core:emerald"},
		{"vlc_core:emerald", "vlc_core:emerald", "vlc_core:emerald"},
		{"vlc_core:emerald", "vlc_core:emerald", "vlc_core:emerald"},
	}
})

minetest.register_craft({
	output = "vlc_core:emerald 9",
	recipe = {
		{"vlc_core:emeraldblock"},
	}
})

minetest.register_craft({
	output = "vlc_core:diamondblock",
	recipe = {
		{"vlc_core:diamond", "vlc_core:diamond", "vlc_core:diamond"},
		{"vlc_core:diamond", "vlc_core:diamond", "vlc_core:diamond"},
		{"vlc_core:diamond", "vlc_core:diamond", "vlc_core:diamond"},
	}
})

minetest.register_craft({
	output = "vlc_core:diamond 9",
	recipe = {
		{"vlc_core:diamondblock"},
	}
})

minetest.register_craft({
	output = "vlc_core:apple_gold",
	recipe = {
		{"vlc_core:gold_ingot", "vlc_core:gold_ingot", "vlc_core:gold_ingot"},
		{"vlc_core:gold_ingot", "vlc_core:apple", "vlc_core:gold_ingot"},
		{"vlc_core:gold_ingot", "vlc_core:gold_ingot", "vlc_core:gold_ingot"},
	}
})

minetest.register_craft({
	output = "vlc_core:sugar",
	recipe = {
		{"vlc_core:reeds"},
	}
})

minetest.register_craft({
	output = "vlc_core:bowl 4",
	recipe = {
		{"group:wood", "", "group:wood"},
		{"", "group:wood", ""},
	}
})

minetest.register_craft({
	output = "vlc_core:snowblock",
	recipe = {
		{"vlc_throwing:snowball", "vlc_throwing:snowball"},
		{"vlc_throwing:snowball", "vlc_throwing:snowball"},
	}
})

minetest.register_craft({
	output = "vlc_core:snow 6",
	recipe = {
		{"vlc_core:snowblock", "vlc_core:snowblock", "vlc_core:snowblock"},
	}
})

minetest.register_craft({
	output = 'vlc_core:packed_ice 1',
	recipe = {
		{'vlc_core:ice', 'vlc_core:ice', 'vlc_core:ice'},
		{'vlc_core:ice', 'vlc_core:ice', 'vlc_core:ice'},
		{'vlc_core:ice', 'vlc_core:ice', 'vlc_core:ice'},
	}
})

--
-- Crafting (tool repair)
--
minetest.register_craft({
	type = "toolrepair",
	additional_wear = -vlc_core.repair,
})

--
-- Cooking recipes
--

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:glass",
	recipe = "group:sand",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:stone",
	recipe = "vlc_core:cobble",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:stone_smooth",
	recipe = "vlc_core:stone",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:stonebrickcracked",
	recipe = "vlc_core:stonebrick",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:iron_ingot",
	recipe = "vlc_core:stone_with_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:gold_ingot",
	recipe = "vlc_core:stone_with_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:brick",
	recipe = "vlc_core:clay_lump",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:charcoal_lump",
	recipe = "group:tree",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:coal_lump",
	recipe = "vlc_core:stone_with_coal",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:diamond",
	recipe = "vlc_core:stone_with_diamond",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:emerald",
	recipe = "vlc_core:stone_with_emerald",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlc_core:lapis",
	recipe = "vlc_core:stone_with_lapis",
	cooktime = 10,
})

--
-- Fuels
--

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_core:coalblock",
	burntime = 800,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_core:coal_lump",
	burntime = 80,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_core:charcoal_lump",
	burntime = 80,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_core:ladder",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_core:bowl",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "vlc_core:stick",
	burntime = 5,
})
