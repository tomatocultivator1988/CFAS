Write-Host "FORCE CLEARING BROWSER CACHE..." -ForegroundColor Cyan

# Clear Chrome cache
Write-Host "Clearing Chrome cache..." -ForegroundColor Yellow
$chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
if (Test-Path $chromePath) {
    Remove-Item -Path "$chromePath\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Chrome cache cleared!" -ForegroundColor Green
}

# Clear Edge cache
Write-Host "Clearing Edge cache..." -ForegroundColor Yellow
$edgePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
if (Test-Path $edgePath) {
    Remove-Item -Path "$edgePath\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Edge cache cleared!" -ForegroundColor Green
}

# Clear Firefox cache
Write-Host "Clearing Firefox cache..." -ForegroundColor Yellow
$firefoxPath = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles"
if (Test-Path $firefoxPath) {
    Get-ChildItem -Path $firefoxPath -Recurse -Include "cache2" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Firefox cache cleared!" -ForegroundColor Green
}

Write-Host ""
Write-Host "BROWSER CACHE CLEARED!" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: Para sigurado, gawin mo rin ito sa browser:" -ForegroundColor Yellow
Write-Host "1. Press CTRL + SHIFT + DELETE" -ForegroundColor White
Write-Host "2. Select 'Cached images and files'" -ForegroundColor White
Write-Host "3. Click 'Clear data'" -ForegroundColor White
Write-Host "4. Refresh ang page gamit CTRL + F5" -ForegroundColor White
Write-Host ""
Write-Host "O kaya, open sa INCOGNITO/PRIVATE mode para sigurado!" -ForegroundColor Cyan