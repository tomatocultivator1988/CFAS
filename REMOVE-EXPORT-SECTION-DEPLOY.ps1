# ============================================
# REMOVE EXPORT SECTION FROM ANALYTICS - DEPLOYMENT SCRIPT
# ============================================
# This script removes the export section and rebuilds/deploys to LAN
# Target: 192.168.11.40 environment
# ============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "REMOVE EXPORT SECTION - DEPLOYMENT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Navigate to frontend directory
Write-Host "[1/5] Navigating to frontend directory..." -ForegroundColor Yellow
Set-Location -Path "Exam-Main/frontend"

if (-not (Test-Path "package.json")) {
    Write-Host "ERROR: Not in frontend directory!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ In frontend directory" -ForegroundColor Green
Write-Host ""

# Step 2: Clean old build
Write-Host "[2/5] Cleaning old build files..." -ForegroundColor Yellow

if (Test-Path "dist") {
    Remove-Item -Path "dist" -Recurse -Force
    Write-Host "✓ Removed old dist folder" -ForegroundColor Green
} else {
    Write-Host "✓ No old dist folder found" -ForegroundColor Green
}

Write-Host ""

# Step 3: Install dependencies (if needed)
Write-Host "[3/5] Checking dependencies..." -ForegroundColor Yellow

if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install dependencies!" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "✓ Dependencies already installed" -ForegroundColor Green
}

Write-Host ""

# Step 4: Build for production
Write-Host "[4/5] Building frontend for production..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Gray

npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Build completed successfully" -ForegroundColor Green
Write-Host ""

# Step 5: Deploy to Apache
Write-Host "[5/5] Deploying to Apache (192.168.11.40)..." -ForegroundColor Yellow

$apachePath = "C:\Apache24\htdocs"

if (-not (Test-Path $apachePath)) {
    Write-Host "ERROR: Apache directory not found at $apachePath" -ForegroundColor Red
    Write-Host "Please update the script with the correct Apache path" -ForegroundColor Yellow
    exit 1
}

# Copy dist files to Apache
Write-Host "Copying files to Apache..." -ForegroundColor Gray
Copy-Item -Path "dist\*" -Destination $apachePath -Recurse -Force

Write-Host "✓ Files deployed to Apache" -ForegroundColor Green
Write-Host ""

# Step 6: Clear browser cache instructions
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: Clear browser cache to see changes!" -ForegroundColor Yellow
Write-Host ""
Write-Host "To clear cache in browser:" -ForegroundColor White
Write-Host "  1. Press Ctrl + Shift + Delete" -ForegroundColor Gray
Write-Host "  2. Select 'Cached images and files'" -ForegroundColor Gray
Write-Host "  3. Click 'Clear data'" -ForegroundColor Gray
Write-Host "  4. Refresh the page (Ctrl + F5)" -ForegroundColor Gray
Write-Host ""
Write-Host "Or use hard refresh: Ctrl + Shift + R" -ForegroundColor White
Write-Host ""
Write-Host "Access your site at: http://192.168.11.40" -ForegroundColor Cyan
Write-Host ""

# Return to root directory
Set-Location -Path "../.."
