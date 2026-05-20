# LAN Access Setup Script
# Run as Administrator

Write-Host "🌐 CFAS Exam System - LAN Setup" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ Please run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit
}

# Get server IP
Write-Host "🔍 Detecting server IP address..." -ForegroundColor Yellow
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.InterfaceAlias -notlike "*Loopback*" -and 
    $_.InterfaceAlias -notlike "*Bluetooth*" -and
    ($_.PrefixOrigin -eq "Dhcp" -or $_.PrefixOrigin -eq "Manual")
} | Select-Object -First 1).IPAddress

if (-not $ip) {
    Write-Host "❌ Could not detect IP address!" -ForegroundColor Red
    exit
}

Write-Host "✅ Server IP: $ip" -ForegroundColor Green

# Add firewall rules
Write-Host "`n🔥 Configuring Windows Firewall..." -ForegroundColor Yellow

try {
    # Remove old rules if exist
    netsh advfirewall firewall delete rule name="Apache HTTP" 2>$null
    netsh advfirewall firewall delete rule name="Apache HTTPS" 2>$null
    
    # Add new rules
    netsh advfirewall firewall add rule name="Apache HTTP" dir=in action=allow protocol=TCP localport=80 | Out-Null
    netsh advfirewall firewall add rule name="Apache HTTPS" dir=in action=allow protocol=TCP localport=443 | Out-Null
    
    Write-Host "✅ Firewall rules added!" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Warning: Could not add firewall rules" -ForegroundColor Yellow
}

# Update frontend API URL
Write-Host "`n📝 Updating frontend configuration..." -ForegroundColor Yellow

$apiFile = "Exam-Main/frontend/src/services/api.js"
if (Test-Path $apiFile) {
    $content = Get-Content $apiFile -Raw
    $newUrl = "http://$ip/exam-backend/api"
    $content = $content -replace "const API_BASE_URL = 'http://localhost/exam-backend/api'", "const API_BASE_URL = '$newUrl'"
    $content = $content -replace "const API_BASE_URL = 'http://[^']+/exam-backend/api'", "const API_BASE_URL = '$newUrl'"
    Set-Content $apiFile -Value $content
    Write-Host "✅ Frontend API URL updated to: $newUrl" -ForegroundColor Green
} else {
    Write-Host "⚠️  Frontend api.js not found" -ForegroundColor Yellow
}

# Update backend .env
Write-Host "`n📝 Updating backend configuration..." -ForegroundColor Yellow

$envFile = "Exam-Main/backend/.env"
if (Test-Path $envFile) {
    $content = Get-Content $envFile
    $newContent = @()
    
    foreach ($line in $content) {
        if ($line -match "^APP_URL=") {
            $newContent += "APP_URL=http://$ip/exam-backend"
        }
        elseif ($line -match "^FRONTEND_URL=") {
            $newContent += "FRONTEND_URL=http://$ip/exam-frontend"
        }
        else {
            $newContent += $line
        }
    }
    
    Set-Content $envFile -Value $newContent
    Write-Host "✅ Backend .env updated!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Backend .env not found" -ForegroundColor Yellow
}

# Update CORS config - Skip for now, will do manually
Write-Host "`n📝 CORS configuration..." -ForegroundColor Yellow
Write-Host "⚠️  Please manually add '$ip' to CORS allowed_origins in:" -ForegroundColor Yellow
Write-Host "   Exam-Main/backend/config/cors.php" -ForegroundColor Gray

# Summary
Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "✅ LAN Setup Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan

Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Manually update CORS (if needed):" -ForegroundColor White
Write-Host "   Edit: Exam-Main/backend/config/cors.php" -ForegroundColor Gray
Write-Host "   Add: 'http://$ip' to allowed_origins array" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Rebuild frontend:" -ForegroundColor White
Write-Host "   cd Exam-Main/frontend" -ForegroundColor Gray
Write-Host "   npm run build" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Copy dist folder to:" -ForegroundColor White
Write-Host "   C:\xampp\htdocs\exam-frontend" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Restart Apache in XAMPP Control Panel" -ForegroundColor White
Write-Host ""
Write-Host "5. Access from any PC on network:" -ForegroundColor White
Write-Host "   http://$ip/exam-frontend" -ForegroundColor Cyan
Write-Host ""

Write-Host "📱 Share this URL with students:" -ForegroundColor Yellow
Write-Host "   http://$ip/exam-frontend" -ForegroundColor Green -BackgroundColor Black
Write-Host ""

# Create access info file
$accessInfo = @"
CFAS Exam System - Network Access Information
==============================================

Server IP: $ip

Access URLs:
- Frontend: http://$ip/exam-frontend
- Backend API: http://$ip/exam-backend/api

Student Login:
- Username: reviewee
- Password: password

Admin Login:
- Username: admin
- Password: admin123

Setup Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Note: All PCs must be connected to the same network/router.

CORS Configuration:
Edit: Exam-Main/backend/config/cors.php
Add this line to 'allowed_origins' array:
    'http://$ip',
"@

Set-Content "Exam-Main/NETWORK_ACCESS_INFO.txt" -Value $accessInfo
Write-Host "📄 Access info saved to: NETWORK_ACCESS_INFO.txt" -ForegroundColor Cyan

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
