local S = minetest.get_translator(modpath)
minetest.register_node("vlf_tripwire:tripwire", {
	description = S("Tripwire"),
	tiles = {"tripwire.png"},
	paramtype2 = "4dir",
	groups = {dig_immediate = 2, choppy = 3, meta_is_privatizable = 1},
	drawtype = "nodebox",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	walkable = false,
	pointable = true,
	drop = "vlf_tripwire:tripwire",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.4, -0.5, 0.5, -0.4, 0.5},
		},
	},
})

minetest.register_node("vlf_tripwire:tripwire_hook", {
	description = S("Tripwire Hook"),
	drawtype = "mesh",
	use_texture_alpha = "clip",
	paramtype2 = "4dir",
	mesh = "tripwire_hook.obj",
	tiles = {"tripwire_hook.png"},
	visual_scale = "0.5",
	sunlight_propagates = true,
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(0.25)
	end,
	on_timer = function(pos, elapsed)
		vlf_redstone.update_node(pos)  -- Replaces mesecon.receptor_off
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
	_vlf_redstone = {
		connects_to = function(node, dir)
			return true
		end,
		get_power = function(node, dir)
			return 0, false
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
	local paramtype2 = minetest.get_node(pos).param2
	local paramtype2_pos2 = minetest.get_node(pos2).param2
	vlf_redstone.swap_node(pos, {name = "vlf_tripwire:tripwire_hook_on", param2=paramtype2})  -- Replaces minetest.set_node
	vlf_redstone.swap_node(pos2, {name = "vlf_tripwire:tripwire_hook_on", param2=paramtype2_pos2})  -- Replaces minetest.set_node
	local meta = minetest.get_meta(pos)
	meta:set_string("connected", minetest.write_json(pos2))
	meta = minetest.get_meta(pos2)
	meta:set_string("connected", minetest.write_json(pos))
end

--[[function detect_entities_and_activate(pos, connected)
	local distance = vector.distance(pos, connected)
	local objs = minetest.get_objects_inside_radius(pos, distance)
	for _, obj in ipairs(objs) do
		local obj_pos = obj:get_pos()
		if is_entity_between(pos, connected, obj_pos) then
			local param2 = minetest.get_node(pos).param2
			minetest.set_node(pos, {name="vlf_tripwire:tripwire_hook_active", param2=param2})
			local param2_connect = minetest.get_node(connected).param2
			minetest.set_node(pos, {name="vlf_tripwire:tripwire_hook_active", param2=param2_connect})
		end
	end
end]]

--[[function detect_entities_and_activate(pos, connected)
    local distance = vector.distance(pos, connected)
    local objs = minetest.get_objects_inside_radius(pos, distance)
    
    for _, obj in ipairs(objs) do
        local obj_pos = obj:get_pos()
        
        -- Check if the entity is positioned correctly between the hooks
        if is_entity_between(pos, connected, obj_pos) then
            local pos_node = minetest.get_node(pos)
            local connected_node = minetest.get_node(connected)
            
            -- Check if we are in the right state to activate the second hook
           -- if connected_node.name == "vlf_tripwire:tripwire_hook_on" then
                -- Activate the second hook and ensure it's in the active state
                minetest.set_node(connected, {name="vlf_tripwire:tripwire_hook_active", param2=connected_node.param2})
            --end

            -- Ensure the first hook transitions to the active state (if not already)
            --if pos_node.name == "vlf_tripwire:tripwire_hook_on" then
                minetest.set_node(pos, {name="vlf_tripwire:tripwire_hook_active", param2=pos_node.param2})
            --end
        else
        	local pos_node = minetest.get_node(pos)
                local connected_node = minetest.get_node(connected)
        	minetest.set_node(pos, {name="vlf_tripwire:tripwire_hook_on", param2=pos_node.param2})
        	minetest.set_node(connected, {name="vlf_tripwire:tripwire_hook_on", param2=connected_node.param2})
        end
    end
end]]

function detect_entities_and_activate(pos, connected)
	local distance = vector.distance(pos, connected)
	local objs = minetest.get_objects_inside_radius(pos, distance)
	for _, obj in ipairs(objs) do
		local obj_pos = obj:get_pos()
		if is_entity_between(pos, connected, obj_pos) then
			--mesecon.receptor_on(pos, mesecon.rules.alldirs)
			update_neighbours(pos)
		end
	end
end


minetest.register_node("vlf_tripwire:tripwire_hook_on", {
	drawtype = "mesh",
	use_texture_alpha = "clip",
	description = S("Tripwire Hook On"),
	paramtype2 = "4dir",
	visual_scale = "0.5",
	sunlight_propagates = true,
	mesh = "tripwire_hook_on.obj",
	tiles = {"tripwire_hook_on.png"},
	groups = {not_in_creative_inventory = 1},
	drop = "vlf_tripwire:tripwire_hook",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("connected", minetest.write_json({x = 0, y = 0, z = 0}))
		minetest.get_node_timer(pos):start(0.25)
	end,
	on_timer = function(pos, elapsed)
		--vlf_redstone.get_power(pos, dir)
		--vlf_redstone.update_node(pos)
		local meta = minetest.get_meta(pos)
		local connected = minetest.parse_json(meta:get_string("connected"))
		if minetest.get_node(connected).name ~= "vlf_tripwire:tripwire_hook_on" then
			local paramtype2 = minetest.get_node(pos).param2
			minetest.set_node(pos, {name = "vlf_tripwire:tripwire_hook", param2=paramtype2})
			--mesecon.receptor_off(pos, mesecon.rules.alldirs)
		else
			detect_entities_and_activate(pos, connected)
		end
		minetest.get_node_timer(pos):start(0.25)
	end,
	_vlf_redstone = {
		connects_to = function(node, dir)
			return true
		end,
		get_power = function(node, dir)
			return 0, false
		end,
	},
})

minetest.register_node("vlf_tripwire:tripwire_hook_active", {
	drawtype = "mesh",
	use_texture_alpha = "clip",
	description = S("Tripwire Hook On"),
	paramtype2 = "4dir",
	visual_scale = "0.5",
	sunlight_propagates = true,
	mesh = "tripwire_hook_on.obj",
	tiles = {"tripwire_hook_on.png"},
	groups = {not_in_creative_inventory = 1},
	drop = "vlf_tripwire:tripwire_hook",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("connected", minetest.write_json({x = 0, y = 0, z = 0}))
		minetest.get_node_timer(pos):start(0.25)
	end,
	on_timer = function(pos, elapsed)
		vlf_redstone.update_node(pos)  -- Replaces mesecon.receptor_off
		local meta = minetest.get_meta(pos)
		local connected = minetest.parse_json(meta:get_string("connected"))
		--[[if minetest.get_node(connected).name ~= "vlf_tripwire:tripwire_hook_on" then
			local paramtype2 = minetest.get_node(pos).param2
			vlf_redstone.swap_node(pos, {name = "vlf_tripwire:tripwire_hook", param2=paramtype2})  -- Replaces minetest.set_node
		else]]
			detect_entities_and_activate(pos, connected)
		--end
		minetest.get_node_timer(pos):start(0.25)
	end,
	_vlf_redstone = {
		connects_to = function(node, dir)
			return true
		end,
		get_power = function(node, dir)
			return 15
		end,
	},
})

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

-- Define the grappling hook item
minetest.register_craftitem(":mod:grappling_hook", {
    description = "Grappling Hook",
    inventory_image = "grappling_hook.png",

    on_use = function(itemstack, user, pointed_thing)
        local player_name = user:get_player_name()
        local pos = user:get_pos()
        local dir = user:get_look_dir()
        local hook_pos = vector.add(pos, vector.multiply(dir, 2))

        -- Create the hook entity
        local hook = minetest.add_entity(hook_pos, "mod:grappling_hook_entity")
        if not hook then
            return
        end

        local hook_ent = hook:get_luaentity()
        if hook_ent then
            hook_ent.owner = player_name
            hook_ent.start_pos = pos
            hook_ent.velocity = vector.multiply(dir, 20) -- Hook speed
        end

        -- Reduce item durability (optional)
        itemstack:add_wear(65535 / 100) -- Adjust durability
        return itemstack
    end,
})

-- Define the hook entity
minetest.register_entity(":mod:grappling_hook_entity", {
    initial_properties = {
        physical = false,
        collide_with_objects = false,
        pointable = false,
        visual = "cube",
        textures = {"hook_texture.png", "hook_texture.png", "hook_texture.png", "hook_texture.png", "hook_texture.png", "hook_texture.png"},
        visual_size = {x = 0.2, y = 0.2},
    },

    owner = nil,
    start_pos = nil,
    velocity = nil,
    attached = false,
    target_pos = nil,

    on_step = function(self, dtime)
        local pos = self.object:get_pos()

        if self.attached then
            -- Handle player reeling and swinging
            if self.owner then
            local player = minetest.get_player_by_name(self.owner)
            if player then
                local player_pos = player:get_pos()
                local rope_dir = vector.direction(player_pos, self.target_pos)

                -- Reel in or swing based on player input
                if player:get_player_control().jump then
                    local reel_speed = 5
                    player:add_velocity(vector.multiply(rope_dir, reel_speed * dtime))
                elseif player:get_player_control().sneak then
                    -- Swinging effect
                    local swing_force = vector.new(-rope_dir.z, 0, rope_dir.x)
                    player:add_velocity(vector.multiply(swing_force, 2 * dtime))
                end
            end
            end
        else
            -- Move hook until it hits a node or maximum range
            local velocity = self.velocity
            if self.object and self.velocity then
            	self.object:set_velocity(velocity)
        end

            if minetest.get_node(pos).name ~= "air" then
                -- Attach hook
                self.attached = true
                self.target_pos = pos
                self.object:set_velocity(vector.new(0, 0, 0))
                self.object:set_acceleration(vector.new(0, 0, 0))
            end
        end

        -- Destroy the hook if it exceeds range
        if self.start_pos and vector.distance(self.start_pos, pos) > 50 then
            self.object:remove()
        end
    end,

    on_activate = function(self, staticdata, dtime_s)
        self.object:set_acceleration(vector.new(0, -9.8, 0))
    end,
})

-- Add a rope particle effect (optional)
minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        local wielded_item = player:get_wielded_item():get_name()
        if wielded_item == "mod:grappling_hook" then
            local pos = player:get_pos()
            local hook_entities = minetest.get_objects_inside_radius(pos, 50)

            for _, obj in ipairs(hook_entities) do
                local ent = obj:get_luaentity()
                if ent and ent.name == "mod:grappling_hook_entity" and ent.owner == player:get_player_name() then
                    minetest.add_particle({
                        pos = pos,
                        velocity = vector.new(0, 0, 0),
                        acceleration = vector.new(0, 0, 0),
                        expirationtime = 0.1,
                        size = 2,
                        texture = "rope_texture.png",
                        glow = 10,
                    })
                end
            end
        end
    end
end)

