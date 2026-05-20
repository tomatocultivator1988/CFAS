# CFAS Analytics Dashboard - Simple LAN Deployment

Write-Host "=== CFAS Analytics Dashboard - LAN Deployment ===" -ForegroundColor Cyan

# Get network IP
$networkIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.IPAddress -like "192.168.*" -or 
    $_.IPAddress -like "10.*" -or 
    $_.IPAddress -like "172.*" 
}).IPAddress | Select-Object -First 1

if (-not $networkIP) {
    $networkIP = "localhost"
}

Write-Host "Network IP: $networkIP" -ForegroundColor Yellow

# Stop existing PHP processes
Get-Process | Where-Object {$_.ProcessName -eq "php"} | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "Stopped existing PHP processes" -ForegroundColor Green

# Start backend for LAN access
Write-Host "`nStarting backend server for LAN access..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-Command", "cd 'backend'; php artisan serve --host=0.0.0.0 --port=8000" -WindowStyle Minimized
Write-Host "Backend started on 0.0.0.0:8000 for LAN access" -ForegroundColor Green

# Wait for backend
Write-Host "Waiting for backend to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

# Test backend
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8000/" -Method GET -TimeoutSec 5
    Write-Host "Backend is responding: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "Backend may still be starting..." -ForegroundColor Yellow
}

Write-Host "`n=== LAN DEPLOYMENT COMPLETE ===" -ForegroundColor Green
Write-Host "Analytics Dashboard deployed for LAN access!" -ForegroundColor Cyan
Write-Host ""
Write-Host "LAN Access URLs:" -ForegroundColor Yellow
Write-Host "  Main Dashboard: http://$networkIP`:8000" -ForegroundColor White
Write-Host "  Analytics Page: http://$networkIP`:8000/admin/analytics" -ForegroundColor White
Write-Host "  Admin Login:    http://$networkIP`:8000/login" -ForegroundColor White
Write-Host ""
Write-Host "Local Access:" -ForegroundColor Yellow
Write-Host "  http://localhost:8000" -ForegroundColor White
Write-Host ""
Write-Host "Status:" -ForegroundColor Yellow
Write-Host "  Backend running on 0.0.0.0:8000 (LAN accessible)" -ForegroundColor Green
Write-Host "  Frontend already built and deployed" -ForegroundColor Green
Write-Host "  Network IP: $networkIP" -ForegroundColor Green
Write-Host ""
Write-Host "Ready na ang analytics dashboard para sa LAN testing!" -ForegroundColor Cyan
Write-Host "Share ang URL sa mga users: http://$networkIP`:8000" -ForegroundColor Yellow