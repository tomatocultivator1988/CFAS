@echo off
REM ============================================================================
REM Setup Laravel Backend to Run on Apache
REM Simple one-time setup - no separate backend server needed!
REM ============================================================================

title Setup CFAS Backend on Apache
color 0A

echo.
echo ========================================
echo   SETUP CFAS BACKEND ON APACHE
echo ========================================
echo.
echo This will configure the backend to run through Apache.
echo No need for separate backend server!
echo.
pause

REM Copy backend to htdocs
echo.
echo [1/5] Copying backend files to Apache...
if not exist "C:\xampp\htdocs\exam-backend" mkdir "C:\xampp\htdocs\exam-backend"

xcopy /E /I /Y "%~dp0backend\*" "C:\xampp\htdocs\exam-backend\" >nul 2>&1

echo Done!

REM Create .htaccess in backend root to redirect to public
echo.
echo [2/5] Creating Apache configuration...

(
echo ^<IfModule mod_rewrite.c^>
echo     RewriteEngine On
echo     RewriteRule ^^$ public/ [L]
echo     RewriteRule ^(.*^)$ public/$1 [L]
echo ^</IfModule^>
) > "C:\xampp\htdocs\exam-backend\.htaccess"

echo Done!

REM Update .env file
echo.
echo [3/5] Configuring environment...

if exist "C:\xampp\htdocs\exam-backend\.env" (
    powershell -Command "(Get-Content 'C:\xampp\htdocs\exam-backend\.env') -replace 'APP_URL=.*', 'APP_URL=http://192.168.11.40/exam-backend' | Set-Content 'C:\xampp\htdocs\exam-backend\.env'"
) else (
    copy "C:\xampp\htdocs\exam-backend\.env.example" "C:\xampp\htdocs\exam-backend\.env" >nul
    powershell -Command "(Get-Content 'C:\xampp\htdocs\exam-backend\.env') -replace 'APP_URL=.*', 'APP_URL=http://192.168.11.40/exam-backend' | Set-Content 'C:\xampp\htdocs\exam-backend\.env'"
)

echo Done!

REM Run composer and Laravel commands
echo.
echo [4/5] Installing dependencies and optimizing...
cd /d "C:\xampp\htdocs\exam-backend"

call composer install --no-dev --optimize-autoloader >nul 2>&1
call php artisan key:generate --force >nul 2>&1
call php artisan config:cache >nul 2>&1
call php artisan route:cache >nul 2>&1

echo Done!

REM Update frontend API URL
echo.
echo [5/5] Updating frontend configuration...

REM Create a new .env file for frontend
(
echo VITE_API_URL=http://192.168.11.40/exam-backend/api
) > "C:\xampp\htdocs\exam-frontend\.env.production"

echo Done!

echo.
echo ========================================
echo   SETUP COMPLETE!
echo ========================================
echo.
echo Backend is now configured to run on Apache!
echo.
echo IMPORTANT: You need to rebuild the frontend:
echo 1. Open Command Prompt
echo 2. cd %~dp0frontend
echo 3. npm run build
echo 4. Copy dist/* to C:\xampp\htdocs\exam-frontend\
echo.
echo After that, just start XAMPP and everything works!
echo.
echo Backend URL: http://192.168.11.40/exam-backend
echo API URL: http://192.168.11.40/exam-backend/api
echo Frontend URL: http://192.168.11.40/exam-frontend
echo.
pause
