@echo off
echo ========================================
echo STARTING LARAVEL BACKEND
echo ========================================
echo.

cd /d "%~dp0backend"

echo Starting server at http://127.0.0.1:8000
echo Press Ctrl+C to stop
echo.

php artisan serve --host=127.0.0.1 --port=8000

pause
