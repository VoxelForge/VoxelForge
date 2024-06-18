local S = minetest.get_translator(minetest.get_current_modname())
local extra_nodes = minetest.settings:get_bool("vlf_extra_nodes", true)

-- Red Nether Brick Fence

vlf_fences.register_fence_and_fence_gate(
	"red_nether_brick_fence",
	S("Red Nether Brick Fence"), S("Red Nether Brick Fence Gate"),
	"vlf_fences_fence_red_nether_brick.png",
	{pickaxey=1, deco_block=1, fence_nether_brick=1, not_in_creative_inventory=not extra_nodes and 1 or 0},
	minetest.registered_nodes["vlf_nether:red_nether_brick"]._vlf_hardness,
	minetest.registered_nodes["vlf_nether:red_nether_brick"]._vlf_blast_resistance,
	{"group:fence_nether_brick"},
	vlf_sounds.node_sound_stone_defaults(), "vlf_fences_nether_brick_fence_gate_open", "vlf_fences_nether_brick_fence_gate_close", 1, 1,
	"vlf_fences_fence_gate_red_nether_brick.png")

vlf_fences.register_fence_gate(
	"nether_brick_fence",
	S("Nether Brick Fence Gate"),
	"vlf_fences_fence_gate_nether_brick.png",
	{pickaxey=1, deco_block=1, fence_nether_brick=1, not_in_creative_inventory=not extra_nodes and 1 or 0},
	minetest.registered_nodes["vlf_nether:nether_brick"]._vlf_hardness,
	minetest.registered_nodes["vlf_nether:nether_brick"]._vlf_blast_resistance,
	vlf_sounds.node_sound_stone_defaults(), "vlf_fences_nether_brick_fence_gate_open", "vlf_fences_nether_brick_fence_gate_close", 1, 1)

-- Crafting

if extra_nodes then
	minetest.register_craft({
		output = "vlfx_fences:red_nether_brick_fence 6",
		recipe = {
			{"vlf_nether:red_nether_brick", "vlf_nether:netherbrick", "vlf_nether:red_nether_brick"},
			{"vlf_nether:red_nether_brick", "vlf_nether:netherbrick", "vlf_nether:red_nether_brick"},
		}
	})

	minetest.register_craft({
		output = "vlfx_fences:red_nether_brick_fence_gate",
		recipe = {
			{"vlf_nether:nether_wart_item", "vlf_nether:red_nether_brick", "vlf_nether:netherbrick"},
			{"vlf_nether:netherbrick", "vlf_nether:red_nether_brick", "vlf_nether:nether_wart_item"},
		}
	})
	minetest.register_craft({
		output = "vlfx_fences:red_nether_brick_fence_gate",
		recipe = {
			{"vlf_nether:netherbrick", "vlf_nether:red_nether_brick", "vlf_nether:nether_wart_item"},
			{"vlf_nether:nether_wart_item", "vlf_nether:red_nether_brick", "vlf_nether:netherbrick"},
		}
	})

	minetest.register_craft({
		output = "vlfx_fences:nether_brick_fence_gate 2",
		recipe = {
			{"vlf_nether:netherbrick", "vlf_nether:nether_brick", "vlf_nether:netherbrick"},
			{"vlf_nether:netherbrick", "vlf_nether:nether_brick", "vlf_nether:netherbrick"},
		}
	})
end


-- Aliases for vlf_supplemental
minetest.register_alias("vlf_supplemental:red_nether_brick_fence", "vlfx_fences:red_nether_brick_fence")

minetest.register_alias("vlf_supplemental:nether_brick_fence_gate", "vlfx_fences:nether_brick_fence_gate")
minetest.register_alias("vlf_supplemental:nether_brick_fence_gate_open", "vlfx_fences:nether_brick_fence_gate_open")

minetest.register_alias("vlf_supplemental:red_nether_brick_fence_gate", "vlfx_fences:red_nether_brick_fence_gate")
minetest.register_alias("vlf_supplemental:red_nether_brick_fence_gate_open", "vlfx_fences:red_nether_brick_fence_gate_open")
