# Documentation System
This mod provides a simple and highly extensible form in which the user
can access help pages about various things and the modder can add those pages.
The mod itself does not provide any help texts, just the framework.

Current version: 0.5.0

## For users
### Accessing the help
To open the help, there are multiple ways:

- Use the `doc` chat command. This works always.
- If you use Unified Inventory, click on the book icon in the inventory menu

The documentation system itself should be more or less self-explanatory.

This mod is useless on its own, you will only need this mod as a dependency
for mods which actually add some help entries.

### Hidden entries
Some entries are initially hidden from you. You can't see them until you
unlocked them. Mods can decide for themselves how particular entries are
revealed. Normally you just have to proceed in the game to unlock more
entries. Hidden entries exist to avoid spoilers and give players a small
sense of progress.

Players with the `doc_reveal` privilege can use the `doc_reveal` chat command
to reveal all hidden entries instantly.


## For modders and subgame authors
This mod helps you in writing extensive documentation for your mod or subgame.
You can write about basically anything in the presentation you prefer.

To get started, read `API.md` in the directory of this mod.

## License of everything
MIT License
