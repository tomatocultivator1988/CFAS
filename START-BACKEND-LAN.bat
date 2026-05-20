@echo off
echo ========================================
echo CFAS Exam System - Backend Server
echo Starting Laravel Backend for LAN Access
echo ========================================
echo.

cd backend
echo Starting Laravel server on 0.0.0.0:8000...
echo Press Ctrl+C to stop the server
echo.
php artisan serve --host=0.0.0.0 --port=8000

pause
