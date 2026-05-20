@echo off
echo ========================================
echo REMOVE EXPORT SECTION - COMPLETE FIX
echo ========================================
echo.

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo Current directory: %CD%
echo.

echo [1/5] Stopping Apache (if running)...
taskkill /f /im httpd.exe >nul 2>&1
taskkill /f /im apache.exe >nul 2>&1
echo Done!
echo.

REM Navigate to frontend directory
cd frontend
if errorlevel 1 (
    echo ERROR: Cannot find frontend directory!
    echo Make sure you're running this from Exam-Main folder
    pause
    exit /b 1
)

echo [2/5] Cleaning ALL build files and cache...
if exist dist rmdir /s /q dist
if exist node_modules\.cache rmdir /s /q node_modules\.cache
echo Done!
echo.

echo [3/5] Cleaning Apache deployment completely...
cd ..
if exist "C:\xampp\htdocs\cfas-exam" rmdir /s /q "C:\xampp\htdocs\cfas-exam"
if exist "C:\Apache24\htdocs\cfas-exam" rmdir /s /q "C:\Apache24\htdocs\cfas-exam"
echo Done!
echo.

echo [4/5] Building fresh frontend (this may take a few minutes)...
cd frontend
call npm run build
if errorlevel 1 (
    echo ERROR: Build failed!
    echo Make sure Node.js and npm are installed
    pause
    exit /b 1
)
echo Done!
echo.

echo [5/5] Deploying fresh build to Apache...
cd ..
REM Try XAMPP first, then Apache24
if exist "C:\xampp\htdocs\" (
    mkdir "C:\xampp\htdocs\cfas-exam" 2>nul
    xcopy /E /I /Y frontend\dist\* C:\xampp\htdocs\cfas-exam\
    echo Deployed to XAMPP!
) else if exist "C:\Apache24\htdocs\" (
    mkdir "C:\Apache24\htdocs\cfas-exam" 2>nul
    xcopy /E /I /Y frontend\dist\* C:\Apache24\htdocs\cfas-exam\
    echo Deployed to Apache24!
) else (
    echo ERROR: No Apache installation found!
    echo Please check your Apache installation
    pause
    exit /b 1
)
echo.

echo ========================================
echo DEPLOYMENT COMPLETE!
echo ========================================
echo.
echo CRITICAL: You MUST clear browser cache completely!
echo.
echo Steps:
echo 1. Press Ctrl + Shift + Delete
echo 2. Select "All time" in time range
echo 3. Check ALL boxes (cookies, cache, etc.)
echo 4. Click "Clear data"
echo 5. Close and reopen browser
echo 6. Go to: http://192.168.11.40
echo.
echo If export section still appears, try:
echo - Hard refresh: Ctrl + Shift + R
echo - Incognito mode: Ctrl + Shift + N
echo.

pause