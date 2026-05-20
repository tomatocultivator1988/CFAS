@echo off
title Create CFAS Desktop Shortcut (Apache Version)
color 0A

echo.
echo ========================================
echo   CREATE CFAS DESKTOP SHORTCUT
echo ========================================
echo.
echo Creating desktop shortcut...
echo.

REM Create VBScript to make shortcut
set SCRIPT="%TEMP%\create-cfas-shortcut-apache.vbs"

echo Set oWS = WScript.CreateObject("WScript.Shell") > %SCRIPT%
echo sLinkFile = oWS.SpecialFolders("Desktop") ^& "\CFAS Exam System.lnk" >> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
echo oLink.TargetPath = "%~dp0START-CFAS-APACHE.bat" >> %SCRIPT%
echo oLink.WorkingDirectory = "%~dp0" >> %SCRIPT%
echo oLink.Description = "CFAS Exam System - Apache Version" >> %SCRIPT%
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
echo To use the system:
echo 1. Start XAMPP (Apache + MySQL)
echo 2. Double-click the "CFAS Exam System" icon on desktop
echo 3. Browser will open automatically
echo 4. Login and use the system!
echo.
echo That's it! No separate backend server needed!
echo.
pause
