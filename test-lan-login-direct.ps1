#!/usr/bin/env pwsh

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TESTING LAN LOGIN DIRECTLY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$ServerIP = "192.168.11.40"

Write-Host ""
Write-Host "1. Testing backend root access..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://$ServerIP/exam-backend/" -TimeoutSec 5 -UseBasicParsing
    Write-Host "   ✅ Backend root accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Backend root error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Testing Laravel public folder..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://$ServerIP/exam-backend/public/" -TimeoutSec 5 -UseBasicParsing
    Write-Host "   ✅ Laravel public accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Laravel public error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Testing API through public folder..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://$ServerIP/exam-backend/public/api/login" -Method POST -TimeoutSec 5 -UseBasicParsing
    Write-Host "   ✅ API through public accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ API through public error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Testing with actual login credentials..." -ForegroundColor Yellow
try {
    $body = @{
        email = "admin@example.com"
        password = "password"
    } | ConvertTo-Json

    $headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
    }

    $response = Invoke-WebRequest -Uri "http://$ServerIP/exam-backend/public/api/login" -Method POST -Body $body -Headers $headers -TimeoutSec 10 -UseBasicParsing
    Write-Host "   ✅ Login successful! (Status: $($response.StatusCode))" -ForegroundColor Green
    Write-Host "   Response: $($response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)))" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "   Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "5. Checking .htaccess configuration..." -ForegroundColor Yellow
$htaccessPath = "C:\xampp\htdocs\exam-backend\.htaccess"
if (Test-Path $htaccessPath) {
    Write-Host "   ✅ Root .htaccess exists" -ForegroundColor Green
    $content = Get-Content $htaccessPath -Raw
    if ($content -match "RewriteRule.*public") {
        Write-Host "   ✅ .htaccess has public redirect" -ForegroundColor Green
    } else {
        Write-Host "   ❌ .htaccess missing public redirect" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ Root .htaccess missing" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DIAGNOSIS COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Recommended Solutions:" -ForegroundColor Yellow
Write-Host "1. If API works through /public/, update frontend to use:" -ForegroundColor White
Write-Host "   http://$ServerIP/exam-backend/public/api" -ForegroundColor Gray
Write-Host "2. Or fix .htaccess to redirect properly" -ForegroundColor White
Write-Host "3. Restart Apache after any changes" -ForegroundColor White
Write-Host ""