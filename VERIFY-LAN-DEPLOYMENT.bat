@echo off
echo Running LAN Deployment Verification...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0VERIFY-LAN-DEPLOYMENT.ps1"
