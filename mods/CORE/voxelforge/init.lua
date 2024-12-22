--===============--
--=== Globals ===--
--===============--
particles = {}
--==============--
--=== Locals ===--
--==============--

--=================--
--=== Functions ===--
--=================--
function particles.trail(start_pos, target_pos, color, a_type, attraction)
	local attract
	if a_type == "in" then
		attract = attraction
	elseif a_type == "out" then
		attract = -attraction
	else
		attract = 0
    -- Add a particle spawner with custom start position, target position, and color
    return minetest.add_particlespawner({
        amount = math.random(20, 40),
        time = 4,
        minpos = vector.subtract(start_pos, {x = 0.2, y = 0.2, z = 0.2}),
        maxpos = vector.add(start_pos, {x = 0.2, y = 0.2, z = 0.2}),
        minvel = vector.multiply(vector.direction(start_pos, target_pos), 3.0),
        maxvel = vector.multiply(vector.direction(start_pos, target_pos), 5.0),
        glow = 8,
        minacc = {x = 0, y = 0, z = 0},
        maxacc = {x = 0, y = 0, z = 0},
        minexptime = 10, -- Particles stay until they hit target
        maxexptime = 15,
        minsize = 0.5,
        maxsize = 1,
        attract = {kind = "point", strength = attract, origin = start_pos}
        texture = "blank.png^[colorize:" .. color .. ":255", -- Dynamic colorization
    })
end
