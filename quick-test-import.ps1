# Quick Test Word Import
Write-Host "=== Testing Word Import ===" -ForegroundColor Cyan

# 1. Check backend
Write-Host "`nChecking backend..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://192.168.11.40/exam-backend/public/api/admin/exams" -Method GET -TimeoutSec 5
    Write-Host "✓ Backend is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Backend not running. Start XAMPP first!" -ForegroundColor Red
    exit
}

# 2. Clear cache
Write-Host "`nClearing Laravel cache..." -ForegroundColor Yellow
Set-Location "backend"
php artisan cache:clear | Out-Null
php artisan config:clear | Out-Null
php artisan route:clear | Out-Null
Write-Host "✓ Cache cleared" -ForegroundColor Green

# 3. Check route
Write-Host "`nChecking import route..." -ForegroundColor Yellow
$route = php artisan route:list | Select-String "import-docx"
if ($route) {
    Write-Host "✓ Import route found" -ForegroundColor Green
} else {
    Write-Host "✗ Import route not found!" -ForegroundColor Red
}

# 4. Check logs
Write-Host "`nChecking recent logs..." -ForegroundColor Yellow
$logFile = "storage\logs\laravel.log"
if (Test-Path $logFile) {
    $recentLogs = Get-Content $logFile -Tail 20
    $errors = $recentLogs | Select-String "ERROR|Exception|Failed"
    if ($errors) {
        Write-Host "⚠ Recent errors found:" -ForegroundColor Yellow
        $errors | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    } else {
        Write-Host "✓ No recent errors" -ForegroundColor Green
    }
}

Set-Location ".."

Write-Host "`n=== Test Complete ===" -ForegroundColor Cyan
Write-Host "`nBoss, ano ang specific error mo?" -ForegroundColor Yellow
Write-Host "1. Wala sang upload button?" -ForegroundColor White
Write-Host "2. May error after upload?" -ForegroundColor White
Write-Host "3. Progress bar stuck?" -ForegroundColor White
Write-Host "4. Questions not saving?" -ForegroundColor White
