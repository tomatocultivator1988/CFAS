@echo off
echo ============================================
echo Testing CFAS Launcher with Logo Display
echo ============================================
echo.
echo This will open the launcher GUI.
echo Check if the CFAS logo appears at the top!
echo.
echo What to look for:
echo - CFAS logo image (120x120 pixels) at the top
echo - OR blue box if logo file not found
echo.
echo Press any key to launch...
pause > nul

powershell.exe -NoExit -ExecutionPolicy Bypass -File "%~dp0CFAS-System-Launcher.ps1"
