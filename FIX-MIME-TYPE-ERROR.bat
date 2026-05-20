@echo off
title CFAS Exam System - Fix MIME Type Error
color 0B

echo ========================================
echo   CFAS EXAM SYSTEM - MIME TYPE FIX
echo ========================================
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0FIX-MIME-TYPE-ERROR.ps1"

pause
