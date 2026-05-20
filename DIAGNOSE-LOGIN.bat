@echo off
title CFAS Login Diagnostic Tool
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "DIAGNOSE-AND-FIX-LOGIN.ps1"
pause
