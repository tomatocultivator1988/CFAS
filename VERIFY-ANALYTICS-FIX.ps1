#!/usr/bin/env pwsh

Write-Host "🔍 VERIFYING ANALYTICS JAVASCRIPT FIX" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$LAN_SERVER = "192.168.11.40"
$ANALYTICS_URL = "http://$LAN_SERVER/exam-frontend/admin/analytics"

# Function to check if server is accessible
function Test-ServerAccess {
    Write-Host "🌐 Testing server accessibility..." -ForegroundColor Blue
    
    try {
        $response = Invoke-WebRequest -Uri "http://$LAN_SERVER/exam-frontend/" -Method GET -TimeoutSec 10 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ LAN server is accessible" -ForegroundColor Green
            return $true
        } else {
            Write-Host "⚠️  Server returned status: $($response.StatusCode)" -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "❌ Server not accessible: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to check analytics page
function Test-AnalyticsPage {
    Write-Host "📊 Testing analytics page..." -ForegroundColor Blue
    
    try {
        $response = Invoke-WebRequest -Uri $ANALYTICS_URL -Method GET -TimeoutSec 15 -ErrorAction Stop
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Analytics page loads successfully" -ForegroundColor Green
            
            # Check for specific content
            $content = $response.Content
            if ($content -match "Analytics Dashboard") {
                Write-Host "✅ Analytics Dashboard content found" -ForegroundColor Green
            } else {
                Write-Host "⚠️  Analytics Dashboard content not found" -ForegroundColor Yellow
            }
            
            # Check for Vue.js
            if ($content -match "vue") {
                Write-Host "✅ Vue.js framework detected" -ForegroundColor Green
            }
            
            return $true
        } else {
            Write-Host "⚠️  Analytics page returned status: $($response.StatusCode)" -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "❌ Analytics page not accessible: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to check for JavaScript files
function Test-JavaScriptFiles {
    Write-Host "📜 Checking JavaScript files..." -ForegroundColor Blue
    
    try {
        $response = Invoke-WebRequest -Uri $ANALYTICS_URL -Method GET -TimeoutSec 15 -ErrorAction Stop
        $content = $response.Content
        
        # Look for JavaScript bundle references
        $jsMatches = [regex]::Matches($content, 'src="([^"]*\.js[^"]*)"')
        
        if ($jsMatches.Count -gt 0) {
            Write-Host "✅ Found $($jsMatches.Count) JavaScript files" -ForegroundColor Green
            
            foreach ($match in $jsMatches) {
                $jsUrl = $match.Groups[1].Value
                if ($jsUrl -notmatch "^http") {
                    $jsUrl = "http://$LAN_SERVER/exam-frontend$jsUrl"
                }
                
                try {
                    $jsResponse = Invoke-WebRequest -Uri $jsUrl -Method GET -TimeoutSec 10 -ErrorAction Stop
                    if ($jsResponse.StatusCode -eq 200) {
                        Write-Host "  ✅ $($match.Groups[1].Value)" -ForegroundColor Green
                    }
                } catch {
                    Write-Host "  ❌ $($match.Groups[1].Value) - Not accessible" -ForegroundColor Red
                }
            }
            
            return $true
        } else {
            Write-Host "⚠️  No JavaScript files found in page" -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "❌ JavaScript file check failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to show testing instructions
function Show-TestingInstructions {
    Write-Host ""
    Write-Host "📋 MANUAL TESTING INSTRUCTIONS" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Open your browser and navigate to:" -ForegroundColor Yellow
    Write-Host "   $ANALYTICS_URL" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Open Developer Tools (F12)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "3. Check the Console tab for errors:" -ForegroundColor Yellow
    Write-Host "   ✅ Should NOT see: 'Cannot access 'e' before initialization'" -ForegroundColor Green
    Write-Host "   ✅ Should NOT see: 'ReferenceError'" -ForegroundColor Green
    Write-Host "   ✅ Should see: Clean console or minimal warnings only" -ForegroundColor Green
    Write-Host ""
    Write-Host "4. Test these features:" -ForegroundColor Yellow
    Write-Host "   • Change time filter dropdown (7 days, 30 days, etc.)" -ForegroundColor White
    Write-Host "   • Click different section tabs (Overview, Exams, Students, etc.)" -ForegroundColor White
    Write-Host "   • Toggle auto-refresh switch" -ForegroundColor White
    Write-Host "   • Click refresh button" -ForegroundColor White
    Write-Host ""
    Write-Host "5. Expected Results:" -ForegroundColor Yellow
    Write-Host "   ✅ All interactions work smoothly" -ForegroundColor Green
    Write-Host "   ✅ No JavaScript errors in console" -ForegroundColor Green
    Write-Host "   ✅ Page loads and functions correctly" -ForegroundColor Green
    Write-Host ""
}

# Function to show fix details
function Show-FixDetails {
    Write-Host ""
    Write-Host "🔧 FIX DETAILS" -ForegroundColor Cyan
    Write-Host "==============" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Problem Fixed:" -ForegroundColor Red
    Write-Host "  ReferenceError: Cannot access 'e' before initialization" -ForegroundColor White
    Write-Host ""
    Write-Host "Root Cause:" -ForegroundColor Yellow
    Write-Host "  • Variable redeclaration in Vue Composition API" -ForegroundColor White
    Write-Host "  • Improper destructuring with renamed variables" -ForegroundColor White
    Write-Host "  • JavaScript hoisting conflicts" -ForegroundColor White
    Write-Host ""
    Write-Host "Solution Applied:" -ForegroundColor Green
    Write-Host "  • Fixed composable initialization pattern" -ForegroundColor White
    Write-Host "  • Eliminated variable redeclarations" -ForegroundColor White
    Write-Host "  • Added proper null safety checks" -ForegroundColor White
    Write-Host "  • Improved error handling throughout" -ForegroundColor White
    Write-Host ""
    Write-Host "File Modified:" -ForegroundColor Blue
    Write-Host "  frontend/src/views/admin/AnalyticsDashboard.vue" -ForegroundColor White
    Write-Host ""
}

# Main execution
Write-Host "Starting Analytics Fix Verification..." -ForegroundColor Green
Write-Host ""

# Test server access
$serverOk = Test-ServerAccess
Write-Host ""

# Test analytics page
$analyticsOk = Test-AnalyticsPage
Write-Host ""

# Test JavaScript files
$jsOk = Test-JavaScriptFiles
Write-Host ""

# Show results
Write-Host "📊 VERIFICATION RESULTS" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan
Write-Host ""

if ($serverOk) {
    Write-Host "✅ Server Access: OK" -ForegroundColor Green
} else {
    Write-Host "❌ Server Access: FAILED" -ForegroundColor Red
}

if ($analyticsOk) {
    Write-Host "✅ Analytics Page: OK" -ForegroundColor Green
} else {
    Write-Host "❌ Analytics Page: FAILED" -ForegroundColor Red
}

if ($jsOk) {
    Write-Host "✅ JavaScript Files: OK" -ForegroundColor Green
} else {
    Write-Host "❌ JavaScript Files: FAILED" -ForegroundColor Red
}

Write-Host ""

if ($serverOk -and $analyticsOk -and $jsOk) {
    Write-Host "🎉 ALL CHECKS PASSED!" -ForegroundColor Green
    Write-Host "The fix appears to be deployed successfully." -ForegroundColor Green
} else {
    Write-Host "⚠️  SOME CHECKS FAILED" -ForegroundColor Yellow
    Write-Host "Manual verification may be needed." -ForegroundColor Yellow
}

# Show fix details and testing instructions
Show-FixDetails
Show-TestingInstructions

Write-Host "Press any key to open the analytics dashboard for manual testing..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Open the analytics dashboard
Start-Process $ANALYTICS_URL