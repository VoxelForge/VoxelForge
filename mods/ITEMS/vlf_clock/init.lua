local S = minetest.get_translator(minetest.get_current_modname())
vlf_clock = {}

vlf_clock.old_time = -1

local clock_frames = 64

-- Timer for random clock spinning
local random_timer = 0.0
local random_timer_trigger = 1.0 -- random clock spinning tick in seconds. Increase if there are performance problems
local random_frame = math.random(0, clock_frames-1)

vlf_clock.images = {}
for frame=0, clock_frames-1 do
	local sframe = tostring(frame)
	if string.len(sframe) == 1 then
		sframe = "0" .. sframe
	end
	table.insert(vlf_clock.images, "vlf_clock_clock_"..sframe..".png")
end

local function round(num)
	return math.floor(num + 0.5)
end

function vlf_clock.get_clock_frame()
	local t = clock_frames * minetest.get_timeofday()
	t = round(t)
	if t == clock_frames then t = 0 end
	return tostring((t + (clock_frames / 2)) % clock_frames)
end

minetest.register_craftitem("vlf_clock:clock", {
	description = S("Clock"),
	_tt_help = S("Displays the time of day in the Overworld"),
	_doc_items_longdesc = S("Clocks are tools which shows the current time of day in the Overworld."),
	_doc_items_usagehelp = S("The clock contains a rotating disc with a sun symbol (yellow disc) and moon symbol and a little “pointer” which shows the current time of day by estimating the real position of the sun and the moon in the sky. Noon is represented by the sun symbol and midnight is represented by the moon symbol."),
	inventory_image = vlf_clock.images[1],
	groups = { tool=1, clock = 1, disable_repair=1 },
	wield_image = "",
	_on_entity_step = function(self, dtime)
		self._clock_timer = (self._clock_timer or 0) - dtime
		if self._clock_timer > 0 then return end
		self._clock_timer = 5
		self.object:set_properties({
			visual = "upright_sprite",
			visual_size = { x = 0.55, y = 0.55 },
			textures = {
				vlf_clock.images[vlf_clock.get_clock_frame() + 1],
				vlf_clock.images[vlf_clock.get_clock_frame() + 1]
			},
		})
	end
})

-- This timer makes sure the clocks get updated from time to time regardless of time_speed,
-- just in case some clocks in the world go wrong
local force_clock_update_timer = 0

minetest.register_globalstep(function(dtime)
	local now = vlf_clock.get_clock_frame()
	force_clock_update_timer = force_clock_update_timer + dtime
	random_timer = random_timer + dtime

	-- This causes the random spinning of the clock
	if random_timer >= random_timer_trigger then
		random_frame = (random_frame + math.random(-4, 4)) % clock_frames
		random_timer = 0
	end

	if vlf_clock.old_time == now and force_clock_update_timer < 1 then
		return
	end
	force_clock_update_timer = 0

	vlf_clock.old_time = now
	vlf_clock.random_frame = random_frame

	for player in vlf_util.connected_players() do
		local inv = player:get_inventory()
		for s, stack in pairs(inv:get_list("main")) do
			if minetest.get_item_group(stack:get_name(), "clock") > 0 then
				stack:set_name("vlf_clock:clock") -- compat to effectively rename clocks - aliases do not do this.
				local frame
				-- Clocks do not work in certain zones
				if not vlf_worlds.clock_works(player:get_pos()) then
					frame = random_frame
				else
					frame = now
				end

				local m = stack:get_meta()
				m:set_string("wield_image", vlf_clock.images[frame + 1])
				m:set_string("inventory_image", vlf_clock.images[frame + 1])
				inv:set_stack("main", s, stack)
			end
		end
	end
end)

minetest.register_on_craft(function(itemstack)
	if itemstack:get_name() == "vlf_clock:clock" then
		itemstack:get_meta():set_string("inventory_image", vlf_clock.images[vlf_clock.get_clock_frame()])
	end
end)

minetest.register_craft({
	output = "vlf_clock:clock",
	recipe = {
		{"", "vlf_core:gold_ingot", ""},
		{"vlf_core:gold_ingot", "vlf_redstone:redstone", "vlf_core:gold_ingot"},
		{"", "vlf_core:gold_ingot", ""}
	}
})

for a=0,clock_frames-1,1 do
	core.register_alias("vlf_clock:clock_"..tostring(a), "vlf_clock:clock")
end

