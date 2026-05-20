# ============================================
# CFAS Sidebar Footer Fix Deployment
# ============================================
# Fixes the sidebar footer (Auto Refresh, Admin User, Logout) 
# to stay fixed at bottom instead of moving when scrolling
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  CFAS Sidebar Footer Fix Deployment" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Navigate to frontend directory
Write-Host "[1/4] Navigating to frontend directory..." -ForegroundColor Yellow

# Get the script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Navigate to frontend
if (Test-Path "frontend") {
    Set-Location "frontend"
} else {
    Write-Host "ERROR: Frontend directory not found!" -ForegroundColor Red
    Write-Host "Current location: $(Get-Location)" -ForegroundColor Gray
    exit 1
}

if (-not (Test-Path "package.json")) {
    Write-Host "ERROR: package.json not found!" -ForegroundColor Red
    exit 1
}

Write-Host "SUCCESS: Frontend directory found" -ForegroundColor Green
Write-Host ""

# Step 2: Install dependencies (if needed)
Write-Host "[2/4] Checking dependencies..." -ForegroundColor Yellow
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install dependencies!" -ForegroundColor Red
        exit 1
    }
}
Write-Host "SUCCESS: Dependencies ready" -ForegroundColor Green
Write-Host ""

# Step 3: Build frontend
Write-Host "[3/4] Building frontend..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Gray

npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "SUCCESS: Frontend built successfully" -ForegroundColor Green
Write-Host ""

# Step 4: Deploy to XAMPP
Write-Host "[4/4] Deploying to XAMPP..." -ForegroundColor Yellow

$xamppPath = "C:\xampp\htdocs\exam-frontend"
$distPath = "dist"

# Check if XAMPP exists
if (-not (Test-Path "C:\xampp\htdocs")) {
    Write-Host "ERROR: XAMPP htdocs not found at C:\xampp\htdocs" -ForegroundColor Red
    Write-Host "Please install XAMPP first or check the path" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $distPath)) {
    Write-Host "ERROR: Build output not found!" -ForegroundColor Red
    exit 1
}

# Backup old deployment if exists
if (Test-Path $xamppPath) {
    Write-Host "Backing up old deployment..." -ForegroundColor Gray
    $backupPath = "$xamppPath.backup." + (Get-Date -Format "yyyyMMdd_HHmmss")
    Copy-Item $xamppPath $backupPath -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $xamppPath -Recurse -Force -ErrorAction SilentlyContinue
}

# Copy files
Write-Host "Copying files to XAMPP..." -ForegroundColor Gray
Copy-Item -Path $distPath -Destination $xamppPath -Recurse -Force

Write-Host "SUCCESS: Files deployed to XAMPP" -ForegroundColor Green
Write-Host ""

# Get IP address
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.*" } | Select-Object -First 1).IPAddress

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "What was fixed:" -ForegroundColor Cyan
Write-Host "- Sidebar is now fixed position" -ForegroundColor White
Write-Host "- Auto Refresh, Admin User, and Logout buttons stay at bottom" -ForegroundColor White
Write-Host "- Only navigation items scroll when there are many items" -ForegroundColor White
Write-Host ""
Write-Host "Deployment Location:" -ForegroundColor Cyan
Write-Host "- C:\xampp\htdocs\exam-frontend" -ForegroundColor White
Write-Host ""
Write-Host "Access your system at:" -ForegroundColor Cyan
Write-Host "- Local: http://localhost/exam-frontend/" -ForegroundColor White
if ($ipAddress) {
    Write-Host "- LAN:   http://$ipAddress/exam-frontend/" -ForegroundColor White
} else {
    Write-Host "- LAN:   http://YOUR-IP/exam-frontend/" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Make sure Apache is running in XAMPP Control Panel" -ForegroundColor White
Write-Host "2. Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
Write-Host "3. Hard refresh (Ctrl+F5)" -ForegroundColor White
Write-Host "4. Test by clicking different navigation items" -ForegroundColor White
Write-Host ""

# Return to root directory
Set-Location $scriptDir

Read-Host "Press Enter to exit"
