# Verify LAN Deployment
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Verification" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$serverIP = "192.168.11.40"
$allGood = $true

# 1. Check frontend files
Write-Host "1. Checking Frontend Deployment..." -ForegroundColor Yellow
$indexPath = "C:\xampp\htdocs\exam-frontend\index.html"
if (Test-Path $indexPath) {
    $lastWrite = (Get-Item $indexPath).LastWriteTime
    Write-Host "   Frontend deployed: $lastWrite" -ForegroundColor Green
} else {
    Write-Host "   Frontend NOT deployed!" -ForegroundColor Red
    $allGood = $false
}

# 2. Check backend files
Write-Host "`n2. Checking Backend Deployment..." -ForegroundColor Yellow
$backendIndex = "C:\xampp\htdocs\exam-backend\public\index.php"
if (Test-Path $backendIndex) {
    Write-Host "   Backend exists" -ForegroundColor Green
} else {
    Write-Host "   Backend NOT found!" -ForegroundColor Red
    $allGood = $false
}

# 3. Check Apache
Write-Host "`n3. Checking Apache..." -ForegroundColor Yellow
$apache = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
if ($apache) {
    Write-Host "   Apache is running" -ForegroundColor Green
} else {
    Write-Host "   Apache is NOT running!" -ForegroundColor Red
    Write-Host "   Start Apache in XAMPP Control Panel" -ForegroundColor Yellow
    $allGood = $false
}

# 4. Check MySQL
Write-Host "`n4. Checking MySQL..." -ForegroundColor Yellow
$mysql = Get-Process -Name "mysqld" -ErrorAction SilentlyContinue
if ($mysql) {
    Write-Host "   MySQL is running" -ForegroundColor Green
} else {
    Write-Host "   MySQL is NOT running!" -ForegroundColor Red
    Write-Host "   Start MySQL in XAMPP Control Panel" -ForegroundColor Yellow
    $allGood = $false
}

# 5. Check frontend config
Write-Host "`n5. Checking Frontend Config..." -ForegroundColor Yellow
$frontendEnv = "Exam-Main/frontend/.env"
if (Test-Path $frontendEnv) {
    $apiUrl = Get-Content $frontendEnv | Select-String "VITE_API_URL"
    if ($apiUrl -match $serverIP) {
        Write-Host "   Frontend configured with correct IP" -ForegroundColor Green
    } else {
        Write-Host "   Frontend config may be wrong: $apiUrl" -ForegroundColor Yellow
    }
}

# 6. Check backend config
Write-Host "`n6. Checking Backend Config..." -ForegroundColor Yellow
$backendEnv = "Exam-Main/backend/.env"
if (Test-Path $backendEnv) {
    $appUrl = Get-Content $backendEnv | Select-String "^APP_URL="
    if ($appUrl -match $serverIP) {
        Write-Host "   Backend configured with correct IP" -ForegroundColor Green
    } else {
        Write-Host "   Backend config may be wrong: $appUrl" -ForegroundColor Yellow
    }
}

# 7. Test local access
Write-Host "`n7. Testing Local Access..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://$serverIP/exam-frontend" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "   Can access frontend (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   Cannot access frontend!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
    $allGood = $false
}

# 8. Test API
Write-Host "`n8. Testing Backend API..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://$serverIP/exam-backend/api/health" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "   Backend API responding (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   Backend API not responding" -ForegroundColor Yellow
    Write-Host "   This may be normal if /health endpoint doesn't exist" -ForegroundColor Gray
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "Status: ALL CHECKS PASSED!" -ForegroundColor Green
} else {
    Write-Host "Status: SOME ISSUES FOUND" -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nAccess URL:" -ForegroundColor Yellow
Write-Host "http://$serverIP/exam-frontend" -ForegroundColor Cyan

Write-Host "`nTest from another PC:" -ForegroundColor Yellow
Write-Host "1. Connect to same network" -ForegroundColor White
Write-Host "2. Open browser" -ForegroundColor White
Write-Host "3. Go to: http://$serverIP/exam-frontend" -ForegroundColor Cyan
Write-Host "4. Try logging in" -ForegroundColor White

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
