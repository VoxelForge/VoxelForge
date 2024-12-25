BoundingBox = {}
BoundingBox.__index = BoundingBox

function BoundingBox.new(minX, minY, minZ, maxX, maxY, maxZ)
    local self = setmetatable({}, BoundingBox)
    self.minX = minX
    self.minY = minY
    self.minZ = minZ
    self.maxX = maxX
    self.maxY = maxY
    self.maxZ = maxZ
    
    if maxX < minX or maxY < minY or maxZ < minZ then
        local errorMsg = "Invalid bounding box data, inverted bounds for: " .. tostring(self)
        print(errorMsg)  -- Replace with logging if needed
        self.minX = math.min(minX, maxX)
        self.minY = math.min(minY, maxY)
        self.minZ = math.min(minZ, maxZ)
        self.maxX = math.max(minX, maxX)
        self.maxY = math.max(minY, maxY)
        self.maxZ = math.max(minZ, maxZ)
    end
    
    return self
end

function BoundingBox.fromCorners(corner1, corner2)
    return BoundingBox.new(
        math.min(corner1.x, corner2.x),
        math.min(corner1.y, corner2.y),
        math.min(corner1.z, corner2.z),
        math.max(corner1.x, corner2.x),
        math.max(corner1.y, corner2.y),
        math.max(corner1.z, corner2.z)
    )
end

function BoundingBox.infinite()
    return BoundingBox.new(
        -math.huge, -math.huge, -math.huge,
        math.huge, math.huge, math.huge
    )
end

function BoundingBox:intersectingChunks()
    local minChunkX = math.floor(self.minX / 16)
    local minChunkZ = math.floor(self.minZ / 16)
    local maxChunkX = math.floor(self.maxX / 16)
    local maxChunkZ = math.floor(self.maxZ / 16)
    
    local chunks = {}
    for x = minChunkX, maxChunkX do
        for z = minChunkZ, maxChunkZ do
            table.insert(chunks, {x = x, z = z})
        end
    end
    
    return chunks
end

function BoundingBox:intersects(other)
    return self.maxX >= other.minX and self.minX <= other.maxX
        and self.maxZ >= other.minZ and self.minZ <= other.maxZ
        and self.maxY >= other.minY and self.minY <= other.maxY
end

function BoundingBox:encapsulate(other)
    self.minX = math.min(self.minX, other.minX)
    self.minY = math.min(self.minY, other.minY)
    self.minZ = math.min(self.minZ, other.minZ)
    self.maxX = math.max(self.maxX, other.maxX)
    self.maxY = math.max(self.maxY, other.maxY)
    self.maxZ = math.max(self.maxZ, other.maxZ)
    return self
end

function BoundingBox:move(dx, dy, dz)
    self.minX = self.minX + dx
    self.minY = self.minY + dy
    self.minZ = self.minZ + dz
    self.maxX = self.maxX + dx
    self.maxY = self.maxY + dy
    self.maxZ = self.maxZ + dz
    return self
end

function BoundingBox:moved(dx, dy, dz)
    return BoundingBox.new(
        self.minX + dx, self.minY + dy, self.minZ + dz,
        self.maxX + dx, self.maxY + dy, self.maxZ + dz
    )
end

function BoundingBox:inflatedBy(dx, dy, dz)
    return BoundingBox.new(
        self.minX - dx, self.minY - dy, self.minZ - dz,
        self.maxX + dx, self.maxY + dy, self.maxZ + dz
    )
end

function BoundingBox:isInside(x, y, z)
    return x >= self.minX and x <= self.maxX
        and z >= self.minZ and z <= self.maxZ
        and y >= self.minY and y <= self.maxY
end

function BoundingBox:getLength()
    return {
        x = self.maxX - self.minX,
        y = self.maxY - self.minY,
        z = self.maxZ - self.minZ
    }
end

function BoundingBox:getXSpan()
    return self.maxX - self.minX + 1
end

function BoundingBox:getYSpan()
    return self.maxY - self.minY + 1
end

function BoundingBox:getZSpan()
    return self.maxZ - self.minZ + 1
end

function BoundingBox:getCenter()
    return {
        x = self.minX + (self.maxX - self.minX + 1) / 2,
        y = self.minY + (self.maxY - self.minY + 1) / 2,
        z = self.minZ + (self.maxZ - self.minZ + 1) / 2
    }
end

function BoundingBox:forAllCorners(func)
    func({x = self.maxX, y = self.maxY, z = self.maxZ})
    func({x = self.minX, y = self.maxY, z = self.maxZ})
    func({x = self.maxX, y = self.minY, z = self.maxZ})
    func({x = self.minX, y = self.minY, z = self.maxZ})
    func({x = self.maxX, y = self.maxY, z = self.minZ})
    func({x = self.minX, y = self.maxY, z = self.minZ})
    func({x = self.maxX, y = self.minY, z = self.minZ})
    func({x = self.minX, y = self.minY, z = self.minZ})
end

function BoundingBox:__tostring()
    return string.format(
        "BoundingBox(minX=%d, minY=%d, minZ=%d, maxX=%d, maxY=%d, maxZ=%d)",
        self.minX, self.minY, self.minZ, self.maxX, self.maxY, self.maxZ
    )
end

function BoundingBox:__eq(other)
    return self.minX == other.minX and self.minY == other.minY and self.minZ == other.minZ
        and self.maxX == other.maxX and self.maxY == other.maxY and self.maxZ == other.maxZ
end

-- Example of creating a BoundingBox instance
local box1 = BoundingBox.new(0, 0, 0, 10, 10, 10)
print(box1)

return BoundingBox
