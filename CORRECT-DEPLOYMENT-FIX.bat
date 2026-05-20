@echo off
echo ========================================
echo CORRECT DEPLOYMENT PATH FIX
echo ========================================
echo Found the issue! You're using /exam-frontend/ path
echo but our scripts were deploying to wrong location!
echo.

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo [1/6] Stopping Apache...
taskkill /f /im httpd.exe >nul 2>&1
taskkill /f /im apache.exe >nul 2>&1
echo Done!

echo [2/6] Deleting OLD files from CORRECT path...
if exist "C:\xampp\htdocs\exam-frontend" rmdir /s /q "C:\xampp\htdocs\exam-frontend"
if exist "C:\Apache24\htdocs\exam-frontend" rmdir /s /q "C:\Apache24\htdocs\exam-frontend"
echo Done!

echo [3/6] Deleting frontend build cache...
cd frontend
if exist dist rmdir /s /q dist
if exist node_modules\.cache rmdir /s /q node_modules\.cache
echo Done!

echo [4/6] Building FRESH frontend...
call npm run build
if errorlevel 1 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)
echo Done!

echo [5/6] Copying to backend/public first...
cd ..
xcopy /E /I /Y frontend\dist\* backend\public\
echo Done!

echo [6/6] Deploying to CORRECT Apache path...
if exist "C:\xampp\htdocs\" (
    mkdir "C:\xampp\htdocs\exam-frontend" 2>nul
    xcopy /E /I /Y backend\public\* C:\xampp\htdocs\exam-frontend\
    echo Deployed to XAMPP at /exam-frontend/!
) else if exist "C:\Apache24\htdocs\" (
    mkdir "C:\Apache24\htdocs\exam-frontend" 2>nul
    xcopy /E /I /Y backend\public\* C:\Apache24\htdocs\exam-frontend\
    echo Deployed to Apache24 at /exam-frontend/!
) else (
    echo ERROR: No Apache installation found!
    pause
    exit /b 1
)

echo ========================================
echo CORRECT DEPLOYMENT COMPLETE!
echo ========================================
echo.
echo The problem was: We were deploying to /cfas-exam/
echo But your URL uses: /exam-frontend/
echo.
echo Now flush DNS and clear browser cache:
echo.

echo Flushing DNS cache...
ipconfig /flushdns

echo.
echo FINAL STEPS:
echo 1. Clear browser cache: Ctrl + Shift + Delete
echo 2. Select "All time" and check all boxes
echo 3. Clear data
echo 4. Go to: http://192.168.11.40/exam-frontend/admin/analytics
echo.
echo Export section should be GONE now!
echo.

pause