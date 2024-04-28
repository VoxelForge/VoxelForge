-- Monster eggs!
-- Blocks which spawn silverfish when destroyed.

local S = minetest.get_translator(minetest.get_current_modname())


-- Template function for registering monster egg blocks
local function register_block(name, description)

	local def = table.copy(minetest.registered_nodes[name])

	def.description = description
	table.update(def.groups, {spawns_silverfish = 1})
	def.drop = ""
	def.after_dig_node = function (pos, oldnode, oldmetadata, digger)
		if not minetest.is_creative_enabled("") then
			minetest.add_entity(pos, "mobs_mc:silverfish")
		end
	end
	def._tt_help = S("Hides a silverfish")
	def._doc_items_longdesc = S([[
		An infested block is a block from which a silverfish will pop out when it is broken.
		It looks identical to its normal counterpart.
	]])
	def._mcl_hardness = def._mcl_hardness / 2
	def._mcl_blast_resistance = 0.75

	local base = name:gsub("^[_%w]*:", "")

	minetest.register_node("mcl_monster_eggs:monster_egg_"..base, def)
end

-- Register all the monster egg blocks
register_block("mcl_core:stone", S("Infested Stone"))
register_block("mcl_core:cobble", S("Infested Cobblestone"))
register_block("mcl_core:stonebrick", S("Infested Stone Bricks"))
register_block("mcl_core:stonebrickcracked", S("Infested Cracked Stone Bricks"))
register_block("mcl_core:stonebrickmossy", S("Infested Mossy Stone Bricks"))
register_block("mcl_core:stonebrickcarved", S("Infested Chiseled Stone Bricks"))
