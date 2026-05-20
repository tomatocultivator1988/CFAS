# ============================================================================
# SIMPLE ANALYTICS CACHE CLEARING SCRIPT
# ============================================================================

Write-Host "========================================" -ForegroundColor Red
Write-Host "CLEARING BROWSER CACHE - ANALYTICS FIX" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

Write-Host "CRITICAL: You are still loading OLD cached files!" -ForegroundColor Red
Write-Host "   Old file: AnalyticsDashboard-B6x0QrGh.js" -ForegroundColor Red
Write-Host "   New file: AnalyticsDashboard-B8gPwN8Z.js" -ForegroundColor Green
Write-Host ""

# Step 1: Close browsers
Write-Host "[1/4] Closing browser processes..." -ForegroundColor Yellow
$browsers = @("chrome", "msedge", "firefox", "iexplore")
foreach ($browser in $browsers) {
    try {
        Get-Process $browser -ErrorAction SilentlyContinue | Stop-Process -Force
        Write-Host "   Closed $browser" -ForegroundColor Gray
    } catch {
        Write-Host "   $browser not running" -ForegroundColor Gray
    }
}

Start-Sleep -Seconds 2

# Step 2: Clear Chrome cache
Write-Host ""
Write-Host "[2/4] Clearing Chrome cache..." -ForegroundColor Yellow
$chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
if (Test-Path $chromePath) {
    try {
        Remove-Item "$chromePath\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   Chrome cache cleared" -ForegroundColor Gray
    } catch {
        Write-Host "   Could not clear Chrome cache" -ForegroundColor Yellow
    }
} else {
    Write-Host "   Chrome cache not found" -ForegroundColor Gray
}

# Step 3: Clear Edge cache
Write-Host ""
Write-Host "[3/4] Clearing Edge cache..." -ForegroundColor Yellow
$edgePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
if (Test-Path $edgePath) {
    try {
        Remove-Item "$edgePath\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   Edge cache cleared" -ForegroundColor Gray
    } catch {
        Write-Host "   Could not clear Edge cache" -ForegroundColor Yellow
    }
} else {
    Write-Host "   Edge cache not found" -ForegroundColor Gray
}

# Step 4: Clear DNS cache
Write-Host ""
Write-Host "[4/4] Clearing DNS cache..." -ForegroundColor Yellow
try {
    ipconfig /flushdns | Out-Null
    Write-Host "   DNS cache cleared" -ForegroundColor Gray
} catch {
    Write-Host "   Could not clear DNS cache" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "CACHE CLEARING COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS - FOLLOW EXACTLY:" -ForegroundColor Red
Write-Host ""
Write-Host "1. Open browser in INCOGNITO/PRIVATE mode:" -ForegroundColor White
Write-Host "   - Chrome: Ctrl + Shift + N" -ForegroundColor Gray
Write-Host "   - Edge: Ctrl + Shift + N" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Navigate to Analytics Dashboard" -ForegroundColor White
Write-Host ""
Write-Host "3. Open DevTools (F12) -> Network tab" -ForegroundColor White
Write-Host ""
Write-Host "4. VERIFY you see the NEW file:" -ForegroundColor White
Write-Host "   GOOD: AnalyticsDashboard-B8gPwN8Z.js" -ForegroundColor Green
Write-Host "   BAD:  AnalyticsDashboard-B6x0QrGh.js" -ForegroundColor Red
Write-Host ""
Write-Host "5. If you STILL see the old file:" -ForegroundColor White
Write-Host "   - Hard refresh: Ctrl + Shift + R" -ForegroundColor Gray
Write-Host "   - Or disable cache in DevTools" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan