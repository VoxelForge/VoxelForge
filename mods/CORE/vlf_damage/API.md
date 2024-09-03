# vlf_damage

This mod is intended to overall minetest's native damage system, to provide a better integration between features that deals with entities' health.

WARNING: Not using it inside your mods may cause strange bugs (using the native damage system may cause conflicts with this system).

## Functions
`vlf_damage.run_modifiers(obj, damage, reason)`
	* Runs all registered damage modifiers for obj, ordered by
          priority, lowest priority first.  Feeds modified damage into
          next modifier, returns final damage.
        * if modifier returns 0, stop loop and return 0.
        * if modifier returns nil, continue with previous damage value.
        * damage may be positive or negative (i.e. healing).
`vlf_damage.run_damage_callbacks(obj, damage, reason)`
	* Runs all registered damage callbacks for obj
`vlf_damage.run_death_callbacks(obj, reason)`
	* Runs all registered death callbacks for obj

`vlf_damage.from_punch(vlf_reason, object)`
	* creates a new "reason" including vlf enrichtments like damage flags.
`vlf_damage.finish_reason(vlf_reason)`
	* Finalizes the reason, e.g. by adding the necessary flags.
`vlf_damage.from_mt(mt_reason)`
	* Creates a "vlf_reason" from a minetest one
`vlf_damage.register_type(name, def)`
	* Registers a new damage type

## Callbacks

To modify the amount of damage made by something:

```lua
--obj: an ObjectRef
vlf_damage.register_modifier(function(obj, damage, reason)
end, 0)
```

`vlf_damage.register_modifier(func, priority)`
	func = function(obj, damage, reason)
`vlf_damage.register_on_damage(func)`
	func = function(obj, damage, reason)
`vlf_damage.register_on_death(func)`
	func = function(obj, reason)
