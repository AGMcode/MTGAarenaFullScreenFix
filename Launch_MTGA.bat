@echo off
REM Launch MTG Arena through Steam and start the fullscreen monitor
REM Adjust the Steam path and App ID if needed

echo Starting MTG Arena...
start "" "C:\Program Files (x86)\Steam\steam.exe" -applaunch 2141910

echo Waiting for game to initialize...
timeout /t 15 /nobreak

echo Starting fullscreen monitor...
powershell -ExecutionPolicy Bypass -File "%~dp0MTGArenaFullscreenFix.ps1"
