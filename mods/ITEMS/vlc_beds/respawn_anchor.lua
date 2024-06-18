--TODO: Add sounds for the respawn anchor (charge sounds etc.)

--Nether ends at y -29077
--Nether roof at y -28933
local S = minetest.get_translator(minetest.get_current_modname())
--local mod_doc = minetest.get_modpath("doc") -> maybe add documentation ?

for i=0,4 do

	local function rightclick(pos, node, player, itemstack)
		if itemstack.get_name(itemstack) == "vlc_nether:glowstone" and i ~= 4 then
			minetest.set_node(pos, {name="vlc_beds:respawn_anchor_charged_" .. i+1})
			itemstack:take_item()
		elseif vlc_worlds.pos_to_dimension(pos) ~= "nether" then
			if node.name ~= "vlc_beds:respawn_anchor" then --only charged respawn anchors are exploding in the overworld & end in minecraft
				vlc_explosions.explode(pos, 5, {drop_chance = 0, fire = true})
			end
		elseif string.match(node.name, "vlc_beds:respawn_anchor_charged_") then
			minetest.chat_send_player(player.get_player_name(player), S"New respawn position set!")
			vlc_spawn.set_spawn_pos(player, pos, nil)
			if i == 4 then
				awards.unlock(player:get_player_name(), "vlc:notQuiteNineLives")
			end
		end
	end


	if i == 0 then
		minetest.register_node("vlc_beds:respawn_anchor",{
			description=S("Respawn Anchor"),
			tiles = {
				"respawn_anchor_top_off.png",
				"respawn_anchor_bottom.png",
				"respawn_anchor_side0.png"
			},
			is_ground_content = false,
			on_rightclick = rightclick,
			groups = {pickaxey=1, material_stone=1},
			_vlc_hardness = 22.5,
			sounds= vlc_sounds.node_sound_stone_defaults(),
			use_texture_alpha = "blend",
		})
		mesecon.register_mvps_stopper("vlc_beds:respawn_anchor")
	else
		minetest.register_node("vlc_beds:respawn_anchor_charged_"..i,{
			description=S("Respawn Anchor"),
			tiles = {
			{
				name = "respawn_anchor_top_on.png",
				animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}
			},
				"respawn_anchor_bottom.png",
				"respawn_anchor_side"..i ..".png"
			},
			on_rightclick = rightclick,
			groups = {pickaxey=1, material_stone=1, not_in_creative_inventory=1},
			_vlc_hardness = 22.5,
			sounds= vlc_sounds.node_sound_stone_defaults(),
			drop = {
				max_items = 1,
				items = {
					{items = {"vlc_beds:respawn_anchor"}},
				}
			},
			light_source = math.min((4 * i) - 1, minetest.LIGHT_MAX),
			use_texture_alpha = "opaque",
		})
		mesecon.register_mvps_stopper("vlc_beds:respawn_anchor_charged_"..i)
	end
 end


minetest.register_craft({
	output = "vlc_beds:respawn_anchor",
	recipe = {
			{"vlc_core:crying_obsidian", "vlc_core:crying_obsidian", "vlc_core:crying_obsidian"},
			{"vlc_nether:glowstone", "vlc_nether:glowstone", "vlc_nether:glowstone"},
			{"vlc_core:crying_obsidian", "vlc_core:crying_obsidian", "vlc_core:crying_obsidian"}
		}
	})
