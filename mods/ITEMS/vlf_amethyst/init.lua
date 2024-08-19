--vlf_amethyst = {}

-- Register Crafts
minetest.register_craft({
	output = "vlf_amethyst:amethyst_block",
	recipe = {
		{"vlf_amethyst:amethyst_shard", "vlf_amethyst:amethyst_shard"},
		{"vlf_amethyst:amethyst_shard", "vlf_amethyst:amethyst_shard"},
	},
})

minetest.register_craft({
	output = "vlf_amethyst:tinted_glass 2",
	recipe = {
		{"",                            "vlf_amethyst:amethyst_shard", ""},
		{"vlf_amethyst:amethyst_shard", "vlf_amethyst:glass",              "vlf_amethyst:amethyst_shard",},
		{"",                            "vlf_amethyst:amethyst_shard", ""},
	},
})

if minetest.get_modpath("vlf_spyglass") then
	minetest.clear_craft({output = "vlf_spyglass:spyglass",})
	local function craft_spyglass(ingot)
		minetest.register_craft({
			output = "vlf_spyglass:spyglass",
			recipe = {
				{"vlf_amethyst:amethyst_shard"},
				{ingot},
				{ingot},
			}
		})
	end
	if minetest.get_modpath("vlf_copper") then
		craft_spyglass("vlf_copper:copper_ingot")
	else
		craft_spyglass("vlf_core:iron_ingot")
	end
end

-- Amethyst Growing
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/grow.lua")

vlf_wip.register_wip_item("vlf_amethyst:budding_amethyst")

