# CFAS Exam System - LAN Deployment with Unified Config
# This script builds and deploys the frontend to XAMPP for LAN access

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CFAS Exam System - LAN Deployment" -ForegroundColor Cyan
Write-Host "Unified Environment Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if XAMPP is installed
Write-Host "[1/6] Checking XAMPP installation..." -ForegroundColor Yellow
$xamppPath = "C:\xampp\htdocs"
if (-not (Test-Path $xamppPath)) {
    Write-Host "ERROR: XAMPP not found at $xamppPath" -ForegroundColor Red
    Write-Host "Please install XAMPP first!" -ForegroundColor Red
    exit 1
}
Write-Host "OK XAMPP found" -ForegroundColor Green
Write-Host ""

# Step 2: Navigate to frontend directory
Write-Host "[2/6] Navigating to frontend directory..." -ForegroundColor Yellow
$frontendPath = Join-Path $PSScriptRoot "frontend"
if (-not (Test-Path $frontendPath)) {
    Write-Host "ERROR: Frontend directory not found!" -ForegroundColor Red
    exit 1
}
Set-Location $frontendPath
Write-Host "OK In frontend directory" -ForegroundColor Green
Write-Host ""

# Step 3: Install dependencies
Write-Host "[3/6] Installing dependencies..." -ForegroundColor Yellow
Write-Host "Running: npm install" -ForegroundColor Gray
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: npm install failed!" -ForegroundColor Red
    exit 1
}
Write-Host "OK Dependencies installed" -ForegroundColor Green
Write-Host ""

# Step 4: Build for LAN (production mode with base path /)
Write-Host "[4/6] Building frontend for LAN..." -ForegroundColor Yellow
Write-Host "Building with base path: /" -ForegroundColor Gray
Write-Host "Environment: LAN (will auto-detect)" -ForegroundColor Gray

# Set environment variable for LAN build
$env:VITE_BASE_PATH = "/"
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "OK Build completed" -ForegroundColor Green
Write-Host ""

# Step 5: Deploy to XAMPP
Write-Host "[5/6] Deploying to XAMPP..." -ForegroundColor Yellow
$targetPath = "C:\xampp\htdocs\exam-frontend"

# Remove old deployment
if (Test-Path $targetPath) {
    Write-Host "Removing old deployment..." -ForegroundColor Gray
    Remove-Item -Path $targetPath -Recurse -Force
}

# Copy new build
Write-Host "Copying files to $targetPath..." -ForegroundColor Gray
$distPath = Join-Path $frontendPath "dist"
Copy-Item -Path $distPath -Destination $targetPath -Recurse -Force

Write-Host "OK Files deployed" -ForegroundColor Green
Write-Host ""

# Step 6: Get LAN IP address
Write-Host "[6/6] Getting network information..." -ForegroundColor Yellow
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*" }).IPAddress | Select-Object -First 1

if ($ipAddress) {
    Write-Host "OK LAN IP detected: $ipAddress" -ForegroundColor Green
} else {
    Write-Host "WARNING: Could not detect LAN IP automatically" -ForegroundColor Yellow
    $ipAddress = "YOUR-IP-ADDRESS"
}
Write-Host ""

# Display success message
Write-Host "========================================" -ForegroundColor Green
Write-Host "DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Access URLs:" -ForegroundColor Cyan
Write-Host "  Server PC:  http://localhost/exam-frontend/" -ForegroundColor White
Write-Host "  LAN Access: http://$ipAddress/exam-frontend/" -ForegroundColor White
Write-Host ""
Write-Host "Diagnostic Page:" -ForegroundColor Cyan
Write-Host "  http://$ipAddress/exam-frontend/diagnostic" -ForegroundColor White
Write-Host ""
Write-Host "Backend API:" -ForegroundColor Cyan
Write-Host "  Make sure backend is running on port 8000" -ForegroundColor White
Write-Host "  Auto-detected URL: http://$ipAddress:8000/api" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Start XAMPP (Apache)" -ForegroundColor White
Write-Host "  2. Start Laravel backend: php artisan serve --host=0.0.0.0" -ForegroundColor White
Write-Host "  3. Open diagnostic page to verify configuration" -ForegroundColor White
Write-Host "  4. Test login with Father Paler image" -ForegroundColor White
Write-Host ""
Write-Host "The system will automatically:" -ForegroundColor Green
Write-Host "  OK Detect LAN environment" -ForegroundColor White
Write-Host "  OK Use correct API endpoint (http://$ipAddress:8000/api)" -ForegroundColor White
Write-Host "  OK Load all images correctly" -ForegroundColor White
Write-Host "  OK Handle routing properly" -ForegroundColor White
Write-Host ""

# Return to original directory
Set-Location $PSScriptRoot
