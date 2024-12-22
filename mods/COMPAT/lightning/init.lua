lightning = {
	auto = true,
	effect_range = 500,
}
setmetatable(lightning, { __index = vlf_lightning })

minetest.register_alias("lightning:dying_flame", "vlf_fire:fire")
