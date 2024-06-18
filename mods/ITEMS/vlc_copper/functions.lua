
minetest.register_abm({
	label = "Oxidatize Nodes",
	nodenames = { "group:oxidizable" },
	interval = 500,
	chance = 3,
	action = function(pos, node)
		local def = minetest.registered_nodes[node.name]
		if def and def._vlc_oxidized_variant then
			if def.groups.door == 1 then
				if node.name:find("_b_") then
					local top_pos = { x = pos.x, y = pos.y + 1, z = pos.z }
					minetest.swap_node(top_pos, { name = def._vlc_oxidized_variant:gsub("_b_", "_t_"), param2 = node.param2 })
				elseif node.name:find("_t_") then
					local bot_pos = { x = pos.x, y = pos.y - 1, z = pos.z }
					minetest.swap_node(bot_pos, { name = def._vlc_oxidized_variant:gsub("_t_", "_b_"), param2 = node.param2 })
				end
			end
			minetest.swap_node(pos, { name = def._vlc_oxidized_variant, param2 = node.param2 })
		end
	end,
})

function vlc_copper.register_oxidation_and_scraping(mod_name, subname, decay_chain)
	local item, oxidized_item
	local door_item, door_oxidized_item
	for i = 1, #decay_chain - 1 do
		item = mod_name..":"..subname..decay_chain[i]
		oxidized_item = mod_name..":"..subname..decay_chain[i + 1]
		minetest.override_item(item, {_vlc_oxidized_variant = oxidized_item})
		minetest.override_item(oxidized_item, {_vlc_stripped_variant = item})
		if subname:find("stair") then
			minetest.override_item(item.."_inner", {_vlc_oxidized_variant = oxidized_item.."_inner"})
			minetest.override_item(item.."_outer", {_vlc_oxidized_variant = oxidized_item.."_outer"})
			minetest.override_item(oxidized_item.."_inner", {_vlc_stripped_variant = item.."_inner"})
			minetest.override_item(oxidized_item.."_outer", {_vlc_stripped_variant = item.."_outer"})
		elseif subname:find("slab") then
			minetest.override_item(item.."_double", {_vlc_oxidized_variant = oxidized_item.."_double"})
			minetest.override_item(item.."_top", {_vlc_oxidized_variant = oxidized_item.."_top"})
			minetest.override_item(oxidized_item.."_double", {_vlc_stripped_variant = item.."_double"})
			minetest.override_item(oxidized_item.."_top", {_vlc_stripped_variant = item.."_top"})
		elseif subname:find("trapdoor") then
			minetest.override_item(item.."_open", {_vlc_oxidized_variant = oxidized_item.."_open"})
			minetest.override_item(oxidized_item.."_open", {_vlc_stripped_variant = item.."_open"})
		elseif subname == "door" then
			minetest.override_item(item.."_b_1", {_vlc_oxidized_variant = oxidized_item.."_b_1"})
			minetest.override_item(oxidized_item.."_b_1", {_vlc_stripped_variant = item.."_b_1"})
			minetest.override_item(item.."_t_1", {_vlc_oxidized_variant = oxidized_item.."_t_1"})
			minetest.override_item(oxidized_item.."_t_1", {_vlc_stripped_variant = item.."_t_1"})
			minetest.override_item(item.."_b_2", {_vlc_oxidized_variant = oxidized_item.."_b_2"})
			minetest.override_item(oxidized_item.."_b_2", {_vlc_stripped_variant = item.."_b_2"})
			minetest.override_item(item.."_t_2", {_vlc_oxidized_variant = oxidized_item.."_t_2"})
			minetest.override_item(oxidized_item.."_t_2", {_vlc_stripped_variant = item.."_t_2"})
		end
	end
end

function vlc_copper.register_waxing_and_scraping(mod_name, subname, decay_chain)
	local waxed_item, unwaxed_item
	for i = 1, #decay_chain do
		waxed_item = mod_name..":"..subname..decay_chain[i]
		unwaxed_item = mod_name..":"..subname:gsub("waxed_", "")..decay_chain[i]
		minetest.override_item(waxed_item, {_vlc_stripped_variant = unwaxed_item})
		minetest.override_item(unwaxed_item, {_vlc_waxed_variant = waxed_item})
		if subname:find("stair") then
			minetest.override_item(waxed_item.."_inner", {_vlc_stripped_variant = unwaxed_item.."_inner"})
			minetest.override_item(waxed_item.."_outer", {_vlc_stripped_variant = unwaxed_item.."_outer"})
			minetest.override_item(unwaxed_item.."_inner", {_vlc_waxed_variant = waxed_item.."_inner"})
			minetest.override_item(unwaxed_item.."_outer", {_vlc_waxed_variant = waxed_item.."_outer"})
		elseif subname:find("slab") then
			minetest.override_item(waxed_item.."_double", {_vlc_stripped_variant = unwaxed_item.."_double"})
			minetest.override_item(waxed_item.."_top", {_vlc_stripped_variant = unwaxed_item.."_top"})
			minetest.override_item(unwaxed_item.."_double", {_vlc_waxed_variant = waxed_item.."_double"})
			minetest.override_item(unwaxed_item.."_top", {_vlc_waxed_variant = waxed_item.."_top"})
		elseif subname:find("trapdoor") then
			minetest.override_item(waxed_item.."_open", {_vlc_stripped_variant = unwaxed_item.."_open"})
			minetest.override_item(unwaxed_item.."_open", {_vlc_waxed_variant = waxed_item.."_open"})
		elseif subname == "waxed_door" then
			minetest.override_item(waxed_item.."_b_1", {_vlc_stripped_variant = unwaxed_item.."_b_1"})
			minetest.override_item(unwaxed_item.."_b_1", {_vlc_waxed_variant = waxed_item.."_b_1"})
			minetest.override_item(waxed_item.."_t_1", {_vlc_stripped_variant = unwaxed_item.."_t_1"})
			minetest.override_item(unwaxed_item.."_t_1", {_vlc_waxed_variant = waxed_item.."_t_1"})
			minetest.override_item(waxed_item.."_b_2", {_vlc_stripped_variant = unwaxed_item.."_b_2"})
			minetest.override_item(unwaxed_item.."_b_2", {_vlc_waxed_variant = waxed_item.."_b_2"})
			minetest.override_item(waxed_item.."_t_2", {_vlc_stripped_variant = unwaxed_item.."_t_2"})
			minetest.override_item(unwaxed_item.."_t_2", {_vlc_waxed_variant = waxed_item.."_t_2"})
		end
	end
end

local cut_decay_chain = {
	"_cut",
	"_exposed_cut",
	"_weathered_cut",
	"_oxidized_cut"
}
local doors_decay_chain = {
	"",
	--"exposed_",
	--"weathered_",
	--"oxidized_"
}

vlc_copper.register_oxidation_and_scraping("vlc_stairs", "stair_copper", cut_decay_chain)
vlc_copper.register_oxidation_and_scraping("vlc_stairs", "slab_copper", cut_decay_chain)
vlc_copper.register_oxidation_and_scraping("vlc_copper", "trapdoor", doors_decay_chain)
vlc_copper.register_oxidation_and_scraping("vlc_copper", "exposed_trapdoor", doors_decay_chain)
vlc_copper.register_oxidation_and_scraping("vlc_copper", "weathered_trapdoor", doors_decay_chain)
vlc_copper.register_oxidation_and_scraping("vlc_copper", "oxidized_trapdoor", doors_decay_chain)
--vlc_copper.register_oxidation_and_scraping("vlc_copper", "copper_door", doors_decay_chain)
vlc_copper.register_waxing_and_scraping("vlc_stairs", "stair_waxed_copper", cut_decay_chain)
vlc_copper.register_waxing_and_scraping("vlc_stairs", "slab_waxed_copper", cut_decay_chain)
--vlc_copper.register_waxing_and_scraping("vlc_copper", "waxed_trapdoor", doors_decay_chain)
--vlc_copper.register_waxing_and_scraping("vlc_copper", "waxed_copper_door", doors_decay_chain)
