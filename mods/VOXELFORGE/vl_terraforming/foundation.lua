local abs = math.abs
local max = math.max
local vector_new = vector.new

local is_solid_not_tree = vl_terraforming._is_solid_not_tree
local make_solid_vm = vl_terraforming._make_solid_vm

-- Batch node setting to avoid multiple calls to minetest.set_node
local function batch_set_nodes(nodes_by_name)
    for _, node_group in pairs(nodes_by_name) do
        local positions = node_group.positions
        local total_positions = #positions
        local max_nodes_per_batch = 20000
        local batch_positions = {}
        
        for i = 1, total_positions, max_nodes_per_batch do
            local end_index = math.min(i + max_nodes_per_batch - 1, total_positions)
            batch_positions = {}
            for j = i, end_index do
                table.insert(batch_positions, positions[j])
            end
            minetest.bulk_swap_node(batch_positions, {name = node_group.name})
        end
    end
end

function vl_terraforming.foundation_vm(vm, px, py, pz, sx, sy, sz, corners, surface_mat, platform_mat, stone_mat, dust_mat, pr)
    if sx <= 0 or sy >= 0 or sz <= 0 then return end
    local get_node_at = vm.get_node_at
    local set_node_at = vm.set_node_at
    corners = corners or 0
    local wx2, wz2 = max(sx - corners, 1) ^ -2 * 2, max(sz - corners, 1) ^ -2 * 2
    local cx, cz = px + sx * 0.5 - 0.5, pz + sz * 0.5 - 0.5
    local pos = vector_new(px, py, pz)

    local nodes_by_name = {}

    -- Optimization 2: Precompute values and minimize looping overhead
    local dx_cache = {}  -- Cache for dx calculations to avoid recalculating
    local dz_cache = {}  -- Cache for dz calculations to avoid recalculating

    for xi = px - 1, px + sx do
        local dx2 = max(abs(cx - xi) + 0.51, 0) ^ 2 * wx2
        local dx21 = max(abs(cx - xi) - 0.49, 0) ^ 2 * wx2
        dx_cache[xi] = {dx2 = dx2, dx21 = dx21} -- Store dx values for reuse
        pos.x = xi
        for zi = pz - 1, pz + sz do
            local dz2 = max(abs(cz - zi) + 0.51, 0) ^ 2 * wz2
            local dz21 = max(abs(cz - zi) - 0.49, 0) ^ 2 * wz2
            dz_cache[zi] = {dz2 = dz2, dz21 = dz21} -- Store dz values for reuse
            pos.z = zi

            -- Only proceed if inside valid region
            --if xi >= px and xi < px + sx and zi >= pz and zi < pz + sz then
                if xi >= px and xi < px + sx and zi >= pz and zi < pz + sz and dx_cache[xi].dx2 + dz_cache[zi].dz2 <= 1 then
                    pos.y = py
                    if get_node_at(vm, pos).name ~= "mcl_core:bedrock" then
                        if not nodes_by_name[surface_mat.name] then
                            nodes_by_name[surface_mat.name] = {positions = {}, name = surface_mat.name}
                        end
                        table.insert(nodes_by_name[surface_mat.name].positions, vector_new(pos.x, pos.y, pos.z))

                        if dust_mat then
                            pos.y = py + 1
                            if get_node_at(vm, pos).name == "air" then
                                if not nodes_by_name[dust_mat.name] then
                                    nodes_by_name[dust_mat.name] = {positions = {}, name = dust_mat.name}
                                end
                                table.insert(nodes_by_name[dust_mat.name].positions, vector_new(pos.x, pos.y, pos.z))
                            end
                        end
                        pos.y = py - 1
                        make_solid_vm(vm, pos, platform_mat)
                    end
                elseif dx_cache[xi].dx21 + dz_cache[zi].dz21 <= 1 then
                    pos.y = py - 1
                    if not nodes_by_name[surface_mat.name] then
                            nodes_by_name[surface_mat.name] = {positions = {}, name = surface_mat.name}
                        end
                        table.insert(nodes_by_name[surface_mat.name].positions, vector_new(pos.x, pos.y, pos.z))
                    if dust_mat then
                        pos.y = py
                        if get_node_at(vm, pos).name == "air" then
                            if not nodes_by_name[dust_mat.name] then
                                nodes_by_name[dust_mat.name] = {positions = {}, name = dust_mat.name}
                            end
                            table.insert(nodes_by_name[dust_mat.name].positions, vector_new(pos.x, pos.y, pos.z))
                        end
                    end
                end
            --end
        end
    end

    -- Set all surface and dust nodes in the "nodes_by_name" setting in bulk
    batch_set_nodes(nodes_by_name)

    -- Handle the lower part of the foundation
    for yi = py - 2, py - 20, -1 do
        local dy2 = max(0, py - 1 - yi) ^ 2 * 0.05
        local active = false
        for xi = px - 1, px + sx do
            local dx22 = max(abs(cx - xi) - 1.49, 0) ^ 2 * wx2
            for zi = pz - 1, pz + sz do
                local dz22 = max(abs(cz - zi) - 1.49, 0) ^ 2 * wz2
                if dx22 + dy2 + dz22 <= 1 then
                    active = true
                    -- Randomly decide per block whether to set stone_mat
                    local current_platform_mat = platform_mat
                    if pr:next(1, 4) == 1 then
                        current_platform_mat = stone_mat
                    end

                    -- Randomly pick one out of every 9 blocks to ignore
                    if pr:next(1, 9) ~= 1 then
                        if not nodes_by_name[current_platform_mat.name] then
                            nodes_by_name[current_platform_mat.name] = {positions = {}, name = current_platform_mat.name}
                        end
                        table.insert(nodes_by_name[current_platform_mat.name].positions, vector_new(xi, yi, zi))
                    end
                end
            end
        end
        if not active and yi < py + sy then
            minetest.log("error", "Stopping foundation construction at yi=" .. yi)
            break
        end
    end

    -- Perform bulk set node for foundation
    batch_set_nodes(nodes_by_name)
end
