# API documentation for version 0.2.0
## Core principles
As a modder, you are free to write basically about everything and are also
relatively free in the presentation of information. The Documentation
System has no restrictions on content whatsoever.

In the documentation system, everything is built on categories and entries.
An entry is a single piece of documentation and is the basis of all actual
documentation. Categories group multiple entries of the same topic together.

Categories also define a template which is used to determine how the final
result in the Entry tab looks like. Entries themselves have a data field
attached to them, this is a table containing arbitrary metadata which is
used to construct the final formspec which is used on the Entry tab.

## Possible use cases
I present to you some possible use cases to give you a rough idea what
this mod is capable and how certain use casescould be implemented.

### Simple use case: Minetest basics
I want to write in freeform short help texts about the basic concepts of
Minetest or my subgame. First I define a category called “Basics”, the data
for each of its entry is just a freeform text. The template function simply
creates a formspec where this freeform text is displayed.

### Complex use case: Blocks
I could create a category called “Blocks”, and this category is supposed to
contain entries for every single block in the game. For this case, a freeform 
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

### `doc.new_category(id, def)`
Adds a new category. You have to define an unique identifier, a name
and a template function to build the entry formspec from the entry
data.

#### Parameters
* `id`: Unique category identifier as a string
* `def`: Definition table, it has the following fields:
    * `name`: Category name to be shown in the interface
    * `build_formspec`: The template function. Takes entry data as its
      only parameter (has the data type of the entry data) and must
      return a formspec which is inserted in the Entry tab.

#### Using `build_formspec`
For `build_formspec` you can either define your own function which
procedurally generates the entry formspec or you use one of the
following predefined convenience functions:

* `doc.entry_builders.text`: Expects entry data to be a string.
  It will be inserted directly into the entry. Useful for entries with
  a freeform text.
* `doc.entry_builders.formspec`: Entry data is expected to contain the
  complete entry formspec as a string. Useful if your entries. Useful
  if you expect your entries to differ wildly in layouts.

When building your formspec, you have to respect the size limitations.
The documentation system uses a size of `12,9` and you should place
all your formspec elements at positions not lower than `0.25,0.5` to
avoid overlapping.

#### Return value
Always `nil`.

### `doc.new_entry(category_id, entry_id, def)`
Adds a new entry into an existing category. You have to define the category
to which to insert the entry, the entry's identifier, a name and some
data which defines the entry. Note you do not directly define here how the
end result of an entry looks like, this is done by `build_formspec` from
the category definition.

#### Parameters
* `category_id`: Identifier of the category to add the entry into
* `entry_id`: Unique identifier of the new entry, as a string
* `def`: Definition table, it has the following fields:
    * `name`: Entry name to be shown in the interface
    * `data`: Arbitrary data attached to the entry. Any data type is allowed;
      The data in this field will be used to create the actual formspec
      with `build_formspec` from the category definition

#### Return value
Always `nil`.

### `function doc.show_doc(playername)`
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

### `doc.show_entry(playername, category_id, entry_id)`
Opens the documentation formspec for the player showing the specified entry
of a category (Entry tab).

#### Parameters
* `playername`: Name of the player to show the formspec to
* `category_id`: Category identifier of the selected category
* `entry_id`: Entry identifier of the entry to show

#### Return value
Always `nil`.

### `doc.entry_exists(category_id, entry_id)`
Checks if the specified entry exists and returns `true` or `false`.

#### Parameters
* `category_id`: Category identifier of the category to check
* `entry_id`: Entry identifier of the entry to check for its existance

#### Return value
Returns `true` if and only if:

* The specified category exists
* This category contains the specified entry

Otherwise, returns `false`.

### `doc.add_entry_alias(category_id, entry_id, alias)`
Adds a single alias for an entry. When an entry has an alias, attempting to open
an entry by an alias name results in opening the entry of the original name.
Aliases are true within one category only.

#### Parameters
* `category_id`: Category identifier of the category of the entry in question
* `entry_id`: Entry identifier of the entry to create an alias for
* `alias`: Alias (string) for `entry_id`

#### Return value
Always `nil`.

### `doc.add_entry_aliases(category_id, entry_id, aliases)`
Adds an arbitrary amount of aliases for an entry at once. Apart from that, this
function has the same effect as `doc.add_entry_alias`.

#### Parameters
* `category_id`: Category identifier of the category of the entry in question
* `entry_id`: Entry identifier of the entry to create aliases for
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

### `function doc.get_viewed_count(playername, category_id)`
Returns how many entries have been viewed by a player.

#### Parameters
* `playername`: Name of the player to count the viewed entries for
* `category_id`: Category identifier of the category in which to count the
  viewed entries

#### Return value
Amount of entries the player has viewed in the specified category. If the
player does not exist, this function returns `nil`.
