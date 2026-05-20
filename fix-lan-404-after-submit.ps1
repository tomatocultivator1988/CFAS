# Fix 404 Error After Exam Submission on LAN
# This ensures the .htaccess file is properly configured for SPA routing

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Fixing 404 After Exam Submission" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$xamppPath = "C:\xampp\htdocs\exam-frontend"

# Check if directory exists
if (-not (Test-Path $xamppPath)) {
    Write-Host "ERROR: $xamppPath not found!" -ForegroundColor Red
    Write-Host "Please run deploy-for-lan.ps1 first" -ForegroundColor Yellow
    exit 1
}

Write-Host "1. Creating proper .htaccess for SPA routing..." -ForegroundColor Yellow

$htaccessContent = @"
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /exam-frontend/
  
  # Don't rewrite files or directories
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  
  # Rewrite everything else to index.html to allow Vue Router to handle it
  RewriteRule ^ index.html [L]
</IfModule>

# Disable directory browsing
Options -Indexes

# Set default charset
AddDefaultCharset UTF-8

# Browser Caching for assets
<IfModule mod_expires.c>
    ExpiresActive On
    
    # Images
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
    
    # CSS and JavaScript
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    
    # HTML - no cache
    ExpiresByType text/html "access plus 0 seconds"
</IfModule>

# Gzip Compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE text/javascript
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/json
</IfModule>
"@

$htaccessPath = Join-Path $xamppPath ".htaccess"
Set-Content -Path $htaccessPath -Value $htaccessContent -Encoding UTF8

Write-Host "   .htaccess created successfully" -ForegroundColor Green

Write-Host "`n2. Verifying Apache mod_rewrite is enabled..." -ForegroundColor Yellow

$httpdConf = "C:\xampp\apache\conf\httpd.conf"
if (Test-Path $httpdConf) {
    $content = Get-Content $httpdConf -Raw
    
    if ($content -match "#LoadModule rewrite_module") {
        Write-Host "   WARNING: mod_rewrite is commented out!" -ForegroundColor Red
        Write-Host "   Please uncomment 'LoadModule rewrite_module' in httpd.conf" -ForegroundColor Yellow
    } elseif ($content -match "LoadModule rewrite_module") {
        Write-Host "   mod_rewrite is enabled" -ForegroundColor Green
    } else {
        Write-Host "   Could not verify mod_rewrite status" -ForegroundColor Yellow
    }
}

Write-Host "`n3. Checking AllowOverride setting..." -ForegroundColor Yellow

if (Test-Path $httpdConf) {
    $content = Get-Content $httpdConf -Raw
    
    if ($content -match "AllowOverride None") {
        Write-Host "   WARNING: AllowOverride is set to None!" -ForegroundColor Red
        Write-Host "   .htaccess files will be ignored" -ForegroundColor Yellow
        Write-Host "   Change 'AllowOverride None' to 'AllowOverride All' in httpd.conf" -ForegroundColor Yellow
    } else {
        Write-Host "   AllowOverride appears to be configured" -ForegroundColor Green
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Fix Applied!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Restart Apache in XAMPP Control Panel" -ForegroundColor White
Write-Host "2. Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
Write-Host "3. Test exam submission again" -ForegroundColor White

Write-Host "`nIf still getting 404:" -ForegroundColor Yellow
Write-Host "1. Check C:\xampp\apache\conf\httpd.conf" -ForegroundColor White
Write-Host "2. Find 'LoadModule rewrite_module' and uncomment it" -ForegroundColor White
Write-Host "3. Find 'AllowOverride None' and change to 'AllowOverride All'" -ForegroundColor White
Write-Host "4. Restart Apache" -ForegroundColor White

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
