-- Evaluates predicates (conditions) in loot tables
vl_loot.predicate = {}

local function check_predicate(predicate_table, loot_context)
    -- TODO: Make this work
    return true
end

local function check_predicates(predicate_tables, loot_context)
    if predicate_tables == nil then return true end
    for _, predicate_table in ipairs(predicate_tables) do
        if not vl_loot.predicate.check_predicate(predicate_table, loot_context) then
            return false
        end
    end
    return true
end

vl_loot.predicate.check_predicates = check_predicates