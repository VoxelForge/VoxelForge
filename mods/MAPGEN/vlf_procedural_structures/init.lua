--[[local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

vlf_procedural_structures = {
	structures = {}
}

dofile(modpath.."/api.lua")
dofile(modpath.."/nether_fortress.lua")

minetest.register_chatcommand("genstruct",{
	params = "dungeon",
	description = S("Generate a procedural structure near your position"),
	privs = {debug = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then return end

		local pos = player:get_pos()
		if not pos then return end
		pos = vector.round(pos)

		vlf_procedural_structures:place( "nether_fortress", vector.offset(pos,14,0,14), 1)
	end
})]]

--[[local vlf_procedural_structures = {}

vlf_procedural_structures.registered_structures = {}

function vlf_procedural_structures.register_structure(name, definition)
    vlf_procedural_structures.registered_structures[name] = definition
end

function vlf_procedural_structures.load_structure(name)
    return vlf_procedural_structures.registered_structures[name]
end

function vlf_procedural_structures.get_heightmap(minp, maxp)
    local heightmap = {}
    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            heightmap[{x, z}] = minetest.get_height({x = x, y = minp.y, z = z})
        end
    end
    return heightmap
end

function vlf_procedural_structures.analyze_biomes(minp, maxp)
    local biomes = {}
    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            local biome = minetest.get_biome({x = x, y = minp.y, z = z})
            biomes[{x, z}] = biome
        end
    end
    return biomes
end

function vlf_procedural_structures.place_structure(name, pos)
    local structure = vlf_procedural_structures.load_structure(name)
    if structure then
        for _, node in ipairs(structure.nodes) do
            local node_pos = vector.add(pos, node.pos)
            minetest.set_node(node_pos, node.node)
        end
    end
end

function vlf_procedural_structures.check_placement_validity(name, pos)
    local structure = vlf_procedural_structures.load_structure(name)
    if structure then
        for _, node in ipairs(structure.nodes) do
            local node_pos = vector.add(pos, node.pos)
            if not minetest.get_node_or_nil(node_pos) then
                return false
            end
        end
        return true
    end
    return false
end

function vlf_procedural_structures.random_structure(name)
    local variants = vlf_procedural_structures.load_structure(name).variants
    return variants[math.random(#variants)]
end

function vlf_procedural_structures.seeded_random(seed)
    math.randomseed(seed)
    return math.random
end

vlf_procedural_structures.vector = {}

function vlf_procedural_structures.vector.add(v1, v2)
    return {x = v1.x + v2.x, y = v1.y + v2.y, z = v1.z + v2.z}
end

function vlf_procedural_structures.iterate_region(minp, maxp, callback)
    for x = minp.x, maxp.x do
        for y = minp.y, maxp.y do
            for z = minp.z, maxp.z do
                callback({x = x, y = y, z = z})
            end
        end
    end
end

local simple_house = {
    nodes = {
        {pos = {x = 0, y = 0, z = 0}, node = {name = "vlf_trees:wood_oak"}},
        {pos = {x = 1, y = 0, z = 0}, node = {name = "vlf_trees:wood_oak"}},
        -- More nodes...
    },
    variants = {
        { -- Variant 1
            nodes = {
                {pos = {x = 0, y = 0, z = 0}, node = {name = "vlf_trees:wood_jungle"}},
                {pos = {x = 10, y = 0, z = 0}, node = {name = "vlf_trees:wood_oak"}},
                -- More nodes...
            }
        },
        { -- Variant 2
            nodes = {
                {pos = {x = 0, y = 0, z = 0}, node = {name = "vlf_core:brick_block"}},
                {pos = {x = 1, y = 0, z = 0}, node = {name = "vlf_core:brick_block"}},
                {pos = {x = 2, y = 1, z = 0}, node = {name = "vlf_core:brick_block"}},
                {pos = {x = 3, y = 2, z = 0}, node = {name = "vlf_core:brick_block"}},
                -- More nodes...
            }
        }
    }
}

vlf_procedural_structures.register_structure("simple_house", simple_house)


minetest.register_chatcommand("generate_structure", {
    params = "<structure_name>",
    description = "Generates a variation of the specified structure at your current position",
    func = function(player_name, param)
        local player = minetest.get_player_by_name(player_name)
        if not player then
            return false, "Player not found"
        end
        
        local structure_name = param:trim()
        if structure_name == "" then
            return false, "You must specify a structure name"
        end
        
        local pos = player:get_pos()
        pos = vector.round(pos)
        
        local structure = vlf_procedural_structures.load_structure(structure_name)
        if not structure then
            return false, "Structure not found"
        end
        
        local variant = vlf_procedural_structures.random_structure(structure_name)
        if variant then
            for _, node in ipairs(variant.nodes) do
                local node_pos = vector.add(pos, node.pos)
                minetest.set_node(node_pos, node.node)
            end
            return true, "Structure generated"
        else
            return false, "No variants found for this structure"
        end
    end
})
]]

--[[local vlf_procedural_structures = {}

vlf_procedural_structures.registered_schematics = {}
vlf_procedural_structures.schematic_directory = minetest.get_modpath("vlf_procedural_structures") .. "/schems/nether_fortress/"
vlf_procedural_structures.placed_schematics = {}

function vlf_procedural_structures.load_schematics(directory)
    local files = minetest.get_dir_list(directory, false)
    for _, file in ipairs(files) do
        if file:match("%.mts$") then
            local name = file:gsub("%.mts$", "")
            vlf_procedural_structures.registered_schematics[name] = minetest.get_modpath("vlf_procedural_structures") .. "/schems/nether_fortress/" .. file
        end
    end
end

function vlf_procedural_structures.get_random_schematic()
    local keys = {}
    for k in pairs(vlf_procedural_structures.registered_schematics) do
        table.insert(keys, k)
    end
    return vlf_procedural_structures.registered_schematics[keys[math.random(#keys)
end

function vlf_procedural_structures.distance(pos1, pos2)
    return math.sqrt((pos1.x - pos2.x)^2 + (pos1.y - pos2.y)^2 + (pos1.z - pos2.z)^2)
end

function vlf_procedural_structures.place_schematic(schematic_path, pos, min_distance)
    for _, placed_pos in ipairs(vlf_procedural_structures.placed_schematics) do
        if vlf_procedural_structures.distance(placed_pos, pos) < min_distance then
            return false
        end
    end

    minetest.place_schematic(pos, schematic_path, "random", nil, true)
    table.insert(vlf_procedural_structures.placed_schematics, pos)
    return true
end

function vlf_procedural_structures.spawn_in_biome(schematic, biome, minp, maxp, min_distance)
    local positions = {}
    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            local y = minetest.get_surface_height({x = x, y = minp.y, z = z})
            local pos = {x = x, y = y, z = z}
            local node_biome = minetest.get_biome_data(pos).biome
            if node_biome == biome then
                table.insert(positions, pos)
            end
        end
    end
    if #positions > 0 then
        local spawn_pos = positions[math.random(#positions)]
        vlf_procedural_structures.place_schematic(schematic, spawn_pos, min_distance)
    end
end

function vlf_procedural_structures.spawn_on_node(schematic, node_name, minp, maxp, min_distance)
    local positions = {}
    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            for y = minp.y, maxp.y do
                local pos = {x = x, y = y, z = z}
                local node = minetest.get_node(pos)
                if node.name == node_name then
                    table.insert(positions, pos)
                end
            end
        end
    end
    if #positions > 0 then
        local spawn_pos = positions[math.random(#positions)]
        vlf_procedural_structures.place_schematic(schematic, spawn_pos, min_distance)
    end
end

vlf_procedural_structures.load_schematics(vlf_procedural_structures.schematic_directory)

minetest.register_chatcommand("generate_schematic", {
    params = "",
    description = "Generates a random schematic at your current position",
    func = function(player_name, _)
        local player = minetest.get_player_by_name(player_name)
        if not player then
            return false, "Player not found"
        end
        
        local pos = player:get_pos()
        pos = vector.round(pos)
        
        local schematic = vlf_procedural_structures.get_random_schematic()
        if schematic then
            if vlf_procedural_structures.place_schematic(schematic, pos, 10) then  -- Example minimum distance of 10
                return true, "Schematic generated"
            else
                return false, "Could not place schematic (too close to another structure)"
            end
        else
            return false, "No schematics found"
        end
    end
})
]]

