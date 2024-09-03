-- Item modifiers are lists of item functions
-- [
--    <item function 1>
--    <item function 2>
-- ]
-- The item functions are applied in order to an itemstack when applying a modifier
vl_loot.modifier = {}

local function apply_item_function(function_table, itemstack, loot_context)
	-- Only apply function if predicates pass
	if not vl_loot.predicate.check_predicates(function_table.conditions, loot_context) then
		return itemstack
	end

	-- TODO: Make this work
	-- Item functions (* means implemented, (*) means partially implemented):
	--[[
			apply_bonus
			copy_components
			copy_custom_data
			copy_name
			copy_state
		(*)	enchant_randomly
			enchant_with_levels
			exploration_map
			explosion_decay
			fill_player_head
			filtered
			furnace_smelt
			limit_count
			enchanted_count_increase
			modify_contents
			reference
			sequence
			set_attributes
			set_banner_pattern
			set_book_cover
			set_components
			set_contents
		*	set_count
			set_custom_data
			set_custom_model_data
			set_damage
			set_enchantments
			set_fireworks
			set_firework_explosion
			set_instrument
			set_item
			set_loot_table
			set_lore
			set_name
			set_entity_effect
			set_stew_entity_effect
			set_writable_book_pages
			set_written_book_pages
			toggle_tooltips
	]]
	local func_type = function_table["function"]
	-- TODO: Make all loot deterministic
	if func_type == "set_count" then
		local count = vl_loot.number_provider.evaluate(function_table.count, loot_context)
		if function_table.add then
			count = count + itemstack:get_count()
		end
		itemstack:set_count(count)
		return itemstack
	elseif func_type == "enchant_randomly" then
		local enchanted_itemstack = vlf_enchanting.enchant_uniform_randomly(itemstack, {"soul_speed"})
		return enchanted_itemstack
	else
		error("Invalid item modifier: " .. tostring(func_type))
	end
end

-- Modify an itemstack based on an item modifier
-- Returns the resulting itemstack
local function apply_item_modifier(modifier_table, itemstack, loot_context)
    if modifier_table == nil then return itemstack end
	for _, function_table in ipairs(modifier_table) do
		itemstack = apply_item_function(function_table, itemstack, loot_context)
	end
	return itemstack
end

vl_loot.modifier.apply_item_modifier = apply_item_modifier
