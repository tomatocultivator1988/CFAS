# ============================================================================
# Test Desktop Icon - Check if CFAS icon is loading
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CFAS Desktop Icon Checker" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get paths
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "CFAS Exam System.lnk"
$iconPath = Join-Path $PSScriptRoot "frontend\CFASLOGO.ico"

Write-Host "[1/4] Checking desktop shortcut..." -ForegroundColor Yellow
if (Test-Path $shortcutPath) {
    Write-Host "      PASS - Shortcut exists!" -ForegroundColor Green
    Write-Host "      Path: $shortcutPath" -ForegroundColor Gray
} else {
    Write-Host "      FAIL - Shortcut not found!" -ForegroundColor Red
    Write-Host "      Expected: $shortcutPath" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "[2/4] Checking icon file..." -ForegroundColor Yellow
if (Test-Path $iconPath) {
    $iconFile = Get-Item $iconPath
    $iconSizeMB = [math]::Round($iconFile.Length / 1MB, 2)
    Write-Host "      PASS - Icon file exists!" -ForegroundColor Green
    Write-Host "      Path: $iconPath" -ForegroundColor Gray
    Write-Host "      Size: $iconSizeMB MB" -ForegroundColor Gray
    
    if ($iconSizeMB -gt 0.5) {
        Write-Host "      WARNING: Icon file is large ($iconSizeMB MB)" -ForegroundColor Yellow
        Write-Host "      Windows shortcuts prefer smaller icons (<500KB)" -ForegroundColor Yellow
    }
} else {
    Write-Host "      FAIL - Icon file not found!" -ForegroundColor Red
    Write-Host "      Expected: $iconPath" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "[3/4] Reading shortcut properties..." -ForegroundColor Yellow
try {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    
    Write-Host "      Target: $($shortcut.TargetPath)" -ForegroundColor Gray
    Write-Host "      Arguments: $($shortcut.Arguments)" -ForegroundColor Gray
    Write-Host "      Icon Location: $($shortcut.IconLocation)" -ForegroundColor Gray
    
    if ($shortcut.IconLocation -like "*CFASLOGO.ico*") {
        Write-Host "      PASS - Icon is set to CFAS logo!" -ForegroundColor Green
    } else {
        Write-Host "      FAIL - Icon is not set correctly!" -ForegroundColor Red
    }
} catch {
    Write-Host "      ERROR: Failed to read shortcut properties!" -ForegroundColor Red
    Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[4/4] Diagnosis..." -ForegroundColor Yellow

# Check if icon path is absolute or relative
$iconLocation = $shortcut.IconLocation
if ($iconLocation -like "*:*") {
    Write-Host "      Icon path is ABSOLUTE" -ForegroundColor Green
} else {
    Write-Host "      Icon path is RELATIVE" -ForegroundColor Yellow
    Write-Host "      This might cause issues!" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Possible Issues:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Icon file too large (1.9MB)" -ForegroundColor Yellow
Write-Host "   - Windows may not load large ICO files in shortcuts" -ForegroundColor Gray
Write-Host "   - Recommended: <500KB" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Icon cache issue" -ForegroundColor Yellow
Write-Host "   - Windows caches icons, may need refresh" -ForegroundColor Gray
Write-Host "   - Try: Restart Windows Explorer" -ForegroundColor Gray
Write-Host ""
Write-Host "3. ICO file format issue" -ForegroundColor Yellow
Write-Host "   - File might not be proper ICO format" -ForegroundColor Gray
Write-Host "   - Check file properties" -ForegroundColor Gray
Write-Host ""

Write-Host "Press Enter to exit..."
Read-Host
