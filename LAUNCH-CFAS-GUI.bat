@echo off
title CFAS Exam System Launcher
color 0A

echo ========================================
echo CFAS Exam System Launcher
echo ========================================
echo.
echo Starting GUI launcher...
echo.

cd /d "%~dp0"

REM Keep terminal open and run PowerShell launcher
powershell.exe -ExecutionPolicy Bypass -NoExit -Command "& { & '%~dp0CFAS-System-Launcher.ps1'; Write-Host ''; Write-Host 'Launcher finished. You can close this window.' -ForegroundColor Green; Read-Host 'Press Enter to exit' }"
