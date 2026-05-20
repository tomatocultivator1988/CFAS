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
echo The fix addresses:
echo - ReferenceError: Cannot access 'e' before initialization
echo - Variable redeclaration conflicts in Vue composables
echo - Router navigation errors
echo.
pause

powershell -ExecutionPolicy Bypass -File "DEPLOY-ANALYTICS-FIX-CLEAN.ps1"

echo.
echo Deployment completed!
echo.
echo Next: Open http://192.168.11.40/exam-frontend/admin/analytics
echo and check the browser console (F12) for errors.
echo.
pause