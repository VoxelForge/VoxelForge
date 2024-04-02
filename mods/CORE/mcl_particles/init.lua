mcl_particles = {}

local warning_text = "invoked. This function has been inactivated in mineclonia and does not do anything. It may be removed in the future."

function mcl_particles.add_node_particlespawner(pos, particlespawner_definition, level)
	minetest.log("warning", "mcl_particles.add_node_particlespawner "..warning_text)
end

function mcl_particles.delete_node_particlespawners(pos)
	minetest.log("warning", "mcl_particles.delete_node_particlespawner "..warning_text)
end

function mcl_particles.spawn_smoke(pos, name, smoke_pdef_base)
	minetest.log("warning", "mcl_particles.add_node_particlespawner "..warning_text)
end
