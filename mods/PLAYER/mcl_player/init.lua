mcl_player = {
	registered_globalsteps = {},
	registered_globalsteps_slow = {},
	players = {},
}

local default_fov = 86.1 --see <https://minecraft.gamepedia.com/Options#Video_settings>>>>

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
	nodes = {},
}

local nodeinfo_pos = { --offset positions of the "nodeinfo" nodes.
	stand =       vector.new(0, -0.1, 0),
	stand_below = vector.new(0, -1.1, 0),
	head =        vector.new(0, 1.5, 0),
	head_top =    vector.new(0, 2, 0),
	feet =        vector.new(0, 0.3, 0),
}

-- Minetest bug: get_bone_position() returns all zeros vectors.
-- Workaround: call set_bone_position() one time first.
-- (Set in on_joinplayer)
local bone_start_positions = {
	Head_Control =            vector.new(0, 6.75, 0),
	Arm_Right_Pitch_Control = vector.new(-3, 5.785, 0),
	Arm_Left_Pitch_Control =  vector.new(3, 5.785, 0),
	Body_Control =            vector.new(0, 6.75, 0),
}

for k, _ in pairs(nodeinfo_pos) do
	tpl_playerinfo.nodes[k] = ""
end

local slow_gs_timer = 0.5

minetest.register_on_joinplayer(function(player)
	mcl_player.players[player] = table.copy(tpl_playerinfo)
	player:get_inventory():set_size("hand", 1)
	player:set_fov(default_fov)
	for bone, pos in pairs(bone_start_positions) do
		player:set_bone_position(bone, pos)
	end
end)

minetest.register_on_leaveplayer(function(player)
	mcl_player.players[player] = nil
end)

local function node_ok(pos, fallback)
	local node = minetest.get_node_or_nil(pos)
	if node and node.name and minetest.registered_nodes[node.name] then
		return node.name
	end
	return fallback or "air"
end

function mcl_player.register_globalstep(func)
	table.insert(mcl_player.registered_globalsteps, func)
end

function mcl_player.register_globalstep_slow(func)
	table.insert(mcl_player.registered_globalsteps, func)
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
		mcl_player.players[player].lastPos = player:get_pos()
	end
end)

mcl_player.register_globalstep_slow(function(player, dtime)
	for k, v in pairs(nodeinfo_pos) do
		mcl_player.players[player].nodes[k] = node_ok(vector.add(player:get_pos(), v))
	end
end)

dofile(minetest.get_modpath(minetest.get_current_modname()).."/animations.lua")
