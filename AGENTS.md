# training_polygon

Dota 2 custom game (addon) with practice modes: dodge, timing, last-hit, aim, dream coil escape.
Server logic is Lua (Dota VScript). UI is Panorama (XML + JS + CSS). Windows dev, PowerShell.

## Hard rules
- NEVER read gamemode.lua (~7.9K lines), casting.lua (~5.7K lines) or dodge_skills.lua (~1.1K lines) in full.
  Search first: grep "function name" and read only a small range around the match.
- Do not edit generated or binary files: `*_c` (compiled panorama), `*.vpk`, `tools_*`, `server_log.txt`, `demoheader.tmp`.
- Edit UI sources only under `content/` (xml/js/css). Compiled output in `game/.../panorama` is built by Workshop Tools.
- New features go in `gamemodes/<mode>/`. Do not refactor the legacy code in gamemode.lua / casting.lua.
- Make the smallest change that works. Ask before touching more than 3 files.
- There are no automated tests. Changes are verified by running the addon in Dota 2 Tools.

## Layout
Two top-level folders mirror Dota's: `game/dota_addons/training_polygon/` and `content/dota_addons/training_polygon/`
(linked into the Dota install with junctions, see CONTRIBUTING.md).

Lua root: `game/dota_addons/training_polygon/scripts/vscripts/` (below: "vscripts/")
- addon_game_mode.lua: Precache() and Activate(); creates GameRules.GameMode.
- gamemode.lua: barebones-derived hub. Top of file: TP_VERSION (bump per workshop push), LEGACY_SWITCH
  (1 unless map is "dota"). Has the `require` list; a `-- gamemodes:` block near line 58 requires each mode.
  Also holds OLD training handlers as global functions with
  `CustomGameEventManager:RegisterListener(...)` at line ~4293+ (euls, manta, invoker, skillshot, glimpse, aim,
  armlet, lasthit...), and event hooks (OnNPCSpawned, OrderFilter, OnAbilityUsed, OnEntityHurt, DamageFilter...)
  that forward to the active mode.
- casting.lua: legacy spell-cast helpers (casterAbilityTarget/Position/Self/Notarget, evasionChecker*, one function per spell).
- events.lua, settings.lua, internal/ (barebones plumbing), utils.lua, utils/, json.lua.
- libraries/: gamemode_manager (mode registry), timebar, precache, creep_controller, tower_controller,
  notifications, place_picker, particle_message, announce_message, dota_database (DotaDB: reads Dota KV values),
  networking, timers, modifiers/ (custom modifiers, linked via LinkLuaModifier in gamemode.lua).
- gamemodes/<name>/<name>.lua: one folder per mode: dodge, timing, lasthit_training, aim_compet,
  dream_coil_escape, test_sandbox (tools only), template_mode (copy source for new modes).

## Quick answers
If a question about where something is can be answered from this section, ANSWER IMMEDIATELY from it.
Do not open or search files to double-check unless the user asks to edit or show code.
Full paths (relative to the repo root, use these exactly):
- Dodge spell list: `self.spellTable` in `dodge:Init()` in
  `game/dota_addons/training_polygon/scripts/vscripts/gamemodes/dodge/dodge.lua` (lines ~10-88),
  keyed by dodge type (item_manta, plus aliases like puck_phase_shift = item_manta).
- Timing spell list: `self.spellTable` in `timing:Init()` in
  `game/dota_addons/training_polygon/scripts/vscripts/gamemodes/timing/timing.lua` (starts ~line 17).
- `.../gamemodes/dodge/dodge_skills.lua` (59KB) is NOT a list. It holds one cast-handler function per spell:
  `dodge:<spell_name>(entry)`. Open it only to change one spell: grep `function dodge:<spell_name>`, read ~30 lines.
- `.../gamemodes/timing/timing_timebar_skills.lua`: one `timing:timebar_<spell_name>()` function per spell, same rule.
- Other tables in dodge.lua Init: unitTable, modifierTable (unused), dodgeCastPointTable.
- Cast helpers in dodge.lua: doTargetCast, doPointCast, doNoTargetCast, doSelfCast, doCast.
- Spell table is sent to the UI by `dodge:SendSpellTable()` as event `dodge_spell_table`.
- Reading files: search with search_files first, then read only a line range around the match.

Other game/ data: `scripts/npc/` (npc_units_custom.txt, npc_abilities_override.txt, npc_items_custom.txt),
`resource/addon_english.txt` (+ russian, schinese, german, turkish, romanian) for strings, `addoninfo.txt`
(maps: `template_map` = legacy/default, `dota` = new WIP), `maps/`, `particles/`, `soundevents/`.

## How a new-style mode works
1. Mode is a class file `gamemodes/<name>/<name>.lua`: Init, Prepare(args), StartGame, Deactivate,
   PrepareDeactivate, plus optional hooks (OnNPCSpawned, OrderFilter, ModifierGained, DamageFilter,
   OnAbilityUsed, OnEntityKilled, OnEntityHurt).
   Mode allso carries menu hud: `content\dota_addons\training_polygon\panorama\layout\custom_game\menu2snippets\gamemodes_hud\<name>\<name>.xml` for settings before launch,
   and in-game hud `content\dota_addons\training_polygon\panorama\layout\custom_game\gamemode_hud\<name>\<name>.xml`
2. File ends with `GamemodeManager:RegisterMode(name, class, type)` and is required in gamemode.lua.
3. Menu sends client event `activate_game_mode` with `gameModeName` -> GameMode:activateGameMode ->
   GamemodeManager:SetActiveGamemode -> mode:Prepare(args) -> precache -> StartGame.
4. StartGame sends `load_hud {name=...}` to the client. Deactivate sends `clear_hud` / `show_main_menu`.
   Only used for loading hud for gamemodes placed in gamemodes folders in content directory, do not use it for any other hud.
5. gamemode.lua hooks forward events to `GamemodeManager.activeGameMode` if the mode defines them.

To add a mode: run `create_gamemode.bat` (calls New-GameMode.ps1, copies template_mode lua/xml/js/css, renaming).
Then add `require('gamemodes/<name>/<name>')` in gamemode.lua and add strings to resource/addon_*.txt.

## Panorama UI (all under content/dota_addons/training_polygon/panorama/)
- layout/custom_game/*.xml, scripts/custom_game/*.js, styles/custom_game/*.css
- Main menu: mainmenu_v2.xml/.js and menu2snippets/main_menu/ (home_page, play_menu, settings_page).
  mainmenu.xml / eul / manta / armlet are the old menu and old trainers.
- Per mode, two folders named after the mode:
  - menu2snippets/gamemodes_hud/<mode>/: the mode's settings page in the menu (e.g. dodge.xml + dodge_type.xml)
  - gamemode_hud/<mode>/: the in-game HUD
  - dynamic_hud_loader.xml/.js loads the HUD when `load_hud` arrives.
- Shared widgets: menu2snippets/ (hero_picker, mode_button, number_switcher), timebar.xml, notifications.xml,
  place_picker.xml, precache_modal.xml, debug_panel.xml.

## Run / test
- Setup junctions once: see CONTRIBUTING.md (`mklink /j` for both game/ and content/).
- In Dota 2 Tools console: `dota_launch_custom_game training_polygon dota` (new) or `... template_map` (legacy).
- Dev console commands: tp_test, tp_test2, tp_hide_menu, tp_show_menu, tp_print_place, tp_start_glimpse.

## Gitignored (do not commit): dev_secret.lua, CLAUDE.md, .claude/, *.vpk, *_c, *.sqlite3, tools_*.bin

## Visual Design Guidelines (Panorama CSS)

### Primary Colors
- **Background dark**: `#18181A` (main container), `#101115` → `#0E0F11` gradient (side bars/buttons)
- **Accent cyan**: `#9CDBEE` → `#FFFFFF` gradient (text, hover effects)
  - Key stops: `#B4D4DE`, `#C1E1EB`, `#CBE8F1`, `#BCDCE6`, `#A8D0DC`, `#D0E5EB`
- **Hover accent**: `#ADD9E6` (cyan-blue)
- **Selected/active bg**: `#FFFFFF` → `#8EBDCB` gradient
- **Text**: `#FFFFFF` (default), `#7d8688` (secondary), `#D1B560` (version/status)
- **Status colors**: `#db0028` (offline/error), `#36ab00` (online/success)

### Gradients
- **Main button gradient**: `linear(0% 0%, 0% 100%), from(#101115) to(#0E0F11)`
- **Selected button gradient**: `linear(0% 0%, 0% 100%), from(#FFFFFF) to(#8EBDCB)`
- **Text gradient**: `linear(10% 120%, 0% 0%), from(#9CDBEE) to(#FFFFFF)` with stops at 0.12, 0.31, 0.4, 0.52, 0.79

### Typography
- **Title font**: `Reaver,Goudy Trajan Medium,FZKai-Z03,TH Sarabun New,YDYGO 540`
- **Body font**: `RadianceM`
- **Text transform**: `uppercase` for buttons/labels
- **Font weights**: `semi-bold` for headers, `thin` for secondary text

### Effects
- **Noise texture**: Applied to backgrounds via `file://{images}/custom_game/noise.png`
- **Box shadows**: `#000000 0px 0px 12px` (buttons), `#5FA5BA26 0px 0px 18px 0px` (selected)
- **Border on hover**: `1px solid #ADD9E6`
- **Saturation**: Disabled (`0`) for muted elements, `1` for active
- **Scale on hover**: `pre-transform-scale2d: 1.05`

### Common UI Patterns
- Buttons have 200ms transitions with `ease-in-out` timing
- Checked checkboxes use cyan gradient background with black border
- Number switchers and small buttons follow the same hover/active states
- Labels are centered, uppercase, with gradient text


