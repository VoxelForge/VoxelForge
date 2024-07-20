vlf_dye = {}
vlf_dye.bone_meal_callbacks = {}
vlf_dye.colors = vlf_dyes.colors
vlf_dye.unicolor_to_dye = vlf_dyes.unicolor_to_dye
vlf_dye.add_bone_meal_particle = vlf_bone_meal.add_bone_meal_particle

vlf_dye.vlfdyes_translate = {}
for k, v in pairs(vlf_dyes.colors) do
	vlf_dye.vlfdyes_translate["vlf_dye:"..(v.vlf or k)] = "vlf_dyes:"..k
end

-- Override of minetest.register_craft rewrites crafing recipes that use vlf item names to use the vlfa eqivalents.
-- It's necessary to prevent turning old lapis, bone meal, ink sacs and cocoanuts into dye as
-- before 0.81 the "vlf_dye:blue" item was the same as lapis.
-- This essentially means in vlfa "vlf_dye:blue" is still lapis (via alias) but all recipes
-- using that itemstring are rewritten to use "vlf_dyes:blue" so they still work the same.

local old_mt_reg_craft = minetest.register_craft
function minetest.register_craft(recipe)
	if recipe.recipe and type(recipe.recipe) == "table" then
		recipe = table.copy(recipe) --we're possibly modifying the input table; make a copy not to cause confusion
		for k,v in pairs(recipe.recipe) do
			if type(v) == "table" then
				for l,w in pairs(v) do
					if vlf_dye.vlfdyes_translate[w] then
						recipe.recipe[k][l] = vlf_dye.vlfdyes_translate[w]
					end
				end
			elseif type(v) == "string"then
				if vlf_dye.vlfdyes_translate[v] then
					recipe.recipe[k] = vlf_dye.vlfdyes_translate[v]
				end
			end
		end
	end
	return old_mt_reg_craft(recipe)
end

function vlf_dye.register_on_bone_meal_apply(func)
	minetest.log("warning", "[vlf_dye] A mod "..(minetest.get_current_modname() or "").."is using the function vlf_dye.register_on_bone_meal_apply - this is deprecated. Use the node defintion callbacks as documented in mods/vlf_bone_meal/API.md instead!")
	table.insert(vlf_dye.bone_meal_callbacks, func)
end

local old_on_place = minetest.registered_items["vlf_bone_meal:bone_meal"].on_place
minetest.override_item("vlf_bone_meal:bone_meal", {
	on_place = function(itemstack, placer, pointed_thing)
		if #vlf_dye.bone_meal_callbacks > 0 then
			local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
			if rc then return rc end

			for _, func in pairs(vlf_dye.bone_meal_callbacks) do
				if func(pointed_thing, placer) then
					itemstack:take_item()
					return itemstack
				end
			end
		end
		return old_on_place(itemstack, placer, pointed_thing)
	end
})
