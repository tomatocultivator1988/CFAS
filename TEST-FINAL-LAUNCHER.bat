@echo off
REM ============================================================================
REM Test Final Launcher
REM ============================================================================

title Test Final Launcher
color 0A

echo.
echo ========================================
echo   TEST FINAL LAUNCHER
echo ========================================
echo.
echo This will test the final launcher...
echo.
pause

echo.
echo Running launcher...
echo.

call "%~dp0START-CFAS-FINAL.bat"

echo.
echo ========================================
echo   TEST COMPLETE
echo ========================================
echo.
echo Did the GUI window appear?
echo Did the system start successfully?
echo Did the browser open?
echo.
echo If YES to all, the launcher is working perfectly!
echo.
pause
