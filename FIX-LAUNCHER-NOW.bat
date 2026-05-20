@echo off
title CFAS Launcher - One-Click Fix
color 0B

echo ========================================
echo CFAS Launcher - One-Click Fix
echo ========================================
echo.
echo This will fix the terminal auto-closing issue.
echo.
echo What this does:
echo   1. Test if fixed files exist
echo   2. Deploy fixed launcher files
echo   3. Create new desktop shortcut
echo.
pause

cd /d "%~dp0"

echo.
echo ========================================
echo Step 1: Testing fixes...
echo ========================================
echo.

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0Test-Fixed-Launcher.ps1"

echo.
echo ========================================
echo Step 2: Deploying fixes...
echo ========================================
echo.

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0Deploy-Fixed-Launcher.ps1"

echo.
echo ========================================
echo Step 3: Creating desktop shortcut...
echo ========================================
echo.

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0Create-Desktop-Shortcut.ps1"

echo.
echo ========================================
echo Fix Complete!
echo ========================================
echo.
echo You can now double-click the desktop shortcut.
echo The terminal will stay open and show all messages.
echo.
pause
