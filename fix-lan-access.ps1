# Quick Fix for LAN Access Issues
# Run as Administrator

Write-Host "🔧 CFAS Exam System - LAN Access Quick Fix" -ForegroundColor Cyan
Write-Host "==========================================`n" -ForegroundColor Cyan

# Check admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ Must run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit
}

# Get IP
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.InterfaceAlias -notlike "*Loopback*" -and 
    $_.InterfaceAlias -notlike "*Bluetooth*"
} | Select-Object -First 1).IPAddress

if (-not $ip) {
    Write-Host "❌ Could not detect IP!" -ForegroundColor Red
    pause
    exit
}

Write-Host "✅ Server IP: $ip`n" -ForegroundColor Green

# Fix 1: Firewall
Write-Host "1️⃣  Adding Firewall Rules..." -ForegroundColor Yellow
netsh advfirewall firewall delete rule name="Apache HTTP" 2>$null | Out-Null
netsh advfirewall firewall delete rule name="Apache HTTPS" 2>$null | Out-Null
netsh advfirewall firewall add rule name="Apache HTTP" dir=in action=allow protocol=TCP localport=80 | Out-Null
netsh advfirewall firewall add rule name="Apache HTTPS" dir=in action=allow protocol=TCP localport=443 | Out-Null
Write-Host "   ✅ Firewall configured`n" -ForegroundColor Green

# Fix 2: Apache httpd.conf
Write-Host "2️⃣  Checking Apache Configuration..." -ForegroundColor Yellow
$httpdConf = "C:\xampp\apache\conf\httpd.conf"
if (Test-Path $httpdConf) {
    $content = Get-Content $httpdConf -Raw
    $modified = $false
    
    # Fix Listen directive
    if ($content -match "Listen 127\.0\.0\.1:80") {
        $content = $content -replace "Listen 127\.0\.0\.1:80", "Listen 80"
        $modified = $true
        Write-Host "   ✅ Fixed Listen directive" -ForegroundColor Green
    }
    
    # Fix Require local
    if ($content -match "Require local") {
        $content = $content -replace "Require local", "Require all granted"
        $modified = $true
        Write-Host "   ✅ Fixed access control" -ForegroundColor Green
    }
    
    if ($modified) {
        # Backup original
        Copy-Item $httpdConf "$httpdConf.backup" -Force
        Set-Content $httpdConf -Value $content
        Write-Host "   ✅ httpd.conf updated (backup created)" -ForegroundColor Green
    } else {
        Write-Host "   ✅ httpd.conf already correct" -ForegroundColor Green
    }
} else {
    Write-Host "   ⚠️  httpd.conf not found" -ForegroundColor Yellow
}
Write-Host ""

# Fix 3: Backend .env
Write-Host "3️⃣  Updating Backend Configuration..." -ForegroundColor Yellow
$backendEnv = "Exam-Main/backend/.env"
if (Test-Path $backendEnv) {
    $content = Get-Content $backendEnv
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
    
    Set-Content $backendEnv -Value $newContent
    Write-Host "   ✅ Backend .env updated`n" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Backend .env not found`n" -ForegroundColor Yellow
}

# Fix 4: Frontend API
Write-Host "4️⃣  Updating Frontend Configuration..." -ForegroundColor Yellow
$apiJs = "Exam-Main/frontend/src/services/api.js"
if (Test-Path $apiJs) {
    $content = Get-Content $apiJs -Raw
    $newUrl = "http://$ip/exam-backend/api"
    $content = $content -replace "const API_BASE_URL = ['\"]http://[^'\"]+['\"]", "const API_BASE_URL = '$newUrl'"
    Set-Content $apiJs -Value $content
    Write-Host "   ✅ Frontend API URL updated`n" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Frontend api.js not found`n" -ForegroundColor Yellow
}

# Fix 5: CORS
Write-Host "5️⃣  Updating CORS Configuration..." -ForegroundColor Yellow
$corsConfig = "Exam-Main/backend/config/cors.php"
if (Test-Path $corsConfig) {
    $content = Get-Content $corsConfig -Raw
    
    # Check if IP already in CORS
    if ($content -notmatch [regex]::Escape($ip)) {
        # Add IP to allowed_origins
        $pattern = "('allowed_origins'\s*=>\s*\[)"
        $replacement = "`$1`n        'http://$ip',"
        $content = $content -replace $pattern, $replacement
        Set-Content $corsConfig -Value $content
        Write-Host "   ✅ CORS updated with server IP`n" -ForegroundColor Green
    } else {
        Write-Host "   ✅ CORS already configured`n" -ForegroundColor Green
    }
} else {
    Write-Host "   ⚠️  CORS config not found`n" -ForegroundColor Yellow
}

# Summary
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "✅ FIXES APPLIED!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Restart Apache in XAMPP Control Panel" -ForegroundColor White
Write-Host "   (Stop, then Start)" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Rebuild Frontend:" -ForegroundColor White
Write-Host "   cd Exam-Main/frontend" -ForegroundColor Gray
Write-Host "   npm run build" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Copy dist to XAMPP:" -ForegroundColor White
Write-Host "   Copy contents of Exam-Main/frontend/dist" -ForegroundColor Gray
Write-Host "   To: C:\xampp\htdocs\exam-frontend" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Test from this PC:" -ForegroundColor White
Write-Host "   http://$ip/exam-frontend" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Test from another PC on same network:" -ForegroundColor White
Write-Host "   http://$ip/exam-frontend" -ForegroundColor Cyan
Write-Host ""

Write-Host "📱 Share with students:" -ForegroundColor Yellow
Write-Host "   http://$ip/exam-frontend" -ForegroundColor Green -BackgroundColor Black
Write-Host ""

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
