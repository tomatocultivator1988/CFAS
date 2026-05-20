# LAN Access Diagnostic Script
# Run as Administrator

Write-Host "🔍 CFAS Exam System - LAN Diagnostic Tool" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

# Check admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠️  Running without admin rights (some checks may fail)" -ForegroundColor Yellow
}

# 1. Get IP Address
Write-Host "1️⃣  Checking IP Address..." -ForegroundColor Yellow
$ips = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.InterfaceAlias -notlike "*Loopback*"
}

if ($ips) {
    foreach ($ip in $ips) {
        Write-Host "   ✅ $($ip.IPAddress) - $($ip.InterfaceAlias)" -ForegroundColor Green
    }
    $serverIP = $ips[0].IPAddress
} else {
    Write-Host "   ❌ No network IP found!" -ForegroundColor Red
    $serverIP = "NOT_FOUND"
}

# 2. Check if Apache is running
Write-Host "`n2️⃣  Checking Apache Status..." -ForegroundColor Yellow
$apacheProcess = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
if ($apacheProcess) {
    Write-Host "   ✅ Apache is running (PID: $($apacheProcess[0].Id))" -ForegroundColor Green
} else {
    Write-Host "   ❌ Apache is NOT running!" -ForegroundColor Red
    Write-Host "   → Start Apache in XAMPP Control Panel" -ForegroundColor Yellow
}

# 3. Check if port 80 is listening
Write-Host "`n3️⃣  Checking Port 80..." -ForegroundColor Yellow
$port80 = netstat -an | Select-String ":80 " | Select-String "LISTENING"
if ($port80) {
    $listening = $port80 -match "0\.0\.0\.0:80"
    if ($listening) {
        Write-Host "   ✅ Port 80 is listening on all interfaces (0.0.0.0:80)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Port 80 is listening but may be restricted:" -ForegroundColor Yellow
        Write-Host "   $port80" -ForegroundColor Gray
        Write-Host "   → Should show '0.0.0.0:80' not '127.0.0.1:80'" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ❌ Port 80 is NOT listening!" -ForegroundColor Red
}

# 4. Check Firewall Rules
Write-Host "`n4️⃣  Checking Firewall Rules..." -ForegroundColor Yellow
$firewallRules = netsh advfirewall firewall show rule name="Apache HTTP" 2>$null
if ($firewallRules -match "Apache HTTP") {
    Write-Host "   ✅ Firewall rule 'Apache HTTP' exists" -ForegroundColor Green
} else {
    Write-Host "   ❌ Firewall rule 'Apache HTTP' NOT found!" -ForegroundColor Red
    Write-Host "   → Run: netsh advfirewall firewall add rule name=`"Apache HTTP`" dir=in action=allow protocol=TCP localport=80" -ForegroundColor Yellow
}

# 5. Check XAMPP Apache Config
Write-Host "`n5️⃣  Checking Apache Configuration..." -ForegroundColor Yellow
$httpdConf = "C:\xampp\apache\conf\httpd.conf"
if (Test-Path $httpdConf) {
    $content = Get-Content $httpdConf -Raw
    
    # Check Listen directive
    if ($content -match "Listen 127\.0\.0\.1:80") {
        Write-Host "   ❌ Apache is listening on localhost only!" -ForegroundColor Red
        Write-Host "   → Change 'Listen 127.0.0.1:80' to 'Listen 80' in httpd.conf" -ForegroundColor Yellow
    } elseif ($content -match "Listen 80") {
        Write-Host "   ✅ Apache Listen directive is correct" -ForegroundColor Green
    }
    
    # Check Require directive
    if ($content -match "Require local") {
        Write-Host "   ⚠️  Found 'Require local' - may block external access" -ForegroundColor Yellow
        Write-Host "   → Change 'Require local' to 'Require all granted' in httpd.conf" -ForegroundColor Yellow
    } elseif ($content -match "Require all granted") {
        Write-Host "   ✅ Apache access control is correct" -ForegroundColor Green
    }
} else {
    Write-Host "   ⚠️  httpd.conf not found at default location" -ForegroundColor Yellow
}

# 6. Check Backend .env
Write-Host "`n6️⃣  Checking Backend Configuration..." -ForegroundColor Yellow
$backendEnv = "Exam-Main/backend/.env"
if (Test-Path $backendEnv) {
    $envContent = Get-Content $backendEnv
    $appUrl = $envContent | Select-String "^APP_URL="
    if ($appUrl) {
        Write-Host "   Current APP_URL: $appUrl" -ForegroundColor Gray
        if ($appUrl -match "localhost") {
            Write-Host "   ⚠️  Using localhost - change to server IP" -ForegroundColor Yellow
        } else {
            Write-Host "   ✅ APP_URL configured with IP" -ForegroundColor Green
        }
    }
} else {
    Write-Host "   ❌ Backend .env not found!" -ForegroundColor Red
}

# 7. Check Frontend API config
Write-Host "`n7️⃣  Checking Frontend Configuration..." -ForegroundColor Yellow
$apiJs = "Exam-Main/frontend/src/services/api.js"
if (Test-Path $apiJs) {
    $apiContent = Get-Content $apiJs -Raw
    if ($apiContent -match 'API_BASE_URL\s*=\s*[''"]([^''"]+)[''"]') {
        $apiUrl = $matches[1]
        Write-Host "   Current API_BASE_URL: $apiUrl" -ForegroundColor Gray
        if ($apiUrl -match "localhost") {
            Write-Host "   ⚠️  Using localhost - change to server IP" -ForegroundColor Yellow
        } else {
            Write-Host "   ✅ API_BASE_URL configured with IP" -ForegroundColor Green
        }
    }
} else {
    Write-Host "   ❌ Frontend api.js not found!" -ForegroundColor Red
}

# 8. Test local access
Write-Host "`n8️⃣  Testing Local Access..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/exam-frontend" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "   ✅ Local access works (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Cannot access http://localhost/exam-frontend" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
}

# Summary
Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "📊 DIAGNOSTIC SUMMARY" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host "`n🔧 Common Issues & Solutions:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Issue 1: Apache listening on 127.0.0.1 only" -ForegroundColor White
Write-Host "  Fix: Edit C:\xampp\apache\conf\httpd.conf" -ForegroundColor Gray
Write-Host "       Change 'Listen 127.0.0.1:80' to 'Listen 80'" -ForegroundColor Gray
Write-Host ""
Write-Host "Issue 2: Firewall blocking connections" -ForegroundColor White
Write-Host "  Fix: Run as admin:" -ForegroundColor Gray
Write-Host "       netsh advfirewall firewall add rule name=Apache HTTP dir=in action=allow protocol=TCP localport=80" -ForegroundColor Gray
Write-Host ""
Write-Host "Issue 3: Require local in httpd.conf" -ForegroundColor White
Write-Host "  Fix: Edit C:\xampp\apache\conf\httpd.conf" -ForegroundColor Gray
Write-Host "       Find Directory sections and change Require local to Require all granted" -ForegroundColor Gray
Write-Host ""
Write-Host "Issue 4: Frontend/Backend using localhost" -ForegroundColor White
Write-Host "  Fix: Update configurations to use: $serverIP" -ForegroundColor Gray
Write-Host ""

Write-Host "📱 After fixing, access from other PCs:" -ForegroundColor Yellow
Write-Host "   http://$serverIP/exam-frontend" -ForegroundColor Green -BackgroundColor Black
Write-Host ""

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
