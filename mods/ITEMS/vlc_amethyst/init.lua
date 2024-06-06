vlc_amethyst = {}

-- Register Crafts
minetest.register_craft({
	output = "vlc_amethyst:amethyst_block",
	recipe = {
		{"vlc_amethyst:amethyst_shard", "vlc_amethyst:amethyst_shard"},
		{"vlc_amethyst:amethyst_shard", "vlc_amethyst:amethyst_shard"},
	},
})

minetest.register_craft({
	output = "vlc_amethyst:tinted_glass 2",
	recipe = {
		{"",                            "vlc_amethyst:amethyst_shard", ""},
		{"vlc_amethyst:amethyst_shard", "mcl_core:glass",              "vlc_amethyst:amethyst_shard",},
		{"",                            "vlc_amethyst:amethyst_shard", ""},
	},
})

if minetest.get_modpath("mcl_spyglass") then
	minetest.clear_craft({output = "mcl_spyglass:spyglass",})
	local function craft_spyglass(ingot)
		minetest.register_craft({
			output = "mcl_spyglass:spyglass",
			recipe = {
				{"vlc_amethyst:amethyst_shard"},
				{ingot},
				{ingot},
			}
		})
	end
	if minetest.get_modpath("mcl_copper") then
		craft_spyglass("mcl_copper:copper_ingot")
	else
		craft_spyglass("mcl_core:iron_ingot")
	end
end

-- Amethyst Growing
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/grow.lua")

mcl_wip.register_wip_item("vlc_amethyst:budding_amethyst")
