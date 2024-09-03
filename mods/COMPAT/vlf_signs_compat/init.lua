
--these are the "rotation strings" of the old sign rotation scheme
local rotkeys = {
	"22_5",
	"45",
	"67_5"
}
--this is a translation table for the old sign rotation scheme to degrotate
--the first level is the itemstring part and the second level represents
--the facedir param2 (+1) mapped to the degrotate param2
local nidp2_degrotate = {
	["22_5"] = {
		225,
		165,
		105,
		45,
	},
	["45"] = {
		210,
		150,
		90,
		30,
	},
	["67_5"] = {
		195,
		135,
		75,
		15,
	}
}
local vlfstandingsigns = {}
vlfstandingsigns["vlf_signs:standing_sign"] = "vlf_signs:standing_sign_oak"
vlfstandingsigns["vlf_signs:standing_sign_acaciawood"] = "vlf_signs:standing_sign_acacia"
vlfstandingsigns["vlf_signs:standing_sign_junglewood"] = "vlf_signs:standing_sign_jungle"
vlfstandingsigns["vlf_signs:standing_sign_birchwood"] = "vlf_signs:standing_sign_birch"
vlfstandingsigns["vlf_signs:standing_sign_darkwood"] = "vlf_signs:standing_sign_dark_oak"
vlfstandingsigns["vlf_signs:standing_sign_sprucewood"] = "vlf_signs:standing_sign_spruce"
vlfstandingsigns["vlf_signs:standing_sign_mangrove_wood"] = "vlf_signs:standing_sign_mangrove"
vlfstandingsigns["vlf_signs:standing_sign_crimson_hyphae_wood"] = "vlf_signs:standing_sign_crimson"
vlfstandingsigns["vlf_signs:standing_sign_warped_hyphae_wood"] = "vlf_signs:standing_sign_warped"
vlfstandingsigns["vlf_signs:standing_sign_cherrywood"] = "vlf_signs:standing_sign_cherry_blossom"

local vlfrotsigns = {}

for _,v in pairs(rotkeys) do
	vlfrotsigns["vlf_signs:standing_sign"..v] = "vlf_signs:standing_sign_oak"
	vlfrotsigns["vlf_signs:standing_sign"..v.."_acaciawood"] = "vlf_signs:standing_sign_acacia"
	vlfrotsigns["vlf_signs:standing_sign"..v.."_junglewood"] = "vlf_signs:standing_sign_jungle"
	vlfrotsigns["vlf_signs:standing_sign"..v.."_birchwood"] = "vlf_signs:standing_sign_birch"
	vlfrotsigns["vlf_signs:standing_sign"..v.."_darkwood"] = "vlf_signs:standing_sign_dark_oak"
	vlfrotsigns["vlf_signs:standing_sign"..v.."_sprucewood"] = "vlf_signs:standing_sign_spruce"
	vlfrotsigns["vlf_signs:standing_sign"..v.."_mangrove_wood"] = "vlf_signs:standing_sign_mangrove"
	vlfrotsigns["vlf_signs:standing_sign"..v.."_crimson_hyphae_wood"] = "vlf_signs:standing_sign_crimson"
	vlfrotsigns["vlf_signs:standing_sign"..v.."_warped_hyphae_wood"] = "vlf_signs:standing_sign_warped"
	vlfrotsigns["vlf_signs:standing_sign"..v.."_cherrywood"] = "vlf_signs:standing_sign_cherry_blossom"
end

function vlf_signs.upgrade_sign_meta(pos)
		local m = minetest.get_meta(pos)
		local col = m:get_string("vlf_signs:text_color")
		local glo = m:get_string("vlf_signs:glowing_sign")
		if col ~= "" then
			m:set_string("color",col)
			m:set_string("vlf_signs:text_color","")
		end
		if glo == "true" then
			m:set_string("glow",glo)
		end
		if glo ~= "" then
			m:set_string("vlf_signs:glowing_sign","")
		end
		vlf_signs.get_text_entity (pos, true) -- the 2nd "true" arg means deleting the entity for respawn
end

function vlf_signs.upgrade_sign_rot(pos,node)
	local numsign = false

	for _,v in pairs(rotkeys) do
		if vlfrotsigns[node.name] then
			node.name = vlfrotsigns[node.name]
			node.param2 = nidp2_degrotate[v][node.param2 + 1]
			numsign = true
		elseif node.name:find(v) then
			node.name = node.name:gsub(v,"")
			node.param2 = nidp2_degrotate[v][node.param2 + 1]
			numsign = true
		end
	end

	if not numsign then
		if vlfstandingsigns[node.name] then
			node.name = vlfstandingsigns[node.name]
		end
		local def = minetest.registered_nodes[node.name]
		if def and def._vlf_sign_type == "standing" then
			if node.param2 == 1 or node.param2 == 121 then
				node.param2 = 180
			elseif node.param2 == 2 or node.param2 == 122 then
				node.param2 = 120
			elseif node.param2 == 3 or node.param2 == 123 then
				node.param2 = 60
			end
		end
	end
	minetest.swap_node(pos,node)
	vlf_signs.upgrade_sign_meta(pos)
	vlf_signs.update_sign(pos)
end

minetest.register_lbm({
	nodenames = {"group:sign"},
	name = ":vlf_signs:update_old_signs",
	label = "Update old signs",
	run_at_every_load = false,
	action = vlf_signs.upgrade_sign_rot,
})

for k,_ in pairs(vlfrotsigns) do table.insert(vlf_signs.old_rotnames, k) end
for k,_ in pairs(vlfstandingsigns) do table.insert(vlf_signs.old_rotnames, k) end
minetest.register_lbm({
	nodenames = vlf_signs.old_rotnames,
	name = ":vlf_signs:update_old_rotated_standing",
	label = "Update old standing rotated signs",
	run_at_every_load = true, --these nodes are supposed to completely be replaced
	action = vlf_signs.upgrade_sign_rot
})
