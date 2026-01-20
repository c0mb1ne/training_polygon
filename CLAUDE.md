# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Dota 2 custom game (addon) called "Training Polygon" - a practice/training mode for Dota 2 players to improve their mechanics.

## Directory Structure

The repository uses symlinks to the actual Dota 2 addon directories:
- `content/dota_addons/training_polygon/` → Content files (maps, materials, panorama sources)
- `game/dota_addons/training_polygon/` → Game files (scripts, compiled panorama, resources)

### Key Directories

**Server-side Lua scripts:** `game/dota_addons/training_polygon/scripts/vscripts/`
- `addon_game_mode.lua` - Entry point, precaching
- `gamemode.lua` - Main game mode logic (largest file, ~320KB)
- `settings.lua` - Game configuration constants
- `events.lua` - Event handlers
- `casting.lua` - Spell casting logic (~200KB)
- `gamemodes/` - Individual game mode implementations (e.g., `dodge.lua`)
- `libraries/` - Utility modules (timers, modifiers, database)
- `internal/` - Barebones framework internals

**Client-side UI (Panorama):** `game/dota_addons/training_polygon/panorama/`
- `layout/custom_game/` - XML layouts (.xml → compiled .vxml_c)
- `scripts/custom_game/` - JavaScript (.js → compiled .vjs_c)
- `styles/custom_game/` - CSS (.css → compiled .vcss_c)
- `mainmenu.vxml/vjs/vcss` - Main menu UI
- `menu2snippets/` - Modular menu components

**NPC definitions:** `game/dota_addons/training_polygon/scripts/npc/`
- `npc_units_custom.txt` - Custom unit definitions
- `npc_items_custom.txt` - Custom item definitions
- `npc_abilities_custom.txt` - Custom ability definitions

**Maps:** `content/dota_addons/training_polygon/maps/`
- `template_map.vmap` - Main map (edit with Hammer)

## Architecture

The codebase is built on the "Barebones" framework for Dota 2 custom games:
1. `addon_game_mode.lua` bootstraps the game, calling `Precache()` then `Activate()`
2. `GameMode` class in `gamemode.lua` handles core logic
3. Game modes (like dodge training) are modular classes in `gamemodes/`
4. Client-server communication uses custom game events (`CustomGameEventManager`)
5. Panorama UI communicates with Lua via `GameEvents.SendCustomGameEventToServer()`

## Compiled Files

The `.gitignore` excludes compiled Panorama files (`.vtex_c`, `.vcss_c`, `.vjs_c`, `.vxml_c`). Edit the source files:
- `.xml` for layouts
- `.js` for scripts
- `.css` for styles

Valve's tools auto-compile these when running in tools mode.

## Testing

Launch Dota 2 Workshop Tools, select the addon, and use "Launch Custom Game" to test changes. Lua changes reload on map restart; Panorama changes may require recompiling.
