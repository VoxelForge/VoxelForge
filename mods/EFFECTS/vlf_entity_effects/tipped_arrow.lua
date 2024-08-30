local S = minetest.get_translator(minetest.get_current_modname())

local arrow_def = minetest.registered_items["vlf_bows:arrow"]
local arrow_longdesc = arrow_def._doc_items_longdesc or ""
local arrow_tt = arrow_def._tt_help or ""

local function arrow_image(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return {"vlf_bows_arrow.png^(vlf_bows_arrow_overlay.png^[colorize:"..colorstring..":"..tostring(opacity)..")"}
end

function vlf_entity_effects.register_arrow(name, desc, color, def)
	local tt = def._tt or ""
	local groups = {ammo=1, ammo_bow=1, brewitem=1, _vlf_entity_effect=1}
	if def.nocreative then groups.not_in_creative_inventory = 1 end
	minetest.register_craftitem("vlf_entity_effects:"..name.."_arrow", table.merge (arrow_def, {
		description = desc,
		_tt_help = arrow_tt .. "\n" .. tt,
		_dynamic_tt = def._dynamic_tt,
		_vlf_filter_description = vlf_entity_effects.filter_entity_effect_description,
		_doc_items_longdesc = arrow_longdesc .. "\n" ..
			S("This particular arrow is tipped and will give an effect when it hits a player or mob.") .. "\n" ..
		    (def.longdesc or ""),
		_effect_list = def._effect_list,
		uses_level = def.uses_level,
		has_potent = def.has_potent,
		has_plus = def.has_plus,
		_default_potent_level = def._default_potent_level,
		_default_extend_level = def._default_extend_level,
		inventory_image = "vlf_bows_arrow_inv.png^(vlf_entity_effects_arrow_inv.png^[colorize:"..color..":100)",
		groups = groups,
	}))

	local ARROW_ENTITY = table.copy(minetest.registered_entities["vlf_bows:arrow_entity"])
	ARROW_ENTITY.initial_properties.textures = arrow_image (color, 100)
	ARROW_ENTITY._itemstring = "vlf_entity_effects:"..name.."_arrow"

	function ARROW_ENTITY._extra_hit_func (obj)
	    local potency, plus = 0, 0
	    if def._effect_list then
		local ef_level
		local dur

		for name, details in pairs(def._effect_list) do
		    ef_level = vlf_entity_effects.level_from_details (details, potency)
		    dur = vlf_entity_effects.duration_from_details (details, potency,
							     plus,
							     vlf_entity_effects.SPLASH_FACTOR)
		    vlf_entity_effects.give_effect_by_level(name, obj, ef_level, dur)
		end
	    end
	    if def.custom_effect then def.custom_effect(obj, potency+1) end
	end

	minetest.register_entity("vlf_entity_effects:"..name.."_arrow_entity", ARROW_ENTITY)

	minetest.register_craft({
		output = "vlf_entity_effects:"..name.."_arrow 8",
		recipe = {
			{"vlf_bows:arrow","vlf_bows:arrow","vlf_bows:arrow"},
			{"vlf_bows:arrow","vlf_entity_effects:"..name.."_lingering","vlf_bows:arrow"},
			{"vlf_bows:arrow","vlf_bows:arrow","vlf_bows:arrow"}
		}
	})

	if minetest.get_modpath("doc_identifier") then
		doc.sub.identifier.register_object("vlf_bows:arrow_entity", "craftitems", "vlf_bows:arrow")
	end
end
