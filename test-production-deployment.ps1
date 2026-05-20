#!/usr/bin/env pwsh

Write-Host "========================================" -ForegroundColor Green
Write-Host "TESTING PRODUCTION DEPLOYMENT" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host ""
Write-Host "1. Checking production folder exists..." -ForegroundColor Yellow
if (Test-Path "C:\xampp\htdocs\exam-production") {
    Write-Host "✅ Production folder exists" -ForegroundColor Green
} else {
    Write-Host "❌ Production folder missing" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. Checking frontend assets deployed..." -ForegroundColor Yellow
if (Test-Path "C:\xampp\htdocs\exam-production\public\assets\UserManagement-DT9gf2oK.css") {
    Write-Host "✅ Latest UserManagement CSS deployed (DT9gf2oK)" -ForegroundColor Green
} else {
    Write-Host "❌ Latest CSS file missing" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "3. Checking Laravel setup..." -ForegroundColor Yellow
if (Test-Path "C:\xampp\htdocs\exam-production\.env") {
    Write-Host "✅ Environment file exists" -ForegroundColor Green
} else {
    Write-Host "❌ Environment file missing" -ForegroundColor Red
}

if (Test-Path "C:\xampp\htdocs\exam-production\bootstrap\cache\config.php") {
    Write-Host "✅ Laravel config cached" -ForegroundColor Green
} else {
    Write-Host "❌ Laravel config not cached" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Testing production URL..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/exam-production/" -TimeoutSec 10 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Production site accessible at http://localhost/exam-production/" -ForegroundColor Green
    } else {
        Write-Host "❌ Production site returned status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Cannot access production site: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "PRODUCTION DEPLOYMENT TEST COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Configure database settings in C:\xampp\htdocs\exam-production\.env" -ForegroundColor White
Write-Host "2. Create production database and import schema" -ForegroundColor White
Write-Host "3. Test login with admin credentials" -ForegroundColor White
Write-Host "4. Verify edit button is BLACK in User Management" -ForegroundColor White
Write-Host "5. Clear browser cache if needed" -ForegroundColor White

Write-Host ""
Write-Host "Production URL: http://localhost/exam-production/" -ForegroundColor Green
Write-Host ""