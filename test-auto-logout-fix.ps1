# Test Auto-Logout Fix
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " TESTING AUTO-LOGOUT FIX" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if frontend files have the fix
Write-Host "[1/4] Checking frontend source code..." -ForegroundColor Yellow
$apiJsContent = Get-Content "frontend/src/services/api.js" -Raw

if ($apiJsContent -match "const basePath = import\.meta\.env\.BASE_URL") {
    Write-Host "  [OK] Redirect URL fix found" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Redirect URL fix NOT found" -ForegroundColor Red
}

if ($apiJsContent -match "TOKEN_CHECK_INTERVAL") {
    Write-Host "  [OK] Token validation system found" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Token validation system NOT found" -ForegroundColor Red
}

# Check backend configuration
Write-Host ""
Write-Host "[2/4] Checking backend configuration..." -ForegroundColor Yellow
$envContent = Get-Content "backend/.env" -Raw

if ($envContent -match "SESSION_TIMEOUT_MINUTES=120") {
    Write-Host "  [OK] Token lifetime increased to 120 minutes" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Token lifetime NOT updated" -ForegroundColor Red
}

# Check if built files exist
Write-Host ""
Write-Host "[3/4] Checking deployment status..." -ForegroundColor Yellow
if (Test-Path "C:\xampp\htdocs\exam-frontend\index.html") {
    Write-Host "  [OK] Frontend deployed to XAMPP" -ForegroundColor Green
    $buildDate = (Get-Item "C:\xampp\htdocs\exam-frontend\index.html").LastWriteTime
    Write-Host "  Last deployed: $buildDate" -ForegroundColor Gray
} else {
    Write-Host "  [FAIL] Frontend NOT deployed to XAMPP" -ForegroundColor Red
    Write-Host "  Run FIX-AUTO-LOGOUT.bat to deploy" -ForegroundColor Yellow
}

# Test API endpoint
Write-Host ""
Write-Host "[4/4] Testing backend API..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://192.168.11.40/exam-backend/public/api/health" -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "  [OK] Backend API is running" -ForegroundColor Green
    }
} catch {
    Write-Host "  [FAIL] Backend API not accessible" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " NEXT STEPS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Run FIX-AUTO-LOGOUT.bat to deploy" -ForegroundColor White
Write-Host "2. Clear browser cache" -ForegroundColor White
Write-Host "3. Login at http://192.168.11.40/exam-frontend" -ForegroundColor White
Write-Host "4. Test for 30+ minutes" -ForegroundColor White
Write-Host ""
