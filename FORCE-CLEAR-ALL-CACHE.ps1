# Force Clear All Cache - Apache + Browser
Write-Host "=== FORCE CLEAR ALL CACHE ===" -ForegroundColor Cyan
Write-Host ""

# 1. Stop Apache
Write-Host "1. Stopping Apache..." -ForegroundColor Yellow
Stop-Process -Name "httpd" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# 2. Close all browsers
Write-Host "2. Closing all browsers..." -ForegroundColor Yellow
Get-Process chrome, msedge, firefox -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# 3. Clear browser cache
Write-Host "3. Clearing browser cache..." -ForegroundColor Yellow
$edgeCachePaths = @(
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\GPUCache"
)

foreach ($path in $edgeCachePaths) {
    if (Test-Path $path) {
        Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   Cleared: $path" -ForegroundColor Green
    }
}

# 4. Clear Apache logs/cache
Write-Host "4. Clearing Apache cache..." -ForegroundColor Yellow
if (Test-Path "C:\xampp\apache\logs\*.log") {
    Clear-Content "C:\xampp\apache\logs\*.log" -ErrorAction SilentlyContinue
    Write-Host "   Cleared Apache logs" -ForegroundColor Green
}

# 5. Restart Apache
Write-Host "5. Starting Apache..." -ForegroundColor Yellow
Start-Process "C:\xampp\apache_start.bat" -WindowStyle Hidden -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# 6. Verify
$apache = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
if ($apache) {
    Write-Host "   ✓ Apache is running!" -ForegroundColor Green
} else {
    Write-Host "   Starting Apache using xampp_start..." -ForegroundColor Yellow
    Start-Process "C:\xampp\xampp_start.exe" -WindowStyle Hidden -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
}

Write-Host ""
Write-Host "=== ALL CACHE CLEARED ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Open your browser" -ForegroundColor White
Write-Host "2. Go to: http://localhost:8000/admin/analytics" -ForegroundColor White
Write-Host "3. Press Ctrl+Shift+R to hard refresh" -ForegroundColor White
Write-Host ""
Write-Host "The Export & Print buttons should now be removed!" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
