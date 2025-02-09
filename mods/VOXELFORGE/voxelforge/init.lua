--===============--
--=== Globals ===--
--===============--
particles = {}
voxelforge = {}
--==============--
--=== Locals ===--
--==============--

--=================--
--=== Functions ===--
--=================--
function particles.trail(start_pos, target_pos, color, a_type, attraction, speed)
	local attract
	if a_type == "in" then
		attract = attraction
	elseif a_type == "out" then
		attract = -attraction
	else
		attract = 0
	end
	local speed = 0.2
    -- Add a particle spawner with custom start position, target position, and color
    return minetest.add_particlespawner({
        amount = math.random(20, 40),
        time = 4,
        minpos = vector.subtract(start_pos, {x = speed.x, y = speed.y, z = speed.z}),
        maxpos = vector.add(start_pos, {x = speed.x, y = speed.y, z = speed.z}),
        minvel = vector.multiply(vector.direction(start_pos, target_pos), 3.0),
        maxvel = vector.multiply(vector.direction(start_pos, target_pos), 5.0),
        glow = 8,
        minacc = {x = 0, y = 0, z = 0},
        maxacc = {x = 0, y = 0, z = 0},
        minexptime = 5, -- Particles stay until they hit target
        maxexptime = 5,
        minsize = 0.5,
        maxsize = 1,
        attract = {kind = "point", strength = attract, origin = start_pos},
        texture = "blank.png^[noalpha^[colorize:" .. color .. ":255", -- Dynamic colorization
    })
end

--TODO: Remove after version 25w09a
minetest.register_on_joinplayer(function(player)
    minetest.chat_send_player(player:get_player_name(),
        minetest.colorize("#FF50FF", "THIS VERSION MAY BE BUGGY, A PATCH RELEASE IS PLANNED BETWEEN 02/13/25 TO 02/19/25. PLEASE REPORT ALL BUGS TO: https://github.com/VoxelForge/VoxelForge/issues")
    )
end)
