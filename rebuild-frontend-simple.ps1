# Rebuild Frontend with New Backend URL
Write-Host ""
Write-Host "========================================"
Write-Host "  REBUILD AND DEPLOY FRONTEND"
Write-Host "========================================"
Write-Host ""

# Navigate to frontend directory
$frontendPath = "C:\Users\Hi\Desktop\CFAS REVIEW CENTER EXAMINATION SYSTEM\Exam-Main\frontend"
Set-Location $frontendPath

Write-Host "[1/4] Updating environment configuration..."
$envContent = "VITE_API_URL=http://192.168.11.40/exam-backend/public/api"
Set-Content -Path ".env.production" -Value $envContent -Encoding UTF8
Write-Host "Done!"
Write-Host ""

Write-Host "[2/4] Installing dependencies..."
Write-Host "This may take a few minutes..."
npm install 2>&1 | Out-Null
Write-Host "Done!"
Write-Host ""

Write-Host "[3/4] Building frontend..."
Write-Host "This may take a few minutes..."
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Build failed!"
    Write-Host "Please check the error messages above."
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Done!"
Write-Host ""

Write-Host "[4/4] Deploying to Apache..."

# Clear existing frontend files
$apacheFrontend = "C:\xampp\htdocs\exam-frontend"
if (Test-Path $apacheFrontend) {
    Remove-Item -Path $apacheFrontend -Recurse -Force
}

# Create directory
New-Item -Path $apacheFrontend -ItemType Directory -Force | Out-Null

# Copy built files
Copy-Item -Path "dist\*" -Destination $apacheFrontend -Recurse -Force

Write-Host "Done!"
Write-Host ""

Write-Host "========================================"
Write-Host "  DEPLOYMENT COMPLETE!"
Write-Host "========================================"
Write-Host ""
Write-Host "Frontend has been rebuilt and deployed!"
Write-Host ""
Write-Host "You can now access the system at:"
Write-Host "http://192.168.11.40/exam-frontend"
Write-Host ""
Write-Host "IMPORTANT: Make sure XAMPP (Apache + MySQL) is running!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Start XAMPP Control Panel"
Write-Host "2. Start Apache (if not running)"
Write-Host "3. Start MySQL (if not running)"
Write-Host "4. Open browser to: http://192.168.11.40/exam-frontend"
Write-Host "5. Login and test!"
Write-Host ""
Read-Host "Press Enter to exit"
