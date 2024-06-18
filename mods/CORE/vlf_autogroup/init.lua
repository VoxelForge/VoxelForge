--[[
This is one part of a mod to replicate the digging times from Minecraft.  This
part only exposes a function to register digging groups.  The rest of the mod is
implemented and documented in the _vlf_autogroup.

The mod is split up into two parts, vlf_autogroup and _vlf_autogroup.
vlf_autogroup contains the API functions used to register custom digging groups.
_vlf_autogroup contains most of the code.  The leading underscore in the name
"_vlf_autogroup" is used to force Minetest to load that part of the mod as late
as possible.  Minetest loads mods in reverse alphabetical order.
--]]
vlf_autogroup = {}
vlf_autogroup.registered_diggroups = {}

assert(minetest.get_modpath("_vlf_autogroup"), "This mod requires the mod _vlf_autogroup to function")

-- Register a group as a digging group.
--
-- Parameters:
-- group - Name of the group to register as a digging group
-- def - Table with information about the diggroup (defaults to {} if unspecified)
--
-- Values in def:
-- level - If specified it is an array containing the names of the different
--         digging levels the digging group supports.
function vlf_autogroup.register_diggroup(group, def)
	vlf_autogroup.registered_diggroups[group] = def or {}
end
