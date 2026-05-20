#!/usr/bin/env pwsh

Write-Host "========================================" -ForegroundColor Green
Write-Host "FIXING LAN BACKEND API CONFIGURATION" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$ServerIP = "192.168.11.40"

Write-Host ""
Write-Host "1. Updating backend .env for LAN..." -ForegroundColor Yellow
$backendEnv = "C:\xampp\htdocs\exam-backend\.env"

if (Test-Path $backendEnv) {
    $content = Get-Content $backendEnv
    $newContent = @()
    
    foreach ($line in $content) {
        if ($line -match "^APP_URL=") {
            $newContent += "APP_URL=http://$ServerIP/exam-backend"
            Write-Host "   Updated APP_URL" -ForegroundColor Green
        }
        elseif ($line -match "^FRONTEND_URL=") {
            $newContent += "FRONTEND_URL=http://$ServerIP/exam-frontend"
            Write-Host "   Updated FRONTEND_URL" -ForegroundColor Green
        }
        elseif ($line -match "^DB_HOST=") {
            $newContent += "DB_HOST=127.0.0.1"
            Write-Host "   Updated DB_HOST" -ForegroundColor Green
        }
        elseif ($line -match "^DB_DATABASE=") {
            $newContent += "DB_DATABASE=review_center_exam"
            Write-Host "   Updated DB_DATABASE" -ForegroundColor Green
        }
        else {
            $newContent += $line
        }
    }
    
    Set-Content $backendEnv -Value $newContent
    Write-Host "   ✅ Backend .env updated" -ForegroundColor Green
} else {
    Write-Host "   ❌ Backend .env not found, creating..." -ForegroundColor Red
    
    # Copy from source
    if (Test-Path "backend\.env") {
        Copy-Item "backend\.env" $backendEnv
        Write-Host "   ✅ Copied .env from source" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Source .env not found" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "2. Updating CORS configuration..." -ForegroundColor Yellow
$corsConfig = "C:\xampp\htdocs\exam-backend\config\cors.php"

if (Test-Path $corsConfig) {
    $content = Get-Content $corsConfig -Raw
    
    # Add LAN IP to allowed origins if not present
    if ($content -notmatch [regex]::Escape("http://$ServerIP")) {
        $pattern = "('allowed_origins'\s*=>\s*\[)"
        $replacement = "`$1`n        'http://$ServerIP',`n        'http://$ServerIP/exam-frontend',"
        $content = $content -replace $pattern, $replacement
        Set-Content $corsConfig -Value $content
        Write-Host "   ✅ CORS updated for LAN" -ForegroundColor Green
    } else {
        Write-Host "   ✅ CORS already configured" -ForegroundColor Green
    }
} else {
    Write-Host "   ❌ CORS config not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Clearing Laravel cache..." -ForegroundColor Yellow
try {
    # Clear config cache
    $output = php "C:\xampp\htdocs\exam-backend\artisan" config:clear 2>&1
    Write-Host "   ✅ Config cache cleared" -ForegroundColor Green
    
    # Clear route cache
    $output = php "C:\xampp\htdocs\exam-backend\artisan" route:clear 2>&1
    Write-Host "   ✅ Route cache cleared" -ForegroundColor Green
    
    # Recreate caches
    $output = php "C:\xampp\htdocs\exam-backend\artisan" config:cache 2>&1
    Write-Host "   ✅ Config cache recreated" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Cache clear failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Updating frontend API configuration..." -ForegroundColor Yellow

# Check if frontend has built-in API URL or needs .env
$frontendIndex = "C:\xampp\htdocs\exam-frontend\index.html"
if (Test-Path $frontendIndex) {
    $indexContent = Get-Content $frontendIndex -Raw
    
    # Check if API URL is hardcoded in built files
    if ($indexContent -match "localhost.*exam-backend") {
        Write-Host "   ⚠️  Frontend has localhost API URLs - needs rebuild" -ForegroundColor Yellow
        
        # Update source frontend .env
        $sourceFrontendEnv = "frontend\.env"
        if (Test-Path $sourceFrontendEnv) {
            $content = Get-Content $sourceFrontendEnv
            $newContent = @()
            
            foreach ($line in $content) {
                if ($line -match "^VITE_API_URL=") {
                    $newContent += "VITE_API_URL=http://$ServerIP/exam-backend/api"
                    Write-Host "   Updated source VITE_API_URL" -ForegroundColor Green
                } else {
                    $newContent += $line
                }
            }
            
            Set-Content $sourceFrontendEnv -Value $newContent
            Write-Host "   ✅ Source frontend .env updated" -ForegroundColor Green
            Write-Host "   ⚠️  Need to rebuild frontend!" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ✅ Frontend API URLs look correct" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "5. Testing API connection..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://$ServerIP/exam-backend/api/login" -Method POST -TimeoutSec 5 -UseBasicParsing
    Write-Host "   ✅ API endpoint accessible" -ForegroundColor Green
} catch {
    Write-Host "   ❌ API endpoint error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Checking if Apache needs restart..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "LAN BACKEND FIX COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Restart Apache in XAMPP Control Panel" -ForegroundColor White
Write-Host "2. If still not working, rebuild frontend:" -ForegroundColor White
Write-Host "   cd frontend && npm run build" -ForegroundColor Gray
Write-Host "   xcopy /E /Y frontend\dist\* C:\xampp\htdocs\exam-frontend\" -ForegroundColor Gray
Write-Host "3. Test login at: http://$ServerIP/exam-frontend" -ForegroundColor White
Write-Host "4. Clear browser cache (Ctrl+F5)" -ForegroundColor White
Write-Host ""