#!/usr/bin/env powershell
# Deploy TDZ Fix to LAN Environment
# This script fixes the Temporal Dead Zone error in PerformanceTrendChart.vue and deploys to XAMPP

Write-Host "🔧 CFAS Analytics TDZ Fix Deployment" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Check if frontend directory exists
if (-not (Test-Path "frontend")) {
    Write-Host "❌ Frontend directory not found!" -ForegroundColor Red
    Write-Host "Please run this script from the Exam-Main directory." -ForegroundColor Yellow
    exit 1
}

# Check if XAMPP directory exists
$xamppPath = "C:/xampp/htdocs/exam-frontend"
if (-not (Test-Path "C:/xampp")) {
    Write-Host "❌ XAMPP not found at C:/xampp!" -ForegroundColor Red
    Write-Host "Please ensure XAMPP is installed and running." -ForegroundColor Yellow
    exit 1
}

Write-Host "📦 Building frontend with TDZ fix..." -ForegroundColor Yellow
Set-Location frontend

# Build the frontend
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

Set-Location ..

Write-Host "✅ Build completed successfully!" -ForegroundColor Green

# Create exam-frontend directory if it doesn't exist
if (-not (Test-Path $xamppPath)) {
    Write-Host "📁 Creating exam-frontend directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $xamppPath -Force | Out-Null
}

Write-Host "🚀 Deploying to LAN environment..." -ForegroundColor Yellow

# Copy built files to XAMPP
Copy-Item -Path "frontend/dist/*" -Destination $xamppPath -Recurse -Force

Write-Host "✅ Deployment completed!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Frontend deployed to: $xamppPath" -ForegroundColor Cyan
Write-Host "🔗 Access URL: http://localhost/exam-frontend" -ForegroundColor Cyan
Write-Host "🔗 LAN URL: http://192.168.11.40/exam-frontend" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔧 TDZ Fix Applied:" -ForegroundColor Green
Write-Host "   - Fixed variable shadowing in PerformanceTrendChart.vue" -ForegroundColor White
Write-Host "   - Renamed 'const e = e.value' to 'const trendChange = improvement.value'" -ForegroundColor White
Write-Host "   - Analytics dashboard should now work without TDZ errors" -ForegroundColor White
Write-Host ""
Write-Host "💡 Test the fix by:" -ForegroundColor Yellow
Write-Host "   1. Open Analytics Dashboard" -ForegroundColor White
Write-Host "   2. Click on any student performance trend" -ForegroundColor White
Write-Host "   3. Verify no console errors appear" -ForegroundColor White
Write-Host ""
Write-Host "🎉 TDZ fix deployment complete!" -ForegroundColor Green