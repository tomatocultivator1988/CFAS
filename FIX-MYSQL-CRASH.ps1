# MySQL Crash Fix Script
Write-Host "FIXING MYSQL CRASH..." -ForegroundColor Red

# Step 1: Stop all MySQL processes
Write-Host "1. Stopping all MySQL processes..." -ForegroundColor Yellow
try {
    Get-Process "mysqld" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process "mysql" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "MySQL processes stopped" -ForegroundColor Green
} catch {
    Write-Host "No MySQL processes running" -ForegroundColor Gray
}

Start-Sleep -Seconds 3

# Step 2: Check for port conflicts
Write-Host "2. Checking port 3306..." -ForegroundColor Yellow
$portCheck = netstat -ano | findstr ":3306"
if ($portCheck) {
    Write-Host "Port 3306 is in use:" -ForegroundColor Yellow
    Write-Host $portCheck
    
    # Try to kill processes using port 3306
    $pids = ($portCheck | ForEach-Object { ($_ -split '\s+')[-1] }) | Sort-Object -Unique
    foreach ($pid in $pids) {
        if ($pid -and $pid -ne "0") {
            try {
                Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
                Write-Host "Killed process PID: $pid" -ForegroundColor Green
            } catch {
                Write-Host "Could not kill PID: $pid" -ForegroundColor Yellow
            }
        }
    }
} else {
    Write-Host "Port 3306 is free" -ForegroundColor Green
}

# Step 3: Remove MySQL lock files
Write-Host "3. Removing MySQL lock files..." -ForegroundColor Yellow
$mysqlDataDir = "C:\xampp\mysql\data"
$lockFiles = @(
    "$mysqlDataDir\mysql.pid",
    "$mysqlDataDir\mysqld.pid",
    "$mysqlDataDir\*.pid",
    "$mysqlDataDir\ibdata1.lck",
    "$mysqlDataDir\ib_logfile0.lck",
    "$mysqlDataDir\ib_logfile1.lck"
)

foreach ($lockFile in $lockFiles) {
    if (Test-Path $lockFile) {
        try {
            Remove-Item -Path $lockFile -Force -ErrorAction SilentlyContinue
            Write-Host "Removed: $lockFile" -ForegroundColor Green
        } catch {
            Write-Host "Could not remove: $lockFile" -ForegroundColor Yellow
        }
    }
}

# Step 4: Check MySQL data directory permissions
Write-Host "4. Checking MySQL data directory..." -ForegroundColor Yellow
if (Test-Path $mysqlDataDir) {
    Write-Host "MySQL data directory exists" -ForegroundColor Green
    
    # Check for corrupted files
    $corruptedFiles = @(
        "$mysqlDataDir\aria_log_control",
        "$mysqlDataDir\multi-master.info"
    )
    
    foreach ($file in $corruptedFiles) {
        if (Test-Path $file) {
            try {
                Remove-Item -Path $file -Force
                Write-Host "Removed potentially corrupted file: $file" -ForegroundColor Green
            } catch {
                Write-Host "Could not remove: $file" -ForegroundColor Yellow
            }
        }
    }
} else {
    Write-Host "MySQL data directory missing!" -ForegroundColor Red
}

# Step 5: Try to start MySQL service
Write-Host "5. Starting MySQL service..." -ForegroundColor Yellow
try {
    # Try Windows service first
    Start-Service "MySQL" -ErrorAction SilentlyContinue
    Write-Host "MySQL Windows service started" -ForegroundColor Green
} catch {
    Write-Host "MySQL Windows service not available, trying XAMPP..." -ForegroundColor Yellow
    
    # Try XAMPP MySQL
    $mysqldPath = "C:\xampp\mysql\bin\mysqld.exe"
    if (Test-Path $mysqldPath) {
        try {
            Start-Process -FilePath $mysqldPath -ArgumentList "--defaults-file=C:\xampp\mysql\bin\my.ini --standalone --console" -WindowStyle Hidden
            Start-Sleep -Seconds 5
            Write-Host "XAMPP MySQL started" -ForegroundColor Green
        } catch {
            Write-Host "Could not start XAMPP MySQL" -ForegroundColor Red
        }
    }
}

# Step 6: Test MySQL connection
Write-Host "6. Testing MySQL connection..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

try {
    $testConnection = Test-NetConnection -ComputerName "localhost" -Port 3306 -WarningAction SilentlyContinue
    if ($testConnection.TcpTestSucceeded) {
        Write-Host "MySQL is responding on port 3306" -ForegroundColor Green
    } else {
        Write-Host "MySQL is not responding on port 3306" -ForegroundColor Red
    }
} catch {
    Write-Host "Could not test MySQL connection" -ForegroundColor Yellow
}

# Step 7: Check MySQL process
$mysqlProcess = Get-Process "mysqld" -ErrorAction SilentlyContinue
if ($mysqlProcess) {
    Write-Host "MySQL process is running (PID: $($mysqlProcess.Id))" -ForegroundColor Green
} else {
    Write-Host "MySQL process is not running" -ForegroundColor Red
}

Write-Host ""
Write-Host "MYSQL FIX COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Open XAMPP Control Panel" -ForegroundColor White
Write-Host "2. Click START next to MySQL" -ForegroundColor White
Write-Host "3. If it still fails, click Config > my.ini and check settings" -ForegroundColor White
Write-Host "4. Try changing MySQL port from 3306 to 3307 if needed" -ForegroundColor White
Write-Host ""
Write-Host "COMMON SOLUTIONS:" -ForegroundColor Yellow
Write-Host "- Restart your computer if MySQL still won't start" -ForegroundColor White
Write-Host "- Check Windows Event Viewer for detailed error messages" -ForegroundColor White
Write-Host "- Disable antivirus temporarily to test" -ForegroundColor White
Write-Host "- Run XAMPP as Administrator" -ForegroundColor White