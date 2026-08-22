@echo off
setlocal

echo ==========================================
echo   training polygon - New Gamemode Setup
echo ==========================================
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

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0New-GameMode.ps1" -NewName "%GAMEMODE_NAME%"

echo.
pause