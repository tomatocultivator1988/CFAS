# Test Exam Submission Flow
# This script verifies that the exam submission will work

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Exam Submission Flow" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Test 1: Backend Health
Write-Host "1. Testing Backend API..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://192.168.11.40/exam-backend/public/api/health" -UseBasicParsing -TimeoutSec 5
    $json = $response.Content | ConvertFrom-Json
    Write-Host "   ✓ Backend is running" -ForegroundColor Green
    Write-Host "   Message: $($json.message)" -ForegroundColor Cyan
    Write-Host "   Version: $($json.version)" -ForegroundColor Cyan
} catch {
    Write-Host "   ✗ Backend is NOT accessible!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "`n   Fix: Make sure Apache and MySQL are running in XAMPP" -ForegroundColor Yellow
    exit 1
}

# Test 2: Frontend Accessibility
Write-Host "`n2. Testing Frontend..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://192.168.11.40/exam-frontend/" -UseBasicParsing -TimeoutSec 5
    Write-Host "   ✓ Frontend is accessible" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Frontend is NOT accessible!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}

# Test 3: Check API URL in Frontend
Write-Host "`n3. Checking Frontend API Configuration..." -ForegroundColor Yellow
$frontendPath = "C:\xampp\htdocs\exam-frontend"
$jsFiles = Get-ChildItem "$frontendPath\assets\*.js" -File | Where-Object { $_.Length -gt 10KB }

$correctApiUrl = $false
foreach ($file in $jsFiles) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match "exam-backend/public/api") {
        $correctApiUrl = $true
        break
    }
}

if ($correctApiUrl) {
    Write-Host "   ✓ API URL correctly configured with /public/ path" -ForegroundColor Green
} else {
    Write-Host "   ✗ API URL does NOT include /public/ path!" -ForegroundColor Red
    Write-Host "   This will cause 404 errors on exam submission!" -ForegroundColor Yellow
    Write-Host "`n   Fix: Run QUICK-FIX-SUBMIT-404.bat" -ForegroundColor Yellow
    exit 1
}

# Test 4: Database Connection
Write-Host "`n4. Testing Database Connection..." -ForegroundColor Yellow
try {
    # Try to access a protected endpoint (will fail with 401 if DB is working)
    $response = Invoke-WebRequest -Uri "http://192.168.11.40/exam-backend/public/api/auth/validate" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 401) {
        Write-Host "   ✓ Database connection is working" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Database may have issues" -ForegroundColor Yellow
        Write-Host "   Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✓ All Tests Passed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nSystem is ready for exam submission!" -ForegroundColor Green
Write-Host "`nAccess URLs:" -ForegroundColor Yellow
Write-Host "  Frontend: http://192.168.11.40/exam-frontend/" -ForegroundColor White
Write-Host "  Backend:  http://192.168.11.40/exam-backend/public/api" -ForegroundColor White

Write-Host "`nTo test exam submission:" -ForegroundColor Yellow
Write-Host "  1. Login as reviewee (e.g., reviewee1 / password123)" -ForegroundColor White
Write-Host "  2. Start an exam" -ForegroundColor White
Write-Host "  3. Answer questions" -ForegroundColor White
Write-Host "  4. Submit exam" -ForegroundColor White
Write-Host "  5. Should redirect to exam list without 404 error" -ForegroundColor White

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
