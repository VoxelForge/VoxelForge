-- Legacy (mcl2) "mcl_dye" itemstrings
minetest.register_alias("mcl_dye:grey","vlf_dyes:silver")
minetest.register_alias("mcl_dye:dark_grey","vlf_dyes:grey")
minetest.register_alias("mcl_dye:violet","vlf_dyes:purple")
minetest.register_alias("mcl_dye:lightblue","vlf_dyes:light_blue")
minetest.register_alias("mcl_dye:cyan","vlf_dyes:cyan")
minetest.register_alias("mcl_dye:dark_green","vlf_dyes:green")
minetest.register_alias("mcl_dye:green","vlf_dyes:lime")
minetest.register_alias("mcl_dye:yellow","vlf_dyes:yellow")
minetest.register_alias("mcl_dye:orange","vlf_dyes:orange")
minetest.register_alias("mcl_dye:red","vlf_dyes:red")
minetest.register_alias("mcl_dye:magenta","vlf_dyes:magenta")
minetest.register_alias("mcl_dye:pink","vlf_dyes:pink")

-- these 4 used to double as other items, aliases to the old items
-- are provided so people do not loose their hard earned lapis etc.
minetest.register_alias("mcl_dye:white","vlf_bone_meal:bone_meal")
minetest.register_alias("mcl_dye:black","vlf_mobitems:ink_sac")
minetest.register_alias("mcl_dye:blue","vlf_core:lapis")
minetest.register_alias("mcl_dye:brown","vlf_cocoas:cocoa_beans")

-- Old messy colornames - not following the color naming scheme most of the codebase uses
minetest.register_alias("mcl_dyes:dark_green","vlf_dyes:green")
minetest.register_alias("mcl_dyes:dark_grey","vlf_dyes:grey")
minetest.register_alias("mcl_dyes:violet","vlf_dyes:purple")
minetest.register_alias("mcl_dyes:lightblue","vlf_dyes:light_blue")

function register_alias_if_not_exists(alias, name)
	if not minetest.registered_nodes[alias] then
		minetest.register_alias(alias, name)
	end
end
minetest.register_on_mods_loaded(function()
	for name, cdef in pairs(vlf_dyes.colors) do
		if cdef.mcl2 then
			register_alias_if_not_exists("mcl_stairs:slab_concrete_"..cdef.mcl2, "vlf_stairs:slab_concrete_"..name)
			register_alias_if_not_exists("mcl_stairs:slab_concrete_"..cdef.mcl2.."_double", "vlf_stairs:slab_concrete_"..name.."_double")
			register_alias_if_not_exists("mcl_stairs:stair_concrete_"..cdef.mcl2, "vlf_stairs:stair_concrete_"..name)
			register_alias_if_not_exists("mcl_stairs:stair_concrete_"..cdef.mcl2.."_inner", "vlf_stairs:stair_concrete_"..name.."_inner")
			register_alias_if_not_exists("mcl_stairs:stair_concrete_"..cdef.mcl2.."_outer", "vlf_stairs:stair_concrete_"..name.."_outer")
		end
	end
end)
