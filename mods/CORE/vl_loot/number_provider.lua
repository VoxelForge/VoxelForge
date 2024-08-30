-- Evaluates number providers in loot tables
vl_loot.number_provider = {}

local function evaluate(number_provider, loot_context)
    -- TODO: Support all types
    -- TODO: Use deterministic random gen
    -- Possible number provider types:
    --  [implied constant]
    --  [implied uniform]
    --  constant: use .value (f)
    --  uniform: between .min (f) and .max (f)
    --  binomial: .n (f), .p (i)
    --  score: TODO
    --  storage: TODO
    --  enchantment_level: TODO (not used for what you think it is)
    
    -- implied constant
    if type(number_provider) == "number" then
        return number_provider
    -- otherwise we can assume it is a table
    elseif number_provider.type == "constant" then
        return number_provider.value
    elseif number_provider.type == "uniform" then
        return math.random(number_provider.min, number_provider.max)
    elseif number_provider.type == "binomial" then
        -- Sample binomial distribution
        local total_value = 0
        local p = number_provider.p
        for i=1,number_provider.n do
            if math.random() >= p then
                total_value = total_value + 1
            end
        end
        return total_value
    --elseif number_provider.type == "score" then
    --elseif number_provider.type == "storage" then
    --elseif number_provider.type == "enchantment_level" then
    elseif number_provider.min and number_provider.max then
        return math.random(number_provider.min, number_provider.max)
    else
        minetest.log("error", "invalid number provider when calculating loot: ", dump(number_provider))
        return 0
    end    
end

vl_loot.number_provider.evaluate = evaluate