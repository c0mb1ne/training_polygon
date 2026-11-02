@echo off
setlocal

set "MODES_DIR=%~dp0game\dota_addons\training_polygon\scripts\vscripts\gamemodes"

echo ==========================================
echo   training polygon - Gamemode Manager
echo ==========================================
echo.
echo   [1] Create new gamemode (from template_mode)
echo   [2] Clone existing gamemode
echo   [3] Delete gamemode
echo   [0] Exit
echo.

set /p CHOICE="Choose an action [1-3]: "

if "%CHOICE%"=="1" goto CREATE
if "%CHOICE%"=="2" goto CLONE
if "%CHOICE%"=="3" goto DELETE
if "%CHOICE%"=="0" exit /b 0

echo Unknown choice. Aborting.
pause
exit /b 1

:CREATE
echo.
set /p GAMEMODE_NAME="Enter new gamemode class name (PascalCase, e.g. CaptureThePoint): "
if "%GAMEMODE_NAME%"=="" (
    echo No name entered. Aborting.
    pause
    exit /b 1
)
echo.
echo Generating files for "%GAMEMODE_NAME%"...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0New-GameMode.ps1" -Action create -NewName "%GAMEMODE_NAME%"
goto END

:CLONE
echo.
echo Existing gamemodes:
for /d %%D in ("%MODES_DIR%\*") do echo   - %%~nxD
echo.
set /p SOURCE_NAME="Enter source gamemode to clone (e.g. dodge): "
if "%SOURCE_NAME%"=="" (
    echo No source entered. Aborting.
    pause
    exit /b 1
)
set /p GAMEMODE_NAME="Enter new gamemode class name (PascalCase, e.g. CaptureThePoint): "
if "%GAMEMODE_NAME%"=="" (
    echo No name entered. Aborting.
    pause
    exit /b 1
)
echo.
echo Cloning "%SOURCE_NAME%" into "%GAMEMODE_NAME%"...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0New-GameMode.ps1" -Action clone -SourceName "%SOURCE_NAME%" -NewName "%GAMEMODE_NAME%"
goto END

:DELETE
echo.
echo Existing gamemodes:
for /d %%D in ("%MODES_DIR%\*") do echo   - %%~nxD
echo.
set /p GAMEMODE_NAME="Enter gamemode to delete (e.g. my_mode): "
if "%GAMEMODE_NAME%"=="" (
    echo No name entered. Aborting.
    pause
    exit /b 1
)
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0New-GameMode.ps1" -Action delete -NewName "%GAMEMODE_NAME%"
goto END

:END
echo.
pause
