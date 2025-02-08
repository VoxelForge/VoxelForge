mcl_achievements = {}

local modpath = minetest.get_modpath("mcl_achievements")

function mcl_achievements.award_unlocked(playername, awardname)
	local unlocked = false
	for _, aw in pairs(awards.get_award_states(playername)) do
		if aw.name == awardname and aw.unlocked then
			unlocked = true
			break
		end
	end
	return unlocked
end

awards.register_on_unlock(function(name, def)
	if def.reward_xp then
		local player = minetest.get_player_by_name(name)
		mcl_experience.throw_xp(player:get_pos(), def.reward_xp)
	end
end)

-- Show achievements formspec when the button was pressed
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.__mcl_achievements then
		local name = player:get_player_name()
		awards.show_to(name, name, nil, false)
	end
end)
-- All categories have been split into different files as of VoxelForge Weekly Release 24w39a. This is to help those searching for one via category.
dofile(modpath.."/adventure.lua")
dofile(modpath.."/end.lua")
dofile(modpath.."/husbandry.lua")
dofile(modpath.."/nether.lua")
dofile(modpath.."/non-pc.lua")
dofile(modpath.."/overworld.lua")
if minetest.settings:get_bool('legacy_achievements', true) then
	dofile(modpath.."/legacy.lua")
end
