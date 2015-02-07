API documentation for the HUD bars mod 0.1.0
============================================

**Warning**: This API is still experimental, everything may change at any time,
and backwards compability will not be ensured until the 1.0.0 release of the
HUD bars mod.

## Introduction
This API allows you to add, change, hide and unhide custom HUD bars for this mod.

## Overview
To give you a *very* brief overview over this API, here is the basic workflow on how to add your own custom HUD bar:

* Create images for your HUD bar
* Call `hud.register_hudbar` to make the definition of the HUD bar known to this mod
* Call `hud.hudbars[identifier].add_all` for each player for which you want to use previously defined HUD bar
* Use `hud.change_hudbar` whenever you need to change the values of a HUD bar of a certain player
* If you need it: Use `hud.hide_hudbar` and `hud.unhide_hudbar` to hide or unhide HUD bars of a certain player

## The basic rules
In order to use this API, you should be aware of a few basic rules in order to understand it:

* A HUD bar is an approximate graphical representation of the ratio of a current value and a maximum value, i.e. current health of 15 and maximum health of 20. A full HUD bar represents 100%, an empty HUD bar represents 0%.
* The current value must always be equal to or smaller then the maximum 
* Both current value and maximum must not be smaller than 0
* Both current value and maximum must be real numbers. So no NaN, infinity, etc.
* The HUD bar will be hidden if the maximum equals 0. This is intentional.
* The health and breath HUD bars are hardcoded and can not be changed with this API.

These are soft rules, the HUD bars mod will not enforce all of these.
But this mod has been programmed under the assumption that these rules are followed, for integrity.

## Adding a HUD bar
To add a HUD bar, you need …

* … an image of size 2×16 for the bar
* … an icon of size 16×16 (optional)
* … to register it wiith hud.
* … to activate it for each player for which you want the HUD 

### Bar image
The image for the bar will be repeated horizontally to denote the “value” of the HUD bar.
It **must** be of size 2×16.
If neccessary, the image will be split vertically in half, and only the left half of the image
is displayed. So the final HUD bar will always be displayed on a per-pixel basis.

The default bar images are single-colored, but you can use other styles as well, for instance,
a vertical gradient.

### Icon
A 16×16 image shown left of the HUD bar. This is optional.

### `hud.register_hudbar(identifier, text_color, label, textures, default_start_value, default_start_max, start_hide, format_string)`
This function adds a new custom HUD
Note this does not yet display the HUD bar.

There is currently no reliable way to force a certain order at which the custom HUD bars will be placed.

#### Parameters
* `identifier`: A globally unique internal name for the HUD bar, will be used later to refer to it. Please only rely on alphanumeric characters for now.
* `text_color`: A 3-byte number defining the color of the text. The bytes denote, in this order red, green and blue and range from `0x00` (complete lack of this component) to `0xFF` (full intensity of this component). Example: `0xFFFFFF` for white.
* `label`: A string which is displayed on the HUD bar itself to describe the HUD bar. Try to keep this string short.
* `textures`: A table with the following fields:
 * `bar`: The file name of the bar image (as string).
 * `icon`: The file name of the icon, as string. This field can be `nil`, in which case no icon will be used.
* `default_start_value`: If this HUD bar is added to a player, and no initial value is specified, this value will be used as initial current value
* `default_max_value`: If this HUD bar is added to a player, and no initial maximum value is specified, this value will be used as initial maximum value
* `start_hide`: The HUD bar will be initially start hidden when added to a player. Use `hud.unhide_hudbar` to unhide it.
* `format_string`: This is optional; You can specify an alternative format string display the final text on the HUD bar. The default format string is “`%s: %d/%d`” (in this order: Label, current value, maximum value). See also the Lua documentation of `string.format`.


#### Return value
Always `nil`.


## Displaying a HUD bar
After a HUD bar has been registered, they are not yet displayed yet for any player. HUD bars must be
explicitly enabled on a per-player basis.

You probably want to do this in the `minetest.register_on_joinplayer`.

### `hud.hudtables[identifier].add_all(player, start_value, start_max)`
This function activates and displays

However, if `start_hide` was set to `true` for the HUD bar, the HUD bar will initially be hidden, but
the HUD elements are still sent to the client.

You have to replace `identifier` with the identifier string you have specified previously, i.e. use
`hud.hudtables["example"].add_all` if your identifier string is `"example"`. The identifier
specifies the type of HUD bar you want to display.

This is admittedly a rather odd function call and will likely to be changed.

#### Parameters
* `player`: `ObjectRef` of the player to which the new HUD bar should be displayed to.
* `start_value`: The initial current value of the HUD bar. This is optional, `default_start_value` of the registration function will be used, if this is `nil`.
* `start_max`: The initial maximum value of the HUD bar. This is optional, `default_start_max` of the registration function will be used, if this is `nil`

#### Return value
Always `nil`.



## Modifying a HUD bar
After a HUD bar has been added, you can change the current and maximum value on a per-player basis.
You use the function `hud.change_hudbar` for this.

### `hud.change_hudbar(player, hudtable, new_value, new_max_value)`
Changes the values of. If

#### Parameters
* `player`: `ObjectRef` of the player to which the HUD bar belongs to
* `hudtable`: The table containing the HUD bar definition. Specify as `hud.hudtables[identifier]`, i.e. if your identifier was `example`, then you use `hud.hudtables["example"]`.
* `new_value`: The new current value of the HUD bar
* `new_max_value`: The new maximum value of the HUD bar

#### Return value
Always `nil`.


## Hiding and unhiding a HUD bar
You can also hide custom HUD bars, meaning they will not be displayed for a certain player. You can still
use `hud.change_hudbar` on a hidden HUD bar, the new values will be correctly displayed after the HUD bar
has been unhidden.

Note that the hidden state of a HUD bar will *not* be saved by this mod on server shutdown, so you may need
to write your own routines for this.

### `hud.hide_hudbar(player, hudtable)`
Hides the specified HUD bar from the screen of the specified player.

#### Parameters
* `player`: `ObjectRef` of the player to which the HUD bar belongs to
* `hudtable`: The table containing the HUD bar definition, see `hud.change_hudbar`.

#### Return value
Always `nil`.


### `hud.hide_hudbar(player, hudtable)`
Makes a previously hidden HUD bar visible again to a player

#### Parameters
* `player`: `ObjectRef` of the player to which the HUD bar belongs to
* `hudtable`: The table containing the HUD bar definition, see `hud.change_hudbar`.

#### Return value
Always `nil`.

