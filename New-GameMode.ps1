<#
    New-GameMode.ps1
    ------------------
    Copies a template gamemode's lua/js/css/layout files into a new gamemode,
    renaming files and replacing the template name inside file contents.

    You normally don't call this directly - create_gamemode.bat calls it for you.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$NewName
)

# =========================================================================
#  CONFIG - edit these paths/names to match your project structure once,
#  then never touch them again.
# =========================================================================

# Root of your addon - auto-detected as the folder this script lives in.
# Works as long as New-GameMode.ps1 sits in the repo root alongside create_gamemode.bat,
# and "game\" / "content\" are direct subfolders of the repo root.
$AddonRoot = $PSScriptRoot

# Name used inside the existing template files - the Lua class name (e.g. "dodge", "timing"),
# and also used for panorama file/id names. Everything is one consistent snake_case name.
$TemplateName = "template_mode"

# Source template file locations (relative to $AddonRoot) - files that live on their own,
# outside the per-mode HUD folder.
$TemplateFiles = @(
    "game\dota_addons\training_polygon\scripts\vscripts\gamemodes\$TemplateName.lua"
)

# Source template FOLDER locations (relative to $AddonRoot) - for gamemodes with multiple
# HUD files per mode: the main .xml/.css/.js plus any extra snippet files
# (e.g. template_mode_type.xml, template_mode_entry.xml), all living together in
# content\...\gamemodes_hud\template_mode\
# The whole folder gets copied, renamed, and every file inside gets its name/contents updated.
$TemplateFolders = @(
    "content\dota_addons\training_polygon\panorama\layout\custom_game\menu2snippets\gamemodes_hud\$TemplateName",
    "content\dota_addons\training_polygon\panorama\styles\custom_game\menu2snippets\gamemodes_hud\$TemplateName",
    "content\dota_addons\training_polygon\panorama\scripts\custom_game\menu2snippets\gamemodes_hud\$TemplateName",
    "content\dota_addons\training_polygon\panorama\layout\custom_game\gamemode_hud\$TemplateName",
    "content\dota_addons\training_polygon\panorama\styles\custom_game\gamemode_hud\$TemplateName",
    "content\dota_addons\training_polygon\panorama\scripts\custom_game\gamemode_hud\$TemplateName"
)

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

$NewSnake = ToSnakeCase $NewName

if ([string]::IsNullOrWhiteSpace($NewSnake)) {
    Write-Host "Could not derive a valid name from '$NewName'. Aborting." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Generating new gamemode: $NewSnake" -ForegroundColor Cyan
Write-Host ""

function Copy-TemplateFile([string]$srcPath, [string]$templateName, [string]$newName) {
    if (-not (Test-Path $srcPath)) {
        Write-Host "  [SKIP] Template file not found: $srcPath" -ForegroundColor Yellow
        return $null
    }

    $destPath = $srcPath -replace [regex]::Escape($templateName), $newName

    if (Test-Path $destPath) {
        Write-Host "  [SKIP] Destination already exists: $destPath" -ForegroundColor Yellow
        return $null
    }

    $content = Get-Content -Raw -LiteralPath $srcPath
    $content = $content -replace [regex]::Escape($templateName), $newName

    $destDir = Split-Path $destPath -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    Set-Content -LiteralPath $destPath -Value $content -NoNewline
    Write-Host "  [OK] Created: $destPath" -ForegroundColor Green
    return $destPath
}

function Copy-TemplateFolder([string]$srcFolder, [string]$templateName, [string]$newName) {
    $created = @()

    if (-not (Test-Path $srcFolder -PathType Container)) {
        Write-Host "  [SKIP] Template folder not found: $srcFolder" -ForegroundColor Yellow
        return $created
    }

    $destFolder = $srcFolder -replace [regex]::Escape($templateName), $newName

    if (Test-Path $destFolder) {
        Write-Host "  [SKIP] Destination folder already exists: $destFolder" -ForegroundColor Yellow
        return $created
    }

    $files = Get-ChildItem -LiteralPath $srcFolder -Recurse -File
    foreach ($file in $files) {
        # Path of this file relative to the template folder root
        $relative = $file.FullName.Substring($srcFolder.Length).TrimStart('\')
        # Rename any template-name occurrences in the relative path too (subfolders/filenames)
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
        Write-Host "  [WARN] Template folder was empty: $srcFolder" -ForegroundColor Yellow
    }

    return $created
}

$createdFiles = @()

foreach ($relativePath in $TemplateFiles) {
    $srcPath = Join-Path $AddonRoot $relativePath
    $result = Copy-TemplateFile -srcPath $srcPath -templateName $TemplateName -newName $NewSnake
    if ($result) { $createdFiles += $result }
}

foreach ($relativeFolder in $TemplateFolders) {
    $srcFolder = Join-Path $AddonRoot $relativeFolder
    $results = Copy-TemplateFolder -srcFolder $srcFolder -templateName $TemplateName -newName $NewSnake
    $createdFiles += $results
}

Write-Host ""
if ($createdFiles.Count -eq 0) {
    Write-Host "No files were created. Check the CONFIG section paths in New-GameMode.ps1." -ForegroundColor Red
} else {
    Write-Host "Done. $($createdFiles.Count) file(s) created for gamemode '$NewSnake'." -ForegroundColor Cyan
    Write-Host "Don't forget to:"
    Write-Host "  - Register the new mode in your gamemode.lua by require('gamemodes/your_mode')"
}