-- Monster eggs!
-- Blocks which spawn silverfish when destroyed.

local S = minetest.get_translator(minetest.get_current_modname())

vlc_monster_eggs = {}

-- Template function for registering monster egg blocks
local function register_infested_block(name, description)

	local olddef = minetest.registered_nodes[name]
	local newdef = table.merge(olddef, {
		description = description,
		_tt_help = S("Hides a silverfish"),
		_doc_items_longdesc = S([[
			An infested block is a block from which a silverfish will pop out when it is broken.
			It looks identical to its normal counterpart.
		]]),
		groups = table.merge(olddef.groups, {spawns_silverfish = 1}),
		drop = "",
		_vlc_silk_touch_drop = {name},
		_vlc_hardness = olddef._vlc_hardness / 2,
		_vlc_blast_resistance = 0.75,
		after_dig_node = function (pos, oldnode, oldmetadata, digger)
			local itemstack = digger:get_wielded_item()
			if not vlc_enchanting.has_enchantment(itemstack, "silk_touch")
			and not minetest.is_creative_enabled("") then
				minetest.add_entity(pos, "mobs_mc:silverfish")
			end
		end,
		on_blast = function (pos, intensity)
			minetest.remove_node(pos)
			if not minetest.is_creative_enabled("") then
				minetest.add_entity(pos, "mobs_mc:silverfish")
			end
		end
	})
	newdef._vlc_stonecutter_recipes = nil
	local base = name:gsub("^[_%w]*:", "")
	minetest.register_node(":vlc_monster_eggs:monster_egg_"..base, newdef)
end

vlc_monster_eggs.register_infested_block = register_infested_block

-- Register all the monster egg blocks
register_infested_block("vlc_core:stone", S("Infested Stone"))
register_infested_block("vlc_core:cobble", S("Infested Cobblestone"))
register_infested_block("vlc_core:stonebrick", S("Infested Stone Bricks"))
register_infested_block("vlc_core:stonebrickcracked", S("Infested Cracked Stone Bricks"))
register_infested_block("vlc_core:stonebrickmossy", S("Infested Mossy Stone Bricks"))
register_infested_block("vlc_core:stonebrickcarved", S("Infested Chiseled Stone Bricks"))
