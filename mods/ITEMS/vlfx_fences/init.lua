local S = minetest.get_translator(minetest.get_current_modname())
local extra_nodes = minetest.settings:get_bool("vlf_extra_nodes", true)

-- Red Nether Brick Fence and Red Nether Brick Fence Gate
vlf_fences.register_fence_and_fence_gate_def("red_nether_brick_fence", {
	tiles = { "vlf_fences_fence_red_nether_brick.png" },
	groups = { pickaxey = 1, fence_nether_brick = 1, not_in_creative_inventory = not extra_nodes and 1 or 0 },
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_blast_resistance = minetest.registered_nodes["vlf_nether:red_nether_brick"]._vlf_blast_resistance,
	_vlf_hardness = minetest.registered_nodes["vlf_nether:red_nether_brick"]._vlf_hardness,
	_vlf_fences_baseitem = "vlf_nether:red_nether_brick",
	_vlf_fences_stickreplacer = "vlf_nether:netherbrick",
}, {
	description = S("Red Nether Brick Fence"),
	connects_to = { "group:fence_nether_brick", "group:solid" },
}, {
	description = S("Red Nether Brick Fence Gate"),
	_vlf_fences_sounds = {
		open = {
			spec = "vlf_fences_nether_brick_fence_gate_open"
		},
		close = {
			spec = "vlf_fences_nether_brick_fence_gate_close"
		}
	},
	_vlf_fences_output_amount = 2
})

-- Nether Brick Fence Gate
vlf_fences.register_fence_gate_def("nether_brick_fence", {
	description = S("Nether Brick Fence Gate"),
	tiles = { "vlf_fences_fence_gate_nether_brick.png" },
	groups = { pickaxey = 1, fence_nether_brick = 1, not_in_creative_inventory = not extra_nodes and 1 or 0 },
	_vlf_blast_resistance = minetest.registered_nodes["vlf_nether:nether_brick"]._vlf_blast_resistance,
	_vlf_hardness = minetest.registered_nodes["vlf_nether:nether_brick"]._vlf_hardness,
	sounds = vlf_sounds.node_sound_stone_defaults(),
	_vlf_fences_sounds = {
		open = {
			spec = "vlf_fences_nether_brick_fence_gate_open"
		},
		close = {
			spec = "vlf_fences_nether_brick_fence_gate_close"
		}
	},
	_vlf_fences_baseitem = "vlf_nether:nether_brick",
	_vlf_fences_stickreplacer = "vlf_nether:netherbrick",
	_vlf_fences_output_amount = 2
})

-- Aliases for vlf_supplemental
minetest.register_alias("vlf_supplemental:red_nether_brick_fence", "vlfx_fences:red_nether_brick_fence")

minetest.register_alias("vlf_supplemental:nether_brick_fence_gate", "vlfx_fences:nether_brick_fence_gate")
minetest.register_alias("vlf_supplemental:nether_brick_fence_gate_open", "vlfx_fences:nether_brick_fence_gate_open")

minetest.register_alias("vlf_supplemental:red_nether_brick_fence_gate", "vlfx_fences:red_nether_brick_fence_gate")
minetest.register_alias("vlf_supplemental:red_nether_brick_fence_gate_open", "vlfx_fences:red_nether_brick_fence_gate_open")
