
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
		15,
		165,
		105,
		225,
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
		15,
		225,
	}
}

minetest.register_lbm({
	nodenames = {"group:sign"},
	name = "mcl_signs:update_old_signs",
	label = "Update old signs",
	run_at_every_load = false,
	action = function(pos, node)
		local def = minetest.registered_nodes[node.name]
		if def and def._mcl_sign_type == "standing" then
			if node.param2 == 1 then
				node.param2 = 180
			elseif node.param2 == 2 then
				node.param2 = 120
			elseif node.param2 == 3 then
				node.param2 = 60
			end
		end
		minetest.swap_node(pos,node)
		mcl_signs.update_sign(pos)
	end
})

minetest.register_lbm({
	nodenames = mcl_signs.old_rotnames,
	name = "mcl_signs:update_old_rotated_standing",
	label = "Update old standing rotated signs",
	run_at_every_load = false,
	action = function(pos, node)
		for _,v in pairs(rotkeys) do
			if node.name:find(v) then
				node.name = node.name:gsub(v,"")
				node.param2 = nidp2_degrotate[v][node.param2 + 1]
			end
		end
		minetest.swap_node(pos,node)
		mcl_signs.update_sign(pos)
	end
})
