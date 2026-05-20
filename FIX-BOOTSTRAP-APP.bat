@echo off
echo ========================================
echo FIXING BOOTSTRAP APP.PHP ISSUE
echo ========================================
echo The issue: index.php can't find ../bootstrap/app.php
echo Solution: Copy entire Laravel backend structure
echo.

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo [1/6] Checking current structure...
if exist "C:\xampp\htdocs\exam-frontend\index.php" (
    echo ✓ Found index.php in exam-frontend
) else (
    echo ✗ index.php not found in exam-frontend
    pause
    exit /b 1
)

if exist "backend\bootstrap\app.php" (
    echo ✓ Found bootstrap/app.php in backend
) else (
    echo ✗ bootstrap/app.php not found in backend
    pause
    exit /b 1
)

echo [2/6] Stopping Apache...
taskkill /f /im httpd.exe >nul 2>&1
taskkill /f /im apache.exe >nul 2>&1
echo Done!

echo [3/6] Copying bootstrap directory...
if exist "C:\xampp\htdocs\bootstrap" rmdir /s /q "C:\xampp\htdocs\bootstrap"
xcopy /E /I /Y backend\bootstrap C:\xampp\htdocs\bootstrap\
echo Done!

echo [4/6] Copying other essential Laravel directories...
REM Copy app directory
if exist "C:\xampp\htdocs\app" rmdir /s /q "C:\xampp\htdocs\app"
xcopy /E /I /Y backend\app C:\xampp\htdocs\app\

REM Copy config directory
if exist "C:\xampp\htdocs\config" rmdir /s /q "C:\xampp\htdocs\config"
xcopy /E /I /Y backend\config C:\xampp\htdocs\config\

REM Copy routes directory
if exist "C:\xampp\htdocs\routes" rmdir /s /q "C:\xampp\htdocs\routes"
xcopy /E /I /Y backend\routes C:\xampp\htdocs\routes\

REM Copy storage directory
if exist "C:\xampp\htdocs\storage" rmdir /s /q "C:\xampp\htdocs\storage"
xcopy /E /I /Y backend\storage C:\xampp\htdocs\storage\

REM Copy database directory
if exist "C:\xampp\htdocs\database" rmdir /s /q "C:\xampp\htdocs\database"
xcopy /E /I /Y backend\database C:\xampp\htdocs\database\

echo Done!

echo [5/6] Copying .env file...
if exist "backend\.env" (
    copy /Y backend\.env C:\xampp\htdocs\.env
    echo ✓ .env file copied
) else (
    echo ⚠ .env file not found in backend, copying .env.example
    if exist "backend\.env.example" (
        copy /Y backend\.env.example C:\xampp\htdocs\.env
    )
)

echo [6/6] Verifying structure...
if exist "C:\xampp\htdocs\bootstrap\app.php" (
    echo ✓ bootstrap/app.php found at correct location
) else (
    echo ✗ bootstrap/app.php still not found
    pause
    exit /b 1
)

if exist "C:\xampp\htdocs\vendor\autoload.php" (
    echo ✓ vendor/autoload.php found
) else (
    echo ✗ vendor/autoload.php not found
    pause
    exit /b 1
)

echo.
echo ========================================
echo BOOTSTRAP APP FIX COMPLETE!
echo ========================================
echo.
echo Laravel backend structure copied to Apache root:
echo - C:\xampp\htdocs\bootstrap\app.php
echo - C:\xampp\htdocs\vendor\autoload.php
echo - C:\xampp\htdocs\app\
echo - C:\xampp\htdocs\config\
echo - C:\xampp\htdocs\routes\
echo - C:\xampp\htdocs\storage\
echo - C:\xampp\htdocs\database\
echo.
echo Now the paths should resolve correctly:
echo - exam-frontend/index.php can find ../bootstrap/app.php
echo - exam-frontend/index.php can find ../vendor/autoload.php
echo.
echo Try accessing: http://192.168.11.40/exam-frontend/admin/analytics
echo.

pause