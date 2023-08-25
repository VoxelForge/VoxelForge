local S = minetest.get_translator(minetest.get_current_modname())

local YAW_OFFSET = -math.pi/2

local how_to_shoot = minetest.registered_items["mcl_bows:arrow"]._doc_items_usagehelp
local arrow_longdesc = minetest.registered_items["mcl_bows:arrow"]._doc_items_longdesc or ""
local arrow_tt = minetest.registered_items["mcl_bows:arrow"]._tt_help or ""

function mcl_potions.register_arrow(name, desc, color, def)

	local longdesc = def.longdesc or ""
	minetest.register_craftitem("mcl_potions:"..name.."_arrow", {
		description = desc,
		_tt_help = arrow_tt .. "\n" .. def.tt,
		_doc_items_longdesc = arrow_longdesc .. "\n" ..
			S("This particular arrow is tipped and will give an effect when it hits a player or mob.") .. "\n" ..
			longdesc,
		_doc_items_usagehelp = how_to_shoot,
		inventory_image = "mcl_bows_arrow_inv.png^(mcl_potions_arrow_inv.png^[colorize:"..color..":100)",
		groups = { ammo=1, ammo_bow=1, brewitem=1},
		_on_dispense = function(itemstack, dispenserpos, droppos, dropnode, dropdir)
			-- Shoot arrow
			local shootpos = vector.add(dispenserpos, vector.multiply(dropdir, 0.51))
			local yaw = math.atan2(dropdir.z, dropdir.x) + YAW_OFFSET
			mcl_bows.shoot_arrow(itemstack:get_name(), shootpos, dropdir, yaw, nil, 19, 3)
		end,
	})

	local ARROW_ENTITY = table.copy(minetest.registered_entities["mcl_bows:arrow_entity"])
	ARROW_ENTITY._extra_hit_func = def.potion_fun
	ARROW_ENTITY._itemstring = "mcl_potions:"..name.."_arrow"

	minetest.register_entity("mcl_potions:"..name.."_arrow_entity", ARROW_ENTITY)

	minetest.register_craft({
		output = "mcl_potions:"..name.."_arrow 8",
		recipe = {
			{"mcl_bows:arrow","mcl_bows:arrow","mcl_bows:arrow"},
			{"mcl_bows:arrow","mcl_potions:"..name.."_lingering","mcl_bows:arrow"},
			{"mcl_bows:arrow","mcl_bows:arrow","mcl_bows:arrow"}
		}
	})

	if minetest.get_modpath("doc_identifier") then
		doc.sub.identifier.register_object("mcl_bows:arrow_entity", "craftitems", "mcl_bows:arrow")
	end
end
