# Rebuild Frontend with MIME Type Fix
# This rebuilds the frontend and fixes the module script loading error

Write-Host "=== CFAS EXAM SYSTEM - REBUILD & FIX ===" -ForegroundColor Cyan
Write-Host ""

# Navigate to frontend directory
Set-Location "frontend"

Write-Host "Step 1: Cleaning old build..." -ForegroundColor Yellow
if (Test-Path "dist") {
    Remove-Item -Path "dist" -Recurse -Force
    Write-Host "  Old build removed" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 2: Building frontend..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    Set-Location ".."
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Step 3: Creating fixed .htaccess..." -ForegroundColor Yellow

# Create improved .htaccess
$htaccessContent = @"
# CRITICAL: Set MIME types BEFORE any rewrite rules
<IfModule mod_mime.c>
  AddType application/javascript .js
  AddType application/javascript .mjs
  AddType text/css .css
  AddType application/json .json
  AddType image/svg+xml .svg
  AddType image/png .png
  AddType image/jpeg .jpg .jpeg
  AddType image/webp .webp
  AddType font/woff .woff
  AddType font/woff2 .woff2
  AddType font/ttf .ttf
  AddType font/eot .eot
</IfModule>

<IfModule mod_rewrite.c>
  RewriteEngine On
  
  # CRITICAL: Don't rewrite actual files - serve them directly
  RewriteCond %{REQUEST_FILENAME} -f
  RewriteRule ^ - [L]
  
  # Don't rewrite directories
  RewriteCond %{REQUEST_FILENAME} -d
  RewriteRule ^ - [L]
  
  # Only rewrite non-existent files to index.html for Vue Router
  RewriteRule ^ index.html [L]
</IfModule>

# Disable directory browsing
Options -Indexes +FollowSymLinks

# Enable CORS for assets
<IfModule mod_headers.c>
  <FilesMatch "\.(js|mjs|css|json|svg|png|jpg|jpeg|webp|woff|woff2|ttf|eot)$">
    Header set Access-Control-Allow-Origin "*"
    Header set Cache-Control "public, max-age=31536000"
  </FilesMatch>
  
  # Ensure correct Content-Type headers
  <FilesMatch "\.js$">
    Header set Content-Type "application/javascript"
  </FilesMatch>
  
  <FilesMatch "\.mjs$">
    Header set Content-Type "application/javascript"
  </FilesMatch>
  
  <FilesMatch "\.css$">
    Header set Content-Type "text/css"
  </FilesMatch>
</IfModule>

# Set default charset
AddDefaultCharset UTF-8
"@

Set-Content -Path "dist/.htaccess" -Value $htaccessContent -Encoding UTF8
Write-Host "  .htaccess created with MIME type fixes" -ForegroundColor Green

Write-Host ""
Write-Host "Step 4: Deploying to Apache..." -ForegroundColor Yellow

# Copy to Apache htdocs
$destination = "C:\xampp\htdocs\exam-frontend"

if (Test-Path $destination) {
    Remove-Item -Path $destination -Recurse -Force
}

Copy-Item -Path "dist" -Destination $destination -Recurse
Write-Host "  Deployed to: $destination" -ForegroundColor Green

Write-Host ""
Write-Host "Step 5: Restarting Apache..." -ForegroundColor Yellow

# Stop Apache
Start-Process "C:\xampp\apache\bin\httpd.exe" -ArgumentList "-k stop" -Wait -NoNewWindow -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Start Apache
Start-Process "C:\xampp\apache\bin\httpd.exe" -ArgumentList "-k start" -Wait -NoNewWindow
Start-Sleep -Seconds 3

# Verify Apache is running
$apacheRunning = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
if ($apacheRunning) {
    Write-Host "  Apache restarted successfully" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Apache may not be running" -ForegroundColor Yellow
    Write-Host "  Please check XAMPP Control Panel" -ForegroundColor Yellow
}

Set-Location ".."

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  REBUILD & FIX COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: Clear your browser cache!" -ForegroundColor Cyan
Write-Host "  1. Press Ctrl + Shift + Delete" -ForegroundColor White
Write-Host "  2. Select 'Cached images and files'" -ForegroundColor White
Write-Host "  3. Click 'Clear data'" -ForegroundColor White
Write-Host "  4. Close ALL browser tabs" -ForegroundColor White
Write-Host "  5. Open new browser window" -ForegroundColor White
Write-Host "  6. Go to: http://192.168.11.40/exam-frontend" -ForegroundColor White
Write-Host ""
Write-Host "The MIME type error should now be fixed!" -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to exit"
