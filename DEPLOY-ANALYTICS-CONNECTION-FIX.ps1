# Deploy Analytics Dashboard Connection Fix
# This script rebuilds the frontend with the connection fixes

Write-Host "🔧 Deploying Analytics Dashboard Connection Fix..." -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Check if we're in the right directory
if (-not (Test-Path "frontend")) {
    Write-Host "❌ Error: frontend directory not found. Please run this script from the Exam-Main directory." -ForegroundColor Red
    exit 1
}

# Step 1: Verify our fixes are in place
Write-Host "`n📋 Step 1: Verifying fixes are in place..." -ForegroundColor Yellow

$filesToCheck = @(
    "frontend/src/config/environmentDetector.js",
    "frontend/src/config/configManager.js", 
    "frontend/src/services/analyticsApi.js"
)

foreach ($file in $filesToCheck) {
    if (Test-Path $file) {
        Write-Host "✅ Found: $file" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing: $file" -ForegroundColor Red
        exit 1
    }
}

# Step 2: Check for Apache backend detection in environmentDetector.js
Write-Host "`n🔍 Step 2: Checking for Apache backend detection..." -ForegroundColor Yellow

$envDetectorContent = Get-Content "frontend/src/config/environmentDetector.js" -Raw
if ($envDetectorContent -match "detectApacheBackend" -and $envDetectorContent -match "192\.168\.11\.40") {
    Write-Host "✅ Apache backend detection found in environmentDetector.js" -ForegroundColor Green
} else {
    Write-Host "❌ Apache backend detection not found in environmentDetector.js" -ForegroundColor Red
    Write-Host "Please ensure the environment detector has been updated with Apache detection logic." -ForegroundColor Red
    exit 1
}

# Step 3: Check for ConfigManager integration in analyticsApi.js
Write-Host "`n🔍 Step 3: Checking for ConfigManager integration..." -ForegroundColor Yellow

$analyticsApiContent = Get-Content "frontend/src/services/analyticsApi.js" -Raw
if ($analyticsApiContent -match "ConfigManager" -and $analyticsApiContent -notmatch "localhost:8000") {
    Write-Host "✅ ConfigManager integration found in analyticsApi.js" -ForegroundColor Green
} else {
    Write-Host "❌ ConfigManager integration not found or hardcoded URLs still present" -ForegroundColor Red
    Write-Host "Please ensure analyticsApi.js has been updated to use ConfigManager" -ForegroundColor Red
    exit 1
}

# Step 4: Navigate to frontend directory
Write-Host "`n📁 Step 4: Navigating to frontend directory..." -ForegroundColor Yellow
Set-Location frontend

# Step 5: Install dependencies (if needed)
Write-Host "`n📦 Step 5: Checking dependencies..." -ForegroundColor Yellow
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
        Set-Location ..
        exit 1
    }
} else {
    Write-Host "✅ Dependencies already installed" -ForegroundColor Green
}

# Step 6: Build the frontend
Write-Host "`n🔨 Step 6: Building frontend with fixes..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Gray

npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Frontend build failed" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Write-Host "✅ Frontend build completed successfully" -ForegroundColor Green

# Step 7: Copy built files to Apache directory (if exists)
Write-Host "`n📋 Step 7: Deploying to Apache..." -ForegroundColor Yellow

$apachePaths = @(
    "C:\xampp\htdocs\exam-frontend",
    "C:\Apache24\htdocs\exam-frontend",
    "..\apache-deployment\exam-frontend"
)

$deploymentPath = $null
foreach ($path in $apachePaths) {
    if (Test-Path $path) {
        $deploymentPath = $path
        break
    }
}

if ($deploymentPath) {
    Write-Host "Found Apache deployment path: $deploymentPath" -ForegroundColor Green
    
    # Backup existing deployment
    $backupPath = "$deploymentPath-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    if (Test-Path $deploymentPath) {
        Write-Host "Creating backup at: $backupPath" -ForegroundColor Yellow
        Copy-Item -Path $deploymentPath -Destination $backupPath -Recurse -Force
    }
    
    # Copy new build
    Write-Host "Copying new build to Apache..." -ForegroundColor Yellow
    if (Test-Path $deploymentPath) {
        Remove-Item -Path $deploymentPath -Recurse -Force
    }
    Copy-Item -Path "dist" -Destination $deploymentPath -Recurse -Force
    
    Write-Host "✅ Deployed to Apache successfully" -ForegroundColor Green
} else {
    Write-Host "⚠️ Apache deployment path not found. Manual deployment required." -ForegroundColor Yellow
    Write-Host "Please copy the 'dist' folder contents to your Apache htdocs/exam-frontend directory" -ForegroundColor Yellow
}

# Step 8: Return to original directory
Set-Location ..

# Step 9: Test the fix
Write-Host "`n🧪 Step 8: Testing the fix..." -ForegroundColor Yellow

Write-Host "Opening test page in browser..." -ForegroundColor Gray
Start-Process "test-analytics-connection-browser.html"

Write-Host "`n🎉 Deployment Complete!" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host "✅ Analytics connection fix has been deployed" -ForegroundColor Green
Write-Host "✅ Frontend rebuilt with updated configuration" -ForegroundColor Green
Write-Host "✅ Test page opened in browser" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Test the analytics dashboard in your browser" -ForegroundColor White
Write-Host "2. Check browser console - should see Apache backend detection" -ForegroundColor White
Write-Host "3. Verify no more 'localhost:8000' connection attempts" -ForegroundColor White
Write-Host "4. Confirm analytics data loads successfully" -ForegroundColor White
Write-Host ""
Write-Host "🔧 If issues persist:" -ForegroundColor Yellow
Write-Host "- Clear browser cache and hard refresh (Ctrl+Shift+R)" -ForegroundColor White
Write-Host "- Check that Apache backend is running at 192.168.11.40" -ForegroundColor White
Write-Host "- Use the test files to diagnose connection issues" -ForegroundColor White

Write-Host "`nPress any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")