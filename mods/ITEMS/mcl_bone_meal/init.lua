local S = minetest.get_translator(minetest.get_current_modname())

local function bone_meal(itemstack,user,pointed_thing)
	local unode = minetest.get_node(pointed_thing.under)
	local anode = minetest.get_node(pointed_thing.above)
	local udef = minetest.registered_nodes[unode.name]
	local adef = minetest.registered_nodes[anode.name]
	if udef and udef._on_bone_meal then
		if udef._on_bone_meal(itemstack,user,pointed_thing, pointed_thing.under,unode) then
			itemstack:take_item()
		end
	elseif adef and adef._on_bone_meal then
		if adef._on_bone_meal(itemstack,user,pointed_thing,pointed_thing.above,anode) then
			itemstack:take_item()
		end
	end
	return itemstack
end

minetest.register_craftitem("mcl_bone_meal:bone_meal", {
	inventory_image = "mcl_bone_meal_bone_meal.png",
	description = S("Bone Meal"),
	_tt_help = S("Speeds up plant growth"),
	_doc_items_longdesc = S("Bone meal is a white dye and also useful as a fertilizer to speed up the growth of many plants."),
	_doc_items_usagehelp = S("Rightclick a sheep to turn its wool white. Rightclick a plant to speed up its growth. Note that not all plants can be fertilized like this. When you rightclick a grass block, tall grass and flowers will grow all over the place."),
	stack_max = 64,
	on_place = function(itemstack, user, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end
		return bone_meal(itemstack,user,pointed_thing)
	end,
	_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
		-- Apply bone meal, if possible
		local pointed_thing
		if dropnode.name == "air" then
			pointed_thing = { above = droppos, under = { x=droppos.x, y=droppos.y-1, z=droppos.z } }
		else
			pointed_thing = { above = pos, under = droppos }
		end
		return bone_meal(itemstack,nil,pointed_thing)
	end,
	_dispense_into_walkable = true
})
