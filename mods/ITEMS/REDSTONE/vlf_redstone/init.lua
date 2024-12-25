vlf_redstone = {}

vlf_redstone._action_tab = {}

function vlf_redstone.register_action(func, node_names)
	for _, name in pairs(node_names) do
		vlf_redstone._action_tab[name] = vlf_redstone._action_tab[name] or {}
		table.insert(vlf_redstone._action_tab[name], func)
	end
end

vlf_redstone._solid_opaque_tab = {} -- True if node is opaque by name

--- Wireflags are numbers with binary representation YYYYXXXX where XXXX
--- determines if there is a visible connection in each of the four cardinal
--- directions and YYYY if the respective connection also goes up over the
--- neighbouring node. Order of the bits (right to left) are -z, +x, +z, -x.
--
-- This table contains wireflags by node name.
vlf_redstone._wireflag_tab = {}

minetest.register_on_mods_loaded(function()
	for name, ndef in pairs(minetest.registered_nodes) do
		if minetest.get_item_group(name, "opaque") ~= 0 and minetest.get_item_group(name, "solid") ~= 0 then
			vlf_redstone._solid_opaque_tab[name] = true
		end
	end
end)

local modpath = minetest.get_modpath(minetest.get_current_modname())
dofile(modpath.."/logic.lua")
dofile(modpath.."/eventqueue.lua")
dofile(modpath.."/wire.lua")
