-- Allow items or nodes to be marked as WIP (Work In Progress) or Experimental

local S = minetest.get_translator(minetest.get_current_modname())

vlf_wip = {}
vlf_wip.registered_wip_items = {}
vlf_wip.registered_experimental_items = {}

function vlf_wip.register_wip_item(itemname)
	table.insert(vlf_wip.registered_wip_items, itemname) --Only check for valid node name after mods loaded
end

function vlf_wip.register_experimental_item(itemname)
	table.insert(vlf_wip.registered_experimental_items, itemname)
end

minetest.register_on_mods_loaded(function()
	for _,name in pairs(vlf_wip.registered_wip_items) do
		local def = minetest.registered_items[name]
		if not def then
			minetest.log("error", "[vlf_wip] Unknown item: "..name)
			break
		end
		local new_description = def.description
		if new_description == "" then
			new_description = name
		end
		new_description = new_description .. "\n"..minetest.colorize(vlf_colors.RED, S("(WIP)"))
		minetest.override_item(name, {description = new_description})
	end

	for _,name in pairs(vlf_wip.registered_experimental_items) do
		local def = minetest.registered_items[name]
		if not def then
			minetest.log("error", "[vlf_wip] Unknown item: "..name)
			break
		end
		local new_description = def.description
		if new_description == "" then
			new_description = name
		end
		new_description = new_description .. "\n"..minetest.colorize(vlf_colors.YELLOW, S("(Temporary)"))
		minetest.override_item(name, {description = new_description})
	end
end)
