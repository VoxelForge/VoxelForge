--[[ -- Gets the last extension of a filename
-- Returns: stem, extension
local function split_fname(filename)
    local matched, _, stem, extension = string.find(filename, "^(.*)%.(.*)$")
    if not matched then
        return filename, ""
    else
        return stem, extension
    end
end




-- Loads a resource into `load_into`
-- key: filename with last extension stripped
-- value: preferred lua format for that resource
local function load_resource(path, filename, load_into, strict)
    local stem, extension = split_fname(filename)
    local filepath = path .. "/" .. filename
    local filestring = read_file_string(filepath, strict)
    if extension == "json" then
        local parsed_json, err = minetest.parse_json(filestring)
        if not parsed_json then
            -- Not valid json
            error("Error while reading json file " .. filepath .. ": " .. error)
        end
        load_into[stem] = parsed_json
    end
end

-- Recursively load resources from `path`
-- `load_into`: table to load into
-- `strict`: whether to error if resources not found
local function load_resources_internal(path, expected_resources, load_into, strict)
    minetest.debug(path, dump(expected_resources))
    for subfile, subfile_expected in pairs(expected_resources) do
        if type(subfile_expected) == "table" then
            if not load_into[subfile] then
                load_into[subfile] = {}
            end
            local subdir_load_into = load_into[subfile]
            load_resources_internal(path .. "/" .. subfile, subfile_expected, subdir_load_into, strict)
        else -- subfile is file, not dir
            load_resource(path, subfile, load_into, strict)
        end
    end
end ]]

--[[ -- Check if match_string starts with start_check
local function startswith(match_string, start_check)
    return string.sub(match_string, 1, string.len(start_check)) == start_check
end ]]

-- Get file subpath without suffix
-- Returns nil if invalid (e.g. file had wrong suffix)
local function get_stem(subpath, file_suffix)
    local _, _, stem = string.find(subpath, "(.*)%." .. file_suffix .. "$")
    return stem
end

-- Read a file at `filepath` and return its contents as a string
-- Raises an error if file could not be opened
local function read_file_string(filepath)
    local file, err = io.open(filepath)
    if not file then
        error("Error while loading resources: could not open file " .. filepath .. ": " .. err)
    end
    local filestring = file:read("*all")
    file:close()
    return filestring
end

-- registry_path must end in a slash
local function load_single_resource(registry_path, subpath, namespace_table, file_suffix)
    local absolute_path = registry_path .. subpath
    local stem = get_stem(subpath, file_suffix)
    if not stem then
        error("Invalid filename in datapack at " .. absolute_path)
    end
    local raw_data = read_file_string(absolute_path)
    local loaded_data

    minetest.debug("Loading resource at " .. subpath .. " in " .. registry_path)

    if file_suffix == "json" then
        loaded_data= minetest.parse_json(raw_data)
        if not loaded_data then
            -- Not valid json
            error("Error while reading json file at " .. absolute_path)
        end
    else
        error("Can't read file with format " .. file_suffix .. " at " .. absolute_path)
    end

    namespace_table[stem] = loaded_data
end

-- registry_path must end in a slash
local function load_resources_recursive(registry_path, subpath, namespace_table, file_suffix)
    -- Put a / on the end of the subpath, unless we are in the main registry directory
    if subpath ~= nil then subpath = subpath .. "/"
    else subpath = "" end

    local absolute_path = registry_path .. subpath

    minetest.debug("Loading resources from " .. absolute_path)
    -- Load files in this directory
    for _, filename in pairs(minetest.get_dir_list(absolute_path, false)) do
        minetest.debug("Loading resource " .. filename)
        load_single_resource(registry_path, subpath .. filename, namespace_table, file_suffix)
    end

    -- Load from subdirectories
    for _, dirname in pairs(minetest.get_dir_list(absolute_path, true)) do
        minetest.debug("Going into subdirectory " .. dirname)
        load_resources_recursive(registry_path, subpath .. dirname, namespace_table, file_suffix)
    end
    minetest.debug("Finished loading resources from " .. absolute_path)
end

local function load_into_registry(path, registry_name, namespace, file_suffix)
    local registry = vl_datapacks.registries[registry_name]
    if not registry[namespace] then registry[namespace] = {} end
    local namespace_table = registry[namespace]
    load_resources_recursive(path, nil, namespace_table, file_suffix)
end


local function load_into_namespace(namespace, path)
    for registry_name, file_suffix in pairs(vl_datapacks.registry_specs) do
        -- registry_path must end in a slash for internal functions
        load_into_registry(path .. "/" .. registry_name .. "/", registry_name, namespace, file_suffix)
    end
end


-- Loads a full datapack into memory, thereby enabling it and any overrides
local function load_datapack(name, path)
    for _, other_name in pairs(vl_datapacks.loaded_datapacks) do
        if name == other_name then
            error("Datapack " .. name .. " is already loaded")
        end
    end


    local data_path = path .. "/data"

    for _, namespace in pairs(minetest.get_dir_list(data_path, true)) do
        load_into_namespace(namespace, data_path .. "/" .. namespace)
    end
    table.insert(vl_datapacks.loaded_datapacks, name)
end

vl_datapacks.load_datapack = load_datapack
