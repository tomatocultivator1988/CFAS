@echo off
title Test Backend API
color 0A

echo.
echo ========================================
echo   TEST BACKEND API
echo ========================================
echo.

echo Testing backend API endpoints...
echo.

echo [1] Testing backend root...
curl -s http://192.168.11.40/exam-backend
echo.
echo.

echo [2] Testing backend public...
curl -s http://192.168.11.40/exam-backend/public
echo.
echo.

echo [3] Testing API health endpoint...
curl -s http://192.168.11.40/exam-backend/api/health
echo.
echo.

echo [4] Testing API login endpoint...
curl -s -X POST http://192.168.11.40/exam-backend/api/auth/login -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"admin123\"}"
echo.
echo.

echo ========================================
echo   TEST COMPLETE
echo ========================================
echo.
echo If you see errors above, the backend may not be configured correctly.
echo.
pause
