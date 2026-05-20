# ============================================================================
# Create Desktop Shortcut for CFAS Exam System Launcher (BAT Version)
# ============================================================================

Write-Host "Creating CFAS Exam System Desktop Shortcut..." -ForegroundColor Cyan
Write-Host ""

# Get the current script directory (Exam-Main folder)
$examMainPath = $PSScriptRoot

# Get user's Desktop path
$desktopPath = [Environment]::GetFolderPath("Desktop")

# Shortcut details
$shortcutName = "CFAS Exam System.lnk"
$shortcutPath = Join-Path $desktopPath $shortcutName
$batFile = Join-Path $examMainPath "LAUNCH-CFAS-GUI.bat"

# Validate bat file exists
if (-not (Test-Path $batFile)) {
    Write-Host "ERROR: Launcher bat file not found at:" -ForegroundColor Red
    Write-Host $batFile -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please make sure LAUNCH-CFAS-GUI.bat exists in the Exam-Main folder." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    pause
    exit 1
}

try {
    # Create WScript Shell object
    $WScriptShell = New-Object -ComObject WScript.Shell
    
    # Create shortcut
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    
    # Set shortcut properties to point to BAT file
    $shortcut.TargetPath = $batFile
    $shortcut.WorkingDirectory = $examMainPath
    $shortcut.Description = "Launch CFAS Exam System with all services"
    $shortcut.IconLocation = "%SystemRoot%\System32\shell32.dll,21"
    
    # Save shortcut
    $shortcut.Save()
    
    Write-Host "SUCCESS!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Desktop shortcut created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Shortcut Location: $shortcutPath" -ForegroundColor Cyan
    Write-Host "Launcher File: $batFile" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "You can now double-click the 'CFAS Exam System' icon on your desktop" -ForegroundColor Green
    Write-Host "to launch the exam system with a professional GUI!" -ForegroundColor Green
    Write-Host ""
}
catch {
    Write-Host "ERROR: Failed to create desktop shortcut" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Press any key to exit..." -ForegroundColor Gray
pause
