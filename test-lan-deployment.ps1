# CFAS Exam System - LAN Deployment Test
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CFAS Exam System - Deployment Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ip = "192.168.11.40"
$frontendUrl = "http://$ip/exam-frontend"
$backendUrl = "http://$ip/exam-backend/api"

# Test 1: Health Check
Write-Host "[1/5] Testing Backend Health..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$backendUrl/health" -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✅ Backend is running!" -ForegroundColor Green
        $health = $response.Content | ConvertFrom-Json
        Write-Host "  Status: $($health.status)" -ForegroundColor White
        Write-Host "  Message: $($health.message)" -ForegroundColor White
    }
} catch {
    Write-Host "  ❌ Backend health check failed!" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: Frontend Access
Write-Host "[2/5] Testing Frontend Access..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $frontendUrl -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✅ Frontend is accessible!" -ForegroundColor Green
    }
} catch {
    Write-Host "  ❌ Frontend access failed!" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Login API
Write-Host "[3/5] Testing Login API..." -ForegroundColor Yellow
try {
    $loginData = @{
        username = "reviewee"
        password = "password"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "$backendUrl/auth/login" -Method POST -Body $loginData -ContentType "application/json" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✅ Login API working!" -ForegroundColor Green
        $loginResult = $response.Content | ConvertFrom-Json
        Write-Host "  User: $($loginResult.user.username)" -ForegroundColor White
        Write-Host "  Role: $($loginResult.user.role)" -ForegroundColor White
    }
} catch {
    Write-Host "  ❌ Login API failed!" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Check Apache
Write-Host "[4/5] Checking Apache Status..." -ForegroundColor Yellow
$apacheProcess = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
if ($apacheProcess) {
    Write-Host "  ✅ Apache is running!" -ForegroundColor Green
    Write-Host "  Processes: $($apacheProcess.Count)" -ForegroundColor White
} else {
    Write-Host "  ❌ Apache is not running!" -ForegroundColor Red
    Write-Host "  Please start Apache in XAMPP Control Panel" -ForegroundColor Yellow
}

Write-Host ""

# Test 5: Check Firewall
Write-Host "[5/5] Checking Firewall Rules..." -ForegroundColor Yellow
$firewallRule = netsh advfirewall firewall show rule name="Apache HTTP" | Select-String "Enabled"
if ($firewallRule) {
    Write-Host "  ✅ Firewall rule exists!" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Firewall rule not found" -ForegroundColor Yellow
    Write-Host "  Run setup-lan.bat to add firewall rule" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Frontend URL: $frontendUrl" -ForegroundColor White
Write-Host "Backend API:  $backendUrl" -ForegroundColor White
Write-Host ""
Write-Host "Student Login:" -ForegroundColor Cyan
Write-Host "  Username: reviewee" -ForegroundColor White
Write-Host "  Password: password" -ForegroundColor White
Write-Host ""
Write-Host "Admin Login:" -ForegroundColor Cyan
Write-Host "  Username: admin" -ForegroundColor White
Write-Host "  Password: admin123" -ForegroundColor White
Write-Host ""
Write-Host "Share this URL with students:" -ForegroundColor Yellow
Write-Host "  $frontendUrl" -ForegroundColor Green
Write-Host ""
