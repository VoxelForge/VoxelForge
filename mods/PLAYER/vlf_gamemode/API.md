# `vlf_gamemode`

## `vlf_gamemode.gamemodes`

List of availlable gamemodes.

Currently `{"survival", "creative"}`

## `vlf_gamemode.get_gamemode(player)`

Get the player's gamemode.

Returns "survival" or "creative".

## `vlf_gamemode.set_gamemode(player, gamemode)`

Set the player's gamemode.

gamemode: "survival" or "creative"

## `vlf_gamemode.register_on_gamemode_change(function(player, old_gamemode, new_gamemode))`

Register a function that will be called when `vlf_gamemode.set_gamemode` is called.

## `vlf_gamemode.registered_on_gamemode_change`

Map of registered on_gamemode_change.
