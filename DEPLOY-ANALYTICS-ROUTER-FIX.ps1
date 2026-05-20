# Deploy Analytics Router Fix to LAN
# This script fixes the JavaScript router error in Analytics Dashboard

Write-Host "=== DEPLOYING ANALYTICS ROUTER FIX TO LAN ===" -ForegroundColor Green
Write-Host "Target: 192.168.11.40" -ForegroundColor Yellow

# Navigate to frontend directory
Set-Location "Exam-Main/frontend"

Write-Host "`n1. Building frontend with router fixes..." -ForegroundColor Cyan
try {
    npm run build
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed"
    }
    Write-Host "✓ Frontend build successful" -ForegroundColor Green
} catch {
    Write-Host "✗ Build failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Deploying to LAN server..." -ForegroundColor Cyan
try {
    # Copy built files to Apache htdocs
    $sourceDir = "dist\*"
    $targetDir = "C:\xampp\htdocs\exam-frontend"
    
    # Ensure target directory exists
    if (!(Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force
        Write-Host "Created target directory: $targetDir" -ForegroundColor Yellow
    }
    
    # Copy files
    Copy-Item -Path $sourceDir -Destination $targetDir -Recurse -Force
    Write-Host "✓ Files copied to Apache htdocs" -ForegroundColor Green
    
    # Restart Apache to clear any cached files
    Write-Host "`n3. Restarting Apache..." -ForegroundColor Cyan
    Stop-Process -Name "httpd" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    # Start Apache
    $apachePath = "C:\xampp\apache\bin\httpd.exe"
    if (Test-Path $apachePath) {
        Start-Process -FilePath $apachePath -WindowStyle Hidden
        Write-Host "✓ Apache restarted" -ForegroundColor Green
    } else {
        Write-Host "⚠ Apache not found at expected path, please restart manually" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "✗ Deployment failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n4. Clearing browser cache..." -ForegroundColor Cyan
Write-Host "Please clear your browser cache and refresh the page at:" -ForegroundColor Yellow
Write-Host "http://192.168.11.40/exam-frontend/#/admin/analytics" -ForegroundColor White

Write-Host "`n=== ROUTER FIX DEPLOYMENT COMPLETE ===" -ForegroundColor Green
Write-Host "Changes made:" -ForegroundColor Cyan
Write-Host "- Added error handling to router.replace calls" -ForegroundColor White
Write-Host "- Fixed NavigationDuplicated errors" -ForegroundColor White
Write-Host "- Added try-catch blocks for export functionality" -ForegroundColor White
Write-Host "- Improved query parameter initialization" -ForegroundColor White

Write-Host "`nTest the fix by:" -ForegroundColor Yellow
Write-Host "1. Opening browser console (F12)" -ForegroundColor White
Write-Host "2. Navigating to Analytics Dashboard" -ForegroundColor White
Write-Host "3. Switching between sections" -ForegroundColor White
Write-Host "4. Changing time filters" -ForegroundColor White
Write-Host "5. Testing export functionality" -ForegroundColor White
Write-Host "6. Checking for JavaScript errors" -ForegroundColor White

# Return to original directory
Set-Location ".."
Set-Location ".."