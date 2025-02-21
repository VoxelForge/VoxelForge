# Contributing to VoxelForge
So you want to contribute to VoxelForge?

Wow, thank you! :-)

VoxelForge is maintained by DragonWrangler. 

By asking us to include your work. You agree that it falls under one of two licenses.

1. GNU GPLv3
2. OCLv1.1
[Open Credit License V1.1](https://github.com/DragonWrangler1/OCL-1.1-License)

## Inclusion criteria
The project goals are listed under the project description in the
[README](./src/branch/main/README.md). Contributions that do not align with the project goals
will not be accepted. The main goal of VoxelForge is to be a stable and
performant clone of Minecraft, while keeping functionality.. We suggest using the
[Minecraft wiki](https://minecraft.wiki/w/Minecraft_Wiki) as a
reference when implementing new features.

While the primary goal of VoxelForge is to clone Minecraft gameplay, sometimes
contributions containing minor deviations from Minecraft will be included. These
deviations should be motivated either by Luanti engine limitations or other
technical difficulties replicating Minecraft behaviour. The addition of bonus
features not found in Minecraft will generally not be accepted. Most of the time
we will suggest putting such features in a separate mod since VoxelForge has
modding support.

Contributions which fix bugs or incomplete features are always welcome.
Contributions of Minecraft features not yet implemented in VoxelForge are also
welcome but should be complete before their inclusion. Assets like sounds and
textures must come from sources which allow their use.

## Code Guidelines
* Each mod must provide `mod.conf`.
* Mod names are snake case, and newly added mods start with `vlf_`, e.g.
  `vlf_core`, `vlf_farming`, `vlf_monster_eggs`. Keep in mind Luanti does not
  support capital letters in mod names.
* To export functions, store them inside a global table named like the mod,
  e.g.

```lua
vlf_example = {}

function vlf_example.do_something()
	-- ...
end
```

* Public functions should not use self references but rather just access the
  table directly, e.g.

```lua
-- bad
function vlf_example:do_something()
end

-- good
function vlf_example.do_something()
end
```

* Use modern Luanti API, e.g. no usage of `minetest.env`
* Tabs should be used for indent, spaces for alignment, e.g.

```lua
-- use tabs for indent

for i = 1, 10 do
	if i % 3 == 0 then
		print(i)
	end
end

-- use tabs for indent and spaces to align things

some_table = {
	{"a string",                   5},
	{"a very much longer string", 10},
}
```

* Use double quotes for strings, e.g. `"asdf"` rather than `'asdf'`
* Use snake_case rather than CamelCase, e.g. `my_function` rather than
  `MyFunction`
* Don't declare functions as an assignment, e.g.

```lua
-- bad
local some_local_func = function()
	-- ...
end

my_mod.some_func = function()
	-- ...
end

-- good
local function some_local_func()
	-- ...
end

function my_mod.some_func()
	-- ...
end
```
