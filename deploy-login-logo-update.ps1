# Deploy Login Logo Update to LAN
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "CFAS Login Logo Deployment" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Build frontend
Write-Host "[1/3] Building frontend..." -ForegroundColor Yellow
Set-Location "frontend"
npm run build
Set-Location ".."
Write-Host "[OK] Build complete!" -ForegroundColor Green
Write-Host ""

# Step 2: Copy to backend/public
Write-Host "[2/3] Deploying to backend/public..." -ForegroundColor Yellow
Copy-Item -Path "frontend/dist/*" -Destination "backend/public/" -Recurse -Force
Copy-Item -Path "frontend/public/cfas-logo.jpg" -Destination "backend/public/" -Force
Write-Host "[OK] Files deployed!" -ForegroundColor Green
Write-Host ""

# Step 3: Instructions
Write-Host "[3/3] IMPORTANTE: Clear Browser Cache!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Para makita ang CFAS logo sa login page:" -ForegroundColor White
Write-Host "1. Open Chrome" -ForegroundColor White
Write-Host "2. Press Ctrl + Shift + Delete" -ForegroundColor Cyan
Write-Host "3. Select 'All time'" -ForegroundColor White
Write-Host "4. Check 'Cached images and files'" -ForegroundColor White
Write-Host "5. Click 'Clear data'" -ForegroundColor White
Write-Host "6. Refresh ang page" -ForegroundColor White
Write-Host ""
Write-Host "OR DALI LANG:" -ForegroundColor Yellow
Write-Host "Press Ctrl + Shift + R sa login page!" -ForegroundColor Cyan
Write-Host ""
Write-Host "==================================" -ForegroundColor Green
Write-Host "DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
