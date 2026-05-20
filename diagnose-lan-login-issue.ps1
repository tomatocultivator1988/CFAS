#!/usr/bin/env pwsh

Write-Host "========================================" -ForegroundColor Red
Write-Host "DIAGNOSING LAN LOGIN ISSUE" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red

Write-Host ""
Write-Host "1. Checking LAN frontend deployment..." -ForegroundColor Yellow
if (Test-Path "C:\xampp\htdocs\exam-frontend\index.html") {
    Write-Host "✅ Frontend deployed" -ForegroundColor Green
} else {
    Write-Host "❌ Frontend missing" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Checking LAN backend deployment..." -ForegroundColor Yellow
if (Test-Path "C:\xampp\htdocs\exam-backend\index.php") {
    Write-Host "✅ Backend deployed" -ForegroundColor Green
} else {
    Write-Host "❌ Backend missing" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Checking backend .env configuration..." -ForegroundColor Yellow
$backendEnv = "C:\xampp\htdocs\exam-backend\.env"
if (Test-Path $backendEnv) {
    Write-Host "✅ Backend .env exists" -ForegroundColor Green
    $envContent = Get-Content $backendEnv
    
    Write-Host "   Checking API URL..." -ForegroundColor Cyan
    $apiUrl = $envContent | Where-Object { $_ -match "^APP_URL=" }
    if ($apiUrl) {
        Write-Host "   $apiUrl" -ForegroundColor White
    } else {
        Write-Host "   ❌ APP_URL not found" -ForegroundColor Red
    }
    
    Write-Host "   Checking database config..." -ForegroundColor Cyan
    $dbHost = $envContent | Where-Object { $_ -match "^DB_HOST=" }
    $dbName = $envContent | Where-Object { $_ -match "^DB_DATABASE=" }
    if ($dbHost) { Write-Host "   $dbHost" -ForegroundColor White }
    if ($dbName) { Write-Host "   $dbName" -ForegroundColor White }
} else {
    Write-Host "❌ Backend .env missing" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Checking frontend .env configuration..." -ForegroundColor Yellow
$frontendEnv = "C:\xampp\htdocs\exam-frontend\.env"
if (Test-Path $frontendEnv) {
    Write-Host "✅ Frontend .env exists" -ForegroundColor Green
    $envContent = Get-Content $frontendEnv
    
    $apiUrl = $envContent | Where-Object { $_ -match "^VITE_API_URL=" }
    if ($apiUrl) {
        Write-Host "   $apiUrl" -ForegroundColor White
    } else {
        Write-Host "   ❌ VITE_API_URL not found" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Frontend .env missing" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Testing API endpoints..." -ForegroundColor Yellow
try {
    Write-Host "   Testing backend root..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri "http://192.168.11.40/exam-backend/" -TimeoutSec 5 -UseBasicParsing
    Write-Host "   ✅ Backend accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Backend not accessible: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    Write-Host "   Testing API login endpoint..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri "http://192.168.11.40/exam-backend/api/login" -Method POST -TimeoutSec 5 -UseBasicParsing
    Write-Host "   ✅ API login endpoint accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ API login endpoint error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "6. Checking XAMPP services..." -ForegroundColor Yellow
$apacheRunning = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
$mysqlRunning = Get-Process -Name "mysqld" -ErrorAction SilentlyContinue

if ($apacheRunning) {
    Write-Host "   ✅ Apache is running" -ForegroundColor Green
} else {
    Write-Host "   ❌ Apache is not running" -ForegroundColor Red
}

if ($mysqlRunning) {
    Write-Host "   ✅ MySQL is running" -ForegroundColor Green
} else {
    Write-Host "   ❌ MySQL is not running" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Red
Write-Host "DIAGNOSIS COMPLETE" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red

Write-Host ""
Write-Host "Common Solutions:" -ForegroundColor Cyan
Write-Host "1. Run: fix-lan-backend-api.ps1" -ForegroundColor White
Write-Host "2. Restart Apache in XAMPP Control Panel" -ForegroundColor White
Write-Host "3. Clear browser cache (Ctrl+F5)" -ForegroundColor White
Write-Host "4. Check if database is accessible" -ForegroundColor White
Write-Host ""