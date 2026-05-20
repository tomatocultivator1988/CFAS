#!/usr/bin/env pwsh

Write-Host "========================================" -ForegroundColor Red
Write-Host "DEEP LOGIN DIAGNOSIS" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red

$ServerIP = "192.168.11.40"

Write-Host ""
Write-Host "1. Checking database connection..." -ForegroundColor Yellow
try {
    # Test database connection through PHP
    $dbTestScript = @"
<?php
try {
    `$pdo = new PDO('mysql:host=127.0.0.1;dbname=review_center_exam', 'root', '');
    echo "✅ Database connection successful\n";
    
    // Check if users table exists
    `$stmt = `$pdo->query("SHOW TABLES LIKE 'users'");
    if (`$stmt->rowCount() > 0) {
        echo "✅ Users table exists\n";
        
        // Check if admin user exists
        `$stmt = `$pdo->prepare("SELECT * FROM users WHERE email = 'admin@example.com'");
        `$stmt->execute();
        if (`$stmt->rowCount() > 0) {
            echo "✅ Admin user exists\n";
            `$user = `$stmt->fetch(PDO::FETCH_ASSOC);
            echo "   User ID: " . `$user['id'] . "\n";
            echo "   Email: " . `$user['email'] . "\n";
            echo "   Role: " . `$user['role'] . "\n";
        } else {
            echo "❌ Admin user not found\n";
        }
    } else {
        echo "❌ Users table not found\n";
    }
} catch (Exception `$e) {
    echo "❌ Database error: " . `$e->getMessage() . "\n";
}
?>
"@
    
    Set-Content -Path "C:\xampp\htdocs\exam-backend\test-db-connection.php" -Value $dbTestScript
    $dbResult = php "C:\xampp\htdocs\exam-backend\test-db-connection.php"
    Write-Host $dbResult -ForegroundColor White
} catch {
    Write-Host "   ❌ Database test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Testing Laravel environment..." -ForegroundColor Yellow
try {
    $laravelTestScript = @"
<?php
require_once 'C:/xampp/htdocs/exam-backend/vendor/autoload.php';

try {
    `$app = require_once 'C:/xampp/htdocs/exam-backend/bootstrap/app.php';
    echo "✅ Laravel app loaded\n";
    
    // Test database through Laravel
    `$kernel = `$app->make(Illuminate\Contracts\Console\Kernel::class);
    `$kernel->bootstrap();
    
    echo "✅ Laravel bootstrapped\n";
    
} catch (Exception `$e) {
    echo "❌ Laravel error: " . `$e->getMessage() . "\n";
}
?>
"@
    
    Set-Content -Path "C:\xampp\htdocs\exam-backend\test-laravel.php" -Value $laravelTestScript
    $laravelResult = php "C:\xampp\htdocs\exam-backend\test-laravel.php"
    Write-Host $laravelResult -ForegroundColor White
} catch {
    Write-Host "   ❌ Laravel test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Testing API endpoint directly..." -ForegroundColor Yellow
try {
    $apiTestScript = @"
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if (`$_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

echo json_encode([
    'status' => 'success',
    'message' => 'API endpoint is working',
    'timestamp' => date('Y-m-d H:i:s'),
    'server_ip' => `$_SERVER['SERVER_ADDR'] ?? 'unknown',
    'request_method' => `$_SERVER['REQUEST_METHOD'],
    'php_version' => phpversion()
]);
?>
"@
    
    Set-Content -Path "C:\xampp\htdocs\exam-backend\public\test-api-direct.php" -Value $apiTestScript
    
    $response = Invoke-WebRequest -Uri "http://$ServerIP/exam-backend/public/test-api-direct.php" -TimeoutSec 5 -UseBasicParsing
    Write-Host "   ✅ Direct API test successful" -ForegroundColor Green
    Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Direct API test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Checking frontend configuration..." -ForegroundColor Yellow
$frontendEnv = "frontend\.env"
if (Test-Path $frontendEnv) {
    Write-Host "   ✅ Frontend .env exists" -ForegroundColor Green
    $envContent = Get-Content $frontendEnv
    $apiUrl = $envContent | Where-Object { $_ -match "^VITE_API_URL=" }
    Write-Host "   Current API URL: $apiUrl" -ForegroundColor White
} else {
    Write-Host "   ❌ Frontend .env missing" -ForegroundColor Red
}

# Check built frontend files
$frontendIndex = "C:\xampp\htdocs\exam-frontend\index.html"
if (Test-Path $frontendIndex) {
    Write-Host "   ✅ Frontend deployed" -ForegroundColor Green
    $indexContent = Get-Content $frontendIndex -Raw
    if ($indexContent -match "192\.168\.11\.40") {
        Write-Host "   ✅ Frontend has LAN IP configured" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Frontend still has localhost URLs" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ Frontend not deployed" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Testing complete login flow..." -ForegroundColor Yellow
try {
    $loginTestScript = @"
<?php
require_once 'C:/xampp/htdocs/exam-backend/vendor/autoload.php';

// Simulate Laravel login
try {
    `$app = require_once 'C:/xampp/htdocs/exam-backend/bootstrap/app.php';
    `$kernel = `$app->make(Illuminate\Contracts\Http\Kernel::class);
    
    // Create a request
    `$request = Illuminate\Http\Request::create('/api/login', 'POST', [
        'email' => 'admin@example.com',
        'password' => 'password'
    ]);
    
    `$request->headers->set('Accept', 'application/json');
    `$request->headers->set('Content-Type', 'application/json');
    
    `$response = `$kernel->handle(`$request);
    
    echo "Status: " . `$response->getStatusCode() . "\n";
    echo "Content: " . `$response->getContent() . "\n";
    
} catch (Exception `$e) {
    echo "❌ Login simulation failed: " . `$e->getMessage() . "\n";
}
?>
"@
    
    Set-Content -Path "C:\xampp\htdocs\exam-backend\test-login-simulation.php" -Value $loginTestScript
    $loginResult = php "C:\xampp\htdocs\exam-backend\test-login-simulation.php"
    Write-Host $loginResult -ForegroundColor White
} catch {
    Write-Host "   ❌ Login simulation failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Red
Write-Host "DIAGNOSIS COMPLETE" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red

Write-Host ""
Write-Host "Next Steps Based on Results:" -ForegroundColor Yellow
Write-Host "1. If database connection failed - check MySQL service" -ForegroundColor White
Write-Host "2. If Laravel failed - check .env configuration" -ForegroundColor White
Write-Host "3. If API test failed - check Apache configuration" -ForegroundColor White
Write-Host "4. If frontend has localhost - rebuild with correct API URL" -ForegroundColor White
Write-Host "5. If login simulation failed - check user credentials in database" -ForegroundColor White
Write-Host ""