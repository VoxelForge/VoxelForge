local ringbuffer_class = {}
local ringbuffer = {}
ringbuffer_class.__index = ringbuffer_class

function ringbuffer.new(size, initial_values)
	return setmetatable({
		data = initial_values or {},
		size = size,
	}, ringbuffer_class)
end

function ringbuffer_class:insert(record)
	if #self.data >= self.size then
		table.remove(self.data, 1)
	end
	table.insert(self.data, record)
end

function ringbuffer_class:indexof(val)
	local i = table.indexof(self.data, val)
	return i ~= -1 and i or false
end

function ringbuffer_class:insert_if_not_exists(record)
	if not self:indexof(record) then
		self:insert(record)
	end
end

function ringbuffer_class:serialize()
	return minetest.serialize(self.data)
end

return setmetatable(ringbuffer, ringbuffer_class)
