local S = minetest.get_translator(minetest.get_current_modname())

-- Armor
tt.register_snippet(function(itemstring)
	--local def = minetest.registered_items[itemstring]
	local s = ""
	local head = minetest.get_item_group(itemstring, "armor_head")
	local torso = minetest.get_item_group(itemstring, "armor_torso")
	local legs = minetest.get_item_group(itemstring, "armor_legs")
	local feet = minetest.get_item_group(itemstring, "armor_feet")
	if head > 0 then
		s = s .. S("Head armor")
	end
	if torso > 0 then
		s = s .. S("Torso armor")
	end
	if legs > 0 then
		s = s .. S("Legs armor")
	end
	if feet > 0 then
		s = s .. S("Feet armor")
	end
	return s ~= "" and s or nil
end)
tt.register_snippet(function(itemstring, _, itemstack)
	--local def = minetest.registered_items[itemstring]
	local s = ""
	local use = minetest.get_item_group(itemstring, "vlf_armor_uses")
	local pts = minetest.get_item_group(itemstring, "vlf_armor_points")
	if pts > 0 then
		s = s .. S("Armor points: @1", pts)
		s = s .. "\n"
	end
	if itemstack then
		local unbreaking = vlf_enchanting.get_enchantment(itemstack, "unbreaking")
		if unbreaking > 0 then
			use = math.floor(use / (0.6 + 0.4 / (unbreaking + 1)))
		end
	end
	if use > 0 then
		s = s .. S("Armor durability: @1", use)
	end
	return s ~= "" and s or nil
end)
-- Horse armor
tt.register_snippet(function(itemstring)
	local armor_g = minetest.get_item_group(itemstring, "horse_armor")
	if armor_g and armor_g > 0 then
		return S("Protection: @1%", 100 - armor_g)
	end
end)

tt.register_snippet(function(itemstring)
	local def = minetest.registered_items[itemstring]
	local s = ""
	if def.groups.eatable and def.groups.eatable > 0 then
		s = s .. S("Hunger points: +@1", def.groups.eatable)
	end
	if def._vlf_saturation and def._vlf_saturation > 0 then
		if s ~= "" then
			s = s .. "\n"
		end
		s = s .. S("Saturation points: +@1", string.format("%.1f", def._vlf_saturation))
	end
	return s ~= "" and s or nil
end)

tt.register_snippet(function(itemstring)
	--local def = minetest.registered_items[itemstring]
	if minetest.get_item_group(itemstring, "crush_after_fall") == 1 then
		return S("Deals damage when falling"), vlf_colors.YELLOW
	end
end)

tt.register_snippet(function(itemstring)
	local def = minetest.registered_items[itemstring]
	if def.groups.place_flowerlike == 1 then
		return S("Grows on grass blocks or dirt")
	elseif def.groups.place_flowerlike == 2 then
		return S("Grows on grass blocks, podzol, dirt or coarse dirt")
	end
end)

tt.register_snippet(function(itemstring)
	local def = minetest.registered_items[itemstring]
	if def.groups.flammable then
		return S("Flammable")
	end
end)

tt.register_snippet(function(itemstring)
	if itemstring == "vlf_heads:zombie" then
		return S("Zombie view range: -50%")
	elseif itemstring == "vlf_heads:skeleton" then
		return S("Skeleton view range: -50%")
	elseif itemstring == "vlf_heads:creeper" then
		return S("Creeper view range: -50%")
	end
end)

tt.register_snippet(function(itemstring, _, itemstack)
	if itemstring:sub(1, 23) == "vlf_fishing:fishing_rod" or itemstring:sub(1, 12) == "vlf_bows:bow" then
		return S("Durability: @1", S("@1 uses", vlf_util.calculate_durability(itemstack or ItemStack(itemstring))))
	end
end)


-- Potions info
tt.register_snippet(function(itemstring, _, itemstack)
	if not itemstack then return end
	local def = itemstack:get_definition()
	if def.groups._vlf_entity_effect ~= 1 then return end

	local s = ""
	local meta = itemstack:get_meta()
	local potency = meta:get_int("vlf_entity_effects:entity_effect_potent")
	local plus = meta:get_int("vlf_entity_effects:entity_effect_plus")
	local sl_factor = 1
	if def.groups.splash_entity_effect == 1 then
		sl_factor = vlf_entity_effects.SPLASH_FACTOR
	elseif def.groups.ling_entity_effect == 1 then
		sl_factor = vlf_entity_effects.LINGERING_FACTOR
	end
	if def._dynamic_tt then s = s.. def._dynamic_tt((potency+1)*sl_factor).. "\n" end
	local entity_effects = def._entity_effect_list
	if entity_effects then
		local entity_effect
		local dur
		local timestamp
		local ef_level
		local roman_lvl
		local factor
		local ef_tt
		for name, details in pairs(entity_effects) do
			entity_effect = vlf_entity_effects.registered_entity_effects[name]
			dur = vlf_entity_effects.duration_from_details (details, potency,
								 plus, sl_factor)
			timestamp = math.floor(dur/60)..string.format(":%02d",math.floor(dur % 60))
			ef_level = vlf_entity_effects.level_from_details (details, potency)
			if ef_level > 1 then roman_lvl = " ".. vlf_util.to_roman(ef_level)
			else roman_lvl = "" end
			s = s.. entity_effect.description.. roman_lvl.. " (".. timestamp.. ")\n"
			if entity_effect.uses_factor then factor = entity_effect.level_to_factor(ef_level) end
			if entity_effect.get_tt then ef_tt = minetest.colorize("grey", entity_effect.get_tt(factor)) else ef_tt = "" end
			if ef_tt ~= "" then s = s.. ef_tt.. "\n" end
		end
	end
	return s:trim()
end)
