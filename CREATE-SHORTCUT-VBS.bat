@echo off
title Create CFAS Desktop Shortcut
color 0A

echo ========================================
echo Creating CFAS Desktop Shortcut
echo ========================================
echo.
echo This will create a desktop shortcut for
echo the CFAS Exam System launcher.
echo.
echo Please wait...
echo.

cd /d "%~dp0"

cscript //NoLogo "%~dp0create-desktop-shortcuts.vbs"

echo.
echo Done!
echo.
pause
