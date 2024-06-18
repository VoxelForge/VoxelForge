local S = minetest.get_translator("vlc_copper")

local function set_description(descs, s_index, n_index)
	local description

	if type(descs[s_index][n_index]) == "string" then
		description = S(descs[s_index][n_index])
	elseif type(descs[s_index][n_index]) == "table" then
		description = S("@1 "..descs[s_index][n_index][2], S(descs[s_index][n_index][1]))
	else
		return nil
	end

	return description
end

local function set_drop(drop, old_name, index_name)
	if drop and old_name and index_name then
		drop = "vlc_copper:"..old_name:gsub(index_name, drop)
	end

	return drop
end

local function set_groups(name, groups)
	local groups = table.copy(groups)

	if name and groups then
		if name:find("waxed") then
			groups.waxed = 1
		elseif not name:find("oxidized") then
			groups.oxidizable = 1
		end

		if name:find("door") then
			groups.building_block = 0
			groups.mesecon_effector_on = 1
		end
	else
		return nil
	end

	return groups
end

local function set_light_level(light_source, index)
	local ceil, floor_5, floor_7 = math.ceil(index / 2), math.floor(index / 5), math.floor(index / 7)
	if light_source then
		light_source = light_source - 3 * (ceil - 1) - floor_5 - floor_7
	end

	return light_source
end

local function set_tiles(tiles, index)
	if not tiles or not index then
		return
	end

	return tiles[math.ceil(index / 2)]
end

function vlc_copper.register_copper_variants(name, definitions)
	local names, oxidized_variant, stripped_variant, waxed_variant

	if name ~= "cut_copper" then
		names = {
			name, "waxed_"..name,
			"exposed_"..name, "waxed_exposed_"..name,
			"weathered_"..name, "waxed_weathered_"..name,
			"oxidized_"..name, "waxed_oxidized_"..name
		}
	else
		names = {
			""..name, "waxed_"..name,
			"exposed_"..name, "waxed_exposed_"..name,
			"weathered_"..name, "waxed_weathered_"..name,
			"oxidized_"..name, "waxed_oxidized_"..name
		}
	end

	local tiles = {
		"vlc_copper_"..name..".png",
		"vlc_copper_exposed_"..name..".png",
		"vlc_copper_weathered_"..name..".png",
		"vlc_copper_oxidized_"..name..".png"
	}

	for i = 1, #names do
		if names[i]:find("waxed") then
			stripped_variant = "vlc_copper:"..names[i-1]
		else
			if not names[i]:find("oxidized") then
				oxidized_variant = "vlc_copper:"..names[i+2]
			end
			if i ~= 1 then
				stripped_variant = "vlc_copper:"..names[i-2]
			end
			waxed_variant = "vlc_copper:"..names[i+1]
		end

		minetest.register_node("vlc_copper:"..names[i], {
			description = set_description(vlc_copper.copper_descs, name, i),
			drawtype = definitions.drawtype or "normal",
			drop = set_drop(definitions.drop, names[i], name),
			groups = set_groups(names[i], definitions.groups),
			is_ground_content = false,
			light_source = set_light_level(definitions.light_source, i),
			mesecons = definitions.mesecons,
			paramtype = definitions.paramtype or "none",
			paramtype2 = definitions.paramtype2 or "none",
			sounds = vlc_sounds.node_sound_metal_defaults(),
			tiles = {set_tiles(tiles, i)},
			_doc_items_longdesc = S(vlc_copper.copper_longdescs[name][math.ceil(i/2)]),
			_vlc_blast_resistance = 6,
			_vlc_hardness = 3,
			_vlc_oxidized_variant = oxidized_variant,
			_vlc_stripped_variant = stripped_variant,
			_vlc_waxed_variant = waxed_variant,
			_vlc_stonecutter_recipes = {  },
		})

		if definitions._vlc_stairs then
			local subname = vlc_copper.stairs_subnames[name][i]

			vlc_stairs.register_slab(subname, "vlc_copper:"..names[i], set_groups(subname, definitions.groups),
				{set_tiles(tiles, i), set_tiles(tiles, i), set_tiles(tiles, i)},
				set_description(vlc_copper.stairs_descs, subname, 1), nil, nil, nil,
				set_description(vlc_copper.stairs_descs, subname, 2)
			)

			vlc_stairs.register_stair(subname, "vlc_copper:"..names[i], set_groups(subname, definitions.groups),
				{set_tiles(tiles, i), set_tiles(tiles, i), set_tiles(tiles, i),
				set_tiles(tiles, i), set_tiles(tiles, i), set_tiles(tiles, i)},
				set_description(vlc_copper.stairs_descs, subname, 3), nil, nil, nil, "woodlike"
			)
		end

		if definitions._vlc_doors then
			local itemimg, lowertext, uppertext, frontimg, sideimg
			local door_groups = set_groups(names[i]:gsub(name, "door"), definitions.groups)
			local trapdoor_groups = set_groups(names[i]:gsub(name, "trapdoor"), definitions.groups)

			if i % 2 == 1 then
				itemimg = "vlc_copper_item_"..names[i]:gsub(name, "door")..".png"
				lowertext = "vlc_copper_"..names[i]:gsub(name, "").."copper_door_bottom.png"
				lowerside = "vlc_copper_"..names[i]:gsub(name, "").."copper_door_bottom_side.png"
				upperside = "vlc_copper_"..names[i]:gsub(name, "").."copper_door_top_side.png"
				uppertext = "vlc_copper_"..names[i]:gsub(name, "").."copper_door_top.png"
				frontimg = "vlc_copper_"..names[i]:gsub(name, "").."copper_trapdoor.png"
				sideimg = "vlc_copper_"..names[i]:gsub(name, "trapdoor").."_side.png"
			else
				itemimg = "vlc_copper_item_"..names[i-1]:gsub(name, "door")..".png"
				lowertext = "vlc_copper_"..names[i-1]:gsub(name, "").."copper_door_bottom.png"
				lowerside = "vlc_copper_"..names[i-1]:gsub(name, "").."copper_door_bottom_side.png"
				upperside = "vlc_copper_"..names[i-1]:gsub(name, "").."copper_door_top_side.png"
				uppertext = "vlc_copper_"..names[i-1]:gsub(name, "").."copper_door_top.png"
				frontimg = "vlc_copper_"..names[i-1]:gsub(name, "").."copper_trapdoor.png"
				sideimg = "vlc_copper_"..names[i-1]:gsub(name, "trapdoor").."_side.png"
			end

			vlc_doors:register_door("vlc_copper:"..names[i]:gsub(name, "copper_door"), {
				description = S(vlc_copper.doors_descs[i][1]),
				groups = door_groups,
				inventory_image = itemimg,
				only_redstone_can_open = false,
				sounds = vlc_sounds.node_sound_metal_defaults(),
				sound_close = "doors_steel_door_close",
				sound_open = "doors_steel_door_open",
				tiles_bottom = {lowertext, lowerside},
				tiles_top = {uppertext, upperside},
				_vlc_blast_resistance = 3,
				_vlc_hardness = 3
			})

			vlc_doors:register_trapdoor("vlc_copper:"..names[i]:gsub(name, "trapdoor"), {
				description = S(vlc_copper.doors_descs[i][2]),
				groups = trapdoor_groups,
				only_redstone_can_open = false,
				sounds = vlc_sounds.node_sound_metal_defaults(),
				sound_close = "doors_steel_door_close",
				sound_open = "doors_steel_door_open",
				tile_front = frontimg,
				tile_side = sideimg,
				wield_image = frontimg,
				_vlc_blast_resistance = 3,
				_vlc_hardness = 3
			})
		end
	end
end

minetest.register_node("vlc_copper:copper_ore", {
	description = S("Copper Ore"),
	_doc_items_longdesc = S("Some copper contained in stone, it is pretty common and can be found below sea level."),
	tiles = {"vlc_copper_copper_ore.png"},
	groups = {pickaxey = 3, building_block = 1, material_stone = 1, blast_furnace_smeltable=1},
	drop = "vlc_copper:raw_copper",
	sounds = vlc_sounds.node_sound_stone_defaults(),
	_vlc_blast_resistance = 3,
	_vlc_hardness = 3,
	_vlc_silk_touch_drop = true,
	_vlc_fortune_drop = vlc_core.fortune_drop_ore,

})

minetest.register_node("vlc_copper:raw_copper_block", {
	description = S("Block of Raw Copper"),
	_doc_items_longdesc = S("A block used for compact raw copper storage."),
	tiles = {"vlc_copper_raw_copper_block.png"},
	is_ground_content = false,
	groups = {pickaxey = 2, building_block = 1, blast_furnace_smeltable = 1 },
	groups = {pickaxey = 2, building_block = 1, blast_furnace_smeltable = 1},
	sounds = vlc_sounds.node_sound_metal_defaults(),
	_vlc_blast_resistance = 6,
	_vlc_hardness = 5,
})

vlc_copper.register_copper_variants("copper", {
	groups = {pickaxey = 2, building_block = 1},
	_vlc_doors = true,
})

vlc_copper.register_copper_variants("cut_copper", {
	groups = {pickaxey = 2, building_block = 1, cut_copper = 1, stonecuttable = 1},
	_vlc_stairs = true,
})

vlc_copper.register_copper_variants("copper_grate", {
	drawtype = "allfaces",
	groups = {pickaxey = 2, building_block = 1, disable_suffocation = 1, grate = 1, stonecuttable = 1},
	sunlight_propagates = true,
})

vlc_copper.register_copper_variants("chiseled_copper", {
	groups = {pickaxey = 2, building_block = 1, chiseled = 1, stonecuttable = 1}
})

vlc_copper.register_copper_variants("copper_bulb", {
	groups = {pickaxey = 2, building_block = 1},
	mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = node.name:gsub("copper_bulb", "copper_bulb_lit_powered")})
			end
		},
	},
})

vlc_copper.register_copper_variants("copper_bulb_lit", {
	drop = "copper_bulb",
	groups = {pickaxey = 2, building_block = 1, not_in_creative_inventory = 1},
	light_source = 14,
	mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = node.name:gsub("copper_bulb_lit", "copper_bulb_powered")})
			end
		},
	},
	paramtype = "light"
})

vlc_copper.register_copper_variants("copper_bulb_powered", {
	drop = "copper_bulb",
	groups = {pickaxey = 2, building_block = 1, not_in_creative_inventory = 1},
	mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = node.name:gsub("copper_bulb_powered", "copper_bulb")})
			end
		}
	}
})

vlc_copper.register_copper_variants("copper_bulb_lit_powered", {
	drop = "copper_bulb",
	groups = {pickaxey = 2, building_block = 1, not_in_creative_inventory = 1},
	light_source = 14,
	mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = node.name:gsub("copper_bulb_lit_powered", "copper_bulb_lit")})
			end
		}
	},
	paramtype = "light"
})
