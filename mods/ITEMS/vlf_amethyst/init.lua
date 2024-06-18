vlf_amethyst = {}

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
		{"vlf_amethyst:amethyst_shard", "vlf_core:glass",              "vlf_amethyst:amethyst_shard",},
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

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local pos = player:get_pos()
        local node = minetest.get_node(pos)
        
        if node.name == "vlf_core:water_source" then
            -- If the player is in water, reduce the gravity to make them fall slowly
            player:set_physics_override({gravity = 0.1})
        elseif node.name == "vlf_core:water_flowing" then
            player:set_physics_override({gravity = 0.1})
        else
            -- Reset gravity to normal when the player is not in water
            player:set_physics_override({gravity = 1.0})
        end
    end
end)

vlf_wip.register_wip_item("vlf_amethyst:budding_amethyst")

