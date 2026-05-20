# CFAS Login & Analytics Diagnostic Script
# Checks authentication and analytics connectivity issues

Write-Host "=== CFAS Login & Analytics Diagnostic ===" -ForegroundColor Cyan
Write-Host ""

# Check if backend is running
Write-Host "1. Checking Backend Server..." -ForegroundColor Yellow
try {
    $backendResponse = Invoke-WebRequest -Uri "http://localhost:8000/api/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "   ✓ Backend is running" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Backend is NOT running!" -ForegroundColor Red
    Write-Host "   Please start the backend first: cd backend; php artisan serve" -ForegroundColor Yellow
    exit 1
}

# Check if frontend is built
Write-Host ""
Write-Host "2. Checking Frontend Build..." -ForegroundColor Yellow
if (Test-Path "Exam-Main/frontend/dist") {
    Write-Host "   ✓ Frontend build exists" -ForegroundColor Green
} else {
    Write-Host "   ✗ Frontend not built!" -ForegroundColor Red
    Write-Host "   Please build frontend: cd frontend && npm run build" -ForegroundColor Yellow
    exit 1
}

# Check Apache deployment
Write-Host ""
Write-Host "3. Checking Apache Deployment..." -ForegroundColor Yellow
$apachePath = "C:\Apache24\htdocs\cfas"
if (Test-Path $apachePath) {
    Write-Host "   ✓ Apache deployment folder exists" -ForegroundColor Green
    
    # Check if files are recent
    $indexFile = Join-Path $apachePath "index.html"
    if (Test-Path $indexFile) {
        $fileAge = (Get-Date) - (Get-Item $indexFile).LastWriteTime
        if ($fileAge.TotalHours -lt 24) {
            Write-Host "   ✓ Deployment is recent (less than 24 hours old)" -ForegroundColor Green
        } else {
            Write-Host "   ⚠ Deployment is old ($([math]::Round($fileAge.TotalHours, 1)) hours)" -ForegroundColor Yellow
            Write-Host "   Consider redeploying if you made recent changes" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "   ✗ Apache deployment not found!" -ForegroundColor Red
    Write-Host "   Please deploy to Apache first" -ForegroundColor Yellow
}

# Test login endpoint
Write-Host ""
Write-Host "4. Testing Login Endpoint..." -ForegroundColor Yellow
try {
    $loginBody = @{
        username = "admin"
        password = "admin123"
    } | ConvertTo-Json

    $loginResponse = Invoke-WebRequest -Uri "http://localhost:8000/api/auth/login" `
        -Method POST `
        -Body $loginBody `
        -ContentType "application/json" `
        -TimeoutSec 10 `
        -ErrorAction Stop

    $loginData = $loginResponse.Content | ConvertFrom-Json
    
    if ($loginData.data.token) {
        Write-Host "   ✓ Login successful" -ForegroundColor Green
        $token = $loginData.data.token
        Write-Host "   Token: $($token.Substring(0, 20))..." -ForegroundColor Gray
        
        # Test analytics endpoint with token
        Write-Host ""
        Write-Host "5. Testing Analytics Endpoint..." -ForegroundColor Yellow
        try {
            $headers = @{
                "Authorization" = "Bearer $token"
                "Accept" = "application/json"
            }
            
            $analyticsResponse = Invoke-WebRequest -Uri "http://localhost:8000/api/analytics/overview" `
                -Method GET `
                -Headers $headers `
                -TimeoutSec 10 `
                -ErrorAction Stop
            
            Write-Host "   ✓ Analytics endpoint accessible" -ForegroundColor Green
            Write-Host "   Response: $($analyticsResponse.StatusCode)" -ForegroundColor Gray
        } catch {
            Write-Host "   ✗ Analytics endpoint failed!" -ForegroundColor Red
            Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
            
            if ($_.Exception.Response.StatusCode -eq 401) {
                Write-Host "   → Token is invalid or expired" -ForegroundColor Yellow
            } elseif ($_.Exception.Response.StatusCode -eq 404) {
                Write-Host "   → Analytics route not found" -ForegroundColor Yellow
            }
        }
        
    } else {
        Write-Host "   ✗ Login failed - no token received" -ForegroundColor Red
    }
} catch {
    Write-Host "   ✗ Login endpoint failed!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Check browser localStorage
Write-Host ""
Write-Host "6. Browser Storage Check..." -ForegroundColor Yellow
Write-Host "   Please check your browser's localStorage:" -ForegroundColor Gray
Write-Host "   1. Open browser DevTools (F12)" -ForegroundColor Gray
Write-Host "   2. Go to Application > Local Storage" -ForegroundColor Gray
Write-Host "   3. Look for 'auth_token' key" -ForegroundColor Gray
Write-Host "   4. If missing or invalid, you need to login again" -ForegroundColor Gray

# Check CORS configuration
Write-Host ""
Write-Host "7. Checking CORS Configuration..." -ForegroundColor Yellow
$envFile = "Exam-Main/backend/.env"
if (Test-Path $envFile) {
    $corsConfig = Get-Content $envFile | Select-String "FRONTEND_URL"
    if ($corsConfig) {
        Write-Host "   ✓ CORS configuration found" -ForegroundColor Green
        Write-Host "   $corsConfig" -ForegroundColor Gray
    } else {
        Write-Host "   ⚠ FRONTEND_URL not set in .env" -ForegroundColor Yellow
        Write-Host "   This might cause CORS issues" -ForegroundColor Yellow
    }
}

# Summary and recommendations
Write-Host ""
Write-Host "=== Diagnostic Summary ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Common Issues and Solutions:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Can't login after deployment:" -ForegroundColor White
Write-Host "   → Clear browser cache and localStorage" -ForegroundColor Gray
Write-Host "   → Try incognito/private browsing mode" -ForegroundColor Gray
Write-Host "   → Check if backend is running" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Analytics page not loading:" -ForegroundColor White
Write-Host "   → Login again to get fresh token" -ForegroundColor Gray
Write-Host "   → Check browser console for errors (F12)" -ForegroundColor Gray
Write-Host "   → Verify analytics routes in backend" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Token expired errors:" -ForegroundColor White
Write-Host "   → Logout and login again" -ForegroundColor Gray
Write-Host "   → Check token expiration time in backend config" -ForegroundColor Gray
Write-Host ""
Write-Host "4. CORS errors:" -ForegroundColor White
Write-Host "   - Update FRONTEND_URL in backend/.env" -ForegroundColor Gray
Write-Host "   - Restart backend after .env changes" -ForegroundColor Gray
Write-Host ""

Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "If login still fails:" -ForegroundColor Yellow
Write-Host "1. Clear browser data (Ctrl+Shift+Delete)" -ForegroundColor Gray
Write-Host "2. Restart backend: cd backend && php artisan serve" -ForegroundColor Gray
Write-Host "3. Redeploy frontend: npm run build && copy to Apache" -ForegroundColor Gray
Write-Host "4. Try accessing: http://localhost/cfas" -ForegroundColor Gray
Write-Host ""
Write-Host "For more help, check:" -ForegroundColor Yellow
Write-Host "- LOGIN-TROUBLESHOOTING-GUIDE.md" -ForegroundColor Gray
Write-Host "- Browser console (F12) for JavaScript errors" -ForegroundColor Gray
Write-Host ""
