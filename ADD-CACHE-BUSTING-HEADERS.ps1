Write-Host "=== ADDING CACHE-BUSTING HEADERS TO APACHE ===" -ForegroundColor Cyan
Write-Host ""

$htaccessPath = "C:\Apache24\htdocs\exam-frontend\.htaccess"

$cacheConfig = @"
# Cache-busting configuration for SPA
<IfModule mod_headers.c>
    # Don't cache HTML files - always get fresh version
    <FilesMatch "\.(html|htm)$">
        Header set Cache-Control "no-cache, no-store, must-revalidate, max-age=0"
        Header set Pragma "no-cache"
        Header set Expires "0"
    </FilesMatch>
    
    # Cache JS/CSS with versioning (1 year)
    <FilesMatch "\.(js|css)$">
        Header set Cache-Control "public, max-age=31536000, immutable"
    </FilesMatch>
    
    # Cache images (1 month)
    <FilesMatch "\.(jpg|jpeg|png|gif|ico|svg|webp)$">
        Header set Cache-Control "public, max-age=2592000"
    </FilesMatch>
</IfModule>

# Existing routing rules
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /exam-frontend/
    
    # Don't rewrite files or directories that exist
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    
    # Rewrite everything else to index.html
    RewriteRule ^ index.html [L]
</IfModule>
"@

Write-Host "Writing .htaccess with cache-busting headers..." -ForegroundColor Yellow
Set-Content -Path $htaccessPath -Value $cacheConfig -Encoding UTF8

Write-Host "Cache-busting headers added!" -ForegroundColor Green
Write-Host ""
Write-Host "=== RESTARTING APACHE ===" -ForegroundColor Cyan
& "C:\Apache24\bin\httpd.exe" -k restart
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "=== DONE! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Now do this:" -ForegroundColor Yellow
Write-Host "1. Close ALL browser windows completely" -ForegroundColor White
Write-Host "2. Open a NEW browser window" -ForegroundColor White
Write-Host "3. Go to: http://192.168.11.40/exam-frontend/admin/analytics" -ForegroundColor White
Write-Host ""
Write-Host "The HTML will never be cached again!" -ForegroundColor Green
Write-Host ""
