doc = {}

doc.VERSION = {}
doc.VERSION.MAJOR = 0
doc.VERSION.MINOR = 1
doc.VERSION.PATCH = 0
doc.VERSION.STRING = "0.1.0"


doc.data = {}
doc.data.categories = {}

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

doc.new_category("one", {name="One"})
doc.new_category("two", {name="Two"})
doc.new_category("three", {name="Three"})

function doc.new_entry(category_id, entry_id, def)
	if doc.data.categories[category_id] ~= nil then
		doc.data.categories[category_id].entries[entry_id] = def
		return true
	else
		return false
	end
end

function doc.show_doc(playername)
	local formspec = doc.formspec_core()..doc.formspec_main()
	minetest.show_formspec(playername, "doc:main", formspec)
end

function doc.formspec_core(tab)
	if tab == nil then tab = 1 else tab = tostring(tab) end
	return "size[12,9]tabheader[0,0;doc_header;Main,Category,Entry;"..tab..";true;false]"
end

function doc.formspec_main()
	local y = 1
	local formstring = "label[0,0;Available help topics:]"
	for id,data in pairs(doc.data.categories) do
		local button = "button[0,"..y..";3,1;button_category_"..id..";"..data.def.name.."]"
		formstring = formstring .. button
		y = y + 1
	end
	return formstring
end

function doc.formspec_category()
	return "label[0,1;Category]"
end

function doc.formspec_entry()
	return "label[0,1;Entry]"
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
				contents = doc.formspec_category()
				subformname = "category"
			elseif(tab==3) then
				contents = doc.formspec_entry()
				subformname = "entry"
			end
			formspec = doc.formspec_core(tab)..contents
			minetest.show_formspec(playername, "doc:" .. subformname, formspec)
			return
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
