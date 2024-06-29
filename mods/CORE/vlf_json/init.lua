local json = dofile(minetest.get_modpath("vlf_json") .. "/json.lua")

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
		description = description .. core.colorize("#5454fc","\nBuilding Blocks")
	end
	if groups["natural_block"] then
		description = description .. core.colorize("#5454fc","\nNatural Blocks")
	end
	if groups["color_block"] then
		description = description .. core.colorize("#5454fc","\nColor Blocks")
	end
	if groups["redstone_block"] then
		description = description .. core.colorize("#5454fc","\nRedstone Blocks")
	end
	if groups["functional_block"] then
		description = description .. core.colorize("#5454fc","\nFunctional Blocks")
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

local function generate_texture_waxed_copper(node_name)
    return node_name:lower():gsub(":waxed_", "_") .. ".png"
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
    local path = minetest.get_modpath("vlf_json") .. "/" .. filename
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
	if not node_def.tiles then
		if not node_def.groups["waxed"] then
			node_def.tiles = {generate_texture(node_def.name)}
		elseif node_def.groups["waxed"] then
			node_def.tiles = {generate_texture_waxed_copper(node_def.name)}
		end
	end
	if node_def.sounds then
		node_def.sounds = get_sound_function(node_def.sounds)
	end
	if node_def.selection_box then
		node_def.selection_box = process_box(node_def.selection_box)
	end
	if node_def.name == "vlf_amethyst:amethyst_cluster" then
	node_def.drop = {
		max_items = 1,
		items = {
			{
				tools = {"~vlf_tools:pick_"},
				items = {"vlf_amethyst:amethyst_shard 4"},
			},
			{
				items = {"vlf_amethyst:amethyst_shard 2"},
			},
		}
	}
	end
	-- Copper Bulb Powering Functions
	if node_def.name == "vlf_copper:copper_bulb" then
            node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:copper_bulb_lit_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:copper_bulb_lit" then
		node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:copper_bulb_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:copper_bulb_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:copper_bulb"})
			end
		}
	}
	elseif node_def.name == "vlf_copper:copper_bulb_lit_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:copper_bulb_lit"})
			end
		}
	}
	elseif node_def.name == "vlf_copper:waxed_copper_bulb" then
            node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_copper_bulb_lit_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:waxed_copper_bulb_lit" then
		node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_copper_bulb_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:waxed_copper_bulb_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_copper_bulb"})
			end
		}
	}
	elseif node_def.name == "vlf_copper:waxed_copper_bulb_lit_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_copper_bulb_lit"})
			end
		}
	}
	elseif node_def.name == "vlf_copper:exposed_copper_bulb" then
            node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:exposed_copper_bulb_lit_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:exposed_copper_bulb_lit" then
		node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:exposed_copper_bulb_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:exposed_copper_bulb_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:exposed_copper_bulb"})
			end
		}
	}
	elseif node_def.name == "vlf_copper:exposed_copper_bulb_lit_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:exposed_copper_bulb_lit"})
			end
		}
	}
	elseif node_def.name == "vlf_copper:waxed_exposed_copper_bulb" then
            node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_exposed_copper_bulb_lit_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:waxed_exposed_copper_bulb_lit" then
		node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_exposed_copper_bulb_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:waxed_exposed_copper_bulb_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_exposed_copper_bulb"})
			end
		}
	}
	elseif node_def.name == "vlf_copper:waxed_exposed_copper_bulb_lit_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_exposed_copper_bulb_lit"})
			end
		}
	}
	elseif node_def.name == "vlf_copper:weathered_copper_bulb" then
            node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:weathered_copper_bulb_lit_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:weathered_copper_bulb_lit" then
		node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:weathered_copper_bulb_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:weathered_copper_bulb_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:weathered_copper_bulb"})
			end
		}
	}
	elseif node_def.name == "vlf_copper:weathered_copper_bulb_lit_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:weathered_copper_bulb_lit"})
			end
		}
	}
	elseif node_def.name == "vlf_copper:waxed_weathered_copper_bulb" then
            node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_weathered_copper_bulb_lit_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:waxed_weathered_copper_bulb_lit" then
		node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_weathered_copper_bulb_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:waxed_weathered_copper_bulb_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_weathered_copper_bulb"})
			end
		}
	}
	elseif node_def.name == "vlf_copper:waxed_weathered_copper_bulb_lit_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_weathered_copper_bulb_lit"})
			end
		}
	}
	elseif node_def.name == "vlf_copper:oxidized_copper_bulb" then
            node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:oxidized_copper_bulb_lit_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:oxidized_copper_bulb_lit" then
		node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:oxidized_copper_bulb_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:oxidized_copper_bulb_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:oxidized_copper_bulb"})
			end
		}
	}
	elseif node_def.name == "vlf_copper:oxidized_copper_bulb_lit_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:oxidized_copper_bulb_lit"})
			end
		}
	}
	elseif node_def.name == "vlf_copper:waxed_oxidized_copper_bulb" then
            node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_oxidized_copper_bulb_lit_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:waxed_oxidized_copper_bulb_lit" then
		node_def.mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_oxidized_copper_bulb_powered"})
			end
		},
	}
	elseif node_def.name == "vlf_copper:waxed_oxidized_copper_bulb_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_oxidized_copper_bulb"})
			end
		}
	}
	elseif node_def.name == "vlf_copper:waxed_oxidized_copper_bulb_lit_powered" then
		node_def.mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = "vlf_copper:waxed_oxidized_copper_bulb_lit"})
			end
		}
	}
        end
        minetest.register_node(":" .. node_def.name, node_def)
    end
end

register_nodes_from_json("nodes.json")
dofile(minetest.get_modpath("vlf_json") .. "/items.lua")


--[[ Required
local minetest = minetest or {}

-- Function to read a file and return its contents as a string
local function read_file(file_path)
    local file = io.open(file_path, "r")
    if not file then
        return nil, "Could not open file: " .. file_path
    end
    local content = file:read("*all")
    file:close()
    return content
end

-- Function to parse C++ file and extract functions
local function parse_cpp_file(content)
    local functions = {}
    for return_type, func_name, params in content:gmatch("([%w_][%w%s_%*&:]*)%s+([%w_][%w_]*)%s*%(([^)]*)%)") do
        local func = {
            return_type = return_type,
            name = func_name,
            parameters = params
        }
        table.insert(functions, func)
    end
    return functions
end

-- Function to convert the extracted functions into a Lua table
local function cpp_to_lua(file_path)
    local content, err = read_file(file_path)
    if not content then
        return nil, err
    end
    local functions = parse_cpp_file(content)
    return functions
end

-- Function to get all enabled mods
local function get_enabled_mods()
    return minetest.get_modnames()
end

-- Function to get the path of a mod
local function get_mod_path(modname)
    return minetest.get_modpath(modname)
end

-- Main function to parse .cpp files from all enabled mods
local function parse_cpp_from_enabled_mods()
    local enabled_mods = get_enabled_mods()
    local all_functions = {}

    for _, modname in ipairs(enabled_mods) do
        local modpath = get_mod_path(modname)
        if modpath then
            for file in io.popen('find "' .. modpath .. '" -name "*.cpp"'):lines() do
                local functions, err = cpp_to_lua(file)
                if functions then
                    all_functions[modname] = all_functions[modname] or {}
                    for _, func in ipairs(functions) do
                        table.insert(all_functions[modname], func)
                    end
                else
                    print("Error parsing file " .. file .. ": " .. err)
                end
            end
        else
            print("Could not get path for mod: " .. modname)
        end
    end

    return all_functions
end

-- Example usage
local all_functions = parse_cpp_from_enabled_mods()
for modname, functions in pairs(all_functions) do
    print("Mod: " .. modname)
    for _, func in ipairs(functions) do
        print("  Function Name: " .. func.name)
        print("  Return Type: " .. func.return_type)
        print("  Parameters: " .. func.parameters)
    end
end
]]
