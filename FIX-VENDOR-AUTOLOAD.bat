@echo off
echo ========================================
echo FIXING VENDOR AUTOLOAD PATH ISSUE
echo ========================================
echo The issue: index.php can't find vendor/autoload.php
echo Solution: Copy vendor directory to correct location
echo.

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo [1/4] Checking current structure...
if exist "C:\xampp\htdocs\exam-frontend\index.php" (
    echo ✓ Found index.php in exam-frontend
) else (
    echo ✗ index.php not found in exam-frontend
    pause
    exit /b 1
)

if exist "backend\vendor" (
    echo ✓ Found vendor directory in backend
) else (
    echo ✗ vendor directory not found in backend
    echo Running composer install...
    cd backend
    composer install --no-dev --optimize-autoloader
    cd ..
)

echo [2/4] Copying vendor directory to correct location...
if exist "C:\xampp\htdocs\vendor" rmdir /s /q "C:\xampp\htdocs\vendor"
xcopy /E /I /Y backend\vendor C:\xampp\htdocs\vendor\
echo Done!

echo [3/4] Verifying autoload.php exists...
if exist "C:\xampp\htdocs\vendor\autoload.php" (
    echo ✓ autoload.php found at correct location
) else (
    echo ✗ autoload.php still not found
    pause
    exit /b 1
)

echo [4/4] Testing the fix...
echo Checking if PHP can find the autoload file...
php -r "if (file_exists('C:/xampp/htdocs/vendor/autoload.php')) { echo 'SUCCESS: autoload.php found'; } else { echo 'ERROR: autoload.php not found'; }"

echo.
echo ========================================
echo VENDOR AUTOLOAD FIX COMPLETE!
echo ========================================
echo.
echo The vendor directory has been copied to:
echo C:\xampp\htdocs\vendor\
echo.
echo Now index.php should be able to find:
echo ../vendor/autoload.php (which resolves to C:\xampp\htdocs\vendor\autoload.php)
echo.
echo Try accessing: http://192.168.11.40/exam-frontend/admin/analytics
echo.

pause