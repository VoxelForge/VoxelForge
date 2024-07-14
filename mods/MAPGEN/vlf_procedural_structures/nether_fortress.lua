local BLAZE_SPAWNER_MAX_LIGHT = 11

loot_table = {
	["vlf_chests:chest_small" ] ={
	{
		stacks_min = 1,
		stacks_max = 2,
		items = {
			--{ itemstring = "FIXME:spectral_arrow", weight = 1, amount_min = 10, amount_max=28 },
			{ itemstring = "vlf_blackstone:blackstone_gilded", weight = 1, amount_min = 8, amount_max=12 },
			{ itemstring = "vlf_core:iron_ingot", weight = 1, amount_min = 4, amount_max=9 },
			{ itemstring = "vlf_core:gold_ingot", weight = 1, amount_min = 4, amount_max=9 },
			{ itemstring = "vlf_core:crying_obsidian", weight = 1, amount_min = 3, amount_max=8 },
			{ itemstring = "vlf_bows:crossbow", weight = 1, func = function(stack, pr)
				vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
			end },
			{ itemstring = "vlf_core:goldblock", weight = 1, },
			{ itemstring = "vlf_tools:sword_gold", weight = 1, },
			{ itemstring = "vlf_tools:axe_gold", weight = 1, func = function(stack, pr)
				vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
			end },
			{ itemstring = "vlf_armor:helmet_gold", weight = 1, func = function(stack, pr)
				vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
			end },
			{ itemstring = "vlf_armor:chestplate_gold", weight = 1, func = function(stack, pr)
				vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
			end },
			{ itemstring = "vlf_armor:leggings_gold", weight = 1, func = function(stack, pr)
				vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
			end },
			{ itemstring = "vlf_armor:boots_gold", weight = 1, func = function(stack, pr)
				vlf_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
			end },
		}
	},
	{
		stacks_min = 2,
		stacks_max = 4,
		items = {
			{ itemstring = "vlf_bows:arrow", weight = 4, amount_min = 5, amount_max=17 },
			{ itemstring = "vlf_mobitems:string", weight = 4, amount_min = 1, amount_max=6 },
			{ itemstring = "vlf_core:iron_nugget", weight = 1, amount_min = 2, amount_max = 6 },
			{ itemstring = "vlf_core:gold_nugget", weight = 1, amount_min = 2, amount_max = 6 },
			{ itemstring = "vlf_mobitems:leather", weight = 1, amount_min = 1, amount_max = 3 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "vlf_compass:lodestone" },
			{ itemstring = "vlf_armor:rib" },
		}
	}}
}

vlf_procedural_structures.structures.nether_fortress = {
	name = "nether_fortress",
	grid_size = vector.new(7,4,7),
	grid_limit = vector.new(5,3,5),
	loot = loot_table,
	parts = {
		-- never access this part
		[0]={
			file = "template_1x1x1.mts",
			size = vector.new(1,1,1),
		},

		{
			file = "corner_1_1x1x1.mts",
			size = vector.new(1,1,1),
			weight = 5,
			rules = {
				{ dir = vector.new( 0, 0,-1), groups = { corridor=1 } },
				{ dir = vector.new( 0, 0, 1), groups = { wall=1 }, },
				{ dir = vector.new(-1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new( 1, 0, 0), groups = { wall=1 }, },
			},
		},
		{
			file = "tee_1_1x1x1.mts",
			size = vector.new(1,1,1),
			weight = 8,
			rules = {
				{ dir = vector.new( 0, 0,-1), groups = { corridor=1 } },
				{ dir = vector.new( 0, 0, 1), groups = { corridor=1 } },
				{ dir = vector.new(-1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new( 1, 0, 0), groups = { wall=1 } },
			},
		},
		{
			file = "cross_glowstone_1x1x1.mts",
			size = vector.new(1,1,1),
			weight = 7,
			rules = {
				{ dir = vector.new( 0, 0,-1), groups = { corridor=1 } },
				{ dir = vector.new( 0, 0, 1), groups = { corridor=1 } },
				{ dir = vector.new(-1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new( 1, 0, 0), groups = { corridor=1 } },
			},
		},
		{
			file = "cross_hidden_1x1x1.mts",
			size = vector.new(1,1,1),
			weight = 2,
			rules = {
				{ dir = vector.new( 0, 0,-1), groups = { corridor=1 } },
				{ dir = vector.new( 0, 0, 1), groups = { corridor=1 } },
				{ dir = vector.new(-1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new( 1, 0, 0), groups = { corridor=1 } },
			},
		},
		{
			file = "cross_fake_1x1x1.mts",
			size = vector.new(1,1,1),
			weight = 6,
			rules = {
				{ dir = vector.new( 0, 0,-1), groups = { corridor=1 } },
				{ dir = vector.new( 0, 0, 1), groups = { corridor=1 } },
				{ dir = vector.new(-1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new( 1, 0, 0), groups = { corridor=1 } },
			},
		},

		{
			file = "corridor_1_1x1x1.mts",
			size = vector.new(1,1,1),
			weight = 3,
			rules = {
				{ dir = vector.new( 1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new(-1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new( 0, 0,-1), groups = { wall=1 } },
				{ dir = vector.new( 0, 0, 1), groups = { wall=1 } },
			},
		},
		{
			file = "corridor_2_1x1x1.mts",
			size = vector.new(1,1,1),
			weight = 3,
			rules = {
				{ dir = vector.new( 1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new(-1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new( 0, 0,-1), groups = { wall=1 } },
				{ dir = vector.new( 0, 0, 1), groups = { wall=1 } },
			},
		},
		{
			file = "corridor_3_1x1x1.mts",
			size = vector.new(1,1,1),
			weight = 3,
			rules = {
				{ dir = vector.new( 1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new(-1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new( 0, 0,-1), groups = { wall=1 } },
				{ dir = vector.new( 0, 0, 1), groups = { wall=1 } },
			},
		},

		{
			file = "quartz_lava_well_1x1x1.mts",
			size = vector.new(1,1,1),
			can_use = function(state)
				return not state.user.has_lava_well
			end,
			after_place = function(state, pos)
				state.user.has_lava_well = true
			end,
			rules = {
				{ dir = vector.new( 1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new(-1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new( 0, 0, 1), groups = { corridor=1 } },
				{ dir = vector.new( 0, 0,-1), groups = { wall=1 } },
			},
		},
		{
			file = "hall_with_nether_wart_1x2x1.mts",
			size = vector.new(2,1,1),
			weight = 2,
			rules = {
				{ dir = vector.new( 1, 0, 0), pos = vector.new(1,0,0), groups = { corridor=1 } },
				{ dir = vector.new(-1, 0, 0), groups = { corridor=1 } },
			},
		},
		{
			file = "lava_tunnel_1x2x1.mts",
			size = vector.new(2,1,1),
			weight = 2,
			rules = {
				{ dir = vector.new( 1, 0, 0), pos = vector.new(1,0,0), groups = { corridor=1 } },
				{ dir = vector.new(-1, 0, 0), groups = { corridor=1 } }
			},
		},
		{
			file = "courtyard_lava_1x1x1.mts",
			size = vector.new(1,1,1),
			rules = {
				{ dir = vector.new(-1, 0, 0), groups = { wall=1 } },
				{ dir = vector.new( 1, 0, 0), groups = { wall=1 } },
				{ dir = vector.new( 0, 0,-1), groups = { wall=1 } },
				{ dir = vector.new( 0, 0, 1), groups = { wall=1 } },
			},
		},
		{
			file = "stairs_1x1x2.mts",
			size = vector.new(1,2,1),
			rules = {
				{ dir = vector.new(-1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new( 1, 0, 0), groups = { wall=1 } },
				{ dir = vector.new( 0, 0,-1), groups = { wall=1 } },
				{ dir = vector.new( 0, 0, 1), groups = { wall=1 } },

				{ dir = vector.new( 1, 0, 0), pos = vector.new(0,1,0), groups = { corridor=1 } },
				{ dir = vector.new(-1, 0, 0), pos = vector.new(0,1,0), groups = { wall=1 } },
				{ dir = vector.new( 0, 0, 1), pos = vector.new(0,1,0), groups = { wall=1 } },
				{ dir = vector.new( 0, 0,-1), pos = vector.new(0,1,0), groups = { wall=1 } },
			},
		},
		{
			file = "stairs_1x1x3.mts",
			size = vector.new(1,3,1),
			rules = {
				{ dir = vector.new(-1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new( 1, 0, 0), groups = { wall=1 } },
				{ dir = vector.new( 0, 0,-1), groups = { wall=1 } },
				{ dir = vector.new( 0, 0, 1), groups = { wall=1 } },

				{ dir = vector.new( 0, 0, 1), pos = vector.new(0,1,0), groups = { wall=1 } },
				{ dir = vector.new( 0, 0,-1), pos = vector.new(0,1,0), groups = { wall=1 } },
				{ dir = vector.new( 1, 0, 0), pos = vector.new(0,1,0), groups = { wall=1 } },
				{ dir = vector.new(-1, 0, 0), pos = vector.new(0,1,0), groups = { wall=1 } },

				{ dir = vector.new( 1, 0, 0), pos = vector.new(0,2,0) },
				{ dir = vector.new(-1, 0, 0), pos = vector.new(0,2,0), groups = { wall=1 } },
				{ dir = vector.new( 0, 0, 1), pos = vector.new(0,2,0), groups = { wall=1 } },
				{ dir = vector.new( 0, 0,-1), pos = vector.new(0,2,0), groups = { wall=1 } },
			}
		},
		{
			file = "mess_1x1x1.mts",
			size = vector.new(1,1,1),
			rules = {
				{ dir = vector.new(-1, 0, 0), groups = { corridor=1 } },
				{ dir = vector.new( 1, 0, 0), groups = { wall=1 } },
				{ dir = vector.new( 0, 0,-1), groups = { wall=1 } },
				{ dir = vector.new( 0, 0, 1), groups = { wall=1 } },
			},
			loot = {
				["vlf_chests:chest_small"] = {{
					stacks_min = 3,
					stacks_max = 9,
					items = {
						{ itemstring = "vlf_mobitems:cooked_porkchop", weight = 10, amount_min = 1, amount_max = 5 },
						{ itemstring = "vlf_mobitems:porkchop", weight = 10, amount_min = 1, amount_max = 30 },
						{ itemstring = "vlf_mobitems:string", weight = 10, amount_min = 1, amount_max = 8 },
						{ itemstring = "vlf_mobitems:rotten_flesh", weight = 20, amount_min = 5, amount_max = 16 },
						{ itemstring = "vlf_core:gold_nugget", weight = 15, amount_min = 4, amount_max = 9 },
						{ itemstring = "vlf_core:iron_nugget", weight = 15, amount_min = 4, amount_max = 9 },
						{ itemstring = "vlf_mobitems:leather", weight = 15, amount_min = 1, amount_max = 4 },
					}
				}},
			},
		},
		{
			file = "mason_1x1x1.mts",
			size = vector.new(1,1,1),
			rules = {
				{ dir = vector.new(-1, 0, 0), },
				{ dir = vector.new( 1, 0, 0), groups = { wall=1 } },
				{ dir = vector.new( 0, 0,-1), groups = { wall=1 } },
				{ dir = vector.new( 0, 0, 1), groups = { wall=1 } },
			},
			loot = {
				["vlf_barrels:barrel_closed"] = {{
					stacks_min = 3,
					stacks_max = 12,
					items = {
						{ itemstring = "vlf_blackstone:blackstone_gilded", weight = 1, amount_min = 8, amount_max = 12 },
						{ itemstring = "vlf_blackstone:blackstone", weight = 10, amount_min = 8, amount_max=12 },
						{ itemstring = "vlf_core:gold_nugget", weight = 15, amount_min = 4, amount_max = 9 },
						{ itemstring = "vlf_core:gold_ingot", weight = 1, amount_min = 4, amount_max=9 },
						{ itemstring = "vlf_core:goldblock", weight = 1, },
						{ itemstring = "vlf_nether:quartz", weight = 5, amount_min = 1, amount_max = 15 },
					}
				}},
			},
		},
		{
			file = "spawner_1x1x2.mts",
			size = vector.new(1,2,1),
			rules = {
				{ dir = vector.new(-1, 0, 0) },
				{ dir = vector.new( 1, 0, 0) },
				{ dir = vector.new( 0, 0, 1) },
				{ dir = vector.new( 0, 0,-1) },

				{ dir = vector.new(-1, 0, 0), pos = vector.new(0,1,0) },
				{ dir = vector.new( 1, 0, 0), pos = vector.new(0,1,0) },
				{ dir = vector.new( 0, 0, 1), pos = vector.new(0,1,0) },
				{ dir = vector.new( 0, 0,-1), pos = vector.new(0,1,0) },
			},
			loot = loot_table,
			can_use = function(state)
				return (state.user.spawners or 0) < 2
			end,
			after_place = function(state, pos)
				-- Track how many blaze spawners we have placed
				state.user.spawners = ( state.user.spawnders or 0 ) + 1

				--[[
				local nodes = minetest.find_nodes_in_area(pos,vector.offset(pos,7,4*2+1,7),{"vlf_mobspawners:spawner"})
				for _,p in ipairs(nodes) do
					vlf_mobspawners.setup_spawner(p, "mobs_mc:blaze", 0, BLAZE_SPAWNER_MAX_LIGHT, 10, 8, 0)
				end
				--]]
			end
		},
	},
}
