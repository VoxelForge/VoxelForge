local json = dofile(minetest.get_modpath("vlc_json") .. "/json.lua")

local function generate_description(node_name, groups)
    local parts = node_name:split(":")
    local description
    if #parts == 2 then
        local raw_name = parts[2]
        description = raw_name:gsub("_", " "):gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)
    else
        description = node_name
    end

    if groups["building_block"] then
        description = description .. core.colorize("#3056ce","\nBuilding Blocks")
    end
    if groups["natural_block"] then
        description = description .. core.colorize("#3056ce","\nNatural Blocks")
    end
    if groups["color_block"] then
        description = description .. core.colorize("#3056ce","\nColor Blocks")
    end

    return description
end

local function get_sound_function(sound_str)
    local sound_func = loadstring("return " .. sound_str .. "()")
    if sound_func then
        return sound_func()
    else
        return nil
    end
end

local function get_drop_function(drop_str)
    local drop_func = loadstring("return " .. drop_str .. "()")
    if drop_func then
        return drop_func()
    else
        return nil
    end
end

local function generate_texture(node_name)
    return node_name:lower():gsub(":", "_") .. ".png"
end

local function process_box(box_def)
    if box_def then
        local box = {type = box_def.type, fixed = {}}
        for _, coords in ipairs(box_def.fixed) do
            table.insert(box.fixed, coords)
        end
        return box
    end
    return nil
end

local function register_nodes_from_json(filename)
    local path = minetest.get_modpath("vlc_json") .. "/" .. filename
    local file = io.open(path, "r")
    if not file then
        error("Could not open file: " .. filename)
    end

    local content = file:read("*all")
    file:close()

    local nodes_data = json.decode(content)
    if not nodes_data then
        error("Invalid JSON data in file: " .. filename)
    end

    for _, node_def in ipairs(nodes_data) do
        node_def.description = generate_description(node_def.name, node_def.groups)
        node_def.tiles = {generate_texture(node_def.name)}
	if node_def.sounds then
		node_def.sounds = get_sound_function(node_def.sounds)
	end
	if node_def.selection_box then
		node_def.selection_box = process_box(node_def.selection_box)
	end
	if node_def.name == "vlc_amethyst:amethyst_cluster" then
	node_def.drop = {
		max_items = 1,
		items = {
			{
				tools = {"~mcl_tools:pick_"},
				items = {"vlc_amethyst:amethyst_shard 4"},
			},
			{
				items = {"vlc_amethyst:amethyst_shard 2"},
			},
		}
	}
	end
        minetest.register_node(":" .. node_def.name, node_def)
    end
end

register_nodes_from_json("nodes.json")
local json = dofile(minetest.get_modpath("vlc_json") .. "/items.lua")
