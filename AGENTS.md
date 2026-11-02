# AGENTS.md — training_polygon

Guidance for AI coding agents working in this repository. Read this fully before
editing; the project has no conventional build system, no package manager and no
automated tests, so most "obvious" assumptions do not apply here.

## Project overview

**Training Polygon** is a single-player Dota 2 custom game (addon) — a practice
tool for grinding mechanics: last-hitting, spell dodging, cast-timing, aim and
dream-coil escape drills, plus legacy exercises (eul's, manta, invoker combos,
skillshot, glimpse, armlet toggling). Published on the Steam Workshop
(id `813598504`), 1M+ subscribers. License: MIT.

The codebase has **two parallel generations** running side by side:

- **Legacy** — active on the `template_map` map (the default). Old menu
  (`mainmenu.xml`) and old trainers implemented as global functions in
  `gamemode.lua` / `casting.lua`. Selected when `LEGACY_SWITCH = 1`.
- **New (WIP)** — active on the `dota` map. New menu (`mainmenu_v2.xml`) and
  modular gamemodes registered in `libraries/gamemode_manager.lua`. Selected
  when `LEGACY_SWITCH = 0` (see the top of `gamemode.lua`).

Both generations share the same `GameMode` class and the same UI sources;
which one runs is decided by `GetMapName()` at `gamemode.lua:13`.

**Current focus — refactoring (read first):** the legacy trainers
(euls, manta, invoker, skillshot, glimpse, armlet, alchemist, ...) are being
ported one by one out of `gamemode.lua` / `casting.lua` into the new
`gamemodes/<name>/` structure. Until a given legacy mode is fully moved,
`gamemode.lua` and `casting.lua` are **frozen — do not edit them at all**,
not for features, fixes or cleanup. If a task seems to require touching them,
stop and ask the user first. All new work happens inside the new structure:
mode code in `gamemodes/<name>/<name>.lua`, UI in the two per-mode panorama
folders.

## Repository layout

The repo mirrors Dota 2's two addon directories and is linked into the Dota
install with junctions/symlinks (one-time setup, see `CONTRIBUTING.md`):

```
game/dota_addons/training_polygon/     server logic + compiled resources
content/dota_addons/training_polygon/  UI sources, maps, materials, sounds
```

- `game/.../scripts/vscripts/` — all server-side Lua (see below).
- `game/.../scripts/npc/` — KV data files: `npc_units_custom.txt`,
  `npc_abilities_custom.txt`, `npc_abilities_override.txt`,
  `npc_heroes_custom.txt`, `npc_items_custom.txt`.
- `game/.../resource/` — localization `addon_<lang>.txt` (english, russian,
  schinese, german, turkish, romanian), `flash3/` (UI images), `overviews/`.
- `game/.../addoninfo.txt` — addon manifest: maps `template_map` (default) and
  `dota`, `MinPlayers = MaxPlayers = 1`.
- `game/.../panorama/` — **compiled** Panorama output (`*_c` files). Never edit;
  Workshop Tools generates it from `content/`.
- `content/.../panorama/` — Panorama sources (XML/JS/CSS). Only edit here.
- `content/.../maps/` — Hammer maps: `template_map.vmap`, `piggy.vmap`.
- `content/.../particles/`, `soundevents/`, `sounds/`, `materials/`,
  `resource/overviews/` — assets; mirrored in `game/`.
- Root: `create_gamemode.bat` + `New-GameMode.ps1` (new-mode scaffolding),
  `docs/gifs/` (README demo images), `todo.md` (informal pending-features list).

## Technology stack

- **Server:** Lua on Dota 2 VScript, built on a trimmed "Barebones" framework
  (`internal/`). There is no Lua build step or linter.
- **Client UI:** Valve Panorama — XML layouts, JavaScript (Panorama's JS API,
  not a browser), CSS. Valve's tools compile these to `*.vxml_c / *.vjs_c /
  *.vcss_c` automatically when running in Tools mode.
- **Data:** Dota KV/KV3 text files for units/abilities/items and localization.
- **No `package.json`, `pyproject.toml`, `Cargo.toml` or similar exists.** The
  only "build" is Dota 2 Workshop Tools asset compilation, and the only codegen
  is `New-GameMode.ps1` (PowerShell, Windows).

## Server-side architecture (`scripts/vscripts/`)

- `addon_game_mode.lua` — entry point. `Precache(context)` declares shared
  sounds/particles/models; `Activate()` creates `GameRules.GameMode = GameMode()`
  and calls `GameMode:_InitGameMode()`.
- `gamemode.lua` (~7.9K lines, largest file) — the `GameMode` class. Top of file
  holds `TP_VERSION` (**bump on every Workshop push** — there is a bug where the
  old version stays playable, so the version must be visible on screenshots; the
  menu displays it via the `get_version` / `version_to_ui` events), the
  `LEGACY_SWITCH` logic, and the `require` list for all libraries and gamemodes
  (the `--gamemodes:` block, ~line 59). It also contains:
  - the `activate_game_mode` listener → `GamemodeManager:SetActiveGamemode`
    → `mode:Prepare(args)` (~line 67),
  - event hooks (`OnNPCSpawned`, `OrderFilter`, `ModifierGained`,
    `DamageFilter`, `OnAbilityUsed`, `OnEntityKilled`, `OnEntityHurt`,
    `OnNonPlayerUsedAbility`, `AbilityTuning`) that forward to
    `GamemodeManager.activeGameMode` **only if the active mode defines them** —
    this is how modes hook game events without touching gamemode.lua,
  - the **legacy trainers** as global functions with
    `CustomGameEventManager:RegisterListener(...)` (~line 4294 onward: euls,
    manta, invoker, skillshot, glimpse, armlet, alchemist, ...),
  - dev console commands (~line 201): `tp_test`, `tp_test2`, `tp_hide_menu`,
    `tp_show_menu`, `tp_print_place`, `tp_start_glimpse`.
- `casting.lua` (~5.7K lines) — legacy spell-cast helpers, one function per
  spell (e.g. `casterAbilityTarget`, `evasionChecker*`, per-spell wrappers).
- `events.lua`, `settings.lua` (game-rule constants), `utils.lua`,
  `json.lua`, `utils/` (misc helpers, e.g. `item_topor*` used by aim mode).
- `internal/` — Barebones plumbing (`events.lua`, `gamemode.lua`, `util.lua`);
  the comment at the top of gamemode.lua says only the timer library is really
  wanted from Barebones.
- `libraries/` — shared singletons: `gamemode_manager` (mode registry + the
  `get_gamemodes_for_menu` listener), `timers`, `precache` (unit/particle
  precache with a completion callback — modes call `precache:doPrecache(cb)`
  in `Prepare` and start the game in `cb`), `timebar`, `notifications`,
  `place_picker`, `particle_message`, `announce_message`, `creep_controller`,
  `tower_controller`, `dota_database` (KV reader), `networking` (leaderboard
  server comms), `main_menu_communicator`, `ping_reader`, `combo_tracker`,
  `action_logging`, `debug_var`, `user_config`, `modifiers/` (custom
  modifiers).
- `gamemodes/<name>/<name>.lua` — one folder per new-style mode:
  - `dodge/` — `dodge.lua` + `dodge_skills.lua` (~1.1K lines; one cast handler
    per spell, `function dodge:<spell_name>(entry)`).
  - `timing/` — `timing.lua` + `timing_timebar_skills.lua` (~735 lines; one
    `timing:timebar_<spell_name>()` per spell).
  - `lasthit_training/` — main file + `lasthit_training_bot_balance.lua` +
    `modifier_attack_tracker.lua`.
  - `aim_compet/`, `dream_coil_escape/` — single-file modes.
  - `test_sandbox/` — dev-only mode, visible in Tools mode.
  - `template_mode/` — copy source for new modes (see below).

### Mode lifecycle (new-style modes)

1. Mode file defines `if <name> == nil then <name> = class({}) end`, sets
   `self.name` / `self.type` (`"sandbox"` or `"compet"`) in `Init()`, and ends
   with `<name>:Init()` + `GamemodeManager:RegisterMode(<name>.name, <name>,
   <name>.type)`.
2. Menu client sends `activate_game_mode { gameModeName, ... }` →
   `GameMode:activateGameMode` → `GamemodeManager:SetActiveGamemode` →
   `mode:Prepare(args)`.
3. `Prepare` builds the precache list and calls `precache:doPrecache(cb)`;
   `cb` calls `mode:StartGame(args)`.
4. `StartGame` sets up units/abilities and sends
   `CustomGameEventManager:Send_ServerToAllClients("load_hud", {name=self.name})`
   so the client loads the in-game HUD. It usually also sends a
   `<mode>_spell_table` event with `self.spellTable`.
5. Deactivation: `PrepareDeactivate` / `Deactivate` clean up and send
   `clear_hud` / `show_main_menu`.
6. Optional event hooks: `OnNPCSpawned`, `OrderFilter`, `ModifierGained`,
   `DamageFilter`, `OnAbilityUsed`, `OnEntityKilled`, `OnEntityHurt`,
   `OnNonPlayerUsedAbility`, `AbilityTuning`.

Key per-mode data tables (see `dodge:Init()` / `timing:Init()`): `spellTable`
(list of castable spells keyed by dodge/timing type; entries carry
`spell_name`, `hero_name`, `level`, `aghs`, `shard`, `is_ability`,
`cast_func`/`need_helper`), `unitTable` (dodge type → player hero), and mode
variants aliasing the shared `item_manta`/`item_cyclone` list.

### Adding a new gamemode

1. Run `create_gamemode.bat` (calls `New-GameMode.ps1`): copies `template_mode`
   across all seven locations (Lua folder + menu-settings XML/CSS/JS + in-game
   HUD XML/CSS/JS under panorama), renaming files and contents. The bat also
   offers **clone** (copy any existing mode instead of the template) and
   **delete** (remove a mode's seven folders, with confirmation; it refuses
   to delete `template_mode`). After delete/clone, hand-edit the leftovers the
   script prints (the `require` in `gamemode.lua`, localization tokens).
2. Add `require('gamemodes/<name>/<name>')` to the `--gamemodes:` block in
   `gamemode.lua`.
3. Add UI strings to `resource/addon_*.txt` (all six languages, or at least
   english + russian).

## Client UI architecture (`content/.../panorama/`)

Sources live under `layout/custom_game/`, `scripts/custom_game/`,
`styles/custom_game/` (XML / JS / CSS respectively). `custom_ui_manifest.xml`
registers the always-on HUD elements, notably `dynamic_hud_loader.xml` and
`mainmenu_v2.xml`.

- **New menu:** `mainmenu_v2.xml/js` + `menu2snippets/main_menu/`
  (`home_page`, `play_menu`, `settings_page`). `play_menu.js` sends
  `get_gamemodes_for_menu` and draws one button per entry from the
  `gamemodes_to_draw` event, splitting by `type` into sandbox vs competitive
  containers. `menu2snippets/mode_button.js` loads the mode's settings page
  from `menu2snippets/gamemodes_hud/<mode>/<mode>.xml` and eventually sends
  `activate_game_mode`.
- **Legacy menu/trainers:** `mainmenu.xml/js`, `eul.xml/js`, `manta.xml/js`,
  `armlet.xml/js` — paired with the legacy listeners in `gamemode.lua`.
- **Per-mode UI — two XMLs, both loaded dynamically at runtime** (never
  register per-mode layouts in `custom_ui_manifest.xml`):
  - `menu2snippets/gamemodes_hud/<mode>/menu_<mode>.xml` — the mode's settings page
    inside the menu (core files carry a `menu_` prefix, e.g. `menu_dodge.xml` +
    `menu_dodge.js/css`, to tell them apart from the in-game HUD; extra snippets like
    `dodge_type.xml` stay unprefixed); loaded on demand when
    the mode's button is picked (`menu2snippets/mode_button.js`).
  - `gamemode_hud/<mode>/` — the in-game HUD (`<mode>.xml` + `<mode>.js` +
    `<mode>.css`); `dynamic_hud_loader.js` listens for `load_hud {name}` /
    `clear_hud` and loads
    `layout/custom_game/gamemode_hud/<name>/<name>.xml` into its container.
- **Shared widgets** (reuse these instead of reinventing): `hero_picker`,
  `mode_button`, `number_switcher` (menu2snippets), `timebar`, `notifications`,
  `place_picker`, `precache_modal`, `debug_panel`, `announce_message`,
  `ping_reader`, `graph`, `combo_tracker`, `action_logging`.
- Localization: XML/JS reference tokens like `#trainingEnd`; add them to
  `game/.../resource/addon_<lang>.txt`.

## Build, run, test

- **There are no automated tests.** Verification = launching the addon in
  Dota 2 Workshop Tools and playing the mode.
- One-time setup: link the repo into the Dota install (`mklink /j` junctions on
  Windows, `ln -s` elsewhere) — full instructions in `CONTRIBUTING.md`.
- Launch from the Tools console:
  - `dota_launch_custom_game training_polygon template_map` (legacy/default)
  - `dota_launch_custom_game training_polygon dota` (new WIP)
- Lua changes take effect on map restart; Panorama sources are recompiled by
  the tools (a `_c` file refresh may be needed).
- `test_sandbox` mode and the `tp_*` console commands exist for poking at
  things in Tools mode.
- Workshop release: bump `TP_VERSION` in `gamemode.lua` (the menu version label
  and the update-available check rely on it) and publish through Workshop Tools.

## Development conventions and gotchas

- **Never read the giant files in full.** `gamemode.lua` (~7.9K lines),
  `casting.lua` (~5.7K lines), `dodge_skills.lua` (~1.1K lines) and
  `timing_timebar_skills.lua` (~735 lines) should be searched, not read: grep
  for `function <name>` and read only a small range around the match.
- **Never edit compiled or generated files:** `*_c` (compiled Panorama),
  `*.vpk`, `tools_*` caches, `server_log.txt`, `demoheader.tmp`. Edit Panorama
  sources under `content/` only.
- **`gamemode.lua` / `casting.lua` are frozen during the refactor** (see
  "Current focus" above): no edits, no matter how small, until the legacy
  trainers are ported into `gamemodes/<mode>/`. All new work goes into the new
  structure; make the smallest change that works there.
- Keep the mode's `self.name` consistent everywhere — it is the key used for
  `RegisterMode`, HUD loading (`gamemode_hud/<name>/<name>.xml`), and the
  settings page path.
- Lua style in this repo: global singleton objects via `class({})`, informal
  English comments with `--TODO:` markers, `print`/`DebugPrint` for logging
  (visible in the Tools console), no linting. Match the surrounding file.
- Windows-first workflow (batch + PowerShell scaffolding); the game itself runs
  on the Dota 2 (Source 2) runtime.
- `todo.md` at the repo root tracks pending feature ideas; check it before
  starting new work.

## Security considerations

- `dev_secret.lua` (gitignored) holds local dev secrets — never commit it or
  copy its contents anywhere.
- `CMB_SERVER` / `DEVBUG_SERVER` URLs at the top of `gamemode.lua` point at the
  author's leaderboard/stats backend; `libraries/networking.lua` talks to it.
  Don't add new external calls or exfiltrate data; keep any server
  communication going through the existing `networking` class.
- The addon is single-player and client-authoritative in places by design
  (custom-game event payloads from the menu are trusted); still, validate
  event payloads server-side in new modes the way `dodge:Prepare` does.
