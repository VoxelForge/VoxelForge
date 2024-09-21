local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node("vlf_powder_snow:powder_snow", {
	description = S("Powder Snow"),
	_doc_items_longdesc = S("This is a block of snow thats extra fluffy, this means players can sink in it"),
	_doc_items_hidden = false,
	tiles = {"vlf_core_powder_snow.png"},
	groups = {shovely=2, snow_cover=1, not_in_creative_inventory = 1},
	sounds = vlf_sounds.node_sound_snow_defaults(),
	post_effect_color = "#CFD7DBFF",
	walkable = false,
	move_resistance = 3,
	is_ground_content = false, -- set to false to potentially create huge drops into caves >:)
	on_construct = vlf_core.on_snow_construct,
	after_destruct = vlf_core.after_snow_destruct,
	on_rightclick = function(pos, _, clicker, itemstack, pointed_thing)
		if itemstack:get_name() ==  "vlf_buckets:bucket_empty" then
			minetest.set_node(pos, {name = "air"})
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				if itemstack:get_count() == 1 then
					itemstack = ItemStack("vlf_powder_snow:bucket_powder_snow")
				else
					local inv = clicker:get_inventory()
					if inv:room_for_item("main", "vlf_powder_snow:bucket_powder_snow") then
						inv:add_item("main", "vlf_powder_snow:bucket_powder_snow")
					else
						minetest.add_item(clicker:get_pos(), "vlf_powder_snow:bucket_powder_snow")
					end
					itemstack:take_item()
				end
			end
		elseif itemstack:get_definition().type == "node" then
			minetest.item_place_node(itemstack, clicker, pointed_thing)
		end

		return itemstack
	end,
	_vlf_blast_resistance = 0.1,
	_vlf_hardness = 0.1,
	_vlf_silk_touch_drop = false,
})

vlf_buckets.register_liquid({
	source_take = {"vlf_powder_snow:powder_snow"},
	source_place = "vlf_powder_snow:powder_snow",
	bucketname = "vlf_powder_snow:bucket_powder_snow",
	inventory_image = "bucket_powder_snow.png",
	name = S("Powder snow"),
	longdesc = S("This bucket is filled powder snow"),
	usagehelp = S("Place it to empty the bucket and place powder snow. Obtain by right clicking on a block of powder snow with an empty bucket."),
	tt_help = S("Places a powder snow block"),
})

local freezing_stages =
{
	"freezing_1.png",
	"freezing_2.png",
	"freezing_3.png",
}

-- key value pair
-- key: name of player
-- value: number of seconds the player spent in powder snow
local freezing_players = {}

local function show_freezing_hud(player, level)
	local player_name = player:get_player_name()
	local freezing_data = freezing_players[player_name]
	if freezing_data and #freezing_data.hud_ids > 0 then
		for _, hud_id in pairs(freezing_data.hud_ids) do
			player:hud_remove(hud_id)
		end
	end

	freezing_data.hud_ids[1] = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0, y = 0},
		scale = {x = 2, y = 2},
		text = freezing_stages[level],
		alignment = {x = 1, y = 1},
		offset = {x = 0, y = 0},
		z_index = 4,
	})

	freezing_data.hud_ids[2] = player:hud_add({
		hud_elem_type = "image",
		position = {x = 1, y = 0},
		scale = {x = 2, y = 2},
		text = freezing_stages[level] .. "^[transform4",
		alignment = {x = -1, y = 1},
		offset = {x = 0, y = 0},
		z_index = 4,
	})

	freezing_data.hud_ids[3] = player:hud_add({
		hud_elem_type = "image",
		position = {x = 0, y = 1},
		scale = {x = 2, y = 2},
		text = freezing_stages[level] .. "^[transform6",
		alignment = {x = 1, y = -1},
		offset = {x = 0, y = 0},
		z_index = 4,
	})

	freezing_data.hud_ids[4] = player:hud_add({
		hud_elem_type = "image",
		position = {x = 1, y = 1},
		scale = {x = 2, y = 2},
		text = freezing_stages[level] .. "^[transform6^[transform4",
		alignment = {x = -1, y = -1},
		offset = {x = 0, y = 0},
		z_index = 4,
	})
end

local function player_has_leather_armor(player)
	local armor_list = player:get_inventory():get_list("armor")
	for i = 2, 5 do
		if minetest.get_item_group(armor_list[i]:get_name(), "armor_leather") == 1 then
			return true
		end
	end
	return false
end

vlf_player.register_globalstep_slow(function(player, dtime)
	local name = player:get_player_name()
	local player_pos = player:get_pos()
	local freezing_data = freezing_players[name]
	if minetest.get_node(player_pos).name == "vlf_powder_snow:powder_snow" and player_has_leather_armor(player) then
		awards.unlock(player:get_player_name(), "vlf:walk_on_powder_snow_with_leather_boots")
	end
	if minetest.get_node(player_pos).name == "vlf_powder_snow:powder_snow" and not player_has_leather_armor(player) then
		if not freezing_data then
			freezing_players[name] = {time_in_snow = 0, hud_ids = {}}
		end

		freezing_players[name].time_in_snow = math.min(freezing_players[name].time_in_snow + 0.5, 7)

		if freezing_players[name].time_in_snow > 5 then
			show_freezing_hud(player, 3)
			vlf_damage.damage_player(player, 0.5, {type = "freeze"})
			hb.change_hudbar(player, "health", nil, nil, "frozen_heart.png")
		elseif freezing_players[name].time_in_snow == 3 then
			show_freezing_hud(player, 2)
		elseif freezing_players[name].time_in_snow == 1 then
			show_freezing_hud(player, 1)
		end
	elseif freezing_players[name] then
		freezing_players[name].time_in_snow = freezing_players[name].time_in_snow - 0.5

		if freezing_players[name].time_in_snow <= 0 then
			if #freezing_players[name].hud_ids > 0 then
				for _, hud_id in pairs(freezing_players[name].hud_ids) do
					player:hud_remove(hud_id)
				end
			end
			freezing_players[name] = nil
		else
			if freezing_players[name].time_in_snow == 1 then
				show_freezing_hud(player, 1)
			elseif freezing_players[name].time_in_snow == 3 then
				hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_health.png")
				show_freezing_hud(player, 2)
			end
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	freezing_players[player] = nil
end)
