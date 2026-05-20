# Test Logo Loading
Write-Host "Testing CFAS Logo..." -ForegroundColor Cyan
Write-Host ""

$scriptDir = $PSScriptRoot
$logoPath = Join-Path $scriptDir "frontend\public\cfas-logo.jpg"

Write-Host "Script Directory: $scriptDir" -ForegroundColor Yellow
Write-Host "Logo Path: $logoPath" -ForegroundColor Yellow
Write-Host ""

# Test 1: Check if file exists
Write-Host "[Test 1] Checking if logo file exists..." -ForegroundColor Cyan
if (Test-Path $logoPath) {
    Write-Host "  SUCCESS: Logo file found!" -ForegroundColor Green
    
    # Get file info
    $fileInfo = Get-Item $logoPath
    Write-Host "  File Size: $($fileInfo.Length) bytes" -ForegroundColor Gray
    Write-Host "  Last Modified: $($fileInfo.LastWriteTime)" -ForegroundColor Gray
} else {
    Write-Host "  ERROR: Logo file NOT found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Expected location: $logoPath" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""

# Test 2: Try to load logo with Windows Forms
Write-Host "[Test 2] Testing logo loading with Windows Forms..." -ForegroundColor Cyan
try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $image = [System.Drawing.Image]::FromFile($logoPath)
    Write-Host "  SUCCESS: Logo loaded successfully!" -ForegroundColor Green
    Write-Host "  Image Size: $($image.Width) x $($image.Height) pixels" -ForegroundColor Gray
    Write-Host "  Image Format: $($image.RawFormat)" -ForegroundColor Gray
    
    # Cleanup
    $image.Dispose()
} catch {
    Write-Host "  ERROR: Failed to load logo!" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Logo test complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Press Enter to exit..." -ForegroundColor Gray
Read-Host
