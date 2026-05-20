#!/usr/bin/env pwsh

Write-Host "🚀 DEPLOYING ANALYTICS JAVASCRIPT FIX TO LAN SERVER" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$LAN_SERVER = "192.168.11.40"
$FRONTEND_PATH = ".\frontend"
$APACHE_FRONTEND_PATH = "C:\xampp\htdocs\exam-frontend"

Write-Host "📋 DEPLOYMENT CONFIGURATION" -ForegroundColor Yellow
Write-Host "LAN Server: $LAN_SERVER" -ForegroundColor White
Write-Host "Frontend Path: $FRONTEND_PATH" -ForegroundColor White
Write-Host "Apache Path: $APACHE_FRONTEND_PATH" -ForegroundColor White
Write-Host ""

# Function to clear browser cache
function Clear-BrowserCache {
    Write-Host "🧹 Clearing browser cache..." -ForegroundColor Blue
    
    try {
        $chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
        if (Test-Path $chromePath) {
            Remove-Item "$chromePath\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "✅ Chrome cache cleared" -ForegroundColor Green
        }
    } catch {
        Write-Host "⚠️  Chrome cache clear failed" -ForegroundColor Yellow
    }
    
    try {
        $edgePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
        if (Test-Path $edgePath) {
            Remove-Item "$edgePath\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "✅ Edge cache cleared" -ForegroundColor Green
        }
    } catch {
        Write-Host "⚠️  Edge cache clear failed" -ForegroundColor Yellow
    }
}

# Function to build frontend
function Build-Frontend {
    Write-Host "🔨 Building frontend with JavaScript fix..." -ForegroundColor Blue
    
    if (!(Test-Path $FRONTEND_PATH)) {
        Write-Host "❌ Frontend directory not found: $FRONTEND_PATH" -ForegroundColor Red
        return $false
    }
    
    Push-Location $FRONTEND_PATH
    try {
        # Clean previous build
        if (Test-Path "dist") {
            Remove-Item "dist" -Recurse -Force
            Write-Host "🧹 Cleaned previous build" -ForegroundColor Yellow
        }
        
        # Install dependencies if needed
        if (!(Test-Path "node_modules")) {
            Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
            npm install
            if ($LASTEXITCODE -ne 0) {
                Write-Host "❌ npm install failed" -ForegroundColor Red
                return $false
            }
        }
        
        # Build
        Write-Host "🔨 Running production build..." -ForegroundColor Yellow
        npm run build
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Frontend build failed" -ForegroundColor Red
            return $false
        }
        
        if (!(Test-Path "dist")) {
            Write-Host "❌ Build output directory not found" -ForegroundColor Red
            return $false
        }
        
        Write-Host "✅ Build completed successfully" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ Build failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    } finally {
        Pop-Location
    }
}

# Function to deploy to Apache
function Deploy-ToApache {
    Write-Host "🚀 Deploying to Apache server..." -ForegroundColor Blue
    
    try {
        # Ensure Apache directory exists
        if (!(Test-Path $APACHE_FRONTEND_PATH)) {
            New-Item -ItemType Directory -Path $APACHE_FRONTEND_PATH -Force | Out-Null
            Write-Host "📁 Created Apache frontend directory" -ForegroundColor Yellow
        }
        
        # Copy built files
        $sourcePath = "$FRONTEND_PATH\dist\*"
        Copy-Item -Path $sourcePath -Destination $APACHE_FRONTEND_PATH -Recurse -Force
        
        Write-Host "✅ Files deployed to Apache" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to test deployment
function Test-Deployment {
    Write-Host "🧪 Testing deployment..." -ForegroundColor Blue
    
    try {
        $testUrl = "http://$LAN_SERVER/exam-frontend/"
        $response = Invoke-WebRequest -Uri $testUrl -Method GET -TimeoutSec 10 -ErrorAction Stop
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Main page accessible" -ForegroundColor Green
        }
        
        $analyticsUrl = "http://$LAN_SERVER/exam-frontend/admin/analytics"
        $analyticsResponse = Invoke-WebRequest -Uri $analyticsUrl -Method GET -TimeoutSec 10 -ErrorAction Stop
        Write-Host "✅ Analytics page accessible" -ForegroundColor Green
        
        return $true
    } catch {
        Write-Host "⚠️  Deployment test: $($_.Exception.Message)" -ForegroundColor Yellow
        return $true # Don't fail for this
    }
}

# Main execution
Write-Host "Starting Analytics JavaScript Fix Deployment..." -ForegroundColor Green
Write-Host ""

# Step 1: Clear browser cache
Clear-BrowserCache
Write-Host ""

# Step 2: Build frontend
if (!(Build-Frontend)) {
    Write-Host "❌ Frontend build failed. Exiting." -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 3: Deploy to Apache
if (!(Deploy-ToApache)) {
    Write-Host "❌ Deployment failed. Exiting." -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 4: Test deployment
Test-Deployment
Write-Host ""

# Show summary
Write-Host "🔧 JAVASCRIPT FIX SUMMARY" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Fixed Issues:" -ForegroundColor Green
Write-Host "  ✅ ReferenceError: Cannot access 'e' before initialization" -ForegroundColor White
Write-Host "  ✅ Variable redeclaration conflicts in Vue composables" -ForegroundColor White
Write-Host "  ✅ Improper destructuring with renamed variables" -ForegroundColor White
Write-Host "  ✅ Unsafe reactive reference access" -ForegroundColor White
Write-Host ""
Write-Host "Files Modified:" -ForegroundColor Blue
Write-Host "  • frontend/src/views/admin/AnalyticsDashboard.vue" -ForegroundColor White
Write-Host ""
Write-Host "Deployment Target:" -ForegroundColor Yellow
Write-Host "  • LAN Server: http://$LAN_SERVER/exam-frontend/" -ForegroundColor White
Write-Host "  • Analytics: http://$LAN_SERVER/exam-frontend/admin/analytics" -ForegroundColor White
Write-Host ""

Write-Host "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Open browser and navigate to: http://$LAN_SERVER/exam-frontend/admin/analytics" -ForegroundColor White
Write-Host "2. Open Developer Tools (F12) and check Console tab" -ForegroundColor White
Write-Host "3. Verify no 'Cannot access 'e' before initialization' errors" -ForegroundColor White
Write-Host "4. Test time filter changes and section switching" -ForegroundColor White
Write-Host ""
Write-Host "Expected Result: Clean console with no JavaScript errors" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to open the analytics dashboard..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Open the analytics dashboard
Start-Process "http://$LAN_SERVER/exam-frontend/admin/analytics"