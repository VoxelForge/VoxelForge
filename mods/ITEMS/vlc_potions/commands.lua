local S = minetest.get_translator(minetest.get_current_modname())

-- ░█████╗░██╗░░██╗░█████╗░████████╗  ░█████╗░░█████╗░███╗░░░███╗███╗░░░███╗░█████╗░███╗░░██╗██████╗░░██████╗
-- ██╔══██╗██║░░██║██╔══██╗╚══██╔══╝  ██╔══██╗██╔══██╗████╗░████║████╗░████║██╔══██╗████╗░██║██╔══██╗██╔════╝
-- ██║░░╚═╝███████║███████║░░░██║░░░  ██║░░╚═╝██║░░██║██╔████╔██║██╔████╔██║███████║██╔██╗██║██║░░██║╚█████╗░
-- ██║░░██╗██╔══██║██╔══██║░░░██║░░░  ██║░░██╗██║░░██║██║╚██╔╝██║██║╚██╔╝██║██╔══██║██║╚████║██║░░██║░╚═══██╗
-- ╚█████╔╝██║░░██║██║░░██║░░░██║░░░  ╚█████╔╝╚█████╔╝██║░╚═╝░██║██║░╚═╝░██║██║░░██║██║░╚███║██████╔╝██████╔╝
-- ░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░  ░╚════╝░░╚════╝░╚═╝░░░░░╚═╝╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░╚═════╝░


local get_chat_function = {}

get_chat_function["poison"] = vlc_potions.poison_func
get_chat_function["regeneration"] = vlc_potions.regeneration_func
get_chat_function["invisibility"] = vlc_potions.invisiblility_func
get_chat_function["fire_resistance"] = vlc_potions.fire_resistance_func
get_chat_function["night_vision"] = vlc_potions.night_vision_func
get_chat_function["water_breathing"] = vlc_potions.water_breathing_func
get_chat_function["leaping"] = vlc_potions.leaping_func
get_chat_function["swiftness"] = vlc_potions.swiftness_func
get_chat_function["heal"] = vlc_potions.healing_func
get_chat_function["bad_omen"] = vlc_potions.bad_omen_func
get_chat_function["withering"] = vlc_potions.withering_func

minetest.register_chatcommand("effect",{
	params = S("<effect> <duration> [<factor>]"),
	description = S("Add a status effect to yourself. Arguments: <effect>: name of status effect, e.g. poison. <duration>: duration in seconds. <factor>: effect strength multiplier (1 = 100%)"),
	privs = {server = true},
	func = function(name, params)

		local P = {}
		local i = 0
		for str in string.gmatch(params, "([^ ]+)") do
			i = i + 1
			P[i] = str
		end

		if not P[1] then
			return false, S("Missing effect parameter!")
		elseif not tonumber(P[2]) then
			return false, S("Missing or invalid duration parameter!")
		elseif P[3] and not tonumber(P[3]) then
			return false, S("Invalid factor parameter!")
		end
		-- Default factor = 1
		if not P[3] then
			P[3] = 1.0
		end

		if get_chat_function[P[1]] then
			get_chat_function[P[1]](minetest.get_player_by_name(name), tonumber(P[3]), tonumber(P[2]))
			return true
		else
			return false, S("@1 is not an available status effect.", P[1])
		end

	 end,
})
