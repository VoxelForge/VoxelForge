# API documentation for version 0.7.0
## Core concepts
As a modder, you are free to write basically about everything and are also
relatively free in the presentation of information. The Documentation
System has no restrictions on content whatsoever.

### Categories and entries
In the documentation system, everything is built on categories and entries.
An entry is a single piece of documentation and is the basis of all actual
documentation. Categories group multiple entries of the same topic together.

Categories also define a template which is used to determine how the final
result in the Entry tab looks like. Entries themselves have a data field
attached to them, this is a table containing arbitrary metadata which is
used to construct the final formspec which is used on the Entry tab.

## Advanced concepts
### Viewed and hidden entries
The mod keeps track of which entries have been viewed by any player.
Any entry which has been accessed by a player is instantly marked as “viewed”.

It also allows entries to be hidden. Hidden entries are not visible or
normally accessible to players until they become revealed by function calls.

Marking an entry as viewed or revealed is not reversible with this API.
The viewed and hidden states are stored in the file `doc.mt` inside the
world directory.

### Entry aliases
Entry aliases are alternative identifiers for entry identifiers. With the
exception of the alias functions themselves, When a function demands an
`entry_id` you can either supply the original `entry_id` or any alias of the
`entry_id`.

## Possible use cases
I present to you some possible use cases to give you a rough idea what
this mod is capable of and how certain use cases should be implemented.

### Simple use case: Minetest basics
I want to write in free form short help texts about the basic concepts of
Minetest or my subgame. First I define a category called “Basics”, the data
for each of its entry is just a free form text. The template function simply
creates a formspec where this free form text is displayed.

### Complex use case: Blocks
I could create a category called “Blocks”, and this category is supposed to
contain entries for every single block in the game. For this case, a free form
approach would be very inefficient and error-prone, as a lot of data can be
reused.

Here the template function comes in handy: The internal entry data
contain a lot of different things about a block, like block name, identifier,
custom description and most importantly, the definition table of the block.

Finally, the template function takes all that data and turns it into
sentences which are just concatenated, telling as many useful facts about
this block as possible.

## Functions
This is a list of all publicly available functions.

### Overview
The most important functions are `doc.new_category` and `doc.new_entry`. All other functions
are mostly used for utility and examination purposes.

These functions are available:

* `doc.new_category`: Adds a new category
* `doc.new_entry`: Adds a new entry
* `doc.show_entry`: Shows a particular entry to a player
* `doc.show_category`: Shows the entry list of a category to a player
* `doc.show_doc`: Opens the main Documentation System form for a player
* `doc.get_category_definition`: Returns the definition table of a category
* `doc.get_entry_definition`: Returns the definition table of an entry
* `doc.entry_exists`: Checks whether an entry exists
* `doc.entry_viewed`: Checks whether an entry has been viewed/read by a player
* `doc.entry_revealed`: Checks whether an entry is visible and normally accessible to a player
* `doc.mark_entry_as_viewed`: Manually marks an entry as viewed/read by a player
* `doc.mark_entry_as_revealed`: Make a hidden entry visible and accessible to a player
* `doc.mark_all_entries_as_revealed`: Make all hidden entries visible and accessible to a player
* `doc.add_entry_alias`: Add an alternative name which can be used to access an entry
* `doc.add_entry_aliases`: Add multiple alternative names which can be used to access an entry
* `doc.get_category_count`: Returns the total number categories
* `doc.get_entry_count`: Returns the total number of entries in a category
* `doc.get_viewed_count`: Returns the number of entries a player has viewed in a category
* `doc.get_revealed_count`: Returns the number of entries a player has access to in a category
* `doc.get_hidden_count`: Returns the number of entries which are hidden from a player in a category
* `doc.get_selection`: Returns the current viewed entry/category of a player

#### Special widgets
This API provides an experimental convenience function for creating a special
widget to be used in formspecs. This function may be deprecated in later versions.

### `doc.new_category(id, def)`
Adds a new category. You have to define an unique identifier, a name
and a template function to build the entry formspec from the entry
data.

**Important**: You must call this function before any player joins, but not later.

#### Parameters
* `id`: Unique category identifier as a string
* `def`: Definition table, it has the following fields:
    * `name`: Category name to be shown in the interface
    * `description`: (optional) Short description of the category,
       will be shown as tooltip. Recommended style (in English):
       First letter capitalized, no punctuation at end of sentence,
       max. 100 characters
    * `build_formspec`: The template function. Takes entry data as its
      only parameter (has the data type of the entry data) and must
      return a formspec which is inserted in the Entry tab.
    * `sorting`: (optional) Sorting algorithm for display order of entries
        * `"abc"`: Alphabetical (default)
        * `"nosort"`: Entries appear in no particular order
        * `"custom"`: Manually define the order of entries in `sorting_data`
        * `"function"`: Sort by function defined in `sorting_data`
    * `sorting_data`: (optional) Additional data for special sorting methods.
        * If `sorting=="custom"`, this field must contain a table (list form) in which
          the entry IDs are specified in the order they are supposed to appear in the
          entry list. All entries which are missing in this table will appear in no
          particular order below the final specified one.
        * If `sorting=="function"`, this field is a compare function to be used as
          the `comp` parameter of `table.sort`. The parameters given are two entries.
        * This field is not required if `sorting` has any other value
    * `hide_entries_by_default` (optional, experimental): If `true`, all entries
      added to this category will start as hidden, unless explicitly specified otherwise
      (default: `false`)

Note: For function-based sorting, the entries provided in the compare function have the
following format:

    {
        name = n, -- entry name
        data = d, -- arbitrary entry data
    }

#### Return value
Always `nil`.

#### Using `build_formspec`
For `build_formspec` you can either define your own function which
procedurally generates the entry formspec or you use one of the
following predefined convenience functions:

* `doc.entry_builders.text`: Expects entry data to be a string.
  It will be inserted directly into the entry. Useful for entries with
  a free form text.
* `doc.entry_builders.formspec`: Entry data is expected to contain the
  complete entry formspec as a string. Useful if your entries. Useful
  if you expect your entries to differ wildly in layouts.

##### Formspec restrictions
When building your formspec, you have to respect the size limitations.
The documentation system uses a size of 12×9 and you must make sure
all entry widgets are inside a boundary box. The remaining space is
reserved for widgets of the Documentation System and should not be used
to avoid overlapping.
Read from the following variables to calculate the final formspec coordinates:

* `doc.FORMSPEC.WIDTH`: Width of Documentation System formspec
* `doc.FORMSPEC.HEIGHT`: Height of Documentation System formspec
* `doc.FORMSPEC.ENTRY_START_X`: Leftmost X point of bounding box
* `doc.FORMSPEC.ENTRY_START_Y`: Topmost Y point of bounding box
* `doc.FORMSPEC.ENTRY_END_X`: Rightmost X point of bounding box
* `doc.FORMSPEC.ENTRY_END_Y`: Bottom Y point of bounding box
* `doc.FORMSPEC.ENTRY_WIDTH`: Width of the entry widgets bounding box
* `doc.FORMSPEC.ENTRY_HEIGHT`: Height of the entry widgets bounding box

Finally, to avoid naming collisions, you must make sure that all identifiers
of your own formspec elements do *not* begin with “`doc_`”.

##### Receiving formspec events
You can even use the formspec elements you have added with `build_formspec` to
receive formspec events, just like with any other formspec. For receiving, use
the standard function `minetest.register_on_player_receive_fields` to register
your event handling. The `formname` parameter will be `doc:entry`. Use
`doc.get_selection` to get the category ID and entry ID of the entry in question.

### `doc.new_entry(category_id, entry_id, def)`
Adds a new entry into an existing category. You have to define the category
to which to insert the entry, the entry's identifier, a name and some
data which defines the entry. Note you do not directly define here how the
end result of an entry looks like, this is done by `build_formspec` from
the category definition.

**Important**: You must call this function before any player joins, but not later.

#### Parameters
* `category_id`: Identifier of the category to add the entry into
* `entry_id`: Unique identifier of the new entry, as a string
* `def`: Definition table, it has the following fields:
    * `name`: Entry name to be shown in the interface
    * `hidden`: (optional) If `true`, entry will not be displayed in entry list
      initially (default: `false`); it can be revealed later
    * `data`: Arbitrary data attached to the entry. Any data type is allowed;
      The data in this field will be used to create the actual formspec
      with `build_formspec` from the category definition

#### Return value
Always `nil`.

### `doc.show_doc(playername)`
Opens the main documentation formspec for the player (Main tab).

#### Parameters
* `playername`: Name of the player to show the formspec to

### `doc.show_category(playername, category_id)`
Opens the documentation formspec for the player at the specified category
(Category tab).

#### Parameters
* `playername`: Name of the player to show the formspec to
* `category_id`: Category identifier of the selected category

#### Return value
Always `nil`.

### `doc.show_entry(playername, category_id, entry_id, ignore_hidden)`
Opens the documentation formspec for the player showing the specified entry
of a category (Entry tab). If the entry is hidden, an error message
is displayed unless `ignore_hidden==true`.

#### Parameters
* `playername`: Name of the player to show the formspec to
* `category_id`: Category identifier of the selected category
* `entry_id`: Entry identifier of the entry to show
* `ignore_hidden`: (optional) If `true`, shows entry even if it is still hidden
  to the player; this will automatically reveal the entry to this player for the
  rest of the game

#### Return value
Always `nil`.

### `doc.get_category_definition(category_id)`
Returns the definition of the specified category.

#### Parameters
* `category_id`: Category identifier of the category to the the definition
  for

#### Return value
The category's definition table as specified in the `def` argument of
`doc.new_category`. The table fields are the same.

### `doc.get_entry_definition(category_id, entry_id)`
Returns the definition of the specified entry.

#### Parameters
* `category_id`: Category identifier of entry's category
* `entry_id`: Entry identifier of the entry to get the definition for

#### Return value
The entry's definition table as specified in the `def` argument of
`doc.new_entry`. The table fields are the same.

### `doc.entry_exists(category_id, entry_id)`
Checks if the specified entry exists and returns `true` or `false`.

#### Parameters
* `category_id`: Category identifier of the category to check
* `entry_id`: Entry identifier of the entry to check for its existence

#### Return value
Returns `true` if and only if:

* The specified category exists
* This category contains the specified entry

Otherwise, returns `false`.

### `doc.entry_viewed(playername, category_id, entry_id)`
Tells whether the specified entry is marked as “viewed” (or read) by
the player.

#### Parameters
* `playername`: Name of the player to check
* `category_id`: Category identifier of the category to check
* `entry_id`: Entry identifier of the entry to check

#### Return value
`true`, if entry is viewed, `false` otherwise.

### `doc.entry_revealed(playername, category_id, entry_id)`
Tells whether the specified entry is marked as “revealed” to the player
and thus visible and generally accessible.

#### Parameters
* `playername`: Name of the player to check
* `category_id`: Category identifier of the category to check
* `entry_id`: Entry identifier of the entry to check

#### Return value
`true`, if entry is revealed, `false` otherwise.

### `doc.mark_entry_as_viewed(playername, category_id, entry_id)`
Marks a particular entry as “viewed” (or read) by a player. This will
also automatically reveal the entry to the player permanently.

#### Parameters
* `playername`: Name of the player for whom to mark an entry as “viewed”
* `category_id`: Category identifier of the category of the entry to mark
* `entry_id`: Entry identifier of the entry to mark

#### Returns
Always `nil`.

### `doc.mark_entry_as_revealed(playername, category_id, entry_id)`
Marks a particular entry as “revealed” to a player. If the entry is
declared as hidden, it will become visible in the list of entries for
this player and will always be accessible with `doc.show_entry`. This
change is permanent.

For entries which are not normally hidden, this function has no direct
effect.

#### Parameters
* `playername`: Name of the player for whom to reveal the entry
* `category_id`: Category identifier of the category of the entry to reveal
* `entry_id`: Entry identifier of the entry to reveal

#### Returns
Always `nil`.

### `doc.mark_entry_as_revealed(playername)`
Marks all entries as “revealed” to a player. This change is permanent.

#### Parameters
* `playername`: Name of the player for whom to reveal the entries

#### Returns
Always `nil`.

### `doc.add_entry_alias(category_id, entry_id, alias)`
Adds a single alias for an entry. When an entry has an alias, supplying the
alias to a function which demands an `entry_id` will work as if the original
`entry_id` has been supplied. Aliases are true within one category only.
When using this function, you must make sure the category already exists.

#### Parameters
* `category_id`: Category identifier of the category of the entry in question
* `entry_id`: The original (!) entry identifier of the entry to create an alias
  for
* `alias`: Alias (string) for `entry_id`

#### Return value
Always `nil`.

### `doc.add_entry_aliases(category_id, entry_id, aliases)`
Adds an arbitrary amount of aliases for an entry at once. Apart from that, this
function has the same effect as `doc.add_entry_alias`.
When using this function, you must make sure the category already exists.

#### Parameters
* `category_id`: Category identifier of the category of the entry in question
* `entry_id`: The original (!) entry identifier of the entry to create aliases
  for
* `aliases`: Table/list of aliases (strings) for `entry_id`

#### Return value
Always `nil`.

### `doc.get_category_count()`
Returns the number of registered categories.

### `doc.get_entry_count(category_id)`
Returns the number of entries in a category.

#### Parameters
* `category_id`: Category identifier of the category in which to count entries

#### Return value
Number of entries in the specified category.

### `doc.get_viewed_count(playername, category_id)`
Returns how many entries have been viewed by a player.

#### Parameters
* `playername`: Name of the player to count the viewed entries for
* `category_id`: Category identifier of the category in which to count the
  viewed entries

#### Return value
Amount of entries the player has viewed in the specified category. If the
player does not exist, this function returns `nil`.

### `doc.get_revealed_count(playername, category_id)`
Returns how many entries the player has access to (non-hidden entries)
in this category.

#### Parameters
* `playername`: Name of the player to count the revealed entries for
* `category_id`: Category identifier of the category in which to count the
  revealed entries

#### Return value
Amount of entries the player has access to in the specified category. If the
player does not exist, this function returns `nil`.

### `doc.get_hidden_count(playername, category_id)`
Returns how many entries are hidden from the player in this category.

#### Parameters
* `playername`: Name of the player to count the hidden entries for
* `category_id`: Category identifier of the category in which to count the
  hidden entries

#### Return value
Amount of entries hidden from the player. If the player does not exist,
this function returns `nil`.

### `doc.widgets.text(data, x, y, width, height)`
This is a convenience function for creating a special formspec widget. It creates
a widget in which you can insert scrollable multi-line text.

This function is provided because Minetest lacks native support for such a widget;
this function may be deprecated if it isn't needed anymore.

#### Parameters
* `data`: Text to be written inside the widget
* `x`: Formspec X coordinate (optional)
* `y`: Formspec Y coordinate (optional)
* `width`: Width of the widget in formspec units (optional)
* `height`: Height of the widget in formspec units (optional)

The default values for the optional parameters result in a widget which fills
nearly the entire entry page.

#### Return value
Two values are returned, in this order:

* String: Contains a complete formspec definition building the widget.
* String: Formspec element ID of the created widget

#### Note
When you use this function to build a formspec string, do not use identifiers
beginning with `doc_widget_text` to avoid naming collisions, as this function
makes use of such identifiers internally.


### `doc.get_selection(playername)`
Returns the currently or last viewed entry and/or category of a player.

#### Parameter
* `playername`: Name of the player to query

#### Return value
It returns up to 2 values. The first one is the category ID, the second one
is the entry ID of the entry/category which the player is currently viewing
or is the last entry the player viewed in this session. If the player only
viewed a category so far, the second value is `nil`. If the player has not
viewed a category as well, both returned values are `nil`.


## Extending this mod (naming conventions)
If you want to extend this mod with your own functionality, it is recommended
that you put all API functions into `doc.sub.<name>`.
As a naming convention, if your mod depends on `doc`, your mod name should also start
with “`doc_`”, like `doc_items`, `doc_minetest_game`, `doc_identifier`.

One mod which uses this convention is `doc_items` which uses the `doc.sub.items`
table.


