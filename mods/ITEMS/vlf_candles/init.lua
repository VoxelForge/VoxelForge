local S = minetest.get_translator("vlf_candles")
local PARTICLE_DISTANCE = 25
for i = 1, 4 do
minetest.register_alias("vlf_candles:candle_"..i.."", "vlf_candles:unl_candle_"..i.."")
minetest.register_alias("vlf_candles:candle_lit_"..i.."", "vlf_candles:lit_candle_"..i.."")
end

local candleboxes = {
    {-1/16, -8/16, -1/16, 1/16, -2/16, 1/16},
    {-2/16, -8/16, -3/16, 2/16, -2/16, 2/16},
    {-3/16, -8/16, -3/16, 2/16, -2/16, 2/16},
    {-3/16, -8/16, -3/16, 3/16, -2/16, 3/16}
}

local cakebox = {
    {-7/16, -8/16, -7/16, 7/16, 0, 7/16},
    {-1/16, 0, -1/16, 1/16, 6/16, 1/16}
}

local colordefs = {
--  {name           candledesc              cakedesc                            dye         },
    {nil,           S("Candle"),            S("Cake With Candle"),              nil         },
    {"black",       S("Black Candle"),      S("Cake With Black Candle"),        "black"     },
    {"blue",        S("Blue Candle"),       S("Cake With Blue Candle"),         "blue"      },
    {"brown",       S("Brown Candle"),      S("Cake With Brown Candle"),        "brown"     },
    {"cyan",        S("Cyan Candle"),       S("Cake With Cyan Candle"),         "cyan"      },
    {"green",       S("Green Candle"),      S("Cake With Green Candle"),        "dark_green"},
    {"grey",        S("Grey Candle"),       S("Cake With Grey Candle"),         "dark_grey" },
    {"light_blue",  S("Light Blue Candle"), S("Cake With Light Blue Candle"),   "lightblue" },
    {"light_grey",  S("Light Grey Candle"), S("Cake With Light Grey Candle"),   "grey"      },
    {"lime",        S("Lime Candle"),       S("Cake With Lime Candle"),         "green"     },
    {"magenta",     S("Magenta Candle"),    S("Cake With Magenta Candle"),      "magenta"   },
    {"orange",      S("Orange Candle"),     S("Cake With Orange Candle"),       "orange"    },
    {"pink",        S("Pink Candle"),       S("Cake With Pink Candle"),         "pink"      },
    {"purple",      S("Purple Candle"),     S("Cake With Purple Candle"),       "violet"    },
    {"red",         S("Red Candle"),        S("Cake With Red Candle"),          "red"       },
    {"white",       S("White Candle"),      S("Cake With White Candle"),        "white"     },
    {"yellow",      S("Yellow Candle"),     S("Cake With Yellow Candle"),       "yellow"    }
}

--local function candles_on_construct(pos) end

--local function candles_on_destruct(pos) end

local function candles_on_place(itemstack, placer, pointed_thing)
    if not placer then
        return
    end

    local upos = pointed_thing.under

    if vlf_util.check_position_protection(upos, placer) then
        return
    end

    local unode = minetest.get_node(upos)
    local ncolor = unode.name:sub(26)
    local icolor = itemstack:get_name():sub(25)
    local icolor_2 = itemstack:get_name():sub(26)
    local samecolor = ncolor == icolor_2
    local creative = minetest.is_creative_enabled(placer:get_player_name())

    if unode.name:find("vlf_candles:unl") and samecolor then
        if unode.name:find("1") then
            minetest.set_node(upos, {name = unode.name:gsub("1", "2")})
            if not creative then itemstack:take_item() end
        elseif unode.name:find("2") then
            minetest.set_node(upos, {name = unode.name:gsub("2", "3")})
            if not creative then itemstack:take_item() end
        elseif unode.name:find("3") then
            minetest.set_node(upos, {name = unode.name:gsub("3", "4")})
            if not creative then itemstack:take_item() end
        end
    elseif unode.name == "vlf_cake:cake" then
        if icolor then
            minetest.set_node(upos, {name = "vlf_candles:cake_unl_candle"..icolor})
        else
            minetest.set_node(upos, {name = "vlf_candles:cake_unl_candle"})
        end
    else
        return minetest.item_place_node(itemstack, placer, pointed_thing)
    end

    return itemstack
end

local function candles_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
    if not clicker then
        return
    end

    if vlf_util.check_position_protection(pos, clicker) then
        return
    end

    if node.name:find("unl") then
        if itemstack:get_name():find("flint_and_steel") then
            minetest.set_node(pos, {name = node.name:gsub("unl", "lit")})
            if not minetest.is_creative_enabled(clicker:get_player_name()) then
                itemstack:add_wear()
            end
        else
            return minetest.item_place_node(itemstack, clicker, pointed_thing)
        end
    elseif node.name:find("lit") then
        if itemstack:is_empty() then
            minetest.set_node(pos, {name = node.name:gsub("lit", "unl")})
        else
            return minetest.item_place_node(itemstack, clicker, pointed_thing)
        end
    end

    return itemstack
end

local function register_candles(index, colordefs, box)
    local desc = colordefs[2]
    local itemimg, litname, unlitname, texture

    if colordefs[1] then
        itemimg = "vlf_candles_item_"..colordefs[1]..".png"
        litname = "vlf_candles:lit_candle_"..tostring(index).."_"..colordefs[1]
        unlitname = "vlf_candles:unl_candle_"..tostring(index).."_"..colordefs[1]
        texture = "vlf_candles_candle_"..colordefs[1]..".png"
    else
        itemimg = "vlf_candles_item.png"
        litname = "vlf_candles:lit_candle_"..tostring(index)
        unlitname = "vlf_candles:unl_candle_"..tostring(index)
        texture = "vlf_candles_candle.png"
    end

    if index ~= 1 then
        desc = colordefs[2].." "..tostring(index)
        itemimg = nil
    end

    local litdefs = {
        collision_box = {type = "fixed", fixed = box},
        description = desc.." "..S("Lit"),
        drawtype = "mesh",
        drop = unlitname:gsub(tostring(index), "1").." "..tostring(index),
        groups = {
            axey = 1, dig_by_piston = 1, handy = 1, lit_candles = 1, not_in_creative_inventory = 1,
            not_solid = 1, pickaxey = 1, shearsy = 1, shovely = 1, swordy = 1
        },
        inventory_image = itemimg,
        is_ground_content = false,
        light_source = 3 * index,
        mesh = "vlf_candles_candle_"..tostring(index)..".obj",
        --on_construct = candles_on_construct,
        --on_destruct = candles_on_destruct,
        on_rightclick = candles_on_rightclick,
        paramtype = "light",
        selection_box = {type = "fixed", fixed = box},
        sounds = vlf_sounds.node_sound_defaults(),
        sunlight_propagates = true,
        tiles = {texture},
        use_texture_alpha = "clip",
        wield_image = itemimg,
        _vlf_blast_resistance = 0.1,
        _vlf_hardness = 0.1,
    }

    local unlitdefs = {
        collision_box = {type = "fixed", fixed = box},
        description = desc,
        drawtype = "mesh",
        drop = unlitname:gsub(tostring(index), "1").." "..tostring(index),
        groups = {
            axey = 1, dig_by_piston = 1, handy = 1, not_solid = 1, pickaxey = 1, shearsy = 1,
            shovely = 1, swordy = 1
        },
        inventory_image = itemimg,
        is_ground_content = false,
        mesh = "vlf_candles_candle_"..tostring(index)..".obj",
        on_place = candles_on_place,
        on_rightclick = candles_on_rightclick,
        paramtype = "light",
        selection_box = {type = "fixed", fixed = box},
        sounds = vlf_sounds.node_sound_defaults(),
        sunlight_propagates = true,
        tiles = {texture},
        use_texture_alpha = "clip",
        wield_image = itemimg,
        _vlf_blast_resistance = 0.1,
        _vlf_hardness = 0.1,
    }

    minetest.register_node(litname, litdefs)
    minetest.register_node(unlitname, unlitdefs)

    if colordefs[4] then
        minetest.register_craft({
            output = "vlf_candles:unl_candle_1_"..colordefs[1],
            recipe = {"vlf_candles:unl_candle_1", "vlf_dye:"..colordefs[4]},
            type = "shapeless"
        })
    end

end

local function cakes_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
    if not clicker then
        return
    end

    if vlf_util.check_position_protection(pos, clicker) then
        return
    end

    local nname = node.name

    if nname:find("unl") then
        if itemstack:get_name():find("flint_and_steel") then
            minetest.set_node(pos, {name = nname:gsub("unl", "lit")})
            if minetest.is_creative_enabled(clicker:get_player_name()) then
                itemstack:add_wear()
            end
        else
		local ccakedrop =  minetest.registered_nodes[nname].drop.items.items[2]
		local cakedefs = minetest.registered_nodes["vlf_cake:cake"]
		minetest.add_item(pos, {name = ccakedrop})
		return cakedefs.on_rightclick(pos, node, clicker, itemstack, pointed_thing)
        end
    else
        local ccakedrop =  minetest.registered_nodes[nname].drop.items.items[2]
        local cakedefs = minetest.registered_nodes["vlf_cake:cake"]

        minetest.add_item(pos, {name = ccakedrop})
        return cakedefs.on_rightclick(pos, node, clicker, itemstack, pointed_thing)
    end

    return itemstack
end

local function register_cakes(colordefs)
    local desc = colordefs[3]
    local litname, unlitname, candlename, candletexture

    if colordefs[1] then
        candlename = "vlf_candles:unl_candle_1_"..colordefs[1]
        candletexture = "vlf_candles_candle_"..colordefs[1]..".png"
        litname = "vlf_candles:cake_lit_candle_"..colordefs[1]
        unlitname = "vlf_candles:cake_unl_candle_"..colordefs[1]
    else
        candlename = "vlf_candles:unl_candle_1"
        candletexture = "vlf_candles_candle.png"
        litname = "vlf_candles:cake_lit_candle"
        unlitname = "vlf_candles:cake_unl_candle"
    end

    local litdefs = {
        collision_box = {type = "fixed", fixed = cakebox},
        description = desc.." "..S("Lit"),
        drawtype = "mesh",
        drop = {
            items = {
                items = {"vlf_cake:cake", candlename},
                rarity = 1
            }
        },
        groups = {dig_by_piston = 1, handy = 1, not_in_creative_inventory = 1},
        is_ground_content = false,
        light_source = 3,
        mesh = "vlf_candles_cake.obj",
        paramtype = "light",
        -- TODO: Add callbacks
        on_rightclick = cakes_on_rightclick,
        selection_box = {type = "fixed", fixed = cakebox},
        -- TODO: Add sounds
        --sounds = ,
        sunlight_propagates = true,
        tiles = {candletexture, "vlf_candles_cake.png"},
        _vlf_blast_resistance = 0.5,
        _vlf_hardness = 0.5
    }

    local unlitdefs = {
        collision_box = {type = "fixed", fixed = cakebox},
        description = desc,
        drawtype = "mesh",
        drop = {
            items = {
                items = {"vlf_cake:cake", candlename}
            }
        },
        groups = {dig_by_piston = 1, handy = 1, not_in_creative_inventory = 1},
        is_ground_content = false,
        mesh = "vlf_candles_cake.obj",
        paramtype = "light",
        -- TODO: Add callbacks
        on_rightclick = cakes_on_rightclick,
        selection_box = {type = "fixed", fixed = cakebox},
        -- TODO: Add sounds
        --sounds = ,
        sunlight_propagates = true,
        tiles = {candletexture, "vlf_candles_cake.png"},
        _vlf_blast_resistance = 0.5,
        _vlf_hardness = 0.5
    }

    minetest.register_node(litname, litdefs)
    minetest.register_node(unlitname, unlitdefs)
end

for i = 1, #candleboxes do
    for j = 1, #colordefs do
        register_candles(i, colordefs[j], candleboxes[i])
    end
end

for i = 1, #colordefs do
    register_cakes(colordefs[i])
end

minetest.register_craft({
    output = "vlf_candles:unl_candle_1",
    recipe = {
        {"vlf_mobitems:string"},
        {"vlf_honey:honeycomb"}
    }
})

for name, defs in pairs(minetest.registered_items) do
    if name:find("vlf_candles") and name:find("unl") and not name:find("1") then
        defs.groups.not_in_creative_inventory = 1
    end
end

local candle_particlespawner = {
	texture = "voxelforge_flame.png",
	texpool = {},
	--amount = 8,
	time = 2,
	minvel = vector.zero(),
	maxvel = vector.zero(),
	minacc = vector.new(0.0, 0.0, 0.0),
	maxacc = vector.new(0.0, 0.1, 0.0),
	minexptime = 1.0,
	maxexptime = 1.4,
	minsize = 1.75,
	maxsize= 2.5,
	glow = 1,
	collisiondetection = true,
	collision_removal = true,
}

local smoke_particlespawner = {
	texture = "",
	texpool = {},
	--amount = 8,
	time = 2,
	minvel = vector.zero(),
	maxvel = vector.zero(),
	minacc = vector.new(0.0, 0.5, 0.0),
	maxacc = vector.new(0.0, 0.9, 0.0),
	minexptime = 2.0,
	maxexptime = 2.25,
	minsize = 1.75,
	maxsize= 2.5,
	glow = 1,
	collisiondetection = true,
	collision_removal = true,
}

minetest.register_abm({
	label = "Candle Particles",
	nodenames = {
	"vlf_candles:lit_candle_1", "vlf_candles:lit_candle_2",
        "vlf_candles:lit_candle_1_black", "vlf_candles:lit_candle_1_blue",
        "vlf_candles:lit_candle_1_brown", "vlf_candles:lit_candle_1_cyan",
        "vlf_candles:lit_candle_1_green", "vlf_candles:lit_candle_1_grey",
        "vlf_candles:lit_candle_1_light_blue", "vlf_candles:lit_candle_1_light_grey",
        "vlf_candles:lit_candle_1_lime", "vlf_candles:lit_candle_1_magenta",
        "vlf_candles:lit_candle_1_orange", "vlf_candles:lit_candle_1_pink",
        "vlf_candles:lit_candle_1_purple", "vlf_candles:lit_candle_1_red",
        "vlf_candles:lit_candle_1_white", "vlf_candles:lit_candle_1_yellow",
        "vlf_candles:lit_candle_2_black", "vlf_candles:lit_candle_2_blue",
        "vlf_candles:lit_candle_2_brown", "vlf_candles:lit_candle_2_cyan",
        "vlf_candles:lit_candle_2_green", "vlf_candles:lit_candle_2_grey",
        "vlf_candles:lit_candle_2_light_blue", "vlf_candles:lit_candle_2_light_grey",
        "vlf_candles:lit_candle_2_lime", "vlf_candles:lit_candle_2_magenta",
        "vlf_candles:lit_candle_2_orange", "vlf_candles:lit_candle_2_pink",
        "vlf_candles:lit_candle_2_purple", "vlf_candles:lit_candle_2_red",
        "vlf_candles:lit_candle_2_white", "vlf_candles:lit_candle_2_yellow",
	},
	interval = 2,
	chance = 1,
	action = function(pos, node)
		for _,pl in pairs(minetest.get_connected_players()) do
			if vector.distance(pos,pl:get_pos()) < PARTICLE_DISTANCE then
				minetest.add_particlespawner(table.merge(candle_particlespawner, {
					amount = 4,
					minpos = vector.offset(pos, -0.05, -0.0, -0.05),
					maxpos = vector.offset(pos, 0.05, 0.1, 0.05),
					playername = pl:get_player_name(),
				}))
				local rand = math.random(1,3)
				local name
				if rand == 1 then
					name = "vlf_particles_generic.png^[colorize:#2c2c2c:255"
				elseif rand == 2 then
					name = "vlf_particles_generic.png^[colorize:#424242:255"
				elseif rand == 3 then
					name = "vlf_particles_generic.png^[colorize:#0f0f0f:255"
				end
				table.insert(smoke_particlespawner.texpool, {
					name = name,
					animation={type="vertical_frames", aspect_w=8, aspect_h=8, length=0.78},
				})
				minetest.add_particlespawner(table.merge(smoke_particlespawner, {
					amount = 3,
					minpos = vector.offset(pos, -0.15, -0.0, -0.15),
					maxpos = vector.offset(pos, 0.15, 0.1, 0.15),
					playername = pl:get_player_name(),
				}))
			end
		end
	end
})

minetest.register_abm({
	label = "Candle Particles 2",
	nodenames = {
	"vlf_candles:lit_candle_3", "vlf_candles:lit_candle_4",
        "vlf_candles:lit_candle_3_black", "vlf_candles:lit_candle_3_blue",
        "vlf_candles:lit_candle_3_brown", "vlf_candles:lit_candle_3_cyan",
        "vlf_candles:lit_candle_3_green", "vlf_candles:lit_candle_3_grey",
        "vlf_candles:lit_candle_3_light_blue", "vlf_candles:lit_candle_3_light_grey",
        "vlf_candles:lit_candle_3_lime", "vlf_candles:lit_candle_3_magenta",
        "vlf_candles:lit_candle_3_orange", "vlf_candles:lit_candle_3_pink",
        "vlf_candles:lit_candle_3_purple", "vlf_candles:lit_candle_3_red",
        "vlf_candles:lit_candle_3_white", "vlf_candles:lit_candle_3_yellow",
        "vlf_candles:lit_candle_4_black", "vlf_candles:lit_candle_4_blue",
        "vlf_candles:lit_candle_4_brown", "vlf_candles:lit_candle_4_cyan",
        "vlf_candles:lit_candle_4_green", "vlf_candles:lit_candle_4_grey",
        "vlf_candles:lit_candle_4_light_blue", "vlf_candles:lit_candle_4_light_grey",
        "vlf_candles:lit_candle_4_lime", "vlf_candles:lit_candle_4_magenta",
        "vlf_candles:lit_candle_4_orange", "vlf_candles:lit_candle_4_pink",
        "vlf_candles:lit_candle_4_purple", "vlf_candles:lit_candle_4_red",
        "vlf_candles:lit_candle_4_white", "vlf_candles:lit_candle_4_yellow",
	},
	interval = 2,
	chance = 1,
	action = function(pos, node)
		for _,pl in pairs(minetest.get_connected_players()) do
			if vector.distance(pos,pl:get_pos()) < PARTICLE_DISTANCE then
				minetest.add_particlespawner(table.merge(candle_particlespawner, {
					amount = 8,
					minpos = vector.offset(pos, -0.15, -0.0, -0.15),
					maxpos = vector.offset(pos, 0.15, 0.1, 0.15),
					playername = pl:get_player_name(),
				}))
				local rand = math.random(1,3)
				local name
				if rand == 1 then
					name = "vlf_particles_generic.png^[colorize:#2c2c2c:255"
				elseif rand == 2 then
					name = "vlf_particles_generic.png^[colorize:#424242:255"
				elseif rand == 3 then
					name = "vlf_particles_generic.png^[colorize:#0f0f0f:255"
				end
				table.insert(smoke_particlespawner.texpool, {
					name = name,
					animation={type="vertical_frames", aspect_w=8, aspect_h=8, length=0.78},
				})
				minetest.add_particlespawner(table.merge(smoke_particlespawner, {
					amount = 6,
					minpos = vector.offset(pos, -0.15, -0.0, -0.15),
					maxpos = vector.offset(pos, 0.15, 0.1, 0.15),
					playername = pl:get_player_name(),
				}))
			end
		end
	end
})

minetest.register_abm({
	label = "Cake Particles 3",
	nodenames = {
	"vlf_candles:cake_lit_candle", "vlf_candles:cake_lit_candle_black",
	"vlf_candles:cake_lit_candle_blue", "vlf_candles:cake_lit_candle_brown",
	"vlf_candles:cake_lit_candle_cyan", "vlf_candles:cake_lit_candle_green",
	"vlf_candles:cake_lit_candle_grey", "vlf_candles:cake_lit_candle_light_blue",
	"vlf_candles:cake_lit_candle_light_grey", "vlf_candles:cake_lit_candle_lime",
	"vlf_candles:cake_lit_candle_magenta", "vlf_candles:cake_lit_candle_orange",
	"vlf_candles:cake_lit_candle_pink", "vlf_candles:cake_lit_candle_purple",
	"vlf_candles:cake_lit_candle_red", "vlf_candles:cake_lit_candle_white",
	"vlf_candles:cake_lit_candle_yellow,
	},
	interval = 2,
	chance = 1,
	action = function(pos, node)
		for _,pl in pairs(minetest.get_connected_players()) do
			if vector.distance(pos,pl:get_pos()) < PARTICLE_DISTANCE then
				minetest.add_particlespawner(table.merge(candle_particlespawner, {
					amount = 3,
					minpos = vector.offset(pos, -0.02, 0.5, -0.02),
					maxpos = vector.offset(pos, 0.02, 0.6, 0.02),
					playername = pl:get_player_name(),
				}))
				local rand = math.random(1,3)
				local name
				if rand == 1 then
					name = "vlf_particles_generic.png^[colorize:#2c2c2c:255"
				elseif rand == 2 then
					name = "vlf_particles_generic.png^[colorize:#424242:255"
				elseif rand == 3 then
					name = "vlf_particles_generic.png^[colorize:#0f0f0f:255"
				end
				table.insert(smoke_particlespawner.texpool, {
					name = name,
					animation={type="vertical_frames", aspect_w=8, aspect_h=8, length=0.78},
				})
				minetest.add_particlespawner(table.merge(smoke_particlespawner, {
					amount = 1,
					minpos = vector.offset(pos, -0.02, 0.5, -0.02),
					maxpos = vector.offset(pos, 0.02, 0.6, 0.02),
					playername = pl:get_player_name(),
				}))
			end
		end
	end
})
