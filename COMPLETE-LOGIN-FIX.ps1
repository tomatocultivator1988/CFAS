#!/usr/bin/env pwsh

Write-Host "========================================" -ForegroundColor Green
Write-Host "COMPLETE LOGIN FIX" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$ServerIP = "192.168.11.40"

Write-Host ""
Write-Host "1. Checking database structure..." -ForegroundColor Yellow
$dbCheckScript = @"
<?php
try {
    `$pdo = new PDO('mysql:host=127.0.0.1;dbname=review_center_exam', 'root', '');
    
    // Check users table structure
    `$stmt = `$pdo->query("DESCRIBE users");
    echo "Users table columns:\n";
    while (`$row = `$stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "- " . `$row['Field'] . " (" . `$row['Type'] . ")\n";
    }
    
    // Check if admin user exists with username
    `$stmt = `$pdo->prepare("SELECT * FROM users WHERE username = 'admin' OR email = 'admin@example.com' LIMIT 1");
    `$stmt->execute();
    if (`$stmt->rowCount() > 0) {
        `$user = `$stmt->fetch(PDO::FETCH_ASSOC);
        echo "\nAdmin user found:\n";
        echo "ID: " . `$user['id'] . "\n";
        echo "Username: " . (`$user['username'] ?? 'N/A') . "\n";
        echo "Email: " . (`$user['email'] ?? 'N/A') . "\n";
        echo "Role: " . (`$user['role'] ?? 'N/A') . "\n";
    } else {
        echo "\nNo admin user found. Creating one...\n";
        
        // Create admin user
        `$hashedPassword = password_hash('password', PASSWORD_DEFAULT);
        `$stmt = `$pdo->prepare("INSERT INTO users (username, email, password, role, first_name, last_name, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)");
        `$result = `$stmt->execute(['admin', 'admin@example.com', `$hashedPassword, 'admin', 'Admin', 'User', 1]);
        
        if (`$result) {
            echo "✅ Admin user created successfully\n";
        } else {
            echo "❌ Failed to create admin user\n";
        }
    }
    
} catch (Exception `$e) {
    echo "❌ Database error: " . `$e->getMessage() . "\n";
}
?>
"@

Set-Content -Path "C:\xampp\htdocs\exam-backend\fix-database.php" -Value $dbCheckScript
$dbResult = php "C:\xampp\htdocs\exam-backend\fix-database.php"
Write-Host $dbResult -ForegroundColor White

Write-Host ""
Write-Host "2. Checking and fixing Laravel routes..." -ForegroundColor Yellow
try {
    # Check if API routes are properly registered
    $routeCheckScript = @"
<?php
require_once 'C:/xampp/htdocs/exam-backend/vendor/autoload.php';

try {
    `$app = require_once 'C:/xampp/htdocs/exam-backend/bootstrap/app.php';
    `$kernel = `$app->make(Illuminate\Contracts\Http\Kernel::class);
    `$kernel->bootstrap();
    
    // Get all routes
    `$router = `$app->make('router');
    `$routes = `$router->getRoutes();
    
    echo "Registered API routes:\n";
    foreach (`$routes as `$route) {
        `$uri = `$route->uri();
        if (strpos(`$uri, 'api/') === 0) {
            echo "- " . `$route->methods()[0] . " /" . `$uri . "\n";
        }
    }
    
} catch (Exception `$e) {
    echo "❌ Route check failed: " . `$e->getMessage() . "\n";
}
?>
"@
    
    Set-Content -Path "C:\xampp\htdocs\exam-backend\check-routes.php" -Value $routeCheckScript
    $routeResult = php "C:\xampp\htdocs\exam-backend\check-routes.php"
    Write-Host $routeResult -ForegroundColor White
} catch {
    Write-Host "   ❌ Route check failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Clearing Laravel caches..." -ForegroundColor Yellow
try {
    php "C:\xampp\htdocs\exam-backend\artisan" config:clear
    php "C:\xampp\htdocs\exam-backend\artisan" route:clear
    php "C:\xampp\htdocs\exam-backend\artisan" cache:clear
    php "C:\xampp\htdocs\exam-backend\artisan" config:cache
    php "C:\xampp\htdocs\exam-backend\artisan" route:cache
    Write-Host "   ✅ Laravel caches cleared and rebuilt" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Cache clear failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Fixing frontend API URL..." -ForegroundColor Yellow
try {
    # Update frontend .env
    $frontendEnvContent = @"
VITE_API_URL=http://$ServerIP/exam-backend/api
VITE_APP_NAME=Review Center Exam System
"@
    Set-Content -Path "frontend\.env" -Value $frontendEnvContent
    Write-Host "   ✅ Frontend .env updated" -ForegroundColor Green
    
    # Rebuild frontend
    Write-Host "   Building frontend with correct API URL..." -ForegroundColor Cyan
    Push-Location frontend
    $buildOutput = npm run build 2>&1
    Pop-Location
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Frontend built successfully" -ForegroundColor Green
        
        # Deploy frontend
        Copy-Item -Path "frontend\dist\*" -Destination "C:\xampp\htdocs\exam-frontend\" -Recurse -Force
        Write-Host "   ✅ Frontend deployed" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Frontend build failed" -ForegroundColor Red
        Write-Host $buildOutput -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Frontend fix failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Testing login with correct credentials..." -ForegroundColor Yellow
try {
    # Test with both username and email
    $testCredentials = @(
        @{ field = "username"; value = "admin" },
        @{ field = "email"; value = "admin@example.com" }
    )
    
    foreach ($cred in $testCredentials) {
        try {
            $body = @{
                $cred.field = $cred.value
                password = "password"
            } | ConvertTo-Json
            
            $headers = @{
                "Content-Type" = "application/json"
                "Accept" = "application/json"
            }
            
            Write-Host "   Testing login with $($cred.field): $($cred.value)" -ForegroundColor Cyan
            $response = Invoke-WebRequest -Uri "http://$ServerIP/exam-backend/api/login" -Method POST -Body $body -Headers $headers -TimeoutSec 10 -UseBasicParsing
            
            if ($response.StatusCode -eq 200) {
                Write-Host "   ✅ Login successful with $($cred.field)!" -ForegroundColor Green
                $responseData = $response.Content | ConvertFrom-Json
                if ($responseData.token) {
                    Write-Host "   ✅ Token received: $($responseData.token.Substring(0, 20))..." -ForegroundColor Green
                }
                break
            }
        } catch {
            Write-Host "   ❌ Login failed with $($cred.field): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "   ❌ Login test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "6. Final verification..." -ForegroundColor Yellow
try {
    # Test frontend access
    $frontendResponse = Invoke-WebRequest -Uri "http://$ServerIP/exam-frontend/" -TimeoutSec 5 -UseBasicParsing
    if ($frontendResponse.StatusCode -eq 200) {
        Write-Host "   ✅ Frontend accessible" -ForegroundColor Green
        
        # Check if frontend has correct API URL
        if ($frontendResponse.Content -match $ServerIP) {
            Write-Host "   ✅ Frontend has correct LAN IP" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Frontend still has localhost URLs" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "   ❌ Frontend verification failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "LOGIN FIX COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host ""
Write-Host "🎯 TESTING INSTRUCTIONS:" -ForegroundColor Cyan
Write-Host "1. Open browser and go to: http://$ServerIP/exam-frontend" -ForegroundColor White
Write-Host "2. Try logging in with:" -ForegroundColor White
Write-Host "   - Username: admin" -ForegroundColor Gray
Write-Host "   - Password: password" -ForegroundColor Gray
Write-Host "3. If that doesn't work, try:" -ForegroundColor White
Write-Host "   - Email: admin@example.com" -ForegroundColor Gray
Write-Host "   - Password: password" -ForegroundColor Gray
Write-Host "4. Clear browser cache (Ctrl+F5) if needed" -ForegroundColor White
Write-Host "5. Check User Management page for BLACK edit button" -ForegroundColor White
Write-Host ""
Write-Host "🎨 THEME: Classic iOS White & Black with Light Accents" -ForegroundColor Magenta
Write-Host ""