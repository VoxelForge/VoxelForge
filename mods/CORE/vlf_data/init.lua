local cpath = minetest.get_modpath("vlf_data")
-- Define a function to load Lua modules
function load_module(module_name)
    local file_path = minetest.get_modpath(minetest.get_current_modname()) .. "/" .. module_name .. ".lua"
    
    local module, err = loadfile(file_path)
    
    if module then
        local success, result = pcall(module)
        if success then
            return result
        else
            minetest.log("error", "Failed to execute module: " .. result)
        end
    else
        minetest.log("error", "Failed to load module: " .. err)
    end
    
    return nil
end

dofile(cpath .. "/pgs.lua")
dofile(cpath .. "/cave_api.lua")
voxelforge = {}

-- Reload command with validation
minetest.register_chatcommand("reload", {
    description = "Reload parts of the mod and validate data",
    privs = {server = true},  -- Only allow server admins to reload
    func = function()
	dofile(cpath .. "/pgs.lua")
	return "successfully reloaded all specified files"
    end,
})
