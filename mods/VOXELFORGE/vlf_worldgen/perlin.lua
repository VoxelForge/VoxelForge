--[[local perlin = {}

-- Permutation table (random shuffle of numbers 0-255)
local p = {}
local perm = {
    151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,
    8,99,37,240,21,10,23,190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,
    35,11,32,57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,
    134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,
    55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208,89,
    18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,
    226,250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,
    17,182,189,28,42,223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,
    155,167,43,172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,
    218,246,97,228,251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,
    249,14,239,107,49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,
    127,4,150,254,138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,
    61,156,180
}
for i = 0, 255 do
    p[i] = perm[i + 1]
    p[i + 256] = p[i]  -- Duplicate permutation table
end

-- Fade function for smooth transitions
local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

-- Linear interpolation
local function lerp(t, a, b)
    return a + t * (b - a)
end

-- Vectorized gradient function
local function grad(hash, x, y, z)
    local h = hash % 16
    local u, v
    if h < 8 then
        u, v = x, y
    elseif h < 12 then
        u, v = y, z
    else
        u, v = x, z
    end
    return ((h % 2 == 0) and u or -u) + ((h % 4 == 0) and v or -v)
end

-- 2D Perlin noise
function perlin.noise2d(x, y, octaves, persistence, spread)
    local total = 0
    local frequency = 1 / spread
    local amplitude = 1
    local max_value = 0  -- Normalization factor

    for i = 1, octaves do
        local xf = x * frequency
        local yf = y * frequency
        local X = math.floor(xf) % 256
        local Y = math.floor(yf) % 256
        local x_frac = xf - math.floor(xf)
        local y_frac = yf - math.floor(yf)

        local u = fade(x_frac)
        local v = fade(y_frac)

        local A = p[X] + Y
        local B = p[X + 1] + Y

        local grad1 = grad(p[A], x_frac, y_frac, 0)
        local grad2 = grad(p[B], x_frac - 1, y_frac, 0)
        local grad3 = grad(p[A + 1], x_frac, y_frac - 1, 0)
        local grad4 = grad(p[B + 1], x_frac - 1, y_frac - 1, 0)

        local lerp1 = lerp(u, grad1, grad2)
        local lerp2 = lerp(u, grad3, grad4)
        local noise_value = lerp(v, lerp1, lerp2)

        total = total + noise_value * amplitude
        max_value = max_value + amplitude
        amplitude = amplitude * persistence
        frequency = frequency * 2
    end

    return total / max_value  -- Normalize to 0-1 range
end

-- 3D Perlin noise
function perlin.noise3d(x, y, z, octaves, persistence, spread)
    local total = 0
    local frequency = 1 / spread
    local amplitude = 1
    local max_value = 0  

    for i = 1, octaves do
        local xf = x * frequency
        local yf = y * frequency
        local zf = z * frequency
        local X = math.floor(xf) % 256
        local Y = math.floor(yf) % 256
        local Z = math.floor(zf) % 256
        local x_frac = xf - math.floor(xf)
        local y_frac = yf - math.floor(yf)
        local z_frac = zf - math.floor(zf)

        local u = fade(x_frac)
        local v = fade(y_frac)
        local w = fade(z_frac)

        local A = p[X] + Y
        local AA = p[A] + Z
        local AB = p[A + 1] + Z
        local B = p[X + 1] + Y
        local BA = p[B] + Z
        local BB = p[B + 1] + Z

        local grad1 = grad(p[AA], x_frac, y_frac, z_frac)
        local grad2 = grad(p[BA], x_frac - 1, y_frac, z_frac)
        local grad3 = grad(p[AB], x_frac, y_frac - 1, z_frac)
        local grad4 = grad(p[BB], x_frac - 1, y_frac - 1, z_frac)
        local grad5 = grad(p[AA + 1], x_frac, y_frac, z_frac - 1)
        local grad6 = grad(p[BA + 1], x_frac - 1, y_frac, z_frac - 1)
        local grad7 = grad(p[AB + 1], x_frac, y_frac - 1, z_frac - 1)
        local grad8 = grad(p[BB + 1], x_frac - 1, y_frac - 1, z_frac - 1)

        local lerp1 = lerp(u, grad1, grad2)
        local lerp2 = lerp(u, grad3, grad4)
        local lerp3 = lerp(u, grad5, grad6)
        local lerp4 = lerp(u, grad7, grad8)

        local lerp5 = lerp(v, lerp1, lerp2)
        local lerp6 = lerp(v, lerp3, lerp4)

        local noise_value = lerp(w, lerp5, lerp6)

        total = total + noise_value * amplitude
        max_value = max_value + amplitude
        amplitude = amplitude * persistence
        frequency = frequency * 2
    end

    return total / max_value  -- Normalize to 0-1 range
end

return perlin]]


local Perlin = {}

-- Permutation table
local function generate_permutation(seed)
    local p = {}
    math.randomseed(seed)
    for i = 0, 255 do
        p[i] = i
    end
    for i = 255, 1, -1 do
        local j = math.random(0, i)
        p[i], p[j] = p[j], p[i]
    end
    for i = 0, 255 do
        p[i + 256] = p[i] -- Duplicate for overflow
    end
    return p
end

-- Converts a string into a 64-bit seed
local function string_to_seed(str)
    local seed = 0
    for i = 1, #str do
        seed = (seed * 31 + string.byte(str, i)) % (2^63)
    end
    return seed
end

-- Fade function
local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

-- Linear interpolation
local function lerp(t, a, b)
    return a + t * (b - a)
end

-- Gradient function (Fix: Ensure valid permutation table lookups)
local function grad(hash, x, y, z)
    local h = hash % 16
    local u = (h < 8) and x or y
    local v = (h < 4) and y or ((h == 12 or h == 14) and x or z)
    
    -- Ensure u and v are numbers, not booleans
    if type(u) ~= "number" then u = 0 end
    if type(v) ~= "number" then v = 0 end

    return ((h % 2 == 0) and u or -u) + ((h % 4 == 0) and v or -v)
end

-- Initialize Perlin with a seed
function Perlin.new(seed)
    if type(seed) == "string" then
        seed = string_to_seed(seed)
    elseif type(seed) ~= "number" then
        seed = os.time()
    end
    local obj = { perm = generate_permutation(seed) }
    setmetatable(obj, { __index = Perlin })
    return obj
end

-- 2D Perlin Noise
function Perlin:noise2d(x, y, octaves, persistence, spread)
    local total, max_value = 0, 0
    local amplitude, frequency = 1, 1 / spread

    for _ = 1, octaves do
        local xf, yf = x * frequency, y * frequency
        local X, Y = math.floor(xf) % 256, math.floor(yf) % 256
        local x_frac, y_frac = xf - math.floor(xf), yf - math.floor(yf)

        local u, v = fade(x_frac), fade(y_frac)

        local A, B = self.perm[X] + Y, self.perm[X + 1] + Y
        local grad1 = grad(self.perm[A] % 256, x_frac, y_frac, 0)
        local grad2 = grad(self.perm[B] % 256, x_frac - 1, y_frac, 0)
        local grad3 = grad(self.perm[A + 1] % 256, x_frac, y_frac - 1, 0)
        local grad4 = grad(self.perm[B + 1] % 256, x_frac - 1, y_frac - 1, 0)

        local lerp1 = lerp(u, grad1, grad2)
        local lerp2 = lerp(u, grad3, grad4)
        local noise_value = lerp(v, lerp1, lerp2)

        total = total + noise_value * amplitude
        max_value = max_value + amplitude
        amplitude = amplitude * persistence
        frequency = frequency * 2
    end

    return total / max_value
end

-- 3D Perlin Noise
function Perlin:noise3d(x, y, z, octaves, persistence, spread)
    local total, max_value = 0, 0
    local amplitude, frequency = 1, 1 / spread

    for _ = 1, octaves do
        local xf, yf, zf = x * frequency, y * frequency, z * frequency
        local X, Y, Z = math.floor(xf) % 256, math.floor(yf) % 256, math.floor(zf) % 256
        local x_frac, y_frac, z_frac = xf - math.floor(xf), yf - math.floor(yf), zf - math.floor(zf)

        local u, v, w = fade(x_frac), fade(y_frac), fade(z_frac)

        local A, B = self.perm[X] + Y, self.perm[X + 1] + Y
        local AA, AB = self.perm[A] + Z, self.perm[A + 1] + Z
        local BA, BB = self.perm[B] + Z, self.perm[B + 1] + Z

        local grad1 = grad(self.perm[AA], x_frac, y_frac, z_frac)
        local grad2 = grad(self.perm[BA], x_frac - 1, y_frac, z_frac)
        local grad3 = grad(self.perm[AB], x_frac, y_frac - 1, z_frac)
        local grad4 = grad(self.perm[BB], x_frac - 1, y_frac - 1, z_frac)
        local grad5 = grad(self.perm[AA + 1], x_frac, y_frac, z_frac - 1)
        local grad6 = grad(self.perm[BA + 1], x_frac - 1, y_frac, z_frac - 1)
        local grad7 = grad(self.perm[AB + 1], x_frac, y_frac - 1, z_frac - 1)
        local grad8 = grad(self.perm[BB + 1], x_frac - 1, y_frac - 1, z_frac - 1)

        local lerp1 = lerp(u, grad1, grad2)
        local lerp2 = lerp(u, grad3, grad4)
        local lerp3 = lerp(u, grad5, grad6)
        local lerp4 = lerp(u, grad7, grad8)

        local lerp5 = lerp(v, lerp1, lerp2)
        local lerp6 = lerp(v, lerp3, lerp4)

        local noise_value = lerp(w, lerp5, lerp6)

        total = total + noise_value * amplitude
        max_value = max_value + amplitude
        amplitude = amplitude * persistence
        frequency = frequency * 2
    end

    return total / max_value
end

return Perlin

--[[local Perlin = {}

-- Permutation table (same as before)
local function generate_permutation(seed)
    local p = {}
    math.randomseed(seed)
    for i = 0, 255 do
        p[i] = i
    end
    for i = 255, 1, -1 do
        local j = math.random(0, i)
        p[i], p[j] = p[j], p[i]
    end
    for i = 0, 255 do
        p[i + 256] = p[i] -- Duplicate for overflow
    end
    return p
end

-- Converts a string into a 64-bit seed
local function string_to_seed(str)
    local seed = 0
    for i = 1, #str do
        seed = (seed * 31 + string.byte(str, i)) % (2^63)
    end
    return seed
end

-- Fade function (same as before)
local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

-- Linear interpolation (same as before)
local function lerp(t, a, b)
    return a + t * (b - a)
end

-- Gradient function (same as before)
local function grad(hash, x, y, z)
    local h = hash % 16
    local u = (h < 8) and x or y
    local v = (h < 4) and y or ((h == 12 or h == 14) and x or z)
    
    if type(u) ~= "number" then u = 0 end
    if type(v) ~= "number" then v = 0 end

    return ((h % 2 == 0) and u or -u) + ((h % 4 == 0) and v or -v)
end

-- Initialize Perlin with a seed
function Perlin.new(seed)
    if type(seed) == "string" then
        seed = string_to_seed(seed)
    elseif type(seed) ~= "number" then
        seed = os.time()
    end
    local obj = { perm = generate_permutation(seed) }
    setmetatable(obj, { __index = Perlin })
    return obj
end

-- 2D Perlin Noise with amplitude table and firstOctave handling
function Perlin:noise2d(x, y, octaves, persistence, spread, amplitudeTable, firstOctave)
    local total, max_value = 0, 0
    local amplitude, frequency = 1, 1 / spread

    -- Handle negative firstOctave
    if firstOctave < 0 then
        frequency = frequency * (2 ^ -firstOctave)
        amplitude = amplitudeTable and amplitudeTable[1] or amplitude
    else
        -- Use amplitude table or default persistence multiplier for positive firstOctave
        amplitude = amplitudeTable and amplitudeTable[firstOctave + 1] or amplitude
    end

    for i = 1, octaves do
        local xf, yf = x * frequency, y * frequency
        local X, Y = math.floor(xf) % 256, math.floor(yf) % 256
        local x_frac, y_frac = xf - math.floor(xf), yf - math.floor(yf)

        local u, v = fade(x_frac), fade(y_frac)

        local A, B = self.perm[X] + Y, self.perm[X + 1] + Y
        local grad1 = grad(self.perm[A] % 256, x_frac, y_frac, 0)
        local grad2 = grad(self.perm[B] % 256, x_frac - 1, y_frac, 0)
        local grad3 = grad(self.perm[A + 1] % 256, x_frac, y_frac - 1, 0)
        local grad4 = grad(self.perm[B + 1] % 256, x_frac - 1, y_frac - 1, 0)

        local lerp1 = lerp(u, grad1, grad2)
        local lerp2 = lerp(u, grad3, grad4)
        local noise_value = lerp(v, lerp1, lerp2)

        total = total + noise_value * amplitude
        max_value = max_value + amplitude

        -- Update amplitude based on table or persistence
        if amplitudeTable then
            amplitude = amplitudeTable[i + firstOctave + 1] or amplitude
        else
            amplitude = amplitude * persistence
        end

        frequency = frequency * 2
    end

    return total / max_value  -- Normalize to 0-1 range
end

-- 3D Perlin Noise with amplitude table and firstOctave handling
function Perlin:noise3d(x, y, z, octaves, persistence, spread, amplitudeTable, firstOctave)
    local total, max_value = 0, 0
    local amplitude, frequency = 1, 1 / spread

    -- Handle negative firstOctave
    if firstOctave < 0 then
        frequency = frequency * (2 ^ -firstOctave)
        amplitude = amplitudeTable and amplitudeTable[1] or amplitude
    else
        -- Use amplitude table or default persistence multiplier for positive firstOctave
        amplitude = amplitudeTable and amplitudeTable[firstOctave + 1] or amplitude
    end

    for i = 1, octaves do
        local xf, yf, zf = x * frequency, y * frequency, z * frequency
        local X, Y, Z = math.floor(xf) % 256, math.floor(yf) % 256, math.floor(zf) % 256
        local x_frac, y_frac, z_frac = xf - math.floor(xf), yf - math.floor(yf), zf - math.floor(zf)

        local u, v, w = fade(x_frac), fade(y_frac), fade(z_frac)

        local A, B = self.perm[X] + Y, self.perm[X + 1] + Y
        local AA, AB = self.perm[A] + Z, self.perm[A + 1] + Z
        local BA, BB = self.perm[B] + Z, self.perm[B + 1] + Z

        local grad1 = grad(self.perm[AA], x_frac, y_frac, z_frac)
        local grad2 = grad(self.perm[BA], x_frac - 1, y_frac, z_frac)
        local grad3 = grad(self.perm[AB], x_frac, y_frac - 1, z_frac)
        local grad4 = grad(self.perm[BB], x_frac - 1, y_frac - 1, z_frac)
        local grad5 = grad(self.perm[AA + 1], x_frac, y_frac, z_frac - 1)
        local grad6 = grad(self.perm[BA + 1], x_frac - 1, y_frac, z_frac - 1)
        local grad7 = grad(self.perm[AB + 1], x_frac, y_frac - 1, z_frac - 1)
        local grad8 = grad(self.perm[BB + 1], x_frac - 1, y_frac - 1, z_frac - 1)

        local lerp1 = lerp(u, grad1, grad2)
        local lerp2 = lerp(u, grad3, grad4)
        local lerp3 = lerp(u, grad5, grad6)
        local lerp4 = lerp(u, grad7, grad8)

        local lerp5 = lerp(v, lerp1, lerp2)
        local lerp6 = lerp(v, lerp3, lerp4)

        local noise_value = lerp(w, lerp5, lerp6)

        total = total + noise_value * amplitude
        max_value = max_value + amplitude

        -- Update amplitude based on table or persistence
        if amplitudeTable then
            amplitude = amplitudeTable[i + firstOctave + 1] or amplitude
        else
            amplitude = amplitude * persistence
        end

        frequency = frequency * 2
    end

    return total / max_value  -- Normalize to 0-1 range
end

return Perlin]]

