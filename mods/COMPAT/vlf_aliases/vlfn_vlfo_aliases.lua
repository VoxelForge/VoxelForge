-- vlf_core
minetest.register_alias("vlf_core:coal_ore", "vlf_core:stone_with_coal")
minetest.register_alias("vlf_core:redstone_ore", "vlf_core:stone_with_redstone")
minetest.register_alias("vlf_core:iron_ore", "vlf_core:stone_with_iron")
minetest.register_alias("vlf_core:diamond_ore", "vlf_core:stone_with_diamond")
minetest.register_alias("vlf_core:gold_ore", "vlf_core:stone_with_gold")
minetest.register_alias("vlf_core:emerald_ore", "vlf_core:stone_with_emerald")
minetest.register_alias("vlf_core:lapis_ore", "vlf_core:stone_with_lapis")
-- vlf_deepslate
minetest.register_alias("vlf_deepslate:deepslate_coal_ore", "vlf_deepslate:deepslate_with_coal")
minetest.register_alias("vlf_deepslate:deepslate_gold_ore", "vlf_deepslate:deepslate_with_gold")
minetest.register_alias("vlf_deepslate:deepslate_redstone_ore", "vlf_deepslate:deepslate_with_redstone")
minetest.register_alias("vlf_deepslate:deepslate_iron_ore", "vlf_deepslate:deepslate_with_iron")
minetest.register_alias("vlf_deepslate:deepslate_copper_ore", "vlf_deepslate:deepslate_with_copper")
minetest.register_alias("vlf_deepslate:deepslate_emerald_ore", "vlf_deepslate:deepslate_with_emerald")
minetest.register_alias("vlf_deepslate:deepslate_lapis_ore", "vlf_deepslate:deepslate_with_lapis")

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

