#!/usr/bin/env lua5.1
--[[

dependencies: luarocks install --lua-version 5.1 metalua luafileystem utf8

rules for lua code this script enforces:

- a local variable S may be assigned to minetest.get_translator(...) where it's argument is one of:
	- minetest.get_current_modname() - current modname will be used as textdomain
	- modname - current modname will be used as textdomain
	- "..." - any string literal that will be used as textdomain
- S may be called with a string literal or concatenation of string literals as first argument. in this case, the first argument will be interpreted as translation template string.
- a local variable W may be assigned to mcl_curry(S)
- S may be called with a string literal or concatenation of string literals as argument. in this case, the argument will be interpreted as translation template string.
- S and W may not we used in any other way
- S may not be assigned twice in a scope
- minetest.get_translator may not be used in any other way
- minetest.translate may not be used

=> Translation strings can not be generated programmatically.

These conditions are very strict to keep the logic of the script minimal while ensuring all translation strings are caught, and cases that can't be handled will throw an error.
If necessary, the set of handled cases may be extended in the future.

for translation files:
- @n must be used for newline escapes
- the script will move unused ("dead") translation strings to a seperate section after used ("alive") translation strings
- the script will add new translation strings at the end of the alive section
- the script will revive strings that are used again and move them back to the alive section
- a line '##### not used anymore ##### is treated as a marker for the begging of the dead section
- comments (with the exception of the textdomain comment) will be treated as referring to the line that follows the comments. they will be moved together with lines. multiple comment lines following each other will be treated as a block and moved together.

]]

local mlc = require("metalua.compiler").new()
local lfs = require("lfs")
local utf8 = require("utf8")

function iterdir(path, func, ...)
	for file in lfs.dir(path) do
		if file:sub(1,1) ~= "." then
			func(path .. "/" .. file, ...)
		end
	end
end

function dump(node, ident)
	ident = ident or ""
	io.write(ident)

	if type(node) ~= "table" then
		print(node)
		return
	end

	print(node.tag)
	for _, c in ipairs(node) do
		dump(c, ident .. "  ")
	end
end

function is_ident(node, id)
	return type(node) == "table" and #node == 1 and node.tag == "Id" and node[1] == id
end

function match(n1, n2)
	if is_ident(n2, "XXX") then
		return n1
	end

	if type(n1) ~= "table" or type(n2) ~= "table" then
		return n1 == n2
	end

	if n1.tag ~= n2.tag or #n1 ~= #n2 then
		return
	end

	local result = true

	for i, c1 in ipairs(n1) do
		local x = match(c1, n2[i])

		if not x then
			return
		end

		if x ~= true then
			result = x
		end
	end

	return result
end

function lineinfo(node)
	return node.lineinfo.first.source .. ":" .. node.lineinfo.first.line
end

local node_assign_S = mlc:src_to_ast("local S = minetest.get_translator(XXX)")[1]
local node_get_modname = mlc:src_to_ast("minetest.get_current_modname()")[1]
local node_string = { tag = "String", { tag = "Id", "XXX" } }
local node_assign_W = mlc:src_to_ast("local W = mcl_curry(S)")[1]

function match_concat(node)
	local x = match(node, node_string)

	if x then
		return x
	end

	if type(node) == "table" and node[1] == "concat" then
		local a, b = match_concat(node[2]), match_concat(node[3])

		if a and b then
			return a .. b
		end
	end
end

function is_translator(node)
	return is_ident(node, "S") or is_ident(node, "W")
end

local mods = {}
local num_mods = 0

-- process an AST node
function proc_node(modname, node, stack, target)
	local target_node = match(node, node_assign_S)
	if target_node then
		assert(not target, "get_translator called twice " .. lineinfo(target_node))

		local target_name
		if is_ident(target_node, "modname") or match(target_node, node_get_modname) then
			target_name = modname
		else
			target_name = match(target_node, node_string)
			assert(target_name, "malformed get_translator argument " .. lineinfo(target_node))
		end

		target = mods[target_name]
		assert(target, "absent mod: " .. target_name .. " " .. lineinfo(target_node))

		return target
	elseif match(node, node_assign_W) then
		assert(target, "currying translator before getting it " .. lineinfo(node))
	elseif is_ident(node, "get_translator") or is_ident(node, "translate") then
		error("malformed occurence of get_translator/translate " .. lineinfo(node))
	elseif is_translator(node) then
		error("malformed occurence of translator " .. lineinfo(node))
	elseif type(node) == "table" and node.tag == "Call" and is_translator(node[1]) then
		local template = match_concat(node[2])

		assert(template, "malformed argument to call to translator " .. lineinfo(node))
		assert(target, "call to translator before assigned ", lineinfo(node))

		template = utf8.gsub(template, "@[^@=0-9]", "@@")
		template = utf8.gsub(template, '\\"', '"')
		template = utf8.gsub(template, "\\'", "'")
		template = utf8.gsub(template, "\n", "@n")
		template = utf8.gsub(template, "\\n", "@n")
		template = utf8.gsub(template, "=", "@=")

		if not target.template_set[template] then
			target.template_set[template] = true
			table.insert(target.template_list, template)
		end
	elseif type(node) == "table" then
		table.insert(stack, node)
		for _, child in ipairs(node) do
			target = proc_node(modname, child, stack, target) or target
		end
		table.remove(stack)
	end
end

-- process a source file (or directory containing source files)
function proc_file(path, modname)
	if lfs.attributes(path).mode == "directory" then
		iterdir(path, proc_file, modname)
		return
	end

	if not path:match("%.lua$") then
		return
	end

	proc_node(modname, mlc:srcfile_to_ast(path), {})
end

-- process a mod or modpack
function proc_mod(path, modpack)
	if modpack or io.open(path .. "/modpack.conf") then
		iterdir(path, proc_mod)
		return
	end

	local f = io.open(path .. "/mod.conf")
	if not f then
		return
	end

	local modname
	for l in f:lines() do
		modname = select(4, l:match("(%s*)name(%s*)=(%s*)([%w_]+)(%s*)"))
		if modname then
			break
		end
	end
	assert(modname, path .. " mod.conf does not contain name")

	if mods[modname] then
		error(modname .. " exists twice at " .. path .. " and " .. mods[modname].path)
	end

	mods[modname] = {
		path = path,
		template_set = {},
		template_list = {},
	}

	num_mods = num_mods + 1
end

function update_template(modname, mod)
	local filename = mod.path .. "/locale/template.txt"
	local f = io.open(filename, "r")

	local has = {}

	local alive = {}

	local dead_add = {}
	local dead_keep = {}

	local unused_line = "##### not used anymore #####"

	if f then
		local current = alive
		local dead = dead_add

		local comments = {}
		local function emit(into, line)
			for _, c in ipairs(comments) do
				table.insert(into, c)
			end
			comments = {}

			table.insert(into, line)
		end

		local function process_line(line)
			local lhs = utf8.match(line, "^(.-)=$")
			local textdomain = utf8.match(line, "# textdomain:%s?(.-)$")

			if textdomain then
				assert(textdomain == modname,
					"invalid textdomain, expected '" .. modname .. "', got '" .. textdomain .. "'")
			elseif line == unused_line then
				dead = dead_keep
				current = dead_keep

				emit(current)
			elseif utf8.sub(line, 1, 1) == "#" then
				table.insert(comments, line)
			elseif lhs then
				if not has[lhs] then
					has[lhs] = true
					emit(mod.template_set[lhs] and alive or dead, line)
				end
			elseif line == "" then
				emit(current, line)
			else
				error("invalid line: '" .. line .. "' in file " .. filename)
			end
		end

		for line in f:lines() do
			process_line(line)
		end

		if #comments > 0 then
			emit(current)
		end

		f:close()
	elseif #mod.template_list > 0 then
		lfs.mkdir(mod.path .. "/locale")
	else
		return
	end

	table.insert(alive, 1, "# textdomain: " .. modname)

	f = io.open(filename, "w")
	local function emit(str)
		f:write(str .. "\n")
	end

	-- emit old lines that have not been killed
	for _, l in ipairs(alive) do
		emit(l)
	end

	-- emit newly spawned lines, in order of occurence in source code
	for _, t in ipairs(mod.template_list) do
		if not has[t] then
			emit(t .. "=")
		end
	end

	if #dead_keep > 0 or #dead_add > 0 then
		emit(unused_line)

		-- emit old dead lines that have not been revived
		for _, l in ipairs(dead_keep) do
			emit(l)
		end

		-- emit newly killed lines
		for _, l in ipairs(dead_add) do
			emit(l)
		end
	end

	f:close()
end

print("populating mods...")
proc_mod("mods", true)

print("extracting translations...")

local cols = io.popen("stty size", "r"):read("*all"):match("%d+ (%d+)")

if cols then
	cols = cols - 2

	io.write("[" .. string.rep(" ", cols) .. "]\r[")
	io.flush()
end

local i, c = 0, 0
for modname, mod in pairs(mods) do
	proc_file(mod.path, modname)

	i = i + 1
	if cols then
		local col = math.floor(cols*i/num_mods)

		while col > c do
			io.write("#")
			c = c + 1
		end
	else
		io.write(".")
	end
	io.flush()
end

if cols then
	print("]")
else
	print()
end

print("updating translation templates...")
for modname, mod in pairs(mods) do
	update_template(modname, mod)
end
