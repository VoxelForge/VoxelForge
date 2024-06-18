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
		{"vlc_amethyst:amethyst_shard", "vlc_core:glass",              "vlc_amethyst:amethyst_shard",},
		{"",                            "vlc_amethyst:amethyst_shard", ""},
	},
})

if minetest.get_modpath("vlc_spyglass") then
	minetest.clear_craft({output = "vlc_spyglass:spyglass",})
	local function craft_spyglass(ingot)
		minetest.register_craft({
			output = "vlc_spyglass:spyglass",
			recipe = {
				{"vlc_amethyst:amethyst_shard"},
				{ingot},
				{ingot},
			}
		})
	end
	if minetest.get_modpath("vlc_copper") then
		craft_spyglass("vlc_copper:copper_ingot")
	else
		craft_spyglass("vlc_core:iron_ingot")
	end
end

-- Amethyst Growing
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/grow.lua")

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local pos = player:get_pos()
        local node = minetest.get_node(pos)
        
        if node.name == "vlc_core:water_source" then
            -- If the player is in water, reduce the gravity to make them fall slowly
            player:set_physics_override({gravity = 0.1})
        elseif node.name == "vlc_core:water_flowing" then
            player:set_physics_override({gravity = 0.1})
        else
            -- Reset gravity to normal when the player is not in water
            player:set_physics_override({gravity = 1.0})
        end
    end
end)

vlc_wip.register_wip_item("vlc_amethyst:budding_amethyst")

