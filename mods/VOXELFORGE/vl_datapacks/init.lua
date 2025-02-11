local modpath = minetest.get_modpath(minetest.get_current_modname())

local default_datapack_path = modpath .. "/../../../datapacks/vanilla"


vl_datapacks = {
    registries = {},
    loaded_datapacks = {},
    registry_specs = {
        ["loot_table"] = "json",
    }
}

--[[ Format of `vl_datapacks.registries`:
    {
        <registry name>: {
            <namespace>: {
                <path string>: resource,
            }
            <namespace>: {
                <path string>: resource,
            }
        },
        <registry name>: {
            <namespace>: {
                <path string>: resource,
            }
            <namespace>: {
                <path string>: resource,
            }
        },
    }
]]

local function split_resource_string(resource_string)
    local match_start, _, namespace, path = string.find(resource_string, "([^%s]+)%:([^%s]+)")
    return match_start, namespace, path
end

-- Get resource, returns nil if resource does not exist
-- Can be used to check if resource exists
function vl_datapacks.get_resource(registry_name, resource_string)
    local matched, namespace, path = split_resource_string(resource_string)
    if not matched then return end
    local registry = vl_datapacks.registries[registry_name]
    if not registry then return end
    local namespace_index = registry[namespace]
    if not namespace_index then return end
    return namespace_index[path]
end

for registry_name, _ in pairs(vl_datapacks.registry_specs) do
    vl_datapacks.registries[registry_name] = {}
end

dofile(modpath .. "/resource_loader.lua")

vl_datapacks.load_datapack("vanilla", default_datapack_path)

minetest.register_chatcommand("reload", {
    func = function(name, param)
        vl_datapacks.loaded_datapacks = {}
        vl_datapacks.load_datapack("vanilla", default_datapack_path)
    end
})