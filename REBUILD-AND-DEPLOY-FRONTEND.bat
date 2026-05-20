@echo off
REM ============================================================================
REM Rebuild Frontend with New Backend URL and Deploy to Apache
REM ============================================================================

title Rebuild and Deploy Frontend
color 0A

echo.
echo ========================================
echo   REBUILD AND DEPLOY FRONTEND
echo ========================================
echo.
echo This will rebuild the frontend with the new backend URL
echo and deploy it to Apache.
echo.
pause

REM Navigate to frontend directory
cd /d "%~dp0frontend"

echo.
echo [1/4] Updating environment configuration...

REM Create .env.production file with correct API URL
(
echo VITE_API_URL=http://192.168.11.40/exam-backend/public/api
) > .env.production

echo Done!

echo.
echo [2/4] Installing dependencies...
echo This may take a few minutes...

call npm install >nul 2>&1

echo Done!

echo.
echo [3/4] Building frontend...
echo This may take a few minutes...

call npm run build

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Build failed!
    echo Please check the error messages above.
    pause
    exit /b 1
)

echo Done!

echo.
echo [4/4] Deploying to Apache...

REM Clear existing frontend files
if exist "C:\xampp\htdocs\exam-frontend" (
    rmdir /s /q "C:\xampp\htdocs\exam-frontend"
)

REM Create directory
mkdir "C:\xampp\htdocs\exam-frontend"

REM Copy built files
xcopy /E /I /Y "dist\*" "C:\xampp\htdocs\exam-frontend\" >nul

echo Done!

echo.
echo ========================================
echo   DEPLOYMENT COMPLETE!
echo ========================================
echo.
echo Frontend has been rebuilt and deployed!
echo.
echo You can now access the system at:
echo http://192.168.11.40/exam-frontend
echo.
echo IMPORTANT: Make sure XAMPP (Apache + MySQL) is running!
echo.
echo Next steps:
echo 1. Start XAMPP Control Panel
echo 2. Start Apache (if not running)
echo 3. Start MySQL (if not running)
echo 4. Open browser to: http://192.168.11.40/exam-frontend
echo 5. Login and test!
echo.
pause
