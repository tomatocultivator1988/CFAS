@echo off
REM ============================================================================
REM CFAS Exam System Launcher - Apache Edition with Modern GUI
REM Starts Apache, MySQL, and opens browser with professional GUI
REM ============================================================================

REM Run the PowerShell GUI launcher (visible window for GUI)
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0CFAS-LAUNCHER-APACHE-GUI.ps1"

exit
