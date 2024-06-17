local S = minetest.get_translator(minetest.get_current_modname())
local extra_nodes = minetest.settings:get_bool("vlc_extra_nodes", true)

-- Red Nether Brick Fence

vlc_fences.register_fence_and_fence_gate(
	"red_nether_brick_fence",
	S("Red Nether Brick Fence"), S("Red Nether Brick Fence Gate"),
	"vlc_fences_fence_red_nether_brick.png",
	{pickaxey=1, deco_block=1, fence_nether_brick=1, not_in_creative_inventory=not extra_nodes and 1 or 0},
	minetest.registered_nodes["vlc_nether:red_nether_brick"]._vlc_hardness,
	minetest.registered_nodes["vlc_nether:red_nether_brick"]._vlc_blast_resistance,
	{"group:fence_nether_brick"},
	vlc_sounds.node_sound_stone_defaults(), "vlc_fences_nether_brick_fence_gate_open", "vlc_fences_nether_brick_fence_gate_close", 1, 1,
	"vlc_fences_fence_gate_red_nether_brick.png")

vlc_fences.register_fence_gate(
	"nether_brick_fence",
	S("Nether Brick Fence Gate"),
	"vlc_fences_fence_gate_nether_brick.png",
	{pickaxey=1, deco_block=1, fence_nether_brick=1, not_in_creative_inventory=not extra_nodes and 1 or 0},
	minetest.registered_nodes["vlc_nether:nether_brick"]._vlc_hardness,
	minetest.registered_nodes["vlc_nether:nether_brick"]._vlc_blast_resistance,
	vlc_sounds.node_sound_stone_defaults(), "vlc_fences_nether_brick_fence_gate_open", "vlc_fences_nether_brick_fence_gate_close", 1, 1)

-- Crafting

if extra_nodes then
	minetest.register_craft({
		output = "vlcx_fences:red_nether_brick_fence 6",
		recipe = {
			{"vlc_nether:red_nether_brick", "vlc_nether:netherbrick", "vlc_nether:red_nether_brick"},
			{"vlc_nether:red_nether_brick", "vlc_nether:netherbrick", "vlc_nether:red_nether_brick"},
		}
	})

	minetest.register_craft({
		output = "vlcx_fences:red_nether_brick_fence_gate",
		recipe = {
			{"vlc_nether:nether_wart_item", "vlc_nether:red_nether_brick", "vlc_nether:netherbrick"},
			{"vlc_nether:netherbrick", "vlc_nether:red_nether_brick", "vlc_nether:nether_wart_item"},
		}
	})
	minetest.register_craft({
		output = "vlcx_fences:red_nether_brick_fence_gate",
		recipe = {
			{"vlc_nether:netherbrick", "vlc_nether:red_nether_brick", "vlc_nether:nether_wart_item"},
			{"vlc_nether:nether_wart_item", "vlc_nether:red_nether_brick", "vlc_nether:netherbrick"},
		}
	})

	minetest.register_craft({
		output = "vlcx_fences:nether_brick_fence_gate 2",
		recipe = {
			{"vlc_nether:netherbrick", "vlc_nether:nether_brick", "vlc_nether:netherbrick"},
			{"vlc_nether:netherbrick", "vlc_nether:nether_brick", "vlc_nether:netherbrick"},
		}
	})
end


-- Aliases for vlc_supplemental
minetest.register_alias("vlc_supplemental:red_nether_brick_fence", "vlcx_fences:red_nether_brick_fence")

minetest.register_alias("vlc_supplemental:nether_brick_fence_gate", "vlcx_fences:nether_brick_fence_gate")
minetest.register_alias("vlc_supplemental:nether_brick_fence_gate_open", "vlcx_fences:nether_brick_fence_gate_open")

minetest.register_alias("vlc_supplemental:red_nether_brick_fence_gate", "vlcx_fences:red_nether_brick_fence_gate")
minetest.register_alias("vlc_supplemental:red_nether_brick_fence_gate_open", "vlcx_fences:red_nether_brick_fence_gate_open")
