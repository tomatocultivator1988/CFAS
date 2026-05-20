# ============================================================================
# DIAGNOSE XAMPP vs APACHE CONFLICT - DEEP ANALYSIS
# ============================================================================
# This script identifies which web server is actually serving your LAN site
# ============================================================================

Write-Host "========================================" -ForegroundColor Red
Write-Host "DEEP ANALYSIS: XAMPP vs APACHE CONFLICT" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

Write-Host "PROBLEM ANALYSIS:" -ForegroundColor Yellow
Write-Host "You're still getting old files, which means we deployed to the WRONG server!" -ForegroundColor Red
Write-Host "URL: http://192.168.11.40/exam-frontend/admin/analytics" -ForegroundColor Gray
Write-Host "Still loading: AnalyticsDashboard-B6x0QrGh.js (OLD)" -ForegroundColor Red
Write-Host ""

Write-Host "[1/6] Checking running web servers..." -ForegroundColor Yellow

# Check Apache services
Write-Host ""
Write-Host "APACHE SERVICES:" -ForegroundColor Cyan
$apacheServices = Get-Service -Name "*Apache*" -ErrorAction SilentlyContinue
if ($apacheServices) {
    foreach ($service in $apacheServices) {
        $status = if ($service.Status -eq 'Running') { "RUNNING" } else { "STOPPED" }
        $color = if ($service.Status -eq 'Running') { "Green" } else { "Red" }
        Write-Host "   $($service.Name): $status" -ForegroundColor $color
    }
} else {
    Write-Host "   No Apache services found" -ForegroundColor Gray
}

# Check XAMPP processes
Write-Host ""
Write-Host "XAMPP PROCESSES:" -ForegroundColor Cyan
$xamppProcesses = Get-Process -Name "*apache*", "*httpd*" -ErrorAction SilentlyContinue
if ($xamppProcesses) {
    foreach ($proc in $xamppProcesses) {
        Write-Host "   $($proc.ProcessName) (PID: $($proc.Id))" -ForegroundColor Green
        
        # Try to get the executable path
        try {
            $path = $proc.Path
            if ($path -like "*xampp*") {
                Write-Host "     -> XAMPP Apache: $path" -ForegroundColor Yellow
            } elseif ($path -like "*Apache24*") {
                Write-Host "     -> Standalone Apache: $path" -ForegroundColor Yellow
            } else {
                Write-Host "     -> Path: $path" -ForegroundColor Gray
            }
        } catch {
            Write-Host "     -> Cannot determine path" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "   No Apache/httpd processes running" -ForegroundColor Red
}

Write-Host ""
Write-Host "[2/6] Checking listening ports..." -ForegroundColor Yellow
try {
    $ports = netstat -an | findstr ":80 "
    if ($ports) {
        Write-Host "PORTS LISTENING ON 80:" -ForegroundColor Cyan
        Write-Host $ports -ForegroundColor Gray
    } else {
        Write-Host "No processes listening on port 80" -ForegroundColor Red
    }
} catch {
    Write-Host "Could not check ports" -ForegroundColor Red
}

Write-Host ""
Write-Host "[3/6] Checking possible document roots..." -ForegroundColor Yellow

$possiblePaths = @(
    "C:\Apache24\htdocs\exam-frontend",
    "C:\xampp\htdocs\exam-frontend", 
    "C:\xampp\htdocs\exam-system",
    "C:\Apache24\htdocs\exam-system",
    "C:\inetpub\wwwroot\exam-frontend",
    "C:\wamp\www\exam-frontend",
    "C:\wamp64\www\exam-frontend"
)

Write-Host ""
Write-Host "DOCUMENT ROOT ANALYSIS:" -ForegroundColor Cyan
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        Write-Host "   FOUND: $path" -ForegroundColor Green
        
        # Check for Analytics Dashboard files
        $analyticsFile = Get-ChildItem "$path\assets" -Filter "AnalyticsDashboard-*.js" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($analyticsFile) {
            $hash = $analyticsFile.Name
            if ($hash -like "*B8gPwN8Z*") {
                Write-Host "     -> HAS NEW BUILD: $hash" -ForegroundColor Green
            } elseif ($hash -like "*B6x0QrGh*") {
                Write-Host "     -> HAS OLD BUILD: $hash" -ForegroundColor Red
            } else {
                Write-Host "     -> HAS UNKNOWN BUILD: $hash" -ForegroundColor Yellow
            }
        } else {
            Write-Host "     -> NO Analytics Dashboard found" -ForegroundColor Gray
        }
        
        # Check last modified time
        try {
            $lastModified = (Get-ChildItem "$path\index.html" -ErrorAction SilentlyContinue).LastWriteTime
            if ($lastModified) {
                Write-Host "     -> Last modified: $lastModified" -ForegroundColor Gray
            }
        } catch {}
        
    } else {
        Write-Host "   NOT FOUND: $path" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "[4/6] Checking XAMPP configuration..." -ForegroundColor Yellow
$xamppConfig = "C:\xampp\apache\conf\httpd.conf"
if (Test-Path $xamppConfig) {
    Write-Host "XAMPP CONFIG FOUND: $xamppConfig" -ForegroundColor Green
    try {
        $docRoot = Select-String -Path $xamppConfig -Pattern "DocumentRoot" | Select-Object -First 1
        if ($docRoot) {
            Write-Host "   DocumentRoot: $($docRoot.Line.Trim())" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   Could not read DocumentRoot" -ForegroundColor Red
    }
} else {
    Write-Host "XAMPP config not found" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[5/6] Checking Apache24 configuration..." -ForegroundColor Yellow
$apacheConfig = "C:\Apache24\conf\httpd.conf"
if (Test-Path $apacheConfig) {
    Write-Host "APACHE24 CONFIG FOUND: $apacheConfig" -ForegroundColor Green
    try {
        $docRoot = Select-String -Path $apacheConfig -Pattern "DocumentRoot" | Select-Object -First 1
        if ($docRoot) {
            Write-Host "   DocumentRoot: $($docRoot.Line.Trim())" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   Could not read DocumentRoot" -ForegroundColor Red
    }
} else {
    Write-Host "Apache24 config not found" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[6/6] Testing actual web server response..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://192.168.11.40/" -TimeoutSec 5 -ErrorAction SilentlyContinue
    if ($response) {
        Write-Host "WEB SERVER RESPONDS:" -ForegroundColor Green
        $server = $response.Headers.Server
        if ($server) {
            Write-Host "   Server header: $server" -ForegroundColor Yellow
        }
        
        # Check if it's XAMPP default page
        if ($response.Content -like "*XAMPP*") {
            Write-Host "   -> XAMPP is serving the site!" -ForegroundColor Red
        } elseif ($response.Content -like "*Apache*") {
            Write-Host "   -> Apache is serving the site" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "Could not connect to web server" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Red
Write-Host "DIAGNOSIS COMPLETE" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""
Write-Host "LIKELY PROBLEMS:" -ForegroundColor Yellow
Write-Host "1. XAMPP is running and serving from C:\xampp\htdocs\" -ForegroundColor White
Write-Host "2. We deployed to C:\Apache24\htdocs\ (wrong location)" -ForegroundColor White
Write-Host "3. Your LAN URL points to XAMPP, not Apache24" -ForegroundColor White
Write-Host ""
Write-Host "SOLUTION:" -ForegroundColor Green
Write-Host "Deploy to the CORRECT document root that's actually serving your site!" -ForegroundColor White
Write-Host ""