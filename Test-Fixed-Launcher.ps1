# ============================================================================
# Test Fixed CFAS Launcher
# This script tests all the fixed launcher components
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CFAS Launcher Fix Validation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$testsPassed = 0
$testsFailed = 0

# Test 1: Check if fixed files exist
Write-Host "Test 1: Checking if fixed files exist..." -ForegroundColor Cyan

$fixedFiles = @(
    "CFAS-System-Launcher-FIXED.ps1",
    "Launch-CFAS-FIXED.vbs",
    "LAUNCH-CFAS-GUI-FIXED.bat",
    "Create-Desktop-Shortcut-FIXED.ps1"
)

foreach ($file in $fixedFiles) {
    if (Test-Path $file) {
        Write-Host "  ✓ $file exists" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  ✗ $file NOT FOUND" -ForegroundColor Red
        $testsFailed++
    }
}

Write-Host ""

# Test 2: Check if fixed files contain -NoExit flag
Write-Host "Test 2: Checking if files contain -NoExit flag..." -ForegroundColor Cyan

$vbsContent = Get-Content "Launch-CFAS-FIXED.vbs" -Raw -ErrorAction SilentlyContinue
if ($vbsContent -match "-NoExit") {
    Write-Host "  ✓ VBS file contains -NoExit flag" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ✗ VBS file missing -NoExit flag" -ForegroundColor Red
    $testsFailed++
}

$batContent = Get-Content "LAUNCH-CFAS-GUI-FIXED.bat" -Raw -ErrorAction SilentlyContinue
if ($batContent -match "-NoExit") {
    Write-Host "  ✓ BAT file contains -NoExit flag" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ✗ BAT file missing -NoExit flag" -ForegroundColor Red
    $testsFailed++
}

$shortcutContent = Get-Content "Create-Desktop-Shortcut-FIXED.ps1" -Raw -ErrorAction SilentlyContinue
if ($shortcutContent -match "-NoExit") {
    Write-Host "  ✓ Shortcut creator contains -NoExit flag" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ✗ Shortcut creator missing -NoExit flag" -ForegroundColor Red
    $testsFailed++
}

Write-Host ""

# Test 3: Check if main launcher has console output
Write-Host "Test 3: Checking if main launcher has console output..." -ForegroundColor Cyan

$launcherContent = Get-Content "CFAS-System-Launcher-FIXED.ps1" -Raw -ErrorAction SilentlyContinue
if ($launcherContent -match "Write-Host") {
    Write-Host "  ✓ Main launcher contains Write-Host statements" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ✗ Main launcher missing Write-Host statements" -ForegroundColor Red
    $testsFailed++
}

Write-Host ""

# Test 4: Check if XAMPP exists
Write-Host "Test 4: Checking XAMPP installation..." -ForegroundColor Cyan

if (Test-Path "C:\xampp") {
    Write-Host "  ✓ XAMPP found at C:\xampp" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ⚠ XAMPP not found at C:\xampp" -ForegroundColor Yellow
    Write-Host "    (This is required for the launcher to work)" -ForegroundColor Gray
    $testsFailed++
}

Write-Host ""

# Test 5: Check if backend directory exists
Write-Host "Test 5: Checking backend directory..." -ForegroundColor Cyan

if (Test-Path "backend") {
    Write-Host "  ✓ Backend directory found" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ✗ Backend directory NOT FOUND" -ForegroundColor Red
    $testsFailed++
}

Write-Host ""

# Test 6: Check if logo exists
Write-Host "Test 6: Checking CFAS logo..." -ForegroundColor Cyan

if (Test-Path "frontend\public\cfas-logo.jpg") {
    Write-Host "  ✓ CFAS logo found" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ⚠ CFAS logo not found (will use fallback)" -ForegroundColor Yellow
    Write-Host "    (This is optional, launcher will still work)" -ForegroundColor Gray
}

Write-Host ""

# Test 7: Check PowerShell version
Write-Host "Test 7: Checking PowerShell version..." -ForegroundColor Cyan

$psVersion = $PSVersionTable.PSVersion
if ($psVersion.Major -ge 5) {
    Write-Host "  ✓ PowerShell version $($psVersion.Major).$($psVersion.Minor) (OK)" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ✗ PowerShell version $($psVersion.Major).$($psVersion.Minor) (Need 5.1+)" -ForegroundColor Red
    $testsFailed++
}

Write-Host ""

# Test 8: Check execution policy
Write-Host "Test 8: Checking PowerShell execution policy..." -ForegroundColor Cyan

$executionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($executionPolicy -eq "Bypass" -or $executionPolicy -eq "RemoteSigned" -or $executionPolicy -eq "Unrestricted") {
    Write-Host "  ✓ Execution policy: $executionPolicy (OK)" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "  ⚠ Execution policy: $executionPolicy" -ForegroundColor Yellow
    Write-Host "    Run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Gray
}

Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Tests Passed: $testsPassed" -ForegroundColor Green
Write-Host "Tests Failed: $testsFailed" -ForegroundColor $(if ($testsFailed -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "✓ All tests passed! Fixed launcher is ready to use." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Run: .\Deploy-Fixed-Launcher.ps1" -ForegroundColor White
    Write-Host "  2. Run: .\Create-Desktop-Shortcut-FIXED.ps1" -ForegroundColor White
    Write-Host "  3. Test: Double-click desktop shortcut" -ForegroundColor White
} else {
    Write-Host "⚠ Some tests failed. Please fix the issues above." -ForegroundColor Yellow
}

Write-Host ""
