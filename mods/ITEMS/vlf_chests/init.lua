local sm = string.match
vlf_chests = {}

-- Christmas chest setup
local it_is_christmas = false
local date = os.date("*t")
if (
		date.month == 12 and (
			date.day == 24 or
			date.day == 25 or
			date.day == 26
		)
	) then
	it_is_christmas = true
end

local tiles = { -- extensions will be added later
	chest_normal_small = { "vlf_chests_normal" },
	chest_normal_double = { "vlf_chests_normal_double" },
	chest_trapped_small = { "vlf_chests_trapped" },
	chest_trapped_double = { "vlf_chests_trapped_double" },
	chest_ender_small = { "vlf_chests_ender" },
	ender_chest_texture = { "vlf_chests_ender" },
}

local tiles_postfix = ".png"
local tiles_postfix_double = ".png"
if it_is_christmas then
	tiles_postfix = "_present.png^vlf_chests_noise.png"
	tiles_postfix_double = "_present.png^vlf_chests_noise_double.png"
end

-- Append the postfixes for each entry
for k,v in pairs(tiles) do
	if not sm(k, "double") then
		tiles[k] = {v[1] .. tiles_postfix}
	else
		tiles[k] = {v[1] .. tiles_postfix_double}
	end
end

vlf_chests.tiles = tiles

local modpath = minetest.get_modpath("vlf_chests")
dofile(modpath .. "/api.lua")
dofile(modpath .. "/chests.lua")
dofile(modpath .. "/ender.lua")
dofile(modpath .. "/shulkers.lua")

-- Disable chest when it has been closed
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname:find("vlf_chests:") == 1 then
		if fields.quit then
			vlf_chests.player_chest_close(player)
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	vlf_chests.player_chest_close(player)
end)

minetest.register_lbm({
	label = "Spawn Chest entities",
	name = "vlf_chests:spawn_chest_entities",
	nodenames = { "group:chest_entity" },
	run_at_every_load = true,
	action = vlf_chests.select_and_spawn_entity,
})
