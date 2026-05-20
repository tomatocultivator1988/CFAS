# Verify LAN Deployment for 192.168.11.40
# Checks if everything is ready for LAN access

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LAN DEPLOYMENT VERIFICATION" -ForegroundColor Cyan
Write-Host "  IP: 192.168.11.40" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check 1: XAMPP Installation
Write-Host "[1/7] Checking XAMPP installation..." -ForegroundColor Yellow
$xamppPath = "C:\xampp"
if (Test-Path $xamppPath) {
    Write-Host "  SUCCESS: XAMPP found at $xamppPath" -ForegroundColor Green
} else {
    Write-Host "  ERROR: XAMPP not found!" -ForegroundColor Red
    $allGood = $false
}
Write-Host ""

# Check 2: Frontend Deployment
Write-Host "[2/7] Checking frontend deployment..." -ForegroundColor Yellow
$frontendPath = "C:\xampp\htdocs\exam-frontend"
if (Test-Path $frontendPath) {
    Write-Host "  SUCCESS: Frontend deployed at $frontendPath" -ForegroundColor Green
    
    # Check index.html
    $indexPath = Join-Path $frontendPath "index.html"
    if (Test-Path $indexPath) {
        Write-Host "  SUCCESS: index.html exists" -ForegroundColor Green
    } else {
        Write-Host "  ERROR: index.html not found!" -ForegroundColor Red
        $allGood = $false
    }
} else {
    Write-Host "  ERROR: Frontend not deployed!" -ForegroundColor Red
    Write-Host "  Run: cd Exam-Main\frontend && npm run build" -ForegroundColor Yellow
    Write-Host "  Then: Copy-Item dist C:\xampp\htdocs\exam-frontend -Recurse" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# Check 3: Images
Write-Host "[3/7] Checking images..." -ForegroundColor Yellow
$images = @(
    @{Name="PalerImageFrontEndLogin.jpg"; MinSize=100000},
    @{Name="cfas-logo.jpg"; MinSize=500000},
    @{Name="review-hub-logo.png"; MinSize=300000}
)

$imagesOk = $true
foreach ($img in $images) {
    $imgPath = Join-Path $frontendPath $img.Name
    if (Test-Path $imgPath) {
        $size = (Get-Item $imgPath).Length
        if ($size -gt $img.MinSize) {
            Write-Host "  SUCCESS: $($img.Name) ($size bytes)" -ForegroundColor Green
        } else {
            Write-Host "  WARNING: $($img.Name) is too small ($size bytes)" -ForegroundColor Yellow
            $imagesOk = $false
        }
    } else {
        Write-Host "  ERROR: $($img.Name) not found!" -ForegroundColor Red
        $imagesOk = $false
        $allGood = $false
    }
}

if (-not $imagesOk) {
    Write-Host "  Images may not have been copied correctly during build" -ForegroundColor Yellow
}
Write-Host ""

# Check 4: Test Page
Write-Host "[4/7] Checking test page..." -ForegroundColor Yellow
$testPagePath = "C:\xampp\htdocs\test-lan-images.html"
if (Test-Path $testPagePath) {
    Write-Host "  SUCCESS: Test page deployed" -ForegroundColor Green
    Write-Host "  Access at: http://192.168.11.40/test-lan-images.html" -ForegroundColor Cyan
} else {
    Write-Host "  WARNING: Test page not found" -ForegroundColor Yellow
    Write-Host "  Copy: Exam-Main\test-lan-images.html to C:\xampp\htdocs\" -ForegroundColor Yellow
}
Write-Host ""

# Check 5: Apache Service
Write-Host "[5/7] Checking Apache service..." -ForegroundColor Yellow
$apacheService = Get-Service -Name "Apache*" -ErrorAction SilentlyContinue
if ($apacheService) {
    if ($apacheService.Status -eq "Running") {
        Write-Host "  SUCCESS: Apache is running" -ForegroundColor Green
    } else {
        Write-Host "  ERROR: Apache is not running!" -ForegroundColor Red
        Write-Host "  Start Apache from XAMPP Control Panel" -ForegroundColor Yellow
        $allGood = $false
    }
} else {
    Write-Host "  WARNING: Apache service not found (may be running as application)" -ForegroundColor Yellow
    Write-Host "  Check XAMPP Control Panel manually" -ForegroundColor Yellow
}
Write-Host ""

# Check 6: Backend
Write-Host "[6/7] Checking Laravel backend..." -ForegroundColor Yellow
$backendPath = "Exam-Main\backend"
if (Test-Path $backendPath) {
    Write-Host "  SUCCESS: Backend found at $backendPath" -ForegroundColor Green
    
    # Check if .env exists
    $envPath = Join-Path $backendPath ".env"
    if (Test-Path $envPath) {
        Write-Host "  SUCCESS: .env file exists" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: .env file not found" -ForegroundColor Yellow
    }
    
    Write-Host "  To start backend for LAN:" -ForegroundColor Cyan
    Write-Host "    Double-click: START-BACKEND-LAN.bat" -ForegroundColor White
    Write-Host "    Or run: cd Exam-Main\backend && php artisan serve --host=0.0.0.0 --port=8000" -ForegroundColor White
} else {
    Write-Host "  ERROR: Backend not found!" -ForegroundColor Red
    $allGood = $false
}
Write-Host ""

# Check 7: Firewall
Write-Host "[7/7] Checking firewall rules..." -ForegroundColor Yellow
$firewallRules = Get-NetFirewallRule -DisplayName "*Apache*" -ErrorAction SilentlyContinue
if ($firewallRules) {
    Write-Host "  SUCCESS: Apache firewall rules found" -ForegroundColor Green
} else {
    Write-Host "  WARNING: No Apache firewall rules found" -ForegroundColor Yellow
    Write-Host "  If LAN access doesn't work, run:" -ForegroundColor Yellow
    Write-Host "    netsh advfirewall firewall add rule name=`"Apache HTTP`" dir=in action=allow protocol=TCP localport=80" -ForegroundColor White
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($allGood) {
    Write-Host "SUCCESS: All critical checks passed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "1. Start backend: Double-click START-BACKEND-LAN.bat" -ForegroundColor White
    Write-Host "2. Test images: http://192.168.11.40/test-lan-images.html" -ForegroundColor Cyan
    Write-Host "3. Access login: http://192.168.11.40/exam-frontend/" -ForegroundColor Cyan
    Write-Host "4. Hard refresh: Ctrl+Shift+R" -ForegroundColor White
    Write-Host ""
    Write-Host "If images don't load, press F12 and check Console for errors" -ForegroundColor Yellow
} else {
    Write-Host "ERROR: Some checks failed!" -ForegroundColor Red
    Write-Host "Please fix the errors above before testing" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Quick fix:" -ForegroundColor Yellow
    Write-Host "  cd Exam-Main\frontend" -ForegroundColor White
    Write-Host "  npm run build" -ForegroundColor White
    Write-Host "  Copy-Item dist C:\xampp\htdocs\exam-frontend -Recurse -Force" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Keep window open
Read-Host "Press Enter to close"
