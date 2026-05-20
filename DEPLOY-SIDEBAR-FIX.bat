@echo off
echo ============================================
echo   CFAS Sidebar Footer Fix Deployment
echo ============================================
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0DEPLOY-SIDEBAR-FIX.ps1"

pause
