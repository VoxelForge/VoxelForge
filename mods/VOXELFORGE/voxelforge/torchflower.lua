local S = minetest.get_translator(minetest.get_current_modname())

local planton = {"mcl_farming:soil", "mcl_farming:soil_wet"}

for i=0, 1 do
	local texture = "vlf_farming_torchflower_" .. i .. ".png"
	if i == 1 then texture = "vlf_farming_torchflower_0.png^vlf_farming_torchflower_1.png" end
	local node_name = "voxelforge:torchflower_crop_" .. i
	local groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1, flammable=3, fire_encouragement=60, fire_flammability=20, compostability=30}
	local orc
	if i >= 2 then
		orc = function(pos, node, clicker, itemstack, pointed_thing)
			if clicker and clicker:is_player() then
				local pn = clicker:get_player_name()
				if minetest.is_protected(pos, pn) then
					minetest.record_protection_violation(pos, pn)
					return false
				end
				if clicker:get_wielded_item():get_name() == "mcl_bone_meal:bone_meal" then
					return false
				end
			end
			minetest.swap_node(pos, {name = "voxelforge:torchflower_1"})
			return itemstack
		end
	end

	minetest.register_node(node_name, {
		drawtype = "plantlike",
		tiles = {texture},
		description = S("TorchFlower Stage: ".. i),
		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "meshoptions",
		place_param2 = 3,
		walkable = false,
		drop = "vlf_farming:torchflower_seeds",
		selection_box = {
			type = "fixed",
			fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, (-0.30 + (i*0.25)), 6 / 16},
		},
		inventory_image = texture,
		wield_image = texture,
		groups = groups,
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0,
		_mcl_hardness = 0,
		on_rightclick = orc,
		_on_bone_meal = function(itemstack,placer,pointed_thing,pos,node)
			mcl_farming.on_bone_meal(itemstack,placer,pointed_thing,pos,node,"plant_torchflower",1)
		end,
	})
end

minetest.register_craftitem("voxelforge:torchflower_seeds", {
	description = S("Torchflower Seeds"),
	inventory_image = "vlf_farming_torchflower_seeds.png",
	_mcl_saturation = 0.4,
	groups = {compostability=30},
	on_place = function(itemstack, placer, pointed_thing)
		local pn = placer:get_player_name()
		if placer:is_player() and minetest.is_protected(pointed_thing.above, pn or "") then
			minetest.record_protection_violation(pointed_thing.above, pn)
			return itemstack
		end
		if pointed_thing.type == "node" and
				table.indexof(planton, minetest.get_node(pointed_thing.under).name) ~= -1 and
				pointed_thing.above.y > pointed_thing.under.y and
				minetest.get_node(pointed_thing.above).name == "air" then
			minetest.set_node(pointed_thing.above, {name="voxelforge:torchflower_crop_0"})
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack:take_item()
			end
			return itemstack
		end
	end,
})

-- TODO: Find proper interval and chance values for sweet berry bushes. Current interval and chance values are copied from vlf_farming:beetroot which has similar growth stages.
mcl_farming:add_plant("plant_torchflower", "voxelforge:torchflower", {"voxelforge:torchflower_crop_0", "voxelforge:torchflower_crop_1"}, 48, 2)

-- COMING SOON

minetest.register_node("voxelforge:torchflower", {
	drawtype = "plantlike",
	tiles = {"vlf_flowers_torchflower.png"},
	description = S("TorchFlower"),
	paramtype = "light",
	sunlight_propagates = true,
	--paramtype2 = "meshoptions",
	place_param2 = 3,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, (-0.30 + (0.75)), 6 / 16},
	},
	groups = {dig_immediate=3,plant=1,attached_node=1,dig_by_water=1,dig_by_lava=1,dig_by_piston=1, flammable=3, fire_encouragement=60, fire_flammability=20, compostability=30},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
	_on_bone_meal = function(itemstack,placer,pointed_thing,pos,node)
		return
	end,
})

minetest.register_alias("vlf_torchflower", "voxelforge:torchflower")
minetest.register_alias("vlf_torchflower_seeds", "voxelforge:torchflower_seeds")
minetest.register_alias("vlf_torchflower_crop_0", "voxelforge:torchflower_crop_0")
minetest.register_alias("vlf_torchflower_crop_1", "voxelforge:torchflower_crop_1")
