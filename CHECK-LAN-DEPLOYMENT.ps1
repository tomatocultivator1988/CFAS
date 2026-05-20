# CHECK LAN DEPLOYMENT STATUS
Write-Host "CHECKING LAN DEPLOYMENT STATUS..." -ForegroundColor Cyan

# Check if frontend is built
Write-Host "1. Checking frontend build..." -ForegroundColor Yellow
$distPath = "frontend\dist"
if (Test-Path $distPath) {
    $distFiles = Get-ChildItem $distPath -Recurse | Measure-Object
    Write-Host "Frontend dist folder exists with $($distFiles.Count) files" -ForegroundColor Green
    
    # Check for specific JS files
    $jsFiles = Get-ChildItem "$distPath\assets" -Filter "*.js" -ErrorAction SilentlyContinue
    if ($jsFiles) {
        Write-Host "JavaScript files found:" -ForegroundColor Green
        $jsFiles | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
    } else {
        Write-Host "NO JavaScript files found in dist/assets!" -ForegroundColor Red
    }
} else {
    Write-Host "Frontend dist folder NOT FOUND!" -ForegroundColor Red
    Write-Host "Need to rebuild frontend first" -ForegroundColor Yellow
}

# Check LAN deployment path
Write-Host ""
Write-Host "2. Checking LAN deployment..." -ForegroundColor Yellow
$lanPath = "C:\xampp\htdocs\exam-frontend"
if (Test-Path $lanPath) {
    $lanFiles = Get-ChildItem $lanPath -Recurse | Measure-Object
    Write-Host "LAN deployment exists with $($lanFiles.Count) files" -ForegroundColor Green
    
    # Check for .htaccess file
    if (Test-Path "$lanPath\.htaccess") {
        Write-Host ".htaccess file exists (cache busting enabled)" -ForegroundColor Green
    } else {
        Write-Host ".htaccess file MISSING (no cache busting)" -ForegroundColor Red
    }
    
    # Check for JS files in LAN
    $lanJsFiles = Get-ChildItem "$lanPath\assets" -Filter "*.js" -ErrorAction SilentlyContinue
    if ($lanJsFiles) {
        Write-Host "LAN JavaScript files:" -ForegroundColor Green
        $lanJsFiles | ForEach-Object { 
            $size = [math]::Round($_.Length / 1KB, 2)
            Write-Host "  - $($_.Name) ($size KB)" -ForegroundColor White 
        }
    } else {
        Write-Host "NO JavaScript files found in LAN deployment!" -ForegroundColor Red
    }
} else {
    Write-Host "LAN deployment path NOT FOUND!" -ForegroundColor Red
    Write-Host "Frontend not deployed to LAN" -ForegroundColor Yellow
}

# Check Apache status
Write-Host ""
Write-Host "3. Checking Apache status..." -ForegroundColor Yellow
try {
    $apacheProcess = Get-Process "httpd" -ErrorAction SilentlyContinue
    if ($apacheProcess) {
        Write-Host "Apache is running (PID: $($apacheProcess.Id))" -ForegroundColor Green
    } else {
        Write-Host "Apache is NOT running" -ForegroundColor Red
    }
} catch {
    Write-Host "Could not check Apache status" -ForegroundColor Yellow
}

# Test LAN connectivity
Write-Host ""
Write-Host "4. Testing LAN connectivity..." -ForegroundColor Yellow
try {
    $testConnection = Test-NetConnection -ComputerName "192.168.11.40" -Port 80 -WarningAction SilentlyContinue
    if ($testConnection.TcpTestSucceeded) {
        Write-Host "LAN server is reachable on port 80" -ForegroundColor Green
    } else {
        Write-Host "LAN server is NOT reachable on port 80" -ForegroundColor Red
    }
} catch {
    Write-Host "Could not test LAN connectivity" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "DEPLOYMENT CHECK COMPLETE!" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT ACTIONS:" -ForegroundColor Yellow
Write-Host "If files are missing or outdated:" -ForegroundColor White
Write-Host "1. Run: npm run build (in frontend folder)" -ForegroundColor White
Write-Host "2. Copy dist contents to C:\xampp\htdocs\exam-frontend" -ForegroundColor White
Write-Host "3. Add .htaccess file for cache busting" -ForegroundColor White
Write-Host "4. Restart Apache" -ForegroundColor White