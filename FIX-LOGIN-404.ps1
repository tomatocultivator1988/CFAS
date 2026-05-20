# Fix Login 404 Error - Complete Solution
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FIXING LOGIN 404 ERROR" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check services
Write-Host "[1/6] Checking services..." -ForegroundColor Yellow
$apache = Get-Service | Where-Object { $_.Name -like "*Apache*" }
$mysql = Get-Service | Where-Object { $_.Name -like "*mysql*" }

if ($apache.Status -ne "Running") {
    Write-Host "âš  Apache is not running. Starting..." -ForegroundColor Yellow
    Start-Service $apache.Name
    Start-Sleep -Seconds 2
}
Write-Host "âœ" Apache is running" -ForegroundColor Green

if ($mysql.Status -ne "Running") {
    Write-Host "âš  MySQL is not running. Starting..." -ForegroundColor Yellow
    Start-Service $mysql.Name
    Start-Sleep -Seconds 3
}
Write-Host "âœ" MySQL is running" -ForegroundColor Green
Write-Host ""

# Step 2: Fix frontend .env file
Write-Host "[2/6] Fixing frontend .env file..." -ForegroundColor Yellow
$frontendEnvPath = Join-Path $PSScriptRoot "frontend\.env"
$envContent = @"
VITE_API_URL=http://192.168.11.40/exam-backend/public/api
VITE_APP_NAME=Review Center Exam System
"@
Set-Content -Path $frontendEnvPath -Value $envContent -Force
Write-Host "âœ" Frontend .env updated with correct API URL" -ForegroundColor Green
Write-Host ""

# Step 3: Rebuild frontend
Write-Host "[3/6] Rebuilding frontend..." -ForegroundColor Yellow
Set-Location (Join-Path $PSScriptRoot "frontend")
npm run build | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "âœ" Frontend built successfully" -ForegroundColor Green
} else {
    Write-Host "âŒ Frontend build failed" -ForegroundColor Red
    pause
    exit 1
}
Write-Host ""

# Step 4: Deploy frontend to XAMPP
Write-Host "[4/6] Deploying frontend to XAMPP..." -ForegroundColor Yellow
$frontendDist = Join-Path $PSScriptRoot "frontend\dist"
$xamppFrontend = "C:\xampp\htdocs\exam-frontend"

if (Test-Path $xamppFrontend) {
    Remove-Item -Path "$xamppFrontend\*" -Recurse -Force
}
Copy-Item -Path "$frontendDist\*" -Destination $xamppFrontend -Recurse -Force
Write-Host "âœ" Frontend deployed to XAMPP" -ForegroundColor Green
Write-Host ""

# Step 5: Verify backend vendor directory
Write-Host "[5/6] Verifying backend dependencies..." -ForegroundColor Yellow
$vendorAutoload = "C:\xampp\htdocs\exam-backend\vendor\autoload.php"
if (Test-Path $vendorAutoload) {
    Write-Host "âœ" Backend vendor directory exists" -ForegroundColor Green
} else {
    Write-Host "âŒ Backend vendor directory missing!" -ForegroundColor Red
    Write-Host "Run FIX-COMPOSER-DEPENDENCIES.bat first" -ForegroundColor Yellow
    pause
    exit 1
}
Write-Host ""

# Step 6: Test the login endpoint
Write-Host "[6/6] Testing login endpoint..." -ForegroundColor Yellow
$loginUrl = "http://192.168.11.40/exam-backend/public/api/auth/login"
$credentials = @{
    username = "admin"
    password = "password"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $loginUrl -Method POST -Body $credentials -ContentType "application/json"
    Write-Host "âœ" LOGIN TEST SUCCESSFUL!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Token: $($response.data.token.substring(0,50))..." -ForegroundColor Yellow
    Write-Host "User: $($response.data.user.username) ($($response.data.user.role))" -ForegroundColor Yellow
} catch {
    Write-Host "âŒ Login test failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "1. Apache is running and configured correctly" -ForegroundColor Yellow
    Write-Host "2. MySQL is running" -ForegroundColor Yellow
    Write-Host "3. Backend vendor directory exists" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FIX COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now log in at:" -ForegroundColor Yellow
Write-Host "http://192.168.11.40/exam-frontend" -ForegroundColor Cyan
Write-Host ""
Write-Host "Credentials:" -ForegroundColor Yellow
Write-Host "Username: admin" -ForegroundColor Cyan
Write-Host "Password: password" -ForegroundColor Cyan
Write-Host ""

Set-Location $PSScriptRoot
pause
