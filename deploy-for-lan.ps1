# Complete LAN Deployment Script
# Run as Administrator

param(
    [string]$ServerIP = ""
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CFAS Exam System - LAN Deployment" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Get IP if not provided
if (-not $ServerIP) {
    $ServerIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
        $_.InterfaceAlias -notlike "*Loopback*" -and 
        $_.InterfaceAlias -notlike "*Bluetooth*"
    } | Select-Object -First 1).IPAddress
}

if (-not $ServerIP) {
    Write-Host "ERROR: Could not detect IP address!" -ForegroundColor Red
    exit 1
}

Write-Host "Server IP: $ServerIP`n" -ForegroundColor Green

# Step 1: Update Backend .env
Write-Host "1. Updating Backend Configuration..." -ForegroundColor Yellow
$backendEnv = "backend/.env"
if (Test-Path $backendEnv) {
    $content = Get-Content $backendEnv
    $newContent = @()
    
    foreach ($line in $content) {
        if ($line -match "^APP_URL=") {
            $newContent += "APP_URL=http://$ServerIP/exam-backend"
        }
        elseif ($line -match "^FRONTEND_URL=") {
            $newContent += "FRONTEND_URL=http://$ServerIP/exam-frontend"
        }
        else {
            $newContent += $line
        }
    }
    
    Set-Content $backendEnv -Value $newContent
    Write-Host "   Backend .env updated" -ForegroundColor Green
}

# Step 2: Update Frontend .env
Write-Host "`n2. Updating Frontend Configuration..." -ForegroundColor Yellow
$frontendEnv = "frontend/.env"
if (Test-Path $frontendEnv) {
    $content = Get-Content $frontendEnv
    $newContent = @()
    
    foreach ($line in $content) {
        if ($line -match "^VITE_API_URL=") {
            $newContent += "VITE_API_URL=http://$ServerIP/exam-backend/api"
        }
        else {
            $newContent += $line
        }
    }
    
    Set-Content $frontendEnv -Value $newContent
    Write-Host "   Frontend .env updated" -ForegroundColor Green
}

# Step 3: Update CORS
Write-Host "`n3. Updating CORS Configuration..." -ForegroundColor Yellow
$corsConfig = "backend/config/cors.php"
if (Test-Path $corsConfig) {
    $content = Get-Content $corsConfig -Raw
    
    if ($content -notmatch [regex]::Escape("http://$ServerIP")) {
        $pattern = "('allowed_origins'\s*=>\s*\[)"
        $replacement = "`$1`n        'http://$ServerIP',`n        'http://$ServerIP/exam-frontend',"
        $content = $content -replace $pattern, $replacement
        Set-Content $corsConfig -Value $content
        Write-Host "   CORS updated" -ForegroundColor Green
    } else {
        Write-Host "   CORS already configured" -ForegroundColor Green
    }
}

# Step 4: Build Frontend
Write-Host "`n4. Building Frontend..." -ForegroundColor Yellow
Push-Location frontend
try {
    $buildOutput = npm run build 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   Frontend built successfully" -ForegroundColor Green
    } else {
        Write-Host "   Build failed!" -ForegroundColor Red
        Write-Host $buildOutput
        Pop-Location
        exit 1
    }
} finally {
    Pop-Location
}

# Step 5: Deploy to XAMPP
Write-Host "`n5. Deploying to XAMPP..." -ForegroundColor Yellow
$source = "frontend/dist/*"
$destination = "C:\xampp\htdocs\exam-frontend\"

if (Test-Path $destination) {
    Copy-Item -Path $source -Destination $destination -Recurse -Force
    Write-Host "   Deployed to XAMPP" -ForegroundColor Green
} else {
    Write-Host "   Creating directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Copy-Item -Path $source -Destination $destination -Recurse -Force
    Write-Host "   Deployed to XAMPP" -ForegroundColor Green
}

# Step 6: Add Firewall Rule
Write-Host "`n6. Configuring Firewall..." -ForegroundColor Yellow
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    netsh advfirewall firewall delete rule name="Apache HTTP" 2>$null | Out-Null
    netsh advfirewall firewall add rule name="Apache HTTP" dir=in action=allow protocol=TCP localport=80 | Out-Null
    Write-Host "   Firewall configured" -ForegroundColor Green
} else {
    Write-Host "   Skipped (not admin)" -ForegroundColor Yellow
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nAccess URLs:" -ForegroundColor Yellow
Write-Host "  Frontend: http://$ServerIP/exam-frontend" -ForegroundColor Cyan
Write-Host "  Backend:  http://$ServerIP/exam-backend" -ForegroundColor Cyan

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Restart Apache in XAMPP Control Panel" -ForegroundColor White
Write-Host "2. Test from this PC: http://$ServerIP/exam-frontend" -ForegroundColor White
Write-Host "3. Test from client PC on same network" -ForegroundColor White

Write-Host "`nShare with students:" -ForegroundColor Yellow
Write-Host "  http://$ServerIP/exam-frontend" -ForegroundColor Green -BackgroundColor Black

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
