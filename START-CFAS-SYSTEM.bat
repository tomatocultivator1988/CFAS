@echo off
title CFAS Exam System Launcher
color 0A

echo ========================================
echo   CFAS EXAM SYSTEM LAUNCHER
echo ========================================
echo.

REM Start backend in a new window
echo Starting Laravel Backend Server...
start "CFAS Backend Server" cmd /k "cd /d "%~dp0backend" && php artisan serve --host=127.0.0.1 --port=8000"

echo Waiting for backend to initialize...
timeout /t 5 /nobreak >nul

echo.
echo Opening browser...
start http://192.168.11.40/exam-frontend

echo.
echo ========================================
echo   SYSTEM STARTED!
echo ========================================
echo.
echo Backend Server: Running in separate window
echo Frontend URL: http://192.168.11.40/exam-frontend
echo.
echo IMPORTANT: Do NOT close the backend server window!
echo.
pause
