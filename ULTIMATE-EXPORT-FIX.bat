@echo off
echo ========================================
echo ULTIMATE EXPORT SECTION FIX
echo ========================================
echo Found the problem! Apache is serving from backend/public
echo instead of frontend/dist!
echo.

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo [1/6] Stopping Apache...
taskkill /f /im httpd.exe >nul 2>&1
taskkill /f /im apache.exe >nul 2>&1
echo Done!

echo [2/6] Deleting OLD built files from backend/public...
if exist "backend\public\assets" rmdir /s /q "backend\public\assets"
if exist "backend\public\index.html" del /q "backend\public\index.html"
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

echo [5/6] Copying NEW build to backend/public...
cd ..
xcopy /E /I /Y frontend\dist\* backend\public\
echo Done!

echo [6/6] Deploying to Apache htdocs...
if exist "C:\xampp\htdocs\" (
    if exist "C:\xampp\htdocs\cfas-exam" rmdir /s /q "C:\xampp\htdocs\cfas-exam"
    mkdir "C:\xampp\htdocs\cfas-exam" 2>nul
    xcopy /E /I /Y backend\public\* C:\xampp\htdocs\cfas-exam\
    echo Deployed to XAMPP!
) else if exist "C:\Apache24\htdocs\" (
    if exist "C:\Apache24\htdocs\cfas-exam" rmdir /s /q "C:\Apache24\htdocs\cfas-exam"
    mkdir "C:\Apache24\htdocs\cfas-exam" 2>nul
    xcopy /E /I /Y backend\public\* C:\Apache24\htdocs\cfas-exam\
    echo Deployed to Apache24!
) else (
    echo ERROR: No Apache installation found!
    pause
    exit /b 1
)

echo ========================================
echo ULTIMATE FIX COMPLETE!
echo ========================================
echo.
echo The problem was: Apache was serving OLD files from backend/public
echo instead of the NEW files from frontend/dist!
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
echo 4. Go to: http://192.168.11.40
echo.
echo Export section should be GONE now!
echo.

pause