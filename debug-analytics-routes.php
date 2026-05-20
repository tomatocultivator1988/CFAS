<?php
/**
 * Debug script to check if analytics routes are being registered
 */

// Test if we can access the deployed backend directly
echo "=== Analytics Routes Debug ===\n\n";

// First, let's check if the AnalyticsController exists in the deployed backend
$controllerPath = 'C:\xampp\htdocs\exam-backend\app\Http\Controllers\AnalyticsController.php';
echo "1. Checking AnalyticsController deployment:\n";
if (file_exists($controllerPath)) {
    echo "✅ AnalyticsController.php exists at: $controllerPath\n";
    $controllerContent = file_get_contents($controllerPath);
    if (strpos($controllerContent, 'getOverviewMetrics') !== false) {
        echo "✅ getOverviewMetrics method found in controller\n";
    } else {
        echo "❌ getOverviewMetrics method NOT found in controller\n";
    }
} else {
    echo "❌ AnalyticsController.php NOT found at: $controllerPath\n";
}

// Check if routes file has analytics routes
$routesPath = 'C:\xampp\htdocs\exam-backend\routes\api.php';
echo "\n2. Checking API routes deployment:\n";
if (file_exists($routesPath)) {
    echo "✅ api.php exists at: $routesPath\n";
    $routesContent = file_get_contents($routesPath);
    if (strpos($routesContent, 'analytics/overview') !== false) {
        echo "✅ Analytics routes found in api.php\n";
    } else {
        echo "❌ Analytics routes NOT found in api.php\n";
    }
    if (strpos($routesContent, 'AnalyticsController') !== false) {
        echo "✅ AnalyticsController reference found in api.php\n";
    } else {
        echo "❌ AnalyticsController reference NOT found in api.php\n";
    }
} else {
    echo "❌ api.php NOT found at: $routesPath\n";
}

// Check if services exist
$analyticsServicePath = 'C:\xampp\htdocs\exam-backend\app\Services\AnalyticsService.php';
echo "\n3. Checking AnalyticsService deployment:\n";
if (file_exists($analyticsServicePath)) {
    echo "✅ AnalyticsService.php exists\n";
} else {
    echo "❌ AnalyticsService.php NOT found\n";
}

$cacheServicePath = 'C:\xampp\htdocs\exam-backend\app\Services\CacheService.php';
if (file_exists($cacheServicePath)) {
    echo "✅ CacheService.php exists\n";
} else {
    echo "❌ CacheService.php NOT found\n";
}

// Check if service provider exists
$serviceProviderPath = 'C:\xampp\htdocs\exam-backend\app\Providers\AnalyticsServiceProvider.php';
echo "\n4. Checking AnalyticsServiceProvider deployment:\n";
if (file_exists($serviceProviderPath)) {
    echo "✅ AnalyticsServiceProvider.php exists\n";
} else {
    echo "❌ AnalyticsServiceProvider.php NOT found\n";
}

// Check if config has the service provider registered
$configPath = 'C:\xampp\htdocs\exam-backend\config\app.php';
echo "\n5. Checking config/app.php:\n";
if (file_exists($configPath)) {
    echo "✅ config/app.php exists\n";
    $configContent = file_get_contents($configPath);
    if (strpos($configContent, 'AnalyticsServiceProvider') !== false) {
        echo "✅ AnalyticsServiceProvider registered in config\n";
    } else {
        echo "❌ AnalyticsServiceProvider NOT registered in config\n";
    }
} else {
    echo "❌ config/app.php NOT found\n";
}

// Test a simple route that should work
echo "\n6. Testing known working route:\n";
$testUrl = 'http://192.168.11.40/exam-backend/public/api/health';
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $testUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 5);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Health endpoint status: $httpCode\n";
if ($httpCode == 200) {
    echo "✅ Backend is responding correctly\n";
} else {
    echo "❌ Backend not responding correctly\n";
}

echo "\n=== Debug Complete ===\n";