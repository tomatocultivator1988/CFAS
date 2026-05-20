# Diagnose Analytics Dashboard Connection Issues
# This script helps identify why the analytics dashboard is still connecting to localhost:8000

Write-Host "🔍 Analytics Dashboard Connection Diagnostics" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Check 1: Verify source files have been updated
Write-Host "`n📋 Check 1: Source File Updates" -ForegroundColor Yellow

$sourceFiles = @{
    "environmentDetector.js" = "frontend/src/config/environmentDetector.js"
    "configManager.js" = "frontend/src/config/configManager.js"
    "analyticsApi.js" = "frontend/src/services/analyticsApi.js"
}

foreach ($name in $sourceFiles.Keys) {
    $file = $sourceFiles[$name]
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        Write-Host "✅ $name exists" -ForegroundColor Green
        
        # Check for specific fixes
        switch ($name) {
            "environmentDetector.js" {
                if ($content -match "detectApacheBackend") {
                    Write-Host "  ✅ Apache backend detection found" -ForegroundColor Green
                } else {
                    Write-Host "  ❌ Apache backend detection missing" -ForegroundColor Red
                }
            }
            "configManager.js" {
                if ($content -match "apache.*192\.168\.11\.40") {
                    Write-Host "  ✅ Apache configuration found" -ForegroundColor Green
                } else {
                    Write-Host "  ❌ Apache configuration missing" -ForegroundColor Red
                }
            }
            "analyticsApi.js" {
                if ($content -match "ConfigManager" -and $content -notmatch "localhost:8000") {
                    Write-Host "  ✅ ConfigManager integration found, no hardcoded URLs" -ForegroundColor Green
                } else {
                    Write-Host "  ❌ Still has hardcoded URLs or missing ConfigManager" -ForegroundColor Red
                }
            }
        }
    } else {
        Write-Host "❌ $name missing" -ForegroundColor Red
    }
}

# Check 2: Look for built/compiled files
Write-Host "`n📋 Check 2: Built Files" -ForegroundColor Yellow

$builtPaths = @(
    "frontend/dist",
    "C:\xampp\htdocs\exam-frontend",
    "C:\Apache24\htdocs\exam-frontend"
)

foreach ($path in $builtPaths) {
    if (Test-Path $path) {
        Write-Host "✅ Found built files at: $path" -ForegroundColor Green
        
        # Check if built files contain old URLs
        $jsFiles = Get-ChildItem -Path $path -Recurse -Filter "*.js" | Select-Object -First 5
        $hasOldUrls = $false
        
        foreach ($jsFile in $jsFiles) {
            $content = Get-Content $jsFile.FullName -Raw -ErrorAction SilentlyContinue
            if ($content -match "localhost:8000") {
                $hasOldUrls = $true
                break
            }
        }
        
        if ($hasOldUrls) {
            Write-Host "  ❌ Built files still contain 'localhost:8000'" -ForegroundColor Red
            Write-Host "  💡 Solution: Rebuild frontend with: npm run build" -ForegroundColor Yellow
        } else {
            Write-Host "  ✅ Built files appear to be updated" -ForegroundColor Green
        }
    } else {
        Write-Host "⚠️ Not found: $path" -ForegroundColor Yellow
    }
}

# Check 3: Test Apache backend connectivity
Write-Host "`n📋 Check 3: Apache Backend Connectivity" -ForegroundColor Yellow

$apacheUrls = @(
    "http://192.168.11.40/exam-backend/public/api/health",
    "http://localhost/exam-backend/public/api/health",
    "http://127.0.0.1/exam-backend/public/api/health"
)

foreach ($url in $apacheUrls) {
    try {
        $response = Invoke-WebRequest -Uri $url -TimeoutSec 3 -ErrorAction Stop
        Write-Host "✅ $url - Status: $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "❌ $url - Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Check 4: Browser cache issues
Write-Host "`n📋 Check 4: Browser Cache Recommendations" -ForegroundColor Yellow
Write-Host "If the dashboard still shows localhost:8000 errors:" -ForegroundColor White
Write-Host "1. Hard refresh: Ctrl+Shift+R (Chrome/Firefox)" -ForegroundColor White
Write-Host "2. Clear browser cache and cookies" -ForegroundColor White
Write-Host "3. Open in incognito/private mode" -ForegroundColor White
Write-Host "4. Check browser developer tools > Network tab" -ForegroundColor White

# Check 5: Provide solutions
Write-Host "`n📋 Check 5: Recommended Solutions" -ForegroundColor Yellow

Write-Host "If source files are missing fixes:" -ForegroundColor White
Write-Host "  Run: git pull origin main (if using git)" -ForegroundColor Gray
Write-Host "  Or manually apply the fixes from the spec" -ForegroundColor Gray

Write-Host "If built files are outdated:" -ForegroundColor White
Write-Host "  Run: DEPLOY-ANALYTICS-FIX.bat" -ForegroundColor Gray
Write-Host "  Or manually: cd frontend && npm run build" -ForegroundColor Gray

Write-Host "If Apache backend is not responding:" -ForegroundColor White
Write-Host "  Check XAMPP/Apache is running" -ForegroundColor Gray
Write-Host "  Verify backend files are deployed" -ForegroundColor Gray
Write-Host "  Check firewall/network settings" -ForegroundColor Gray

Write-Host "`n🎯 Quick Fix Command:" -ForegroundColor Green
Write-Host ".\DEPLOY-ANALYTICS-FIX.bat" -ForegroundColor White

Write-Host "`nPress any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")