local json = {}

function json.decode(str)
    local success, result = pcall(function()
        return minetest.parse_json(str)
    end)
    if success then
        return result
    else
        return nil
    end
end

return json


