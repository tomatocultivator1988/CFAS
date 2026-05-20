# CFAS Login Diagnostic and Fix Script
# This script diagnoses and fixes login issues after deployment

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CFAS LOGIN DIAGNOSTIC & FIX TOOL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$backendPath = "C:\xampp\htdocs\exam-backend"
$frontendPath = "C:\xampp\htdocs\exam-frontend"
$apiUrl = "http://192.168.11.40/exam-backend/public/api"
$frontendUrl = "http://192.168.11.40/exam-frontend"

# Test Results
$testResults = @()

function Test-Component {
    param(
        [string]$Name,
        [scriptblock]$Test
    )
    
    Write-Host "Testing: $Name..." -NoNewline
    try {
        $result = & $Test
        if ($result) {
            Write-Host " [OK]" -ForegroundColor Green
            $script:testResults += @{ Name = $Name; Status = "PASS"; Message = "" }
            return $true
        } else {
            Write-Host " [FAIL]" -ForegroundColor Red
            $script:testResults += @{ Name = $Name; Status = "FAIL"; Message = "Test returned false" }
            return $false
        }
    } catch {
        Write-Host " [ERROR]" -ForegroundColor Red
        $script:testResults += @{ Name = $Name; Status = "ERROR"; Message = $_.Exception.Message }
        return $false
    }
}

Write-Host "PHASE 1: ENVIRONMENT CHECKS" -ForegroundColor Yellow
Write-Host "----------------------------" -ForegroundColor Yellow

# 1. Check if XAMPP Apache is running
Test-Component "Apache Service" {
    $apache = Get-Process -Name "httpd" -ErrorAction SilentlyContinue
    return $null -ne $apache
}

# 2. Check if MySQL is running
Test-Component "MySQL Service" {
    $mysql = Get-Process -Name "mysqld" -ErrorAction SilentlyContinue
    return $null -ne $mysql
}

# 3. Check if backend files exist
Test-Component "Backend Files" {
    return Test-Path "$backendPath\public\index.php"
}

# 4. Check if frontend files exist
Test-Component "Frontend Files" {
    return Test-Path "$frontendPath\index.html"
}

Write-Host ""
Write-Host "PHASE 2: BACKEND API CHECKS" -ForegroundColor Yellow
Write-Host "----------------------------" -ForegroundColor Yellow

# 5. Test backend health endpoint
Test-Component "Backend Health API" {
    try {
        $response = Invoke-WebRequest -Uri "$apiUrl/health" -Method GET -UseBasicParsing -TimeoutSec 5
        $json = $response.Content | ConvertFrom-Json
        return $json.status -eq "ok"
    } catch {
        return $false
    }
}

# 6. Check .htaccess files
Test-Component "Backend .htaccess (root)" {
    return Test-Path "$backendPath\.htaccess"
}

Test-Component "Backend .htaccess (public)" {
    return Test-Path "$backendPath\public\.htaccess"
}

# 7. Check database connection
Test-Component "Database Connection" {
    try {
        $envContent = Get-Content "$backendPath\.env" -Raw
        if ($envContent -match "DB_DATABASE=(\w+)") {
            $dbName = $Matches[1]
            # Try to connect to MySQL
            $mysqlPath = "C:\xampp\mysql\bin\mysql.exe"
            if (Test-Path $mysqlPath) {
                $result = & $mysqlPath -u root -e "USE $dbName; SELECT 1;" 2>&1
                return $LASTEXITCODE -eq 0
            }
        }
        return $false
    } catch {
        return $false
    }
}

Write-Host ""
Write-Host "PHASE 3: FRONTEND CONFIGURATION" -ForegroundColor Yellow
Write-Host "--------------------------------" -ForegroundColor Yellow

# 8. Check frontend API configuration
Test-Component "Frontend API URL" {
    try {
        $indexHtml = Get-Content "$frontendPath\index.html" -Raw
        # Check if the built files contain the correct API URL
        $jsFiles = Get-ChildItem "$frontendPath\assets" -Filter "*.js" -ErrorAction SilentlyContinue
        if ($jsFiles) {
            $found = $false
            foreach ($file in $jsFiles) {
                $content = Get-Content $file.FullName -Raw
                if ($content -match "192\.168\.11\.40/exam-backend/public/api") {
                    $found = $true
                    break
                }
            }
            return $found
        }
        return $false
    } catch {
        return $false
    }
}

Write-Host ""
Write-Host "PHASE 4: AUTHENTICATION TEST" -ForegroundColor Yellow
Write-Host "-----------------------------" -ForegroundColor Yellow

# 9. Test login endpoint
Test-Component "Login Endpoint" {
    try {
        $body = @{
            username = "admin"
            password = "admin123"
        } | ConvertTo-Json
        
        $response = Invoke-WebRequest -Uri "$apiUrl/auth/login" `
            -Method POST `
            -Body $body `
            -ContentType "application/json" `
            -UseBasicParsing `
            -TimeoutSec 10
        
        $json = $response.Content | ConvertFrom-Json
        return $null -ne $json.data.token
    } catch {
        Write-Host ""
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "  Response: $responseBody" -ForegroundColor Red
        }
        return $false
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DIAGNOSTIC RESULTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$passCount = ($testResults | Where-Object { $_.Status -eq "PASS" }).Count
$failCount = ($testResults | Where-Object { $_.Status -ne "PASS" }).Count
$totalCount = $testResults.Count

Write-Host "Total Tests: $totalCount" -ForegroundColor White
Write-Host "Passed: $passCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor Red
Write-Host ""

if ($failCount -gt 0) {
    Write-Host "FAILED TESTS:" -ForegroundColor Red
    Write-Host "-------------" -ForegroundColor Red
    foreach ($result in $testResults | Where-Object { $_.Status -ne "PASS" }) {
        Write-Host "  - $($result.Name): $($result.Status)" -ForegroundColor Red
        if ($result.Message) {
            Write-Host "    $($result.Message)" -ForegroundColor Yellow
        }
    }
    Write-Host ""
    
    Write-Host "RECOMMENDED FIXES:" -ForegroundColor Yellow
    Write-Host "------------------" -ForegroundColor Yellow
    
    # Provide specific fixes based on failures
    foreach ($result in $testResults | Where-Object { $_.Status -ne "PASS" }) {
        switch ($result.Name) {
            "Apache Service" {
                Write-Host "  1. Open XAMPP Control Panel" -ForegroundColor White
                Write-Host "  2. Click 'Start' on Apache" -ForegroundColor White
                Write-Host "  3. Wait for it to turn green" -ForegroundColor White
            }
            "MySQL Service" {
                Write-Host "  1. Open XAMPP Control Panel" -ForegroundColor White
                Write-Host "  2. Click 'Start' on MySQL" -ForegroundColor White
                Write-Host "  3. Wait for it to turn green" -ForegroundColor White
            }
            "Backend Health API" {
                Write-Host "  1. Run: .\fix-apache-routing-simple.ps1" -ForegroundColor White
                Write-Host "  2. Restart Apache in XAMPP" -ForegroundColor White
            }
            "Backend .htaccess (root)" {
                Write-Host "  1. Run: .\fix-apache-routing-simple.ps1" -ForegroundColor White
            }
            "Backend .htaccess (public)" {
                Write-Host "  1. Run: .\fix-apache-routing-simple.ps1" -ForegroundColor White
            }
            "Frontend API URL" {
                Write-Host "  1. Run: .\rebuild-frontend-simple.ps1" -ForegroundColor White
                Write-Host "  2. Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
            }
            "Login Endpoint" {
                Write-Host "  1. Check if admin user exists in database" -ForegroundColor White
                Write-Host "  2. Run: php reset-admin-password.php" -ForegroundColor White
                Write-Host "  3. Clear browser cache and try again" -ForegroundColor White
            }
            "Database Connection" {
                Write-Host "  1. Check MySQL is running" -ForegroundColor White
                Write-Host "  2. Verify database 'review_center_exam' exists" -ForegroundColor White
                Write-Host "  3. Check .env file has correct DB credentials" -ForegroundColor White
            }
        }
        Write-Host ""
    }
    
    Write-Host "QUICK FIX COMMAND:" -ForegroundColor Cyan
    Write-Host "  .\FIX-LOGIN-COMPLETE.bat" -ForegroundColor White
    Write-Host ""
    
} else {
    Write-Host "ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your system is configured correctly." -ForegroundColor Green
    Write-Host "If you still can't login, try:" -ForegroundColor Yellow
    Write-Host "  1. Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
    Write-Host "  2. Close and reopen browser" -ForegroundColor White
    Write-Host "  3. Try: http://192.168.11.40/exam-frontend" -ForegroundColor White
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Ask if user wants to run auto-fix
if ($failCount -gt 0) {
    $response = Read-Host "Do you want to run automatic fixes? (Y/N)"
    if ($response -eq "Y" -or $response -eq "y") {
        Write-Host ""
        Write-Host "Running automatic fixes..." -ForegroundColor Cyan
        Write-Host ""
        
        # Fix .htaccess files
        if ((Test-Path ".\fix-apache-routing-simple.ps1")) {
            Write-Host "Fixing Apache routing..." -ForegroundColor Yellow
            & ".\fix-apache-routing-simple.ps1"
        }
        
        # Rebuild frontend if needed
        $frontendFailed = $testResults | Where-Object { $_.Name -eq "Frontend API URL" -and $_.Status -ne "PASS" }
        if ($frontendFailed -and (Test-Path ".\rebuild-frontend-simple.ps1")) {
            Write-Host "Rebuilding frontend..." -ForegroundColor Yellow
            & ".\rebuild-frontend-simple.ps1"
        }
        
        Write-Host ""
        Write-Host "Fixes applied! Please:" -ForegroundColor Green
        Write-Host "  1. Restart Apache in XAMPP" -ForegroundColor White
        Write-Host "  2. Clear browser cache" -ForegroundColor White
        Write-Host "  3. Try logging in again" -ForegroundColor White
        Write-Host ""
    }
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
