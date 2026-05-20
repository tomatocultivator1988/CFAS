<?php
/**
 * Test if AnalyticsController class can be loaded
 */

echo "=== Analytics Class Loading Test ===\n\n";

// Test 1: Check if we can access the deployed backend directory
$backendPath = 'C:\xampp\htdocs\exam-backend';
echo "1. Backend path check:\n";
if (is_dir($backendPath)) {
    echo "✅ Backend directory exists: $backendPath\n";
} else {
    echo "❌ Backend directory NOT found: $backendPath\n";
    exit(1);
}

// Test 2: Check if we can include Laravel's autoloader
echo "\n2. Laravel autoloader test:\n";
$autoloadPath = $backendPath . '/vendor/autoload.php';
if (file_exists($autoloadPath)) {
    echo "✅ Autoloader exists: $autoloadPath\n";
    try {
        require_once $autoloadPath;
        echo "✅ Autoloader loaded successfully\n";
    } catch (Exception $e) {
        echo "❌ Error loading autoloader: " . $e->getMessage() . "\n";
        exit(1);
    }
} else {
    echo "❌ Autoloader NOT found: $autoloadPath\n";
    exit(1);
}

// Test 3: Check if AnalyticsController class exists
echo "\n3. AnalyticsController class test:\n";
try {
    if (class_exists('App\Http\Controllers\AnalyticsController')) {
        echo "✅ AnalyticsController class found\n";
        
        // Test if we can instantiate it
        $controller = new App\Http\Controllers\AnalyticsController();
        echo "✅ AnalyticsController instantiated successfully\n";
        
        // Test if methods exist
        $methods = ['getOverviewMetrics', 'getExamPerformance', 'getStudentPerformance'];
        foreach ($methods as $method) {
            if (method_exists($controller, $method)) {
                echo "✅ Method $method exists\n";
            } else {
                echo "❌ Method $method NOT found\n";
            }
        }
    } else {
        echo "❌ AnalyticsController class NOT found\n";
    }
} catch (Exception $e) {
    echo "❌ Error testing AnalyticsController: " . $e->getMessage() . "\n";
}

// Test 4: Check if AnalyticsService class exists
echo "\n4. AnalyticsService class test:\n";
try {
    if (class_exists('App\Services\AnalyticsService')) {
        echo "✅ AnalyticsService class found\n";
        
        $service = new App\Services\AnalyticsService();
        echo "✅ AnalyticsService instantiated successfully\n";
    } else {
        echo "❌ AnalyticsService class NOT found\n";
    }
} catch (Exception $e) {
    echo "❌ Error testing AnalyticsService: " . $e->getMessage() . "\n";
}

// Test 5: Check if CacheService class exists
echo "\n5. CacheService class test:\n";
try {
    if (class_exists('App\Services\CacheService')) {
        echo "✅ CacheService class found\n";
        
        $cache = new App\Services\CacheService();
        echo "✅ CacheService instantiated successfully\n";
    } else {
        echo "❌ CacheService class NOT found\n";
    }
} catch (Exception $e) {
    echo "❌ Error testing CacheService: " . $e->getMessage() . "\n";
}

echo "\n=== Test Complete ===\n";
echo "If all classes load successfully, the issue is likely:\n";
echo "1. Route middleware blocking access\n";
echo "2. Laravel route registration issue\n";
echo "3. Apache .htaccess rewrite rules\n";