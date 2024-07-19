local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local spawn_interval = 20 * 60
local max_lifetime = 60 * 60
local current_chance = 25
local wandering_trader = table.copy(mobs_mc.villager_mob)

local function E(f, t)
	return { "vlf_core:emerald", f or 1, t or f or 1 }
end

local function get_random_color()
	local _, color = table.random_element(vlf_dyes.colors)
	return color
end

local function get_random_dye()
	return "vlf_dyes:"..get_random_color()
end

local function get_random_tree()
	local _, wood = table.random_element(vlf_trees.woods)
	return "vlf_trees:tree_"..wood
end

local function get_random_sapling()
	local r = {}
	for k, v in pairs(vlf_trees.woods) do
		local sap = "vlf_trees:sapling_"..k
		if minetest.registered_nodes[sap] then
			table.insert(r, sap)
		end
	end
	return table.random_element(r)
end

local function get_random_flower()
	local _, flower = table.random_element(vlf_flowers.registered_simple_flowers)
	return flower
end
mobs_mc.wandering_trader = {}
mobs_mc.wandering_trader.trades_purchasing_table = {
	{ { "vlf_entity_effects:water", 1, 1, }, E() },
	{ { "vlf_buckets:bucket_water", 1, 1, }, E(2) },
	{ { "vlf_mobitems:milk_bucket", 1, 1, }, E(2) },
	{ { "vlf_entity_effects:fermented_spider_eye", 1, 1, }, E(3) },
	{ { "vlf_farming:potato_item_baked", 1, 1, }, E(1) },
	{ { "vlf_farming:hay_block", 1, 1, }, E(1) },
}

mobs_mc.wandering_trader.trades_special_table = {
	{ E(), { "vlf_core:packed_ice", 1, 1, } },
	{ E(), { "vlf_mobitems:gunpowder", 4, 4, } },
	{ E(), { get_random_tree, 8, 8, } },
	{ E(3), { "vlf_core:podzol", 3, 3, } },
	{ E(5), { "vlf_core:ice", 1, 1, } },
	{ E(6), { "vlf_entity_effects:invisibility", 1, 1, } },
	{ E(6, 20), { "vlf_tools:pick_diamond_enchanted", 1, 1 } },
}

mobs_mc.wandering_trader.trades_ordinary_table = {
	{ E(), { "vlf_flowers:fern", 1, 1, } },
	{ E(), { "vlf_core:reeds", 1, 1, } },
	{ E(), { "vlf_farming:pumpkin", 1, 1, } },
	{ E(), { get_random_flower, 1, 1, } },

	{ E(), { "vlf_farming:wheat_seeds", 1, 1, } },
	{ E(), { "vlf_farming:beetroot_seeds", 1, 1, } },
	{ E(), { "vlf_farming:pumpkin_seeds", 1, 1, } },
	{ E(), { "vlf_farming:melon_seeds", 1, 1, } },
	{ E(), { get_random_dye, 1, 1, } },
	{ E(), { "vlf_core:vine", 3, 3, } },
	{ E(), { "vlf_flowers:waterlily", 3, 3, } },
	{ E(), { "vlf_core:sand", 3, 3, } },
	{ E(), { "vlf_core:redsand", 3, 3, } },
	--{ E(), { "TODO: small_dripleaf", 3, 3, } },
	{ E(), { "vlf_mushrooms:mushroom_brown", 3, 3, } },
	{ E(), { "vlf_mushrooms:mushroom_red", 3, 3, } },
	--{ E(), { "TODO:pointed_dripstone", 2, 5, } },
	{ E(), { "vlf_lush_caves:rooted_dirt", 2, 2, } },
	{ E(), { "vlf_lush_caves:moss", 2, 2, } },
	{ E(2), { "vlf_ocean:sea_pickle_1_dead_brain_coral_block", 1, 1, } },
	{ E(2), { "vlf_nether:glowstone", 1, 5, } },
	{ E(3), { "vlf_buckets:bucket_tropical_fish", 1, 1, } },
	--{ E(3), { "TODO: vlf_buckets:bucket_pufferfish", 1, 5, } },
	{ E(3), { "vlf_ocean:kelp", 1, 1, } },
	{ E(3), { "vlf_core:cactus", 1, 1, } },
	{ E(3), { "vlf_ocean:brain_coral_block", 1, 1, } },
	{ E(3), { "vlf_ocean:tube_coral_block", 1, 1, } },
	{ E(3), { "vlf_ocean:bubble_coral_block", 1, 1, } },
	{ E(3), { "vlf_ocean:fire_coral_block", 1, 1, } },
	{ E(3), { "vlf_ocean:horn_coral_block", 1, 1, } },
	{ E(4), { "vlf_mobitems:slimeball", 1, 1, } },
	{ E(5), { get_random_sapling, 8, 8, } },
	{ E(5), { "vlf_mobitems:nautilus_shell", 1, 1, } },
}


local function get_wandering_trades()
	local purch = table.copy(mobs_mc.wandering_trader.trades_purchasing_table)
	local speci = table.copy(mobs_mc.wandering_trader.trades_special_table)
	local ordin = table.copy(mobs_mc.wandering_trader.trades_ordinary_table)
	local t = {}
	for i=1,2 do
		table.insert(t, table.remove(purch, math.random(#purch)))
		table.insert(t, table.remove(speci, math.random(#speci)))
	end
	for i=1,5 do
		table.insert(t, table.remove(ordin, math.random(#ordin)))
	end
	return { t }
end

function wandering_trader:do_custom(dtime)
	if os.time() - self._spawn_time > max_lifetime then
		self:safe_remove()
	end
end

function wandering_trader:on_spawn(dtime)
	if self._id then
		self:set_textures()
		for _, lid in pairs(self._llamas) do
			local e = vlf_util.get_luaentity_by_id(lid)
			if e then
				e.following = self.object
			end
		end
		return
	end
	self._id = minetest.sha1(minetest.get_gametime()..minetest.pos_to_string(self.object:get_pos())..tostring(math.random()))
	self._llamas = {}
	self._spawn_time = os.time()
	self:set_textures()
end

function wandering_trader:on_rightclick(clicker)
	self._profession = "wandering_trader"
	self:init_trader_vars()
	local name = clicker:get_player_name()
	self._trading_players[name] = true

	if self._trades == nil or self._trades == false then
		mobs_mc.professions["wandering_trader"].trades = get_wandering_trades()
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
	_notiers = true,
})

vlf_mobs.register_mob("mobs_mc:wandering_trader", wandering_trader)

-- spawn eggs
vlf_mobs.register_egg("mobs_mc:wandering_trader", S("Wandering Trader"), "#1E90FF", "#bc8b72", 0)

function mobs_mc.spawn_trader_llama(pos, wt)
	local o = minetest.add_entity(pos, "mobs_mc:llama")
	if o then
		local ot = o:get_properties().textures
		local l = o:get_luaentity()
		local wl = wt:get_luaentity()
		l._id = minetest.sha1(minetest.get_gametime()..minetest.pos_to_string(o:get_pos())..tostring(math.random()))
		table.insert(wl._llamas, l._id)
		local tx = {"blank.png", "mobs_mc_llama_decor_wandering_trader.png", ot[3]}
		l.base_texture = tx
		l.following = wt
		l._follow_trader = wt._id
		o:set_properties({
			textures = tx,
		})
	end
end

function mobs_mc.spawn_wandering_trader(pos)
	local trader = minetest.add_entity(vector.offset(pos, 0, 1, 0), "mobs_mc:wandering_trader")
	if trader then
		local nn = minetest.find_nodes_in_area_under_air(vector.offset(pos, -2, -2 , -2), vector.offset(pos, 2, 2, 2), {"group:opaque"})
		if nn and #nn > 0 then
			for i=1,math.random(2) do
				mobs_mc.spawn_trader_llama(vector.offset((nn[i] or nn[i - 1]), 0, 1, 0), trader)
			end
		end
		return true
	end
end

local function get_points_on_circle(pos,r,n)
	local rt = {}
	for i=1, n do
		table.insert(rt,vector.offset(pos,r * math.cos(((i-1)/n) * (2*math.pi)),0,  r* math.sin(((i-1)/n) * (2*math.pi)) ))
	end
	return rt
end

local function attempt_trader_spawn(manual)
	local exists = false
	local spawned = false
	for _, v in pairs(minetest.luaentities) do
		if v.name == "mobs_mc:wandering_trader" then
			exists = true
		end
	end
	if not exists and math.random(100) < current_chance then
		current_chance = 25
		local ow_players = {}
		for _, pl in pairs(minetest.get_connected_players()) do
			if vlf_worlds.pos_to_dimension(pl:get_pos()) == "overworld" then
				table.insert(ow_players, pl)
			end
		end
		if #ow_players > 0 then
			table.shuffle(ow_players)
			local pl = ow_players[1]
			local poss = get_points_on_circle(pl:get_pos(), 50, 24)
			table.shuffle(poss)
			for _, sp in pairs(poss) do
				local nn = minetest.find_nodes_in_area_under_air(vector.offset(sp, -5, -5 , -5), vector.offset(sp, 5, 5, 5), {"group:solid"})
				if nn and #nn > 0 then
					if mobs_mc.spawn_wandering_trader(nn[1]) then
						break
					end
				end
			end
			spawned = true
		end
	elseif not exists then
		current_chance = math.min(75, current_chance + 25)
	end

	if not manual then
		if mobs_mc.wandering_trader_spawn_job then
			mobs_mc.wandering_trader_spawn_job:cancel()
			--prevent multiple spawn jobs from being run
		end
		mobs_mc.wandering_trader_spawn_job = minetest.after(spawn_interval, attempt_trader_spawn)
	end
	return spawned
end

if minetest.settings:get_bool("mobs_spawn", true) then
	mobs_mc.wandering_trader_spawn_job = minetest.after(spawn_interval, attempt_trader_spawn)
end

minetest.register_chatcommand("spawn_wandering_trader", {
	privs = { debug = true, },
	func = function(pn, pr)
		minetest.log("current wandering trader spawn chance: "..tostring(current_chance))
		if attempt_trader_spawn(true) then
			minetest.log("wandering trader spawned")
		end
	end,
})
