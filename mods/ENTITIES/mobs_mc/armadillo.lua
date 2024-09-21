local S = minetest.get_translator(minetest.get_current_modname())

vlf_mobs.register_mob("mobs_mc:armadillo", {
	description = S("Armadillo"),
	type = "animal",
	can_despawn = false,
	passive = true,
	hp_min = 6,
	hp_max = 6,
	collisionbox = {-0.5, -0.0, -0.5, 0.5, 0.7, 0.5},
	visual = "mesh",
	mesh = "mobs_mc_armadillo.obj",
	rotate = 180,
	textures = {"mobs_mc_armadillo.png"},
	visual_size = {x = 6.5, y = 7},
	sounds = {},
	walk_velocity = 0.14,
	run_velocity = 0.14,
	walk_chance = 80,
	fall_damage = 10,
	view_range = 8,
	fear_height = 4,
	jump = false,
	fly = false,
	makes_footstep_sound = false,
	scared = false,
	do_custom = mobs_mc.armadillo_scare(),
	on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local item_name = item:get_name()

		-- Check if the player is holding the correct brush item
		if item_name == "vlf_sus_nodes:brush" then
			-- Drop an armadillo scute
			minetest.add_item(self.object:get_pos(), "vlf_mobitems:armadillo_scute")
			if awards and awards.unlock and clicker then
				awards.unlock(clicker:get_player_name(), "vlf:brush_armadillo")
			end

			-- Remove 13 durability points from the brush
			item:add_wear(65535 / 100 * 13) -- Assuming 100 uses for the brush
			clicker:set_wielded_item(item)
		end
	end,
	deal_damage = mobs_mc.armadillo_damage(),
})

vlf_mobs.spawn_setup({
	name = "mobs_mc:armadillo",
	dimension = "overworld",
	type_of_spawning = "ground",
	min_height = 1,
	min_light = 4,
	max_light = 15,
	aoc = 80,
	chance = 2400,
	biomes = {
		"Savanna",
		"SavannaM",
		"Savanna_beach",
		"Mesa",
		"MesaPlateauF",
		"MesaPlateauFM",
		"MesaPlateauF_grasstop",
		"MesaPlateauFM_grasstop",
		"MesaBryce",
	},
})

-- spawn eggs
vlf_mobs.register_egg("mobs_mc:armadillo", S("Armadillo"), "#A56C68", "#663939", 0)
