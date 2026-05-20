# Deploy Frontend to XAMPP for LAN Access
# Automatically builds and deploys the frontend

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  DEPLOY TO LAN (XAMPP)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$frontendDir = Join-Path $PSScriptRoot "frontend"
$xamppPath = "C:\xampp\htdocs\exam-frontend"

# Step 1: Check if frontend directory exists
Write-Host "[Step 1] Checking frontend directory..." -ForegroundColor Yellow
if (-not (Test-Path $frontendDir)) {
    Write-Host "  ERROR: Frontend directory not found!" -ForegroundColor Red
    Write-Host "  Looking for: $frontendDir" -ForegroundColor Gray
    exit 1
}
Write-Host "  SUCCESS: Frontend directory found" -ForegroundColor Green

# Step 2: Check if node_modules exists
Write-Host "`n[Step 2] Checking node_modules..." -ForegroundColor Yellow
$nodeModulesPath = Join-Path $frontendDir "node_modules"
if (-not (Test-Path $nodeModulesPath)) {
    Write-Host "  WARNING: node_modules not found" -ForegroundColor Yellow
    Write-Host "  Installing dependencies..." -ForegroundColor Cyan
    Push-Location $frontendDir
    npm install
    Pop-Location
}
Write-Host "  SUCCESS: node_modules found" -ForegroundColor Green

# Step 3: Build the frontend
Write-Host "`n[Step 3] Building frontend..." -ForegroundColor Yellow
Write-Host "  This may take a minute..." -ForegroundColor Gray
Push-Location $frontendDir
$buildResult = npm run build 2>&1
$buildExitCode = $LASTEXITCODE
Pop-Location

if ($buildExitCode -ne 0) {
    Write-Host "  ERROR: Build failed!" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Red
    exit 1
}
Write-Host "  SUCCESS: Build completed" -ForegroundColor Green

# Step 4: Check if dist folder was created
Write-Host "`n[Step 4] Checking build output..." -ForegroundColor Yellow
$distPath = Join-Path $frontendDir "dist"
if (-not (Test-Path $distPath)) {
    Write-Host "  ERROR: dist folder not found!" -ForegroundColor Red
    exit 1
}
Write-Host "  SUCCESS: dist folder created" -ForegroundColor Green

# Step 5: Check if images are in dist
Write-Host "`n[Step 5] Verifying images in build..." -ForegroundColor Yellow
$images = @(
    "PalerImageFrontEndLogin.jpg",
    "cfas-logo.jpg",
    "review-hub-logo.png"
)

$allImagesFound = $true
foreach ($img in $images) {
    if (Test-Path "$frontendDir\dist\$img") {
        Write-Host "  SUCCESS: $img found" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: $img not found in build" -ForegroundColor Yellow
        $allImagesFound = $false
    }
}

if (-not $allImagesFound) {
    Write-Host "`n  WARNING: Some images are missing from the build!" -ForegroundColor Yellow
    Write-Host "  Make sure images are in frontend/public/ folder" -ForegroundColor Yellow
}

# Step 6: Check if XAMPP htdocs exists
Write-Host "`n[Step 6] Checking XAMPP installation..." -ForegroundColor Yellow
if (-not (Test-Path "C:\xampp\htdocs")) {
    Write-Host "  ERROR: XAMPP htdocs not found!" -ForegroundColor Red
    Write-Host "  Please install XAMPP first" -ForegroundColor Yellow
    exit 1
}
Write-Host "  SUCCESS: XAMPP htdocs found" -ForegroundColor Green

# Step 7: Backup old deployment (if exists)
Write-Host "`n[Step 7] Backing up old deployment..." -ForegroundColor Yellow
if (Test-Path $xamppPath) {
    $backupPath = "$xamppPath.backup." + (Get-Date -Format "yyyyMMdd_HHmmss")
    Write-Host "  Creating backup: $backupPath" -ForegroundColor Gray
    Copy-Item $xamppPath $backupPath -Recurse -Force
    Write-Host "  SUCCESS: Backup created" -ForegroundColor Green
    
    # Remove old deployment
    Write-Host "  Removing old deployment..." -ForegroundColor Gray
    Remove-Item $xamppPath -Recurse -Force
} else {
    Write-Host "  No previous deployment found" -ForegroundColor Gray
}

# Step 8: Deploy to XAMPP
Write-Host "`n[Step 8] Deploying to XAMPP..." -ForegroundColor Yellow
try {
    Copy-Item "$frontendDir\dist" $xamppPath -Recurse -Force
    Write-Host "  SUCCESS: Files copied to XAMPP" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Failed to copy files!" -ForegroundColor Red
    Write-Host "  $_" -ForegroundColor Red
    exit 1
}

# Step 9: Verify deployment
Write-Host "`n[Step 9] Verifying deployment..." -ForegroundColor Yellow
$deployedImages = 0
foreach ($img in $images) {
    if (Test-Path "$xamppPath\$img") {
        Write-Host "  SUCCESS: $img deployed" -ForegroundColor Green
        $deployedImages++
    } else {
        Write-Host "  WARNING: $img not deployed" -ForegroundColor Yellow
    }
}

Write-Host "`n  Deployed $deployedImages of $($images.Count) images" -ForegroundColor Cyan

# Step 10: Get server IP address
Write-Host "`n[Step 10] Getting server IP address..." -ForegroundColor Yellow
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.*" } | Select-Object -First 1).IPAddress

if ($ipAddress) {
    Write-Host "  Server IP: $ipAddress" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Could not detect LAN IP address" -ForegroundColor Yellow
    Write-Host "  Run 'ipconfig' to find your IP address" -ForegroundColor Gray
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  DEPLOYMENT COMPLETE!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Deployment Summary:" -ForegroundColor White
Write-Host "  Location: $xamppPath" -ForegroundColor Gray
Write-Host "  Images: $deployedImages of $($images.Count) deployed" -ForegroundColor Gray

if ($ipAddress) {
    Write-Host "`nAccess URLs:" -ForegroundColor White
    Write-Host "  Local: http://localhost/exam-frontend/" -ForegroundColor Cyan
    Write-Host "  LAN:   http://$ipAddress/exam-frontend/" -ForegroundColor Cyan
} else {
    Write-Host "`nAccess URL:" -ForegroundColor White
    Write-Host "  Local: http://localhost/exam-frontend/" -ForegroundColor Cyan
    Write-Host "  LAN:   http://YOUR_IP/exam-frontend/" -ForegroundColor Yellow
}

Write-Host "`nNext Steps:" -ForegroundColor White
Write-Host "  1. Make sure Apache is running in XAMPP" -ForegroundColor Gray
Write-Host "  2. Open the URL in your browser" -ForegroundColor Gray
Write-Host "  3. Hard refresh (Ctrl+Shift+R) if needed" -ForegroundColor Gray
Write-Host "  4. Check browser console (F12) for errors`n" -ForegroundColor Gray

# Ask if user wants to open in browser
$response = Read-Host "Do you want to open in browser now? (Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    Start-Process "http://localhost/exam-frontend/"
}

Write-Host "`nDeployment complete!`n" -ForegroundColor Green
