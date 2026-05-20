# ============================================================================
# Deploy Laravel Backend to Apache XAMPP
# This script deploys the backend to run through Apache
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEPLOY BACKEND TO APACHE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$backendSource = Join-Path $PSScriptRoot "backend"
$backendDest = "C:\xampp\htdocs\exam-backend"
$frontendPath = "C:\xampp\htdocs\exam-frontend"

# Check if backend source exists
if (-not (Test-Path $backendSource)) {
    Write-Host "ERROR: Backend source not found at: $backendSource" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Create backend directory in htdocs
Write-Host "Creating backend directory..." -ForegroundColor Yellow
if (-not (Test-Path $backendDest)) {
    New-Item -ItemType Directory -Path $backendDest -Force | Out-Null
}

# Copy backend files
Write-Host "Copying backend files to Apache..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Gray

# Copy all files except vendor (we'll run composer install)
$excludeDirs = @('vendor', 'node_modules', 'storage\logs', 'storage\framework\cache', 'storage\framework\sessions', 'storage\framework\views')

Get-ChildItem -Path $backendSource -Recurse | ForEach-Object {
    $relativePath = $_.FullName.Substring($backendSource.Length)
    $destPath = Join-Path $backendDest $relativePath
    
    $shouldExclude = $false
    foreach ($excludeDir in $excludeDirs) {
        if ($relativePath -like "*\$excludeDir\*" -or $relativePath -like "*/$excludeDir/*") {
            $shouldExclude = $true
            break
        }
    }
    
    if (-not $shouldExclude) {
        if ($_.PSIsContainer) {
            if (-not (Test-Path $destPath)) {
                New-Item -ItemType Directory -Path $destPath -Force | Out-Null
            }
        } else {
            Copy-Item -Path $_.FullName -Destination $destPath -Force
        }
    }
}

Write-Host "Backend files copied successfully!" -ForegroundColor Green
Write-Host ""

# Create necessary storage directories
Write-Host "Creating storage directories..." -ForegroundColor Yellow
$storageDirs = @(
    "$backendDest\storage\app\public",
    "$backendDest\storage\framework\cache\data",
    "$backendDest\storage\framework\sessions",
    "$backendDest\storage\framework\views",
    "$backendDest\storage\logs"
)

foreach ($dir in $storageDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

Write-Host "Storage directories created!" -ForegroundColor Green
Write-Host ""

# Run composer install
Write-Host "Installing Composer dependencies..." -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Gray
Push-Location $backendDest
& composer install --no-dev --optimize-autoloader 2>&1 | Out-Null
Pop-Location
Write-Host "Composer dependencies installed!" -ForegroundColor Green
Write-Host ""

# Copy .env file
Write-Host "Configuring environment..." -ForegroundColor Yellow
if (Test-Path "$backendSource\.env") {
    Copy-Item "$backendSource\.env" "$backendDest\.env" -Force
} else {
    Copy-Item "$backendSource\.env.example" "$backendDest\.env" -Force
}

# Update .env for Apache deployment
$envContent = Get-Content "$backendDest\.env" -Raw
$envContent = $envContent -replace 'APP_URL=.*', 'APP_URL=http://192.168.11.40/exam-backend'
$envContent = $envContent -replace 'FRONTEND_URL=.*', 'FRONTEND_URL=http://192.168.11.40/exam-frontend'
Set-Content "$backendDest\.env" $envContent

Write-Host "Environment configured!" -ForegroundColor Green
Write-Host ""

# Create .htaccess for Laravel routing
Write-Host "Creating Apache configuration..." -ForegroundColor Yellow

$htaccessContent = @"
<IfModule mod_rewrite.c>
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

# Disable directory browsing
Options -Indexes

# Set default charset
AddDefaultCharset UTF-8

# Enable CORS
<IfModule mod_headers.c>
    Header set Access-Control-Allow-Origin "*"
    Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With"
</IfModule>
"@

Set-Content "$backendDest\public\.htaccess" $htaccessContent

Write-Host "Apache configuration created!" -ForegroundColor Green
Write-Host ""

# Update frontend API configuration
Write-Host "Updating frontend API configuration..." -ForegroundColor Yellow

$apiJsPath = "$frontendPath\assets\api-*.js"
$apiFiles = Get-ChildItem -Path "$frontendPath\assets" -Filter "api-*.js" -ErrorAction SilentlyContinue

if ($apiFiles) {
    foreach ($file in $apiFiles) {
        $content = Get-Content $file.FullName -Raw
        $content = $content -replace 'http://127\.0\.0\.1:8000/api', 'http://192.168.11.40/exam-backend/public/api'
        $content = $content -replace 'http://localhost:8000/api', 'http://192.168.11.40/exam-backend/public/api'
        Set-Content $file.FullName $content
    }
    Write-Host "Frontend API configuration updated!" -ForegroundColor Green
} else {
    Write-Host "Warning: Frontend API files not found. You may need to rebuild frontend." -ForegroundColor Yellow
}

Write-Host ""

# Generate application key if needed
Write-Host "Generating application key..." -ForegroundColor Yellow
Push-Location $backendDest
& php artisan key:generate --force 2>&1 | Out-Null
Pop-Location
Write-Host "Application key generated!" -ForegroundColor Green
Write-Host ""

# Run migrations
Write-Host "Running database migrations..." -ForegroundColor Yellow
Push-Location $backendDest
& php artisan migrate --force 2>&1 | Out-Null
Pop-Location
Write-Host "Database migrations completed!" -ForegroundColor Green
Write-Host ""

# Clear and cache config
Write-Host "Optimizing application..." -ForegroundColor Yellow
Push-Location $backendDest
& php artisan config:cache 2>&1 | Out-Null
& php artisan route:cache 2>&1 | Out-Null
& php artisan view:cache 2>&1 | Out-Null
Pop-Location
Write-Host "Application optimized!" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "  DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Backend URL: http://192.168.11.40/exam-backend/public" -ForegroundColor Cyan
Write-Host "API URL: http://192.168.11.40/exam-backend/public/api" -ForegroundColor Cyan
Write-Host "Frontend URL: http://192.168.11.40/exam-frontend" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: You need to rebuild the frontend with the new API URL!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Update frontend .env file:" -ForegroundColor White
Write-Host "   VITE_API_URL=http://192.168.11.40/exam-backend/public/api" -ForegroundColor Gray
Write-Host "2. Rebuild frontend:" -ForegroundColor White
Write-Host "   cd frontend && npm run build" -ForegroundColor Gray
Write-Host "3. Start XAMPP (Apache + MySQL)" -ForegroundColor White
Write-Host "4. Open browser to: http://192.168.11.40/exam-frontend" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to exit"
