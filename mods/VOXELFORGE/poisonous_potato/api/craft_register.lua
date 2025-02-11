local custom_crafts = {}

function voxelforge.register_craft(def)
    assert(def.type, "Craft type is required")
    assert(def.output, "Output item is required")
    assert(def.recipe, "Recipe is required")

    if def.type == "potato_refinery" then
        assert(type(def.recipe) == "table", "Recipe must be a table for cooking crafts")
        assert(#def.recipe > 0, "Recipe table cannot be empty")
        assert(def.cooktime, "Cooktime is required for cooking crafts")

        -- Register the custom craft for each item + potato_oil
        table.insert(custom_crafts, {
            type = def.type,
            output = def.output,
            recipe = def.recipe,
            cooktime = def.cooktime,
            meta = def.meta,
        })
    else
        error("Unsupported craft type: " .. def.type)
    end
end

-- Function to register potato refinery crafts for all registered items
function register_potato_refinery_for_all_items()
    -- Iterate through all registered items and blocks
    for _, item in pairs(minetest.registered_items) do

        -- Register the potato refinery craft for each item
        if item.name ~= "custom_mod:potato_oil" then
			voxelforge.register_craft({
            type = "potato_refinery",
            output = item.name,  -- Output item with metadata attached
            recipe = { item.name, "custom_mod:potato_oil"},  -- Using the registered item + potato_oil
            cooktime = 10,  -- Set cooktime as needed
            meta = {
                LubricatedIncrement = 1,  -- Increment Lubricated by 1
                description = minetest.colorize("#FFD700", "Lubricated")

            }
        })
        end
    end
end

-- Call the function to register potato refinery crafts for all registered items
minetest.register_on_mods_loaded(function()
	register_potato_refinery_for_all_items()
end)

function voxelforge.get_craft_result(params)
    assert(params.method, "Craft method is required")
    assert(params.items, "Items are required")
    assert(type(params.items) == "table", "Items must be a table")
    assert(params.width, "Craft width is required")

    -- Handling for 'potato_refinery' craft method
    if params.method == "potato_refinery" then
        for _, craft in ipairs(custom_crafts) do
            if craft.type == "potato_refinery" then
                local all_match = true
                for _, input in ipairs(craft.recipe) do
                    local found = false
                    for i, item in ipairs(params.items) do
                        if item:get_name() == input then
                            found = true
                            params.items[i]:take_item(1)  -- Decrement the stack
                            break
                        end
                    end
                    if not found then
                        all_match = false
                        break
                    end
                end

                if all_match then
                    -- Create the output item
                    local output_item = ItemStack(craft.output)

                    -- Check if metadata is defined and apply it to the output item
                    if craft.meta then
                        local meta = output_item:get_meta()

                        -- Apply Lubricated metadata increment
                        if craft.meta.LubricatedIncrement then
                            local current_lubricated = meta:get_int("Lubricated")
                            meta:set_int("Lubricated", current_lubricated + craft.meta.LubricatedIncrement)
                        end

                    end

                    return {
                        item = output_item,
                        time = craft.cooktime,
                        meta = craft.meta,
                        replacements = {},  -- No replacements for now
                    }
                end
            end
        end
    end

    -- Return empty ItemStack and 0 time if no match
    return {
        item = ItemStack(""),
        time = 0,
        meta = nil,
        replacements = {},
    }
end



-- Example Usage:
voxelforge.register_craft({
    type = "potato_refinery",
    output = "custom_mod:potato_oil",
    recipe = {"mcl_farming:potato_item", "mcl_potions:glass_bottle"},
    cooktime = 5,
})

