# Fix Paler Image on Login Page
# Diagnostic and fix script for missing Father Paler image

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  PALER IMAGE DIAGNOSTIC & FIX" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$imagePath = "Exam-Main\frontend\public\PalerImageFrontEndLogin.jpg"
$publicDir = "Exam-Main\frontend\public"

# Test 1: Check if file exists
Write-Host "[Test 1] Checking if image file exists..." -ForegroundColor Yellow
if (Test-Path $imagePath) {
    $fileInfo = Get-Item $imagePath
    Write-Host "  SUCCESS: Image file found!" -ForegroundColor Green
    Write-Host "  Location: $($fileInfo.FullName)" -ForegroundColor Gray
    Write-Host "  Size: $($fileInfo.Length) bytes" -ForegroundColor Gray
    Write-Host "  Last Modified: $($fileInfo.LastWriteTime)" -ForegroundColor Gray
} else {
    Write-Host "  ERROR: Image file NOT found!" -ForegroundColor Red
    Write-Host "  Expected location: $imagePath" -ForegroundColor Red
    exit 1
}

# Test 2: Check file permissions
Write-Host "`n[Test 2] Checking file permissions..." -ForegroundColor Yellow
try {
    $acl = Get-Acl $imagePath
    Write-Host "  SUCCESS: File is accessible" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Cannot access file permissions" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
}

# Test 3: List all images in public folder
Write-Host "`n[Test 3] Listing all images in public folder..." -ForegroundColor Yellow
$images = Get-ChildItem $publicDir -Filter "*.jpg","*.jpeg","*.png" -File
Write-Host "  Found $($images.Count) image files:" -ForegroundColor Green
foreach ($img in $images) {
    Write-Host "    - $($img.Name) ($($img.Length) bytes)" -ForegroundColor Gray
}

# Test 4: Check if dev server is running
Write-Host "`n[Test 4] Checking if dev server is running..." -ForegroundColor Yellow
$viteProcess = Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*vite*"
}
if ($viteProcess) {
    Write-Host "  SUCCESS: Dev server appears to be running" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Dev server may not be running" -ForegroundColor Yellow
    Write-Host "  Run: cd Exam-Main/frontend && npm run dev" -ForegroundColor Gray
}

# Test 5: Check LoginView.vue
Write-Host "`n[Test 5] Checking LoginView.vue configuration..." -ForegroundColor Yellow
$loginViewPath = "Exam-Main\frontend\src\views\LoginView.vue"
if (Test-Path $loginViewPath) {
    $content = Get-Content $loginViewPath -Raw
    if ($content -match 'PalerImageFrontEndLogin\.jpg') {
        Write-Host "  SUCCESS: LoginView.vue references the image" -ForegroundColor Green
        
        # Extract the image tag
        if ($content -match '<img[^>]*src="([^"]*PalerImageFrontEndLogin[^"]*)"') {
            Write-Host "  Image path in code: $($matches[1])" -ForegroundColor Gray
        }
    } else {
        Write-Host "  WARNING: LoginView.vue does not reference PalerImageFrontEndLogin.jpg" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ERROR: LoginView.vue not found" -ForegroundColor Red
}

# Solutions
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SOLUTIONS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "If the image is not showing on the login page, try these solutions:`n" -ForegroundColor White

Write-Host "Solution 1: Clear Browser Cache" -ForegroundColor Yellow
Write-Host "  - Press Ctrl+Shift+R (hard refresh)" -ForegroundColor Gray
Write-Host "  - Or clear browser cache completely`n" -ForegroundColor Gray

Write-Host "Solution 2: Restart Dev Server" -ForegroundColor Yellow
Write-Host "  - Stop the current dev server (Ctrl+C)" -ForegroundColor Gray
Write-Host "  - Run: cd Exam-Main/frontend" -ForegroundColor Gray
Write-Host "  - Run: npm run dev`n" -ForegroundColor Gray

Write-Host "Solution 3: Test Image Loading" -ForegroundColor Yellow
Write-Host "  - Copy test-paler-image.html to frontend/public/" -ForegroundColor Gray
Write-Host "  - Open: http://localhost:5173/test-paler-image.html" -ForegroundColor Gray
Write-Host "  - Check which test passes`n" -ForegroundColor Gray

Write-Host "Solution 4: Check Browser Console" -ForegroundColor Yellow
Write-Host "  - Open browser DevTools (F12)" -ForegroundColor Gray
Write-Host "  - Go to Console tab" -ForegroundColor Gray
Write-Host "  - Look for 404 errors or image loading errors`n" -ForegroundColor Gray

Write-Host "Solution 5: Verify Image Path" -ForegroundColor Yellow
Write-Host "  - Current path in LoginView.vue: /PalerImageFrontEndLogin.jpg" -ForegroundColor Gray
Write-Host "  - This should work if file is in frontend/public/" -ForegroundColor Gray
Write-Host "  - Vite automatically serves files from public/ folder`n" -ForegroundColor Gray

# Quick fix option
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  QUICK FIX" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$response = Read-Host "Do you want to copy the test file to public folder? (Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    $testFile = "Exam-Main\test-paler-image.html"
    $destFile = "Exam-Main\frontend\public\test-paler-image.html"
    
    if (Test-Path $testFile) {
        Copy-Item $testFile $destFile -Force
        Write-Host "`nSUCCESS: Test file copied!" -ForegroundColor Green
        Write-Host "Open: http://localhost:5173/test-paler-image.html" -ForegroundColor Cyan
    } else {
        Write-Host "`nERROR: test-paler-image.html not found" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  DIAGNOSTIC COMPLETE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Summary:" -ForegroundColor White
Write-Host "  Image file: EXISTS" -ForegroundColor Green
Write-Host "  Location: $imagePath" -ForegroundColor Gray
Write-Host "`nNext steps:" -ForegroundColor White
Write-Host "  1. Make sure dev server is running" -ForegroundColor Gray
Write-Host "  2. Hard refresh browser (Ctrl+Shift+R)" -ForegroundColor Gray
Write-Host "  3. Check browser console for errors" -ForegroundColor Gray
Write-Host "  4. Run test file if needed`n" -ForegroundColor Gray

Read-Host "Press Enter to exit"
