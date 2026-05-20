# Test CFAS System Launcher
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CFAS System Launcher - Validation Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allPassed = $true

# Test 1: Check launcher script
Write-Host "[1/6] Checking launcher script..." -ForegroundColor Yellow
$launcherPath = Join-Path $PSScriptRoot "CFAS-System-Launcher.ps1"
if (Test-Path $launcherPath) {
    Write-Host "  ✓ CFAS-System-Launcher.ps1 found" -ForegroundColor Green
} else {
    Write-Host "  ✗ CFAS-System-Launcher.ps1 NOT FOUND" -ForegroundColor Red
    $allPassed = $false
}
Write-Host ""

# Test 2: Check shortcut creator
Write-Host "[2/6] Checking shortcut creator..." -ForegroundColor Yellow
$shortcutCreatorPath = Join-Path $PSScriptRoot "Create-Desktop-Shortcut.ps1"
if (Test-Path $shortcutCreatorPath) {
    Write-Host "  ✓ Create-Desktop-Shortcut.ps1 found" -ForegroundColor Green
} else {
    Write-Host "  ✗ Create-Desktop-Shortcut.ps1 NOT FOUND" -ForegroundColor Red
    $allPassed = $false
}
Write-Host ""

# Test 3: Check CFAS logo
Write-Host "[3/6] Checking CFAS logo..." -ForegroundColor Yellow
$logoPath = Join-Path $PSScriptRoot "frontend\public\cfas-logo.jpg"
if (Test-Path $logoPath) {
    Write-Host "  ✓ CFAS logo found" -ForegroundColor Green
} else {
    Write-Host "  ⚠ CFAS logo not found (fallback will be used)" -ForegroundColor Yellow
}
Write-Host ""

# Test 4: Check XAMPP
Write-Host "[4/6] Checking XAMPP installation..." -ForegroundColor Yellow
if (Test-Path "C:\xampp") {
    Write-Host "  ✓ XAMPP found at C:\xampp" -ForegroundColor Green
} else {
    Write-Host "  ✗ XAMPP NOT FOUND at C:\xampp" -ForegroundColor Red
    $allPassed = $false
}
Write-Host ""

# Test 5: Check backend
Write-Host "[5/6] Checking backend directory..." -ForegroundColor Yellow
$backendPath = Join-Path $PSScriptRoot "backend"
if (Test-Path $backendPath) {
    Write-Host "  ✓ Backend directory found" -ForegroundColor Green
} else {
    Write-Host "  ✗ Backend directory NOT FOUND" -ForegroundColor Red
    $allPassed = $false
}
Write-Host ""

# Test 6: Check PHP
Write-Host "[6/6] Checking PHP availability..." -ForegroundColor Yellow
try {
    $phpCheck = & php -v 2>&1
    if ($phpCheck -match "PHP") {
        Write-Host "  ✓ PHP is available" -ForegroundColor Green
    } else {
        Write-Host "  ✗ PHP not found" -ForegroundColor Red
        $allPassed = $false
    }
} catch {
    Write-Host "  ✗ PHP not found" -ForegroundColor Red
    $allPassed = $false
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "✓ ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Run Create-Desktop-Shortcut.ps1" -ForegroundColor White
    Write-Host "2. Double-click desktop icon" -ForegroundColor White
    Write-Host "3. Click START SYSTEM button" -ForegroundColor White
} else {
    Write-Host "✗ SOME TESTS FAILED" -ForegroundColor Red
    Write-Host "Please fix the issues above." -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
pause
