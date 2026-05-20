@echo off
echo ============================================
echo   Convert CFAS Logo to ICO Format
echo ============================================
echo.
echo This will convert cfas-logo.jpg to cfas-icon.ico
echo for use as desktop shortcut icon.
echo.
echo Press any key to start conversion...
pause > nul

powershell.exe -ExecutionPolicy Bypass -File "%~dp0convert-logo-to-ico.ps1"
