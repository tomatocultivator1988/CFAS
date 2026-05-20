@echo off
echo ========================================
echo FINDING EXPORT SECTION SOURCE
echo ========================================
echo.

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo Checking where the export section is coming from...
echo.

echo [1] Checking current browser URL...
echo Open your browser and go to 192.168.11.40
echo Right-click on the export section and select "Inspect Element"
echo Look for the HTML source and tell me what you see.
echo.

echo [2] Checking if it's from a different component...
echo The export section might be coming from:
echo - A different page (not Analytics Dashboard)
echo - A modal or popup
echo - A different route
echo.

echo [3] Let me check the current deployment...
if exist "C:\xampp\htdocs\cfas-exam\index.html" (
    echo Found deployment in XAMPP
    findstr /i "export" "C:\xampp\htdocs\cfas-exam\index.html" >nul
    if errorlevel 1 (
        echo No export text found in index.html
    ) else (
        echo FOUND export text in index.html!
    )
) else (
    echo No deployment found in XAMPP
)

echo.
echo [4] Checking if you're on the right page...
echo Make sure you're on: http://192.168.11.40/admin/analytics
echo NOT on: http://192.168.11.40/admin/exports
echo.

echo [5] Quick test - try these URLs:
echo - http://192.168.11.40/admin/analytics (should NOT have export)
echo - http://192.168.11.40/admin/exports (SHOULD have export)
echo.

echo If export section appears on BOTH pages, then it's embedded
echo in a shared component like the sidebar or header.
echo.

pause