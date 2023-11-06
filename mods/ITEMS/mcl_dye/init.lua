mcl_dye = {}
mcl_dye.colors = mcl_dyes.colors
mcl_dye.unicolor_to_dye = mcl_dyes.unicolor_to_dye

mcl_dye.mcl2dyes_translate = {}
for k, v in pairs(mcl_dyes.colors) do
	mcl_dye.mcl2dyes_translate["mcl_dye:"..(v.mcl2 or k)] = "mcl_dyes:"..k
end

local old_mt_reg_craft = minetest.register_craft
function minetest.register_craft(recipe)
	if recipe.recipe and type(recipe.recipe) == "table" then
		recipe = table.copy(recipe) --we're possibly modifying the input table; make a copy not to cause confusion
		for k,v in pairs(recipe.recipe) do
			if type(v) == "table" then
				for l,w in pairs(v) do
					if mcl_dye.mcl2dyes_translate[w] then
						recipe.recipe[k][l] = mcl_dye.mcl2dyes_translate[w]
					end
				end
			elseif type(v) == "string"then
				if mcl_dye.mcl2dyes_translate[v] then
					recipe.recipe[k] = mcl_dye.mcl2dyes_translate[v]
				end
			end
		end
	end
	return old_mt_reg_craft(recipe)
end

-- TEST RECIPE: this should result in a recipe of 3 blue dyes (not lapis) yielding a stick
minetest.register_craft({
    output = "mcl_core:stick",
    type = "shapeless",
    recipe = {
        "mcl_dye:blue",
        "mcl_dye:blue",
        "mcl_dye:blue",
    },
})
