@echo off
REM ============================================================================
REM Install Laravel Backend as Windows Service using NSSM
REM This makes the backend run automatically with XAMPP
REM ============================================================================

title Install CFAS Backend Service
color 0A

echo.
echo ========================================
echo   INSTALL CFAS BACKEND SERVICE
echo ========================================
echo.

REM Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script requires Administrator privileges!
    echo.
    echo Please right-click and select "Run as Administrator"
    echo.
    pause
    exit /b 1
)

echo Checking for NSSM (Non-Sucking Service Manager)...
echo.

REM Check if NSSM exists
if not exist "%~dp0nssm.exe" (
    echo NSSM not found. Downloading...
    echo.
    echo Please download NSSM from: https://nssm.cc/download
    echo Extract nssm.exe to this folder: %~dp0
    echo Then run this script again.
    echo.
    pause
    exit /b 1
)

echo NSSM found!
echo.

REM Stop and remove existing service if it exists
echo Checking for existing service...
sc query "CFASBackend" >nul 2>&1
if %errorlevel% equ 0 (
    echo Stopping existing service...
    "%~dp0nssm.exe" stop CFASBackend
    timeout /t 2 /nobreak >nul
    
    echo Removing existing service...
    "%~dp0nssm.exe" remove CFASBackend confirm
    timeout /t 2 /nobreak >nul
)

echo.
echo Installing CFAS Backend Service...
echo.

REM Install the service
"%~dp0nssm.exe" install CFASBackend "C:\xampp\php\php.exe" "artisan" "serve" "--host=127.0.0.1" "--port=8000"

REM Set working directory
"%~dp0nssm.exe" set CFASBackend AppDirectory "%~dp0backend"

REM Set service description
"%~dp0nssm.exe" set CFASBackend Description "CFAS Exam System Backend API Server"

REM Set display name
"%~dp0nssm.exe" set CFASBackend DisplayName "CFAS Backend Service"

REM Set startup type to automatic
"%~dp0nssm.exe" set CFASBackend Start SERVICE_AUTO_START

REM Set service to restart on failure
"%~dp0nssm.exe" set CFASBackend AppExit Default Restart
"%~dp0nssm.exe" set CFASBackend AppRestartDelay 5000

REM Set output logging
"%~dp0nssm.exe" set CFASBackend AppStdout "%~dp0backend\storage\logs\service-output.log"
"%~dp0nssm.exe" set CFASBackend AppStderr "%~dp0backend\storage\logs\service-error.log"

echo.
echo Starting CFAS Backend Service...
"%~dp0nssm.exe" start CFASBackend

echo.
echo Waiting for service to start...
timeout /t 5 /nobreak >nul

REM Check if service is running
sc query "CFASBackend" | find "RUNNING" >nul
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   SERVICE INSTALLED SUCCESSFULLY!
    echo ========================================
    echo.
    echo The CFAS Backend Service is now running!
    echo It will start automatically when Windows boots.
    echo.
    echo Service Name: CFASBackend
    echo Backend URL: http://127.0.0.1:8000
    echo API URL: http://127.0.0.1:8000/api
    echo.
    echo To manage the service:
    echo - Start: nssm start CFASBackend
    echo - Stop: nssm stop CFASBackend
    echo - Restart: nssm restart CFASBackend
    echo - Remove: nssm remove CFASBackend confirm
    echo.
) else (
    echo.
    echo ========================================
    echo   SERVICE INSTALLATION FAILED!
    echo ========================================
    echo.
    echo The service was installed but failed to start.
    echo Please check the logs at:
    echo %~dp0backend\storage\logs\
    echo.
)

pause
