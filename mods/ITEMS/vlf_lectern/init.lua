-- Made for MineClone 2 by Michieal.
-- Texture made by Michieal; The model borrows the top from NathanS21's (Nathan Salapat) Lectern model; The rest of the
-- lectern model was created by Michieal.
-- Adapted for mineclonia and added model with book by pixelzone
-- lectern GUI code by cora

local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape

local function get_formspec(text, title, author)
	local fs = "size[8,9]" ..
	"no_prepend[]" .. vlf_vars.gui_nonbg .. vlf_vars.gui_bg_color ..
	"style_type[button;border=false;bgimg=vlf_books_button9.png;bgimg_pressed=vlf_books_button9_pressed.png;bgimg_middle=2,2]" ..
	"background[-0.5,-0.5;9,10;vlf_books_book_bg.png]"

	if title ~= "" then
		fs = fs .. "hypertext[0,0.3;8,0.7;title;<style color=black font=normal size=24><center>"..F(title or "").."</center></style>]"
	end
	if author ~= "" then
		fs = fs .. "hypertext[0.75,0.8;7.25,0.5;author;<style color=black font=normal size=12>by </style><style color=#1E1E1E font=mono size=14>"..F(author or "").."</style>]"
	end
	fs = fs .."textarea[0.75,1.24;7.20,7.5;;" .. F(text or "") .. ";]" ..
	"button_exit[1.25,7.95;3,1;ok;" .. F(S("Done")) .. "]"..
	"button[4.25,7.95;3,1;take;" .. F(S("Take Book")) .. "]"
	return fs
end

local lectern_tpl = {
	description = S("Lectern"),
	_tt_help = S("Lecterns not only look good, but are job site blocks for Librarians."),
	_doc_items_longdesc = S("Lecterns not only look good, but are job site blocks for Librarians."),
	_doc_items_usagehelp = S("Place the Lectern on a solid node for best results. May attract villagers, so it's best to place outside of where you call 'home'."),
	sounds = vlf_sounds.node_sound_wood_defaults(),
	paramtype = "light",
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	paramtype2 = "facedir",
	drawtype = "mesh",
	mesh = "vlf_lectern_lectern.obj",
	tiles = {"vlf_lectern_lectern.png", },
	drop = "vlf_lectern:lectern",
	groups = {handy = 1, axey = 1, flammable = 2, fire_encouragement = 5, fire_flammability = 5, solid = 1, deco_block=1, lectern = 1, _vlf_partial = 2},
	sunlight_propagates = true,
	is_ground_content = false,
	node_placement_prediction = "",
	_vlf_blast_resistance = 3,
	_vlf_hardness = 2,
	_vlf_burntime = 15,
	selection_box = {
		type = "fixed",
		fixed = {
			--   L,    T,    Ba,    R,    Bo,    F.
			{-0.5, -0.5, -0.5, 0.5, -0.5 + 2/16, 0.5},
			{-0.25, -0.5 + 2/16, -0.25, 0.25, 0.5 - 2/16, 0.25},
			{-0.5 + 1/16, 0.5 - 2/16, -0.5 + 1/16, 0.5 - 1/16, 0.5 + 2/16, 0.5 - 1/16},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			--   L,    T,    Ba,    R,    Bo,    F.
			{-0.32, 0.46, -0.32, 0.32, 0.175, 0.32},
			{-0.18, 0.175, -0.055, 0.18, -0.37, 0.21},
			{-0.5 + 1/16, 0.5 - 2/16, -0.5 + 1/16, 0.5 - 1/16, 0.5 + 0/16, 0.5 - 1/16},
		}
	},

	on_place = function(itemstack, placer, pointed_thing)

		if not placer or not placer:is_player() then
			return itemstack
		end

		local rc = vlf_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		if minetest.is_protected(pointed_thing.above, placer:get_player_name()) then
			minetest.record_protection_violation(pointed_thing.above, placer:get_player_name())
			return
		end

		if minetest.dir_to_wallmounted(vector.subtract(pointed_thing.under,  pointed_thing.above)) == 1 then
			local _, success = minetest.item_place_node(itemstack, placer, pointed_thing, minetest.dir_to_facedir(vector.direction(placer:get_pos(),pointed_thing.above)))
			if not success then
				return
			end
			minetest.sound_play(vlf_sounds.node_sound_wood_defaults().place, {pos=pointed_thing.above, gain=1}, true)
		end
		return itemstack
	end,
}

minetest.register_node("vlf_lectern:lectern", table.merge(lectern_tpl,{
	on_rightclick = function(pos, node, clicker, itemstack)
		if itemstack:get_name() == "vlf_books:written_book"
			or itemstack:get_name() == "vlf_books:writable_book" then
			local player_name = clicker:get_player_name()
			if minetest.is_protected(pos, player_name) then
				minetest.record_protection_violation(pos, player_name)
				return
			end
			local im = itemstack:get_meta()
			local nm = minetest.get_meta(pos)
			node.name = "vlf_lectern:lectern_with_book"
			vlf_redstone.swap_node(pos,node)
			nm:set_string("formspec",get_formspec(im:get_string("text"),im:get_string("title"),im:get_string("author")))
			if itemstack:get_name() == "vlf_books:written_book" then
				nm:set_string("infotext", im:get_string("author") .. " - " .. im:get_string("title"))
			end
			nm:set_string("pages","15")
			nm:set_string("page","1")
			local book_item = ItemStack(itemstack)
			if not minetest.is_creative_enabled(player_name) then
				book_item = itemstack:take_item()
			end
			book_item:set_count(1)
			nm:set_string("book_item", book_item:to_string())
			return itemstack
		end
	end,
	_vlf_redstone = {
		connects_to = function()
			return true
		end,
	},
}))

minetest.register_node("vlf_lectern:lectern_with_book", table.merge( lectern_tpl,{
	groups = table.merge(lectern_tpl.groups, {not_in_creative_inventory = 1}),
	mesh = "vlf_lectern_lectern_with_book.obj",
	on_receive_fields = function(pos, _, fields, sender)
		local sender_name = sender:get_player_name()
		if minetest.is_protected(pos, sender_name) then
			minetest.record_protection_violation(pos, sender_name)
			return
		end
		if fields and fields.take then
			local inv = sender:get_inventory()
			local node = minetest.get_node(pos)
			local nm = minetest.get_meta(pos)
			local is = nm:get_string("book_item")
			if is and is ~= "" then
				inv:add_item("main", is)
			end
			node.name = "vlf_lectern:lectern"
			vlf_redstone.swap_node(pos,node)
			nm:set_string("formspec","")
			nm:set_string("infotext","")
			nm:set_string("pages","")
			nm:set_string("book_item","")
			nm:set_string("page","")
		elseif fields and fields.ok then
			-- simulate a page turn
			-- TODO: actually implement multi page books
			local node = minetest.get_node(pos)
			local nm = minetest.get_meta(pos)
			local pages = tonumber(nm:get_string("pages")) or 1
			local page = tonumber(nm:get_string("page")) or 1
			page = (page % pages) + 1
			nm:set_string("page",tostring(page))
			if node.param2 < 128 then
				node.param2 = node.param2 + 128
				vlf_redstone.swap_node(pos,node)
			end
		end
	end,
	after_dig_node = function(pos, _, oldmetadata, _)
		if oldmetadata and oldmetadata.fields and oldmetadata.fields.book_item then
			minetest.add_item(pos, ItemStack(oldmetadata.fields.book_item))
		end
	end,
	_vlf_redstone = {
		connects_to = function()
			return true
		end,
		get_power = function(node, dir)
			local powered = node.param2 >= 128
			return powered and 15 or 0, false
		end,
		update = function(_, node)
			local powered = node.param2 >= 128
			if powered then
				return {
					name = node.name,
					param2 = node.param2 - 128,
				}
			end
		end,
	},
}))

vlf_wip.register_wip_item("vlf_lectern:lectern")

-- April Fools setup
local date = os.date("*t")
if (date.month == 4 and date.day == 1) then
	minetest.override_item("vlf_lectern:lectern", {waving = 2})
end

minetest.register_craft({
	output = "vlf_lectern:lectern",
	recipe = {
		{"group:wood_slab", "group:wood_slab", "group:wood_slab"},
		{"", "vlf_books:bookshelf", ""},
		{"", "group:wood_slab", ""},
	}
})
