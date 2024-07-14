--[[local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local function debug(f)
    minetest.log("warning", f)
end

local function is_occupied(state, pos)
    return state.occupied[tostring(pos)]
end

local function set_occupied(state, pos)
    state.occupied[tostring(pos)] = true
end

local function is_in_bounds(state, pos)
    local struct = state.struct

    if pos.x < 0 or pos.x >= struct.grid_limit.x then return false end
    if pos.y < 0 or pos.y >= struct.grid_limit.y then return false end
    if pos.z < 0 or pos.z >= struct.grid_limit.z then return false end

    return true
end

local function rotate_rule(rule, rot)
    if rot == 0 then
        return rule
    elseif rot == 2 then
        return {
            groups = rule.groups,
            dir = -rule.dir,
            pos = rule.pos
        }
    end

    return rule
end

local function rotate_rules(rules, rot)
    local new_rules = {}
    for i, rule in ipairs(rules) do
        new_rules[i] = rotate_rule(rule, rot)
    end
    return new_rules
end

local function does_rule_match(conditions, rule)
    local rotated = rotate_rule(conditions, 2)

    if rotated.dir ~= rule.dir then return false end
    for k, v in pairs(conditions.groups or {}) do
        if rule.groups and rule.groups[k] == v then return true end
    end

    return false
end

local function add_node_pos(state, rule, new_grid_pos)
    if not state:is_in_bounds(new_grid_pos) then
        debug(tostring(new_grid_pos).." is out of bounds")
        return
    end
    if state:is_occupied(new_grid_pos) then
        debug(tostring(new_grid_pos).." is already occupied")
        return
    end

    for _, n in ipairs(state.nodes) do
        if n.pos == new_grid_pos then
            n.rules[#n.rules + 1] = rule
            return
        end
    end

    state.nodes[#state.nodes + 1] = { pos = new_grid_pos, rules = { rule } }
    debug("adding "..tostring(new_grid_pos))
end

local function place_part(state, idx, rot, grid_pos)
    if not grid_pos or type(grid_pos) ~= "table" then
        debug("Invalid grid_pos: " .. tostring(grid_pos))
        return
    end

    local root_pos = state.root_pos
    local struct = state.struct
    local part = struct.parts[idx]

    for x = 1, part.size.x do
        for y = 1, part.size.y do
            for z = 1, part.size.z do
                local pn = vector.offset(grid_pos, x-1, y-1, z-1)
                if state:is_occupied(pn) then return end
                if not state:is_in_bounds(pn) then return end
            end
        end
    end

    debug("Placing part #"..tostring(idx).." ("..part.file..") at grid_pos="..tostring(grid_pos)..", root_pos="..tostring(root_pos))
    local pos = root_pos + vector.new(
        grid_pos.x * struct.grid_size.x,
        grid_pos.y * struct.grid_size.y,
        grid_pos.z * struct.grid_size.z
    )
    minetest.place_schematic(pos, modpath.."/schems/".. struct.name .. "/" .. part.file, ({"0","90","180","270"})[rot], nil, false)

    if part.after_place then
        part.after_place(state, pos)
    end

    if part.loot then
        local p2 = pos + struct.grid_size
        vlf_structures.fill_chests(pos, p2, part.loot or struct.loot, state.pr)
    end

    for x = 1, part.size.x do
        for y = 1, part.size.y do
            for z = 1, part.size.z do
                local pn = vector.offset(grid_pos, x-1, y-1, z-1)
                state:set_occupied(pn)
            end
        end
    end

    for _, rule in ipairs(part.rules or {}) do
        state:add_node_pos(rule, grid_pos + (rule.dir or vector.new(0,0,0)) + (rule.pos or vector.new(0,0,0)))
    end
end

local function do_part_rules_contain(part_rules, rule)
    for _, r in ipairs(part_rules) do
        if does_rule_match(rule, r) then return true end
    end

    return false
end

local function do_part_rules_match(state, pid, rot, node)
    local part_rules = state.struct.parts[pid].rules or {}

    if node.rules then
        for _, r in ipairs(node.rules) do
            if not do_part_rules_contain(part_rules, r) then
                debug("No match for rule")
                debug(dump(r))
                debug(dump(part_rules))
                return false
            end
        end
    end

    return true
end

local function select_part(state, node)
    local pr = state.pr
    local struct = state.struct

    local possible_parts = {}
    local total_weight = 0

    debug("node="..dump(node))
    for i, part in ipairs(struct.parts) do
        debug("checking "..part.file)
        local valid_part = true

        if part.can_use and not part.can_use(state) then
            debug("can't use")
            valid_part = false
        end
        if not do_part_rules_match(state, i, 0, node) then valid_part = false end

        if valid_part then
            debug("possible part: "..tostring(part.file))
            possible_parts[#possible_parts + 1] = { i = i, part = part }
            total_weight = total_weight + (part.weight or 1)
        end
    end

    if total_weight == 0 then return 0, 0 end

    local w = pr:next(1, total_weight)
    for _, p in ipairs(possible_parts) do
        if w <= (p.part.weight or 1) then
            return p.i, 0
        end

        w = w - (p.part.weight or 1)
    end

    return 0, 0
end

function vlf_procedural_structures:place(name, root_pos, seed)
    local state = {
        root_pos = root_pos,
        occupied = {},
        nodes = {},
        user = {},

        is_occupied = is_occupied,
        set_occupied = set_occupied,
        is_in_bounds = is_in_bounds,
        place_part = place_part,
        select_part = select_part,
        add_node_pos = add_node_pos,
    }

    local struct = self.structures[name]
    if not struct then return end
    state.struct = struct

    if struct.before_place then struct.before_place(state) end

    if #state.nodes == 0 then
        state.nodes[1] = { pos = vector.new(0, 0, 0) }
    end

    local pr = PseudoRandom(seed)
    state.pr = pr

    local nodes = state.nodes
    while #nodes > 0 do
        debug("Nodes remaining: "..tostring(#nodes))
        local j = pr:next(1, #nodes)
        local node = nodes[j]
        if j ~= #nodes then
            nodes[j] = nodes[#nodes]
        end
        nodes[#nodes] = nil

        if not state:is_occupied(node.pos) then
            local id, rot = state:select_part(node)
            state:place_part(id, rot, node.pos)
        end
    end
end]]

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local function debug(f)
    minetest.log("warning", f)
end

local function is_occupied(state, pos)
    return state.occupied[tostring(pos)]
end

local function set_occupied(state, pos)
    state.occupied[tostring(pos)] = true
end

local function is_in_bounds(state, pos)
    local struct = state.struct

    if pos.x < 0 or pos.x >= struct.grid_limit.x then return false end
    if pos.y < 0 or pos.y >= struct.grid_limit.y then return false end
    if pos.z < 0 or pos.z >= struct.grid_limit.z then return false end

    return true
end

local function rotate_rule(rule, rot)
    if rot == 0 then
        return rule
    elseif rot == 2 then
        return {
            groups = rule.groups,
            dir = -rule.dir,
            pos = rule.pos
        }
    end

    return rule
end

local function rotate_rules(rules, rot)
    local new_rules = {}
    for i, rule in ipairs(rules) do
        new_rules[i] = rotate_rule(rule, rot)
    end
    return new_rules
end

local function does_rule_match(conditions, rule)
    local rotated = rotate_rule(conditions, 2)

    if rotated.dir ~= rule.dir then return false end
    for k, v in pairs(conditions.groups or {}) do
        if rule.groups and rule.groups[k] == v then return true end
    end

    return false
end

local function add_node_pos(state, rule, new_grid_pos)
    if not state:is_in_bounds(new_grid_pos) then
        debug(tostring(new_grid_pos).." is out of bounds")
        return
    end
    if state:is_occupied(new_grid_pos) then
        debug(tostring(new_grid_pos).." is already occupied")
        return
    end

    for _, n in ipairs(state.nodes) do
        if n.pos == new_grid_pos then
            n.rules[#n.rules + 1] = rule
            return
        end
    end

    state.nodes[#state.nodes + 1] = { pos = new_grid_pos, rules = { rule } }
    debug("adding "..tostring(new_grid_pos))
end

local function place_part(state, idx, rot, grid_pos)
    if not grid_pos or type(grid_pos) ~= "table" then
        debug("Invalid grid_pos: " .. tostring(grid_pos))
        return
    end

    local root_pos = state.root_pos
    local struct = state.struct
    local part = struct.parts[idx]

    for x = 1, part.size.x do
        for y = 1, part.size.y do
            for z = 1, part.size.z do
                local pn = vector.offset(grid_pos, x-1, y-1, z-1)
                if state:is_occupied(pn) then
                    debug("Position "..tostring(pn).." is already occupied.")
                    return
                end
                if not state:is_in_bounds(pn) then
                    debug("Position "..tostring(pn).." is out of bounds.")
                    return
                end
            end
        end
    end

    debug("Placing part #"..tostring(idx).." ("..part.file..") at grid_pos="..tostring(grid_pos)..", root_pos="..tostring(root_pos))
    local pos = root_pos + vector.new(
        grid_pos.x * struct.grid_size.x,
        grid_pos.y * struct.grid_size.y,
        grid_pos.z * struct.grid_size.z
    )
    minetest.place_schematic(pos, modpath.."/schems/".. struct.name .. "/" .. part.file, ({"0","90","180","270"})[rot], nil, false)

    if part.after_place then
        part.after_place(state, pos)
    end

    if part.loot then
        local p2 = pos + struct.grid_size
        vlf_structures.fill_chests(pos, p2, part.loot or struct.loot, state.pr)
    end

    for x = 1, part.size.x do
        for y = 1, part.size.y do
            for z = 1, part.size.z do
                local pn = vector.offset(grid_pos, x-1, y-1, z-1)
                state:set_occupied(pn)
            end
        end
    end

    for _, rule in ipairs(part.rules or {}) do
        state:add_node_pos(rule, grid_pos + (rule.dir or vector.new(0,0,0)) + (rule.pos or vector.new(0,0,0)))
    end
end

local function do_part_rules_contain(part_rules, rule)
    for _, r in ipairs(part_rules) do
        if does_rule_match(rule, r) then return true end
    end

    return false
end

local function do_part_rules_match(state, pid, rot, node)
    local part_rules = state.struct.parts[pid].rules or {}

    if node.rules then
        for _, r in ipairs(node.rules) do
            if not do_part_rules_contain(part_rules, r) then
                debug("No match for rule")
                debug(dump(r))
                debug(dump(part_rules))
                return false
            end
        end
    end

    return true
end

local function select_part(state, node)
    local pr = state.pr
    local struct = state.struct

    local possible_parts = {}
    local total_weight = 0

    debug("node="..dump(node))
    for i, part in ipairs(struct.parts) do
        debug("checking "..part.file)
        local valid_part = true

        if part.can_use and not part.can_use(state) then
            debug("can't use")
            valid_part = false
        end
        if not do_part_rules_match(state, i, 0, node) then valid_part = false end

        if valid_part then
            debug("possible part: "..tostring(part.file))
            possible_parts[#possible_parts + 1] = { i = i, part = part }
            total_weight = total_weight + (part.weight or 1)
        end
    end

    if total_weight == 0 then return 0, 0 end

    local w = pr:next(1, total_weight)
    for _, p in ipairs(possible_parts) do
        if w <= (p.part.weight or 1) then
            return p.i, 0
        end

        w = w - (p.part.weight or 1)
    end

    return 0, 0
end

function vlf_procedural_structures:place(name, root_pos, seed)
    local state = {
        root_pos = root_pos,
        occupied = {},
        nodes = {},
        user = {},

        is_occupied = is_occupied,
        set_occupied = set_occupied,
        is_in_bounds = is_in_bounds,
        place_part = place_part,
        select_part = select_part,
        add_node_pos = add_node_pos,
    }

    local struct = self.structures[name]
    if not struct then
        debug("No structure found with name: " .. tostring(name))
        return
    end
    state.struct = struct

    if struct.before_place then struct.before_place(state) end

    if #state.nodes == 0 then
        state.nodes[1] = { pos = vector.new(0, 0, 0) }
    end

    local pr = PseudoRandom(seed)
    state.pr = pr

    local nodes = state.nodes
    while #nodes > 0 do
        debug("Nodes remaining: "..tostring(#nodes))
        local j = pr:next(1, #nodes)
        local node = nodes[j]
        if j ~= #nodes then
            nodes[j] = nodes[#nodes]
        end
        nodes[#nodes] = nil

        if not state:is_occupied(node.pos) then
            local id, rot = state:select_part(node)
            if id ~= 0 then
                state:place_part(id, rot, node.pos)
            else
                debug("No valid part found for node: " .. tostring(node.pos))
            end
        end
    end
end

