-- Reliable Seed and Hash-based Randomizer Library

local Randomizer = {}
Randomizer.__index = Randomizer

-- Hash function (FNV-1a Hash)
local function fnv1a_hash(str)
    local hash = 0x811c9dc5
    for i = 1, #str do
        hash = bit.bxor(hash, str:byte(i))
        hash = (hash * 0x01000193) % 2^32
    end
    return hash
end

-- Initialize the randomizer with two seeds
function Randomizer.new(seed1, seed2)
    local self = setmetatable({}, Randomizer)

    -- Combine the two seeds into a single hash
    local combined_seed = fnv1a_hash(tostring(seed1)) + fnv1a_hash(tostring(seed2))
    self.seed = combined_seed % 2^32
    self.state = self.seed

    return self
end

-- Generate a pseudo-random number based on the internal state
function Randomizer:random(min, max)
    -- Advance the state using a simple PRNG algorithm (LCG)
    self.state = (self.state * 1664525 + 1013904223) % 2^32

    -- Generate a random number
    local rand = self.state / 2^32

    -- Return a random number within the specified range
    if min and max then
        return math.floor(rand * (max - min + 1)) + min
    elseif min then
        return math.floor(rand * min) + 1
    else
        return rand
    end
end

-- Generate a hash-based random number using a custom key
function Randomizer:hash_random(key, min, max)
    local combined_key = tostring(self.seed) .. tostring(key)
    local hash = fnv1a_hash(combined_key)
    local rand = hash / 2^32

    if min and max then
        return math.floor(rand * (max - min + 1)) + min
    elseif min then
        return math.floor(rand * min) + 1
    else
        return rand
    end
end

-- Chance-based randomization
function Randomizer:chance(probability)
    if probability < 0 or probability > 1 then
        error("Probability must be between 0 and 1")
    end
    return self:random() < probability
end

-- Weighted random selection
function Randomizer:weighted_random(weights)
    local total_weight = 0
    for _, weight in pairs(weights) do
        total_weight = total_weight + weight
    end

    local rand = self:random() * total_weight
    local cumulative_weight = 0

    for option, weight in pairs(weights) do
        cumulative_weight = cumulative_weight + weight
        if rand <= cumulative_weight then
		return option
        end
    end
end

-- Randomize a value with chance and weighted randomization
function Randomizer:randomize(value, probability, weights, pi_factor)
    if not self:chance(probability) then
        return value
    end

    -- Select random option based on weights
    local random_option = self:weighted_random(weights)

    -- Incorporate π into randomness
    pi_factor = pi_factor or 1.0
    local pi_noise = self:random(-pi_factor, pi_factor)

    -- Apply the selected option to the value
    return value + pi_noise * random_option
end

return Randomizer

