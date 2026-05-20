# Fix Composer Dependencies for Backend
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FIXING COMPOSER DEPENDENCIES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Composer is installed
Write-Host "[1/5] Checking Composer installation..." -ForegroundColor Yellow
$composerPath = Get-Command composer -ErrorAction SilentlyContinue

if (-not $composerPath) {
    Write-Host "âŒ Composer is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Composer from: https://getcomposer.org/download/" -ForegroundColor Yellow
    Write-Host "After installation, restart this script." -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "âœ" Composer found: $($composerPath.Source)" -ForegroundColor Green
Write-Host ""

# Navigate to backend directory
Write-Host "[2/5] Navigating to backend directory..." -ForegroundColor Yellow
$backendPath = Join-Path $PSScriptRoot "backend"

if (-not (Test-Path $backendPath)) {
    Write-Host "âŒ Backend directory not found: $backendPath" -ForegroundColor Red
    pause
    exit 1
}

Set-Location $backendPath
Write-Host "âœ" Current directory: $backendPath" -ForegroundColor Green
Write-Host ""

# Update composer.lock to sync with composer.json
Write-Host "[3/5] Updating composer.lock file..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Gray
composer update --no-install 2>&1 | Out-String | Write-Host

if ($LASTEXITCODE -ne 0) {
    Write-Host "âŒ Failed to update composer.lock" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "âœ" composer.lock updated successfully" -ForegroundColor Green
Write-Host ""

# Install dependencies
Write-Host "[4/5] Installing Composer dependencies..." -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Gray
composer install --no-dev --optimize-autoloader 2>&1 | Out-String | Write-Host

if ($LASTEXITCODE -ne 0) {
    Write-Host "âŒ Failed to install dependencies" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "âœ" Dependencies installed successfully" -ForegroundColor Green
Write-Host ""

# Copy vendor directory to XAMPP deployment
Write-Host "[5/5] Deploying vendor directory to XAMPP..." -ForegroundColor Yellow
$xamppBackendPath = "C:\xampp\htdocs\exam-backend"
$vendorSource = Join-Path $backendPath "vendor"
$vendorDest = Join-Path $xamppBackendPath "vendor"

if (-not (Test-Path $xamppBackendPath)) {
    Write-Host "âŒ XAMPP backend directory not found: $xamppBackendPath" -ForegroundColor Red
    Write-Host "Please ensure backend is deployed to XAMPP first." -ForegroundColor Yellow
    pause
    exit 1
}

if (Test-Path $vendorDest) {
    Write-Host "Removing old vendor directory..." -ForegroundColor Gray
    Remove-Item -Path $vendorDest -Recurse -Force
}

Write-Host "Copying vendor directory (this may take a minute)..." -ForegroundColor Gray
Copy-Item -Path $vendorSource -Destination $vendorDest -Recurse -Force

Write-Host "âœ" Vendor directory deployed successfully" -ForegroundColor Green
Write-Host ""

# Test the login endpoint
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TESTING LOGIN ENDPOINT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$loginUrl = "http://192.168.11.40/exam-backend/public/api/auth/login"
$testCredentials = @{
    username = "admin"
    password = "password"
} | ConvertTo-Json

Write-Host "Testing: $loginUrl" -ForegroundColor Yellow
Write-Host "Credentials: admin / password" -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri $loginUrl -Method POST -Body $testCredentials -ContentType "application/json" -UseBasicParsing
    
    if ($response.StatusCode -eq 200) {
        Write-Host "âœ" LOGIN TEST SUCCESSFUL!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Response:" -ForegroundColor Cyan
        $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Write-Host
    } else {
        Write-Host "âš  Unexpected status code: $($response.StatusCode)" -ForegroundColor Yellow
        Write-Host "Response: $($response.Content)" -ForegroundColor Gray
    }
} catch {
    Write-Host "âŒ Login test failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now log in at: http://192.168.11.40/exam-frontend" -ForegroundColor Yellow
Write-Host "Username: admin" -ForegroundColor Yellow
Write-Host "Password: password" -ForegroundColor Yellow
Write-Host ""

pause
