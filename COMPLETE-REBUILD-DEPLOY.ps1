# Complete Rebuild and Deploy Script
Write-Host "=== COMPLETE REBUILD & DEPLOY ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean old build
Write-Host "Step 1: Cleaning old build..." -ForegroundColor Yellow
if (Test-Path "Exam-Main/frontend/dist") {
    Remove-Item -Path "Exam-Main/frontend/dist" -Recurse -Force
    Write-Host "  ✓ Old build removed" -ForegroundColor Green
}

# Step 2: Rebuild frontend
Write-Host "`nStep 2: Rebuilding frontend..." -ForegroundColor Yellow
Set-Location "Exam-Main/frontend"
npm run build
Set-Location "../.."
Write-Host "  ✓ Build complete!" -ForegroundColor Green

# Step 3: Stop Apache
Write-Host "`nStep 3: Stopping Apache..." -ForegroundColor Yellow
Stop-Process -Name "httpd" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "  ✓ Apache stopped" -ForegroundColor Green

# Step 4: Clear Apache htdocs
Write-Host "`nStep 4: Clearing Apache htdocs..." -ForegroundColor Yellow
if (Test-Path "C:/Apache24/htdocs") {
    Remove-Item -Path "C:/Apache24/htdocs/*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  ✓ htdocs cleared" -ForegroundColor Green
}

# Step 5: Deploy new build
Write-Host "`nStep 5: Deploying new build..." -ForegroundColor Yellow
Copy-Item -Path "Exam-Main/frontend/dist/*" -Destination "C:/Apache24/htdocs/" -Recurse -Force
Write-Host "  ✓ Files deployed" -ForegroundColor Green

# Step 6: Start Apache
Write-Host "`nStep 6: Starting Apache..." -ForegroundColor Yellow
Start-Process "C:\xampp\apache_start.bat" -WindowStyle Hidden -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
Write-Host "  ✓ Apache started" -ForegroundColor Green

# Step 7: Close all browsers
Write-Host "`nStep 7: Closing all browsers..." -ForegroundColor Yellow
Get-Process chrome, msedge, firefox -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Write-Host "  ✓ Browsers closed" -ForegroundColor Green

# Step 8: Clear browser cache
Write-Host "`nStep 8: Clearing browser cache..." -ForegroundColor Yellow
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
Write-Host "  ✓ Cache cleared" -ForegroundColor Green

Write-Host ""
Write-Host "=== DEPLOYMENT COMPLETE ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Open your browser" -ForegroundColor White
Write-Host "2. Go to: http://localhost:8000/admin/analytics" -ForegroundColor White
Write-Host "3. The Export & Print section should be REMOVED!" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
