-- Main loot engine
vl_loot.engine = {}

-- Adds all items from array `to_append` into old_table
-- Returns nil
local function append_table(old_table, to_append)
    for _, item in ipairs(to_append) do
        table.insert(old_table, item)
    end
end

-- Modifies each of the stacks in `loot_stacks` according to `modifier_table` (array)
-- Edits `loot_stacks` in-place
local function modify_stacks(modifier_table, loot_stacks, loot_context)
    for i, itemstack in pairs(loot_stacks) do
        loot_stacks[i] = vl_loot.modifier.apply_item_modifier(modifier_table, itemstack, loot_context)
    end
end

-- Conditionally returns an entry based on whether its conditions passed
-- For compound-type entries this can return multiple entries
-- Returns array of entries to add to pool
local function unpack_entry(entry_provider_table, loot_context)
    -- ENTRY PROVIDER TYPES (compound have *)
    -- item
    -- tag
    -- loot_table
    -- dynamic
    -- empty
    -- group *
    -- alternative *
    -- sequence *
    
    if not vl_loot.predicate.check_predicates(entry_provider_table.conditions, loot_context) then return {} end

    -- TODO: Support other types
    local entry_type = entry_provider_table.type
    if entry_type == "item" or entry_type == "empty" then
        return {entry_provider_table}
    else
        error("Invalid loot entry type: " .. tostring(entry_type))
    end
end

-- Should always receive a simple-type entry
-- Returns all (already modified) stacks to use as pool loot
local function get_entry_loot(entry_table, loot_context)
    -- SIMPLE ENTRY TYPES
    -- item
    -- tag
    -- loot_table
    -- dynamic
    -- empty

    -- Don't check conditions, these were already checked in unpack_entry

    local loot_stacks = {}
    -- TODO: Support other types
    if entry_table.type == "item" then
        local itemstack = ItemStack(entry_table.name)
        table.insert(loot_stacks, itemstack)
    elseif entry_table.type == "empty" then
        -- Add nothing to loot
    else
        error("Invalid loot entry type: " .. tostring(entry_table.type))
    end

    -- Apply modifier
    modify_stacks(entry_table.functions, loot_stacks, loot_context)
    
    return loot_stacks
end

local function get_final_weight(entry_table, loot_context)
    -- TODO: Add 'quality' based on luck
    -- TODO: Do some floor stuff?
    return entry_table.weight
end

local function get_final_rolls(pool_table, loot_context)
    -- TODO: bonus_rolls (also a number provider)
    local rolls = vl_loot.number_provider.evaluate(pool_table.rolls, loot_context)
    -- Must be an integer
    return math.floor(rolls)
end

-- returns list of itemstacks to add to loot
local function get_pool_loot(pool_table, loot_context)
    if not vl_loot.predicate.check_predicates(pool_table.conditions, loot_context) then return {} end
    local loot_stacks = {}

    -- Calculate how many rolls to do
    local rolls = get_final_rolls(pool_table, loot_context)

    -- Unpack entries of a compound type into simple entries
    local unpacked_entries = {}
    for _, entry_provider_table in ipairs(pool_table.entries) do
        local new_unpacked_entries = unpack_entry(entry_provider_table, loot_context)
        append_table(unpacked_entries, new_unpacked_entries)
    end

    for i=1,rolls do
        -- The 'total weight' of all entries combined (= 1 probability)
        local total_weight = 0
        -- Array of weights of individual entries
        local entry_weights = {}

        -- Calculate weights and add to array and total_weight
        for _, entry_table in ipairs(unpacked_entries) do
            local current_entry_weight = get_final_weight(entry_table, loot_context)
            table.insert(entry_weights, current_entry_weight)
            total_weight = total_weight + current_entry_weight
        end

        -- Get a random value
        -- TODO: Make this deterministic per-loot table and world seed
        local random_value = math.random(0, total_weight)

        -- Work out which entry was picked
        local chosen_entry
        for i, entry_weight in ipairs(entry_weights) do
            random_value = random_value - entry_weight
            -- If the value went <= 0 then this was the chosen entry
            if random_value <= 0 then
                chosen_entry = unpacked_entries[i]
                break
            end
        end

        -- Get loot from the chosen entry
        local current_roll_loot = get_entry_loot(chosen_entry, loot_context)
        append_table(loot_stacks, current_roll_loot)
        
    end
    modify_stacks(pool_table.functions, loot_stacks, loot_context)
    return loot_stacks
end

local function get_loot(loot_table, loot_context)
    local start_time = minetest.get_us_time()
    -- DEBUG ONLY ^^ REMOVE
    local loot_stacks = {}
    for _, pool_table in ipairs(loot_table.pools) do
        local pool_loot_stacks = get_pool_loot(pool_table, loot_context, loot_stacks)
        append_table(loot_stacks, pool_loot_stacks)
    end
    modify_stacks(loot_table.functions, loot_stacks, loot_context)
    minetest.debug("Generated loot in " .. tostring((minetest.get_us_time() - start_time)/1000) .. " milliseconds")
    -- DEBUG ONLY ^^ REMOVE
    return loot_stacks
end

vl_loot.engine.get_loot = get_loot