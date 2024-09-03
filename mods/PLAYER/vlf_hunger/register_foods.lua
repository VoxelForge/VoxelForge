-- Apply food poisoning entity_effect as long there are no real status entity_effect.
-- TODO: Sanitize this now that Food Poisoning is now an entity_effect in vlf_entity_effects
-- Normal poison damage is set to 0 because it's handled elsewhere.

vlf_hunger.register_food("vlf_mobitems:rotten_flesh",		4, "", 30, 0, 1, 80)
vlf_hunger.register_food("vlf_mobitems:chicken",		2, "", 30, 0, 1, 30)
vlf_hunger.register_food("vlf_fishing:pufferfish_raw",		1, "", 15, 0, 3)
