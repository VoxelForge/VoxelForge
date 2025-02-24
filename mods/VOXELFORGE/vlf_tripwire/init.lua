minetest.register_node("vlf_tripwire:tripwire", {
    description = "Tripwire",
    tiles = {"tripwire.png"},
    paramtype2 = "4dir",
    groups = {dig_immediate = 2, choppy = 3, meta_is_privatizable = 1},
    drawtype = "nodebox",
    sunlight_propagates = true,
    walkable = false,
    pointable = true,
    drop = "vlf_tripire:tripwire",
    use_texture_alpha = "clip",
    node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.4, -0.5, 0.5, -0.4, 0.5},
		},
	},
})

minetest.register_node("vlf_tripwire:tripwire_hook", {
    description = "Tripwire Hook",
    drawtype = "mesh",
    mesh = "tripwire_hook.obj",
    paramtype2 = "4dir",
	tiles = {"tripwire_hook.png"},
	use_texture_alpha = "clip",
    on_construct = function(pos)
        minetest.get_node_timer(pos):start(0.25)
    end,
    on_timer = function(pos, elapsed)
        --mesecon.receptor_off(pos, mesecon.rules.alldirs)

        for _, dir in ipairs({"x", "y", "z"}) do
            for _, sign in ipairs({1, -1}) do
                local offset = {x = 0, y = 0, z = 0}
                offset[dir] = sign
                local p = vector.add(pos, offset)
                if minetest.get_node(p).name == "vlf_tripwire:tripwire" then
                    if is_felt(pos, offset) then
                        local connected_pos = find_connected_tripwire(pos, offset)
                        tripwire_on(pos, connected_pos)
                    end
                end
            end
        end
        minetest.get_node_timer(pos):start(0.25)
    end,
    _mcl_redstone = {
			get_power = function(node, dir)
				return 0
			end,
		},
})

function is_felt(pos, dir)
    local node = minetest.get_node(pos)
    if node.name == "vlf_tripwire:tripwire_hook" then
        pos = vector.add(pos, dir)
        local limit = 0
        while minetest.get_node(pos).name == "vlf_tripwire:tripwire" do
            pos = vector.add(pos, dir)
            limit = limit + 1
            if limit > 20 then
                return false
            end
        end
        return minetest.get_node(pos).name == "vlf_tripwire:tripwire_hook"
    end
    return false
end

function find_connected_tripwire(pos, dir)
    pos = vector.add(pos, dir)
    while minetest.get_node(pos).name == "vlf_tripwire:tripwire" do
        pos = vector.add(pos, dir)
    end
    return pos
end

function tripwire_on(pos, pos2)
    minetest.set_node(pos, {name = "vlf_tripwire:tripwire_hook_on"})
    minetest.set_node(pos2, {name = "vlf_tripwire:tripwire_hook_on"})
    local meta = minetest.get_meta(pos)
    meta:set_string("connected", minetest.write_json(pos2))
    meta = minetest.get_meta(pos2)
    meta:set_string("connected", minetest.write_json(pos))
end

minetest.register_node("vlf_tripwire:tripwire_hook_on", {
    description = "Tripwire Hook On",
    drawtype = "mesh",
    paramtype2 = "4dir",
    mesh = "tripwire_hook_on.obj",
	tiles = {"tripwire_hook_on.png"},
	use_texture_alpha = "clip",
    groups = {not_in_creative_inventory = 1},
    drop = "vlf_tripwire:tripwire",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("connected", minetest.write_json({x = 0, y = 0, z = 0}))
        minetest.get_node_timer(pos):start(0.25)
    end,
    on_timer = function(pos, elapsed)
        --mesecon.receptor_off(pos, mesecon.rules.alldirs)
        local meta = minetest.get_meta(pos)
        local connected = minetest.parse_json(meta:get_string("connected"))

        if minetest.get_node(connected).name ~= "vlf_tripwire:tripwire_hook_on" then
            minetest.set_node(pos, {name = "vlf_tripwire:tripwire_hook"})
            --mesecon.receptor_off(pos, mesecon.rules.alldirs)
        else
            detect_entities_and_activate(pos, connected)
        end
        minetest.get_node_timer(pos):start(0.25)
    end,
    _mcl_redstone = {
			get_power = function(node, dir)
				return 0
			end,
		},
})

minetest.register_node("vlf_tripwire:tripwire_hook_active", {
    description = "Tripwire Hook Active",
    drawtype = "mesh",
    paramtype2 = "4dir",
    mesh = "tripwire_hook_active.obj",
	tiles = {"tripwire_hook_on.png"},
	use_texture_alpha = "clip",
    groups = {not_in_creative_inventory = 1},
    drop = "vlf_tripwire:tripwire",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("connected", minetest.write_json({x = 0, y = 0, z = 0}))
        minetest.get_node_timer(pos):start(0.25)
    end,
    on_timer = function(pos, elapsed)
        local meta = minetest.get_meta(pos)
        local connected = minetest.parse_json(meta:get_string("connected"))

        if minetest.get_node(connected).name ~= "vlf_tripwire:tripwire_hook_active" then
            minetest.set_node(pos, {name = "vlf_tripwire:tripwire_hook"})
        else
            detect_entities_and_activate(pos, connected)
        end
        minetest.get_node_timer(pos):start(0.25)
    end,
    _mcl_redstone = {
			get_power = function(node, dir)
				return 15
			end,
		},
})

function detect_entities_and_activate(pos, connected)
    local distance = vector.distance(pos, connected)
    local objs = minetest.get_objects_inside_radius(pos, distance)
    for _, obj in ipairs(objs) do
        local obj_pos = obj:get_pos()
        if is_entity_between(pos, connected, obj_pos) then
            --mesecon.receptor_on(pos, mesecon.rules.alldirs)
            minetest.set_node(pos, {name="vlf_tripwire:tripwire_hook_active"})
            minetest.set_node(connected, {name="vlf_tripwire:tripwire_hook_active"})
        end
    end
end

function is_entity_between(pos1, pos2, entity_pos)
    local x_within = (math.min(pos1.x, pos2.x) - 0.5 <= entity_pos.x) and (entity_pos.x <= math.max(pos1.x, pos2.x) + 0.5)
    local y_within = (math.min(pos1.y, pos2.y) - 1.5 <= entity_pos.y) and (entity_pos.y <= math.max(pos1.y, pos2.y) + 0.5)
    local z_within = (math.min(pos1.z, pos2.z) - 0.5 <= entity_pos.z) and (entity_pos.z <= math.max(pos1.z, pos2.z) + 0.5)
    return x_within and y_within and z_within
end

minetest.register_craft({
    output = "vlf_tripwire:tripwire 12",
    recipe = {
        {"group:wool"},
        {"group:wool"},
        {"group:wool"},
    }
})

minetest.register_craft({
    output = "vlf_tripwire:tripwire_hook 2",
    recipe = {
        {"group:wood", "vlf_tripwire:tripwire", "group:wood"},
        {"group:wood", "vlf_tripwire:tripwire", "group:wood"},
        {"group:wood", "vlf_tripwire:tripwire", "group:wood"},
    }
})
