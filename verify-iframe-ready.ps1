# Verify ML Iframe Dashboard is Ready to Deploy

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ML IFRAME DASHBOARD - PRE-DEPLOYMENT CHECK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check 1: MLDashboardIframe.vue exists
Write-Host "[1/5] Checking MLDashboardIframe.vue..." -NoNewline
if (Test-Path "frontend\src\views\admin\MLDashboardIframe.vue") {
    Write-Host " OK" -ForegroundColor Green
} else {
    Write-Host " MISSING!" -ForegroundColor Red
    $allGood = $false
}

# Check 2: Router configuration
Write-Host "[2/5] Checking router configuration..." -NoNewline
$routerContent = Get-Content "frontend\src\router\index.js" -Raw
if ($routerContent -match "MLDashboardIframe") {
    Write-Host " OK" -ForegroundColor Green
} else {
    Write-Host " NOT CONFIGURED!" -ForegroundColor Red
    $allGood = $false
}

# Check 3: Deployment script exists
Write-Host "[3/5] Checking deployment script..." -NoNewline
if (Test-Path "DEPLOY-ML-IFRAME-DASHBOARD.bat") {
    Write-Host " OK" -ForegroundColor Green
} else {
    Write-Host " MISSING!" -ForegroundColor Red
    $allGood = $false
}

# Check 4: Frontend dependencies
Write-Host "[4/5] Checking frontend setup..." -NoNewline
if (Test-Path "frontend\node_modules") {
    Write-Host " OK" -ForegroundColor Green
} else {
    Write-Host " NEED TO RUN: npm install" -ForegroundColor Yellow
    $allGood = $false
}

# Check 5: Python ML API
Write-Host "[5/5] Checking Python ML API..." -NoNewline
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/api/stats" -TimeoutSec 2 -ErrorAction Stop
    Write-Host " RUNNING" -ForegroundColor Green
} catch {
    Write-Host " NOT RUNNING" -ForegroundColor Yellow
    Write-Host "    Note: Python API should be started before viewing dashboard" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "STATUS: READY TO DEPLOY!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Run: .\DEPLOY-ML-IFRAME-DASHBOARD.bat" -ForegroundColor White
    Write-Host "2. Start Python API (if not running):" -ForegroundColor White
    Write-Host "   cd C:\Users\Hi\Desktop\review-center-ml-system-master" -ForegroundColor Gray
    Write-Host "   python dashboard_server.py" -ForegroundColor Gray
    Write-Host "3. Open: http://192.168.11.40/admin/ml-predictions" -ForegroundColor White
    Write-Host "4. Hard refresh: Ctrl + Shift + R" -ForegroundColor White
} else {
    Write-Host "STATUS: ISSUES FOUND!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please fix the issues above before deploying." -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
