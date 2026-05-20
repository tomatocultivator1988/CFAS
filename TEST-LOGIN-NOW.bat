@echo off
REM ============================================================================
REM Test Login Functionality
REM ============================================================================

title Test Login
color 0A

echo.
echo ========================================
echo   TEST LOGIN FUNCTIONALITY
echo ========================================
echo.

echo [1] Testing Backend API Health...
curl -s http://192.168.11.40/exam-backend/public/api/health
echo.
echo.

echo [2] Testing Login Endpoint...
curl -s -X POST http://192.168.11.40/exam-backend/public/api/auth/login -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"admin123\"}"
echo.
echo.

echo [3] Opening Frontend in Browser...
start http://192.168.11.40/exam-frontend
echo.

echo ========================================
echo   TEST COMPLETE
echo ========================================
echo.
echo If you see JSON responses above (not HTML), the backend is working!
echo.
echo The frontend should now be open in your browser.
echo Try logging in with:
echo   Username: admin
echo   Password: admin123
echo.
echo If login works, EVERYTHING IS FIXED!
echo.
pause
