-- No-op in MCL2 (capturing mobs is not possible).
-- Provided for compability with Mobs Redo
function vlf_mobs.capture_mob() return false end

-- No-op in MCL2 (protecting mobs is not possible).
function vlf_mobs.protect() return false end

-- this is to make the register_mob and register egg functions commonly used by mods not break
-- when they use the weird old : notation AND self as first argument
local oldregmob = vlf_mobs.register_mob
function vlf_mobs.register_mob(self,name,def) ---@diagnostic disable-line: duplicate-set-field
	if type(self) == "string" then
		def = name
		name = self
	end
	return oldregmob(name,def)
end
local oldregegg = vlf_mobs.register_egg
function vlf_mobs.register_egg(self, mob, desc, background_color, overlay_color, addegg, no_creative) ---@diagnostic disable-line: duplicate-set-field
	if type(self) == "string" then
		no_creative = addegg
		addegg = overlay_color
		overlay_color = background_color
		background_color = desc
		desc = mob
		mob = self
	end
	return oldregegg(mob, desc, background_color, overlay_color, addegg, no_creative)
end

local oldregarrow = vlf_mobs.register_arrow
function vlf_mobs.register_arrow(self,name,def) ---@diagnostic disable-line: duplicate-set-field
	if type(self) == "string" then
		def = name
		name = self
	end
	return oldregarrow(name,def)
end

function vlf_mobs.spawn_specific(name, dimension, type_of_spawning, biomes, min_light, max_light, _, chance, aoc, min_height, max_height, day_toggle, on_spawn)
	vlf_mobs.spawn_setup({
		name             = name,
		dimension        = dimension,
		type_of_spawning = type_of_spawning,
		biomes           = biomes,
		min_light        = min_light,
		max_light        = max_light,
		chance           = chance,
		aoc              = aoc,
		min_height       = min_height,
		max_height       = max_height,
		day_toggle       = day_toggle,
		on_spawn         = on_spawn,
	})
end

