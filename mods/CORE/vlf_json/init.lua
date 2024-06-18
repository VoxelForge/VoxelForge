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

