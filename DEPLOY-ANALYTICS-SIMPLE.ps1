# Simple Analytics Dashboard Deployment Script

Write-Host "=== CFAS Analytics Dashboard - Simple Deployment ===" -ForegroundColor Cyan

# Get network IP
$networkIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*" -or $_.IPAddress -like "172.*" }).IPAddress | Select-Object -First 1
if (-not $networkIP) {
    $networkIP = "localhost"
}

Write-Host "Network IP: $networkIP" -ForegroundColor Yellow

# Start backend
Write-Host "`n1. Starting backend..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-Command", "cd 'backend'; php artisan serve --host=0.0.0.0 --port=8000" -WindowStyle Minimized
Write-Host "Backend starting in background..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Build frontend
Write-Host "`n2. Building frontend..." -ForegroundColor Cyan
Set-Location "frontend"

if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
}

Write-Host "Building production bundle..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Frontend build completed successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Frontend build failed" -ForegroundColor Red
    Set-Location ".."
    exit 1
}

# Deploy to backend
Write-Host "`n3. Deploying to backend..." -ForegroundColor Cyan
$frontendDist = "dist"
$backendPublic = "../backend/public"

if (Test-Path "$backendPublic/assets") {
    Remove-Item "$backendPublic/assets" -Recurse -Force
    Write-Host "✓ Cleaned old assets" -ForegroundColor Green
}

Copy-Item "$frontendDist/*" "$backendPublic/" -Recurse -Force
Write-Host "✓ Frontend deployed to backend public directory" -ForegroundColor Green

Set-Location ".."

Write-Host "`n=== DEPLOYMENT COMPLETE ===" -ForegroundColor Green
Write-Host "🌐 Local: http://localhost:8000" -ForegroundColor White
Write-Host "🌐 LAN: http://$networkIP:8000" -ForegroundColor White
Write-Host "📈 Analytics: http://localhost:8000/admin/analytics" -ForegroundColor White

Write-Host "`nWait 10 seconds for backend to fully start, then test the analytics dashboard!" -ForegroundColor Cyan