-- Tree nodes: Wood, Wooden Planks, Sapling, Leaves, Stripped Wood
local S = minetest.get_translator(minetest.get_current_modname())

local mod_screwdriver = minetest.get_modpath("screwdriver")

local bark_stairs = true --TODO: make a setting

local wood_groups = {
	handy = 1, axey = 1,
	wood = 1, material_wood = 1, wood_stairs = 1,
	flammable = 3, fire_encouragement = 5, fire_flammability = 20
}


-- Check dug/destroyed tree trunks for orphaned leaves.
--
-- This function is meant to be called by the `after_destruct` handler of
-- treetrunk nodes.
--
-- Whenever a trunk node is removed, all `group:leaves` nodes in a sphere
-- with radius 6 are checked.  Every such node that does not have a trunk
-- node within a distance of 6 blocks is converted into a orphan leaf node.
-- An ABM will gradually decay these nodes.
--
-- If param2 of the node is set to a nonzero value, the node will always
-- be preserved.  This is set automatically when leaves are placed manually.
--
-- @param pos the position of the removed trunk node.
-- @param oldnode the node table of the removed trunk node.
local function update_leaves(pos, oldnode)
	local pos1, pos2 = vector.offset(pos, -6, -6, -6), vector.offset(pos, 6, 6, 6)
	local lnode
	local leaves = minetest.find_nodes_in_area(pos1, pos2, "group:leaves")
	for _, lpos in pairs(leaves) do
		lnode = minetest.get_node(lpos)
		-- skip already decaying leaf nodes
		if minetest.get_item_group(lnode.name, "orphan_leaves") ~= 1 then
			if not minetest.find_node_near(lpos, 6, "group:tree") then
				-- manually placed leaf nodes have "no_decay" set to 1
				-- in their node meta and will not decay automatically
				if minetest.get_meta(lpos):get_int("no_decay") == 0 then
					minetest.swap_node(lpos, {name = lnode.name .. "_orphan"})
				end
			end
		end
	end
end

--called from leaves after_place_node
function mcl_trees.update_leaf_p2(pos, placer, itemstack, pointed_thing)
	local n = minetest.get_node(pos)
	local p2 = mcl_util.get_pos_p2(pos)
	if n.param2 ~= p2 then
		n.param2 = p2
		minetest.swap_node(pos,n)
	end
end

mcl_trees.tpl_log = {
	groups = wood_groups,
	_doc_items_hidden = false,
	paramtype2 = "facedir",
	groups = {
		handy = 1, axey = 1,
		building_block = 1,
		tree = 1, material_wood=1,
		flammable = 3, fire_encouragement=5, fire_flammability=20
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_place = mcl_util.rotate_axis,
	after_destruct = update_leaves,
	on_rotate = screwdriver.rotate_3way,
	_on_axe_place = mcl_trees.strip_tree,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
}
mcl_trees.tpl_planks = {
	_doc_items_hidden = false,
	is_ground_content = false,
	groups = wood_groups,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
}
mcl_trees.tpl_leaves = {
	_doc_items_hidden = false,
	drawtype = "allfaces_optional",
	waving = 2,
	paramtype = "light",
	paramtype2 = "color",
	palette = "mcl_core_palette_leaves.png",
	groups = {
		handy = 1, hoey = 1, shearsy = 1, swordy = 1, dig_by_piston = 1,
		deco_block = 1, leaves = 1, biomecolor = 1,
		flammable = 2, fire_encouragement = 30, fire_flammability = 60,
		compostability = 30
	},
	after_place_node = mcl_trees.update_leaf_p2,
	_mcl_shears_drop = true,
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	_mcl_silk_touch_drop = true,
}
mcl_trees.tpl_sapling = {
	_doc_items_longdesc = S("When placed on soil (such as dirt) and exposed to light, a sapling will grow into a tree after some time."),
	_tt_help = S("Needs soil and light to grow"),
	_doc_items_hidden = false,
	drawtype = "plantlike",
	waving = 1,
	visual_scale = 1.0,
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-5/16, -0.5, -5/16, 5/16, 0.5, 5/16},
	},
	groups = {
		dig_immediate = 3, dig_by_water = 1, dig_by_piston = 1, destroy_by_lava_flow = 1,
		attached_node = 1,
		deco_block = 1,
		plant = 1, sapling = 1, non_mycelium_plant = 1,
		compostability = 30
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("stage", 0)
	end,
	on_place = mcl_util.generate_on_place_plant_function(function(pos, node)
		local node_below = minetest.get_node_or_nil({x=pos.x,y=pos.y-1,z=pos.z})
		if not node_below then return false end
		local nn = node_below.name
		return minetest.get_item_group(nn, "grass_block") == 1 or
				nn == "mcl_flora:dirt_podzol" or nn == "mcl_flora:dirt_podzol_snow" or
				nn == "mcl_flora:dirt" or nn == "mcl_flora:dirt_mycelium" or nn == "mcl_flora:dirt_coarse"
	end),
	node_placement_prediction = "",
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
}

local function register_leaves(subname, description, longdesc, tiles, sapling, drop_apples, sapling_chances)
	local apple_chances = {200, 180, 160, 120, 40}
	local stick_chances = {50, 45, 30, 35, 10}

	local function get_drops(fortune_level)
		local drop = {
			max_items = 1,
			items = {
				{
					items = {sapling},
					rarity = sapling_chances[fortune_level + 1] or sapling_chances[fortune_level]
				},
				{
					items = {"mcl_trees:stick 1"},
					rarity = stick_chances[fortune_level + 1]
				},
				{
					items = {"mcl_trees:stick 2"},
					rarity = stick_chances[fortune_level + 1]
				},
			}
		}
		if drop_apples then
			table.insert(drop.items, {
				items = {"mcl_trees:apple"},
				rarity = apple_chances[fortune_level + 1]
			})
		end
		return drop
	end

	local l_def = table.merge(mcl_trees.tpl_leaves, {
		description = description,
		_doc_items_longdesc = longdesc,
		tiles = tiles,
		drop = get_drops(0),
		_mcl_fortune_drop = { get_drops(1), get_drops(2), get_drops(3), get_drops(4) },
		on_construct = function(pos)
			-- manually placed leaves nodes do not decay automatically.
			minetest.get_meta(pos):set_int("no_decay", "1")
		end
	})

	minetest.register_node(":mcl_trees:"..subname, l_def)

	local o_def = table.merge(l_def, {
		_doc_items_create_entry = false,
		_mcl_shears_drop = {"mcl_trees:" .. subname},
		_mcl_silk_touch_drop = {"mcl_trees:" .. subname},
		on_construct = nil
	})
	o_def.groups = table.merge(l_def.groups, {
		not_in_creative_inventory = 1,
		orphan_leaves = 1,
	})

	minetest.register_node(":mcl_trees:" .. subname .. "_orphan", o_def)
end

function readable_name(str)
	str = str:gsub("_", " ")
    return (str:gsub("^%l", string.upper))
end


function mcl_trees.register_wood(name,p)
	if not p then p = {} end
	local rname = readable_name(name)
	if p.tree == nil or type(p.tree) == "table" then
		minetest.register_node(":mcl_trees:".."tree_"..name,table.merge(mcl_trees.tpl_log,{
			description = S(rname.." Wood"),
			_doc_items_longdesc = S("The trunk of a "..name.." tree."),
			tiles = { "mcl_core_log_"..name.."_top.png",  "mcl_core_log_"..name.."_top.png", "mcl_core_log_"..name..".png"},
			_mcl_stripped_variant = "mcl_trees:stripped_"..name,
		},p.tree or {}))
	end

	if p.planks == nil or type(p.planks) == "table" then
		minetest.register_node(":mcl_trees:planks_"..name, table.merge(mcl_trees.tpl_planks,{
			description =  S(rname.." Wood Planks"),
			_doc_items_longdesc = doc.sub.items.temp.build,
			tiles = {"mcl_core_planks_"..name..".png"},
		},p.planks or {}))
		minetest.register_craft({
			output = "mcl_trees:planks_"..name.." 4",
			recipe = {
				{ "mcl_trees:tree_"..name },
			}
		})
	end

	if p.bark == nil or type(p.bark) == "table" then
		minetest.register_node(":mcl_trees:bark_"..name,table.merge(mcl_trees.tpl_log,{
			description = S(rname.." Bark"),
			_doc_items_longdesc = S("This is a decorative block surrounded by the bark of a tree trunk."),
			tiles = {"mcl_core_log_"..name..".png"},
			is_ground_content = false,
			_mcl_stripped_variant = "mcl_trees:bark_stripped_"..name,
		},p.bark or {}))
		minetest.register_craft({
			output = "mcl_trees:"..name.."_bark 3",
			recipe = {
				{ "mcl_trees:"..name, "mcl_trees:"..name },
				{ "mcl_trees:"..name, "mcl_trees:"..name },
			}
		})

		minetest.register_craft({
			output = "mcl_trees:"..name.."_bark 3",
			recipe = {
				{ "mcl_trees:"..name, "mcl_trees:"..name },
				{ "mcl_trees:"..name, "mcl_trees:"..name },
			}
		})
	end

	if p.stripped == nil or type(p.stripped) == "table" then
		minetest.register_node(":mcl_trees:stripped_"..name, table.merge(mcl_trees.tpl_log,{
			description = S("Stripped "..rname.." Log"),
			_doc_items_longdesc = S("The stripped trunk of an "..name.." tree."),
			_doc_items_hidden = false,
			tiles = { "mcl_core_stripped_"..name.."_top.png",  "mcl_core_stripped_"..name.."_top.png", "mcl_core_stripped_"..name.."_side.png"},
		},p.stripped or {}))
	end

	if p.stripped_bark == nil or type(p.stripped_bark) == "table" then
		minetest.register_node(":mcl_trees:bark_stripped_"..name, table.merge(mcl_trees.tpl_log,{
			description = S("Stripped "..rname.." Wood"),
			_doc_items_longdesc = S("The stripped wood of an "..name.." tree."),
			tiles = {"mcl_core_stripped_"..name.."_side.png"},
			is_ground_content = false,
		},p.stripped_bark or {}))
	end

	if p.sapling == nil or type(p.sapling) == "table" then
		minetest.register_node(":mcl_trees:sapling_"..name, table.merge(mcl_trees.tpl_sapling,{
			description = S(rname.." Sapling"),
			tiles = {"mcl_core_sapling_"..name..".png"},
			inventory_image = "mcl_core_sapling_"..name..".png",
			wield_image = "mcl_core_sapling_"..name..".png",
		}))
	end


	if p.leaves == nil or type(p.leaves) == "table" then
		register_leaves("leaves_"..name, S(rname.." Leaves"), S(rname.." leaves are grown from "..name.." trees."), p.leaves and p.leaves.tiles or { "mcl_core_leaves_"..name..".png"}, "mcl_trees:sapling_"..name, true, {20, 16, 12, 10})
	end

	--[[if p.stairs == nil or type(p.stairs) == "table" then
		mcl_stairs.register_stair("mcl_trees:planks_"..name,p.stair or {})

		if bark_stairs then
			mcl_stairs.register_stair("mcl_trees:bark_"..name,p.stair or {})
		end
	end

	if p.slab == nil or type(p.slab) == "table" then
		mcl_stairs.register_slab("mcl_trees:planks_"..name, p.slab or {})

		if bark_stairs then
			mcl_stairs.register_slab("mcl_trees:bark_"..name, p.slab or {})
		end
	end

	if p.fence == nil or type(p.fence) == "table" then
		mcl_fences.register_fence("mcl_trees:planks_"..name,p.fence or {
			description = S(rname.." fence"),
		})
	end
	if p.gate == nil or type(p.gate) == "table" then
		mcl_fences.register_gate("mcl_trees:planks_"..name,p.gate or{
			description = S(rname.." fence gate"),
		})
	end

	if p.door == nil or type(p.door) == "table" then
		mcl_doors:register_door("mcl_doors:door_"..name,table.merge({
			description = S(rname.." Door"),
			_doc_items_longdesc = S("Wooden doors are 2-block high barriers which can be opened or closed by hand and by a redstone signal."),
			_doc_items_usagehelp = S("To open or close a wooden door, rightclick it or supply its lower half with a redstone signal."),
			inventory_image = "mcl_doors_door_"..name..".png",
			groups = {handy=1,axey=1, material_wood=1, flammable=-1},
			_mcl_hardness = 3,
			_mcl_blast_resistance = 3,
			tiles_bottom = {"mcl_doors_door_"..name.."_lower.png", "mcl_trees_planks_"..name..".png"},
			tiles_top = {"mcl_doors_door_"..name.."_upper.png", "mcl_trees_planks_"..name..".png"},
			sounds = mcl_sounds.node_sound_wood_defaults(),
		},p.door or {}))
		minetest.register_craft({
			output = "mcl_doors:door_"..name.." 3",
			recipe = {
				{ "mcl_trees:planks_"..name,"mcl_trees:planks_"..name },
				{ "mcl_trees:planks_"..name,"mcl_trees:planks_"..name },
				{ "mcl_trees:planks_"..name,"mcl_trees:planks_"..name },
			}
		})
		minetest.register_craft({
			type = "fuel",
			recipe = "mcl_doors:door_"..name,
			burntime = 15
		})
	end
	if p.trapdoor == nil or type(p.trapdoor) == "table" then
		mcl_doors:register_trapdoor("mcl_doors:trapdoor_"..name, table.merge({
			description = S(rname.." Trapdoor"),
			_doc_items_longdesc = S("Wooden trapdoors are horizontal barriers which can be opened and closed by hand or a redstone signal. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder."),
			_doc_items_usagehelp = S("To open or close the trapdoor, rightclick it or send a redstone signal to it."),
			tile_front = "mcl_doors_trapdoor_"..name..".png",
			tile_side = "mcl_trees_planks_"..name..".png",
			wield_image = "mcl_doors_trapdoor_"..name..".png",
			groups = {handy=1,axey=1, redstone_effector_on=1, material_wood=1, flammable=-1},
			_mcl_hardness = 3,
			_mcl_blast_resistance = 3,
			sounds = mcl_sounds.node_sound_wood_defaults(),
		},p.trapdoor or {}))
		minetest.register_craft({
			output = "mcl_doors:trapdoor_"..name.." 3",
			recipe = {
				{ "mcl_trees:planks_"..name,"mcl_trees:planks_"..name,"mcl_trees:planks_"..name  },
				{ "mcl_trees:planks_"..name,"mcl_trees:planks_"..name,"mcl_trees:planks_"..name  },
			}
		})
		minetest.register_craft({
			type = "fuel",
			recipe = "mcl_doors:trapdoor_"..name,
			burntime = 12
		})
	end

	if p.pressure_plate == nil or type(p.pressure_plate) == "table" then
		redstone.register_pplate("mcl_trees:planks_"..name,p.pressure_plate or {})
		minetest.register_craft({
			type = "fuel",
			recipe = "redstone_pressureplates:planks_"..name.."_pplate_off",
			burntime = 10
		})
	end
	if p.button == nil or type(p.button) == "table" then
		mesecons.register_button("mcl_trees:planks_"..name,table.merge({
			groups={material_wood=1,handy=1,axey=1},
			sounds={dig = "redstone_button_push_wood"},
			description = S(rname .. " Button"),
		},p.button or {}))
		minetest.register_craft({
			type = "fuel",
			recipe = "redstone_pressureplates:planks_"..name.."_button_off",
			burntime = 5
		})
	end-

	if p.sign_color and ( p.sign == nil or type(p.sign) == "table" ) then
		mcl_signs.register_sign_custom("mcl_trees", "_"..name,
				"mcl_signs_sign_greyscale.png",p.sign_color, "default_sign_greyscale.png",
				"default_sign_greyscale.png", rname.." Sign"
		)
		mcl_signs.register_sign_craft("mcl_trees", "mcl_trees:planks_"..name, "_"..name,p.sign or {})
	end

	if p.boat == nil or type(p.boat) == "table" then
		mcl_boats.register_boat({
			name = "boat_"..name,
			readable_name = rname.." Boat",
			craftnode = "mcl_trees:planks_"..name
		})

		mcl_boats.register_boat({
			name = "chest_boat_"..name,
			readable_name = rname.." Chest Boat",
			craftnode = "mcl_trees:planks_"..name
		})
	end-]]
end

local modpath = minetest.get_modpath(minetest.get_current_modname())
minetest.register_on_mods_loaded(function()
	mcl_structures.register_structure("wood_test",{
	filenames = {
		modpath.."/schematics/wood_test.mts"
		},
	},true)
end)

local function get_stairs_nodes()
	local r = {}
	for n,def in pairs(minetest.registered_nodes) do
		if n:find("_stair") or n:find("_slab") then
			table.insert(r,n)
		end
	end
	return r
end

minetest.register_on_mods_loaded(function()
	mcl_structures.register_structure("stairs_test",{
	place_func = function(pos,def,pr)
		local stairs = get_stairs_nodes()
		local s = math.ceil(math.sqrt(#stairs))
		local x = 1
		local y = 1
		for i,n in pairs(stairs) do
			if x > s then x=1 y = y + 1 end
			minetest.set_node(vector.offset(pos,x,y,0),{name=n})
			x = x + 1
		end
	end,
	},true)
end)
