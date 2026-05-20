@echo off
echo ============================================
echo   CFAS Desktop Icon Setup (All-in-One)
echo ============================================
echo.
echo This will:
echo 1. Convert cfas-logo.jpg to cfas-icon.ico
echo 2. Create desktop shortcut with CFAS icon
echo.
echo Press any key to start...
pause > nul
echo.

echo [Step 1/2] Converting logo to ICO format...
echo.
powershell.exe -ExecutionPolicy Bypass -File "%~dp0convert-logo-to-ico.ps1"

if errorlevel 1 (
    echo.
    echo ERROR: Logo conversion failed!
    pause
    exit /b 1
)

echo.
echo [Step 2/2] Creating desktop shortcut...
echo.
cscript //NoLogo "%~dp0create-shortcut-with-icon.vbs"

echo.
echo ============================================
echo   DONE!
echo ============================================
echo.
echo Check your desktop for the CFAS icon!
echo.
pause
