Write-Host "Deploying TDZ Fix to LAN..." -ForegroundColor Cyan

# Build frontend
Write-Host "Building frontend..." -ForegroundColor Yellow
Set-Location frontend
npm run build
Set-Location ..

# Deploy to XAMPP
Write-Host "Deploying to XAMPP..." -ForegroundColor Yellow
$xamppPath = "C:/xampp/htdocs/exam-frontend"

if (-not (Test-Path $xamppPath)) {
    New-Item -ItemType Directory -Path $xamppPath -Force
}

Copy-Item -Path "frontend/dist/*" -Destination $xamppPath -Recurse -Force

Write-Host "TDZ fix deployed successfully!" -ForegroundColor Green
Write-Host "Access: http://192.168.11.40/exam-frontend" -ForegroundColor Cyan