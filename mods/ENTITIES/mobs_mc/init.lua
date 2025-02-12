--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes
mobs_mc = {}

local offsets = {}
for x=-2, 2 do
	for z=-2, 2 do
		table.insert(offsets, {x=x, y=0, z=z})
	end
end

mobs_mc.shears_wear = 276
mobs_mc.water_level = tonumber(minetest.settings:get("water_level")) or 0

-- Load mobs in the right order.
local path = minetest.get_modpath ("mobs_mc")
local files = {
	"armadillo.lua",
	"axolotl.lua",
	"bat.lua",
	"blaze.lua",
	"chicken.lua",
	"cod.lua",
	"cow+mooshroom.lua",
	"creeper.lua",
	"dolphin.lua",
	"ender_dragon.lua",
	"enderman.lua",
	"endermite.lua",
	"ghast.lua",
	"guardian.lua",
	"guardian_elder.lua",
	"hoglin+zoglin.lua",
	"horse.lua",
	"illager_common.lua",
	"iron_golem.lua",
	"llama.lua",
	"ocelot.lua",
	"parrot.lua",
	"pig.lua",
	"pillager.lua",
	"polar_bear.lua",
	"rabbit.lua",
	"salmon.lua",
	"sheep.lua",
	"shulker.lua",
	"silverfish.lua",
	"skeleton+stray.lua",
	"skeleton_wither.lua",
	"slime+magma_cube.lua",
	"snowman.lua",
	"spider.lua",
	"squid+glow_squid.lua",
	"strider.lua",
	"tropical_fish.lua",
	"vex.lua",
	"villager_evoker.lua",
	"villager_illusioner.lua",
	"villager.lua",
	"villager_vindicator.lua",
	"wandering_trader.lua",
	"witch.lua",
	"wither.lua",
	"wolf.lua",
	"zombie.lua",
	"villager_zombie.lua",
	"zombiepig.lua",
	"piglin.lua",
}
for _, file in pairs (files) do
	dofile (path .. "/" .. file)
end
