<#
    New-GameMode.ps1
    ------------------
    Manages gamemode file structures:
      create - copies template_mode into a new gamemode
      clone  - copies ANY existing gamemode into a new gamemode
      delete - removes a gamemode's folders from all locations

    Copies/renames files and replaces the source mode name inside file contents.

    You normally don't call this directly - create_gamemode.bat calls it for you.
#>

param(
    [ValidateSet('create', 'clone', 'delete')]
    [string]$Action = 'create',

    [string]$NewName,

    # Source mode for 'clone' (defaults to the template for 'create').
    [string]$SourceName,

    # Skip the interactive confirmation for 'delete' (used by tests/scripts).
    [switch]$Force
)

# =========================================================================
#  CONFIG - edit these paths/names to match your project structure once,
#  then never touch them again.
# =========================================================================

# Root of your addon - auto-detected as the folder this script lives in.
# Works as long as New-GameMode.ps1 sits in the repo root alongside create_gamemode.bat,
# and "game\" / "content\" are direct subfolders of the repo root.
$AddonRoot = $PSScriptRoot

# Name of the template mode - the copy source for 'create', and the one mode
# that 'delete' refuses to touch.
$TemplateName = "template_mode"

# Every per-mode folder, relative to $AddonRoot. Used by all actions.
# Naming convention: the mode's CORE menu files carry a "menu_" prefix
# (menu_<mode>.xml/.js/.css under menu2snippets\gamemodes_hud\<mode>\) so they can't be
# confused with the in-game HUD files of the same name under gamemode_hud\<mode>\.
# Extra snippet files (e.g. <mode>_type.xml) stay unprefixed - they exist only on the menu side.
function Get-ModeFolders([string]$mode) {
    return @(
        "game\dota_addons\training_polygon\scripts\vscripts\gamemodes\$mode",
        "content\dota_addons\training_polygon\panorama\layout\custom_game\menu2snippets\gamemodes_hud\$mode",
        "content\dota_addons\training_polygon\panorama\styles\custom_game\menu2snippets\gamemodes_hud\$mode",
        "content\dota_addons\training_polygon\panorama\scripts\custom_game\menu2snippets\gamemodes_hud\$mode",
        "content\dota_addons\training_polygon\panorama\layout\custom_game\gamemode_hud\$mode",
        "content\dota_addons\training_polygon\panorama\styles\custom_game\gamemode_hud\$mode",
        "content\dota_addons\training_polygon\panorama\scripts\custom_game\gamemode_hud\$mode"
    )
}

# =========================================================================
#  END CONFIG
# =========================================================================

function ToSnakeCase([string]$s) {
    # "My New Mode", "MyNewMode", "my-new-mode" -> "my_new_mode"
    $s = $s.Trim()
    # Insert underscore before capitals that follow a lowercase/digit (handles PascalCase/camelCase input)
    $s = [regex]::Replace($s, '(?<=[a-z0-9])(?=[A-Z])', '_')
    # Normalize spaces/dashes to underscores
    $s = $s -replace '[\s\-]+', '_'
    # Collapse repeated underscores
    $s = $s -replace '_+', '_'
    return $s.ToLower().Trim('_')
}

function Copy-TemplateFolder([string]$srcFolder, [string]$templateName, [string]$newName) {
    $created = @()

    if (-not (Test-Path $srcFolder -PathType Container)) {
        Write-Host "  [SKIP] Source folder not found: $srcFolder" -ForegroundColor Yellow
        return $created
    }

    $destFolder = $srcFolder -replace [regex]::Escape($templateName), $newName

    if (Test-Path $destFolder) {
        Write-Host "  [SKIP] Destination folder already exists: $destFolder" -ForegroundColor Yellow
        return $created
    }

    $files = Get-ChildItem -LiteralPath $srcFolder -Recurse -File
    foreach ($file in $files) {
        # Path of this file relative to the source folder root
        $relative = $file.FullName.Substring($srcFolder.Length).TrimStart('\')
        # Rename any source-name occurrences in the relative path too (subfolders/filenames)
        $relative = $relative -replace [regex]::Escape($templateName), $newName

        $destPath = Join-Path $destFolder $relative
        $destDir = Split-Path $destPath -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        $content = Get-Content -Raw -LiteralPath $file.FullName
        $content = $content -replace [regex]::Escape($templateName), $newName
        Set-Content -LiteralPath $destPath -Value $content -NoNewline

        Write-Host "  [OK] Created: $destPath" -ForegroundColor Green
        $created += $destPath
    }

    if ($files.Count -eq 0) {
        Write-Host "  [WARN] Source folder was empty: $srcFolder" -ForegroundColor Yellow
    }

    return $created
}

# -------------------------------------------------------------------------
#  DELETE
# -------------------------------------------------------------------------
function Remove-GameMode([string]$mode) {
    if ($mode -eq $TemplateName) {
        Write-Host "Refusing to delete '$TemplateName' - it is the copy source for new modes." -ForegroundColor Red
        exit 1
    }

    # Collect the mode's folders that actually exist
    $existing = @()
    foreach ($relativeFolder in (Get-ModeFolders $mode)) {
        $folder = Join-Path $AddonRoot $relativeFolder
        if (Test-Path $folder -PathType Container) {
            $existing += $folder
        }
    }

    if ($existing.Count -eq 0) {
        Write-Host "No folders found for gamemode '$mode'. Nothing to delete." -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    Write-Host "The following folders will be permanently deleted:" -ForegroundColor Yellow
    foreach ($folder in $existing) {
        $count = (Get-ChildItem -LiteralPath $folder -Recurse -File).Count
        Write-Host "  $folder  ($count file(s))"
    }

    if (-not $Force) {
        Write-Host ""
        $answer = Read-Host "Type the mode name '$mode' to confirm deletion"
        if ($answer -ne $mode) {
            Write-Host "Confirmation did not match. Aborting - nothing was deleted." -ForegroundColor Red
            exit 1
        }
    }

    $deletedFiles = 0
    foreach ($folder in $existing) {
        $deletedFiles += (Get-ChildItem -LiteralPath $folder -Recurse -File).Count
        Remove-Item -LiteralPath $folder -Recurse -Force
        Write-Host "  [OK] Deleted: $folder" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "Done. Deleted gamemode '$mode' ($deletedFiles file(s))." -ForegroundColor Cyan
    Write-Host "Don't forget to also remove by hand:"
    Write-Host "  - require('gamemodes/$mode/$mode') from the --gamemodes: block in gamemode.lua"
    Write-Host "  - the mode's localization tokens from resource/addon_*.txt"
}

# -------------------------------------------------------------------------
#  CREATE / CLONE
# -------------------------------------------------------------------------
function New-GameModeFromSource([string]$srcName, [string]$newName) {
    # Make sure the source mode exists somewhere before copying
    $sourceExists = $false
    foreach ($relativeFolder in (Get-ModeFolders $srcName)) {
        if (Test-Path (Join-Path $AddonRoot $relativeFolder) -PathType Container) {
            $sourceExists = $true
            break
        }
    }
    if (-not $sourceExists) {
        Write-Host "Source gamemode '$srcName' not found in any known location. Aborting." -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    Write-Host "Generating new gamemode: $newName (from '$srcName')" -ForegroundColor Cyan
    Write-Host ""

    $createdFiles = @()
    foreach ($relativeFolder in (Get-ModeFolders $srcName)) {
        $srcFolder = Join-Path $AddonRoot $relativeFolder
        $results = Copy-TemplateFolder -srcFolder $srcFolder -templateName $srcName -newName $newName
        $createdFiles += $results
    }

    Write-Host ""
    if ($createdFiles.Count -eq 0) {
        Write-Host "No files were created (destination may already exist)." -ForegroundColor Red
    } else {
        Write-Host "Done. $($createdFiles.Count) file(s) created for gamemode '$newName'." -ForegroundColor Cyan
        Write-Host "Don't forget to:"
        Write-Host "  - Register the new mode in your gamemode.lua by require('gamemodes/$newName/$newName')"
        Write-Host "  - Add the mode's localization tokens to resource/addon_*.txt"
    }
}

# -------------------------------------------------------------------------
#  MAIN
# -------------------------------------------------------------------------
switch ($Action) {
    'delete' {
        $mode = ToSnakeCase $NewName
        if ([string]::IsNullOrWhiteSpace($mode)) {
            Write-Host "Could not derive a valid name from '$NewName'. Aborting." -ForegroundColor Red
            exit 1
        }
        Remove-GameMode $mode
    }
    default {
        # 'create' clones the template; 'clone' clones the given source mode
        $src = if ($Action -eq 'clone' -and -not [string]::IsNullOrWhiteSpace($SourceName)) {
            ToSnakeCase $SourceName
        } else {
            $TemplateName
        }

        $new = ToSnakeCase $NewName
        if ([string]::IsNullOrWhiteSpace($new)) {
            Write-Host "Could not derive a valid name from '$NewName'. Aborting." -ForegroundColor Red
            exit 1
        }
        if ($new -eq $src) {
            Write-Host "New name '$new' is the same as the source mode. Aborting." -ForegroundColor Red
            exit 1
        }

        New-GameModeFromSource -srcName $src -newName $new
    }
}
