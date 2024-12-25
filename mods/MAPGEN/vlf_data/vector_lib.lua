-- vector_lib.lua
local vector_lib = {}

-- Create a new vector
function vector_lib.new(x, y, z)
    return {x = x, y = y, z = z}
end

-- Add two vectors
function vector_lib.add(v1, v2)
    return vector_lib.new(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
end

-- Subtract two vectors
function vector_lib.subtract(v1, v2)
    return vector_lib.new(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
end

-- Multiply a vector by a scalar
function vector_lib.scale(v, s)
    return vector_lib.new(v.x * s, v.y * s, v.z * s)
end

-- Dot product of two vectors
function vector_lib.dot(v1, v2)
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
end

-- Cross product of two vectors
function vector_lib.cross(v1, v2)
    return vector_lib.new(
        v1.y * v2.z - v1.z * v2.y,
        v1.z * v2.x - v1.x * v2.z,
        v1.x * v2.y - v1.y * v2.x
    )
end

-- Normalize a vector
function vector_lib.normalize(v)
    local length = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
    return vector_lib.scale(v, 1 / length)
end

-- Rotate a vector around the Y-axis (yaw rotation)
function vector_lib.rotate_y(v, angle)
    local rad = math.rad(angle)
    local cos_a = math.cos(rad)
    local sin_a = math.sin(rad)
    return vector_lib.new(
        v.x * cos_a - v.z * sin_a,
        v.y,
        v.x * sin_a + v.z * cos_a
    )
end

-- Align two schematics with a given offset and rotation
function vector_lib.align_schematics(pos1, pos2, rotation)
    local offset = vector_lib.subtract(pos2, pos1)
    local aligned_pos = vector_lib.rotate_y(offset, -rotation)
    return vector_lib.add(pos1, aligned_pos)
end

return vector_lib

