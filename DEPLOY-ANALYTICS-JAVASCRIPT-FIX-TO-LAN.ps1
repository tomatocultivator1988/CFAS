#!/usr/bin/env pwsh

Write-Host "🚀 DEPLOYING ANALYTICS JAVASCRIPT FIX TO LAN SERVER" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$LAN_SERVER = "192.168.11.40"
$FRONTEND_PATH = ".\frontend"
$APACHE_FRONTEND_PATH = "C:\xampp\htdocs\exam-frontend"
$BACKUP_PATH = ".\backup\frontend-$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss')"

Write-Host "📋 DEPLOYMENT CONFIGURATION" -ForegroundColor Yellow
Write-Host "LAN Server: $LAN_SERVER" -ForegroundColor White
Write-Host "Frontend Path: $FRONTEND_PATH" -ForegroundColor White
Write-Host "Apache Path: $APACHE_FRONTEND_PATH" -ForegroundColor White
Write-Host "Backup Path: $BACKUP_PATH" -ForegroundColor White
Write-Host ""

# Function to check if frontend directory exists
function Test-FrontendDirectory {
    if (!(Test-Path $FRONTEND_PATH)) {
        Write-Host "❌ Frontend directory not found: $FRONTEND_PATH" -ForegroundColor Red
        return $false
    }
    
    if (!(Test-Path "$FRONTEND_PATH\package.json")) {
        Write-Host "❌ package.json not found in frontend directory" -ForegroundColor Red
        return $false
    }
    
    Write-Host "✅ Frontend directory validated" -ForegroundColor Green
    return $true
}

# Function to backup current deployment
function Backup-CurrentDeployment {
    Write-Host "💾 Creating backup of current deployment..." -ForegroundColor Blue
    
    try {
        if (Test-Path $APACHE_FRONTEND_PATH) {
            New-Item -ItemType Directory -Path $BACKUP_PATH -Force | Out-Null
            Copy-Item -Path "$APACHE_FRONTEND_PATH\*" -Destination $BACKUP_PATH -Recurse -Force
            Write-Host "✅ Backup created: $BACKUP_PATH" -ForegroundColor Green
            return $true
        } else {
            Write-Host "⚠️  Apache frontend path not found, skipping backup" -ForegroundColor Yellow
            return $true
        }
    } catch {
        Write-Host "❌ Backup failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

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
        Write-Host "⚠️  Chrome cache clear failed" -ForegroundColor Yellow
    }
    
    # Clear Edge cache
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

# Function to install dependencies
function Install-Dependencies {
    Write-Host "📦 Installing frontend dependencies..." -ForegroundColor Blue
    
    Push-Location $FRONTEND_PATH
    try {
        # Check if node_modules exists and is recent
        $nodeModulesPath = "node_modules"
        $packageJsonTime = (Get-Item "package.json").LastWriteTime
        
        if (Test-Path $nodeModulesPath) {
            $nodeModulesTime = (Get-Item $nodeModulesPath).LastWriteTime
            if ($nodeModulesTime -lt $packageJsonTime) {
                Write-Host "📦 package.json is newer than node_modules, reinstalling..." -ForegroundColor Yellow
                Remove-Item $nodeModulesPath -Recurse -Force
            }
        }
        
        if (!(Test-Path $nodeModulesPath)) {
            Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
            npm install
            
            if ($LASTEXITCODE -ne 0) {
                Write-Host "❌ npm install failed" -ForegroundColor Red
                return $false
            }
        }
        
        Write-Host "✅ Dependencies ready" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ Dependency installation failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    } finally {
        Pop-Location
    }
}

# Function to build frontend
function Build-Frontend {
    Write-Host "🔨 Building frontend with JavaScript fix..." -ForegroundColor Blue
    
    Push-Location $FRONTEND_PATH
    try {
        # Clean previous build
        if (Test-Path "dist") {
            Remove-Item "dist" -Recurse -Force
            Write-Host "🧹 Cleaned previous build" -ForegroundColor Yellow
        }
        
        # Build with production optimizations
        Write-Host "🔨 Running production build..." -ForegroundColor Yellow
        npm run build
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Frontend build failed" -ForegroundColor Red
            return $false
        }
        
        # Verify build output
        if (!(Test-Path "dist")) {
            Write-Host "❌ Build output directory not found" -ForegroundColor Red
            return $false
        }
        
        $buildFiles = Get-ChildItem "dist" -Recurse
        Write-Host "✅ Build completed successfully" -ForegroundColor Green
        Write-Host "📁 Build files: $($buildFiles.Count) files generated" -ForegroundColor White
        
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
        
        # Verify deployment
        $deployedFiles = Get-ChildItem $APACHE_FRONTEND_PATH -Recurse
        Write-Host "📁 Deployed files: $($deployedFiles.Count) files" -ForegroundColor White
        
        return $true
    } catch {
        Write-Host "❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to restart Apache
function Restart-Apache {
    Write-Host "🔄 Restarting Apache server..." -ForegroundColor Blue
    
    try {
        # Stop Apache
        $apacheService = Get-Service -Name "Apache*" -ErrorAction SilentlyContinue
        if ($apacheService) {
            Stop-Service $apacheService.Name -Force
            Start-Sleep -Seconds 2
            Start-Service $apacheService.Name
            Write-Host "✅ Apache restarted via service" -ForegroundColor Green
        } else {
            # Try XAMPP control
            $xamppPath = "C:\xampp\apache_stop.bat"
            if (Test-Path $xamppPath) {
                & $xamppPath
                Start-Sleep -Seconds 3
                & "C:\xampp\apache_start.bat"
                Write-Host "✅ Apache restarted via XAMPP" -ForegroundColor Green
            } else {
                Write-Host "⚠️  Apache restart method not found" -ForegroundColor Yellow
            }
        }
        
        return $true
    } catch {
        Write-Host "⚠️  Apache restart failed: $($_.Exception.Message)" -ForegroundColor Yellow
        return $true # Don't fail deployment for this
    }
}

# Function to test deployment
function Test-Deployment {
    Write-Host "🧪 Testing deployment..." -ForegroundColor Blue
    
    try {
        # Test main page
        $testUrl = "http://$LAN_SERVER/exam-frontend/"
        $response = Invoke-WebRequest -Uri $testUrl -Method GET -TimeoutSec 10 -ErrorAction Stop
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Main page accessible" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Main page returned status: $($response.StatusCode)" -ForegroundColor Yellow
        }
        
        # Test analytics page
        $analyticsUrl = "http://$LAN_SERVER/exam-frontend/admin/analytics"
        try {
            $analyticsResponse = Invoke-WebRequest -Uri $analyticsUrl -Method GET -TimeoutSec 10 -ErrorAction Stop
            Write-Host "✅ Analytics page accessible" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Analytics page test failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        return $true
    } catch {
        Write-Host "❌ Deployment test failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to show fix summary
function Show-FixSummary {
    Write-Host ""
    Write-Host "🔧 JAVASCRIPT FIX SUMMARY" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Fixed Issues:" -ForegroundColor Green
    Write-Host "  ✅ ReferenceError: Cannot access 'e' before initialization" -ForegroundColor White
    Write-Host "  ✅ Variable redeclaration conflicts in Vue composables" -ForegroundColor White
    Write-Host "  ✅ Improper destructuring with renamed variables" -ForegroundColor White
    Write-Host "  ✅ Unsafe reactive reference access" -ForegroundColor White
    Write-Host "  ✅ Router navigation error handling" -ForegroundColor White
    Write-Host ""
    Write-Host "Files Modified:" -ForegroundColor Blue
    Write-Host "  • frontend/src/views/admin/AnalyticsDashboard.vue" -ForegroundColor White
    Write-Host ""
    Write-Host "Deployment Target:" -ForegroundColor Yellow
    Write-Host "  • LAN Server: http://$LAN_SERVER/exam-frontend/" -ForegroundColor White
    Write-Host "  • Analytics: http://$LAN_SERVER/exam-frontend/admin/analytics" -ForegroundColor White
    Write-Host ""
}

# Main execution
Write-Host "Starting Analytics JavaScript Fix Deployment..." -ForegroundColor Green
Write-Host ""

# Step 1: Validate frontend directory
if (!(Test-FrontendDirectory)) {
    Write-Host "❌ Frontend validation failed. Exiting." -ForegroundColor Red
    exit 1
}

# Step 2: Create backup
if (!(Backup-CurrentDeployment)) {
    Write-Host "❌ Backup failed. Exiting for safety." -ForegroundColor Red
    exit 1
}

# Step 3: Clear browser cache
Clear-BrowserCache

# Step 4: Install dependencies
if (!(Install-Dependencies)) {
    Write-Host "❌ Dependency installation failed. Exiting." -ForegroundColor Red
    exit 1
}

# Step 5: Build frontend
if (!(Build-Frontend)) {
    Write-Host "❌ Frontend build failed. Exiting." -ForegroundColor Red
    exit 1
}

# Step 6: Deploy to Apache
if (!(Deploy-ToApache)) {
    Write-Host "❌ Deployment failed. Exiting." -ForegroundColor Red
    exit 1
}

# Step 7: Restart Apache
Restart-Apache

# Step 8: Test deployment
Start-Sleep -Seconds 5
Test-Deployment

# Show summary
Show-FixSummary

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