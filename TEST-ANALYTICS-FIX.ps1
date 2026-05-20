#!/usr/bin/env pwsh

Write-Host "🔧 ANALYTICS DASHBOARD FIX TEST" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 Issue Fixed: ReferenceError: Cannot access 'e' before initialization" -ForegroundColor Yellow
Write-Host ""

# Function to clear browser cache
function Clear-BrowserCache {
    Write-Host "🧹 Clearing browser cache..." -ForegroundColor Blue
    
    # Clear Chrome cache
    try {
        $chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
        if (Test-Path $chromePath) {
            Remove-Item "$chromePath\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "✅ Chrome cache cleared" -ForegroundColor Green
        }
    } catch {
        Write-Host "⚠️  Chrome cache clear failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Clear Edge cache
    try {
        $edgePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
        if (Test-Path $edgePath) {
            Remove-Item "$edgePath\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "✅ Edge cache cleared" -ForegroundColor Green
        }
    } catch {
        Write-Host "⚠️  Edge cache clear failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Clear Firefox cache
    try {
        $firefoxPath = "$env:APPDATA\Mozilla\Firefox\Profiles"
        if (Test-Path $firefoxPath) {
            Get-ChildItem $firefoxPath | ForEach-Object {
                $cachePath = Join-Path $_.FullName "cache2"
                if (Test-Path $cachePath) {
                    Remove-Item "$cachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
            Write-Host "✅ Firefox cache cleared" -ForegroundColor Green
        }
    } catch {
        Write-Host "⚠️  Firefox cache clear failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Function to test frontend build
function Test-FrontendBuild {
    Write-Host "🏗️  Testing frontend build..." -ForegroundColor Blue
    
    $frontendPath = ".\frontend"
    if (Test-Path $frontendPath) {
        Push-Location $frontendPath
        try {
            # Check if node_modules exists
            if (!(Test-Path "node_modules")) {
                Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
                npm install
            }
            
            # Build the frontend
            Write-Host "🔨 Building frontend..." -ForegroundColor Yellow
            npm run build
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Frontend build successful" -ForegroundColor Green
            } else {
                Write-Host "❌ Frontend build failed" -ForegroundColor Red
                return $false
            }
        } catch {
            Write-Host "❌ Frontend build error: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "⚠️  Frontend directory not found" -ForegroundColor Yellow
        return $false
    }
    return $true
}

# Function to check if backend is running
function Test-BackendConnection {
    Write-Host "🔌 Testing backend connection..." -ForegroundColor Blue
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000/api/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Backend is running" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "❌ Backend not accessible: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "💡 Make sure to start the backend first" -ForegroundColor Yellow
        return $false
    }
    return $false
}

# Function to open test page
function Open-TestPage {
    Write-Host "🌐 Opening test page..." -ForegroundColor Blue
    
    $testPagePath = ".\test-analytics-fix.html"
    if (Test-Path $testPagePath) {
        Start-Process $testPagePath
        Write-Host "✅ Test page opened" -ForegroundColor Green
    } else {
        Write-Host "❌ Test page not found" -ForegroundColor Red
    }
}

# Function to display fix summary
function Show-FixSummary {
    Write-Host ""
    Write-Host "🔧 FIX SUMMARY" -ForegroundColor Cyan
    Write-Host "==============" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Problem:" -ForegroundColor Yellow
    Write-Host "  • ReferenceError: Cannot access 'e' before initialization" -ForegroundColor White
    Write-Host "  • Variable redeclaration in Vue composables" -ForegroundColor White
    Write-Host "  • Improper destructuring with renamed variables" -ForegroundColor White
    Write-Host ""
    Write-Host "Solution Applied:" -ForegroundColor Green
    Write-Host "  ✅ Fixed variable redeclaration conflicts" -ForegroundColor White
    Write-Host "  ✅ Proper composable initialization" -ForegroundColor White
    Write-Host "  ✅ Safe null checking throughout component" -ForegroundColor White
    Write-Host "  ✅ Improved error handling in watchers" -ForegroundColor White
    Write-Host "  ✅ Better template event handling" -ForegroundColor White
    Write-Host ""
    Write-Host "Files Modified:" -ForegroundColor Blue
    Write-Host "  • frontend/src/views/admin/AnalyticsDashboard.vue" -ForegroundColor White
    Write-Host ""
}

# Main execution
Write-Host "Starting Analytics Dashboard Fix Test..." -ForegroundColor Green
Write-Host ""

Show-FixSummary

# Clear browser cache
Clear-BrowserCache
Write-Host ""

# Test frontend build
$buildSuccess = Test-FrontendBuild
Write-Host ""

# Test backend connection
$backendRunning = Test-BackendConnection
Write-Host ""

# Open test page
Open-TestPage
Write-Host ""

# Final instructions
Write-Host "📋 TESTING INSTRUCTIONS" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Navigate to: http://localhost:3000/admin/analytics" -ForegroundColor White
Write-Host "2. Open browser developer tools (F12)" -ForegroundColor White
Write-Host "3. Check Console tab for errors" -ForegroundColor White
Write-Host "4. Test the following features:" -ForegroundColor White
Write-Host "   • Time filter dropdown changes" -ForegroundColor Gray
Write-Host "   • Section tab switching" -ForegroundColor Gray
Write-Host "   • Auto-refresh toggle" -ForegroundColor Gray
Write-Host "   • Refresh button clicks" -ForegroundColor Gray
Write-Host ""

if ($buildSuccess -and $backendRunning) {
    Write-Host "✅ All systems ready for testing!" -ForegroundColor Green
} elseif ($buildSuccess) {
    Write-Host "⚠️  Frontend ready, but backend needs to be started" -ForegroundColor Yellow
} else {
    Write-Host "❌ Issues detected. Please resolve before testing." -ForegroundColor Red
}

Write-Host ""
Write-Host "Expected Result: No 'Cannot access 'e' before initialization' errors" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")