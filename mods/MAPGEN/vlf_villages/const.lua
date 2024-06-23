local water_villages = minetest.settings:get_bool("vlf_villages_allow_water_villages", false)

-- switch for debugging
function vlf_villages.debug(message)
	minetest.log("verbose", "[vlf_villages] "..message)
end

vlf_villages.surface_mat = {}

function vlf_villages.grundstellungen()
	vlf_villages.surface_mat = vlf_villages.Set {
		"vlf_core:dirt_with_grass",
		--"vlf_core:dry_dirt_with_grass",
		"vlf_core:dirt_with_grass_snow",
		--"vlf_core:dirt_with_dry_grass",
		"vlf_core:podzol",
		"vlf_core:sand",
		"vlf_core:redsand",
		--"vlf_core:silver_sand",
		--"vlf_core:snow"
	}

	-- allow villages on more surfaces
	vlf_villages.surface_mat["vlf_colorblocks:hardened_clay"] = true
	vlf_villages.surface_mat["vlf_colorblocks:hardened_clay_orange"] = true
	vlf_villages.surface_mat["vlf_colorblocks:hardened_clay_red"] = true
	vlf_villages.surface_mat["vlf_colorblocks:hardened_clay_white"] = true
	vlf_villages.surface_mat["vlf_core:andesite"] = true
	vlf_villages.surface_mat["vlf_core:coarse_dirt"] = true
	vlf_villages.surface_mat["vlf_core:diorite"] = true
	vlf_villages.surface_mat["vlf_core:dirt"] = true
	vlf_villages.surface_mat["vlf_core:granite"] = true
	vlf_villages.surface_mat["vlf_core:grass_path"] = true
	vlf_villages.surface_mat["vlf_core:sandstone"] = true
	vlf_villages.surface_mat["vlf_core:sandstonesmooth"] = true
	vlf_villages.surface_mat["vlf_core:sandstonesmooth2"] = true
	vlf_villages.surface_mat["vlf_core:stone"] = true
	vlf_villages.surface_mat["vlf_core:stone_with_coal"] = true
	vlf_villages.surface_mat["vlf_core:stone_with_iron"] = true

	if water_villages then
		vlf_villages.surface_mat["vlf_core:water_source"] = true
		vlf_villages.surface_mat["vlf_core:river_water_source"] = true
		vlf_villages.surface_mat["vlf_core:water_flowing"] = true
		vlf_villages.surface_mat["vlf_core:river_water_flowing"] = true
	end
end

vlf_villages.half_map_chunk_size = 40

--
-- Biome based block substitutions
--
-- TODO maybe this should be in the biomes?
vlf_villages.biome_map = {
	BambooJungle = "bamboo",
	BambooJungleEdge = "bamboo",
	BambooJungleEdgeM = "bamboo",
	BambooJungleM = "bamboo",

	Jungle = "jungle",
	JungleEdge = "jungle",
	JungleEdgeM = "jungle",
	JungleM = "jungle",

	Desert = "desert",

	Savanna = "acacia",
	SavannaM = "acacia",

	Mesa = "hardened_clay",
	MesaBryce = "hardened_clay ",
	MesaPlateauF = "hardened_clay",
	MesaPlateauFM = "hardened_clay",

	MangroveSwamp = "mangrove",

	RoofedForest = "dark_oak",

	BirchForest = "birch",
	BirchForestM = "birch",

	ColdTaiga = "spruce",
	ExtremeHills = "spruce",
	ExtremeHillsM = "spruce",
	IcePlains = "spruce",
	IcePlainsSpikes = "spruce",
	MegaSpruceTaiga = "spruce",
	MegaTaiga = "spruce",
	Taiga = "spruce",
	["ExtremeHills+"] = "spruce",

	CherryGrove = "cherry",

	-- no change
	--FlowerForest = "oak",
	--Forest = "oak",
	--MushroomIsland = "",
	--Plains = "oak",
	--StoneBeach = "",
	--SunflowerPlains = "oak",
	--Swampland = "oak",
}

vlf_villages.material_substitions = {
	desert = {
		{ '"vlf_stairs:slab_oak([^"]*)"', '"vlf_stairs:slab_sandstonesmooth%1"' },
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_birchwood_%1"',
		},
		{ '"vlf_doors:trapdoor_oak([^"]*)"', '"vlf_doors:birch_trapdoor%1"' },
		{ '"vlf_doors:door_oak([^"]*)"', '"vlf_doors:birch_door%1"' },

		{ "vlf_core:cobble", "vlf_core:sandstone" },
		{ '"vlf_stairs:stair_cobble([^"]*)"', '"vlf_stairs:stair_sandstone%1"' },
		{ '"vlf_walls:cobble([^"]*)"', '"vlf_walls:sandstone%1"' },
		{ '"vlf_stairs:slab_cobble([^"]*)"', '"vlf_stairs:slab_sandstone%1"' },

		{ '"vlf_core:stonebrick"', '"vlf_core:redsandstone"' },
		{ '"vlf_core:stonebrick_([^"]+)"', '"vlf_core:redsandstone_%1"' },
		{ '"vlf_walls:stonebrick([^"]*)"', '"vlf_walls:redsandstone%1"' },
		{ '"vlf_stairs:stair_stonebrick"', '"vlf_stairs:stair_redsandstone"' },
		{ '"vlf_stairs:stair_stonebrick_([^"]+)"', '"vlf_stairs:stair_redsandstone_%1"' },

		{ '"vlf_stairs:slab_brick_block([^"]*)"', '"vlf_core:redsandstonesmooth2%1"' },
		{ '"vlf_core:brick_block"', '"vlf_core:redsandstonesmooth2"' },

		{ "vlf_trees:tree_oak", "vlf_core:redsandstonecarved" },
		{ "vlf_trees:wood_oak", "vlf_core:redsandstonesmooth" },
		{ '"vlf_fences:oak_fence([^"]*)"', '"vlf_fences:birch_fence%1"' },
		{ '"vlf_stairs:stair_oak_bark([^"]*)"', '"vlf_stairs:stair_sandstonesmooth2%1"' },
		{ '"vlf_stairs:stair_oak([^"]*)"', '"vlf_stairs:stair_sandstonesmooth%1"' },
	},
	spruce = {
		{ '"vlf_stairs:slab_oak([^"]*)"', '"vlf_stairs:slab_sprucewood%1"' },
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_sprucewood_%1"',
		},
		{ '"vlf_doors:trapdoor_oak([^"]*)"', '"vlf_doors:spruce_trapdoor%1"' },
		{ '"vlf_doors:door_oak([^"]*)"', '"vlf_doors:spruce_door%1"' },
		{ "vlf_trees:tree_oak", "vlf_trees:tree_spruce" },
		{ "vlf_trees:wood_oak", "vlf_trees:wood_spruce" },
		{ '"vlf_fences:oak_fence([^"]*)"', '"vlf_fences:spruce_fence%1"' },
		{ '"vlf_stairs:stair_oak([^"]*)"', '"vlf_stairs:stair_spruce%1"' },
	},
	birch = {
		{ '"vlf_stairs:slab_oak([^"]*)"', '"vlf_stairs:slab_birchwood%1"' },
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_birchwood_%1"',
		},
		{ '"vlf_doors:trapdoor_oak([^"]*)"', '"vlf_doors:birch_trapdoor%1"' },
		{ '"vlf_doors:door_oak([^"]*)"', '"vlf_doors:birch_door%1"' },
		{ "vlf_trees:tree_oak", "vlf_trees:tree_birch" },
		{ "vlf_trees:wood_oak", "vlf_trees:wood_birch" },
		{ '"vlf_fences:oak_fence([^"]*)"', '"vlf_fences:birch_fence%1"' },
		{ '"vlf_stairs:stair_oak([^"]*)"', '"vlf_stairs:stair_birch%1"' },
	},
	acacia = {
		{ '"vlf_stairs:slab_oak([^"]*)"', '"vlf_stairs:slab_acaciawood%1"' },
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_acaciawood_%1"',
		},
		{ '"vlf_doors:trapdoor_oak([^"]*)"', '"vlf_doors:acacia_trapdoor%1"' },
		{ '"vlf_doors:door_oak([^"]*)"', '"vlf_doors:acacia_door%1"' },
		{ "vlf_trees:tree_oak", "vlf_trees:tree_acacia" },
		{ "vlf_trees:wood_oak", "vlf_trees:wood_acacia" },
		{ '"vlf_fences:oak_fence([^"]*)"', '"vlf_fences:acacia_fence%1"' },
		{ '"vlf_stairs:stair_oak([^"]*)"', '"vlf_stairs:stair_acacia%1"' },
	},
	dark_oak = {
		{ '"vlf_stairs:slab_oak([^"]*)"', '"vlf_stairs:slab_darkwood%1"' },
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_darkwood_%1"',
		},
		{ '"vlf_doors:trapdoor_oak([^"]*)"', '"vlf_doors:dark_oak_trapdoor%1"' },
		{ '"vlf_doors:door_oak([^"]*)"', '"vlf_doors:dark_oak_door%1"' },
		{ "vlf_trees:tree_oak", "vlf_trees:tree_dark_oak" },
		{ "vlf_trees:wood_oak", "vlf_trees:wood_dark_oak" },
		{ '"vlf_fences:oak_fence([^"]*)"', '"vlf_fences:dark_oak_fence%1"' },
		{ '"vlf_stairs:stair_oak([^"]*)"', '"vlf_stairs:stair_dark_oak%1"' },
	},
	jungle = {
		{ '"vlf_stairs:slab_oak([^"]*)"', '"vlf_stairs:slab_junglewood%1"' },
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_junglewood_%1"',
		},
		{ '"vlf_doors:trapdoor_oak([^"]*)"', '"vlf_doors:jungle_trapdoor%1"' },
		{ '"vlf_doors:door_oak([^"]*)"', '"vlf_doors:jungle_door%1"' },
		{ "vlf_trees:tree_oak", "vlf_trees:tree_jungle" },
		{ "vlf_trees:wood_oak", "vlf_trees:wood_jungle" },
		{ '"vlf_fences:oak_fence([^"]*)"', '"vlf_fences:jungle_fence%1"' },
		{ '"vlf_stairs:stair_oak([^"]*)"', '"vlf_stairs:stair_jungle%1"' },
	},
	bamboo = {
		{ '"vlf_stairs:slab_oak([^"]*)"', '"vlf_stairs:slab_bamboo_block%1"' },
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_bamboo_%1"',
		},
		{ '"vlf_doors:trapdoor_oak([^"]*)"', '"vlf_doors:trapdoor_bamboo%1"' },
		{ '"vlf_doors:door_oak([^"]*)"', '"vlf_doors:door_bamboo%1"' },

		{ "vlf_core:cobble", "vlf_core:andesite" },
		{ '"vlf_stairs:stair_cobble([^"]*)"', '"vlf_stairs:stair_andesite%1"' },
		{ '"vlf_walls:cobble([^"]*)"', '"vlf_walls:andesite%1"' },
		{ '"vlf_stairs:slab_cobble([^"]*)"', '"vlf_stairs:slab_andesite%1"' },
		{ "vlf_trees:tree_oak", "vlf_trees:tree_bamboo" },
		{ "vlf_trees:wood_oak", "vlf_trees:wood_bamboo" },
		{ '"vlf_fences:oak_fence([^"]*)"', '"vlf_fences:bamboo_fence%1"' },
		{ '"vlf_stairs:stair_oak([^"]*)"', '"vlf_stairs:stair_bamboo%1"' },
	},
	cherry = {
		{ '"vlf_stairs:slab_oak([^"]*)"', '"vlf_stairs:slab_cherry_blossom%1"' },
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_cherry_blossom_%1"',
		},
		{ '"vlf_doors:trapdoor_oak([^"]*)"', '"vlf_doors:trapdoor_cherry_blossom%1"' },
		{ '"vlf_doors:door_oak([^"]*)"', '"vlf_doors:door_cherry_blossom%1"' },
		{ "vlf_trees:tree_oak", "vlf_trees:tree_cherry_blossom" },
		{ "vlf_trees:wood_oak", "vlf_trees:wood_cherry_blossom" },
		{ '"vlf_fences:oak_fence([^"]*)"', '"vlf_fences:cherry_blossom_fence%1"' },
		{ '"vlf_stairs:stair_oak([^"]*)"', '"vlf_stairs:stair_cherry_blossom%1"' },
	},
}
