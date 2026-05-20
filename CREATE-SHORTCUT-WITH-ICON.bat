@echo off
echo ============================================
echo   Create Desktop Shortcut with CFAS Icon
echo ============================================
echo.
echo This will create a desktop shortcut with
echo the CFAS logo as the icon.
echo.
echo NOTE: You must run CONVERT-LOGO-TO-ICO.bat first!
echo.
echo Press any key to create shortcut...
pause > nul

cscript //NoLogo "%~dp0create-shortcut-with-icon.vbs"

echo.
pause
