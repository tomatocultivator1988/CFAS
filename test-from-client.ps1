# Test LAN Access from Client PC
# Run this on the CLIENT PC (not server)

$serverIP = "192.168.11.40"

Write-Host "Testing LAN Access to Exam System" -ForegroundColor Cyan
Write-Host "==================================`n" -ForegroundColor Cyan

# 1. Check network
Write-Host "1. Checking your IP address..." -ForegroundColor Yellow
$clientIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | Select-Object -First 1).IPAddress
Write-Host "   Your IP: $clientIP" -ForegroundColor Gray

if ($clientIP -match "^192\.168\.11\.") {
    Write-Host "   Same network as server (GOOD)" -ForegroundColor Green
} else {
    Write-Host "   Different network than server (BAD)" -ForegroundColor Red
    Write-Host "   Server is on 192.168.11.x network" -ForegroundColor Yellow
    Write-Host "   You need to connect to the same router/network" -ForegroundColor Yellow
}

# 2. Ping test
Write-Host "`n2. Testing connection to server..." -ForegroundColor Yellow
$ping = Test-Connection -ComputerName $serverIP -Count 2 -Quiet
if ($ping) {
    Write-Host "   Can reach server (GOOD)" -ForegroundColor Green
} else {
    Write-Host "   Cannot reach server (BAD)" -ForegroundColor Red
    Write-Host "   Check if you're on same network" -ForegroundColor Yellow
}

# 3. Port test
Write-Host "`n3. Testing port 80..." -ForegroundColor Yellow
try {
    $portTest = Test-NetConnection -ComputerName $serverIP -Port 80 -WarningAction SilentlyContinue
    if ($portTest.TcpTestSucceeded) {
        Write-Host "   Port 80 is open (GOOD)" -ForegroundColor Green
    } else {
        Write-Host "   Port 80 is closed (BAD)" -ForegroundColor Red
        Write-Host "   Server firewall may be blocking" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   Could not test port" -ForegroundColor Yellow
}

# 4. HTTP test
Write-Host "`n4. Testing HTTP access..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://$serverIP/exam-frontend" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "   Can access exam system (GOOD)" -ForegroundColor Green
    Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
} catch {
    Write-Host "   Cannot access exam system (BAD)" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
}

# Summary
Write-Host "`n===================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

Write-Host "`nServer IP: $serverIP" -ForegroundColor White
Write-Host "Your IP: $clientIP" -ForegroundColor White
Write-Host "`nAccess URL:" -ForegroundColor Yellow
Write-Host "http://$serverIP/exam-frontend" -ForegroundColor Green

Write-Host "`nIf tests failed:" -ForegroundColor Yellow
Write-Host "1. Make sure you're on the same network" -ForegroundColor White
Write-Host "2. Ask server admin to check firewall" -ForegroundColor White
Write-Host "3. Try accessing URL in browser" -ForegroundColor White

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
