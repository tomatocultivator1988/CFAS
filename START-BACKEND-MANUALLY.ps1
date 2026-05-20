# ============================================================================
# Manual Backend Starter - Simple Version
# Run this if the launcher doesn't start the backend
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STARTING LARAVEL BACKEND MANUALLY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$backendPath = Join-Path $PSScriptRoot "backend"

# Check if backend directory exists
if (-not (Test-Path $backendPath)) {
    Write-Host "ERROR: Backend directory not found!" -ForegroundColor Red
    Write-Host "Expected path: $backendPath" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit
}

Write-Host "Backend directory found: $backendPath" -ForegroundColor Green
Write-Host ""

# Check if PHP is available
try {
    $phpVersion = php -v 2>&1 | Select-Object -First 1
    Write-Host "PHP found: $phpVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: PHP not found in PATH!" -ForegroundColor Red
    Write-Host "Make sure XAMPP PHP is in your system PATH" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit
}

Write-Host ""
Write-Host "Starting Laravel backend server..." -ForegroundColor Cyan
Write-Host "Host: 127.0.0.1" -ForegroundColor White
Write-Host "Port: 8000" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Navigate to backend and start server
Set-Location $backendPath
php artisan serve --host=127.0.0.1 --port=8000
