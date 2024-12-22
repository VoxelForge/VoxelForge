local S = minetest.get_translator(minetest.get_current_modname())
local mod_vlf_core = minetest.get_modpath("vlf_core")
local mod_vlfx_core = minetest.get_modpath("vlfx_core")
local has_awards = minetest.get_modpath("awards")

if mod_vlf_core then
	-- Lava bucket
	vlf_buckets.register_liquid({
		id = "lava",
		source_place = function(pos)
			local dim = vlf_worlds.pos_to_dimension(pos)
			if dim == "nether" then
				return "vlf_nether:nether_lava_source"
			else
				return "vlf_core:lava_source"
			end
		end,
		source_take = {"vlf_core:lava_source", "vlf_nether:nether_lava_source"},
		on_take = function(user)
			if has_awards and user and user:is_player() then
				awards.unlock(user:get_player_name(), "vlf:hotStuff")
			end
		end,
		bucketname = "vlf_buckets:bucket_lava",
		inventory_image = "bucket_lava.png",
		name = S("Lava Bucket"),
		longdesc = S("A bucket can be used to collect and release liquids. This one is filled with hot lava, safely contained inside. Use with caution."),
		usagehelp = S("Get in a safe distance and place the bucket to empty it and create a lava source at this spot. Don't burn yourself!"),
		tt_help = S("Places a lava source"),
		_vlf_burntime = 1000,
		_vlf_fuel_replacements = {{"vlf_buckets:bucket_lava", "vlf_buckets:bucket_empty"}}
	})

	-- Water bucket
	vlf_buckets.register_liquid({
		id = "water",
		source_place = "vlf_core:water_source",
		source_take = {"vlf_core:water_source"},
		bucketname = "vlf_buckets:bucket_water",
		inventory_image = "bucket_water.png",
		name = S("Water Bucket"),
		longdesc = S("A bucket can be used to collect and release liquids. This one is filled with water."),
		usagehelp = S("Place it to empty the bucket and create a water source."),
		tt_help = S("Places a water source"),
		extra_check = function(pos, _)
			local dim = vlf_worlds.pos_to_dimension(pos)
			if dim == "nether" then
				minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
				return false, true
			end
		end,
		groups = { water_bucket = 1 },
	})
end

if mod_vlfx_core then
	-- River water bucket
	vlf_buckets.register_liquid({
		id = "river_water",
		source_place = "vlfx_core:river_water_source",
		source_take = {"vlfx_core:river_water_source"},
		bucketname = "vlf_buckets:bucket_river_water",
		inventory_image = "bucket_river_water.png",
		name = S("River Water Bucket"),
		longdesc = S("A bucket can be used to collect and release liquids. This one is filled with river water."),
		usagehelp = S("Place it to empty the bucket and create a river water source."),
		tt_help = S("Places a river water source"),
		extra_check = function(pos, _)
			-- Evaporate water if used in Nether
			local dim = vlf_worlds.pos_to_dimension(pos)
			if dim == "nether" then
				minetest.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
				return false, true
			end
		end,
		groups = { water_bucket = 1 },
	})
end
