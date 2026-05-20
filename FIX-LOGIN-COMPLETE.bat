@echo off
REM ============================================================================
REM Complete Login Fix - Rebuild Frontend and Test
REM ============================================================================

title Fix Login Issue
color 0A

echo.
echo ========================================
echo   FIX LOGIN ISSUE
echo ========================================
echo.
echo This will:
echo 1. Update frontend API configuration
echo 2. Rebuild frontend
echo 3. Deploy to Apache
echo 4. Test the backend API
echo.
pause

REM Step 1: Update frontend .env
echo.
echo [1/5] Updating frontend configuration...
cd /d "%~dp0frontend"

(
echo VITE_API_URL=http://192.168.11.40/exam-backend/api
) > .env.production

echo Done!

REM Step 2: Install dependencies (if needed)
echo.
echo [2/5] Checking dependencies...
if not exist "node_modules" (
    echo Installing dependencies...
    call npm install >nul 2>&1
) else (
    echo Dependencies already installed.
)

REM Step 3: Build frontend
echo.
echo [3/5] Building frontend...
echo This may take a few minutes...

call npm run build

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Build failed!
    echo.
    pause
    exit /b 1
)

echo Done!

REM Step 4: Deploy to Apache
echo.
echo [4/5] Deploying to Apache...

REM Clear existing files
if exist "C:\xampp\htdocs\exam-frontend" (
    rmdir /s /q "C:\xampp\htdocs\exam-frontend"
)

REM Create directory and copy files
mkdir "C:\xampp\htdocs\exam-frontend"
xcopy /E /I /Y "dist\*" "C:\xampp\htdocs\exam-frontend\" >nul

echo Done!

REM Step 5: Test backend API
echo.
echo [5/5] Testing backend API...

curl -s http://192.168.11.40/exam-backend/api/health >nul 2>&1
if %errorlevel% equ 0 (
    echo Backend API is responding!
) else (
    echo WARNING: Backend API may not be responding.
    echo Make sure Apache is running!
)

echo.
echo ========================================
echo   FIX COMPLETE!
echo ========================================
echo.
echo Frontend has been rebuilt and deployed!
echo.
echo Next steps:
echo 1. Make sure XAMPP (Apache + MySQL) is running
echo 2. Open browser to: http://192.168.11.40/exam-frontend
echo 3. Try logging in with:
echo    Username: admin
echo    Password: admin123
echo.
echo If login still fails, check:
echo - Apache is running
echo - MySQL is running
echo - Backend files exist at: C:\xampp\htdocs\exam-backend
echo.
pause
