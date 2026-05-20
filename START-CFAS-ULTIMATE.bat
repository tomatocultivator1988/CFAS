@echo off
title CFAS Exam System
color 0A

echo.
echo ========================================
echo   CFAS EXAM SYSTEM
echo   Review Center Management System
echo ========================================
echo.
echo Starting system, please wait...
echo.

REM Check if backend is already running
netstat -ano | findstr ":8000" | findstr "LISTENING" >nul 2>&1
if %errorlevel% equ 0 (
    echo Backend is already running!
    goto open_browser
)

REM Start backend using VBScript (completely hidden)
echo Starting backend server...
cscript //nologo "%~dp0start-backend-hidden.vbs"

REM Wait for backend to start (check every second for 15 seconds)
echo Initializing backend...
set /a counter=0
:wait_loop
timeout /t 1 /nobreak >nul
netstat -ano | findstr ":8000" | findstr "LISTENING" >nul 2>&1
if %errorlevel% equ 0 goto backend_ready
set /a counter+=1
if %counter% lss 15 goto wait_loop

echo.
echo WARNING: Backend startup is taking longer than expected.
echo The system may still work. Opening browser...
echo.
goto open_browser

:backend_ready
echo Backend started successfully!
echo.

:open_browser
echo Opening CFAS Exam System...
timeout /t 2 /nobreak >nul
start http://192.168.11.40/exam-frontend

echo.
echo ========================================
echo   SYSTEM IS READY!
echo ========================================
echo.
echo The CFAS Exam System is now running.
echo.
echo IMPORTANT NOTES:
echo - Do NOT close XAMPP (Apache and MySQL must be running)
echo - You can close this window now
echo - To stop the system, close XAMPP
echo.
echo Press any key to close this window...
pause >nul
exit
