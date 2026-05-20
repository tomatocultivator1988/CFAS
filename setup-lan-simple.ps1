# Simple LAN Setup Script
Write-Host "🌐 CFAS Exam System - LAN Setup" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Get IP address
Write-Host "🔍 Getting your IP address..." -ForegroundColor Yellow
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" } | Select-Object -First 1).IPAddress

if ($ip) {
    Write-Host "✅ Your Server IP: $ip" -ForegroundColor Green
} else {
    Write-Host "❌ Could not detect IP!" -ForegroundColor Red
    Write-Host "Please run: ipconfig" -ForegroundColor Yellow
    Write-Host "And manually note your IPv4 Address" -ForegroundColor Yellow
    pause
    exit
}

# Add firewall rules
Write-Host "`n🔥 Adding firewall rules..." -ForegroundColor Yellow
Write-Host "(You may need to run as Administrator)" -ForegroundColor Gray

netsh advfirewall firewall delete rule name="Apache HTTP" 2>$null
netsh advfirewall firewall add rule name="Apache HTTP" dir=in action=allow protocol=TCP localport=80

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "📋 Manual Configuration Steps" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Cyan

Write-Host "`n1️⃣  Update Frontend API URL:" -ForegroundColor Cyan
Write-Host "   File: Exam-Main/frontend/src/services/api.js" -ForegroundColor White
Write-Host "   Change: const API_BASE_URL = 'http://localhost/exam-backend/api'" -ForegroundColor Gray
Write-Host "   To:     const API_BASE_URL = 'http://$ip/exam-backend/api'" -ForegroundColor Green

Write-Host "`n2️⃣  Update Backend .env:" -ForegroundColor Cyan
Write-Host "   File: Exam-Main/backend/.env" -ForegroundColor White
Write-Host "   Change: APP_URL=http://localhost/exam-backend" -ForegroundColor Gray
Write-Host "   To:     APP_URL=http://$ip/exam-backend" -ForegroundColor Green

Write-Host "`n3️⃣  Update CORS Config:" -ForegroundColor Cyan
Write-Host "   File: Exam-Main/backend/config/cors.php" -ForegroundColor White
Write-Host "   Add to 'allowed_origins' array:" -ForegroundColor Gray
Write-Host "   'http://$ip'," -ForegroundColor Green

Write-Host "`n4️⃣  Rebuild Frontend:" -ForegroundColor Cyan
Write-Host "   cd Exam-Main/frontend" -ForegroundColor White
Write-Host "   npm run build" -ForegroundColor White

Write-Host "`n5️⃣  Copy to XAMPP:" -ForegroundColor Cyan
Write-Host "   Copy dist folder contents to:" -ForegroundColor White
Write-Host "   C:\xampp\htdocs\exam-frontend" -ForegroundColor White

Write-Host "`n6️⃣  Restart Apache in XAMPP" -ForegroundColor Cyan

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "📱 Access URL" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Cyan
Write-Host "http://$ip/exam-frontend" -ForegroundColor Green -BackgroundColor Black

Write-Host "`n"
pause
