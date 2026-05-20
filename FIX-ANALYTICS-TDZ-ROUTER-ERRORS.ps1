# ============================================================================
# FIX ANALYTICS TDZ AND ROUTER ERRORS - DEPLOYMENT SCRIPT
# ============================================================================
# This script fixes critical TDZ (Temporal Dead Zone) bugs and router 
# navigation errors in the Analytics Dashboard
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Analytics Dashboard - TDZ & Router Fix" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to frontend directory
Set-Location "Exam-Main/frontend"

Write-Host "[1/5] Checking current build hash..." -ForegroundColor Yellow
$oldHash = Get-ChildItem "dist/assets" -Filter "AnalyticsDashboard-*.js" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Name
if ($oldHash) {
    Write-Host "   Old build: $oldHash" -ForegroundColor Gray
} else {
    Write-Host "   No previous build found" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[2/5] Rebuilding frontend..." -ForegroundColor Yellow
Write-Host "   Running: npm run build" -ForegroundColor Gray
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    Write-Host "Please check the error messages above and fix any issues." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[3/5] Verifying new build hash..." -ForegroundColor Yellow
$newHash = Get-ChildItem "dist/assets" -Filter "AnalyticsDashboard-*.js" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Name
if ($newHash) {
    Write-Host "   New build: $newHash" -ForegroundColor Green
    
    if ($oldHash -eq $newHash) {
        Write-Host ""
        Write-Host "WARNING: Build hash did not change!" -ForegroundColor Yellow
        Write-Host "This means the fix was not included in the build." -ForegroundColor Yellow
    } else {
        Write-Host "   ✓ Build hash changed successfully" -ForegroundColor Green
    }
} else {
    Write-Host "   ERROR: New build not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[4/5] Copying to Apache htdocs..." -ForegroundColor Yellow
$apachePath = "C:\Apache24\htdocs\exam-system"
if (Test-Path $apachePath) {
    Copy-Item -Path "dist\*" -Destination $apachePath -Recurse -Force
    Write-Host "   ✓ Files copied to Apache" -ForegroundColor Green
} else {
    Write-Host "   WARNING: Apache path not found: $apachePath" -ForegroundColor Yellow
    Write-Host "   Skipping Apache deployment" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[5/5] Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. Hard refresh your browser:" -ForegroundColor White
Write-Host "   - Windows/Linux: Ctrl + Shift + R" -ForegroundColor Gray
Write-Host "   - Mac: Cmd + Shift + R" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Open DevTools Network tab and verify:" -ForegroundColor White
Write-Host "   - Look for: $newHash" -ForegroundColor Gray
Write-Host "   - This confirms the new build is loaded" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Test the Analytics Dashboard:" -ForegroundColor White
Write-Host "   - Switch between sections (Overview, Exams, etc.)" -ForegroundColor Gray
Write-Host "   - Change time filters" -ForegroundColor Gray
Write-Host "   - Click refresh button" -ForegroundColor Gray
Write-Host "   - No router errors should appear in console" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

Set-Location "../.."
