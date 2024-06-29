minetest.register_craft({
	output = "vlf_copper:block_raw",
	recipe = {
		{ "vlf_copper:raw_copper", "vlf_copper:raw_copper", "vlf_copper:raw_copper" },
		{ "vlf_copper:raw_copper", "vlf_copper:raw_copper", "vlf_copper:raw_copper" },
		{ "vlf_copper:raw_copper", "vlf_copper:raw_copper", "vlf_copper:raw_copper" },
	},
})

minetest.register_craft({
	output = "vlf_copper:block",
	recipe = {
		{ "vlf_copper:copper_ingot", "vlf_copper:copper_ingot", "vlf_copper:copper_ingot" },
		{ "vlf_copper:copper_ingot", "vlf_copper:copper_ingot", "vlf_copper:copper_ingot" },
		{ "vlf_copper:copper_ingot", "vlf_copper:copper_ingot", "vlf_copper:copper_ingot" },
	},
})

local function get_shape(name, material)
	if name == "cut" then
		return {
			{material, material},
			{material, material}
		}
	elseif name == "grate" then
		return {
			{"", material, ""},
			{material, "", material},
			{"", material, ""}
		}
	elseif name == "chiseled" then
		return {
			{material},
			{material},
		}
	elseif name == "door" then
		return {
			{material, material},
			{material, material},
			{material, material}
		}
	elseif name == "trapdoor" then
		return {
			{material, material, material},
			{material, material, material}
		}
	elseif name == "bulb_off" then
		return {
			{"", material, ""},
			{material, "vlf_mobitems:blaze_rod", material},
			{"", "mesecons:redstone", ""}
		}
	else
		return {}
	end
end

function vlf_copper.register_variants_recipes(name, material, amount)
	local names
	local materials = {}
	if name ~= "cut" then
		names = {
			name, "waxed_"..name,
			name.."_exposed", "waxed_"..name.."_exposed",
			name.."_weathered", "waxed_"..name.."_weathered",
			name.."_oxidized", "waxed_"..name.."_oxidized"
		}
	else
		names = {
			"block_"..name, "waxed_block_"..name,
			"block_exposed_"..name, "waxed_block_exposed_"..name,
			"block_weathered_"..name, "waxed_block_weathered_"..name,
			"block_oxidized_"..name, "waxed_block_oxidized_"..name
		}
	end
	
	if type(material) == "string" then
		materials = {
			"vlf_copper:"..material, "vlf_copper:waxed_"..material,
			"vlf_copper:"..material.."_exposed", "vlf_copper:waxed_"..material.."_exposed",
			"vlf_copper:"..material.."_weathered", "vlf_copper:waxed_"..material.."_weathered",
			"vlf_copper:"..material.."_oxidized", "vlf_copper:waxed_"..material.."_oxidized"
		}
	elseif type(material) == "table" then
		if #material == 8 then
			materials = material
		else
			return
		end
	else
		return
	end

	for i = 1, 8 do
		minetest.register_craft({
			output = "vlf_copper:"..names[i].." "..tostring(amount),
			recipe = get_shape(name, materials[i])
		})
	end
end

vlf_copper.register_variants_recipes("cut", "block", 4)
vlf_copper.register_variants_recipes("grate", "block", 4)
vlf_copper.register_variants_recipes("door", "block", 3)
vlf_copper.register_variants_recipes("trapdoor", "block", 2)
vlf_copper.register_variants_recipes("bulb_off", "block", 4)

local chiseled_materials = {
	"vlf_stairs:slab_copper_cut",
	"vlf_stairs:slab_waxed_copper_cut",
	"vlf_stairs:slab_copper_exposed_cut",
	"vlf_stairs:slab_waxed_copper_exposed_cut",
	"vlf_stairs:slab_copper_weathered_cut",
	"vlf_stairs:slab_waxed_copper_weathered_cut",
	"vlf_stairs:slab_copper_oxidized_cut",
	"vlf_stairs:slab_waxed_copper_oxidized_cut"
}

vlf_copper.register_variants_recipes("chiseled", chiseled_materials, 1)

local waxable_blocks = {
	"block",
	"block_cut",
	"grate",
	"chiseled",
	"bulb_off",
	"block_exposed",
	"block_exposed_cut",
	"grate_exposed",
	"chiseled_exposed",
	"bulb_off_exposed",
	"block_weathered",
	"block_weathered_cut",
	"grate_weathered",
	"chiseled_weathered",
	"bulb_off_weathered",
	"block_oxidized",
	"block_oxidized_cut",
	"grate_oxidized",
	"chiseled_oxidized",
	"bulb_off_oxidized"
}

for _, w in ipairs(waxable_blocks) do
	minetest.register_craft({
		output = "vlf_copper:waxed_"..w,
		recipe = {
			{ "vlf_copper:"..w, "vlf_honey:honeycomb" },
		},
	})
end

local cuttable_blocks = {
	"block",
	"waxed_block",
	"block_exposed",
	"waxed_block_exposed",
	"block_weathered",
	"waxed_block_weathered",
	"block_oxidized",
	"waxed_block_oxidized"
}

--[[for _, c in ipairs(cuttable_blocks) do
	vlf_stonecutter.register_recipe("vlf_copper:"..c, "vlf_copper:"..c.."_cut", 4)
	vlf_stonecutter.register_recipe("vlf_copper:"..c, "vlf_copper:"..c:gsub("block", "grate"), 4)
	vlf_stonecutter.register_recipe("vlf_copper:"..c, "vlf_copper:"..c:gsub("block", "chiseled"), 4)
	vlf_stonecutter.register_recipe("vlf_copper:"..c.."_cut", "vlf_copper:"..c:gsub("block", "chiseled"))
end]]

minetest.register_craft({
	output = "vlf_copper:copper_ingot 9",
	recipe = {
		{ "vlf_copper:block" },
	},
})

minetest.register_craft({
	output = "vlf_copper:raw_copper 9",
	recipe = {
		{ "vlf_copper:block_raw" },
	},
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_copper:copper_ingot",
	recipe = "vlf_copper:raw_copper",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_copper:copper_ingot",
	recipe = "vlf_copper:stone_with_copper",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "vlf_copper:block",
	recipe = "vlf_copper:block_raw",
	cooktime = 90,
})
