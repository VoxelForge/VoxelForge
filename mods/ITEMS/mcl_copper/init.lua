mcl_copper = {}
local path = minetest.get_modpath("mcl_copper")

dofile(path .. "/decaychains.lua")
dofile(path .. "/nodes.lua")
dofile(path .. "/items.lua")
dofile(path .. "/crafting.lua")

mcl_copper.register_decaychain("copper",{
	preserve_group = "preserves_copper",
	unpreserve_callback = "_on_axe_place",
	undecay_callback = "_on_axe_place",
	nodes = { --order is significant
		"mcl_copper:block",
		"mcl_copper:exposed_block",
		"mcl_copper:weathered_block",
		"mcl_copper:oxidized_block",
	},
})

for _, v in pairs({ "chiseled", "grate", "cut" }) do
	mcl_copper.register_decaychain(v.."_copper",{
		preserve_group = "preserves_copper",
		unpreserve_callback = "_on_axe_place",
		undecay_callback = "_on_axe_place",
		nodes = { --order is significant
			"mcl_copper:block_"..v,
			"mcl_copper:exposed_block_"..v,
			"mcl_copper:weathered_block_"..v,
			"mcl_copper:oxidized_block_"..v,
		},
	})
end

for _, v in pairs({ "_lit", "_lit_powered", "_powered", ""}) do
	mcl_copper.register_decaychain("copper_bulb"..v,{
		preserve_group = "preserves_copper",
		unpreserve_callback = "_on_axe_place",
		undecay_callback = "_on_axe_place",
		nodes = { --order is significant
			"mcl_copper:copper_bulb"..v,
			"mcl_copper:exposed_copper_bulb"..v,
			"mcl_copper:weathered_copper_bulb"..v,
			"mcl_copper:oxidized_copper_bulb"..v,
		},
	})
end

for _, v in pairs({"", "_open"}) do
	mcl_copper.register_decaychain("copper_trapdoor"..v,{
		preserve_group = "preserves_copper",
		unpreserve_callback = "_on_axe_place",
		undecay_callback = "_on_axe_place",
		nodes = { --order is significant
			"mcl_copper:copper_trapdoor"..v,
			"mcl_copper:exposed_copper_trapdoor"..v,
			"mcl_copper:weathered_copper_trapdoor"..v,
			"mcl_copper:oxidized_copper_trapdoor"..v,
		},
	})
end

-- "mcl_copper:block_exposed_cut"

for _,v in pairs({"stair","slab"}) do
	mcl_copper.register_decaychain("cut_copper_"..v,{
		preserve_group = "preserves_copper",
		unpreserve_callback = "_on_axe_place",
		undecay_callback = "_on_axe_place",
		nodes = { --order is significant
			"mcl_stairs:"..v.."_copper_cut",
			"mcl_stairs:"..v.."_exposed_copper_cut",
			"mcl_stairs:"..v.."_weathered_copper_cut",
			"mcl_stairs:"..v.."_oxidized_copper_cut",
		},
	})
end

for _,v in pairs({"inner","outer"}) do
	mcl_copper.register_decaychain("cut_copper_stair_"..v,{
		preserve_group = "preserves_copper",
		unpreserve_callback = "_on_axe_place",
		undecay_callback = "_on_axe_place",
		nodes = { --order is significant
			"mcl_stairs:stair_copper_cut_"..v,
			"mcl_stairs:stair_exposed_copper_cut_"..v,
			"mcl_stairs:stair_weathered_copper_cut_"..v,
			"mcl_stairs:stair_oxidized_copper_cut_"..v,
		},
	})
end
for _,v in pairs({"top","double"}) do
	mcl_copper.register_decaychain("cut_copper_slab_"..v,{
		preserve_group = "preserves_copper",
		unpreserve_callback = "_on_axe_place",
		undecay_callback = "_on_axe_place",
		nodes = { --order is significant
			"mcl_stairs:slab_copper_cut_"..v,
			"mcl_stairs:slab_exposed_copper_cut_"..v,
			"mcl_stairs:slab_weathered_copper_cut_"..v,
			"mcl_stairs:slab_oxidized_copper_cut_"..v,
		},
	})
end
