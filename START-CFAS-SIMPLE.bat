@echo off
title CFAS Exam System - Starting...
color 0A

echo.
echo ========================================
echo   CFAS EXAM SYSTEM
echo   Starting all services...
echo ========================================
echo.

REM Check if backend is already running
netstat -ano | findstr ":8000" | findstr "LISTENING" >nul 2>&1
if %errorlevel% equ 0 (
    echo Backend is already running!
    echo Opening browser...
    timeout /t 2 /nobreak >nul
    start http://192.168.11.40/exam-frontend
    echo.
    echo System is ready!
    timeout /t 3 /nobreak >nul
    exit
)

REM Start backend in background using PowerShell
echo Starting backend server...
powershell -WindowStyle Hidden -Command "Start-Process -FilePath 'php' -ArgumentList 'artisan','serve','--host=127.0.0.1','--port=8000' -WorkingDirectory '%~dp0backend' -WindowStyle Hidden"

REM Wait for backend to start
echo Waiting for backend to initialize...
set /a counter=0
:wait_loop
timeout /t 1 /nobreak >nul
netstat -ano | findstr ":8000" | findstr "LISTENING" >nul 2>&1
if %errorlevel% equ 0 goto backend_ready
set /a counter+=1
if %counter% lss 10 goto wait_loop

echo WARNING: Backend may not have started properly
echo But continuing anyway...

:backend_ready
echo Backend is ready!
echo.

REM Open browser
echo Opening browser...
start http://192.168.11.40/exam-frontend

echo.
echo ========================================
echo   SYSTEM STARTED!
echo ========================================
echo.
echo The system is now running.
echo You can close this window.
echo.
timeout /t 5 /nobreak >nul
exit
