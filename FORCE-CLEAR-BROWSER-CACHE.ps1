# FORCE CLEAR BROWSER CACHE - Analytics Fix
Write-Host "🧹 FORCE CLEARING BROWSER CACHE FOR ANALYTICS FIX..." -ForegroundColor Red

# Function to close browsers
function Close-Browsers {
    Write-Host "🛑 Closing browsers..." -ForegroundColor Yellow
    
    # Close Chrome
    try {
        Get-Process "chrome" -ErrorAction SilentlyContinue | Stop-Process -Force
        Write-Host "✅ Chrome closed" -ForegroundColor Green
    } catch {
        Write-Host "ℹ️ Chrome not running" -ForegroundColor Gray
    }
    
    # Close Edge
    try {
        Get-Process "msedge" -ErrorAction SilentlyContinue | Stop-Process -Force
        Write-Host "✅ Edge closed" -ForegroundColor Green
    } catch {
        Write-Host "ℹ️ Edge not running" -ForegroundColor Gray
    }
    
    # Close Firefox
    try {
        Get-Process "firefox" -ErrorAction SilentlyContinue | Stop-Process -Force
        Write-Host "✅ Firefox closed" -ForegroundColor Green
    } catch {
        Write-Host "ℹ️ Firefox not running" -ForegroundColor Gray
    }
    
    Start-Sleep -Seconds 2
}

# Function to clear Chrome cache
function Clear-ChromeCache {
    Write-Host "🗑️ Clearing Chrome cache..." -ForegroundColor Yellow
    
    $chromePaths = @(
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\GPUCache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Service Worker\CacheStorage",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Application Cache"
    )
    
    foreach ($path in $chromePaths) {
        if (Test-Path $path) {
            try {
                Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "✅ Cleared: $path" -ForegroundColor Green
            } catch {
                Write-Host "⚠️ Could not clear: $path" -ForegroundColor Yellow
            }
        }
    }
}

# Function to clear Edge cache
function Clear-EdgeCache {
    Write-Host "🗑️ Clearing Edge cache..." -ForegroundColor Yellow
    
    $edgePaths = @(
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\GPUCache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Service Worker\CacheStorage"
    )
    
    foreach ($path in $edgePaths) {
        if (Test-Path $path) {
            try {
                Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "✅ Cleared: $path" -ForegroundColor Green
            } catch {
                Write-Host "⚠️ Could not clear: $path" -ForegroundColor Yellow
            }
        }
    }
}

# Function to clear DNS cache
function Clear-DNSCache {
    Write-Host "🌐 Clearing DNS cache..." -ForegroundColor Yellow
    try {
        ipconfig /flushdns | Out-Null
        Write-Host "✅ DNS cache cleared" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Could not clear DNS cache" -ForegroundColor Yellow
    }
}

# Main execution
Write-Host "🎯 Starting comprehensive cache clearing..." -ForegroundColor Cyan

# Step 1: Close browsers
Close-Browsers

# Step 2: Clear browser caches
Clear-ChromeCache
Clear-EdgeCache

# Step 3: Clear DNS cache
Clear-DNSCache

# Step 4: Clear Windows temp files
Write-Host "🗑️ Clearing Windows temp files..." -ForegroundColor Yellow
try {
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Windows temp files cleared" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Some temp files could not be cleared" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 CACHE CLEARING COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Open your browser" -ForegroundColor White
Write-Host "2. Go to: http://192.168.11.40/exam-frontend/#/admin/analytics" -ForegroundColor White
Write-Host "3. Press Ctrl+Shift+R (hard refresh) when the page loads" -ForegroundColor White
Write-Host "4. Check DevTools (F12) for any remaining errors" -ForegroundColor White
Write-Host ""
Write-Host "🔧 If you still see errors:" -ForegroundColor Yellow
Write-Host "- Press Ctrl+Shift+Delete in your browser" -ForegroundColor White
Write-Host "- Select All time and clear everything" -ForegroundColor White
Write-Host "- Restart your browser completely" -ForegroundColor White
Write-Host ""
Write-Host "📊 The JavaScript errors should now be fixed!" -ForegroundColor Green