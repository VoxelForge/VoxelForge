--
-- Sounds
--

vlf_sounds = {}

function vlf_sounds.node_sound_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="", gain=1.0}
	table.dug = table.dug or
			{name="default_dug_node", gain=0.25}
	table.dig = table.dig or
			{name="default_dig_oddly_breakable_by_hand", gain=0.5}
	table.place = table.place or
			{name="default_place_node_hard", gain=1.0}
	return table
end

function vlf_sounds.node_sound_stone_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="vlf_sounds_stone_footsteps", gain=0.25}
	table.dug = table.dug or
			{name="vlf_sounds_stone_footsteps", gain=1.0}
	table.dig = table.dig or
			{name="vlf_sounds_dig_stone", gain=0.5}
	vlf_sounds.node_sound_defaults(table)
	return table
end

function vlf_sounds.node_sound_metal_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_metal_footstep", gain=0.2}
	table.dug = table.dug or
			{name="default_dug_metal", gain=0.5}
	table.dig = table.dig or
			{name="default_dig_metal", gain=0.5}
	table.place = table.place or
			{name="default_place_node_metal", gain=0.5}
	vlf_sounds.node_sound_defaults(table)
	return table
end

function vlf_sounds.node_sound_dirt_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_dirt_footstep", gain=0.25}
	table.dug = table.dug or
			{name="default_dirt_footstep", gain=1.0}
	table.dig = table.dig or
			{name="default_dig_crumbly", gain=0.4}
	table.place = table.place or
			{name="default_place_node", gain=1.0}
	vlf_sounds.node_sound_defaults(table)
	return table
end

function vlf_sounds.node_sound_sand_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="vlf_sounds_sand_footsteps", gain=0.15}
	table.dug = table.dug or
			{name="vlf_sounds_sand_dig", gain=0.35}
	table.dig = table.dig or
			{name="vlf_sounds_sand_dig", gain=0.4}
	table.place = table.place or
			{name="default_place_node", gain=1.0}
	vlf_sounds.node_sound_defaults(table)
	return table
end

function vlf_sounds.node_sound_gravel_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="vlf_sounds_gravel_footsteps", gain=0.25}
	table.dug = table.dug or
			{name="vlf_sounds_gravel_dig", gain=1.0}
	table.dig = table.dig or
			{name="vlf_sounds_gravel_dig", gain=0.35}
	table.place = table.place or
			{name="default_place_node", gain=1.0}
	vlf_sounds.node_sound_defaults(table)
	return table
end

function vlf_sounds.node_sound_snow_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="vlf_sounds_snow_footsteps", gain=0.5}
	table.dug = table.dug or
			{name="vlf_sounds_snow_dig", gain=1.0}
	table.dig = table.dig or
			{name="vlf_sounds_snow_dig", gain=1.0}
	table.place = table.place or
			{name="default_place_node", gain=1.0}
	vlf_sounds.node_sound_defaults(table)
	return table
end

function vlf_sounds.node_sound_ice_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_ice_footstep", gain=0.15}
	table.dug = table.dug or
			{name="default_ice_dug", gain=0.5}
	table.dig = table.dig or
			{name="default_ice_dig", gain=0.5}
	vlf_sounds.node_sound_defaults(table)
	return table
end

function vlf_sounds.node_sound_wood_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="vlf_sounds_wood_footsteps", gain=0.25}
	table.dug = table.dug or
			{name="vlf_sounds_wood_footsteps", gain=1.0}
	table.dig = table.dig or
			{name="default_dig_choppy", gain=0.4}
	vlf_sounds.node_sound_defaults(table)
	return table
end

function vlf_sounds.node_sound_wool_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="vlf_sounds_cloth_footsteps", gain=0.5}
	table.dug = table.dug or
			{name="vlf_sounds_cloth_dig", gain=1.0}
	table.dig = table.dig or
			{name="vlf_sounds_cloth_dig", gain=0.9}
	table.place = table.dig or
			{name="vlf_sounds_cloth_dig", gain=1.0}
	vlf_sounds.node_sound_defaults(table)
	return table
end

function vlf_sounds.node_sound_leaves_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="vlf_sounds_grass_footsteps", gain=0.1825}
	table.dug = table.dug or
			{name="vlf_sounds_grass_dig", gain=0.425}
	table.dig = table.dig or
			{name="default_dig_snappy", gain=0.4}
	table.place = table.place or
			{name="default_place_node", gain=1.0}
	vlf_sounds.node_sound_defaults(table)
	return table
end

function vlf_sounds.node_sound_glass_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_glass_footstep", gain=0.3}
	table.dug = table.dug or
			{name="default_break_glass", gain=0.7}
	table.dig = table.dig or
			{name="default_dig_cracky", gain=0.5}
	vlf_sounds.node_sound_defaults(table)
	return table
end

function vlf_sounds.node_sound_water_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "default_water_footstep", gain = 0.2}
	table.place = table.place or
			{name = "vlf_sounds_place_node_water", gain = 1.0}
	table.dug = table.dug or
			{name = "vlf_sounds_dug_water", gain = 1.0}
	vlf_sounds.node_sound_defaults(table)
	return table
end

function vlf_sounds.node_sound_lava_defaults(table)
	table = table or {}
	-- TODO: Footstep
	table.place = table.place or
			{name = "default_place_node_lava", gain = 1.0}
	table.dug = table.dug or
			{name = "default_place_node_lava", gain = 1.0}
	-- TODO: Different dug sound
	vlf_sounds.node_sound_defaults(table)
	return table
end

-- Player death sound
minetest.register_on_dieplayer(function(player)
	-- TODO: Add separate death sound
	minetest.sound_play({name="player_damage", gain = 1.0}, {pos=player:get_pos(), max_hear_distance=16}, true)
end)
