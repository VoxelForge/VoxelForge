local modpath = minetest.get_modpath("poisonous_potato")
-----------------
---=== API ===---
-----------------
dofile(modpath.."/api/craft_register.lua")
--------------------
---=== BLOCKS ===---
--------------------
dofile(modpath.."/blocks/blocks.lua")
dofile(modpath.."/blocks/potato_bud.lua")
dofile(modpath.."/blocks/potato_cutter.lua")
dofile(modpath.."/blocks/potato_fryer.lua")
dofile(modpath.."/blocks/potato_refinery.lua")
dofile(modpath.."/blocks/powerful_potato.lua")

minetest.register_on_mods_loaded(function()
    for name, def in pairs(minetest.registered_items) do
        -- Check if the item belongs to the "potato" group
        if def.groups and def.groups.potato then
            -- Add "Potato" to the description in green
            local new_description = def.description .. "\n" .. minetest.colorize("#00FF00", "Potato")

            -- Override the item definition with the updated description
            minetest.override_item(name, {
                description = new_description,
            })
        end
    end
end)
