@echo off
echo ========================================
echo NUCLEAR EXPORT SECTION REMOVAL
echo ========================================
echo This will COMPLETELY wipe everything!
echo.
pause

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo [1/8] Stopping ALL web services...
taskkill /f /im httpd.exe >nul 2>&1
taskkill /f /im apache.exe >nul 2>&1
taskkill /f /im nginx.exe >nul 2>&1
taskkill /f /im chrome.exe >nul 2>&1
taskkill /f /im firefox.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1
echo Done!

echo [2/8] Flushing DNS cache...
ipconfig /flushdns
echo Done!

echo [3/8] Clearing Windows DNS resolver cache...
net stop dnscache
net start dnscache
echo Done!

echo [4/8] Deleting ALL browser caches...
REM Chrome cache
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" rmdir /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache"
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Code Cache" rmdir /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Code Cache"

REM Edge cache  
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" rmdir /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache"
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Code Cache" rmdir /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Code Cache"

REM Firefox cache
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%i in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") do (
        if exist "%%i\cache2" rmdir /s /q "%%i\cache2"
    )
)
echo Done!

echo [5/8] Deleting ALL build files and caches...
cd frontend
if exist dist rmdir /s /q dist
if exist node_modules\.cache rmdir /s /q node_modules\.cache
if exist .vite rmdir /s /q .vite
if exist .nuxt rmdir /s /q .nuxt
echo Done!

echo [6/8] COMPLETELY wiping Apache deployment...
cd ..
if exist "C:\xampp\htdocs\cfas-exam" rmdir /s /q "C:\xampp\htdocs\cfas-exam"
if exist "C:\Apache24\htdocs\cfas-exam" rmdir /s /q "C:\Apache24\htdocs\cfas-exam"
if exist "C:\xampp\htdocs\index.html" del /q "C:\xampp\htdocs\index.html"
if exist "C:\Apache24\htdocs\index.html" del /q "C:\Apache24\htdocs\index.html"
echo Done!

echo [7/8] Building FRESH frontend (no export components)...
cd frontend
call npm run build
if errorlevel 1 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)
echo Done!

echo [8/8] Deploying CLEAN build...
cd ..
REM Deploy to both possible locations
if exist "C:\xampp\htdocs\" (
    mkdir "C:\xampp\htdocs\cfas-exam" 2>nul
    xcopy /E /I /Y frontend\dist\* C:\xampp\htdocs\cfas-exam\
    echo Deployed to XAMPP!
)
if exist "C:\Apache24\htdocs\" (
    mkdir "C:\Apache24\htdocs\cfas-exam" 2>nul
    xcopy /E /I /Y frontend\dist\* C:\Apache24\htdocs\cfas-exam\
    echo Deployed to Apache24!
)

echo ========================================
echo NUCLEAR REMOVAL COMPLETE!
echo ========================================
echo.
echo CRITICAL NEXT STEPS:
echo 1. RESTART YOUR COMPUTER (important!)
echo 2. After restart, open browser
echo 3. Go to: http://192.168.11.40
echo.
echo If STILL showing export section:
echo - Try different browser (Firefox, Edge)
echo - Check if you're going to correct URL
echo - Verify Apache is serving from correct folder
echo.

pause