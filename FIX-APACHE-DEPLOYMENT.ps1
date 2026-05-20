# CFAS Apache Deployment Fix
# This script fixes the Apache path issues and deploys properly

Write-Host "=== CFAS APACHE DEPLOYMENT FIX ===" -ForegroundColor Cyan

# Step 1: Build frontend
Write-Host "Step 1: Building frontend..." -ForegroundColor Yellow
Set-Location "Exam-Main/frontend"
npm run build --silent
Set-Location "../.."
Write-Host "✓ Build complete!" -ForegroundColor Green

# Step 2: Stop XAMPP Apache
Write-Host "Step 2: Stopping XAMPP Apache..." -ForegroundColor Yellow
Stop-Process -Name "httpd" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "apache" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "✓ Apache stopped" -ForegroundColor Green

# Step 3: Clear XAMPP htdocs
Write-Host "Step 3: Clearing XAMPP htdocs..." -ForegroundColor Yellow
if (Test-Path "C:\xampp\htdocs") {
    Remove-Item -Path "C:\xampp\htdocs\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✓ htdocs cleared" -ForegroundColor Green
} else {
    Write-Host "! XAMPP htdocs not found" -ForegroundColor Red
}

# Step 4: Deploy to XAMPP
Write-Host "Step 4: Deploying to XAMPP..." -ForegroundColor Yellow
if (Test-Path "Exam-Main/frontend/dist") {
    Copy-Item -Path "Exam-Main/frontend/dist/*" -Destination "C:\xampp\htdocs\" -Recurse -Force
    Write-Host "✓ Files deployed to XAMPP" -ForegroundColor Green
} else {
    Write-Host "! Build files not found" -ForegroundColor Red
}

# Step 5: Start XAMPP Apache
Write-Host "Step 5: Starting XAMPP Apache..." -ForegroundColor Yellow
if (Test-Path "C:\xampp\apache_start.bat") {
    Start-Process "C:\xampp\apache_start.bat" -WindowStyle Hidden -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    Write-Host "✓ XAMPP Apache started" -ForegroundColor Green
} else {
    Write-Host "! XAMPP start script not found" -ForegroundColor Red
}

# Step 6: Clear browser cache
Write-Host "Step 6: Clearing browser cache..." -ForegroundColor Yellow
Get-Process chrome, msedge, firefox -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

$edgeCachePaths = @(
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache", 
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\GPUCache"
)

foreach ($path in $edgeCachePaths) {
    if (Test-Path $path) {
        Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}
Write-Host "✓ Cache cleared!" -ForegroundColor Green

Write-Host ""
Write-Host "=== DEPLOYMENT COMPLETE ===" -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor White
Write-Host "1. Open your browser" -ForegroundColor White
Write-Host "2. Go to: http://localhost" -ForegroundColor White
Write-Host "3. Your application should be running!" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")