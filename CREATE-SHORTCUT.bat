@echo off
title Create CFAS Desktop Shortcut
color 0A

echo ========================================
echo Creating CFAS Desktop Shortcut
echo ========================================
echo.

cd /d "%~dp0"

powershell.exe -ExecutionPolicy Bypass -NoExit -File "%~dp0Create-Shortcut-Helper.ps1"
