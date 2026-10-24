# mod-spheregrid

**WORK IN PROGRESS**

**Usable as it is.**

A second progression for AzerothCore 3.3.5a: a grid of cells the character walks through, buying what it passes with Spherite, a currency the content awards.

## Key features

- Cells that grant statistics, hold sockets for stones and runes, or teach new class spells and ranks.
- Spherite earned by the account (dungeon and raid bosses, clears, grinding, Mythic+), spent by each character.
- A free respec: a character hands its grid back and gets every point again.
- Stones, runes and Nexuses dropped across the game; fused, rerolled and reforged at the workbench.
- Beside Blizzard's talent tree, without touching it; an in-game layout editor to draw your own grid.
- Texts in English, French, German, Spanish and Russian.

## Dependencies

| Dependency | For |
|---|---|
| [AzerothCore](https://github.com/azerothcore/azerothcore-wotlk) (WotLK 3.3.5a) | the server |
| [mod-ale](https://github.com/azerothcore/mod-ale) | runs the interface |
| [AIO](https://github.com/Rochet2/AIO) | the interface: `AIO_Server` in `lua_scripts`, and the `AIO_Client` addon on every client |
| [dynamicloot](https://github.com/Adrestie/WoW-mods-dynamicloot) | places the module's drops across the game; install it first, with the installer too |
| [The workbench](https://github.com/Adrestie/WoW-mods-workbench) | fusing and rerolling; shipped inside this module, the installer places it |
| [MythicPlus](https://github.com/huptiq/MythicPlus) | optional: the Spherite of keystone dungeons |
| Python 3, the `mysql` client, Pillow and numpy | only for the out-of-game layout editor |

## How to install

1. Download `installer.exe` from the [WoW-mods-installer releases](https://github.com/Adrestie/WoW-mods-installer/releases).
2. Stop the worldserver and close the game.
3. Run `installer.exe`, give it this folder and the folders it asks for, click **Check**, then **Install**.
4. Rebuild the worldserver. On its next start, the core applies the module's SQL.
5. The installer writes the game files into `Data\patch-Z.MPQ`: give that archive to the other players.
6. Put a workbench down in your world (game object 810000), where you want it.

## How to update

Same steps with the new version's folder, choosing **Update** instead of **Install**. The accounts' Spherite and stones, the characters' lit cells, and your `mod-spheregrid.conf` settings, are kept. Rebuild the worldserver, then give the players the new `patch-Z.MPQ`.

## How to uninstall

Same steps, choosing **Remove**. Everything goes, database included. The workbench stays while another module uses it. Rebuild the worldserver.

## Configuration

`mod-spheregrid.conf` sets:

- the cost of cells;
- the Spherite earned from dungeon bosses and clears, raids by tier, grinding and Mythic+;
- the stat bonuses of stones and runes;
- the drops of stones, runes and Nexuses (DynamicLoot lines), and one rate on top;
- the summons the grid's spells call.

## Commands

| Command | |
|---|---|
| `/spheregrid` | opens the window |
| `.spheregrid show` | opens the window |
| `.spheregrid activate` | buys a cell |
| `.spheregrid socket \| unsocket` | fills or empties a cell |
| `.spheregrid fuse \| reroll \| reforge \| grind` | the workbench |
| `.spheregrid respec` | hands the grid back |
| `.spheregrid info` | game master: the loaded definition |
| `.spheregrid status \| stats` | game master: a player's points, and what the grid grants |
| `.spheregrid points add \| remove \| set` | game master: a player's Spherite |
| `.spheregrid reset \| wipeall` | game master: wipes a character, or a whole account |
| `.spheregrid reload` | game master: reads the definition again |
| `.spheregrid editor` | game master: the layout editor |
