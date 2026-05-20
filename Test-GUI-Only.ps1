# Quick test to see if GUI opens
Write-Host "Testing CFAS Launcher GUI..." -ForegroundColor Cyan
Write-Host ""

$launcherPath = Join-Path $PSScriptRoot "CFAS-System-Launcher.ps1"

if (Test-Path $launcherPath) {
    Write-Host "Launcher found. Opening GUI..." -ForegroundColor Green
    Write-Host ""
    Write-Host "The GUI window should appear now." -ForegroundColor Yellow
    Write-Host "Click CANCEL to close it and test that it works." -ForegroundColor Yellow
    Write-Host ""
    
    # Run the launcher
    & $launcherPath
    
    Write-Host ""
    Write-Host "Test complete!" -ForegroundColor Green
} else {
    Write-Host "ERROR: Launcher not found!" -ForegroundColor Red
}

pause
