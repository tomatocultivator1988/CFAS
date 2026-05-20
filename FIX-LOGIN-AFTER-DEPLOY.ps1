# Quick Fix for Login Issues After Deployment
# This script fixes common authentication problems

Write-Host "=== CFAS Login Fix Script ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clear Laravel cache
Write-Host "1. Clearing Laravel cache..." -ForegroundColor Yellow
Push-Location "Exam-Main/backend"
try {
    php artisan config:clear
    php artisan cache:clear
    php artisan route:clear
    Write-Host "   ✓ Laravel cache cleared" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed to clear cache: $($_.Exception.Message)" -ForegroundColor Red
}
Pop-Location

# Step 2: Verify database connection
Write-Host ""
Write-Host "2. Checking database connection..." -ForegroundColor Yellow
Push-Location "Exam-Main/backend"
try {
    $dbCheck = php artisan migrate:status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Database connection OK" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Database connection failed" -ForegroundColor Red
        Write-Host "   Please check your .env database settings" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ✗ Error checking database" -ForegroundColor Red
}
Pop-Location

# Step 3: Rebuild frontend with cache busting
Write-Host ""
Write-Host "3. Rebuilding frontend with cache busting..." -ForegroundColor Yellow
Push-Location "Exam-Main/frontend"
try {
    # Update build timestamp to force cache refresh
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    Write-Host "   Build timestamp: $timestamp" -ForegroundColor Gray
    
    npm run build
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Frontend rebuilt successfully" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Frontend build failed" -ForegroundColor Red
        Pop-Location
        exit 1
    }
} catch {
    Write-Host "   ✗ Build error: $($_.Exception.Message)" -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location

# Step 4: Deploy to Apache with timestamp
Write-Host ""
Write-Host "4. Deploying to Apache..." -ForegroundColor Yellow
$apachePath = "C:\Apache24\htdocs\cfas"

# Backup old deployment
if (Test-Path $apachePath) {
    $backupPath = "C:\Apache24\htdocs\cfas_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Write-Host "   Creating backup: $backupPath" -ForegroundColor Gray
    Copy-Item -Path $apachePath -Destination $backupPath -Recurse -Force
}

# Deploy new build
try {
    if (!(Test-Path $apachePath)) {
        New-Item -ItemType Directory -Path $apachePath -Force | Out-Null
    }
    
    Copy-Item -Path "Exam-Main/frontend/dist/*" -Destination $apachePath -Recurse -Force
    Write-Host "   ✓ Deployed to Apache" -ForegroundColor Green
    
    # Add cache-busting headers to .htaccess
    $htaccessContent = @"
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /cfas/
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /cfas/index.html [L]
</IfModule>

# Cache busting for static assets
<IfModule mod_headers.c>
  # Force revalidation for HTML files
  <FilesMatch "\.(html|htm)$">
    Header set Cache-Control "no-cache, no-store, must-revalidate"
    Header set Pragma "no-cache"
    Header set Expires 0
  </FilesMatch>
  
  # Cache JS and CSS with versioning
  <FilesMatch "\.(js|css)$">
    Header set Cache-Control "public, max-age=31536000, immutable"
  </FilesMatch>
  
  # Cache images
  <FilesMatch "\.(jpg|jpeg|png|gif|ico|svg)$">
    Header set Cache-Control "public, max-age=2592000"
  </FilesMatch>
</IfModule>

# Enable CORS for API requests
<IfModule mod_headers.c>
  Header always set Access-Control-Allow-Origin "*"
  Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
  Header always set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With"
</IfModule>
"@
    
    $htaccessPath = Join-Path $apachePath ".htaccess"
    Set-Content -Path $htaccessPath -Value $htaccessContent -Force
    Write-Host "   ✓ Updated .htaccess with cache busting" -ForegroundColor Green
    
} catch {
    Write-Host "   ✗ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 5: Restart Apache
Write-Host ""
Write-Host "5. Restarting Apache..." -ForegroundColor Yellow
try {
    $apacheService = Get-Service -Name "Apache2.4" -ErrorAction SilentlyContinue
    if ($apacheService) {
        Restart-Service -Name "Apache2.4" -Force
        Start-Sleep -Seconds 2
        Write-Host "   ✓ Apache restarted" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Apache service not found, trying httpd.exe..." -ForegroundColor Yellow
        $httpdPath = "C:\Apache24\bin\httpd.exe"
        if (Test-Path $httpdPath) {
            & $httpdPath -k restart
            Start-Sleep -Seconds 2
            Write-Host "   ✓ Apache restarted via httpd.exe" -ForegroundColor Green
        } else {
            Write-Host "   ⚠ Could not restart Apache automatically" -ForegroundColor Yellow
            Write-Host "   Please restart Apache manually" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   ⚠ Apache restart warning: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Step 6: Test the deployment
Write-Host ""
Write-Host "6. Testing deployment..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

try {
    $testUrl = "http://localhost/cfas"
    $response = Invoke-WebRequest -Uri $testUrl -Method GET -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✓ Deployment accessible at $testUrl" -ForegroundColor Green
    }
} catch {
    Write-Host "   ✗ Could not access deployment" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Final instructions
Write-Host ""
Write-Host "=== Fix Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Open your browser" -ForegroundColor Gray
Write-Host "2. Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor Gray
Write-Host "   - Select 'Cached images and files'" -ForegroundColor Gray
Write-Host "   - Select 'Cookies and other site data'" -ForegroundColor Gray
Write-Host "3. Go to: http://localhost/cfas" -ForegroundColor Gray
Write-Host "4. Login with your credentials" -ForegroundColor Gray
Write-Host ""
Write-Host "If you still can't login:" -ForegroundColor Yellow
Write-Host "- Try incognito/private browsing mode" -ForegroundColor Gray
Write-Host "- Check browser console (F12) for errors" -ForegroundColor Gray
Write-Host "- Run: .\DIAGNOSE-LOGIN-ANALYTICS.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "Access URLs:" -ForegroundColor Cyan
Write-Host "- Frontend: http://localhost/cfas" -ForegroundColor Gray
Write-Host "- Backend API: http://localhost:8000/api" -ForegroundColor Gray
Write-Host ""
