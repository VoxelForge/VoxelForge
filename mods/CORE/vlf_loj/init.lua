--===============================================--
--=== By LuaRocks Modified by DragonWrangler1 ===--
--===============================================--

-- If you struggle with ending up in solid blocks when you join worlds, download luarocks mod: https://content.minetest.net/packages/luarocks/lift_on_joinplayer/

-- LICENSE: MIT

local function is_solid_node(pos)
	local node = minetest.get_node(pos)
	local node_def = minetest.registered_nodes[node.name]
	return node_def and node_def.walkable
end
local function check_and_lift_player(player)
	local pos = player:get_pos()
	if not pos then
		return
	end
	local node_below_pos = { x = pos.x, y = pos.y, z = pos.z }
	local node_above_pos = { x = pos.x, y = pos.y + 1, z = pos.z }
	if is_solid_node(node_below_pos) or is_solid_node(node_above_pos) then
		player:set_pos { x = pos.x, y = pos.y + 1, z = pos.z }
		minetest.after(0.01, check_and_lift_player, player)
	else
		player:set_pos { x = pos.x, y = pos.y + 1, z = pos.z }
	end
end
local function start_lifting(player)
	minetest.after(0.1, check_and_lift_player, player)
end
minetest.register_on_joinplayer(start_lifting)
minetest.register_on_respawnplayer(start_lifting)
