Write-Host "=== FORCE CLEAR BROWSER CACHE FOR ANALYTICS ===" -ForegroundColor Cyan
Write-Host ""

# Stop all browsers
Write-Host "1. Stopping all browser processes..." -ForegroundColor Yellow
Get-Process chrome, msedge, firefox -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Clear Chrome cache
Write-Host "2. Clearing Chrome cache..." -ForegroundColor Yellow
$chromeCachePaths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache"
)
foreach ($path in $chromeCachePaths) {
    if (Test-Path $path) {
        Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   Cleared: $path" -ForegroundColor Green
    }
}

# Clear Edge cache
Write-Host "3. Clearing Edge cache..." -ForegroundColor Yellow
$edgeCachePaths = @(
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache"
)
foreach ($path in $edgeCachePaths) {
    if (Test-Path $path) {
        Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   Cleared: $path" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== VERIFICATION ===" -ForegroundColor Cyan
Write-Host ""

# Check deployed file
$deployedFile = "C:\Apache24\htdocs\exam-frontend\assets\AnalyticsDashboard-BnCcAgRM.js"
if (Test-Path $deployedFile) {
    $fileInfo = Get-Item $deployedFile
    Write-Host "Deployed File: $($fileInfo.Name)" -ForegroundColor Green
    Write-Host "Last Modified: $($fileInfo.LastWriteTime)" -ForegroundColor Green
    Write-Host "Size: $([math]::Round($fileInfo.Length / 1KB, 2)) KB" -ForegroundColor Green
} else {
    Write-Host "ERROR: Analytics file not found!" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. Open browser in INCOGNITO/PRIVATE mode" -ForegroundColor Yellow
Write-Host "2. Navigate to: http://192.168.11.40/exam-frontend/admin/analytics" -ForegroundColor Yellow
Write-Host "3. Check console - errors should be gone!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Or press Ctrl+Shift+Delete in your browser and clear:" -ForegroundColor Yellow
Write-Host "  - Cached images and files" -ForegroundColor Yellow
Write-Host "  - Then press Ctrl+F5 to hard refresh" -ForegroundColor Yellow
Write-Host ""
