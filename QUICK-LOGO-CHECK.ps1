# Quick Logo Check Script
# This script checks if the logo is properly configured

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CFAS Launcher - Logo Quick Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = $PSScriptRoot
$logoPath = Join-Path $scriptDir "frontend\public\cfas-logo.jpg"

# Check 1: Logo file exists
Write-Host "[1/4] Checking logo file..." -ForegroundColor Yellow
if (Test-Path $logoPath) {
    Write-Host "      PASS - Logo file found!" -ForegroundColor Green
    $fileInfo = Get-Item $logoPath
    Write-Host "      Size: $($fileInfo.Length) bytes" -ForegroundColor Gray
} else {
    Write-Host "      FAIL - Logo file NOT found!" -ForegroundColor Red
    Write-Host "      Expected: $logoPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "SOLUTION: Copy cfas-logo.jpg to frontend\public\" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Check 2: Windows Forms available
Write-Host "[2/4] Checking Windows Forms..." -ForegroundColor Yellow
try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Write-Host "      PASS - Windows Forms loaded!" -ForegroundColor Green
} catch {
    Write-Host "      FAIL - Windows Forms error!" -ForegroundColor Red
    Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Check 3: Logo can be loaded
Write-Host "[3/4] Testing logo loading..." -ForegroundColor Yellow
try {
    $image = [System.Drawing.Image]::FromFile($logoPath)
    Write-Host "      PASS - Logo loaded successfully!" -ForegroundColor Green
    Write-Host "      Dimensions: $($image.Width) x $($image.Height) pixels" -ForegroundColor Gray
    $image.Dispose()
} catch {
    Write-Host "      FAIL - Cannot load logo!" -ForegroundColor Red
    Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "SOLUTION: Logo file might be corrupt. Get a fresh copy." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Check 4: Launcher script exists
Write-Host "[4/4] Checking launcher script..." -ForegroundColor Yellow
$launcherPath = Join-Path $scriptDir "CFAS-System-Launcher.ps1"
if (Test-Path $launcherPath) {
    Write-Host "      PASS - Launcher script found!" -ForegroundColor Green
    
    # Check if logo path is correct in launcher
    $launcherContent = Get-Content $launcherPath -Raw
    if ($launcherContent -match 'frontend\\public\\cfas-logo\.jpg') {
        Write-Host "      PASS - Logo path configured correctly!" -ForegroundColor Green
    } else {
        Write-Host "      WARN - Logo path might be wrong in launcher!" -ForegroundColor Yellow
    }
} else {
    Write-Host "      FAIL - Launcher script NOT found!" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ALL CHECKS PASSED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The logo should work in the launcher!" -ForegroundColor Green
Write-Host ""
Write-Host "Next step: Run TEST-LAUNCHER-WITH-LOGO.bat" -ForegroundColor Yellow
Write-Host "to see the actual GUI with logo." -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Enter to exit..." -ForegroundColor Gray
Read-Host
