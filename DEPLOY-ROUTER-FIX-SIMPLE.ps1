Write-Host "=== DEPLOYING ANALYTICS ROUTER FIX ===" -ForegroundColor Green

# Navigate to frontend directory
cd "frontend"

Write-Host "Building frontend..." -ForegroundColor Cyan
npm run build

Write-Host "Copying files to Apache..." -ForegroundColor Cyan
$targetDir = "C:\xampp\htdocs\exam-frontend"
if (!(Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force
}
Copy-Item -Path "dist\*" -Destination $targetDir -Recurse -Force

Write-Host "Restarting Apache..." -ForegroundColor Cyan
Stop-Process -Name "httpd" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process -FilePath "C:\xampp\apache\bin\httpd.exe" -WindowStyle Hidden

Write-Host "=== DEPLOYMENT COMPLETE ===" -ForegroundColor Green
Write-Host "Test at: http://192.168.11.40/exam-frontend/#/admin/analytics" -ForegroundColor Yellow

cd ".."