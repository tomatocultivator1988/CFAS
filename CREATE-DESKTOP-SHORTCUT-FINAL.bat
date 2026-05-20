@echo off
REM ============================================================================
REM Create Desktop Shortcut for CFAS Exam System - Final Version
REM ============================================================================

title Create Desktop Shortcut
color 0A

echo.
echo ========================================
echo   CREATE DESKTOP SHORTCUT
echo ========================================
echo.
echo Creating desktop shortcut for CFAS Exam System...
echo.

REM Get the desktop path
set "DESKTOP=%USERPROFILE%\Desktop"

REM Create VBS script to create shortcut
set "VBS_SCRIPT=%TEMP%\create_cfas_shortcut.vbs"

(
echo Set oWS = WScript.CreateObject^("WScript.Shell"^)
echo sLinkFile = "%DESKTOP%\CFAS Exam System.lnk"
echo Set oLink = oWS.CreateShortcut^(sLinkFile^)
echo oLink.TargetPath = "%~dp0START-CFAS-FINAL.bat"
echo oLink.WorkingDirectory = "%~dp0"
echo oLink.Description = "CFAS Review Center Examination System"
echo oLink.IconLocation = "%~dp0cfas-icon.ico"
echo oLink.Save
) > "%VBS_SCRIPT%"

REM Execute VBS script
cscript //nologo "%VBS_SCRIPT%"

REM Clean up
del "%VBS_SCRIPT%"

echo.
echo ========================================
echo   SHORTCUT CREATED!
echo ========================================
echo.
echo Desktop shortcut has been created successfully!
echo.
echo You can now:
echo 1. Go to your Desktop
echo 2. Double-click "CFAS Exam System" icon
echo 3. The system will start automatically!
echo.
echo SIMPLE LANG!
echo.
pause
