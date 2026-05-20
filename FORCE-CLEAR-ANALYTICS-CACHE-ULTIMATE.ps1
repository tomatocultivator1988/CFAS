# ============================================================================
# ULTIMATE ANALYTICS CACHE CLEARING SCRIPT
# ============================================================================
# This script aggressively clears ALL browser caches to ensure the new
# Analytics Dashboard build is loaded
# ============================================================================

Write-Host "========================================" -ForegroundColor Red
Write-Host "ULTIMATE CACHE CLEARING - ANALYTICS FIX" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

Write-Host "🚨 CRITICAL: You are still loading OLD cached files!" -ForegroundColor Red
Write-Host "   Old file: AnalyticsDashboard-B6x0QrGh.js" -ForegroundColor Red
Write-Host "   New file: AnalyticsDashboard-B8gPwN8Z.js" -ForegroundColor Green
Write-Host ""

# Step 1: Close all browsers
Write-Host "[1/6] Closing all browser processes..." -ForegroundColor Yellow
$browsers = @("chrome", "msedge", "firefox", "iexplore", "opera")
foreach ($browser in $browsers) {
    try {
        Get-Process $browser -ErrorAction SilentlyContinue | Stop-Process -Force
        Write-Host "   ✓ Closed $browser" -ForegroundColor Gray
    } catch {
        Write-Host "   - $browser not running" -ForegroundColor Gray
    }
}

Start-Sleep -Seconds 2

# Step 2: Clear Chrome cache
Write-Host ""
Write-Host "[2/6] Clearing Chrome cache..." -ForegroundColor Yellow
$chromePaths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\GPUCache"
)

foreach ($path in $chromePaths) {
    if (Test-Path $path) {
        try {
            Remove-Item "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "   ✓ Cleared $path" -ForegroundColor Gray
        } catch {
            Write-Host "   ⚠ Could not clear $path (in use)" -ForegroundColor Yellow
        }
    }
}

# Step 3: Clear Edge cache
Write-Host ""
Write-Host "[3/6] Clearing Edge cache..." -ForegroundColor Yellow
$edgePaths = @(
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\GPUCache"
)

foreach ($path in $edgePaths) {
    if (Test-Path $path) {
        try {
            Remove-Item "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "   ✓ Cleared $path" -ForegroundColor Gray
        } catch {
            Write-Host "   ⚠ Could not clear $path (in use)" -ForegroundColor Yellow
        }
    }
}

# Step 4: Clear Firefox cache
Write-Host ""
Write-Host "[4/6] Clearing Firefox cache..." -ForegroundColor Yellow
$firefoxProfile = Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
if ($firefoxProfile) {
    $firefoxCachePath = "$($firefoxProfile.FullName)\cache2"
    if (Test-Path $firefoxCachePath) {
        try {
            Remove-Item "$firefoxCachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "   ✓ Cleared Firefox cache" -ForegroundColor Gray
        } catch {
            Write-Host "   ⚠ Could not clear Firefox cache" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "   - Firefox not installed" -ForegroundColor Gray
}

# Step 5: Clear DNS cache
Write-Host ""
Write-Host "[5/6] Clearing DNS cache..." -ForegroundColor Yellow
try {
    ipconfig /flushdns | Out-Null
    Write-Host "   ✓ DNS cache cleared" -ForegroundColor Gray
} catch {
    Write-Host "   ⚠ Could not clear DNS cache" -ForegroundColor Yellow
}

# Step 6: Clear temporary files
Write-Host ""
Write-Host "[6/6] Clearing temporary files..." -ForegroundColor Yellow
$tempPaths = @(
    "$env:TEMP",
    "$env:LOCALAPPDATA\Temp"
)

foreach ($path in $tempPaths) {
    if (Test-Path $path) {
        try {
            Get-ChildItem $path -Filter "*analytics*" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Get-ChildItem $path -Filter "*B6x0QrGh*" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Write-Host "   ✓ Cleared analytics temp files from $path" -ForegroundColor Gray
        } catch {
            Write-Host "   ⚠ Could not clear some temp files" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "CACHE CLEARING COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "🔥 NEXT STEPS - FOLLOW EXACTLY:" -ForegroundColor Red
Write-Host ""
Write-Host "1. WAIT 10 seconds before opening browser" -ForegroundColor White
Write-Host "2. Open browser in INCOGNITO/PRIVATE mode:" -ForegroundColor White
Write-Host "   - Chrome: Ctrl + Shift + N" -ForegroundColor Gray
Write-Host "   - Edge: Ctrl + Shift + N" -ForegroundColor Gray
Write-Host "   - Firefox: Ctrl + Shift + P" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Navigate to Analytics Dashboard" -ForegroundColor White
Write-Host ""
Write-Host "4. Open DevTools (F12) → Network tab" -ForegroundColor White
Write-Host ""
Write-Host "5. VERIFY you see the NEW file:" -ForegroundColor White
Write-Host "   ✅ AnalyticsDashboard-B8gPwN8Z.js" -ForegroundColor Green
Write-Host "   ❌ NOT AnalyticsDashboard-B6x0QrGh.js" -ForegroundColor Red
Write-Host ""
Write-Host "6. If you STILL see the old file:" -ForegroundColor White
Write-Host "   - Hard refresh: Ctrl + Shift + R" -ForegroundColor Gray
Write-Host "   - Or disable cache in DevTools" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Waiting 10 seconds before you can open browser..." -ForegroundColor Yellow
for ($i = 10; $i -gt 0; $i--) {
    Write-Host "   $i..." -ForegroundColor Gray
    Start-Sleep -Seconds 1
}
Write-Host ""
Write-Host "✅ Ready! Open browser in INCOGNITO mode now." -ForegroundColor Green