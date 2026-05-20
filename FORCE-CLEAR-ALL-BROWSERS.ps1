# FORCE CLEAR ALL BROWSERS - COMPREHENSIVE CACHE CLEARING
Write-Host "FORCE CLEARING ALL BROWSER CACHES..." -ForegroundColor Red

# Function to kill browser processes
function Kill-BrowserProcesses {
    $browsers = @("chrome", "msedge", "firefox", "iexplore", "opera")
    foreach ($browser in $browsers) {
        try {
            Get-Process $browser -ErrorAction SilentlyContinue | Stop-Process -Force
            Write-Host "Closed $browser" -ForegroundColor Yellow
        } catch {
            Write-Host "$browser not running" -ForegroundColor Gray
        }
    }
}

# Kill all browsers
Kill-BrowserProcesses
Start-Sleep -Seconds 3

# Clear Chrome cache (all profiles)
Write-Host "Clearing Chrome cache..." -ForegroundColor Yellow
$chromeProfiles = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Profile 1",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Profile 2"
)

foreach ($profile in $chromeProfiles) {
    if (Test-Path $profile) {
        try {
            Remove-Item -Path "$profile\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$profile\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$profile\GPUCache\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Cleared Chrome profile: $profile" -ForegroundColor Green
        } catch {
            Write-Host "Could not clear Chrome profile: $profile" -ForegroundColor Red
        }
    }
}

# Clear Edge cache
Write-Host "Clearing Edge cache..." -ForegroundColor Yellow
$edgeProfiles = @(
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Profile 1"
)

foreach ($profile in $edgeProfiles) {
    if (Test-Path $profile) {
        try {
            Remove-Item -Path "$profile\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$profile\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$profile\GPUCache\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Cleared Edge profile: $profile" -ForegroundColor Green
        } catch {
            Write-Host "Could not clear Edge profile: $profile" -ForegroundColor Red
        }
    }
}

# Clear Firefox cache
Write-Host "Clearing Firefox cache..." -ForegroundColor Yellow
$firefoxPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
if (Test-Path $firefoxPath) {
    Get-ChildItem $firefoxPath | ForEach-Object {
        try {
            Remove-Item -Path "$($_.FullName)\cache2\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Cleared Firefox profile: $($_.Name)" -ForegroundColor Green
        } catch {
            Write-Host "Could not clear Firefox profile: $($_.Name)" -ForegroundColor Red
        }
    }
}

# Clear DNS cache
Write-Host "Clearing DNS cache..." -ForegroundColor Yellow
try {
    ipconfig /flushdns | Out-Null
    Write-Host "DNS cache cleared" -ForegroundColor Green
} catch {
    Write-Host "Could not clear DNS cache" -ForegroundColor Red
}

# Clear Windows temporary files
Write-Host "Clearing Windows temp files..." -ForegroundColor Yellow
try {
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Windows temp files cleared" -ForegroundColor Green
} catch {
    Write-Host "Could not clear all temp files" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "COMPREHENSIVE CACHE CLEARING COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "CRITICAL NEXT STEPS:" -ForegroundColor Red
Write-Host "1. DO NOT open any browser yet" -ForegroundColor White
Write-Host "2. Restart your computer completely" -ForegroundColor White
Write-Host "3. After restart, open browser in INCOGNITO/PRIVATE mode" -ForegroundColor White
Write-Host "4. Go to: http://192.168.11.40/exam-frontend/#/admin/analytics" -ForegroundColor White
Write-Host "5. Press Ctrl+Shift+R for hard refresh" -ForegroundColor White
Write-Host ""
Write-Host "IF STILL HAVING ISSUES:" -ForegroundColor Yellow
Write-Host "- Try a different browser (Edge if using Chrome, Chrome if using Edge)" -ForegroundColor White
Write-Host "- Use incognito/private browsing mode" -ForegroundColor White
Write-Host "- Check if antivirus is blocking cache clearing" -ForegroundColor White