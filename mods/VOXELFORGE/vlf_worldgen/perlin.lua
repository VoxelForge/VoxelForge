--[[
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

        amplitude = amplitude * persistence
        total = total + noise_value * amplitude
        max_value = max_value + amplitude
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
    local amplitude, frequency = 1, 1 / spread * persistence

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
        frequency = frequency * 2  -- Double frequency for next octave
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
        frequency = frequency * 2  -- Double frequency for next octave
    end

    return total / max_value
end

return Perlin]]

--[[local Perlin = {}

local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

local function lerp(a, b, t)
    return a + t * (b - a)
end

local function grad(hash, x, y, z)
    local h = hash % 16
    local u = h < 8 and x or y
    local v = h < 4 and y or (h == 12 or h == 14) and x or z
    return ((h % 2 == 0) and u or -u) + ((h % 4 < 2) and v or -v)
end

local permutation = {}
local p = {}

math.randomseed(os.time())
for i = 0, 255 do
    permutation[i] = i
end

for i = 255, 0, -1 do
    local j = math.random(0, 255)
    permutation[i], permutation[j] = permutation[j], permutation[i]
end

for i = 0, 511 do
    p[i] = permutation[i % 256]
end

function Perlin.noise(x, y, z, spread)
    spread = spread or 1
    x, y, z = x / spread, y / spread, z and z / spread or nil
    
    if z == nil then
        local X = math.floor(x) % 256
        local Z = math.floor(y) % 256
        
        x = x - math.floor(x)
        z = y - math.floor(y)
        
        local u, v = fade(x), fade(z)
        
        local A = p[X] + Z
        local B = p[X + 1] + Z
        
        return lerp(
            lerp(grad(p[A], x, 0, z), grad(p[B], x - 1, 0, z), u),
            lerp(grad(p[A + 1], x, 0, z - 1), grad(p[B + 1], x - 1, 0, z - 1), u),
            v
        )
    else
        local X = math.floor(x) % 256
        local Y = math.floor(y) % 256
        local Z = math.floor(z) % 256
        
        x = x - math.floor(x)
        y = y - math.floor(y)
        z = z - math.floor(z)
        
        local u, v, w = fade(x), fade(y), fade(z)
        
        local A = p[X] + Y
        local AA = p[A] + Z
        local AB = p[A + 1] + Z
        local B = p[X + 1] + Y
        local BA = p[B] + Z
        local BB = p[B + 1] + Z
        
        return lerp(
            lerp(
                lerp(grad(p[AA], x, y, z), grad(p[BA], x - 1, y, z), u),
                lerp(grad(p[AB], x, y - 1, z), grad(p[BB], x - 1, y - 1, z), u),
                v
            ),
            lerp(
                lerp(grad(p[AA + 1], x, y, z - 1), grad(p[BA + 1], x - 1, y, z - 1), u),
                lerp(grad(p[AB + 1], x, y - 1, z - 1), grad(p[BB + 1], x - 1, y - 1, z - 1), u),
                v
            ),
            w
        )
    end
end

function Perlin.fbm(x, y, z, octaves, lacunarity, gain, spread)
    local sum, amplitude = 0, 1
    if z == nil then y, z = 0, y end
    for i = 1, octaves do
        sum = sum + amplitude * Perlin.noise(x, y, z, spread)
        x, y, z = x * lacunarity, y * lacunarity, z * lacunarity
        amplitude = amplitude * gain
    end
    return sum
end

return Perlin]]

local bit = {}

function bit.band(a, b)
    local r = 0
    local shift = 0
    while a > 0 or b > 0 do
        local ai = a % 2
        local bi = b % 2
        if ai == 1 and bi == 1 then
            r = r + 2^shift
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        shift = shift + 1
    end
    return r
end

function bit.floor(x)
    return math.floor(x)
end

perlin = {}
perlin.p = {}

-- Hash lookup table as defined by Ken Perlin
local permutation = {151,160,137,91,90,15,
  131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
  190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
  88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
  77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
  102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
  135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
  5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
  223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
  129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
  251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
  49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
  138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
}

-- p is used to hash unit cube coordinates to [0, 255]
for i=0,255 do
    perlin.p[i] = permutation[i+1]
    perlin.p[i+256] = permutation[i+1]
end

-- Return range: [-1, 1]
-- 2D Noise with Octaves
function perlin.noise2d(x, y, octaves, persistence)
    octaves = octaves or 1
    persistence = persistence or 0.5

    local total = 0
    local frequency = 1
    local amplitude = 1
    local maxAmplitude = 0

    for i = 1, octaves do
        total = total + perlin.single_noise2d(x * frequency, y * frequency) * amplitude
        maxAmplitude = maxAmplitude + amplitude
        amplitude = amplitude * persistence
        frequency = frequency * 2
    end

    return total / maxAmplitude  -- Normalize the result
end

-- 3D Noise with Octaves
function perlin.noise3d(x, y, z, octaves, persistence)
    octaves = octaves or 1
    persistence = persistence or 0.5

    local total = 0
    local frequency = 1
    local amplitude = 1
    local maxAmplitude = 0

    for i = 1, octaves do
        total = total + perlin.single_noise3d(x * frequency, y * frequency, z * frequency) * amplitude
        maxAmplitude = maxAmplitude + amplitude
        amplitude = amplitude * persistence
        frequency = frequency * 2
    end

    return total / maxAmplitude  -- Normalize the result
end

-- Single Octave 2D Noise
function perlin.single_noise2d(x, y)
    -- Calculate the "unit cube" that the point asked will be located in
    local xi = bit.band(math.floor(x),255)
    local yi = bit.band(math.floor(y),255)

    -- Next we calculate the location (from 0 to 1) in that cube
    x = x - math.floor(x)
    y = y - math.floor(y)

    -- We also fade the location to smooth the result
    local u = perlin.fade(x)
    local v = perlin.fade(y)

    -- Hash all 4 unit square coordinates surrounding input coordinate
    local p = perlin.p
    local A, AA, AB, B, BA, BB
    A   = p[xi  ] + yi
    AA  = p[A   ]
    AB  = p[A+1 ]
    B   = p[xi+1] + yi
    BA  = p[B   ]
    BB  = p[B+1 ]

    -- Take the weighted average between all 4 unit square coordinates
    return perlin.lerp(v,
        perlin.lerp(u,
            perlin.grad(AA,x,y),
            perlin.grad(BA,x-1,y)
        ),
        perlin.lerp(u,
            perlin.grad(AB,x,y-1),
            perlin.grad(BB,x-1,y-1)
        )
    )
end

-- Single Octave 3D Noise
function perlin.single_noise3d(x, y, z)
    -- Calculate the "unit cube" that the point asked will be located in
    local xi = bit.band(math.floor(x),255)
    local yi = bit.band(math.floor(y),255)
    local zi = bit.band(math.floor(z),255)

    -- Next we calculate the location (from 0 to 1) in that cube
    x = x - math.floor(x)
    y = y - math.floor(y)
    z = z - math.floor(z)

    -- We also fade the location to smooth the result
    local u = perlin.fade(x)
    local v = perlin.fade(y)
    local w = perlin.fade(z)

    -- Hash all 8 unit cube coordinates surrounding input coordinate
    local p = perlin.p
    local A, AA, AB, AAA, ABA, AAB, ABB, B, BA, BB, BAA, BBA, BAB, BBB
    A   = p[xi  ] + yi
    AA  = p[A   ] + zi
    AB  = p[A+1 ] + zi
    AAA = p[ AA ]
    ABA = p[ AB ]
    AAB = p[ AA+1 ]
    ABB = p[ AB+1 ]

    B   = p[xi+1] + yi
    BA  = p[B   ] + zi
    BB  = p[B+1 ] + zi
    BAA = p[ BA ]
    BBA = p[ BB ]
    BAB = p[ BA+1 ]
    BBB = p[ BB+1 ]

    -- Take the weighted average between all 8 unit cube coordinates
    return perlin.lerp(w,
        perlin.lerp(v,
            perlin.lerp(u,
                perlin.grad(AAA,x,y,z),
                perlin.grad(BAA,x-1,y,z)
            ),
            perlin.lerp(u,
                perlin.grad(ABA,x,y-1,z),
                perlin.grad(BBA,x-1,y-1,z)
            )
        ),
        perlin.lerp(v,
            perlin.lerp(u,
                perlin.grad(AAB,x,y,z-1), perlin.grad(BAB,x-1,y,z-1)
            ),
            perlin.lerp(u,
                perlin.grad(ABB,x,y-1,z-1), perlin.grad(BBB,x-1,y-1,z-1)
            )
        )
    )
end

-- Gradient function finds dot product between pseudorandom gradient vector
function perlin.grad(hash, x, y, z)
    return perlin.dot_product[bit.band(hash,0xF)](x,y,z)
end

-- Fade function is used to smooth final output
function perlin.fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

function perlin.lerp(t, a, b)
    return a + t * (b - a)
end


return perlin
