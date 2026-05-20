@echo off
echo.
echo ========================================
echo  ANALYTICS JAVASCRIPT FIX DEPLOYMENT
echo ========================================
echo.
echo This will:
echo 1. Build the frontend with JavaScript fixes
echo 2. Deploy to LAN server (192.168.11.40)
echo 3. Clear browser cache
echo 4. Test the deployment
echo.
pause

powershell -ExecutionPolicy Bypass -File "DEPLOY-ANALYTICS-FIX-CLEAN.ps1"

echo.
echo Deployment completed!
pause