local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local wandering_trader = table.copy(mobs_mc.villager_mob)

function wandering_trader:do_custom(dtime)

end

function wandering_trader:on_spawn(dtime)
	if self._id then
		self:set_textures()
		return
	end
	self._id=minetest.sha1(minetest.get_gametime()..minetest.pos_to_string(self.object:get_pos())..tostring(math.random()))
	self:set_textures()
end

function wandering_trader:on_rightclick(clicker)
	self._profession = "wandering_trader"
	self:init_trader_vars()
	local name = clicker:get_player_name()
	self._trading_players[name] = true

	if self._trades == nil or self._trades == false then
		self:init_trades()
	end
	self:update_max_tradenum()
	if self._trades == false then
		return
	end

	local inv = minetest.get_inventory({type="detached", name="mobs_mc:trade_"..name})
	if not inv then
		return
	end

	self:show_trade_formspec(name)

	local selfpos = self.object:get_pos()
	local clickerpos = clicker:get_pos()
	local dir = vector.direction(selfpos, clickerpos)
	self.object:set_yaw(minetest.dir_to_yaw(dir))
	self:stand_still()
end

table.update(wandering_trader, {
	description = S("Wandering Trader"),
	textures = {
		"mobs_mc_villager.png",
		"mobs_mc_villager.png", --hat
	},
	_profession = "wandering_trader",
})

mcl_mobs.register_mob("mobs_mc:wandering_trader", wandering_trader)

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:wandering_trader", S("Wandering Trader"), "#1E90FF", "#bc8b72", 0)
