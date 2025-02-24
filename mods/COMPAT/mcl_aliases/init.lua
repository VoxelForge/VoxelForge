local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/mcl_trees.lua")
dofile(modpath.."/mcl_doors.lua")
dofile(modpath.."/mcl_tools.lua")
dofile(modpath.."/mcl_dyes.lua")
dofile(modpath.."/mcl_copper.lua")
dofile(modpath.."/mcl_stairs.lua")
dofile(modpath.."/mcl_crimson.lua")
dofile(modpath.."/mcl_armor.lua")
dofile(modpath.."/mcl_panes.lua")
dofile(modpath.."/mcl_bamboo.lua")
dofile(modpath.."/mesecons.lua")


minetest.register_chatcommand("place_all_blocks", {
    description = "Places all registered blocks in a square around you",
    privs = {server = true}, -- Adjust privileges as needed
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found!"
        end

        local pos = vector.round(player:get_pos())
        local nodes = {}
        for nodename in pairs(minetest.registered_nodes) do
            table.insert(nodes, nodename)
        end

        -- Square placement logic
        local side_length = math.ceil(math.sqrt(#nodes))
        local index = 1
        for x = 0, side_length - 1 do
            for z = 0, side_length - 1 do
                if index > #nodes then break end
                local block_pos = {x = pos.x + x, y = pos.y, z = pos.z + z}
                minetest.set_node(block_pos, {name = nodes[index]})
                index = index + 1
            end
        end

        return true, "Placed " .. #nodes .. " blocks in a square around your position."
    end,
})


local pos1, pos2 = nil, nil

minetest.register_chatcommand("set_pos1", {
    description = "Set the first position for the area check",
    privs = {server = true}, -- Adjust privileges if needed
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found!"
        end

        pos1 = vector.round(player:get_pos())
        return true, "Position 1 set to " .. minetest.pos_to_string(pos1)
    end,
})

minetest.register_chatcommand("set_pos2", {
    description = "Set the second position for the area check",
    privs = {server = true}, -- Adjust privileges if needed
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found!"
        end

        pos2 = vector.round(player:get_pos())
        return true, "Position 2 set to " .. minetest.pos_to_string(pos2)
    end,
})

minetest.register_chatcommand("find_unregistered_blocks", {
    description = "Find all unregistered blocks in the selected area and save to file",
    privs = {server = true}, -- Adjust privileges if needed
    func = function(name)
        if not pos1 or not pos2 then
            return false, "Please set both positions with /set_pos1 and /set_pos2 first."
        end

        local minp = vector.new(
            math.min(pos1.x, pos2.x),
            math.min(pos1.y, pos2.y),
            math.min(pos1.z, pos2.z)
        )
        local maxp = vector.new(
            math.max(pos1.x, pos2.x),
            math.max(pos1.y, pos2.y),
            math.max(pos1.z, pos2.z)
        )

        local unregistered_nodes = {}
        for x = minp.x, maxp.x do
            for y = minp.y, maxp.y do
                for z = minp.z, maxp.z do
                    local pos = {x = x, y = y, z = z}
                    local node = minetest.get_node_or_nil(pos)
                    if node and not minetest.registered_nodes[node.name] then
                        unregistered_nodes[node.name] = true
                    end
                end
            end
        end

        local file_path = minetest.get_worldpath() .. "/unregistered_blocks.txt"
        local file = io.open(file_path, "w")
        if not file then
            return false, "Failed to open file for writing."
        end

        for block_name in pairs(unregistered_nodes) do
            file:write(block_name .. "\n")
        end
        file:close()

        return true, "Unregistered blocks saved to " .. file_path
    end,
})


minetest.register_on_mods_loaded(function()
    local count = 0
    for node_name, _ in pairs(minetest.registered_nodes) do
        if node_name:sub(1, 3) == "mcl" then
            local alias_name = "vlf" .. node_name:sub(4) -- Replace "vlf:" with "mcl:"
            minetest.register_alias(alias_name, node_name)
            count = count + 1
        end
    end

    -- Log success message
    --[[if count > 0 then
        minetest.log("error", "[Alias Creator] Registered " .. count .. " aliases from 'vlf:' to 'mcl:'.")
    else
        minetest.log("error", "[Alias Creator] No 'mcl:' nodes found to alias.")
    end]]
end)
minetest.register_on_mods_loaded(function()
    local count = 0
    for item_name, _ in pairs(minetest.registered_items) do
        if item_name:sub(1, 3) == "mcl" then
            local alias_name = "vlf" .. item_name:sub(4) -- Replace "vlf:" with "mcl:"
            minetest.register_alias(alias_name, item_name)
            count = count + 1
        end
    end

    -- Log success message
    --[[if count > 0 then
        minetest.log("error", "[Alias Creator] Registered " .. count .. " aliases from 'vlf:' to 'mcl:'.")
    else
        minetest.log("error", "[Alias Creator] No 'mcl:' items found to alias.")
    end]]
end)

-- vlf_core
minetest.register_alias("vlf_core:coal_ore", "mcl_core:stone_with_coal")
minetest.register_alias("vlf_core:redstone_ore", "mcl_core:stone_with_redstone")
minetest.register_alias("vlf_core:redstone_ore_lit", "mcl_core:stone_with_redstone_lit")
minetest.register_alias("vlf_core:iron_ore", "mcl_core:stone_with_iron")
minetest.register_alias("vlf_core:diamond_ore", "mcl_core:stone_with_diamond")
minetest.register_alias("vlf_core:gold_ore", "mcl_core:stone_with_gold")
minetest.register_alias("vlf_core:emerald_ore", "vlf_core:stone_with_emerald")
minetest.register_alias("vlf_core:lapis_ore", "vlf_core:stone_with_lapis")
-- vlf_deepslate
minetest.register_alias("vlf_deepslate:deepslate_coal_ore", "mcl_deepslate:deepslate_with_coal")
minetest.register_alias("vlf_deepslate:deepslate_gold_ore", "mcl_deepslate:deepslate_with_gold")
minetest.register_alias("vlf_deepslate:deepslate_redstone_ore", "mcl_deepslate:deepslate_with_redstone")
minetest.register_alias("vlf_deepslate:deepslate_redstone_lit_ore", "mcl_deepslate:deepslate_with_redstone_lit")
minetest.register_alias("vlf_deepslate:deepslate_iron_ore", "mcl_deepslate:deepslate_with_iron")
minetest.register_alias("vlf_deepslate:deepslate_copper_ore", "mcl_deepslate:deepslate_with_copper")
minetest.register_alias("vlf_deepslate:deepslate_emerald_ore", "mcl_deepslate:deepslate_with_emerald")
minetest.register_alias("vlf_deepslate:deepslate_lapis_ore", "mcl_deepslate:deepslate_with_lapis")
minetest.register_alias("vlf_deepslate:deepslate_diamond_ore", "mcl_deepslate:deepslate_with_diamond")
-- vlf_structures
minetest.register_alias("vlf_structures:structblock_water_lake", "air")
minetest.register_alias("vlf_structures:structblock_desert_temple", "air")
minetest.register_alias("vlf_structures:structblock_mineshaft", "air")
minetest.register_alias("vlf_structures:structblock_nether_outpost", "air")
minetest.register_alias("vlf_structures:structblock_shipwreck", "air")
minetest.register_alias("vlf_structures:structblock_dripstone_stalagtite", "air")
minetest.register_alias("vlf_structures:structblock_basalt_pillar", "air")
minetest.register_alias("vlf_structures:structblock_large_dripstone_column", "air")
minetest.register_alias("vlf_structures:structblock_large_dripstone_stalagtite", "air")
minetest.register_alias("vlf_structures:structblock_igloo", "air")
minetest.register_alias("vlf_structures:structblock_desert_well", "air")
minetest.register_alias("vlf_structures:structblock_end_shipwreck", "air")
minetest.register_alias("vlf_structures:structblock_cold_ocean_ruins", "air")
minetest.register_alias("vlf_structures:structblock_lavapool", "air")
minetest.register_alias("vlf_structures:structblock_fallen_tree", "air")
minetest.register_alias("vlf_structures:structblock_woodland_cabin", "air")
minetest.register_alias("vlf_structures:structblock_ocean_temple", "air")
minetest.register_alias("vlf_structures:structblock_end_boat", "air")
minetest.register_alias("vlf_structures:structblock_pale_moss", "air")
minetest.register_alias("vlf_structures:structblock_lavadelta", "air")
minetest.register_alias("vlf_structures:structblock_large_dripstone_stalagmite", "air")
minetest.register_alias("vlf_structures:structblock_nether_bridge", "air")
minetest.register_alias("vlf_structures:structblock_witch_hut", "air")
minetest.register_alias("vlf_structures:structblock_fossil", "air")
minetest.register_alias("vlf_structures:structblock_basalt_column", "air")
minetest.register_alias("vlf_structures:structblock_warm_ocean_ruins", "air")
minetest.register_alias("vlf_structures:structblock_dripstone_stalagmite", "air")
minetest.register_alias("vlf_structures:structblock_powder_snow_trap", "air")
minetest.register_alias("vlf_structures:structblock_ruined_portal_nether", "air")
minetest.register_alias("vlf_structures:structblock_ruined_portal_overworld", "air")
minetest.register_alias("vlf_structures:structblock_ancient_hermitage", "air")
minetest.register_alias("vlf_structures:structblock_water_lake_mangrove_swamp", "air")
minetest.register_alias("vlf_structures:structblock_pillager_outpost", "air")
minetest.register_alias("vlf_structures:structblock_trial_chambers", "air")
minetest.register_alias("vlf_structures:structblock_geode", "air")
minetest.register_alias("vlf_structures:structblock_jungle_temple", "air")
minetest.register_alias("vlf_structures:structblock_nether_bulwark", "air")
-- vlf_vaults
minetest.register_alias("vlf_trials:vault", "mcl_vaults:vault")
minetest.register_alias("vlf_trials:vault_on", "mcl_vaults:vault_on")
minetest.register_alias("vlf_trials:ominous_vault", "mcl_vaults:ominous_vault")
minetest.register_alias("vlf_trials:ominous_vault_on", "mcl_vaults:ominous_vault_on")
minetest.register_alias("vlf_trials:ominous_vault_ejecting", "mcl_vaults:ominous_vault_ejecting")
minetest.register_alias("vlf_trials:vault_ejecting", "mcl_vaults:vault_ejecting")
-- vlf_buttons
--[[minetest.register_alias("mesecons_button:acacia_button_off", "vlf_buttons:acacia_button_off")
minetest.register_alias("mesecons_button:birch_button_on", "vlf_buttons:birch_button_on")
minetest.register_alias("mesecons_button:crimson_button_on", "vlf_buttons:crimson_button_on")
minetest.register_alias("mesecons_button:copper_button_off", "vlf_buttons:copper_button_off")
minetest.register_alias("mesecons_button:cherry_blossom_button_off", "vlf_buttons:cherry_blossom_button_off")
minetest.register_alias("mesecons_button:oak_button_off", "vlf_buttons:oak_button_off")
minetest.register_alias("mesecons_button:mangrove_button_on", "vlf_buttons:mangrove_button_on")
minetest.register_alias("mesecons_button:warped_button_off", "vlf_buttons:warped_button_off")
minetest.register_alias("mesecons_button:jungle_button_on", "vlf_buttons:jungle_button_on")
minetest.register_alias("mesecons_button:warped_button_on", "vlf_buttons:warped_button_on")
minetest.register_alias("mesecons_button:stone_button_on", "vlf_buttons:stone_button_on")
minetest.register_alias("mesecons_button:stone_button_off", "vlf_buttons:stone_button_off")
minetest.register_alias("mesecons_button:spruce_button_on", "vlf_buttons:spruce_button_on")
minetest.register_alias("mesecons_button:pale_oak_button_on", "vlf_buttons:pale_oak_button_on")
minetest.register_alias("mesecons_button:polished_blackstone_button_on", "vlf_buttons:polished_blackstone_button_on")
minetest.register_alias("mesecons_button:polished_blackstone_button_off", "vlf_buttons:polished_blackstone_button_off")
minetest.register_alias("mesecons_button:crimson_button_off", "vlf_buttons:crimson_button_off")
minetest.register_alias("mesecons_button:bamboo_button_on", "vlf_buttons:bamboo_button_on")
minetest.register_alias("mesecons_button:dark_oak_button_on", "vlf_buttons:dark_oak_button_on")
minetest.register_alias("mesecons_button:acacia_button_on", "vlf_buttons:acacia_button_on")
minetest.register_alias("mesecons_button:bamboo_button_off", "vlf_buttons:bamboo_button_off")
minetest.register_alias("mesecons_button:dark_oak_button_off", "vlf_buttons:dark_oak_button_off")
minetest.register_alias("mesecons_button:cherry_blossom_button_on", "vlf_buttons:cherry_blossom_button_on")
minetest.register_alias("mesecons_button:stone_button_on", "vlf_buttons:stone_button_on")
minetest.register_alias("mesecons_button:oak_button_on", "vlf_buttons:oak_button_on")
minetest.register_alias("mesecons_button:acacia_button_off", "vlf_buttons:button_acacia_off")
minetest.register_alias("mesecons_button:birch_button_on", "vlf_buttons:button_birch_on")
minetest.register_alias("mesecons_button:crimson_button_on", "vlf_buttons:button_crimson_on")
minetest.register_alias("mesecons_button:copper_button_off", "vlf_buttons:button_copper_off")
minetest.register_alias("mesecons_button:cherry_blossom_button_off", "vlf_buttons:button_cherry_blossom_off")
minetest.register_alias("mesecons_button:oak_button_off", "vlf_buttons:button_oak_off")
minetest.register_alias("mesecons_button:mangrove_button_on", "vlf_buttons:button_mangrove_on")
minetest.register_alias("mesecons_button:warped_button_off", "vlf_buttons:button_warped_off")
minetest.register_alias("mesecons_button:jungle_button_on", "vlf_buttons:button_jungle_on")
minetest.register_alias("mesecons_button:jungle_button_off", "vlf_buttons:button_jungle_off")
minetest.register_alias("mesecons_button:warped_button_on", "vlf_buttons:button_warped_on")
minetest.register_alias("mesecons_button:stone_button_on", "vlf_buttons:button_stone_on")
minetest.register_alias("mesecons_button:stone_button_off", "vlf_buttons:button_stone_off")
minetest.register_alias("mesecons_button:spruce_button_on", "vlf_buttons:button_spruce_on")
minetest.register_alias("mesecons_button:pale_oak_button_on", "vlf_buttons:button_pale_oak_on")
minetest.register_alias("mesecons_button:polished_blackstone_button_on", "vlf_buttons:button_polished_blackstone_on")
minetest.register_alias("mesecons_button:polished_blackstone_button_off", "vlf_buttons:button_polished_blackstone_off")
minetest.register_alias("mesecons_button:crimson_button_off", "vlf_buttons:button_crimson_off")
minetest.register_alias("mesecons_button:bamboo_button_on", "vlf_buttons:button_bamboo_on")
minetest.register_alias("mesecons_button:dark_oak_button_on", "vlf_buttons:button_dark_oak_on")
minetest.register_alias("mesecons_button:acacia_button_on", "vlf_buttons:button_acacia_on")
minetest.register_alias("mesecons_button:bamboo_button_off", "vlf_buttons:button_bamboo_off")
minetest.register_alias("mesecons_button:dark_oak_button_off", "vlf_buttons:button_dark_oak_off")
minetest.register_alias("mesecons_button:cherry_blossom_button_on", "vlf_buttons:button_cherry_blossom_on")
minetest.register_alias("mesecons_button:stone_button_on", "vlf_buttons:button_stone_on")
minetest.register_alias("mesecons_button:oak_button_on", "vlf_buttons:button_oak_on")]]
-- vlf_chests
minetest.register_alias("vlf_chests:light_blue_shulker_box_small", "mcl_chests:lightblue_shulker_box_small")
minetest.register_alias("vlf_chests:silver_shulker_box_small", "mcl_chests:grey_shulker_box_small")
minetest.register_alias("vlf_chests:lime_shulker_box_small", "mcl_chests:green_shulker_box_small")
minetest.register_alias("vlf_chests:purple_shulker_box_small", "mcl_chests:violet_shulker_box_small")
-- vlf_amethyst
minetest.register_alias("vlf_amethyst:budding_amethyst", "mcl_amethyst:budding_amethyst_block")
-- vlf_bamboo
minetest.register_alias("vlf_trees:sapling_bamboo", "air")
