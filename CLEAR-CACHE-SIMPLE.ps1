# Simple Cache Clearing Script
Write-Host "CLEARING BROWSER CACHE..." -ForegroundColor Green

# Close Chrome
try {
    Get-Process "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "Chrome closed" -ForegroundColor Yellow
} catch {
    Write-Host "Chrome not running" -ForegroundColor Gray
}

Start-Sleep -Seconds 2

# Clear Chrome cache
$chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
if (Test-Path $chromePath) {
    try {
        Remove-Item -Path "$chromePath\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Chrome cache cleared" -ForegroundColor Green
    } catch {
        Write-Host "Could not clear Chrome cache" -ForegroundColor Red
    }
}

# Clear DNS cache
try {
    ipconfig /flushdns | Out-Null
    Write-Host "DNS cache cleared" -ForegroundColor Green
} catch {
    Write-Host "Could not clear DNS cache" -ForegroundColor Red
}

Write-Host ""
Write-Host "CACHE CLEARING COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Open browser and go to: http://192.168.11.40/exam-frontend/#/admin/analytics"
Write-Host "2. Press Ctrl+Shift+R for hard refresh"
Write-Host "3. Check DevTools (F12) for errors"
Write-Host ""
Write-Host "If still having issues, manually clear browser cache:"
Write-Host "- Press Ctrl+Shift+Delete"
Write-Host "- Select All time"
Write-Host "- Clear everything"
Write-Host "- Restart browser"