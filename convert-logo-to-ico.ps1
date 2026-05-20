# ============================================================================
# Convert CFAS Logo JPG to ICO Format
# Creates a proper Windows icon file for desktop shortcut
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CFAS Logo Converter (JPG to ICO)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Paths
$scriptDir = $PSScriptRoot
$logoJpgPath = Join-Path $scriptDir "frontend\public\cfas-logo.jpg"
$logoIcoPath = Join-Path $scriptDir "cfas-icon.ico"

# Check if JPG exists
Write-Host "[1/3] Checking source logo file..." -ForegroundColor Yellow
if (-not (Test-Path $logoJpgPath)) {
    Write-Host "      ERROR: Logo JPG not found!" -ForegroundColor Red
    Write-Host "      Expected: $logoJpgPath" -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "      PASS - Logo JPG found!" -ForegroundColor Green
Write-Host ""

# Load assemblies
Write-Host "[2/3] Loading image libraries..." -ForegroundColor Yellow
try {
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Windows.Forms
    Write-Host "      PASS - Libraries loaded!" -ForegroundColor Green
} catch {
    Write-Host "      ERROR: Failed to load libraries!" -ForegroundColor Red
    Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# Convert JPG to ICO
Write-Host "[3/3] Converting JPG to ICO..." -ForegroundColor Yellow
try {
    # Load the JPG image
    $image = [System.Drawing.Image]::FromFile($logoJpgPath)
    
    # Create icon using Icon.FromHandle method
    $iconSize = 256
    $bitmap = New-Object System.Drawing.Bitmap($iconSize, $iconSize)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    # Set high quality rendering
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    
    # Draw the image scaled to icon size
    $graphics.DrawImage($image, 0, 0, $iconSize, $iconSize)
    $graphics.Dispose()
    
    # Convert bitmap to icon using GetHicon
    $icon = [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())
    
    # Save as ICO file
    $iconStream = New-Object System.IO.FileStream($logoIcoPath, [System.IO.FileMode]::Create)
    $icon.Save($iconStream)
    
    # Cleanup
    $iconStream.Close()
    $iconStream.Dispose()
    $icon.Dispose()
    $bitmap.Dispose()
    $image.Dispose()
    
    Write-Host "      SUCCESS - ICO file created!" -ForegroundColor Green
    Write-Host "      Location: $logoIcoPath" -ForegroundColor Gray
    
    # Check file size
    $icoInfo = Get-Item $logoIcoPath
    Write-Host "      Size: $($icoInfo.Length) bytes" -ForegroundColor Gray
    
} catch {
    Write-Host "      ERROR: Conversion failed!" -ForegroundColor Red
    Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CONVERSION COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "ICO file created: cfas-icon.ico" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run: CREATE-SHORTCUT-WITH-ICON.bat" -ForegroundColor White
Write-Host "2. Desktop shortcut will have CFAS icon!" -ForegroundColor White
Write-Host ""
Write-Host "Press Enter to exit..." -ForegroundColor Gray
Read-Host
