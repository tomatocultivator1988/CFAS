# Test Login Page Images
# Comprehensive test for Father Paler image and all login page assets

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  LOGIN PAGE IMAGES TEST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$frontendDir = "Exam-Main\frontend"
$publicDir = "$frontendDir\public"

# Test 1: Check all required image files
Write-Host "[Test 1] Checking required image files..." -ForegroundColor Yellow
$requiredImages = @(
    @{ Name = "PalerImageFrontEndLogin.jpg"; Required = $true },
    @{ Name = "cfas-logo.jpg"; Required = $true },
    @{ Name = "review-hub-logo.png"; Required = $true },
    @{ Name = "ISUFST-logo-PNG-1-1024x712-800x550.png"; Required = $false }
)

$allRequiredFilesExist = $true
foreach ($img in $requiredImages) {
    $path = Join-Path $publicDir $img.Name
    if (Test-Path $path) {
        $size = (Get-Item $path).Length
        Write-Host "  SUCCESS: $($img.Name) ($size bytes)" -ForegroundColor Green
    } else {
        if ($img.Required) {
            Write-Host "  ERROR: $($img.Name) NOT FOUND!" -ForegroundColor Red
            $allRequiredFilesExist = $false
        } else {
            Write-Host "  WARNING: $($img.Name) NOT FOUND (optional)" -ForegroundColor Yellow
        }
    }
}

if (-not $allRequiredFilesExist) {
    Write-Host "`nERROR: Some required image files are missing!" -ForegroundColor Red
    Write-Host "Please add the missing files to: $publicDir" -ForegroundColor Yellow
    exit 1
}

# Test 2: Check assetPath.js utility
Write-Host "`n[Test 2] Checking assetPath.js utility..." -ForegroundColor Yellow
$assetPathFile = "$frontendDir\src\utils\assetPath.js"
if (Test-Path $assetPathFile) {
    Write-Host "  SUCCESS: assetPath.js exists" -ForegroundColor Green
} else {
    Write-Host "  ERROR: assetPath.js NOT FOUND!" -ForegroundColor Red
    Write-Host "  This utility is required for proper image path handling" -ForegroundColor Red
}

# Test 3: Check LoginView.vue
Write-Host "`n[Test 3] Checking LoginView.vue configuration..." -ForegroundColor Yellow
$loginViewFile = "$frontendDir\src\views\LoginView.vue"
if (Test-Path $loginViewFile) {
    $content = Get-Content $loginViewFile -Raw
    
    # Check if using assetPath utility
    if ($content -match 'getPublicAssetPath') {
        Write-Host "  SUCCESS: Using getPublicAssetPath utility" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: Not using getPublicAssetPath utility" -ForegroundColor Yellow
    }
    
    # Check if using computed properties
    if ($content -match 'palerImagePath|cfasLogoPath|reviewHubLogoPath') {
        Write-Host "  SUCCESS: Using computed properties for image paths" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: Not using computed properties" -ForegroundColor Yellow
    }
    
    # Check if using :src binding
    if ($content -match ':src=') {
        Write-Host "  SUCCESS: Using Vue :src binding" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: Not using Vue :src binding" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ERROR: LoginView.vue NOT FOUND!" -ForegroundColor Red
}

# Test 4: Check Vite config
Write-Host "`n[Test 4] Checking Vite configuration..." -ForegroundColor Yellow
$viteConfigFile = "$frontendDir\vite.config.js"
if (Test-Path $viteConfigFile) {
    $viteContent = Get-Content $viteConfigFile -Raw
    if ($viteContent -match "base:\s*[`"']\/exam-frontend\/[`"']") {
        Write-Host "  INFO: Base path is set to '/exam-frontend/'" -ForegroundColor Cyan
        Write-Host "  This is correct for production deployment" -ForegroundColor Gray
    } else {
        Write-Host "  INFO: Base path is default '/'" -ForegroundColor Cyan
    }
}

# Test 5: Check if dev server is running
Write-Host "`n[Test 5] Checking dev server status..." -ForegroundColor Yellow
$viteProcess = Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*vite*"
}
if ($viteProcess) {
    Write-Host "  SUCCESS: Vite dev server is running" -ForegroundColor Green
    Write-Host "  PID: $($viteProcess.Id)" -ForegroundColor Gray
} else {
    Write-Host "  WARNING: Vite dev server is NOT running" -ForegroundColor Yellow
    Write-Host "  Run: cd $frontendDir && npm run dev" -ForegroundColor Gray
}

# Test 6: Check package.json scripts
Write-Host "`n[Test 6] Checking available npm scripts..." -ForegroundColor Yellow
$packageJsonFile = "$frontendDir\package.json"
if (Test-Path $packageJsonFile) {
    $packageJson = Get-Content $packageJsonFile -Raw | ConvertFrom-Json
    if ($packageJson.scripts.dev) {
        Write-Host "  SUCCESS: 'npm run dev' script available" -ForegroundColor Green
    }
    if ($packageJson.scripts.build) {
        Write-Host "  SUCCESS: 'npm run build' script available" -ForegroundColor Green
    }
}

# Summary and Instructions
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  INSTRUCTIONS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "How to test the login page images:`n" -ForegroundColor White

Write-Host "1. Start the development server:" -ForegroundColor Yellow
Write-Host "   cd $frontendDir" -ForegroundColor Gray
Write-Host "   npm run dev`n" -ForegroundColor Gray

Write-Host "2. Open your browser:" -ForegroundColor Yellow
Write-Host "   Development: http://localhost:5173/" -ForegroundColor Gray
Write-Host "   (Note: In dev mode, base path is ignored)`n" -ForegroundColor Gray

Write-Host "3. Check the login page:" -ForegroundColor Yellow
Write-Host "   - Father Paler photo should appear on the left" -ForegroundColor Gray
Write-Host "   - CFAS logo should appear on the right (top)" -ForegroundColor Gray
Write-Host "   - Review Hub logo should appear on the right (top)" -ForegroundColor Gray
Write-Host "   - ISUFST watermark should appear in background`n" -ForegroundColor Gray

Write-Host "4. Open browser DevTools (F12):" -ForegroundColor Yellow
Write-Host "   - Check Console tab for errors" -ForegroundColor Gray
Write-Host "   - Check Network tab for 404 errors" -ForegroundColor Gray
Write-Host "   - All images should return 200 OK`n" -ForegroundColor Gray

Write-Host "5. Hard refresh if needed:" -ForegroundColor Yellow
Write-Host "   - Press Ctrl+Shift+R to clear cache`n" -ForegroundColor Gray

# Troubleshooting
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  TROUBLESHOOTING" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "If images still don't appear:`n" -ForegroundColor White

Write-Host "Problem 1: Browser Cache" -ForegroundColor Yellow
Write-Host "  Solution: Press Ctrl+Shift+R (hard refresh)`n" -ForegroundColor Gray

Write-Host "Problem 2: Dev Server Not Running" -ForegroundColor Yellow
Write-Host "  Solution: cd $frontendDir" -ForegroundColor Gray
Write-Host "  Then run: npm run dev`n" -ForegroundColor Gray

Write-Host "Problem 3: Wrong URL" -ForegroundColor Yellow
Write-Host "  Development URL: http://localhost:5173/" -ForegroundColor Gray
Write-Host "  (Do NOT use /exam-frontend/ in development)`n" -ForegroundColor Gray

Write-Host "Problem 4: Node Modules Missing" -ForegroundColor Yellow
Write-Host "  Solution: cd $frontendDir" -ForegroundColor Gray
Write-Host "  Then run: npm install`n" -ForegroundColor Gray

Write-Host "Problem 5: Port Already in Use" -ForegroundColor Yellow
Write-Host "  Solution: Check if another process is using port 5173" -ForegroundColor Gray
Write-Host "  Or change port in vite.config.js`n" -ForegroundColor Gray

# Quick Actions
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  QUICK ACTIONS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$response = Read-Host "Do you want to start the dev server now? (Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    Write-Host "`nStarting dev server..." -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop the server`n" -ForegroundColor Gray
    
    Set-Location $frontendDir
    npm run dev
} else {
    Write-Host "`nTo start manually, run:" -ForegroundColor Cyan
    Write-Host "  cd $frontendDir" -ForegroundColor Gray
    Write-Host "  npm run dev`n" -ForegroundColor Gray
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  TEST COMPLETE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
