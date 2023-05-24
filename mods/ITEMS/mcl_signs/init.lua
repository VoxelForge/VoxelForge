---
--- Generated by EmmyLua.
--- Created by Michieal (FaerRaven).
--- DateTime: 10/14/22 4:05 PM
---

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- Signs API
dofile(modpath .. "/signs_api.lua")

-- LOCALIZATION
local S = minetest.get_translator(modname)

-- HANDLE THE FORMSPEC CALLBACK
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname:find("mcl_signs:set_text_") == 1 then
        local x, y, z = formname:match("mcl_signs:set_text_(.-)_(.-)_(.*)")
        local pos = { x = tonumber(x), y = tonumber(y), z = tonumber(z) }
        if not pos or not pos.x or not pos.y or not pos.z then
            return
        end
        mcl_signs:update_sign(pos, fields, player)
    end
end)

-- This defines the text entity for the lettering of the sign.
-- FIXME: Prevent entity destruction by /clearobjects
minetest.register_entity("mcl_signs:text", {
    pointable = false,
    visual = "upright_sprite",
    textures = {},
    physical = false,
    collide_with_objects = false,

    _signnodename = nil, -- node name of sign node to which the text belongs

    on_activate = function(self, staticdata)

        local meta = minetest.get_meta(self.object:get_pos())
        local text = meta:get_string("text")
        local text_color = meta:get_string("mcl_signs:text_color")
        local glowing_sign = meta:get_string("mcl_signs:glowing_sign")
        if staticdata and staticdata ~= "" then
            local des = minetest.deserialize(staticdata)
            if des then
                self._signnodename = des._signnodename
                if des._text_color ~= nil and des._text_color ~= "" then
                    self.text_color = des._text_color
                end
                if des._glowing_sign ~= nil and des._glowing_sign ~= "" then
                    self.glowing_sign = des._glowing_sign
                end
            end
        end

        if text_color == "" or text_color == nil then
            text_color = "#000000" -- default to black text.
            meta:set_string("mcl_signs:text_color", text_color)
        end

        if glowing_sign == "" or glowing_sign == nil then
            glowing_sign = "false" -- default to not glowing.
            meta:set_string("mcl_signs:glowing_sign", glowing_sign)
        end

        self.object:set_properties({
            textures = { mcl_signs:create_lettering(text, self._signnodename, text_color) },
        })
        if glowing_sign == "true" then
            self.object:set_properties({
                glow = 6, --sign_glow,
            })
        end

        self.object:set_armor_groups({ immortal = 1 })

    end,
    get_staticdata = function(self)
        local out = {
            _signnodename = self._signnodename,
        }
        return minetest.serialize(out)
    end,
})

-- Build the signs x,y,z & rotations so that they work. (IE, do not remove!)
mcl_signs.build_signs_info()

-- ---------------------------- --
--   Register Signs for use.    --
-- ---------------------------- --

-- Standard (original) Sign
mcl_signs.register_sign("mcl_core", "#ffffff", "", S("Sign"))
mcl_signs.register_sign_craft("mcl_core", "mcl_core:wood", "")

-- birchwood Sign "#d5cb8d" / "#ffdba7"
mcl_signs.register_sign_custom("mcl_core", "_birchwood",
        "mcl_signs_sign_greyscale.png","#ffdba7", "default_sign_greyscale.png",
        "default_sign_greyscale.png", S("Birch Sign")
)
mcl_signs.register_sign_craft("mcl_core", "mcl_core:birchwood", "_birchwood")

-- sprucewood Sign
mcl_signs.register_sign_custom("mcl_core", "_sprucewood",
        "mcl_signs_sign_dark.png","#ffffff", "default_sign_dark.png",
        "default_sign_dark.png", S("Spruce Sign")
)
mcl_signs.register_sign_craft("mcl_core", "mcl_core:sprucewood", "_sprucewood")

-- darkwood Sign "#291f1a" / "#856443"
mcl_signs.register_sign_custom("mcl_core", "_darkwood",
        "mcl_signs_sign_greyscale.png","#856443", "default_sign_greyscale.png",
        "default_sign_greyscale.png", S("Dark Oak Sign")
)
mcl_signs.register_sign_craft("mcl_core", "mcl_core:darkwood", "_darkwood")

-- junglewood Sign
mcl_signs.register_sign("mcl_core", "#866249", "_junglewood", S("Jungle Sign"))
mcl_signs.register_sign_craft("mcl_core", "mcl_core:junglewood", "_junglewood")

-- acaciawood Sign "b8693d"
mcl_signs.register_sign("mcl_core", "#ea7479", "_acaciawood", S("Acacia Sign"))
mcl_signs.register_sign_craft("mcl_core", "mcl_core:acaciawood", "_acaciawood")

if minetest.get_modpath("mcl_mangrove") then
	-- mangrove_wood Sign  "#c7545c"
	mcl_signs.register_sign("mcl_mangrove", "#b8693d", "_mangrove_wood", S("Mangrove Sign"))
	mcl_signs.register_sign_craft("mcl_mangrove", "mcl_mangrove:mangrove_wood", "_mangrove_wood")
end

-- add in the nether wood signs
if minetest.get_modpath("mcl_crimson") then

    -- warped_hyphae_wood Sign
    mcl_signs.register_sign_custom("mcl_crimson","_warped_hyphae_wood", "mcl_signs_sign_greyscale.png",
            "#9f7dcf", "default_sign_greyscale.png", "default_sign_greyscale.png",
            S("Warped Hyphae Sign"))
    mcl_signs.register_sign_craft("mcl_crimson", "mcl_crimson:warped_hyphae_wood", "_warped_hyphae_wood")

    -- crimson_hyphae_wood Sign
    mcl_signs.register_sign_custom("mcl_crimson", "_crimson_hyphae_wood","mcl_signs_sign_greyscale.png",
            "#c35f51","default_sign_greyscale.png", "default_sign_greyscale.png",
            S("Crimson Hyphae Sign"))
    mcl_signs.register_sign_craft("mcl_crimson", "mcl_crimson:crimson_hyphae_wood", "_crimson_hyphae_wood")

end

-- Register the LBMs for the created signs.
mcl_signs.make_lbm()

-- really ancient compatibility.
minetest.register_alias("signs:sign_wall", "mcl_signs:wall_sign")
minetest.register_alias("signs:sign_yard", "mcl_signs:standing_sign")
minetest.register_alias("mcl_signs:wall_sign_dark", "mcl_signs:wall_sign_sprucewood")
minetest.register_alias("mcl_signs:standing_sign_dark", "mcl_signs:standing_sign_sprucewood")
