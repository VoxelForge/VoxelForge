-- register extra flavours of a base nodedef
walkover = {}

local on_walk = {}
local on_walk_through = {}
local registered_globals = {}

walkover.registered_globals = registered_globals

function walkover.register_global(func)
	table.insert(registered_globals, func)
end

minetest.register_on_mods_loaded(function()
	for name,def in pairs(minetest.registered_nodes) do
		if def.on_walk_over then
			on_walk[name] = def.on_walk_over
		end
		if def.on_walk_through then
			on_walk_through[name] = def._on_walk_through
		end
	end
end)

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer >= 0.6 then
		for _, player in pairs(minetest.get_connected_players()) do
			local pos = player:get_pos()
			local npos = vector.offset(pos, 0, -0.1, 0)
			local node = minetest.get_node(npos)
			if on_walk[mcl_player.players[player].nodes.stand] then
				on_walk[node.name](npos, node, player)
			end
			for i = 1, #registered_globals do
				registered_globals[i](npos, node, player)
			end
			if on_walk_through[mcl_player.players[player].nodes.feet] then
				local npos = vector.offset(pos, 0, 0.3, 0)
				on_walk_through[mcl_player.players[player].nodes.feet](npos, minetest.get_node(npos), player)
			end
			if on_walk_through[mcl_player.players[player].nodes.head] then
				local npos = vector.offset(pos, 0, 1.5, 0)
				on_walk_through[mcl_player.players[player].nodes.head](npos, minetest.get_node(npos), player)
			end
		end
		timer = 0
	end
end)
