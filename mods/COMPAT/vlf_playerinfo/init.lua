vlf_playerinfo = {}

-- This metatable provides compatibility to the old vlf_playerinfo rerouting all
-- indexing attempts on vlf_playerinfo[playername] to the new vlf_player.player[playerobject]
local mt = {
	__index = function (t, k)
		if type(k) == "string" and k:sub(1,5) == "node_" and vlf_player.players[t.player] and vlf_player.players[t.player].nodes and vlf_player.players[t.player].nodes[k:sub(6,-1)] then
			return vlf_player.players[t.player].nodes[k:sub(6,-1)]
		end
		return false
	end,
	__newindex = function () return false end
}

minetest.register_on_joinplayer(function(pl)
	local pn = pl:get_player_name()
	vlf_playerinfo[pn] = { player = pl }
	setmetatable(vlf_playerinfo[pn], mt)
end)
minetest.register_on_leaveplayer(function(pl) vlf_playerinfo[pl:get_player_name()] = nil end)
