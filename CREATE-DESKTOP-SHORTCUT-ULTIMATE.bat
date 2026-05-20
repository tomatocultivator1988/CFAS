@echo off
title Create CFAS Desktop Shortcut
color 0A

echo.
echo ========================================
echo   CREATE CFAS DESKTOP SHORTCUT
echo ========================================
echo.
echo Creating desktop shortcut...
echo.

REM Create VBScript to make shortcut
set SCRIPT="%TEMP%\create-cfas-shortcut.vbs"

echo Set oWS = WScript.CreateObject("WScript.Shell") > %SCRIPT%
echo sLinkFile = oWS.SpecialFolders("Desktop") ^& "\CFAS Exam System.lnk" >> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
echo oLink.TargetPath = "%~dp0START-CFAS-ULTIMATE.bat" >> %SCRIPT%
echo oLink.WorkingDirectory = "%~dp0" >> %SCRIPT%
echo oLink.Description = "CFAS Exam System - One Click Start" >> %SCRIPT%
echo oLink.IconLocation = "%~dp0cfas-icon.ico" >> %SCRIPT%
echo oLink.Save >> %SCRIPT%

REM Run the VBScript
cscript //nologo %SCRIPT%
del %SCRIPT%

echo.
echo ========================================
echo   SUCCESS!
echo ========================================
echo.
echo Desktop shortcut created successfully!
echo.
echo You can now start CFAS Exam System by:
echo 1. Double-clicking the desktop icon
echo 2. Or running START-CFAS-ULTIMATE.bat
echo.
echo IMPORTANT: Make sure XAMPP is running first!
echo.
pause
