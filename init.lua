doc = {}

doc.VERSION = {}
doc.VERSION.MAJOR = 0
doc.VERSION.MINOR = 1
doc.VERSION.PATCH = 0
doc.VERSION.STRING = doc.VERSION.MAJOR.."."..doc.VERSION.MINOR.."."..doc.VERSION.PATCH


doc.data = {}
doc.data.categories = {}
doc.data.players = {}

-- Space for additional APIs
doc.sub = {}

--[[ Core API functions ]]

-- Add a new category
function doc.new_category(id, def)
	if doc.data.categories[id] == nil and id ~= nil then
		doc.data.categories[id] = {}
		doc.data.categories[id].entries = {}
		doc.data.categories[id].def = def
		return true
	else
		return false
	end
end

-- Add a new entry
function doc.new_entry(category_id, entry_id, def)
	if doc.data.categories[category_id] ~= nil then
		doc.data.categories[category_id].entries[entry_id] = def
		return true
	else
		return false
	end
end

-- Opens the main documentation formspec for the player
function doc.show_doc(playername)
	local formspec = doc.formspec_core()..doc.formspec_main()
	minetest.show_formspec(playername, "doc:main", formspec)
end

-- Opens the documentation formspec for the player at the specified category
function doc.show_category(playername, category_id)
	doc.data.players[playername].catsel = nil
	doc.data.players[playername].category = category_id
	doc.data.players[playername].entry = nil
	local formspec = doc.formspec_core(2)..doc.formspec_category(category_id, playername)
	minetest.show_formspec(playername, "doc:category", formspec)
end

-- Opens the documentation formspec for the player showing the specified entry in a category
function doc.show_entry(playername, category_id, entry_id)
	doc.data.players[playername].catsel = nil
	doc.data.players[playername].category = category_id
	doc.data.players[playername].entry = entry_id
	local eids, catsel = doc.data.players[playername].entry_ids, doc.data.players[playername].catsel
	local formspec = doc.formspec_core(3)..doc.formspec_entry(category_id, entry_id)
	minetest.show_formspec(playername, "doc:entry", formspec)
end

-- Returns true if and only if:
-- * The specified category exists
-- * This category contains the specified entry
function doc.entry_exists(category_id, entry_id)
	if doc.data.categories[category_id] ~= nil then
		return doc.data.categories[category_id].entries[entry_id] ~= nil
	else
		return false
	end
end

--[[ Functions for internal use ]]

function doc.formspec_core(tab)
	if tab == nil then tab = 1 else tab = tostring(tab) end
	return "size[12,9]tabheader[0,0;doc_header;Main,Category,Entry;"..tab..";true;false]"
end

function doc.formspec_main()
	local y = 1
	local formstring = "label[0,0;Available help topics:]"
	for id,data in pairs(doc.data.categories) do
		local button = "button[0,"..y..";3,1;doc_button_category_"..id..";"..minetest.formspec_escape(data.def.name).."]"
		formstring = formstring .. button
		y = y + 1
	end
	return formstring
end

function doc.generate_entry_list(cid, playername)
	local formstring
	if doc.data.players[playername].entry_textlist == nil or doc.data.players[playername].category ~= cid then
		local entry_textlist = "textlist[0,1;11,7;doc_catlist;"
		local counter = 0
		doc.data.players[playername].entry_ids = {}
		local entries = doc.get_sorted_entry_names(cid)
		for i=1, #entries do
			table.insert(doc.data.players[playername].entry_ids, entries[i].eid)
			entry_textlist = entry_textlist .. minetest.formspec_escape(entries[i].name) .. ","
			counter = counter + 1
		end
		if counter >= 1  then
			entry_textlist = string.sub(entry_textlist, 1, #entry_textlist-1)
		end
		local catsel = doc.data.players[playername].catsel
		if catsel then
			entry_textlist = entry_textlist .. ";"..catsel
		end
		entry_textlist = entry_textlist .. "]"
		doc.data.players[playername].entry_textlist = entry_textlist
		formstring = entry_textlist
	else
		formstring = doc.data.players[playername].entry_textlist
	end
	return formstring
end

function doc.get_sorted_entry_names(cid)
	local sort_table = {}
	local entry_table = {}
	for eid,entry in pairs(doc.data.categories[cid].entries) do
		local new_entry = table.copy(entry)
		new_entry.eid = eid
		table.insert(entry_table, new_entry)
		table.insert(sort_table, entry.name)
	end
	table.sort(sort_table)
	local reverse_sort_table = table.copy(sort_table)
	for i=1, #sort_table do
		reverse_sort_table[sort_table[i]] = i
	end
	local comp = function(e1, e2)
		if reverse_sort_table[e1.name] < reverse_sort_table[e2.name] then return true else return false end
	end
	table.sort(entry_table, comp)

	return entry_table
end

function doc.formspec_category(id, playername)
	local formstring
	if id == nil then
		formstring = "label[0,0;You haven't selected a help topic yet. Please select one in the category list first.]"
		formstring = formstring .. "button[0,1;3,1;doc_button_goto_main;Go to category list]"
	else
		formstring = "label[0,0;Current help topic: "..doc.data.categories[id].def.name.."]"
		formstring = formstring .. "label[0,0.5;Available entries:]"
		formstring = formstring .. doc.generate_entry_list(id, playername)
		formstring = formstring .. "button[0,8;3,1;doc_button_goto_entry;Show entry]"
	end
	return formstring
end

function doc.formspec_entry(category_id, entry_id)
	local formstring
	if category_id == nil then
		formstring = "label[0,0;You haven't selected a help topic yet. Please select one in the category list first.]"
		formstring = formstring .. "button[0,1;3,1;doc_button_goto_main;Go to category list]"
	elseif entry_id == nil then
		formstring = "label[0,0;You haven't selected an help entry yet. Please select one in the list of entries first.]"
		formstring = formstring .. "button[0,1;3,1;doc_button_goto_category;Go to entry list]"
	else
		local category = doc.data.categories[category_id]
		local entry = category.entries[entry_id]
		formstring = "label[0,0;Help > "..category.def.name.." > "..entry.name.."]"
		formstring = formstring .. category.def.build_formspec(entry.data)
	end
	return formstring
end

function doc.process_form(player,formname,fields)
	local playername = player:get_player_name()
	--[[ process clicks on the tab header ]]
	if(formname == "doc:main" or formname == "doc:category" or formname == "doc:entry") then
		if fields.doc_header ~= nil then
			local tab = tonumber(fields.doc_header)
			local formspec, subformname, contents
			if(tab==1) then
				contents = doc.formspec_main()
				subformname = "main"
			elseif(tab==2) then
				contents = doc.formspec_category(doc.data.players[playername].category, playername)
				subformname = "category"
			elseif(tab==3) then
				contents = doc.formspec_entry(doc.data.players[playername].category, doc.data.players[playername].entry)
				subformname = "entry"
			end
			formspec = doc.formspec_core(tab)..contents
			minetest.show_formspec(playername, "doc:" .. subformname, formspec)
			return
		end
	end
	if(formname == "doc:main") then
		for id,category in pairs(doc.data.categories) do
			if fields["doc_button_category_"..id] then
				local formspec = doc.formspec_core(2)..doc.formspec_category(id, playername)
				doc.data.players[playername].catsel = nil
				doc.data.players[playername].category = id
				doc.data.players[playername].entry = nil
				minetest.show_formspec(playername, "doc:category", formspec)
				break
			end
		end
	elseif(formname == "doc:category") then
		if fields["doc_button_goto_entry"] then
			local cid = doc.data.players[playername].category
			if cid ~= nil then
				local eid = nil
				local eids, catsel = doc.data.players[playername].entry_ids, doc.data.players[playername].catsel
				if eids ~= nil and catsel ~= nil then
					eid = eids[catsel]
				end
				local formspec = doc.formspec_core(3)..doc.formspec_entry(cid, eid)
				minetest.show_formspec(playername, "doc:entry", formspec)
			end
		end
		if fields["doc_button_goto_main"] then
			local formspec = doc.formspec_core(1)..doc.formspec_main()
			minetest.show_formspec(playername, "doc:main", formspec)
		end
		if fields["doc_catlist"] then
			local event = minetest.explode_textlist_event(fields["doc_catlist"])
			if event.type == "CHG" then
				doc.data.players[playername].catsel = event.index
				doc.data.players[playername].entry = doc.data.players[playername].entry_ids[event.index]
			elseif event.type == "DCL" then
				local cid = doc.data.players[playername].category
				local eid = nil
				local eids, catsel = doc.data.players[playername].entry_ids, event.index
				if eids ~= nil and catsel ~= nil then
					eid = eids[catsel]
				end
				local formspec = doc.formspec_core(3)..doc.formspec_entry(cid, eid)
				minetest.show_formspec(playername, "doc:entry", formspec)
			end
		end
	elseif(formname == "doc:entry") then
		if fields["doc_button_goto_main"] then
			local formspec = doc.formspec_core(1)..doc.formspec_main()
			minetest.show_formspec(playername, "doc:main", formspec)
		elseif fields["doc_button_goto_category"] then
			local formspec = doc.formspec_core(2)..doc.formspec_category(doc.data.players[playername].category, playername)
			minetest.show_formspec(playername, "doc:category", formspec)
		end
	end
end

minetest.register_on_player_receive_fields(doc.process_form)

minetest.register_chatcommand("doc", {
	params = "",
	description = "Show in-game documentation system.",
	privs = {},
	func = function(playername, param)
		doc.show_doc(playername)
	end,
	}
)

minetest.register_on_joinplayer(function(player)
	doc.data.players[player:get_player_name()] = {}
end)

minetest.register_on_leaveplayer(function(player)
	doc.data.players[player:get_player_name()] = nil
end)
