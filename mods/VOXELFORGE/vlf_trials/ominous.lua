local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

local function register_ominous_bottles()
	for i = 1, 5 do
		local item_name = "vlf_trials:ominous_bottle_" .. i
		minetest.register_craftitem(item_name, {
			description = S("Ominous Bottle"),
			inventory_image = "vlf_trials_bottle.png^vlf_trials_ominous_icon.png",
			wield_image = "vlf_trials_bottle.png^vlf_trials_ominous_icon.png",
			stack_max = 64,
			groups = { rare = 1 },
			on_place = function(itemstack, user)
				mcl_potions.give_effect("bad_omen", user, 1*i, 6000)
				itemstack:take_item()
				return itemstack
			end,
			on_secondary_use = function(itemstack, user)
				mcl_potions.give_effect("bad_omen", user, 1*i, 6000)
				itemstack:take_item()
				return itemstack
			end,
		})
	end
end
register_ominous_bottles()

mcl_potions.register_effect({
	name = "trial_omen",
	description = S("Trial Omen"),
	particle_color = "#44FF44",
})
