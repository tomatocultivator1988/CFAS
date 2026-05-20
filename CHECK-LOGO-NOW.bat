@echo off
echo ============================================
echo   CFAS Launcher - Logo Check
echo ============================================
echo.
echo This will check if the logo is working.
echo.
echo Step 1: Running diagnostic checks...
echo.
pause

powershell.exe -ExecutionPolicy Bypass -File "%~dp0QUICK-LOGO-CHECK.ps1"
