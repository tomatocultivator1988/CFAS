# Simple Desktop Shortcut Creator
Write-Host "Creating CFAS Desktop Shortcut..." -ForegroundColor Cyan
Write-Host ""

$examMainPath = $PSScriptRoot
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutName = "CFAS Exam System.lnk"
$shortcutPath = Join-Path $desktopPath $shortcutName
$launcherScript = Join-Path $examMainPath "CFAS-System-Launcher.ps1"

if (-not (Test-Path $launcherScript)) {
    Write-Host "ERROR: Launcher script not found!" -ForegroundColor Red
    Write-Host $launcherScript -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press Enter to exit..." -ForegroundColor Gray
    Read-Host
    exit 1
}

try {
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-ExecutionPolicy Bypass -NoProfile -NoExit -File `"$launcherScript`""
    $shortcut.WorkingDirectory = $examMainPath
    $shortcut.Description = "Launch CFAS Exam System"
    $shortcut.IconLocation = "powershell.exe,0"
    $shortcut.Save()
    
    Write-Host "SUCCESS!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Desktop shortcut created!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Shortcut: $shortcutPath" -ForegroundColor Cyan
    Write-Host "Launcher: $launcherScript" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "You can now double-click the CFAS Exam System icon" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: Failed to create shortcut" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Press Enter to exit..." -ForegroundColor Gray
Read-Host
