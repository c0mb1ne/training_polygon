# Contributing Setup Guide

This addon's repo is structured with two top-level folders — `game` and `content` — that mirror the two locations Dota 2 expects addon files to live in:

```
training_polygon/
├── game/dota_addons/training_polygon/
└── content/dota_addons/training_polygon/
```

Since Dota 2 needs these as separate folders under `dota 2 beta/game/dota_addons/` and `dota 2 beta/content/dota_addons/`, we use directory junctions (`mklink /j`) to link the repo into both locations without duplicating or copying files. This means you can just edit files in your cloned repo, and Dota 2 will pick up the changes directly — no manual copying needed.

## Prerequisites

- Steam with Dota 2 (and Dota 2 Workshop Tools) installed
- Git installed

## 1. Find your Dota 2 `dota_addons` folders

The path depends entirely on where **you** installed Steam and Dota 2 — it's different for everyone, so don't copy the paths below literally. Find yours first:

1. In Steam, right-click **Dota 2** → **Properties** → **Installed Files** → **Browse...**. This opens the `dota 2 beta` folder.
2. Inside it you need two subfolders (create them if they don't exist yet):
   - `dota 2 beta\game\dota_addons\`
   - `dota 2 beta\content\dota_addons\`

Some examples of what the full path might look like, just for illustration:
- Dota installed on the same drive as Steam: `D:\Program Files\Steam\steamapps\common\dota 2 beta\game\dota_addons`
- Dota installed on a separate Steam Library drive: `Z:\SteamLibrary\steamapps\common\dota 2 beta\game\dota_addons`

Everywhere below, `<DOTA_PATH>` means `...\dota 2 beta` from **your** setup, and `<REPO_PATH>` means wherever you cloned this repo.

## 2. Clone the repository

Clone the repo to a location of your choice — **not** inside the Dota 2 folder itself, e.g.:

```
D:\projects\training_polygon
```

## 3. Link the repo into Dota 2

### Windows

Directory junctions (`mklink /j`) are a Windows/NTFS feature — this is the same approach used in the original setup. Open **Command Prompt**:

```bat
cd "<DOTA_PATH>\game\dota_addons"
mklink /j training_polygon "<REPO_PATH>\game\dota_addons\training_polygon"

cd "<DOTA_PATH>\content\dota_addons"
mklink /j training_polygon "<REPO_PATH>\content\dota_addons\training_polygon"
```

### Linux / macOS

Yes, this works fine — you just use a symbolic link instead of a junction, since junctions don't exist outside NTFS:

```bash
ln -s "<REPO_PATH>/game/dota_addons/training_polygon" "<DOTA_PATH>/game/dota_addons/training_polygon"
ln -s "<REPO_PATH>/content/dota_addons/training_polygon" "<DOTA_PATH>/content/dota_addons/training_polygon"
```

On a native Linux Steam install, `<DOTA_PATH>` is typically something like `~/.local/share/Steam/steamapps/common/dota 2 beta` (or `~/.steam/steam/steamapps/common/dota 2 beta`), but check via Steam's **Properties → Installed Files → Browse...** just like on Windows.

## 4. Verify

- Open `<DOTA_PATH>\game\dota_addons\` and `<DOTA_PATH>\content\dota_addons\` (or the equivalent `/` paths on Linux/macOS) — you should see a `training_polygon` entry in each, shown as a link/junction rather than a regular folder.
- Launch **Dota 2**, open the **Workshop Tools** (comes as DLC for Dota), and confirm `training_polygon` shows up and loads correctly.

## 5. Launching in Tools mode

Once you're in Tools mode, open the console and use `dota_launch_custom_game` to launch the addon:

- Legacy version:
  ```
  dota_launch_custom_game training_polygon template_map
  ```
- New work-in-progress version:
  ```
  dota_launch_custom_game training_polygon dota
  ```

## Notes

- If a `training_polygon` folder already exists in either `dota_addons` directory (not as a link), delete or rename it first — both `mklink` and `ln -s` will fail if the target name is already taken.
- To remove a link later (e.g. to relink elsewhere), just delete the `training_polygon` entry from `dota_addons`. This removes the link only, not your repo files:
  - Windows: `rmdir training_polygon`
  - Linux/macOS: `rm training_polygon`
- You only need to do this setup once per machine. After that, just `git pull` inside your cloned repo and Dota 2 will always see the latest files.
