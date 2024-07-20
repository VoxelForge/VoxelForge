## Potions and Effects API

<!-- TOC -->
* [Potions and Effects API](#entity_effects-and-effects-api)
    * [Namespace](#namespace)
    * [Effects](#effects)
        * [Functions](#functions)
        * [Deprecated Functions](#deprecated-functions)
        * [Tables](#tables)
        * [Internally registered effects](#internally-registered-effects)
        * [Constants](#constants)
        * [Effect Definition](#effect-definition)
    * [HP Hudbar Modifiers](#hp-hudbar-modifiers)
        * [Functions](#functions)
        * [HP Hudbar Modifier Definition](#hp-hudbar-modifier-definition)
    * [Potions](#entity_effects)
        * [Functions](#functions)
        * [Tables](#tables)
        * [Internally registered entity_effects](#internally-registered-entity_effects)
        * [Constants](#constants)
        * [Potion Definition](#entity_effect-definition)
    * [Brewing](#brewing)
        * [Functions](#functions)
    * [Miscellaneous Functions](#miscellaneous-functions)
<!-- TOC -->

### Namespace
All of the API is defined in the `vlf_entity_effects` namespace.

### Effects
This section describes parts of the API related to defining and managing effects on players and entities. The mod defines a bunch of effects internally using the same API as described below.

#### Functions
`vlf_entity_effects.register_effect(def)` – takes an effect definition (`def`) and registers an effect if the definition is valid, and adds the known parts of the definition as well as the outcomes of processing of some parts of the definition to the `vlf_entity_effects.registered_effects` table. This should only be used at load time.


`vlf_entity_effects.apply_haste_fatigue(toolcaps, h_fac, f_fac)` – takes a table of tool capabilities (`toolcaps`) and modifies it using the provided haste factor (`h_fac`) and fatigue factor (`f_fac`). The factors default to no-op values.


`vlf_entity_effects.hf_update_internal(hand, object)` – returns the `hand` of the `object` updated according to their combined haste and fatigue. **This doesn't change anything by itself!** Manual update of the hand with the hand returned by this function has to be done. This should only be called in situations that are *directly* impacted by haste and/or fatigue, and therefore require an update of the hand.


`vlf_entity_effects.update_haste_and_fatigue(player)` – updates haste and fatigue on a `player` (described by an ObjectRef). This should be called whenever an update of the haste-type and fatigue-type effects is desired.


`vlf_entity_effects._reset_haste_fatigue_item_meta(player)` – resets the item meta changes caused by haste-type and fatigue-type effects throughout the inventory of the `player` described by an ObjectRef.


`vlf_entity_effects._clear_cached_effect_data(object)` – clears cashed effect data for the `object`. This shouldn't be used for resetting effects.


`vlf_entity_effects._reset_effects(object, set_hud)` – actually resets the effects for the `object`. It also updates HUD if `set_hud` is `true` or undefined (`nil`).


`vlf_entity_effects._save_player_effects(player)` – saves all effects of the `player` described by an ObjectRef to metadata.


`vlf_entity_effects._load_player_effects(player)` – loads all effects from the metadata of the `player` described by an ObjectRef.


`vlf_entity_effects._load_entity_effects(entity)` – loads all effects from the `entity` (a LuaEntity).


`vlf_entity_effects.has_effect(object, effect_name)` – returns `true` if `object` (described by an ObjectRef) has the effect of the ID `effect_name`, `false` otherwise.


`vlf_entity_effects.get_effect(object, effect_name)` - returns a table containing values of the effect of the ID `effect_name` on the `object` if the object has the named effect, `false` otherwise.


`vlf_entity_effects.get_effect_level(object, effect_name)` – returns the level of the effect of the ID `effect_name` on the `object`. If the effect has no levels, returns `1`. If the object doesn't have the effect, returns `0`. If the effect is not registered, returns `nil`.


`vlf_entity_effects.get_total_haste(object)` – returns the total haste of the `object` (from all haste-type effects).


`vlf_entity_effects.get_total_fatigue(object)` – returns the total fatigue of the `object` (from all fatigue-type effects).


`vlf_entity_effects.clear_effect(object, effect)` – attempts to remove the effect of the ID `effect` from the `object`. If the effect is not registered, logs a warning and returns `false`. Otherwise, returns `nil`.


`vlf_entity_effects.make_invisible(obj_ref, hide)` – makes the object going by the `obj_ref` invisible if `hide` is true, visible otherwise.


`vlf_entity_effects.register_generic_resistance_predicate(predicate)` – registers an arbitrary effect resistance predicate. This can be used e.g. to make some entity resistant to all (or some) effects under specific conditions.

* `predicate` – `function(object, effect_name)` - return `true` if `object` resists effect of the ID `effect_name`


`vlf_entity_effects.give_effect(name, object, factor, duration, no_particles)` – attempts to give effect of the ID `name` to the `object` with the provided `factor` and `duration`. If `no_particles` is `true`, no particles will be emitted from the object when under the effect. If the effect is not registered, target is invalid (or resistant), or the same effect with more potency is already applied to the target, this function does nothing and returns `false`. On success, this returns `true`.


`vlf_entity_effects.give_effect_by_level(name, object, level, duration, no_particles)` – attempts to give effect of the ID `name` to the `object` with the provided `level` and `duration`. If `no_particles` is `true`, no particles will be emitted from the object when under the effect. This converts `level` to factor and calls `vlf_entity_effects.give_effect()` internally, returning the return value of that function. `level` equal to `0` is no-op.


`vlf_entity_effects.healing_func(object, hp)` – attempts to heal the `object` by `hp`. Negative `hp` harms magically instead.


#### Deprecated functions
**Don't use the following functions, use the above API instead!** The following are only provided for backwards compatibility and will be removed later. They all call `vlf_entity_effects.give_effect()` internally.

* `vlf_entity_effects.strength_func(object, factor, duration)`
* `vlf_entity_effects.leaping_func(object, factor, duration)`
* `vlf_entity_effects.weakness_func(object, factor, duration)`
* `vlf_entity_effects.swiftness_func(object, factor, duration)`
* `vlf_entity_effects.slowness_func(object, factor, duration)`
* `vlf_entity_effects.withering_func(object, factor, duration)`
* `vlf_entity_effects.poison_func(object, factor, duration)`
* `vlf_entity_effects.regeneration_func(object, factor, duration)`
* `vlf_entity_effects.invisiblility_func(object, null, duration)`
* `vlf_entity_effects.water_breathing_func(object, null, duration)`
* `vlf_entity_effects.fire_resistance_func(object, null, duration)`
* `vlf_entity_effects.night_vision_func(object, null, duration)`
* `vlf_entity_effects.bad_omen_func(object, factor, duration)`



#### Tables
`vlf_entity_effects.registered_effects` – contains all effects that have been registered. You can read from it various data about the effects. You can overwrite the data and alter the effects' definitions too, but this is discouraged, i.e. only do this if you really know what you are doing. You shouldn't add effects directly to this table, as this would skip important setup; instead use the `vlf_entity_effects.register_effect()` function, which is described above.

#### Internally registered effects
You can't register effects going by these names, because they are already used:
* `invisibility`
* `poison`
* `regeneration`
* `strength`
* `weakness`
* `weakness`
* `dolphin_grace`
* `leaping`
* `slow_falling`
* `swiftness`
* `slowness`
* `levitation`
* `night_vision`
* `darkness`
* `glowing`
* `health_boost`
* `absorption`
* `fire_resistance`
* `resistance`
* `luck`
* `bad_luck`
* `bad_omen`
* `hero_of_village`
* `withering`
* `frost`
* `blindness`
* `nausea`
* `food_poisoning`
* `saturation`
* `haste`
* `fatigue`
* `conduit_power`

#### Constants
`vlf_entity_effects.LONGEST_MINING_TIME` – longest mining time of one block that can be achieved by slowing down the mining by fatigue-type effects.

`vlf_entity_effects.LONGEST_PUNCH_INTERVAL` – longest punch interval that can be achieved by slowing down the punching by fatigue-type effects.

#### Effect Definition
```lua
def = {
-- required parameters in def:
    name = string -- effect name in code (unique ID) - can't be one of the reserved words ("list", "heal", "remove", "clear")
    description = S(string) -- actual effect name in game
-- optional parameters in def:
    get_tt = function(factor) -- returns tooltip description text for use with entity_effects
    icon = string -- file name of the effect icon in HUD - defaults to one based on name
    res_condition = function(object) -- returning true if target is to be resistant to the effect
    on_start = function(object, factor) -- called when dealing the effect
    on_load = function(object, factor) -- called on_joinplayer and on_activate
    on_step = function(dtime, object, factor, duration) -- running every step for all objects with this effect
    on_hit_timer = function(object, factor, duration) -- if defined runs a hit_timer depending on timer_uses_factor value
    on_end = function(object) -- called when the effect wears off
    after_end = function(object) -- called when the effect wears off, after purging the data of the effect
    on_save_effect = function(object -- called when the effect is to be serialized for saving (supposed to do cleanup)
    particle_color = string -- colorstring for particles - defaults to #3000EE
    uses_factor = bool -- whether factor affects the effect
    lvl1_factor = number -- factor for lvl1 effect - defaults to 1 if uses_factor
    lvl2_factor = number -- factor for lvl2 effect - defaults to 2 if uses_factor
    timer_uses_factor = bool -- whether hit_timer uses factor (uses_factor must be true) or a constant value (hit_timer_step must be defined)
    hit_timer_step = float -- interval between hit_timer hits
    damage_modifier = string -- damage flag of which damage is changed as defined by modifier_func, pass empty string for all damage
    dmg_mod_is_type = bool -- damage_modifier string is used as type instead of flag of damage, defaults to false
    modifier_func = function(damage, effect_vals) -- see damage_modifier, if not defined damage_modifier defaults to 100% resistance
    modifier_priority = integer -- priority passed when registering damage_modifier - defaults to -50
    affects_item_speed = table
-- -- if provided, effect gets added to the item_speed_effects table, this should be true if the effect affects item speeds,
-- -- otherwise it won't work properly with other such effects (like haste and fatigue)
-- -- -- factor_is_positive - bool - whether values of factor between 0 and 1 should be considered +factor% or speed multiplier
-- -- --   - obviously +factor% is positive and speed multiplier is negative interpretation
-- -- --   - values of factor higher than 1 will have a positive effect regardless
-- -- --   - values of factor lower than 0 will have a negative effect regardless
}
```

### HP Hudbar Modifiers
This part of the API allows complex modification of the HP hudbar. It is mainly required here, so it is defined here. It may be moved to a different mod in the future.

#### Functions
`vlf_entity_effects.register_hp_hudbar_modifier(def)` – this function takes a modifier definition (`def`, described below) and registers a HP hudbar modifier if the definition is valid.

#### HP Hudbar Modifier Definition
```lua
def = {
-- required parameters in def:
    predicate = function(player) -- returns true if player fulfills the requirements (eg. has the effects) for the hudbar look
    icon = string -- name of the icon to which the modifier should change the HP hudbar heart
    priority = signed_int -- lower gets checked first, and first fulfilled predicate applies its modifier
}
```

### Potions
Magic!

#### Functions
`vlf_entity_effects.register_entity_effect(def)` – takes a entity_effect definition (`def`) and registers a entity_effect if the definition is valid, and adds the known parts of the definition as well as the outcomes of processing of some parts of the definition to the `vlf_entity_effects.registered_effects` table. This, depending on some fields of the definition, may as well register the corresponding splash entity_effect, lingering entity_effect and tipped arrow. This should only be used at load time.

`vlf_entity_effects.register_splash(name, descr, color, def)` – registers a splash entity_effect (item and entity when thrown). This is mostly part of the internal API and probably shouldn't be used from outside, therefore not providing exact description. This is used by `vlf_entity_effects.register_entity_effect()`.

`vlf_entity_effects.register_lingering(name, descr, color, def)` – registers a lingering entity_effect (item and entity when thrown). This is mostly part of the internal API and probably shouldn't be used from outside, therefore not providing exact description. This is used by `vlf_entity_effects.register_entity_effect()`.

`vlf_entity_effects.register_arrow(name, desc, color, def)` – registers a tipped arrow (item and entity when shot). This is mostly part of the internal API and probably shouldn't be used from outside, therefore not providing exact description. This is used by `vlf_entity_effects.register_entity_effect()`.

#### Tables
`vlf_entity_effects.registered_entity_effects` – contains all entity_effects that have been registered. You can read from it various data about the entity_effects. You can overwrite the data and alter the definitions too, but this is discouraged, i.e. only do this if you really know what you are doing. You shouldn't add entity_effects directly to this table, because they have to be registered as items too; instead use the `vlf_entity_effects.register_entity_effect()` function, which is described above. Some brewing recipes are autofilled based on this table after the loading of all the mods is done.

#### Constants
* `vlf_entity_effects.POTENT_FACTOR = 2`
* `vlf_entity_effects.PLUS_FACTOR = 8/3`
* `vlf_entity_effects.INV_FACTOR = 0.50`
* `vlf_entity_effects.DURATION = 180`
* `vlf_entity_effects.DURATION_INV = vlf_entity_effects.DURATION * vlf_entity_effects.INV_FACTOR`
* `vlf_entity_effects.DURATION_POISON = 45`
* `vlf_entity_effects.II_FACTOR = vlf_entity_effects.POTENT_FACTOR` – **DEPRECATED**
* `vlf_entity_effects.DURATION_PLUS = vlf_entity_effects.DURATION * vlf_entity_effects.PLUS_FACTOR` – **DEPRECATED**
* `vlf_entity_effects.DURATION_2 = vlf_entity_effects.DURATION / vlf_entity_effects.II_FACTOR` – **DEPRECATED**
* `vlf_entity_effects.SPLASH_FACTOR = 0.75`
* `vlf_entity_effects.LINGERING_FACTOR = 0.25`

#### Potion Definition
```lua
def = {
-- required parameters in def:
    name = string, -- entity_effect name in code
-- optional parameters in def:
    desc_prefix = S(string), -- part of visible entity_effect name, comes before the word "Potion"
    desc_suffix = S(string), -- part of visible entity_effect name, comes after the word "Potion"
    _tt = S(string), -- custom tooltip text
    _dynamic_tt = function(level), -- returns custom tooltip text dependent on entity_effect level
    _longdesc = S(string), -- text for in=game documentation
    stack_max = int, -- max stack size -  defaults to 1
    image = string, -- name of a custom texture of the entity_effect icon
    color = string, -- colorstring for entity_effect icon when image is not defined - defaults to #0000FF
    groups = table, -- item groups definition for the regular entity_effect, not splash or lingering -
--   - must contain _vlf_entity_effects=1 for tooltip to include dynamic_tt and effects
--   - defaults to {brewitem=1, food=3, can_eat_when_full=1, _vlf_entity_effects=1}
    nocreative = bool, -- adds a not_in_creative_inventory=1 group - defaults to false
    _effect_list = {, -- all the effects dealt by the entity_effect in the format of tables
-- -- the name of each sub-table should be a name of a registered effect, and fields can be the following:
        uses_level = bool, -- whether the level of the entity_effect affects the level of the effect -
-- -- --   - defaults to the uses_factor field of the effect definition
        level = int, -- used as the effect level if uses_level is false and for lvl1 entity_effects - defaults to 1
        level_scaling = int, -- used as the number of effect levels added per entity_effect level - defaults to 1 -
-- -- --   - this has no effect if uses_level is false
        dur = float, -- duration of the effect in seconds - defaults to vlf_entity_effects.DURATION
        dur_variable = bool, -- whether variants of the entity_effect should have the length of this effect changed -
-- -- --   - defaults to true
-- -- --   - if at least one effect has this set to true, the entity_effect has a "plus" variant
        effect_stacks = bool, -- whether the effect stacks - defaults to false
    }
    uses_level = bool, -- whether the entity_effect should come at different levels -
--   - defaults to true if uses_level is true for at least one effect, else false
    drinkable = bool, -- defaults to true
    has_splash = bool, -- defaults to true
    has_lingering = bool, -- defaults to true
    has_arrow = bool, -- defaults to false
    has_potent = bool, -- whether there is a potent (e.g. II) variant - defaults to the value of uses_level
    default_potent_level = int, -- entity_effect level used for the default potent variant - defaults to 2
    default_extend_level = int, -- extention level (amount of +) used for the default extended variant - defaults to 1
    custom_on_use = function(user, level), -- called when the entity_effect is drunk, returns true on success
    custom_effect = function(object, level, plus), -- called when the entity_effect effects are applied, returns true on success
    custom_splash_effect = function(pos, level), -- called when the splash entity_effect explodes, returns true on success
    custom_linger_effect = function(pos, radius, level), -- called on the lingering entity_effect step, returns true on success
}
```

### Brewing
Functions supporting brewing entity_effects, used by the `vlf_brewing` module, which calls `vlf_entity_effects.get_alchemy()`.

#### Functions
`vlf_entity_effects.register_ingredient_entity_effect(input, out_table)` – registers a entity_effect (`input`, item string) that can be combined with multiple ingredients for different outcomes; `out_table` contains the recipes for those outcomes

`vlf_entity_effects.register_water_brew(ingr, entity_effect)` – registers a `entity_effect` (item string) brewed from water with a specific ingredient (`ingr`)

`vlf_entity_effects.register_awkward_brew(ingr, entity_effect)` – registers a `entity_effect` (item string) brewed from an awkward entity_effect with a specific ingredient (`ingr`)

`vlf_entity_effects.register_mundane_brew(ingr, entity_effect)` – registers a `entity_effect` (item string) brewed from a mundane entity_effect with a specific ingredient (`ingr`)

`vlf_entity_effects.register_thick_brew(ingr, entity_effect)` – registers a `entity_effect` (item string) brewed from a thick entity_effect with a specific ingredient (`ingr`)

`vlf_entity_effects.register_table_modifier(ingr, modifier)` – registers a brewing recipe altering the entity_effect using a table; this is supposed to substitute one item with another

`vlf_entity_effects.register_inversion_recipe(input, output)` – what it says

`vlf_entity_effects.register_meta_modifier(ingr, mod_func)` – registers a brewing recipe altering the entity_effect using a function; this is supposed to be a recipe that changes metadata only

`vlf_entity_effects.get_alchemy(ingr, pot)` – finds an alchemical recipe for given ingredient and entity_effect; returns outcome

### Miscellaneous Functions
`vlf_entity_effects._extinguish_nearby_fire(pos, radius)` – attempts to extinguish fires in an area, both on objects and nodes.

`vlf_entity_effects._add_spawner(obj, color)` – adds a particle spawner denoting an effect being in action.

`vlf_entity_effects._use_entity_effect(obj, color)` – visual and sound effects of drinking a entity_effect.

`vlf_entity_effects.is_obj_hit(self, pos)` – determines if an object is hit (by a thrown entity_effect).
