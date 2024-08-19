--vlf_amethyst = {}

-- Register Crafts
minetest.register_craft({
	output = "voxelforge:amethyst_block",
	recipe = {
		{"voxelforge:amethyst_shard", "voxelforge:amethyst_shard"},
		{"voxelforge:amethyst_shard", "voxelforge:amethyst_shard"},
	},
})

minetest.register_craft({
	output = "voxelforge:tinted_glass 2",
	recipe = {
		{"",                            "voxelforge:amethyst_shard", ""},
		{"voxelforge:amethyst_shard", "voxelforge:glass",              "voxelforge:amethyst_shard",},
		{"",                            "voxelforge:amethyst_shard", ""},
	},
})

if minetest.get_modpath("vlf_spyglass") then
	minetest.clear_craft({output = "voxelforge:spyglass",})
	local function craft_spyglass(ingot)
		minetest.register_craft({
			output = "voxelforge:spyglass",
			recipe = {
				{"voxelforge:amethyst_shard"},
				{ingot},
				{ingot},
			}
		})
	end
	if minetest.get_modpath("vlf_copper") then
		craft_spyglass("voxelforge:copper_ingot")
	else
		craft_spyglass("voxelforge:iron_ingot")
	end
end

-- Amethyst Growing
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/grow.lua")

vlf_wip.register_wip_item("voxelforge:budding_amethyst")

