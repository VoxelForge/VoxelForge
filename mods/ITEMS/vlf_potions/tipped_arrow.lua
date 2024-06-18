local S = minetest.get_translator(minetest.get_current_modname())

local arrow_def = minetest.registered_items["vlf_bows:arrow"]
local arrow_longdesc = arrow_def._doc_items_longdesc or ""
local arrow_tt = arrow_def._tt_help or ""

function vlf_potions.register_arrow(name, desc, color, def)

	minetest.register_craftitem("vlf_potions:"..name.."_arrow",table.merge(arrow_def, {
		description = desc,
		_tt_help = arrow_tt .. "\n" .. (def.tt or ""),
		_doc_items_longdesc = arrow_longdesc .. "\n" ..
			S("This particular arrow is tipped and will give an effect when it hits a player or mob.") .. "\n" ..
			(def.longdesc or ""),
		inventory_image = "vlf_bows_arrow_inv.png^(vlf_potions_arrow_inv.png^[colorize:"..color..":100)",
		groups = { ammo=1, ammo_bow=1, brewitem=1},
	}))

	local ARROW_ENTITY = table.copy(minetest.registered_entities["vlf_bows:arrow_entity"])
	ARROW_ENTITY._extra_hit_func = def.potion_fun
	ARROW_ENTITY._itemstring = "vlf_potions:"..name.."_arrow"

	minetest.register_entity("vlf_potions:"..name.."_arrow_entity", ARROW_ENTITY)

	minetest.register_craft({
		output = "vlf_potions:"..name.."_arrow 8",
		recipe = {
			{"vlf_bows:arrow","vlf_bows:arrow","vlf_bows:arrow"},
			{"vlf_bows:arrow","vlf_potions:"..name.."_lingering","vlf_bows:arrow"},
			{"vlf_bows:arrow","vlf_bows:arrow","vlf_bows:arrow"}
		}
	})

	if minetest.get_modpath("doc_identifier") then
		doc.sub.identifier.register_object("vlf_bows:arrow_entity", "craftitems", "vlf_bows:arrow")
	end
end
