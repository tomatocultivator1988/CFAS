# Fix MIME Type Error - Module Script Loading Issue
# This fixes the "Expected a JavaScript module but got text/html" error

Write-Host "=== CFAS EXAM SYSTEM - MIME TYPE FIX ===" -ForegroundColor Cyan
Write-Host ""

# Check if Apache is running
$apacheRunning = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
if (-not $apacheRunning) {
    Write-Host "ERROR: Apache is not running!" -ForegroundColor Red
    Write-Host "Please start Apache in XAMPP Control Panel first." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Step 1: Stopping Apache..." -ForegroundColor Yellow
# Stop Apache
Start-Process "C:\xampp\apache\bin\httpd.exe" -ArgumentList "-k stop" -Wait -NoNewWindow

Write-Host "Step 2: Updating .htaccess file..." -ForegroundColor Yellow

# Create improved .htaccess for frontend
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

# Write to htdocs location
$htaccessPath = "C:\xampp\htdocs\exam-frontend\.htaccess"
Set-Content -Path $htaccessPath -Value $htaccessContent -Encoding UTF8

Write-Host "Step 3: Clearing browser cache..." -ForegroundColor Yellow
Write-Host "You will need to manually clear your browser cache:" -ForegroundColor Cyan
Write-Host "  1. Press Ctrl + Shift + Delete" -ForegroundColor White
Write-Host "  2. Select 'Cached images and files'" -ForegroundColor White
Write-Host "  3. Click 'Clear data'" -ForegroundColor White
Write-Host ""

Write-Host "Step 4: Starting Apache..." -ForegroundColor Yellow
# Start Apache
Start-Process "C:\xampp\apache\bin\httpd.exe" -ArgumentList "-k start" -Wait -NoNewWindow

Start-Sleep -Seconds 3

# Verify Apache is running
$apacheRunning = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
if ($apacheRunning) {
    Write-Host ""
    Write-Host "SUCCESS! Apache restarted with fixed configuration." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Clear your browser cache (Ctrl + Shift + Delete)" -ForegroundColor White
    Write-Host "  2. Close all browser tabs with the exam system" -ForegroundColor White
    Write-Host "  3. Open a new browser window" -ForegroundColor White
    Write-Host "  4. Go to: http://192.168.11.40/exam-frontend" -ForegroundColor White
    Write-Host ""
    Write-Host "The MIME type error should now be fixed!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "ERROR: Apache failed to start!" -ForegroundColor Red
    Write-Host "Please check XAMPP Control Panel and start Apache manually." -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to exit"
