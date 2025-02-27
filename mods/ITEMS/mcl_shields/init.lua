local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local D = mcl_util.get_dynamic_translator(modname)

mcl_shields = {
	types = {
		mob = true,
		player = true,
		arrow = true,
		generic = true,
		explosion = true,
		dragon_breath = true,
	},
	enchantments = {"mending", "unbreaking"},
	players = {},
}

local interact_priv = minetest.registered_privileges.interact
interact_priv.give_to_singleplayer = false
interact_priv.give_to_admin = false

local overlay = mcl_enchanting.overlay
local hud = "mcl_shield_hud.png"

minetest.register_tool("mcl_shields:shield", {
	description = S("Shield"),
	_doc_items_longdesc = S("A shield is a tool used for protecting the player against attacks."),
	inventory_image = "mcl_shield_48.png",
	stack_max = 1,
	groups = {
		shield = 1,
		weapon = 1,
		enchantability = -1,
		offhand_item = 1,
	},
	sound = {breaks = "default_tool_breaks"},
	_repair_material = "group:wood",
	wield_scale = vector.new(2, 2, 2),
	_mcl_wieldview_item = "",
	_placement_class = "shield",
})

local function wielded_item(obj, i)
	local itemstack = obj:get_wielded_item()
	if i == 1 then
		itemstack = mcl_offhand.get_offhand(obj)
	end
	return itemstack:get_name(), itemstack
end

local function set_wielded_item(player, stack, i)
	if i ~= 1 then
		player:set_wielded_item(stack)
	else
		mcl_offhand.set_offhand(player, stack)
	end
end

function mcl_shields.wielding_shield(obj, i)
	return wielded_item(obj, i):find("mcl_shields:shield")
end

local function shield_is_enchanted(obj, i)
	return mcl_enchanting.is_enchanted(wielded_item(obj, i))
end

local rgb_to_unicolor

local function migrate_custom_shield_texture(texture)
	-- Build colour mapping, required to parse layer info from old texture
	if not rgb_to_unicolor then
		rgb_to_unicolor = {}
		for _, v in pairs( mcl_dyes.colors ) do
			rgb_to_unicolor[v.rgb:lower()] = v.unicolor
		end
	end
	-- Rebuild layers from texture.
	-- Example: (mcl_shield_base_nopattern.png^mcl_shield_pattern_base.png^[mask:mcl_shield_base_nopattern.png^mcl_shield_pattern_base.png)^((mcl_shield_base_nopattern.png^mcl_shield_pattern_base.png^[colorize:#f1b216:224)^[mask:mcl_shield_pattern_base.png)^((mcl_shield_pattern_rhombus.png^[colorize:#912222:255)^[mask:mcl_shield_pattern_rhombus.png)^((mcl_shield_pattern_globe.png^[colorize:#60ac19:255)^[mask:mcl_shield_pattern_globe.png)
	local layers = {}
	for layer in texture:gmatch("mcl_shield_pattern_([%w_]+%.png%^%[colorize:#[%w]+)") do
		-- layer = base.png^[colorize:#f1b216, rhombus.png^[colorize:#912222, globe.png^[colorize:#60ac19
		local i,j = layer:find( "%.png%^%[colorize:" )
		local pattern, colour = layer:sub(1, i-1), layer:sub(j+1):lower()
		if pattern ~= "base" then -- Base colour already coded in itemstring, only need layers.
			if not rgb_to_unicolor[colour] then
				core.log("warning", "Cannot migrate old shield banner pattern: "..colour.." not found in dye")
				return nil
			end
			table.insert(layers, { color = "unicolor_"..rgb_to_unicolor[colour], pattern = pattern } )
		end
	end
	return layers
end

local shield_texture_builder = {
	-- luacheck will flag this style of "function table" as non-standard global hence add an exception
	blank = function() return shield_texture_builder.combine("mcl_banners_banner_base.png","") end, -- luacheck: globals shield_texture_builder
	base = function (rgb, ratio)
		local banner = "mcl_banners_banner_base.png"
		if rgb then banner = "(" .. banner .. "^[colorize:"..rgb..":"..ratio .. ")" end
		return banner -- Passed as "base" in combine()
	end,
	combine = function (base, layers)
		local escape = mcl_banners.escape_texture
		-- Enlarge base texture for banner placement.  Banner patterns need to be resized and offset to leave only front.
		local shield = "[combine:128x128:0,0=mcl_shield_base_nopattern.png\\^[resize\\:128x128"
		return shield .. ":4,4=" .. escape("[combine:20x40:-1,-1=" .. escape(base .. layers .."^[resize:64x64"))
	end,
}

local function set_shield_layers(itemstack, layers)
	if not itemstack then return end
	local itemname, meta = itemstack:get_name(), itemstack:get_meta()
	local def = core.registered_items[itemname]
	if not meta or not def or not def._shield_color_key then return end
	local b, base_colour = mcl_banners, def._shield_color_key

	if layers and #layers > 0 then mcl_banners.write_layers(meta, layers) end
	b.update_description(itemstack)

	local item_image = b.make_banner_texture(base_colour, layers, "item")
	item_image = item_image:gsub("mcl_banners_item_base_48.png", "mcl_shield_48.png")
	meta:set_string("inventory_overlay", item_image)

	local texture = b.make_banner_texture(base_colour, layers, shield_texture_builder)
	meta:set_string("mcl_shields:banner_texture", texture)
	return texture
end

minetest.register_entity("mcl_shields:shield_entity", {
	initial_properties = {
		visual = "mesh",
		mesh = "mcl_shield.obj",
		physical = false,
		pointable = false,
		collide_with_objects = false,
		textures = {"mcl_shield_base_nopattern.png"},
		visual_size = vector.new(1, 1, 1),
	},
	_blocking = false,
	_shield_number = 2,
	_texture_copy = "",
	on_step = function(self, _, _)
		local player = self.object:get_attach()
		if not player then
			self.object:remove()
			return
		end
		local shield_texture = "mcl_shield_base_nopattern.png"
		local i = self._shield_number
		local item, itemstack = wielded_item(player, i)

		if item ~= "mcl_shields:shield" and item ~= "mcl_shields:shield_enchanted" then -- Bannered shield?
			local meta = itemstack:get_meta()
			local meta_texture = meta:get_string("mcl_shields:banner_texture")
			if meta_texture and meta_texture ~= "" then
				shield_texture = meta_texture
			else
				local layers
				meta:set_string("wield_overlay", "") -- Clear inner face (wield_texture) to show raw shield.
				local custom_texture = meta:get_string("mcl_shields:shield_custom_pattern_texture")
				if custom_texture and custom_texture ~= "" then -- Parse layers from custom standalone pattern texture.
					shield_texture = custom_texture
					layers = migrate_custom_shield_texture(custom_texture) -- May be nil
					if layers then -- Item image would be broken on downgrade anyway, may as well remove old cache.
						meta:set_string("mcl_shields:shield_custom_pattern_texture", nil)
					end
				else
					layers = mcl_banners.read_layers(meta) -- Non-nil
				end
				if layers then
					local texture = set_shield_layers(itemstack, layers)
					if texture then
						shield_texture = texture
					end
				end
				meta:set_string("mcl_shields:banner_texture", shield_texture)
				set_wielded_item(player, itemstack, i)
			end
		end

		if shield_is_enchanted(player, i) then
			shield_texture = shield_texture .. overlay
		end

		if self._texture_copy ~= shield_texture then
			self.object:set_properties({textures = {shield_texture}})
			self._texture_copy = shield_texture
		end
	end,
})

for _, e in pairs(mcl_shields.enchantments) do
	mcl_enchanting.enchantments[e].secondary.shield = true
end

function mcl_shields.is_blocking(obj)
	if not obj:is_player() then return end
	if mcl_shields.players[obj] then
		local blocking = mcl_shields.players[obj].blocking
		if blocking <= 0 then return end
		local _, shieldstack = wielded_item(obj, blocking)
		return blocking, shieldstack
	end
end

mcl_damage.register_modifier(function(obj, damage, reason)
	local type = reason.type
	local damager = reason.direct
	local blocking, shieldstack = mcl_shields.is_blocking(obj)

	if not (obj:is_player() and blocking and mcl_shields.types[type] and damager) then
		return
	end

	local entity = damager:get_luaentity()
	if entity and entity._shooter then
		damager = entity._shooter
	end

	local dpos = damager:get_pos()

	-- Used for removed / killed entities before the projectile hits the player
	if entity and not entity._shooter and entity._saved_shooter_pos then
		dpos = entity._saved_shooter_pos
	end

	if not dpos or vector.dot(obj:get_look_dir(), vector.subtract(dpos, obj:get_pos())) < 0 then
		return
	end

	local durability = 336
	local unbreaking = mcl_enchanting.get_enchantment(shieldstack, mcl_shields.enchantments[2])
	if unbreaking > 0 then
		durability = durability * (unbreaking + 1)
	end

	if not minetest.is_creative_enabled(obj:get_player_name()) and damage >= 3 then
		shieldstack:add_wear(65535 / durability) ---@diagnostic disable-line: need-check-nil
		if blocking == 2 then
			obj:set_wielded_item(shieldstack)
		else
			obj:get_inventory():set_stack("offhand", 1, shieldstack)
			mcl_inventory.update_inventory_formspec(obj)
		end
	end
	minetest.sound_play({name = "mcl_block"}, {pos = obj:get_pos(), max_hear_distance = 16})
	return 0
end)

local function modify_shield(player, vpos, vrot, i)
	local arm = "Right"
	if i == 1 then
		arm = "Left"
	end
	local shield = mcl_shields.players[player].shields[i]
	if shield then
		shield:set_attach(player, "Arm_" .. arm, vpos, vrot, false)
	end
end

local function set_shield(player, block, i)
	if block then
		if i == 1 then
			modify_shield(player, vector.new(-9, 4, 0.5), vector.new(80, 100, 0), i) -- TODO
		else
			modify_shield(player, vector.new(-8, 4, -2.5), vector.new(80, 80, 0), i)
		end
	else
		if i == 1 then
			modify_shield(player, vector.new(-3, -5, 0), vector.new(0, 180, 0), i)
		else
			modify_shield(player, vector.new(3, -5, 0), vector.new(0, 0, 0), i)
		end
	end
	local shield = mcl_shields.players[player].shields[i]
	if not shield then return end

	local luaentity = shield:get_luaentity()
	if not luaentity then return end

	luaentity._blocking = block
end

local function set_interact(player, interact)
	local player_name = player:get_player_name()
	local privs = minetest.get_player_privs(player_name)
	if privs.interact == interact then
		return
	end
	local meta = player:get_meta()

	if interact and meta:get_int("mcl_shields:interact_revoked") ~= 0 then
		meta:set_int("mcl_shields:interact_revoked", 0)
		privs.interact = true
	elseif not interact then
		meta:set_int("mcl_shields:interact_revoked", privs.interact and 1 or 0)
		privs.interact = nil
	end

	minetest.set_player_privs(player_name, privs)
end

-- Prevent player from being able to circumvent interact privilage removal by
-- using shield.
minetest.register_on_priv_revoke(function(name, revoker, priv)
	if priv == "interact" and revoker then
		local player = minetest.get_player_by_name(name)
		if not player then
			return
		end
		local meta = player:get_meta()
		meta:set_int("mcl_shields:interact_revoked", 0)
	end
end)

local shield_hud = {}

local function remove_shield_hud(player)
	set_interact(player, true)
	playerphysics.remove_physics_factor(player, "speed", "shield_speed")

	player:hud_remove(shield_hud[player])
	shield_hud[player] = nil
	set_shield(player, false, 1)
	set_shield(player, false, 2)

	local hf = player:hud_get_flags()
	if not hf.wielditem then
		player:hud_set_flags({wielditem = true})
	end
end

local function add_shield_entity(player, i)
	local shield = minetest.add_entity(player:get_pos(), "mcl_shields:shield_entity")
	if shield and shield:get_pos() then
		shield:get_luaentity()._shield_number = i
		mcl_shields.players[player].shields[i] = shield
		set_shield(player, false, i)
	end
end

local function remove_shield_entity(player, i)
	local shields = mcl_shields.players[player].shields
	if shields[i] then
		shields[i]:remove()
		shields[i] = nil
	end
end

local function is_node_stack(itemstack)
	return itemstack:get_definition().drawtype -- only node's definition table contains element "drawtype"
end

local function is_rmb_conflicting_node(nodename)
	local nodedef = minetest.registered_nodes[nodename]
	return nodedef and nodedef.on_rightclick
end

function mcl_shields.set_blocking (player, blocking)
	local player_shield = mcl_shields.players[player]
	if player_shield then
		player_shield.blocking = blocking
	end
end

local function handle_blocking(player)
	local player_shield = mcl_shields.players[player]
	if not player_shield then return end

	if mcl_serverplayer.is_csm_at_least (player, 1) then
		local shield_in_offhand
			= mcl_shields.wielding_shield (player, 1)
		local shield_in_hand
			= mcl_shields.wielding_shield (player)
		if not shield_in_hand and not shield_in_offhand then
			player_shield.blocking = 0
		end
		return
	end

	local rmb = player:get_player_control().RMB
	if not rmb then
		if player_shield.blocking ~= 0 then
			mcl_serverplayer.handle_blocking (player, 0)
		end
		player_shield.blocking = 0
		return
	end

	local shield_in_offhand = mcl_shields.wielding_shield(player, 1)
	local shield_in_hand = mcl_shields.wielding_shield(player)
	local not_blocking = player_shield.blocking == 0

	if shield_in_hand then
		if not_blocking then
			minetest.after(0.05, function()
				if (not_blocking or not shield_in_offhand) and shield_in_hand and rmb then
					if player_shield.blocking ~= 2 then
						mcl_serverplayer.handle_blocking (player, 2)
					end
					player_shield.blocking = 2
					set_shield(player, true, 2)
				end
			end)
		elseif not shield_in_offhand then
			player_shield.blocking = 2
			if player_shield.blocking ~= 2 then
				mcl_serverplayer.handle_blocking (player, 2)
			end
		end
	elseif shield_in_offhand then
		local pointed_thing = mcl_util.get_pointed_thing(player, true)
		local wielded_stack = player:get_wielded_item()
		local offhand_can_block = (minetest.get_item_group(wielded_item(player), "bow") ~= 1
		and minetest.get_item_group(wielded_item(player), "crossbow") ~= 1)

		if pointed_thing and pointed_thing.type == "node" then
			local pointed_node = minetest.get_node(pointed_thing.under)
			if minetest.get_item_group(pointed_node.name, "container") > 1
			or is_rmb_conflicting_node(pointed_node.name)
			or is_node_stack(wielded_stack)
			then
				return
			end
		end

		if not offhand_can_block then
			return
		end
		if not_blocking then
			minetest.after(0.05, function()
				if (not_blocking or not shield_in_hand) and shield_in_offhand and rmb  and offhand_can_block then
					if player_shield.blocking ~= 1 then
						mcl_serverplayer.handle_blocking (player, 1)
					end
					player_shield.blocking = 1
					set_shield(player, true, 1)
				end
			end)
		elseif not shield_in_hand then
			if player_shield.blocking ~= 1 then
				mcl_serverplayer.handle_blocking (player, 1)
			end
			player_shield.blocking = 1
		end
	else
		if player_shield.blocking ~= 0 then
			mcl_serverplayer.handle_blocking (player, 0)
		end
		player_shield.blocking = 0
	end
end

local function update_shield_entity(player, blocking, i)
	local shield = mcl_shields.players[player].shields[i]
	if mcl_shields.wielding_shield(player, i) then
		if not shield then
			add_shield_entity(player, i)
		else
			if blocking == i then
				if shield:get_luaentity() and not shield:get_luaentity()._blocking then
					set_shield(player, true, i)
				end
			else
				set_shield(player, false, i)
			end
		end
	elseif shield then
		remove_shield_entity(player, i)
	end
end

local function add_shield_hud(shieldstack, player, blocking)
	local texture = hud
	if mcl_enchanting.is_enchanted(shieldstack:get_name()) then
		texture = texture .. overlay
	end
	local offset = 100
	if blocking == 1 then
		texture = texture .. "^[transform4"
		offset = -100
	else
		player:hud_set_flags({wielditem = false})
	end
	shield_hud[player] = player:hud_add({
		type = "image",
		position = {x = 0.5, y = 0.5},
		scale = {x = -101, y = -101},
		offset = {x = offset, y = 0},
		text = texture,
		z_index = -200,
	})
	playerphysics.add_physics_factor(player, "speed", "shield_speed", 0.5)
	set_interact(player, false)
end

local function update_shield_hud(player, blocking, shieldstack)
	local shieldhud = shield_hud[player]
	if not shieldhud then
		add_shield_hud(shieldstack, player, blocking)
		return
	end

	local wielditem = player:hud_get_flags().wielditem
	if blocking == 1 then
		if not wielditem then
			player:hud_change(shieldhud, "text", hud .. "^[transform4")
			player:hud_change(shieldhud, "offset", {x = -100, y = 0})
			player:hud_set_flags({wielditem = true})
		end
	elseif wielditem then
		player:hud_change(shieldhud, "text", hud)
		player:hud_change(shieldhud, "offset", {x = 100, y = 0})
		player:hud_set_flags({wielditem = false})
	end

	local image = player:hud_get(shieldhud).text
	local enchanted = hud .. overlay
	local enchanted1 = image == enchanted
	local enchanted2 = image == enchanted .. "^[transform4"
	if mcl_enchanting.is_enchanted(shieldstack:get_name()) then
		if not enchanted1 and not enchanted2 then
			if blocking == 1 then
				player:hud_change(shieldhud, "text", hud .. overlay .. "^[transform4")
			else
				player:hud_change(shieldhud, "text", hud .. overlay)
			end
		end
	elseif enchanted1 or enchanted2 then
		if blocking == 1 then
			player:hud_change(shieldhud, "text", hud .. "^[transform4")
		else
			player:hud_change(shieldhud, "text", hud)
		end
	end
end

minetest.register_globalstep(function()
	for player in mcl_util.connected_players() do

		handle_blocking(player)

		local blocking, shieldstack = mcl_shields.is_blocking(player)

		if blocking then
			update_shield_hud(player, blocking, shieldstack)
		elseif shield_hud[player] then --this function takes a long time. only run it when necessary
			remove_shield_hud(player)
		end

		for i = 1, 2 do
			update_shield_entity(player, blocking, i)
		end
	end
end)

minetest.register_on_dieplayer(function(player)
	set_interact(player, true)
	playerphysics.remove_physics_factor(player, "speed", "shield_speed")
	if not minetest.settings:get_bool("mcl_keepInventory") then
		remove_shield_entity(player, 1)
		remove_shield_entity(player, 2)
	end
end)

minetest.register_on_leaveplayer(function(player)
	shield_hud[player] = nil
	mcl_shields.players[player] = nil
end)

minetest.register_craft({
	output = "mcl_shields:shield",
	recipe = {
		{"group:wood", "mcl_core:iron_ingot", "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
		{"", "group:wood", ""},
	}
})

for colorkey, colortab in pairs(mcl_banners.colors) do
	local color = colortab.color_key
	minetest.register_tool("mcl_shields:shield_" .. color, {
		description = D(colortab.color_name.." Shield"), -- "Purple Shield"
		_doc_items_longdesc = S("A shield is a tool used for protecting the player against attacks."),
		inventory_image = "mcl_shield_48.png^(mcl_banners_item_overlay_48.png^[colorize:" .. colortab.rgb ..")",
		wield_image = "mcl_shield_48.png",
		stack_max = 1,
		groups = {
			shield = 1,
			weapon = 1,
			enchantability = -1,
			not_in_creative_inventory = 1,
			offhand_item = 1,
		},
		sound = {breaks = "default_tool_breaks"},
		_repair_material = "group:wood",
		wield_scale = vector.new(2, 2, 2),
		_shield_color_key = colorkey,
		_mcl_wieldview_item = "",
		_mcl_generate_description = mcl_banners.update_description,
		_on_set_item_entity = function (stack)
			local meta = stack:get_meta()
			meta:set_string("mcl_shields:banner_texture", "") -- Force texture rebuild to clear wield texture.
			local pattern = meta:get_string("inventory_overlay")
			if pattern and pattern ~= "" then
				meta:set_string("wield_overlay", pattern) -- Set texture of dropped item.
			end
			return stack, {wield_item = stack:to_string()}
		end,
	})

	local banner = "mcl_banners:banner_item_" .. color
	minetest.register_craft({
		type = "shapeless",
		output = "mcl_shields:shield_" .. color,
		recipe = {"mcl_shields:shield", banner},
	})
	minetest.register_craft({
		type = "shapeless",
		output = "mcl_shields:shield_" .. color .. "_enchanted",
		recipe = {"mcl_shields:shield_enchanted", banner},
	})
end

local function craft_banner_on_shield(itemstack, player, old_craft_grid, _)
	if not string.find(itemstack:get_name(), "^mcl_shields:shield_") then
		return
	end

	local shield_stack, banner_stack
	for i = 1, player:get_inventory():get_size("craft") do
		local stack = old_craft_grid[i]
		local name = stack:get_name()
		if name ~= "" then
			if core.get_item_group(name, "shield") > 0 then
				if shield_stack then return end
				shield_stack = stack
			elseif core.get_item_group(name, "banner") > 0 then
				if banner_stack then return end
				banner_stack = stack
			else
				return
			end
			if shield_stack and banner_stack then break end
		end
	end
	if not shield_stack or not banner_stack then return end

	local b, e = mcl_banners, mcl_enchanting
	local banner_meta = banner_stack:get_meta()
	local layers = b.read_layers(banner_meta)
	if #layers > b.max_craftable_layers then
		return ItemStack("") -- Too many layers to be placed on a shield.
	end

	-- Data copy
	local item_meta, shield_meta = itemstack:get_meta(), shield_stack:get_meta()
	local banner_name, shield_name = banner_meta:get_string("name"), shield_meta:get_string("name")
	if shield_name and shield_name ~= "" then
		item_meta:set_string("name", shield_name)
	elseif banner_name and banner_name ~= "" then
		item_meta:set_string("name", banner_name)
	end
	if e.is_enchanted(shield_stack:get_name()) then
		e.set_enchantments(itemstack, e.get_enchantments(shield_stack))
	end
	set_shield_layers(itemstack, layers)
	itemstack:set_wear(shield_stack:get_wear())
end

minetest.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv)
	return craft_banner_on_shield(itemstack, player, old_craft_grid, craft_inv)
end)

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	return craft_banner_on_shield(itemstack, player, old_craft_grid, craft_inv)
end)

minetest.register_on_joinplayer(function(player)
	mcl_shields.players[player] = {
		shields = {},
		blocking = 0,
	}
	set_interact(player, true)
	playerphysics.remove_physics_factor(player, "speed", "shield_speed")
end)
