# Quick Login Diagnostic Script
Write-Host "=== CFAS Login Diagnostic ===" -ForegroundColor Cyan
Write-Host ""

# Check backend
Write-Host "1. Checking Backend..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/api/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "   Backend is running" -ForegroundColor Green
} catch {
    Write-Host "   Backend is NOT running!" -ForegroundColor Red
    Write-Host "   Start it with: cd backend; php artisan serve" -ForegroundColor Yellow
}

# Check frontend build
Write-Host ""
Write-Host "2. Checking Frontend Build..." -ForegroundColor Yellow
if (Test-Path "frontend/dist") {
    Write-Host "   Frontend build exists" -ForegroundColor Green
} else {
    Write-Host "   Frontend NOT built!" -ForegroundColor Red
    Write-Host "   Build it with: cd frontend; npm run build" -ForegroundColor Yellow
}

# Check Apache
Write-Host ""
Write-Host "3. Checking Apache Deployment..." -ForegroundColor Yellow
if (Test-Path "C:\Apache24\htdocs\cfas") {
    Write-Host "   Apache deployment exists" -ForegroundColor Green
} else {
    Write-Host "   Apache deployment NOT found!" -ForegroundColor Red
}

# Test login
Write-Host ""
Write-Host "4. Testing Login..." -ForegroundColor Yellow
try {
    $body = @{
        username = "admin"
        password = "admin123"
    } | ConvertTo-Json

    $loginResp = Invoke-WebRequest -Uri "http://localhost:8000/api/auth/login" `
        -Method POST `
        -Body $body `
        -ContentType "application/json" `
        -TimeoutSec 10 `
        -ErrorAction Stop

    $data = $loginResp.Content | ConvertFrom-Json
    if ($data.data.token) {
        Write-Host "   Login successful!" -ForegroundColor Green
        $token = $data.data.token
        
        # Test analytics
        Write-Host ""
        Write-Host "5. Testing Analytics..." -ForegroundColor Yellow
        try {
            $headers = @{
                "Authorization" = "Bearer $token"
                "Accept" = "application/json"
            }
            
            $analyticsResp = Invoke-WebRequest -Uri "http://localhost:8000/api/analytics/overview" `
                -Method GET `
                -Headers $headers `
                -TimeoutSec 10 `
                -ErrorAction Stop
            
            Write-Host "   Analytics accessible!" -ForegroundColor Green
        } catch {
            Write-Host "   Analytics failed!" -ForegroundColor Red
            Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "   Login failed!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Quick Fix ===" -ForegroundColor Cyan
Write-Host "If login fails:" -ForegroundColor Yellow
Write-Host "1. Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor Gray
Write-Host "2. Try incognito mode (Ctrl+Shift+N)" -ForegroundColor Gray
Write-Host "3. Run: .\FIX-LOGIN-AFTER-DEPLOY.ps1" -ForegroundColor Gray
Write-Host ""
