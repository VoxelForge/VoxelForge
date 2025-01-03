local deepslate_max = vlf_worlds.layer_to_y(16)
local deepslate_min = vlf_vars.mg_overworld_min

local mountains = {
	"ExtremeHills", "ExtremeHills_beach", "ExtremeHills_ocean", "ExtremeHills_deep_ocean", "ExtremeHills_underground",
	"ExtremeHills+", "ExtremeHills+_ocean", "ExtremeHills+_deep_ocean", "ExtremeHills+_underground",
	"ExtremeHillsM", "ExtremeHillsM_ocean", "ExtremeHillsM_deep_ocean", "ExtremeHillsM_underground",
}

local mesa = {
	"Mesa", "Mesa_sandlevel", "Mesa_ocean", "MesaBryce", "MesaBryce_sandlevel",
	"MesaBryce_ocean", "MesaPlateauF", "MesaPlateauF_sandlevel", "MesaPlateauF_ocean",
	"MesaPlateauFM", "MesaPlateauFM_sandlevel", "MesaPlateauFM_ocean",
}

--Clay
minetest.register_ore({
	ore_type       = "blob",
	ore            = "vlf_core:clay",
	wherein        = {"vlf_core:sand","vlf_core:stone","vlf_core:gravel"},
	clust_scarcity = 15*15*15,
	clust_num_ores = 33,
	clust_size     = 5,
	y_min          = -5,
	y_max          = 0,
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 34843,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

-- Diorite, andesite and granite
local specialstones = { "vlf_core:diorite", "vlf_core:andesite", "vlf_core:granite" }
for s=1, #specialstones do
	local node = specialstones[s]
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"vlf_core:stone"},
		clust_scarcity = 15*15*15,
		clust_num_ores = 33,
		clust_size     = 5,
		y_min          = vlf_vars.mg_overworld_min,
		y_max          = vlf_vars.mg_overworld_max,
		noise_params = {
			offset  = 0,
			scale   = 1,
			spread  = {x=250, y=250, z=250},
			seed    = 12345,
			octaves = 3,
			persist = 0.6,
			lacunarity = 2,
			flags = "defaults",
		}
	})
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"vlf_core:stone"},
		clust_scarcity = 10*10*10,
		clust_num_ores = 58,
		clust_size     = 7,
		y_min          = vlf_vars.mg_overworld_min,
		y_max          = vlf_vars.mg_overworld_max,
		noise_params = {
			offset  = 0,
			scale   = 1,
			spread  = {x=250, y=250, z=250},
			seed    = 12345,
			octaves = 3,
			persist = 0.6,
			lacunarity = 2,
			flags = "defaults",
		}
	})
end

local stonelike = {"vlf_core:stone", "vlf_core:diorite", "vlf_core:andesite", "vlf_core:granite"}

-- Dirt
minetest.register_ore({
	ore_type       = "blob",
	ore            = "vlf_core:dirt",
	wherein        = stonelike,
	clust_scarcity = 15*15*15,
	clust_num_ores = 33,
	clust_size     = 4,
	y_min          = vlf_vars.mg_overworld_min,
	y_max          = vlf_vars.mg_overworld_max,
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

-- Gravel
minetest.register_ore({
	ore_type       = "blob",
	ore            = "vlf_core:gravel",
	wherein        = stonelike,
	clust_scarcity = 14*14*14,
	clust_num_ores = 33,
	clust_size     = 5,
	y_min          = vlf_vars.mg_overworld_min,
	y_max          = vlf_worlds.layer_to_y(111),
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

minetest.register_ore({
	ore_type       = "blob",
	ore            = "vlf_deepslate:deepslate",
	wherein        = { "vlf_core:stone" },
	clust_scarcity = 200,
	clust_num_ores = 100,
	clust_size     = 10,
	y_min          = deepslate_min,
	y_max          = deepslate_max,
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = { x = 250, y = 250, z = 250 },
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

minetest.register_ore({
	ore_type       = "blob",
	ore            = "vlf_deepslate:tuff",
	wherein        = { "vlf_core:stone", "vlf_core:diorite", "vlf_core:andesite", "vlf_core:granite", "vlf_deepslate:deepslate" },
	clust_scarcity = 10*10*10,
	clust_num_ores = 58,
	clust_size     = 7,
	y_min          = deepslate_min,
	y_max          = deepslate_max,
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "vlf_deepslate:infested_deepslate",
	wherein        = "vlf_deepslate:deepslate",
	clust_scarcity = 26 * 26 * 26,
	clust_num_ores = 3,
	clust_size     = 2,
	y_min          = deepslate_min,
	y_max          = deepslate_max,
	biomes         = mountains,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "vlf_core:water_source",
	wherein        = "vlf_deepslate:deepslate",
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = vlf_worlds.layer_to_y(5),
	y_max          = deepslate_max,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "vlf_core:lava_source",
	wherein        = "vlf_deepslate:deepslate",
	clust_scarcity = 2000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = vlf_worlds.layer_to_y(1),
	y_max          = vlf_worlds.layer_to_y(10),
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "vlf_core:lava_source",
	wherein        = "vlf_deepslate:deepslate",
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = vlf_worlds.layer_to_y(11),
	y_max          = deepslate_max,
})

if minetest.settings:get_bool("vlf_generate_ores", true) then
	--
	-- Ancient debris
	--
	local ancient_debris_wherein = {"vlf_nether:netherrack","vlf_blackstone:blackstone","vlf_blackstone:basalt"}
	-- Common spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "vlf_nether:ancient_debris",
		wherein         = ancient_debris_wherein,
		clust_scarcity = 15000,
		-- in MC it's 0.004% chance (~= scarcity 25000) but reports and experiments show that ancient debris is unreasonably hard to find in survival with that value
		clust_num_ores = 3,
		clust_size     = 3,
		y_min = vlf_vars.mg_nether_min + 8,
		y_max = vlf_vars.mg_nether_min + 22,
	})

	-- Rare spawn (below)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "vlf_nether:ancient_debris",
		wherein         = ancient_debris_wherein,
		clust_scarcity = 32000,
		clust_num_ores = 2,
		clust_size     = 3,
		y_min = vlf_vars.mg_nether_min,
		y_max = vlf_vars.mg_nether_min + 8,
	})

	-- Rare spawn (above)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "vlf_nether:ancient_debris",
		wherein         = ancient_debris_wherein,
		clust_scarcity = 32000,
		clust_num_ores = 2,
		clust_size     = 3,
		y_min = vlf_vars.mg_nether_min + 22,
		y_max = vlf_vars.mg_nether_min + 119,
	})

	local stonelike = { "vlf_core:stone", "vlf_core:diorite", "vlf_core:andesite", "vlf_core:granite" }

	local function register_ore_mg(ore, wherein, defs)
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = ore,
			wherein        = wherein,
			clust_scarcity = defs[1],
			clust_num_ores = defs[2],
			clust_size     = defs[3],
			y_min          = defs[4],
			y_max          = defs[5],
			biomes		   = defs[6],
		})
	end

	local ore_mapgen = {
		["deepslate"] = {
			["coal"] = {
				{ 1575, 5, 3, deepslate_min, deepslate_max },
				{ 1530, 8, 3, deepslate_min, deepslate_max },
				{ 1500, 12, 3, deepslate_min, deepslate_max },
			},
			["iron"] = {
				{ 830, 5, 3, deepslate_min, deepslate_max },
			},
			["gold"] = {
				{ 4775, 5, 3, deepslate_min, deepslate_max },
				{ 6560, 7, 3, deepslate_min, deepslate_max },
			},
			["diamond"] = {
				{ 10000, 4, 3, deepslate_min, vlf_worlds.layer_to_y(12) },
				{ 5000, 2, 3, deepslate_min, vlf_worlds.layer_to_y(12) },
				{ 10000, 8, 3, deepslate_min, vlf_worlds.layer_to_y(12) },
				{ 20000, 1, 1, vlf_worlds.layer_to_y(13), vlf_worlds.layer_to_y(15) },
				{ 20000, 2, 2, vlf_worlds.layer_to_y(13), vlf_worlds.layer_to_y(15) },
			},
			["redstone"] = {
				{ 500, 4, 3, deepslate_min, vlf_worlds.layer_to_y(13) },
				{ 800, 7, 4, deepslate_min, vlf_worlds.layer_to_y(13) },
				{ 1000, 4, 3, vlf_worlds.layer_to_y(13), vlf_worlds.layer_to_y(15) },
				{ 1600, 7, 4, vlf_worlds.layer_to_y(13), vlf_worlds.layer_to_y(15) },
			},
			["lapis"] = {
				{ 10000, 7, 4, vlf_worlds.layer_to_y(14), deepslate_max },
				{ 12000, 6, 3, vlf_worlds.layer_to_y(10), vlf_worlds.layer_to_y(13) },
				{ 14000, 5, 3, vlf_worlds.layer_to_y(6), vlf_worlds.layer_to_y(9) },
				{ 16000, 4, 3, vlf_worlds.layer_to_y(2), vlf_worlds.layer_to_y(5) },
				{ 18000, 3, 2, vlf_worlds.layer_to_y(0), vlf_worlds.layer_to_y(2) },
			},
			["emerald"] = {
				{ 16384, 1, 1, vlf_worlds.layer_to_y(4), deepslate_max, mountains },
			},
			["copper"] = {
				{ 830, 5, 3, deepslate_min, deepslate_max },
			}
		},
		["stone"] = {
			["coal"] = {
				{ 525*3, 5, 3, vlf_vars.mg_overworld_min, vlf_worlds.layer_to_y(50) },
				{ 510*3, 8, 3, vlf_vars.mg_overworld_min, vlf_worlds.layer_to_y(50) },
				{ 500*3, 12, 3, vlf_vars.mg_overworld_min, vlf_worlds.layer_to_y(50) },
				{ 550*3, 4, 2, vlf_worlds.layer_to_y(51), vlf_worlds.layer_to_y(80) },
				{ 525*3, 6, 3, vlf_worlds.layer_to_y(51), vlf_worlds.layer_to_y(80) },
				{ 500*3, 8, 3, vlf_worlds.layer_to_y(51), vlf_worlds.layer_to_y(80) },
				{ 600*3, 3, 2, vlf_worlds.layer_to_y(81), vlf_worlds.layer_to_y(128) },
				{ 550*3, 4, 3, vlf_worlds.layer_to_y(81), vlf_worlds.layer_to_y(128) },
				{ 500*3, 5, 3, vlf_worlds.layer_to_y(81), vlf_worlds.layer_to_y(128) },
			},
			["iron"] = {
				{ 830, 5, 3, vlf_vars.mg_overworld_min, vlf_worlds.layer_to_y(39) },
				{ 1660, 4, 2, vlf_worlds.layer_to_y(40), vlf_worlds.layer_to_y(63) },
			},
			["gold"] = {
				{ 4775, 5, 3, vlf_vars.mg_overworld_min, vlf_worlds.layer_to_y(30) },
				{ 6560, 7, 3, vlf_vars.mg_overworld_min, vlf_worlds.layer_to_y(30) },
				{ 13000, 4, 2, vlf_worlds.layer_to_y(31), vlf_worlds.layer_to_y(33) },
				{ 3333, 5, 3, vlf_worlds.layer_to_y(32), vlf_worlds.layer_to_y(79), mesa }
			},
			["diamond"] = {
				{ 10000, 4, 3, vlf_vars.mg_overworld_min, vlf_worlds.layer_to_y(12) },
				{ 5000, 2, 2, vlf_vars.mg_overworld_min, vlf_worlds.layer_to_y(12) },
				{ 10000, 8, 3, vlf_vars.mg_overworld_min, vlf_worlds.layer_to_y(12) },
				{ 20000, 1, 1, vlf_worlds.layer_to_y(13), vlf_worlds.layer_to_y(15) },
				{ 20000, 2, 2, vlf_worlds.layer_to_y(13), vlf_worlds.layer_to_y(15) },
			},
			["redstone"] = {
				{ 500, 4, 3, vlf_vars.mg_overworld_min, vlf_worlds.layer_to_y(13) },
				{ 800, 7, 4, vlf_vars.mg_overworld_min, vlf_worlds.layer_to_y(13) },
				{ 1000, 4, 3, vlf_worlds.layer_to_y(13), vlf_worlds.layer_to_y(15) },
				{ 1600, 7, 4, vlf_worlds.layer_to_y(13), vlf_worlds.layer_to_y(15) },
			},
			["lapis"] = {
				{ 7000, 7, 4, vlf_worlds.layer_to_y(14), vlf_worlds.layer_to_y(16) },
				{ 10000, 6, 3, vlf_worlds.layer_to_y(10), vlf_worlds.layer_to_y(13) },
				{ 12000, 5, 3, vlf_worlds.layer_to_y(6), vlf_worlds.layer_to_y(9) },
				{ 16000, 4, 3, vlf_worlds.layer_to_y(2), vlf_worlds.layer_to_y(5) },
				{ 18000, 3, 2, vlf_worlds.layer_to_y(0), vlf_worlds.layer_to_y(2) },
				{ 10000, 6, 3, vlf_worlds.layer_to_y(17), vlf_worlds.layer_to_y(20) },
				{ 12000, 5, 3, vlf_worlds.layer_to_y(21), vlf_worlds.layer_to_y(24) },
				{ 14000, 4, 3, vlf_worlds.layer_to_y(25), vlf_worlds.layer_to_y(28) },
				{ 18000, 3, 2, vlf_worlds.layer_to_y(29), vlf_worlds.layer_to_y(32) },
				{ 28000, 1, 1, vlf_worlds.layer_to_y(31), vlf_worlds.layer_to_y(32) },
			},
			["copper"] = {
				{ 830, 5, 3, vlf_vars.mg_overworld_min, vlf_worlds.layer_to_y(39) },
				{ 1660, 4, 2, vlf_worlds.layer_to_y(40), vlf_worlds.layer_to_y(63) },
			},
			["emerald"] = {
				{ 16384, 1, 1, vlf_worlds.layer_to_y(4), vlf_worlds.layer_to_y(32), mountains }
			},
		}
	}

	for stone, ore in pairs(ore_mapgen) do
		local modname = ""
		local wherein

		for name, defs in pairs(ore) do
			if stone == "deepslate" then
				modname = "vlf_deepslate"
				wherein = { "vlf_deepslate:deepslate", "vlf_deepslate:tuff" }
			elseif stone == "stone" then
				modname = "vlf_core"
				wherein = stonelike
				if name == "copper" then
					modname = "vlf_copper"
				end
			end
			for _, def in pairs(defs) do
				register_ore_mg(modname..":"..stone.."_with_"..name, wherein, def)
			end
		end
	end
end

if not vlf_vars.superflat then
-- Water and lava springs (single blocks of lava/water source)
-- Water appears at nearly every height, but not near the bottom
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "vlf_core:water_source",
	wherein         = {"vlf_core:stone", "vlf_core:andesite", "vlf_core:diorite", "vlf_core:granite", "vlf_core:dirt"},
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = vlf_worlds.layer_to_y(5),
	y_max          = vlf_worlds.layer_to_y(128),
})

-- Lava springs are rather common at -31 and below
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "vlf_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 2000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = vlf_worlds.layer_to_y(1),
	y_max          = vlf_worlds.layer_to_y(10),
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "vlf_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = vlf_worlds.layer_to_y(11),
	y_max          = vlf_worlds.layer_to_y(31),
})

-- Lava springs will become gradually rarer with increasing height
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "vlf_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 32000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = vlf_worlds.layer_to_y(32),
	y_max          = vlf_worlds.layer_to_y(47),
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "vlf_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 72000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = vlf_worlds.layer_to_y(48),
	y_max          = vlf_worlds.layer_to_y(61),
})

-- Lava may even appear above surface, but this is very rare
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "vlf_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 96000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = vlf_worlds.layer_to_y(62),
	y_max          = vlf_worlds.layer_to_y(127),
})
end
