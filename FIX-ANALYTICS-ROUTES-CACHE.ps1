#!/usr/bin/env powershell
# Fix Analytics Routes Cache Issue
# This script clears Laravel caches and restarts Apache to fix route registration

Write-Host "=== Fixing Analytics Routes Cache Issue ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clear Laravel caches
Write-Host "Step 1: Clearing Laravel caches..." -ForegroundColor Yellow
try {
    Set-Location "C:\xampp\htdocs\exam-backend"
    
    Write-Host "Clearing route cache..." -ForegroundColor Gray
    & php artisan route:clear
    
    Write-Host "Clearing config cache..." -ForegroundColor Gray
    & php artisan config:clear
    
    Write-Host "Clearing application cache..." -ForegroundColor Gray
    & php artisan cache:clear
    
    Write-Host "Clearing view cache..." -ForegroundColor Gray
    & php artisan view:clear
    
    Write-Host "✅ Laravel caches cleared successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Error clearing Laravel caches: $_" -ForegroundColor Red
}

# Step 2: Restart Apache
Write-Host ""
Write-Host "Step 2: Restarting Apache..." -ForegroundColor Yellow
try {
    # Stop Apache
    Write-Host "Stopping Apache..." -ForegroundColor Gray
    & "C:\xampp\apache\bin\httpd.exe" -k stop
    Start-Sleep -Seconds 3
    
    # Start Apache
    Write-Host "Starting Apache..." -ForegroundColor Gray
    & "C:\xampp\apache\bin\httpd.exe" -k start
    Start-Sleep -Seconds 5
    
    Write-Host "✅ Apache restarted successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Error restarting Apache: $_" -ForegroundColor Red
    Write-Host "Try restarting Apache manually from XAMPP Control Panel" -ForegroundColor Yellow
}

# Step 3: Test analytics routes
Write-Host ""
Write-Host "Step 3: Testing analytics routes..." -ForegroundColor Yellow
try {
    Set-Location "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main"
    
    Write-Host "Running analytics backend test..." -ForegroundColor Gray
    & php test-analytics-backend-direct.php
    
} catch {
    Write-Host "❌ Error testing routes: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Fix Complete ===" -ForegroundColor Cyan
Write-Host "If analytics routes still return 404, check:" -ForegroundColor Yellow
Write-Host "1. Laravel service provider registration" -ForegroundColor Gray
Write-Host "2. Route middleware conflicts" -ForegroundColor Gray
Write-Host "3. Apache .htaccess configuration" -ForegroundColor Gray