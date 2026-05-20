# Quick Rollback to Working Version
# This restores the frontend to the last working state

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ROLLBACK TO WORKING VERSION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$frontendPath = Join-Path $PSScriptRoot "frontend"
$xamppPath = "C:\xampp\htdocs\exam-frontend"

# Check for backup
Write-Host "Looking for backup..." -ForegroundColor Yellow
$backups = Get-ChildItem "C:\xampp\htdocs" -Filter "exam-frontend.backup.*" | Sort-Object LastWriteTime -Descending

if ($backups.Count -eq 0) {
    Write-Host "No backup found. Rebuilding from source..." -ForegroundColor Yellow
    
    # Build fresh
    Push-Location $frontendPath
    Write-Host "Building frontend..." -ForegroundColor Yellow
    npm run build
    Pop-Location
    
    # Deploy
    if (Test-Path $xamppPath) {
        Remove-Item $xamppPath -Recurse -Force
    }
    Copy-Item (Join-Path $frontendPath "dist") $xamppPath -Recurse -Force
    
    Write-Host "Fresh build deployed!" -ForegroundColor Green
} else {
    $latestBackup = $backups[0]
    Write-Host "Found backup: $($latestBackup.Name)" -ForegroundColor Green
    
    # Remove current
    if (Test-Path $xamppPath) {
        Remove-Item $xamppPath -Recurse -Force
    }
    
    # Restore backup
    Copy-Item $latestBackup.FullName $xamppPath -Recurse -Force
    Write-Host "Backup restored!" -ForegroundColor Green
}

Write-Host ""
Write-Host "System restored. Try accessing:" -ForegroundColor Cyan
Write-Host "http://localhost/exam-frontend/" -ForegroundColor White
Write-Host ""
