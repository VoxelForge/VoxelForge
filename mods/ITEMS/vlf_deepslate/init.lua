local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

vlf_deepslate = {}
vlf_deepslate.translator = minetest.get_translator(modname)
local S = vlf_deepslate.translator

function vlf_deepslate.register_deepslate_ore(item, desc, extra, basename)
	local nodename = "vlf_deepslate:deepslate_".. item .. "_ore"
	local basename = basename or "vlf_core:".. item .. "_ore"

	local def = table.copy(minetest.registered_nodes[basename])
	def._doc_items_longdesc = S("@1 is a variant of @2 that can generate in deepslate and tuff blobs.", desc, def.description)
	def.description = desc
	def.tiles = { "vlf_deepslate_" .. item .. "_ore.png" }

	table.update(def,extra or {})

	minetest.register_node(nodename, def)

	local result = minetest.get_craft_result({
		method = "cooking",
		width = 1,
		items = {basename},
	})

	if not result.item:is_empty() then
		minetest.register_craft({
			type = "cooking",
			output = result.item:to_string(),
			recipe = nodename,
			cooktime = result.time,
		})
	end
end

function vlf_deepslate.register_variants(name, defs)
	assert(name, "[vlf_deepslate] vlf_deepslate.register_variants called without a valid name, refer to API.md in vlf_deepslate.")
	assert(defs.basename, "[vlf_deepslate] vlf_deepslate.register_variants needs a basename field to work, refer to API.md in vlf_deepslate.")
	assert(defs.basetiles, "[vlf_deepslate] vlf_deepslate.register_variants needs a basetiles field to work, refer to API.md in vlf_deepslate.")

	local main_itemstring = "vlf_deepslate:"..defs.basename.."_"..name
	local main_def = table.merge({
		_doc_items_hidden = false,
		tiles = { defs.basetiles.."_"..name..".png" },
		is_ground_content = false,
		groups = { pickaxey = 1, building_block = 1, material_stone = 1 },
		sounds = vlf_sounds.node_sound_stone_defaults(),
		_vlf_blast_resistance = 6,
		_vlf_hardness = 3.5,
		_vlf_silk_touch_drop = true,
	}, defs.basedef or {})
	if defs.node then
		defs.node.groups = table.merge(main_def.groups, defs.node.groups)
		minetest.register_node(main_itemstring, table.merge(main_def, defs.node))
	end

	if defs.cracked then
		minetest.register_node(main_itemstring.."_cracked", table.merge(main_def, {
			_doc_items_longdesc = S("@1 are a cracked variant.", defs.cracked.description),
			tiles = { defs.basetiles.."_"..name.."_cracked.png" },
		}, defs.cracked))
	end
	if defs.node and defs.stair then
		vlf_stairs.register_stair(defs.basename.."_"..name, {
			description = defs.stair.description,
			baseitem = main_itemstring,
			overrides = defs.stair
		})
	end
	if defs.node and defs.slab then
		vlf_stairs.register_slab(defs.basename.."_"..name, {
			description = defs.slab.description,
			baseitem = main_itemstring,
			overrides = defs.slab
		})
	end

	if defs.node and defs.wall then
		vlf_walls.register_wall("vlf_deepslate:"..defs.basename..name.."wall", defs.wall.description, main_itemstring, nil, nil, nil, nil, defs.wall)
	end
end

dofile(modpath.."/deepslate.lua")
dofile(modpath.."/tuff.lua")
