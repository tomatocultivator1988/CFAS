@echo off
title CFAS Exam System - Rebuild & Fix MIME Error
color 0B

echo ========================================
echo   REBUILD FRONTEND - FIX MIME ERROR
echo ========================================
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0REBUILD-FRONTEND-FIX-MIME.ps1"

pause
