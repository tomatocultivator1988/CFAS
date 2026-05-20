@echo off
title Test CFAS GUI
color 0B

echo ========================================
echo Testing CFAS Launcher GUI
echo ========================================
echo.
echo This will test if the GUI opens...
echo.
echo If you see a window with CFAS logo, it works!
echo.
pause

cd /d "%~dp0"

powershell.exe -ExecutionPolicy Bypass -NoExit -File "%~dp0CFAS-System-Launcher.ps1"

echo.
echo ========================================
echo Test complete!
echo ========================================
pause
