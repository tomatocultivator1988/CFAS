# ============================================================================
# Create Desktop Shortcut for CFAS Exam System Launcher - FIXED VERSION
# This version keeps the terminal open for user feedback
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CFAS Desktop Shortcut Creator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get the current script directory (Exam-Main folder)
$examMainPath = $PSScriptRoot

# Get user's Desktop path
$desktopPath = [Environment]::GetFolderPath("Desktop")

Write-Host "Exam-Main Path: $examMainPath" -ForegroundColor Gray
Write-Host "Desktop Path: $desktopPath" -ForegroundColor Gray
Write-Host ""

# Shortcut details
$shortcutName = "CFAS Exam System.lnk"
$shortcutPath = Join-Path $desktopPath $shortcutName
$launcherScript = Join-Path $examMainPath "CFAS-System-Launcher.ps1"

Write-Host "Checking launcher script..." -ForegroundColor Cyan

# Validate launcher script exists
if (-not (Test-Path $launcherScript)) {
    Write-Host ""
    Write-Host "ERROR: Launcher script not found!" -ForegroundColor Red
    Write-Host "Expected location: $launcherScript" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please make sure CFAS-System-Launcher.ps1 exists in the Exam-Main folder." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "✓ Launcher script found" -ForegroundColor Green
Write-Host ""
Write-Host "Creating desktop shortcut..." -ForegroundColor Cyan

try {
    # Create WScript Shell object
    $WScriptShell = New-Object -ComObject WScript.Shell
    
    # Create shortcut
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    
    # Set shortcut properties
    # Using -NoExit to keep terminal open for debugging
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-ExecutionPolicy Bypass -NoProfile -NoExit -Command `"& { & '$launcherScript'; Write-Host ''; Write-Host 'Launcher finished. You can close this window.' -ForegroundColor Green; Read-Host 'Press Enter to exit' }`""
    $shortcut.WorkingDirectory = $examMainPath
    $shortcut.Description = "Launch CFAS Exam System with all services"
    $shortcut.IconLocation = "powershell.exe,0"
    
    # Save shortcut
    $shortcut.Save()
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Desktop shortcut created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Details:" -ForegroundColor Cyan
    Write-Host "  Shortcut: $shortcutPath" -ForegroundColor Gray
    Write-Host "  Launcher: $launcherScript" -ForegroundColor Gray
    Write-Host ""
    Write-Host "How to use:" -ForegroundColor Cyan
    Write-Host "  1. Double-click 'CFAS Exam System' icon on your desktop" -ForegroundColor White
    Write-Host "  2. GUI window will appear" -ForegroundColor White
    Write-Host "  3. Click the green 'START SYSTEM' button" -ForegroundColor White
    Write-Host "  4. Wait for services to start" -ForegroundColor White
    Write-Host "  5. Browser will open automatically" -ForegroundColor White
    Write-Host ""
    Write-Host "Note: Terminal window will stay open for debugging." -ForegroundColor Yellow
    Write-Host "      You can close it after the launcher finishes." -ForegroundColor Yellow
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "ERROR!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Failed to create desktop shortcut" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error details:" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
