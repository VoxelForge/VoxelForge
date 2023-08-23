mcl_pottery_sherds = {}
local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

mcl_pottery_sherds.names = {"angler", "archer", "arms_up", "blade", "brewer", "burn", "danger", "explorer", "friend", "heartbreak", "heart", "howl", "miner", "mourner", "plenty", "mcl_pottery_sherds", "prize", "sheaf", "shelter", "skull", "snort"}

local pot_face_positions = {
	vector.new(-0.2,-0.3,0),
	vector.new(0,   -0.3,-0.2),
	vector.new(0,   -0.3,0.2),
	vector.new(0.2, -0.3,0),
}
local pot_face_rotations = {
	vector.new(0,0.5*math.pi,0),
	vector.new(0,0,0),
	vector.new(0,0,0),
	vector.new(0,-0.5*math.pi,0),
}

for _,name in pairs(mcl_pottery_sherds.names) do
	minetest.register_craftitem("mcl_pottery_sherds:"..name, {
		description = S(name.." Pottery Sherd"),
		_tt_help = S("Used for crafting decorative pots"),
		_doc_items_create_entry = false,
		inventory_image = "mcl_pottery_sherds_"..name..".png",
		wield_image = "mcl_pottery_sherds_"..name..".png",
		groups = { pottery_sherd = 1 },
		_mcl_pottery_sherd_name = name,
	})
end

minetest.register_craftitem("mcl_pottery_sherds:blank", {
	description = S("Blank Pottery Sherd"),
	_tt_help = S("Used for crafting decorative pots"),
	_doc_items_create_entry = false,
	inventory_image = "blank.png",
	wield_image = "blank.png",
	groups = { pottery_sherd = 1, not_in_creative_inventory = 1 },
})

local pot_box = {
	type = "fixed",
	fixed = {
		{ -0.1875, -0.5, -0.1875, 0.1875, -0.125, 0.1875 },
	},
}

minetest.register_entity("mcl_pottery_sherds:pot_face",{
	initial_properties = {
		physical = false,
		visual = "wielditem",
		visual_size = {x=0.15, y=0.15},
		collisionbox = {0,0,0,0,0,0},
		pointable = true,
	},
})

local function update_entities(pos,rm)
	local pots = {}
	for _,v in pairs(minetest.get_objects_inside_radius(pos ,0.4, true)) do
		if v:get_luaentity().name == "mcl_pottery_sherds:pot_face" then table.insert(pots,v) end
	end
	if #pots ~= 4 or rm then
		for _,v in pairs(pots) do v:remove() end
		if rm then return end
		local meta = minetest.get_meta(pos)
		local faces = minetest.deserialize(meta:get_string("pot_faces"))
		if not faces then return end
		for k,v in pairs(pot_face_positions) do
			local o = minetest.add_entity(pos + v, "mcl_pottery_sherds:pot_face")
			o:set_properties({
				wield_item = "mcl_pottery_sherds:"..faces[k]
			})
			o:set_rotation(pot_face_rotations[k])
		end
	end
end


minetest.register_node("mcl_pottery_sherds:pot", {
	description = S("Decorative Pot"),
	_tt_help = S("Nice looking pot"),
	_doc_items_longdesc = S("Pots are decorative blocks."),
	_doc_items_usagehelp = S("Specially decorated pots can be crafted using pottery sherds"),
	drawtype = "mesh",
	mesh = "flowerpot.obj",
	tiles = {
		"mcl_flowerpots_flowerpot.png",
	},
	use_texture_alpha = "clip",
	visual_scale = 0.5,
	wield_image = "mcl_flowerpots_flowerpot_inventory.png",
	paramtype = "light",
	sunlight_propagates = true,
	selection_box = pot_box,
	collision_box = pot_box,
	is_ground_content = false,
	inventory_image = "mcl_flowerpots_flowerpot_inventory.png",
	groups = { dig_immediate = 3, deco_block = 1, attached_node = 1, dig_by_piston = 1, flower_pot = 1 },
	sounds = mcl_sounds.node_sound_stone_defaults(),
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		--meta:from_table(itemstack:to_table())
		meta:set_string("pot_faces",itemstack:get_meta():get_string("pot_faces"))
		update_entities(pos)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		update_entities(pos,true)
	end
})

local function get_sherd_name(itemstack)
	local def = minetest.registered_items[itemstack:get_name()]
	local r = "blank"
	if def and def._mcl_pottery_sherd_name then
		r = def._mcl_pottery_sherd_name
	end
	return r
end

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name() ~= "mcl_pottery_sherds:pot" then return end
	if old_craft_grid[1][2] == "mcl_core:brick" then return end
	local meta = itemstack:get_meta()
	meta:set_string("pot_faces",minetest.serialize({
		get_sherd_name(old_craft_grid[2]),
		get_sherd_name(old_craft_grid[6]),
		get_sherd_name(old_craft_grid[4]),
		get_sherd_name(old_craft_grid[8]),
	}))
	return itemstack
end)

minetest.register_craft({
	output = "mcl_pottery_sherds:pot",
	recipe = {
		{ "", "group:pottery_sherd", "" },
		{ "group:pottery_sherd", "", "group:pottery_sherd" },
		{ "", "group:pottery_sherd", "" },
	}
})

minetest.register_craft({
	output = "mcl_pottery_sherds:pot",
	recipe = {
		{ "", "mcl_core:brick", "" },
		{ "mcl_core:brick", "", "mcl_core:brick" },
		{ "", "mcl_core:brick", "" },
	}
})
