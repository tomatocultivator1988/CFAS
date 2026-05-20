# Simple LAN Diagnostic
Write-Host "LAN Access Diagnostic" -ForegroundColor Cyan
Write-Host "=====================`n" -ForegroundColor Cyan

# 1. Get IP
Write-Host "1. Server IP Address:" -ForegroundColor Yellow
$ips = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"}
foreach ($ip in $ips) {
    Write-Host "   $($ip.IPAddress) - $($ip.InterfaceAlias)" -ForegroundColor Green
}
$serverIP = $ips[0].IPAddress

# 2. Check Apache
Write-Host "`n2. Apache Status:" -ForegroundColor Yellow
$apache = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
if ($apache) {
    Write-Host "   Running" -ForegroundColor Green
} else {
    Write-Host "   NOT Running - Start in XAMPP!" -ForegroundColor Red
}

# 3. Check Port 80
Write-Host "`n3. Port 80 Status:" -ForegroundColor Yellow
$port = netstat -an | Select-String ":80 " | Select-String "LISTENING"
if ($port -match "0\.0\.0\.0:80") {
    Write-Host "   Listening on all interfaces (GOOD)" -ForegroundColor Green
} elseif ($port -match "127\.0\.0\.1:80") {
    Write-Host "   Only listening on localhost (BAD)" -ForegroundColor Red
    Write-Host "   FIX: Edit C:\xampp\apache\conf\httpd.conf" -ForegroundColor Yellow
    Write-Host "        Change 'Listen 127.0.0.1:80' to 'Listen 80'" -ForegroundColor Yellow
} else {
    Write-Host "   Not listening" -ForegroundColor Red
}

# 4. Check Firewall
Write-Host "`n4. Firewall Rule:" -ForegroundColor Yellow
$fw = netsh advfirewall firewall show rule name="Apache HTTP" 2>$null
if ($fw -match "Apache HTTP") {
    Write-Host "   Rule exists" -ForegroundColor Green
} else {
    Write-Host "   Rule missing (BAD)" -ForegroundColor Red
    Write-Host "   FIX: Run as admin:" -ForegroundColor Yellow
    Write-Host "        netsh advfirewall firewall add rule name=Apache HTTP dir=in action=allow protocol=TCP localport=80" -ForegroundColor Yellow
}

# 5. Check configs
Write-Host "`n5. Configuration Files:" -ForegroundColor Yellow

$backendEnv = "backend/.env"
if (Test-Path $backendEnv) {
    $appUrl = Get-Content $backendEnv | Select-String "^APP_URL="
    Write-Host "   Backend: $appUrl" -ForegroundColor Gray
}

$apiJs = "frontend/src/services/api.js"
if (Test-Path $apiJs) {
    $apiUrl = Get-Content $apiJs | Select-String "API_BASE_URL"
    Write-Host "   Frontend: $apiUrl" -ForegroundColor Gray
}

# Summary
Write-Host "`n=====================" -ForegroundColor Cyan
Write-Host "Access URL:" -ForegroundColor Yellow
Write-Host "http://$serverIP/exam-frontend" -ForegroundColor Green
Write-Host "`nPress any key..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
