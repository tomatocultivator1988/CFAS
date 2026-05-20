@echo off
title Test CFAS Launcher (Encoding Fixed)
color 0A

echo ========================================
echo Testing CFAS Launcher
echo ========================================
echo.
echo This will test if the launcher script
echo runs without encoding errors.
echo.
echo Press any key to start the test...
pause > nul
echo.

cd /d "%~dp0"

echo Running launcher script...
echo.

powershell.exe -ExecutionPolicy Bypass -NoExit -File "%~dp0CFAS-System-Launcher.ps1"

echo.
echo Test complete!
pause
