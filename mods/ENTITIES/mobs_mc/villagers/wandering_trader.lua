local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local spawn_interval = 20 * 60
local max_lifetime = 60 * 60
local current_chance = 25
local wandering_trader = table.copy(mobs_mc.villager_mob)

function wandering_trader:do_custom(dtime)

end

function wandering_trader:on_spawn(dtime)
	if self._id then
		if os.time() - self._spawn_time > max_lifetime then
			self:safe_remove()
		end
		self:set_textures()
		return
	end
	self._id = minetest.sha1(minetest.get_gametime()..minetest.pos_to_string(self.object:get_pos())..tostring(math.random()))
	self._spawn_time = os.time()
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

function mobs_mc.spawn_trader_llama(pos)
	local o = minetest.add_entity(pos, "mobs_mc:llama")
	if o then
		local ot = o:get_properties().textures
		o:set_properties({
			textures = {"blank.png", "mobs_mc_llama_decor_wandering_trader.png", ot[3]},
		})
	end
end

function mobs_mc.spawn_wandering_trader(pos)
	minetest.add_entity(pos, "mobs_mc:wandering_trader")
	for i=1,math.random(2) do
		mobs_mc.spawn_trader_llama(pos)
	end
end

minetest.register_chatcommand("spawn_wandering_trader", {
	privs = { debug = true, },
	func = function(pn, pr)
		local pl = minetest.get_player_by_name(pn)
		mobs_mc.spawn_wandering_trader(pl:get_pos())
	end,
})

local function attempt_trader_spawn()
	if math.random(100) < current_chance then
		current_chance = 25
		local ow_players = {}
		for _, pl in pairs(minetest.get_connected_players()) do
			if mcl_worlds.pos_to_dimension(pl:get_pos()) == "overworld" then
				table.insert(ow_players, pl)
			end
		end
		table.shuffle(ow_players)

		--spawn_trader
	else
		current_chance = current_chance + 25
	end
	minetest.after(spawn_interval, attempt_trader_spawn)
end

minetest.after(spawn_interval, attempt_trader_spawn)
