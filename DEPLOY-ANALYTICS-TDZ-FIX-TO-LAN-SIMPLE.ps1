# ============================================================================
# DEPLOY ANALYTICS TDZ FIX TO LAN SERVER - SIMPLE VERSION
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DEPLOY ANALYTICS TDZ FIX TO LAN SERVER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "PROBLEM IDENTIFIED:" -ForegroundColor Red
Write-Host "   You're accessing: http://192.168.11.40/exam-frontend/admin/analytics" -ForegroundColor Red
Write-Host "   But the fix was only deployed locally!" -ForegroundColor Red
Write-Host "   LAN server still has: AnalyticsDashboard-B6x0QrGh.js (OLD)" -ForegroundColor Red
Write-Host ""

# Navigate to frontend directory
Set-Location "Exam-Main/frontend"

Write-Host "[1/4] Checking current build..." -ForegroundColor Yellow
$currentBuild = Get-ChildItem "dist/assets" -Filter "AnalyticsDashboard-*.js" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Name
if ($currentBuild) {
    Write-Host "   Current build: $currentBuild" -ForegroundColor Gray
    if ($currentBuild -like "*B8gPwN8Z*") {
        Write-Host "   Build contains TDZ fixes" -ForegroundColor Green
    } else {
        Write-Host "   Build may not contain fixes" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ERROR: No build found!" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

Write-Host ""
Write-Host "[2/4] Looking for LAN deployment paths..." -ForegroundColor Yellow

# Common LAN deployment paths
$lanPaths = @(
    "C:\Apache24\htdocs\exam-frontend",
    "C:\xampp\htdocs\exam-frontend",
    "C:\inetpub\wwwroot\exam-frontend"
)

$deployPath = $null
foreach ($path in $lanPaths) {
    if (Test-Path $path) {
        $deployPath = $path
        Write-Host "   Found LAN path: $path" -ForegroundColor Green
        break
    } else {
        Write-Host "   Not found: $path" -ForegroundColor Gray
    }
}

if (-not $deployPath) {
    Write-Host ""
    Write-Host "ERROR: Could not find LAN deployment path!" -ForegroundColor Red
    Write-Host ""
    Write-Host "MANUAL DEPLOYMENT REQUIRED:" -ForegroundColor Yellow
    Write-Host "1. Copy contents of: Exam-Main/frontend/dist/*" -ForegroundColor White
    Write-Host "2. To your LAN server where exam-frontend is hosted" -ForegroundColor White
    Write-Host "3. Overwrite existing files" -ForegroundColor White
    Write-Host "4. Restart your web server" -ForegroundColor White
    Set-Location "../.."
    exit 1
}

Write-Host ""
Write-Host "[3/4] Deploying to LAN server..." -ForegroundColor Yellow
try {
    Copy-Item -Path "dist\*" -Destination $deployPath -Recurse -Force
    Write-Host "   Files deployed successfully" -ForegroundColor Green
    
    # Verify deployment
    $lanBuild = Get-ChildItem "$deployPath\assets" -Filter "AnalyticsDashboard-*.js" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Name
    if ($lanBuild) {
        Write-Host "   LAN now has: $lanBuild" -ForegroundColor Green
        if ($lanBuild -like "*B8gPwN8Z*") {
            Write-Host "   SUCCESS: TDZ fixes deployed to LAN!" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "   ERROR: Failed to deploy: $($_.Exception.Message)" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

Write-Host ""
Write-Host "[4/4] Attempting to restart web server..." -ForegroundColor Yellow
# Try to restart Apache
$apacheService = Get-Service -Name "Apache*" -ErrorAction SilentlyContinue
if ($apacheService) {
    try {
        Restart-Service $apacheService.Name -Force
        Write-Host "   Apache restarted" -ForegroundColor Green
    } catch {
        Write-Host "   Could not restart Apache automatically" -ForegroundColor Yellow
    }
} else {
    Write-Host "   Apache service not found" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "LAN DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Red
Write-Host ""
Write-Host "1. CLEAR BROWSER CACHE:" -ForegroundColor White
Write-Host "   - Close all browsers" -ForegroundColor Gray
Write-Host "   - Open in INCOGNITO mode" -ForegroundColor Gray
Write-Host ""
Write-Host "2. ACCESS LAN URL:" -ForegroundColor White
Write-Host "   http://192.168.11.40/exam-frontend/admin/analytics" -ForegroundColor Gray
Write-Host ""
Write-Host "3. VERIFY IN DEVTOOLS:" -ForegroundColor White
Write-Host "   GOOD: AnalyticsDashboard-B8gPwN8Z.js" -ForegroundColor Green
Write-Host "   BAD:  AnalyticsDashboard-B6x0QrGh.js" -ForegroundColor Red
Write-Host ""
Write-Host "4. IF STILL OLD FILE:" -ForegroundColor White
Write-Host "   - Hard refresh: Ctrl + Shift + R" -ForegroundColor Gray
Write-Host "   - Add ?v=123 to URL to bypass cache" -ForegroundColor Gray
Write-Host ""

Set-Location "../.."