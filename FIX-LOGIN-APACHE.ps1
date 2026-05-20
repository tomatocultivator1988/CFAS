#!/usr/bin/env pwsh

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FIX LOGIN - APACHE ROUTING ISSUE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ServerIP = "192.168.11.40"

# Step 1: Stop Apache
Write-Host "1. Stopping Apache..." -ForegroundColor Yellow
try {
    Stop-Process -Name "httpd" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Host "   ✅ Apache stopped" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Apache may not be running" -ForegroundColor Yellow
}

# Step 2: Check backend deployment
Write-Host ""
Write-Host "2. Checking backend deployment..." -ForegroundColor Yellow
if (Test-Path "C:\xampp\htdocs\exam-backend\public\index.php") {
    Write-Host "   ✅ Backend is deployed" -ForegroundColor Green
} else {
    Write-Host "   ❌ Backend NOT deployed! Deploying now..." -ForegroundColor Red
    
    # Deploy backend
    if (Test-Path "C:\xampp\htdocs\exam-backend") {
        Remove-Item -Path "C:\xampp\htdocs\exam-backend" -Recurse -Force
    }
    
    Copy-Item -Path "backend" -Destination "C:\xampp\htdocs\exam-backend" -Recurse -Force
    Write-Host "   ✅ Backend deployed" -ForegroundColor Green
}

# Step 3: Create .htaccess for backend
Write-Host ""
Write-Host "3. Creating backend .htaccess..." -ForegroundColor Yellow
$backendHtaccess = @"
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule ^(.*)$ public/$1 [L]
</IfModule>
"@

Set-Content -Path "C:\xampp\htdocs\exam-backend\.htaccess" -Value $backendHtaccess
Write-Host "   ✅ Backend .htaccess created" -ForegroundColor Green

# Step 4: Create .htaccess for backend/public
Write-Host ""
Write-Host "4. Creating backend/public .htaccess..." -ForegroundColor Yellow
$publicHtaccess = @"
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect Trailing Slashes If Not A Folder...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To Front Controller...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>
"@

Set-Content -Path "C:\xampp\htdocs\exam-backend\public\.htaccess" -Value $publicHtaccess
Write-Host "   ✅ Backend/public .htaccess created" -ForegroundColor Green

# Step 5: Check Apache httpd.conf
Write-Host ""
Write-Host "5. Checking Apache configuration..." -ForegroundColor Yellow
$httpdConf = "C:\xampp\apache\conf\httpd.conf"

if (Test-Path $httpdConf) {
    $content = Get-Content $httpdConf -Raw
    
    # Check if mod_rewrite is enabled
    if ($content -match "#LoadModule rewrite_module") {
        Write-Host "   ⚠️  mod_rewrite is disabled. Enabling..." -ForegroundColor Yellow
        $content = $content -replace "#LoadModule rewrite_module", "LoadModule rewrite_module"
        Set-Content -Path $httpdConf -Value $content
        Write-Host "   ✅ mod_rewrite enabled" -ForegroundColor Green
    } else {
        Write-Host "   ✅ mod_rewrite already enabled" -ForegroundColor Green
    }
    
    # Check AllowOverride
    if ($content -match "AllowOverride None") {
        Write-Host "   ⚠️  AllowOverride is None. Changing to All..." -ForegroundColor Yellow
        $content = $content -replace "AllowOverride None", "AllowOverride All"
        Set-Content -Path $httpdConf -Value $content
        Write-Host "   ✅ AllowOverride set to All" -ForegroundColor Green
    } else {
        Write-Host "   ✅ AllowOverride already configured" -ForegroundColor Green
    }
} else {
    Write-Host "   ❌ httpd.conf not found!" -ForegroundColor Red
}

# Step 6: Start Apache
Write-Host ""
Write-Host "6. Starting Apache..." -ForegroundColor Yellow
try {
    Start-Process "C:\xampp\apache\bin\httpd.exe" -WindowStyle Hidden
    Start-Sleep -Seconds 3
    
    $apache = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
    if ($apache) {
        Write-Host "   ✅ Apache started successfully" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Apache failed to start" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Error starting Apache: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 7: Test backend API
Write-Host ""
Write-Host "7. Testing backend API..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

try {
    $response = Invoke-WebRequest -Uri "http://$ServerIP/exam-backend/public/api/health" -Headers @{"Accept"="application/json"} -UseBasicParsing -TimeoutSec 10
    
    if ($response.Content -match "status") {
        Write-Host "   ✅ Backend API is working!" -ForegroundColor Green
        Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ Backend API returned unexpected response" -ForegroundColor Red
        Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ❌ Backend API test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 8: Test login
Write-Host ""
Write-Host "8. Testing login..." -ForegroundColor Yellow
try {
    $body = @{
        username = "admin"
        password = "password"
    } | ConvertTo-Json
    
    $headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
    }
    
    $response = Invoke-WebRequest -Uri "http://$ServerIP/exam-backend/public/api/auth/login" -Method POST -Body $body -Headers $headers -UseBasicParsing -TimeoutSec 10
    
    if ($response.StatusCode -eq 200) {
        $data = $response.Content | ConvertFrom-Json
        if ($data.data.token) {
            Write-Host "   ✅ Login successful!" -ForegroundColor Green
            Write-Host "   Token: $($data.data.token.Substring(0, 20))..." -ForegroundColor Gray
        } else {
            Write-Host "   ❌ Login response missing token" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "   ❌ Login test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FIX COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Open browser: http://$ServerIP/exam-frontend" -ForegroundColor White
Write-Host "2. Login with:" -ForegroundColor White
Write-Host "   Username: admin" -ForegroundColor Gray
Write-Host "   Password: password" -ForegroundColor Gray
Write-Host "3. If still not working, check XAMPP Control Panel" -ForegroundColor White
Write-Host ""
