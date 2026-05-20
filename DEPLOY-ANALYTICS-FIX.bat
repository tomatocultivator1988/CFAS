@echo off
echo.
echo ================================================================
echo   ANALYTICS DASHBOARD CONNECTION FIX - DEPLOYMENT
echo ================================================================
echo.

echo [1/4] Checking files...
if not exist "frontend\src\config\environmentDetector.js" (
    echo ERROR: environmentDetector.js not found
    pause
    exit /b 1
)

if not exist "frontend\src\config\configManager.js" (
    echo ERROR: configManager.js not found  
    pause
    exit /b 1
)

if not exist "frontend\src\services\analyticsApi.js" (
    echo ERROR: analyticsApi.js not found
    pause
    exit /b 1
)

echo ✓ All fix files found

echo.
echo [2/4] Building frontend...
cd frontend
call npm run build
if errorlevel 1 (
    echo ERROR: Build failed
    cd ..
    pause
    exit /b 1
)
cd ..

echo ✓ Frontend build completed

echo.
echo [3/4] Checking for Apache deployment...
if exist "C:\xampp\htdocs\exam-frontend" (
    echo Found XAMPP deployment path
    xcopy /E /Y /I "frontend\dist\*" "C:\xampp\htdocs\exam-frontend\"
    echo ✓ Deployed to XAMPP
) else (
    echo WARNING: XAMPP path not found
    echo Please manually copy frontend\dist contents to your Apache directory
)

echo.
echo [4/4] Opening test page...
start "" "test-analytics-connection-browser.html"

echo.
echo ================================================================
echo   DEPLOYMENT COMPLETE!
echo ================================================================
echo.
echo ✓ Analytics connection fix deployed
echo ✓ Frontend rebuilt with updated configuration  
echo ✓ Test page opened in browser
echo.
echo NEXT STEPS:
echo 1. Test the analytics dashboard in your browser
echo 2. Check console - should see Apache backend detection
echo 3. Verify no more 'localhost:8000' connection attempts
echo 4. Clear browser cache if needed (Ctrl+Shift+R)
echo.
pause