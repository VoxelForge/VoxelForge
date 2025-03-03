--[[local Perlin = {}

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

return Perlin]]

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

-- Gradient function
local function grad(hash, x, y, z)
    local h = hash % 16
    local u = (h < 8) and x or y
    local v = (h < 4) and y or ((h == 12 or h == 14) and x or z)
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

-- 2D Perlin Noise with adjustable amplitudes per octave
function Perlin:noise2d(x, y, octaves, amplitude_table, spread)
    local total, max_value = 0, 0
    local frequency = 1 / spread

    for i = 1, octaves do
        local amplitude = amplitude_table[i] or 1
        local xf, yf = x * frequency, y * frequency
        local X, Y = math.floor(xf) % 256, math.floor(yf) % 256
        local x_frac, y_frac = xf - math.floor(xf), yf - math.floor(yf)

        local u, v = fade(x_frac), fade(y_frac)

        local A, B = self.perm[X] + Y, self.perm[X + 1] + Y
        local grad1 = grad(self.perm[A], x_frac, y_frac, 0)
        local grad2 = grad(self.perm[B], x_frac - 1, y_frac, 0)
        local grad3 = grad(self.perm[A + 1], x_frac, y_frac - 1, 0)
        local grad4 = grad(self.perm[B + 1], x_frac - 1, y_frac - 1, 0)

        local lerp1 = lerp(u, grad1, grad2)
        local lerp2 = lerp(u, grad3, grad4)
        local noise_value = lerp(v, lerp1, lerp2)

        total = total + noise_value * amplitude
        max_value = max_value + amplitude
        frequency = frequency * 2
    end

    return total / max_value
end

-- 3D Perlin Noise with adjustable amplitudes per octave
function Perlin:noise3d(x, y, z, octaves, amplitude_table, spread)
    local total, max_value = 0, 0
    local frequency = 1 / spread

    for i = 1, octaves do
        local amplitude = amplitude_table[i] or 1
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
        frequency = frequency * 2
    end

    return total / max_value
end

return Perlin

