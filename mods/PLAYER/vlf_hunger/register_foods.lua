-- Apply food poisoning effect as long there are no real status effect.
-- TODO: Remove this when food poisoning a status effect in vlf_potions.
-- Normal poison damage is set to 0 because it's handled elsewhere.

vlf_hunger.register_food("vlf_mobitems:rotten_flesh",		4, "", 30, 0, 100, 80)
vlf_hunger.register_food("vlf_mobitems:chicken",		2, "", 30, 0, 100, 30)
vlf_hunger.register_food("vlf_fishing:pufferfish_raw",		1, "", 15, 0, 300)
