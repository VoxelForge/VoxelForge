- liquids.lua
local liquid_renderer = {}

-- Define textures and node names
local water_node = "vlf_core:water_source"
local lava_node = "vlf_core:lava_source"
local water_flowing_texture = "default_water_flowing.png"
local lava_flowing_texture = "default_lava_flowing.png"

-- Setup textures for rendering
function liquid_renderer.setup_textures()
    -- Register custom textures or use existing ones
    minetest.register_node(":custom:water", {
        description = "Custom Water",
        tiles = {"default_water.png"},
        drawtype = "liquid",
        paramtype = "light",
        light_source = 7,
        liquid_viscosity = 1,
        liquid_renewable = true,
        groups = {water = 1, liquid = 3}
    })

    minetest.register_node(":custom:lava", {
        description = "Custom Lava",
        tiles = {"default_lava.png"},
        drawtype = "liquid",
        paramtype = "light",
        light_source = 14,
        liquid_viscosity = 1,
        liquid_renewable = true,
        groups = {lava = 1, liquid = 3}
    })
end

-- Check if the neighbor should be rendered
local function should_render_face(pos, fluid)
    -- Check the block in the neighboring positions
    local directions = {
        {x = 1, y = 0, z = 0}, -- East
        {x = -1, y = 0, z = 0}, -- West
        {x = 0, y = 1, z = 0}, -- Up
        {x = 0, y = -1, z = 0}, -- Down
        {x = 0, y = 0, z = 1}, -- South
        {x = 0, y = 0, z = -1} -- North
    }

    for _, dir in ipairs(directions) do
        local neighbor_pos = vector.add(pos, dir)
        local neighbor_node = minetest.get_node(neighbor_pos)
        if neighbor_node.name ~= fluid then
            return true
        end
    end

    return false
end

-- Render liquid nodes
function liquid_renderer.render_liquids(pos, node)
    local fluid = node.name
    local texture = fluid == water_node and water_flowing_texture or lava_flowing_texture
    
    -- Render logic (simplified)
    local height = 1.0 -- Assume full height for simplicity

    -- Render the block
    if should_render_face(pos, fluid) then
        -- Example of how you might set textures
        minetest.set_node(pos, {name = fluid, param2 = 0})
        minetest.override_item(fluid, {tiles = {texture}})
    end
end

return liquid_renderer
