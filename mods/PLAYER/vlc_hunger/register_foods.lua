-- Apply food poisoning effect as long there are no real status effect.
-- TODO: Remove this when food poisoning a status effect in vlc_potions.
-- Normal poison damage is set to 0 because it's handled elsewhere.

vlc_hunger.register_food("vlc_mobitems:rotten_flesh",		4, "", 30, 0, 100, 80)
vlc_hunger.register_food("vlc_mobitems:chicken",		2, "", 30, 0, 100, 30)
vlc_hunger.register_food("vlc_fishing:pufferfish_raw",		1, "", 15, 0, 300)
