local modpath = minetest.get_modpath("vlf_data")
local binser = dofile(modpath .. "/binser.lua")

local function convert_vlfschem_to_binary(directory)
    local function process_directory(dir)
        -- Get the list of files and subdirectories in the current directory
        local files = minetest.get_dir_list(dir, false)
        local subdirs = minetest.get_dir_list(dir, true)

        -- Process files in the current directory
        for _, file in ipairs(files) do
            local filepath = dir .. "/" .. file
            if filepath:sub(-9) == ".vlfschem" then
                local output_file_path = filepath .. ""
                minetest.log("action", "Converting file to binary: " .. filepath .. " -> " .. output_file_path)

                -- Attempt to open the input file in text mode
                local input_file = io.open(filepath, "r")
                if not input_file then
                    minetest.log("error", "Cannot open input file: " .. filepath)
                    return false
                end

                -- Read the input file content
                local content = input_file:read("*a")
                input_file:close()

                -- Attempt to deserialize the content into a Lua table
                local func, err = loadstring(content)
                if not func then
                    minetest.log("error", "Error loading input file: " .. err)
                    return false
                end

                local success, data = pcall(func)
                if not success then
                    minetest.log("error", "Error executing input file: " .. data)
                    return false
                end

                -- Serialize the Lua table into binary format
                local binary_data = binser.serialize(data)

                -- Attempt to open the output file in binary mode
                local output_file = io.open(output_file_path, "wb")
                if not output_file then
                    minetest.log("error", "Cannot open output file: " .. output_file_path)
                    return false
                end

                -- Write the binary data to the output file
                output_file:write(binary_data)
                output_file:close()

                minetest.log("action", "File successfully converted to binary: " .. output_file_path)
            end
        end

        -- Recursively process subdirectories
        for _, subdir in ipairs(subdirs) do
            process_directory(dir .. "/" .. subdir)
        end
    end

    -- Start processing from the specified directory
    process_directory(directory)
end

--convert_vlfschem_to_binary(modpath.."/data/voxelforge/structure/trial_chambers")

local function loadvlfschem(file_name)
    if not file_name then
        minetest.log("error", "File name is nil.")
        return nil
    end

    local file_path = modpath .. "/data/voxelforge/structure/trial_chambers/" .. file_name
    minetest.log("action", "Loading schematic from file: " .. file_path)
    -- Attempt to open the file
    local file = io.open(file_path, "r")
    if not file then
        minetest.log("error", "Cannot open file: " .. file_path)
        return nil
    end

    -- Read the file content
    local content = file:read("*a")
    file:close()

    -- Attempt to deserialize the content
    local func, err = loadstring(content)
    if not func then
        minetest.log("error", "Error loading .vlfschem file: " .. err)
        return nil
    end

    local success, schematic_data = pcall(func)
    if not success then
        minetest.log("error", "Error executing .vlfschem file: " .. schematic_data)
        return nil
    end

    if type(schematic_data) ~= "table" or type(schematic_data.nodes) ~= "table" then
        minetest.log("error", "Invalid schematic data format in file: " .. file_name)
        return nil
    end

    return schematic_data, content
end

local function replace_node_names_in_vlfschem_files(directory, alias)
    local function process_directory(dir)
        -- Get the list of files and subdirectories in the current directory
        local files = minetest.get_dir_list(dir, false)
        local subdirs = minetest.get_dir_list(dir, true)

        -- Process files in the current directory
        for _, file in ipairs(files) do
            local filepath = dir .. "/" .. file
            if filepath:sub(-9) == ".lua" then
                local vlfschem, original_content = loadvlfschem(filepath)

                if vlfschem and vlfschem.nodes then
                    local modified_content = original_content

                    for original_name, new_name in pairs(alias) do
                        -- Only replace exact matches of the name field in the file content
                        local pattern = 'name%s*=%s*"' .. original_name .. '"'
                        local replacement = 'name = "' .. new_name .. '"'
                        if string.find(modified_content, pattern) then
                            modified_content = string.gsub(modified_content, pattern, replacement)
                            minetest.log("action", "Replaced '" .. original_name .. "' with '" .. new_name .. "' in file: " .. filepath)
                        end
                    end

                    -- Write the modified content back to the file
                    local f = io.open(filepath, "w")
                    if f then
                        f:write(modified_content)
                        f:close()
                        minetest.log("action", "Successfully wrote changes to " .. filepath)
                    else
                        minetest.log("error", "Failed to write to vlfschem file: " .. filepath)
                    end
                else
                    minetest.log("error", "Failed to load vlfschem: " .. filepath)
                end
            end
        end

        -- Recursively process subdirectories
        for _, subdir in ipairs(subdirs) do
            process_directory(dir .. "/" .. subdir)
        end
    end

    -- Start processing from the specified directory
    process_directory(modpath.."/data/voxelforge/structure/trial_chambers")
end

-- Example usage:
local files = {
"decor/candle_1.lua",
"decor/light_gray_bed.lua",
"decor/scrape_pot.lua",
"decor/guster_pot.lua",
"decor/empty_pot.lua",
"decor/cyan_bed.lua",
"decor/candle_3.lua",
"decor/candle_4.lua",
"decor/blue_bed.lua",
"decor/orange_bed.lua",
"decor/magenta_bed.lua",
"decor/candle_2.lua",
"decor/brown_bed.lua",
"decor/white_bed.lua",
"decor/barrel.lua",
"decor/green_bed.lua",
"decor/gray_bed.lua",
"decor/yellow_bed.lua",
"decor/red_bed.lua",
"decor/undecorated_pot.lua",
"decor/lime_bed.lua",
"decor/disposal.lua",
"decor/light_blue_bed.lua",
"decor/flow_pot.lua",
"decor/dead_bush_pot.lua",
"decor/pink_bed.lua",
"decor/black_bed.lua",
"decor/purple_bed.lua",
"reward/ominous_vault.lua",
"reward/vault.lua",
"hallway/straight_staircase.lua",
"hallway/long_straight_staircase_down.lua",
"hallway/encounter_3.lua",
"hallway/rubble_chamber.lua",
"hallway/rubble_chamber_thin.lua",
"hallway/encounter_2.lua",
"hallway/cache_1.lua",
"hallway/long_straight_staircase.lua",
"hallway/corridor_connector_1.lua",
"hallway/right_corner.lua",
"hallway/straight_staircase_down.lua",
"hallway/upper_hallway_connector.lua",
"hallway/rubble_thin.lua",
"hallway/encounter_1.lua",
"hallway/encounter_4.lua",
"hallway/rubble.lua",
"hallway/straight.lua",
"hallway/trapped_staircase.lua",
"hallway/corner_staircase.lua",
"hallway/corner_staircase_down.lua",
"hallway/lower_hallway_connector.lua",
"hallway/left_corner.lua",
"hallway/encounter_5.lua",
"chamber/eruption.lua",
"chamber/chamber_1.lua",
"chamber/chamber_8.lua",
"chamber/assembly.lua",
"chamber/entrance_cap.lua",
"chamber/pedestal.lua",
"chamber/slanted.lua",
"chamber/chamber_4.lua",
"chamber/chamber_2.lua",
"chamber/slanted/hallway_4.lua",
"chamber/slanted/ramp_4.lua",
"chamber/slanted/ramp_2.lua",
"chamber/slanted/hallway_2.lua",
"chamber/slanted/hallway_5.lua",
"chamber/slanted/hallway_3.lua",
"chamber/slanted/ramp_1.lua",
"chamber/slanted/hallway_1.lua",
"chamber/slanted/quadrant_3.lua",
"chamber/slanted/quadrant_2.lua",
"chamber/slanted/quadrant_4.lua",
"chamber/slanted/center.lua",
"chamber/slanted/ominous_upper_arm_1.lua",
"chamber/slanted/ramp_3.lua",
"chamber/slanted/quadrant_1.lua",
"chamber/pedestal/ominous_slice_1.lua",
"chamber/pedestal/slice_3.lua",
"chamber/pedestal/slice_1.lua",
"chamber/pedestal/slice_5.lua",
"chamber/pedestal/center_1.lua",
"chamber/pedestal/quadrant_3.lua",
"chamber/pedestal/quadrant_2.lua",
"chamber/pedestal/slice_2.lua",
"chamber/pedestal/slice_4.lua",
"chamber/pedestal/quadrant_1.lua",
"chamber/eruption/slice_3.lua",
"chamber/eruption/quadrant_5.lua",
"chamber/eruption/slice_1.lua",
"chamber/eruption/center_1.lua",
"chamber/eruption/quadrant_3.lua",
"chamber/eruption/quadrant_2.lua",
"chamber/eruption/breeze_slice_1.lua",
"chamber/eruption/quadrant_4.lua",
"chamber/eruption/slice_2.lua",
"chamber/eruption/quadrant_1.lua",
"chamber/addon/lower_staircase_down.lua",
"chamber/addon/walkway_with_bridge_1.lua",
"chamber/addon/full_stacked_walkway_2.lua",
"chamber/addon/full_stacked_walkway.lua",
"chamber/addon/short_grate_platform.lua",
"chamber/addon/hanging_platform.lua",
"chamber/addon/grate_bridge.lua",
"chamber/addon/full_corner_column.lua",
"chamber/addon/c1_breeze.lua",
"chamber/addon/short_platform.lua",
"chamber/assembly/cover_1.lua",
"chamber/assembly/cover_6.lua",
"chamber/assembly/spawner_1.lua",
"chamber/assembly/hanging_4.lua",
"chamber/assembly/hanging_1.lua",
"chamber/assembly/hanging_2.lua",
"chamber/assembly/cover_3.lua",
"chamber/assembly/right_staircase_3.lua",
"chamber/assembly/cover_4.lua",
"chamber/assembly/hanging_5.lua",
"chamber/assembly/right_staircase_1.lua",
"chamber/assembly/right_staircase_2.lua",
"chamber/assembly/cover_5.lua",
"chamber/assembly/left_staircase_2.lua",
"chamber/assembly/hanging_3.lua",
"chamber/assembly/left_staircase_3.lua",
"chamber/assembly/left_staircase_1.lua",
"chamber/assembly/cover_2.lua",
"chamber/assembly/cover_7.lua",
"chamber/assembly/platform_1.lua",
"chamber/assembly/full_column.lua",
"spawner/ranged/poison_skeleton.lua",
"spawner/ranged/skeleton.lua",
"spawner/ranged/stray.lua",
"spawner/breeze/breeze.lua",
"spawner/slow_ranged/poison_skeleton.lua",
"spawner/slow_ranged/skeleton.lua",
"spawner/slow_ranged/stray.lua",
"spawner/small_melee/silverfish.lua",
"spawner/small_melee/cave_spider.lua",
"spawner/small_melee/baby_zombie.lua",
"spawner/small_melee/slime.lua",
"spawner/melee/husk.lua",
"spawner/melee/spider.lua",
"spawner/melee/zombie.lua",
"spawner/connectors/slow_ranged.lua",
"spawner/connectors/ranged.lua",
"spawner/connectors/melee.lua",
"spawner/connectors/small_melee.lua",
"spawner/connectors/breeze.lua",
"dispensers/chamber.lua",
"dispensers/floor_dispenser.lua",
"dispensers/wall_dispenser.lua",
"chests/supply.lua",
"chests/connectors/supply.lua",
"intersection/intersection_2.lua",
"intersection/intersection_1.lua",
"intersection/intersection_3.lua",
"corridor/straight_6.lua",
"corridor/entrance_1.lua",
"corridor/straight_8.lua",
"corridor/entrance_2.lua",
"corridor/end_1.lua",
"corridor/first_plate.lua",
"corridor/straight_5.lua",
"corridor/second_plate.lua",
"corridor/atrium_1.lua",
"corridor/straight_1.lua",
"corridor/straight_4.lua",
"corridor/straight_2.lua",
"corridor/entrance_3.lua",
"corridor/straight_3.lua",
"corridor/end_2.lua",
"corridor/straight_7.lua",
"corridor/addon/decoration_upper.lua",
"corridor/addon/walled_walkway.lua",
"corridor/addon/arrow_dispenser.lua",
"corridor/addon/open_walkway.lua",
"corridor/addon/display_1.lua",
"corridor/addon/head_upper.lua",
"corridor/addon/ladder_to_middle.lua",
"corridor/addon/display_2.lua",
"corridor/addon/reward_upper.lua",
"corridor/addon/chandelier_upper.lua",
"corridor/addon/display_3.lua",
"corridor/addon/staircase.lua",
"corridor/addon/wall.lua",
"corridor/addon/open_walkway_upper.lua",
"corridor/addon/bridge_lower.lua",
"corridor/atrium/grand_staircase_3.lua",
"corridor/atrium/spiral_relief.lua",
"corridor/atrium/bogged_relief.lua",
"corridor/atrium/breeze_relief.lua",
"corridor/atrium/grand_staircase_2.lua",
"corridor/atrium/grand_staircase_1.lua",
"corridor/atrium/spider_relief.lua",
}

local alias = {
    -- In the order that the mc Wiki specified.
    --=============== Trial Chambers ===============--
    	["minecraft:air"] = "air",
	["minecraft:barrel"] = "voxelforge:barrel_closed",
	["minecraft:bed"] = "voxelforge:blue_bed",
	["minecraft:black_bed"] = "voxelforge:bed_black_bottom",
	["minecraft:black_stained_glass"] = "voxelforge:glass_black",
	["minecraft:blue_bed"] = "voxelforge:bed_blue_bottom",
	["minecraft:bone_block"] = "voxelforge:bone_block",
	["minecraft:brown_bed"] = "voxelforge:bed_brown_bottom",
	["minecraft:cactus"] = "voxelforge:cactus",
	["minecraft:candle"] = "voxelforge:candle_lit_1",
	["minecraft:chain"] = "voxelforge:chain",
	["minecraft:chest"] = "voxelforge:chest_small",
	["minecraft:chiseled_sandstone"] = "voxelforge:sandstonecarved",
	["minecraft:chiseled_tuff"] = "voxelforge:tuff_chiseled",
	["minecraft:chiseled_tuff_bricks"] = "voxelforge:tuff_chiseled_bricks",
	["minecraft:cobbled_deepslate"] = "voxelforge:deepslate_cobbled",
	["minecraft:cobblestone"] = "voxelforge:cobble",
	["minecraft:cobweb"] = "voxelforge:cobweb",
	["minecraft:copper_block"] = "voxelforge:copper",
	["minecraft:crafting_table"] = "voxelforge:crafting_table",
	["minecraft:cyan_bed"] = "voxelforge:bed_cyan_bottom",
	["minecraft:dead_bush"] = "voxelforge:deadbush",
	["minecraft:decorated_pot"] = "voxelforge:pot",
	["minecraft:dirt"] = "voxelforge:dirt",
	["minecraft:dispenser"] = "voxelforge:dispenser",
	["minecraft:flower_pot"] = "voxelforge:flower_pot",
	["minecraft:gray_bed"] = "voxelforge:bed_gray_bottom",
	["minecraft:green_bed"] = "voxelforge:bed_green_bottom",
	["minecraft:hopper"] = "voxelforge:hopper",
	["minecraft:jigsaw"] = "voxelforge:jigsaw",
	["minecraft:ladder"] = "voxelforge:ladder",
	["minecraft:light_blue_bed"] = "voxelforge:bed_light_blue_bottom",
	["minecraft:light_gray_bed"] = "voxelforge:bed_silver_bottom",
	["minecraft:light_gray_stained_glass"] =  "voxelforge:glass_silver",
	["minecraft:lime_bed"] = "voxelforge:bed_lime_bottom",
	["minecraft:magenta_bed"] = "voxelforge:bed_magenta_bottom",
	["minecraft:magma_block"] = "voxelforge:magma",
	["minecraft:mangrove_leaves"] = "voxelforge:leaves_mangrove",
	["minecraft:mangrove_log"] = "voxelforge:bark_mangrove",
	["minecraft:mangrove_roots"] = "voxelforge:mangrove_roots",
	["minecraft:mangrove_wood"] = "voxelforge:wood_mangrove",
	["minecraft:moss_block"] = "voxelforge:moss",
	["minecraft:moss_carpet"] = "voxelforge:moss_carpet",
	["minecraft:mossy_cobblestone"] = "voxelforge:mossycobble",
	["minecraft:mud"] = "voxelforge:mud",
	--["minecraft:muddy_mangrove_roots"] =
	["minecraft:oak_button"] = "voxelforge:button_oak_off",
	["minecraft:oak_fence"] = "voxelforge:oak_fence",
	["minecraft:oak_leaves"] = "voxelforge:leaves_oak",
	["minecraft:oak_log"] = "voxelforge:bark_oak",
	["minecraft:oak_pressure_plate"] = "voxelforge:pressure_plate_oak_off",
	["minecraft:oak_slab"] = "voxelforge:slab_oak",
	--["minecraft:ominous_vault"] =
	["minecraft:orange_bed"] = "voxelforge:bed_orange_bottom",
	["minecraft:oxidized_copper_trapdoor"] = "voxelforge:oxidized_trapdoor", 
	["minecraft:oxidized_cut_copper"] = "voxelforge:oxidized_cut_copper",
	["minecraft:packed_ice"] = "voxelforge:packed_ice",
	["minecraft:pink_bed"] = "voxelforge:bed_pink_bottom",
	["minecraft:podzol"] = "voxelforge:podzol",
	--["minecraft:pointed_dripstone"] =
	["minecraft:polished_andesite"] = "voxelforge:andesite_smooth",
	["minecraft:polished_tuff"] = "voxelforge:tuff_polished",
	["minecraft:polished_tuff_slab"] = "voxelforge:slab_tuff_polished",
	["minecraft:potted_dead_bush"] = "voxelforge:flower_pot_deadbush",
	["minecraft:powder_snow"] = "voxelforge:powdered_snow",
	["minecraft:purple_bed"] = "voxelforge:bed_purple_bottom",
	["minecraft:red_bed"] = "voxelforge:bed_purple_bottom",
	["minecraft:red_candle"] = "voxelforge:candle_lit_4",
	["minecraft:red_concrete"] = "voxelforge:concrete_red",
	["minecraft:red_glazed_terracotta"] = "voxelforge:glazed_terracotta_red",
	["minecraft:red_mushroom"] = "voxelforge:mushroom_red",
	["minecraft:redstone_wire"] = "voxelforge:wire_00000000_off",
	["minecraft:sand"] = "voxelforge:sand",
	--["minecraft:spawner"] =
	["minecraft:stone"] = "voxelforge:stone",
	["minecraft:stone_bricks"] = "voxelforge:stonebrick",
	["minecraft:stone_button"] = "voxelforge:button_stone_off",
	--["minecraft:structure_block"] = "voxelforge:schematic_editor"
	--["minecraft:trial_spawner"] =
	["minecraft:tripwire"] = "voxelforge:tripwire",
	["minecraft:tripwire_hook"] = "voxelforge:tripwire_hook",
	["minecraft:tuff_bricks"] = "voxelforge:tuff_bricks",
	["minecraft:vault"] = "voxelforge:vault",
	["minecraft:vine"] = "voxelforge:vine",
	["minecraft:water"] = "voxelforge:water_source",
	["minecraft:waxed_chiseled_copper"] = "voxelforge:waxed_chiseled_copper",
	["minecraft:waxed_copper_block"] = "voxelforge:waxed_copper",
	["minecraft:waxed_copper_bulb"] = "voxelforge:waxed_copper_bulb_lit",
	["minecraft:waxed_copper_door"] = "voxelforge:waxed_copper_door_b_1",
	["minecraft:waxed_copper_grate"] = "voxelforge:waxed_copper_grate",
	["minecraft:waxed_cut_copper"] = "voxelforge:waxed_cut_copper",
	["minecraft:waxed_cut_copper_slab"] = "voxelforge:slab_waxed_copper_cut",
	["minecraft:waxed_cut_copper_stairs"] = "voxelforge:stair_waxed_copper_cut",
	["minecraft:waxed_oxidized_chiseled_copper"] = "voxelforge:waxed_oxidized_chiseled_copper",
	["minecraft:waxed_oxidized_copper"] = "voxelforge:waxed_oxidized_copper",
	["minecraft:waxed_oxidized_copper_door"] = "voxelforge:waxed_oxidized_copper_door_b_1",
	["minecraft:waxed_oxidized_copper_grate"] = "voxelforge:waxed_oxidized_copper_grate",
	["minecraft:waxed_oxidized_copper_trapdoor"] =  "voxelforge:waxed_oxidized_trapdoor",
	["minecraft:waxed_oxidized_cut_copper"] = "voxelforge:waxed_oxidized_cut_copper",
	["minecraft:waxed_oxidized_cut_copper_slab"] = "voxelforge:slab_waxed_copper_oxidized_cut",
	["minecraft:waxed_oxidized_cut_copper_stairs"] = "voxelforge:stair_waxed_copper_oxidized_cut",
	["minecraft:white_bed"] = "voxelforge:bed_white_bottom",
	["minecraft:white_concrete"] = "voxelforge:concrete_white",
	["minecraft:white_stained_glass"] = "voxelforge:glass_white",
	["minecraft:yellow_bed"] = "voxelforge:bed_yellow_bottom",
}

-- This function conflicts with mod security. Only enable this is you're trying to convert MC nbt files to VF vlfschem files
replace_node_names_in_vlfschem_files(files, alias)
