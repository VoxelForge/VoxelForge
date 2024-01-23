mcl_player = {
	registered_player_models = {},
	registered_globalsteps = {},
	registered_globalsteps_slow = {},
	registered_on_visual_change = {},
	players = {},
}

local tpl_playerinfo = {
	textures = { "character.png", "blank.png", "blank.png" },
	model = "",
	animation = "",
	sneak = false,
	visible = true,
	attached = false,
	elytra = {active = false, rocketing = 0, speed = 0},
	is_pressing_jump = {},
	lastPos = nil,
	swimDistance = 0,
	jump_cooldown = -1,	-- Cooldown timer for jumping, we need this to prevent the jump exhaustion to increase rapidly
	vel_yaw = nil,
	is_swimming = false,
	nodes = {
		stand = "",
		stand_below = "",
		head = "",
		feet = "",
		head_top = "",
	},
}

local nodeinfo_pos = {
	stand =       vector.new(0, -0.1, 0),
	stand_below = vector.new(0, -1.1, 0),
	head =        vector.new(0, 1.5, 0),
	head_top =    vector.new(0, 2, 0),
	feet =        vector.new(0, 0.3, 0),
}

local slow_gs_timer = 0.5

minetest.register_on_joinplayer(function(player)
	mcl_player.players[player] = table.copy(tpl_playerinfo)
	player:get_inventory():set_size("hand", 1)
	--player:set_local_animation({x=0, y=79}, {x=168, y=187}, {x=189, y=198}, {x=200, y=219}, 30)
	player:set_fov(86.1) -- see <https://minecraft.gamepedia.com/Options#Video_settings>>>>

	-- Minetest bug: get_bone_position() returns all zeros vectors.
	-- Workaround: call set_bone_position() one time first.
	player:set_bone_position("Head_Control", vector.new(0, 6.75, 0))
	player:set_bone_position("Arm_Right_Pitch_Control", vector.new(-3, 5.785, 0))
	player:set_bone_position("Arm_Left_Pitch_Control", vector.new(3, 5.785, 0))
	player:set_bone_position("Body_Control", vector.new(0, 6.75, 0))
end)

minetest.register_on_leaveplayer(function(player)
	mcl_player.players[player] = nil
end)

local function node_ok(pos, fallback)
	fallback = fallback or "air"
	local node = minetest.get_node_or_nil(pos)
	if not node then
		return fallback
	end
	if minetest.registered_nodes[node.name] then
		return node.name
	end
	return fallback
end

function mcl_player.register_globalstep(func)
	table.insert(mcl_player.registered_globalsteps, func)
end

function mcl_player.register_globalstep_slow(func)
	table.insert(mcl_player.registered_globalsteps, func)
end

function mcl_player.player_register_model(name, def)
	mcl_player.registered_player_models[name] = def
end

function mcl_player.register_on_visual_change(func)
	table.insert(mcl_player.registered_on_visual_change, func)
end

-- Check each player and run callbacks
minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		for _, func in pairs(mcl_player.registered_globalsteps) do
			func(player, dtime)
		end
	end

	slow_gs_timer = slow_gs_timer - dtime
	if slow_gs_timer > 0 then return end
	slow_gs_timer = 0.5
	for _, player in pairs(minetest.get_connected_players()) do
		for _, func in pairs(mcl_player.registered_globalsteps_slow) do
			func(player, dtime)
		end
	end
end)

mcl_player.register_globalstep_slow(function(player, dtime)
	for k, v in pairs(nodeinfo_pos) do
		mcl_player.players[player].nodes[k] = node_ok(vector.add(player:get_pos(), v))
	end
end)

dofile(minetest.get_modpath(minetest.get_current_modname()).."/animations.lua")
