# vlf_compass

# Compass API

##vlf_compass.stereotype = "vlf_compass:" .. stereotype_frame
Default compass craftitem.  This is also the image that is shown in the inventory.

##vlf_compass/init.lua:function vlf_compass.get_compass_itemname(pos, dir, itemstack)
Returns the itemname of a compass with needle direction matching the
current compass position.

  pos: position of the compass;
  dir: rotational orientation of the compass;
  itemstack: the compass including its optional lodestone metadata.

##vlf_compass/init.lua:function vlf_compass.get_compass_image(pos, dir)
-- Returns partial itemname of a compass with needle direction matching compass position.
-- Legacy compatibility function for mods using older api.


