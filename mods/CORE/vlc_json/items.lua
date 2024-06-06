-- Load the JSON library
local json = dofile(minetest.get_modpath("vlc_json") .. "/json.lua")

-- Function to convert item name to user-friendly description
local function generate_description(item_name)
    local description = item_name:match(":(.+)$")  -- Extracts the part after the colon
    description = description:gsub("_", " ")      -- Replace underscores with spaces
    description = description:gsub("(%l)(%w*)", function(a, b) return string.upper(a) .. b end) -- Capitalize the first letter of each word
    return description
end

-- Function to register craftitems from JSON data
local function register_craftitems_from_json(filename)
    -- Load JSON data from file
    local file_path = minetest.get_modpath("vlc_json").."/"..filename
    local file = io.open(file_path, "r")
    if not file then
        minetest.log("error", "Failed to open file: " .. filename)
        return
    end

    local data = file:read("*all")
    file:close()

    -- Parse JSON data
    local craftitems = json.decode(data)

    -- Register craftitems
    for _, item in ipairs(craftitems) do
        local item_name = item.name
        local item_groups = item.groups or {}
        local item_description = generate_description(item_name)
        local item_texture = item_name:gsub(":", "_") .. ".png"

        minetest.register_craftitem(":" .. item_name, {
            description = item_description,
            inventory_image = item_texture,
            groups = item_groups
        })
    end
end

-- Example usage:
register_craftitems_from_json("items.json")

