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

local function load_single_resource(registry_path, subpath, namespace_table, file_suffix)
    local absolute_path = registry_path .. subpath
    local stem = get_stem(subpath, file_suffix)
    if not stem then
        minetest.log("error", "Invalid filename in datapack at " .. absolute_path)
        return
    end

    local raw_data = read_file_string(absolute_path)
    if not raw_data then
        minetest.log("error", "Could not read file at " .. absolute_path)
        return
    end

    local loaded_data

    --minetest.debug("Loading resource at " .. subpath .. " in " .. registry_path)

    if file_suffix == "json" then
        loaded_data = minetest.parse_json(raw_data)
        if not loaded_data then
            minetest.log("error", "Error while reading json file at " .. absolute_path)
            return
        end
    else
        minetest.log("error", "Can't read file with format " .. file_suffix .. " at " .. absolute_path)
        return
    end

    namespace_table[stem] = loaded_data
end


-- registry_path must end in a slash
local function load_resources_recursive(registry_path, subpath, namespace_table, file_suffix)
    -- Put a / on the end of the subpath, unless we are in the main registry directory
    if subpath ~= nil then subpath = subpath .. "/"
    else subpath = "" end

    local absolute_path = registry_path .. subpath

    --minetest.debug("Loading resources from " .. absolute_path)
    -- Load files in this directory
    for _, filename in pairs(minetest.get_dir_list(absolute_path, false)) do
        --minetest.debug("Loading resource " .. filename)
        load_single_resource(registry_path, subpath .. filename, namespace_table, file_suffix)
    end

    -- Load from subdirectories
    for _, dirname in pairs(minetest.get_dir_list(absolute_path, true)) do
        --minetest.debug("Going into subdirectory " .. dirname)
        load_resources_recursive(registry_path, subpath .. dirname, namespace_table, file_suffix)
    end
    --minetest.debug("Finished loading resources from " .. absolute_path)
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
