# Clear Browser Cache Script
Write-Host "Clearing Browser Cache..." -ForegroundColor Cyan

# Stop all browser processes
Write-Host "`nStopping browser processes..." -ForegroundColor Yellow
Get-Process chrome, msedge, firefox -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2

# Clear Edge Cache
Write-Host "`nClearing Microsoft Edge cache..." -ForegroundColor Yellow
$edgeCachePaths = @(
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\GPUCache"
)

foreach ($path in $edgeCachePaths) {
    if (Test-Path $path) {
        Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  Cleared: $path" -ForegroundColor Green
    }
}

# Clear Chrome Cache
Write-Host "`nClearing Google Chrome cache..." -ForegroundColor Yellow
$chromeCachePaths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\GPUCache"
)

foreach ($path in $chromeCachePaths) {
    if (Test-Path $path) {
        Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  Cleared: $path" -ForegroundColor Green
    }
}

# Clear Firefox Cache
Write-Host "`nClearing Firefox cache..." -ForegroundColor Yellow
$firefoxProfile = Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($firefoxProfile) {
    $firefoxCachePath = Join-Path $firefoxProfile.FullName "cache2"
    if (Test-Path $firefoxCachePath) {
        Remove-Item -Path "$firefoxCachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  Cleared: $firefoxCachePath" -ForegroundColor Green
    }
}

Write-Host "`n✓ Browser cache cleared successfully!" -ForegroundColor Green
Write-Host "`nYou can now open your browser and access the analytics page." -ForegroundColor Cyan
Write-Host "The Export & Print buttons should now be removed." -ForegroundColor Cyan

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
