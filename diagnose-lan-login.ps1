# LAN Login Diagnostic Script
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LAN LOGIN DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check if frontend is deployed
Write-Host "[1/6] Checking frontend deployment..." -ForegroundColor Yellow
if (Test-Path "C:\xampp\htdocs\exam-frontend\index.html") {
    Write-Host "  ✓ Frontend deployed" -ForegroundColor Green
} else {
    Write-Host "  ✗ Frontend NOT deployed!" -ForegroundColor Red
    Write-Host "  Run: xcopy Exam-Main\frontend\dist\* C:\xampp\htdocs\exam-frontend\ /E /I /Y" -ForegroundColor Yellow
}

# 2. Check if backend is deployed
Write-Host "[2/6] Checking backend deployment..." -ForegroundColor Yellow
if (Test-Path "C:\xampp\htdocs\exam-backend\public\index.php") {
    Write-Host "  ✓ Backend deployed" -ForegroundColor Green
} else {
    Write-Host "  ✗ Backend NOT deployed!" -ForegroundColor Red
}

# 3. Check Apache status
Write-Host "[3/6] Checking Apache status..." -ForegroundColor Yellow
$apache = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
if ($apache) {
    Write-Host "  ✓ Apache is running" -ForegroundColor Green
} else {
    Write-Host "  ✗ Apache is NOT running!" -ForegroundColor Red
    Write-Host "  Start XAMPP Control Panel and start Apache" -ForegroundColor Yellow
}

# 4. Check MySQL status
Write-Host "[4/6] Checking MySQL status..." -ForegroundColor Yellow
$mysql = Get-Process -Name "mysqld" -ErrorAction SilentlyContinue
if ($mysql) {
    Write-Host "  ✓ MySQL is running" -ForegroundColor Green
} else {
    Write-Host "  ✗ MySQL is NOT running!" -ForegroundColor Red
    Write-Host "  Start XAMPP Control Panel and start MySQL" -ForegroundColor Yellow
}

# 5. Check network connectivity
Write-Host "[5/6] Checking network connectivity..." -ForegroundColor Yellow
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "192.168.*"}).IPAddress
if ($ip) {
    Write-Host "  ✓ LAN IP: $ip" -ForegroundColor Green
} else {
    Write-Host "  ✗ No LAN IP found!" -ForegroundColor Red
}

# 6. Test localhost access
Write-Host "[6/6] Testing localhost access..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/exam-frontend/" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✓ Localhost access working" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✗ Localhost access failed!" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  COMMON ISSUES & SOLUTIONS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Issue 1: Cannot access from other devices" -ForegroundColor Yellow
Write-Host "  Solution: Check Windows Firewall" -ForegroundColor White
Write-Host "  Run: netsh advfirewall firewall add rule name='Apache' dir=in action=allow protocol=TCP localport=80" -ForegroundColor Gray
Write-Host ""
Write-Host "Issue 2: 404 Not Found" -ForegroundColor Yellow
Write-Host "  Solution: Check .htaccess and Apache config" -ForegroundColor White
Write-Host "  Ensure AllowOverride All in httpd.conf" -ForegroundColor Gray
Write-Host ""
Write-Host "Issue 3: API calls failing" -ForegroundColor Yellow
Write-Host "  Solution: Check frontend .env file" -ForegroundColor White
Write-Host "  Should be: VITE_API_URL=http://192.168.11.40/exam-backend/public/api" -ForegroundColor Gray
Write-Host ""
Write-Host "Issue 4: Login not working" -ForegroundColor Yellow
Write-Host "  Solution: Check backend .env database config" -ForegroundColor White
Write-Host "  Ensure DB_HOST=127.0.0.1 and credentials are correct" -ForegroundColor Gray
Write-Host ""

Write-Host "Test URLs:" -ForegroundColor Cyan
Write-Host "  Frontend: http://192.168.11.40/exam-frontend/" -ForegroundColor White
Write-Host "  Backend:  http://192.168.11.40/exam-backend/public/api/health" -ForegroundColor White
Write-Host ""

pause