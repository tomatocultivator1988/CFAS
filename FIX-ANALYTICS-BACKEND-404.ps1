# Fix Analytics Backend 404 Error
# This script diagnoses and fixes the analytics backend 404 issue

Write-Host "🔧 Fixing Analytics Backend 404 Error..." -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Step 1: Test current backend status
Write-Host "`n📋 Step 1: Testing backend connectivity..." -ForegroundColor Yellow

$testUrls = @(
    "http://192.168.11.40/exam-backend/public/api/health",
    "http://localhost/exam-backend/public/api/health",
    "http://127.0.0.1/exam-backend/public/api/health"
)

$workingUrl = $null
foreach ($url in $testUrls) {
    try {
        Write-Host "Testing: $url" -ForegroundColor Gray
        $response = Invoke-WebRequest -Uri $url -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Backend accessible at: $url" -ForegroundColor Green
            $workingUrl = $url -replace "/api/health", ""
            break
        }
    } catch {
        Write-Host "❌ Failed: $url" -ForegroundColor Red
    }
}

if (-not $workingUrl) {
    Write-Host "❌ Backend not accessible. Please ensure Apache/XAMPP is running." -ForegroundColor Red
    Write-Host "💡 Try running: START-CFAS-FINAL.bat" -ForegroundColor Yellow
    exit 1
}

# Step 2: Test analytics endpoints specifically
Write-Host "`n📋 Step 2: Testing analytics endpoints..." -ForegroundColor Yellow

$analyticsUrls = @(
    "$workingUrl/api/analytics/overview?timeFilter=all",
    "$workingUrl/api/analytics/exams?timeFilter=all"
)

$analyticsWorking = $false
foreach ($url in $analyticsUrls) {
    try {
        Write-Host "Testing: $url" -ForegroundColor Gray
        $response = Invoke-WebRequest -Uri $url -TimeoutSec 5 -ErrorAction Stop
        Write-Host "✅ Analytics endpoint working: Status $($response.StatusCode)" -ForegroundColor Green
        $analyticsWorking = $true
        break
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 401) {
            Write-Host "🔐 Authentication required (401) - This is expected" -ForegroundColor Yellow
            $analyticsWorking = $true
        } elseif ($statusCode -eq 404) {
            Write-Host "❌ Analytics endpoint not found (404)" -ForegroundColor Red
        } else {
            Write-Host "⚠️ Unexpected status: $statusCode" -ForegroundColor Yellow
        }
    }
}

# Step 3: Check if backend files are deployed
Write-Host "`n📋 Step 3: Checking backend deployment..." -ForegroundColor Yellow

$backendPaths = @(
    "C:\xampp\htdocs\exam-backend",
    "C:\Apache24\htdocs\exam-backend",
    "backend"
)

$backendPath = $null
foreach ($path in $backendPaths) {
    if (Test-Path $path) {
        $backendPath = $path
        Write-Host "✅ Found backend at: $path" -ForegroundColor Green
        break
    }
}

if (-not $backendPath) {
    Write-Host "❌ Backend files not found in expected locations" -ForegroundColor Red
    Write-Host "💡 Please deploy backend files to Apache htdocs directory" -ForegroundColor Yellow
    exit 1
}

# Step 4: Check if analytics routes exist
Write-Host "`n📋 Step 4: Checking analytics routes..." -ForegroundColor Yellow

$routesFile = "$backendPath\routes\api.php"
if (Test-Path $routesFile) {
    $routesContent = Get-Content $routesFile -Raw
    if ($routesContent -match "analytics.*overview") {
        Write-Host "✅ Analytics routes found in api.php" -ForegroundColor Green
    } else {
        Write-Host "❌ Analytics routes missing from api.php" -ForegroundColor Red
        Write-Host "💡 Need to add analytics routes to backend" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Routes file not found: $routesFile" -ForegroundColor Red
}

# Step 5: Check if analytics controller exists
Write-Host "`n📋 Step 5: Checking analytics controller..." -ForegroundColor Yellow

$controllerFile = "$backendPath\app\Http\Controllers\AnalyticsController.php"
if (Test-Path $controllerFile) {
    Write-Host "✅ AnalyticsController.php exists" -ForegroundColor Green
} else {
    Write-Host "❌ AnalyticsController.php missing" -ForegroundColor Red
    Write-Host "💡 Need to deploy analytics controller to backend" -ForegroundColor Yellow
}

# Step 6: Run direct PHP test
Write-Host "`n📋 Step 6: Running direct backend test..." -ForegroundColor Yellow

if (Test-Path "test-analytics-backend-direct.php") {
    Write-Host "Running PHP test script..." -ForegroundColor Gray
    try {
        $phpResult = php "test-analytics-backend-direct.php"
        Write-Host $phpResult -ForegroundColor White
    } catch {
        Write-Host "❌ Failed to run PHP test: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️ PHP test script not found" -ForegroundColor Yellow
}

# Step 7: Provide solutions
Write-Host "`n📋 Step 7: Recommended Solutions..." -ForegroundColor Yellow

if (-not $analyticsWorking) {
    Write-Host "`n🔧 SOLUTION 1: Deploy Analytics Backend Files" -ForegroundColor Green
    Write-Host "The analytics endpoints are returning 404, which means:" -ForegroundColor White
    Write-Host "1. Analytics routes are not deployed to the backend" -ForegroundColor White
    Write-Host "2. Analytics controller is missing" -ForegroundColor White
    Write-Host "3. Backend needs to be redeployed with analytics support" -ForegroundColor White
    
    Write-Host "`n📋 Quick Fix Commands:" -ForegroundColor Cyan
    Write-Host "1. Copy analytics files to backend:" -ForegroundColor White
    Write-Host "   xcopy /E /Y `"backend\*`" `"$backendPath\`"" -ForegroundColor Gray
    Write-Host "2. Restart Apache/XAMPP" -ForegroundColor White
    Write-Host "3. Test again with: php test-analytics-backend-direct.php" -ForegroundColor White
}

Write-Host "`n🔧 SOLUTION 2: Authentication Issue" -ForegroundColor Green
Write-Host "If endpoints return 401 (Authentication Required):" -ForegroundColor White
Write-Host "1. This is normal - analytics requires login" -ForegroundColor White
Write-Host "2. Frontend will handle authentication automatically" -ForegroundColor White
Write-Host "3. Test with actual login in browser" -ForegroundColor White

Write-Host "`n🔧 SOLUTION 3: Complete Backend Deployment" -ForegroundColor Green
Write-Host "For a complete fix:" -ForegroundColor White
Write-Host "1. Run: DEPLOY-BACKEND-TO-APACHE.ps1" -ForegroundColor Gray
Write-Host "2. Or manually copy all backend files to Apache" -ForegroundColor Gray
Write-Host "3. Ensure Apache is running and configured correctly" -ForegroundColor Gray

Write-Host "`n🎯 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Deploy backend files if missing" -ForegroundColor White
Write-Host "2. Restart Apache/XAMPP" -ForegroundColor White
Write-Host "3. Test analytics dashboard in browser with login" -ForegroundColor White
Write-Host "4. Check browser console for connection success" -ForegroundColor White

Write-Host "`nPress any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")