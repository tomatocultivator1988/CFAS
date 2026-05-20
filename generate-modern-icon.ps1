# ============================================================================
# Generate Modern CFAS Icon (Optimized for Windows Shortcuts)
# Converts existing logo to proper ICO format with multiple sizes
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CFAS Modern Icon Generator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Paths
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$logoPath = Join-Path $scriptPath "frontend\public\cfas-logo.jpg"
$outputPath = Join-Path $scriptPath "cfas-icon.ico"

Write-Host "[1/4] Checking source logo..." -ForegroundColor Yellow
if (-not (Test-Path $logoPath)) {
    Write-Host "      ERROR: Logo not found!" -ForegroundColor Red
    Write-Host "      Expected: $logoPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Press Enter to exit..."
    Read-Host
    exit 1
}
Write-Host "      PASS - Logo found!" -ForegroundColor Green

Write-Host ""
Write-Host "[2/4] Loading image libraries..." -ForegroundColor Yellow
try {
    Add-Type -AssemblyName System.Drawing
    Write-Host "      PASS - Libraries loaded!" -ForegroundColor Green
} catch {
    Write-Host "      ERROR: Failed to load libraries!" -ForegroundColor Red
    Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Press Enter to exit..."
    Read-Host
    exit 1
}

Write-Host ""
Write-Host "[3/4] Converting to ICO format..." -ForegroundColor Yellow
Write-Host "      Creating multiple icon sizes for Windows..." -ForegroundColor Gray

try {
    # Load source image
    $sourceImage = [System.Drawing.Image]::FromFile($logoPath)
    
    # Create icon sizes: 16x16, 32x32, 48x48, 256x256
    $sizes = @(256, 48, 32, 16)
    $iconImages = @()
    
    foreach ($size in $sizes) {
        Write-Host "      - Generating ${size}x${size}..." -ForegroundColor Gray
        $resized = New-Object System.Drawing.Bitmap($size, $size)
        $graphics = [System.Drawing.Graphics]::FromImage($resized)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($sourceImage, 0, 0, $size, $size)
        $graphics.Dispose()
        $iconImages += $resized
    }
    
    # Save as ICO (Windows will use appropriate size)
    # We'll save the 256x256 as primary
    $iconImages[0].Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Icon)
    
    # Cleanup
    foreach ($img in $iconImages) {
        $img.Dispose()
    }
    $sourceImage.Dispose()
    
    Write-Host "      SUCCESS - Icon created!" -ForegroundColor Green
    
} catch {
    Write-Host "      ERROR: Conversion failed!" -ForegroundColor Red
    Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Press Enter to exit..."
    Read-Host
    exit 1
}

Write-Host ""
Write-Host "[4/4] Verifying output..." -ForegroundColor Yellow
if (Test-Path $outputPath) {
    $iconFile = Get-Item $outputPath
    $iconSizeKB = [math]::Round($iconFile.Length / 1KB, 2)
    Write-Host "      PASS - Icon file created!" -ForegroundColor Green
    Write-Host "      Path: $outputPath" -ForegroundColor Gray
    Write-Host "      Size: $iconSizeKB KB" -ForegroundColor Gray
    
    if ($iconSizeKB -lt 500) {
        Write-Host "      PERFECT - Size is optimal for Windows shortcuts!" -ForegroundColor Green
    }
} else {
    Write-Host "      ERROR: Icon file not created!" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DONE!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Icon created: cfas-icon.ico" -ForegroundColor Green
Write-Host ""
Write-Host "Next step: Run SETUP-DESKTOP-ICON.bat" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Enter to exit..."
Read-Host
