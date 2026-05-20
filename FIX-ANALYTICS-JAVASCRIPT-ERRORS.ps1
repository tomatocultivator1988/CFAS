# Fix Analytics JavaScript Errors Script
Write-Host "FIXING ANALYTICS JAVASCRIPT ERRORS..." -ForegroundColor Red

# Step 1: Clear browser cache and force refresh
Write-Host "1. Clearing browser cache..." -ForegroundColor Yellow
try {
    # Clear Chrome cache
    $chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
    if (Test-Path $chromePath) {
        Get-ChildItem -Path $chromePath -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "Chrome cache cleared" -ForegroundColor Green
    }
    
    # Clear Edge cache
    $edgePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
    if (Test-Path $edgePath) {
        Get-ChildItem -Path $edgePath -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "Edge cache cleared" -ForegroundColor Green
    }
} catch {
    Write-Host "Could not clear browser cache (browsers may be running)" -ForegroundColor Yellow
}

# Step 2: Clear frontend build cache
Write-Host "2. Clearing frontend build cache..." -ForegroundColor Yellow
$frontendPath = "frontend"
if (Test-Path $frontendPath) {
    # Clear node_modules/.cache
    $cacheDir = "$frontendPath\node_modules\.cache"
    if (Test-Path $cacheDir) {
        Remove-Item -Path $cacheDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Node cache cleared" -ForegroundColor Green
    }
    
    # Clear dist directory
    $distDir = "$frontendPath\dist"
    if (Test-Path $distDir) {
        Remove-Item -Path $distDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Dist directory cleared" -ForegroundColor Green
    }
}

# Step 3: Rebuild frontend with fresh dependencies
Write-Host "3. Rebuilding frontend..." -ForegroundColor Yellow
Set-Location $frontendPath

try {
    # Install dependencies
    Write-Host "Installing dependencies..." -ForegroundColor Cyan
    npm install --silent
    
    # Build for production
    Write-Host "Building for production..." -ForegroundColor Cyan
    npm run build
    
    Write-Host "Frontend rebuilt successfully" -ForegroundColor Green
} catch {
    Write-Host "Error rebuilding frontend: $($_.Exception.Message)" -ForegroundColor Red
}

Set-Location ..

# Step 4: Copy to Apache htdocs
Write-Host "4. Deploying to Apache..." -ForegroundColor Yellow
$apacheHtdocs = "C:\xampp\htdocs\exam-frontend"
$frontendDist = "frontend\dist"

if (Test-Path $frontendDist) {
    try {
        # Remove old deployment
        if (Test-Path $apacheHtdocs) {
            Remove-Item -Path $apacheHtdocs -Recurse -Force
        }
        
        # Copy new build
        Copy-Item -Path $frontendDist -Destination $apacheHtdocs -Recurse -Force
        Write-Host "Deployed to Apache successfully" -ForegroundColor Green
    } catch {
        Write-Host "Error deploying to Apache: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "Frontend dist directory not found" -ForegroundColor Red
}

# Step 5: Restart Apache
Write-Host "5. Restarting Apache..." -ForegroundColor Yellow
try {
    # Stop Apache
    $apacheService = Get-Service "Apache2.4" -ErrorAction SilentlyContinue
    if ($apacheService -and $apacheService.Status -eq "Running") {
        Stop-Service "Apache2.4" -Force
        Start-Sleep -Seconds 2
    }
    
    # Start Apache
    Start-Service "Apache2.4"
    Write-Host "Apache restarted successfully" -ForegroundColor Green
} catch {
    Write-Host "Could not restart Apache service, try XAMPP Control Panel" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "ANALYTICS FIX COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Open browser and press Ctrl+F5 to force refresh" -ForegroundColor White
Write-Host "2. Clear browser data if errors persist:" -ForegroundColor White
Write-Host "   - Chrome: Settings > Privacy > Clear browsing data" -ForegroundColor White
Write-Host "   - Edge: Settings > Privacy > Clear browsing data" -ForegroundColor White
Write-Host "3. Try incognito/private browsing mode" -ForegroundColor White
Write-Host "4. Check browser console for any remaining errors" -ForegroundColor White
Write-Host ""
Write-Host "If errors persist, the issue may be in the backend API." -ForegroundColor Yellow
Write-Host "Check: http://localhost/exam-backend/public/api/health" -ForegroundColor White