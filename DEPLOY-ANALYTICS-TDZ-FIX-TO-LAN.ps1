# ============================================================================
# DEPLOY ANALYTICS TDZ FIX TO LAN SERVER
# ============================================================================
# This script deploys the fixed Analytics Dashboard to the LAN server
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

Write-Host "[1/5] Checking current build..." -ForegroundColor Yellow
$currentBuild = Get-ChildItem "dist/assets" -Filter "AnalyticsDashboard-*.js" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Name
if ($currentBuild) {
    Write-Host "   Current build: $currentBuild" -ForegroundColor Gray
    if ($currentBuild -like "*B8gPwN8Z*") {
        Write-Host "   ✓ Build contains TDZ fixes" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Build may not contain fixes" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ERROR: No build found! Running build first..." -ForegroundColor Red
    npm run build
}

Write-Host ""
Write-Host "[2/5] Identifying LAN deployment paths..." -ForegroundColor Yellow

# Common LAN deployment paths
$lanPaths = @(
    "\\192.168.11.40\exam-frontend",
    "\\192.168.11.40\c$\Apache24\htdocs\exam-frontend",
    "\\192.168.11.40\c$\xampp\htdocs\exam-frontend",
    "\\192.168.11.40\c$\inetpub\wwwroot\exam-frontend",
    "C:\Apache24\htdocs\exam-frontend",
    "C:\xampp\htdocs\exam-frontend"
)

$deployPath = $null
foreach ($path in $lanPaths) {
    if (Test-Path $path) {
        $deployPath = $path
        Write-Host "   ✓ Found LAN path: $path" -ForegroundColor Green
        break
    } else {
        Write-Host "   - Not found: $path" -ForegroundColor Gray
    }
}

if (-not $deployPath) {
    Write-Host ""
    Write-Host "ERROR: Could not find LAN deployment path!" -ForegroundColor Red
    Write-Host "Please manually copy the dist folder to your LAN server." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Manual steps:" -ForegroundColor White
    Write-Host "1. Copy contents of: Exam-Main/frontend/dist/*" -ForegroundColor Gray
    Write-Host "2. To LAN server path where exam-frontend is hosted" -ForegroundColor Gray
    Write-Host "3. Overwrite existing files" -ForegroundColor Gray
    Set-Location "../.."
    exit 1
}

Write-Host ""
Write-Host "[3/5] Backing up current LAN deployment..." -ForegroundColor Yellow
$backupPath = "$deployPath-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
try {
    Copy-Item -Path $deployPath -Destination $backupPath -Recurse -Force
    Write-Host "   ✓ Backup created: $backupPath" -ForegroundColor Green
} catch {
    Write-Host "   ⚠ Could not create backup: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[4/5] Deploying fixed build to LAN..." -ForegroundColor Yellow
try {
    # Copy all files from dist to LAN server
    Copy-Item -Path "dist\*" -Destination $deployPath -Recurse -Force
    Write-Host "   ✓ Files deployed to LAN server" -ForegroundColor Green
    
    # Verify the new build is there
    $lanBuild = Get-ChildItem "$deployPath\assets" -Filter "AnalyticsDashboard-*.js" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Name
    if ($lanBuild) {
        Write-Host "   ✓ LAN now has: $lanBuild" -ForegroundColor Green
        if ($lanBuild -like "*B8gPwN8Z*") {
            Write-Host "   ✅ SUCCESS: TDZ fixes deployed to LAN!" -ForegroundColor Green
        } else {
            Write-Host "   ⚠ WARNING: May not be the fixed version" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   ❌ ERROR: Failed to deploy to LAN: $($_.Exception.Message)" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

Write-Host ""
Write-Host "[5/5] Clearing LAN server cache..." -ForegroundColor Yellow
# Try to clear IIS cache if it exists
try {
    if (Get-Command "iisreset" -ErrorAction SilentlyContinue) {
        iisreset /noforce
        Write-Host "   ✓ IIS cache cleared" -ForegroundColor Green
    }
} catch {
    Write-Host "   - IIS not available" -ForegroundColor Gray
}

# Try to clear Apache cache
$apacheService = Get-Service -Name "Apache*" -ErrorAction SilentlyContinue
if ($apacheService) {
    try {
        Restart-Service $apacheService.Name -Force
        Write-Host "   ✓ Apache restarted" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠ Could not restart Apache" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "LAN DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "🔥 CRITICAL NEXT STEPS:" -ForegroundColor Red
Write-Host ""
Write-Host "1. CLEAR YOUR BROWSER CACHE AGAIN:" -ForegroundColor White
Write-Host "   - Close all browser windows" -ForegroundColor Gray
Write-Host "   - Open in INCOGNITO mode" -ForegroundColor Gray
Write-Host ""
Write-Host "2. ACCESS THE LAN URL:" -ForegroundColor White
Write-Host "   http://192.168.11.40/exam-frontend/admin/analytics" -ForegroundColor Gray
Write-Host ""
Write-Host "3. VERIFY IN DEVTOOLS NETWORK TAB:" -ForegroundColor White
Write-Host "   ✅ GOOD: AnalyticsDashboard-B8gPwN8Z.js" -ForegroundColor Green
Write-Host "   ❌ BAD:  AnalyticsDashboard-B6x0QrGh.js" -ForegroundColor Red
Write-Host ""
Write-Host "4. IF STILL SHOWING OLD FILE:" -ForegroundColor White
Write-Host "   - Hard refresh: Ctrl + Shift + R" -ForegroundColor Gray
Write-Host "   - Or add ?v=$(Get-Date -Format 'yyyyMMddHHmmss') to URL" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

Set-Location "../.."