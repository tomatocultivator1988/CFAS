<?php
/**
 * Test the analytics route fix
 */

echo "=== Analytics Route Fix Test ===\n\n";

$baseUrl = 'http://192.168.11.40/exam-backend/public/api';

// Test the new test route
$testUrl = $baseUrl . '/test-analytics';
echo "Testing analytics controller access:\n";
echo "URL: $testUrl\n";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $testUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

if ($error) {
    echo "❌ CURL Error: $error\n";
} else {
    echo "📊 HTTP Status: $httpCode\n";
    
    if ($httpCode == 200) {
        echo "✅ SUCCESS - AnalyticsController is accessible\n";
        $data = json_decode($response, true);
        if ($data) {
            echo "📋 Response: " . json_encode($data, JSON_PRETTY_PRINT) . "\n";
        }
    } else {
        echo "❌ FAILED\n";
        echo "📋 Response: $response\n";
    }
}

echo "\n" . str_repeat("-", 50) . "\n\n";

// Now test the actual analytics overview route
$analyticsUrl = $baseUrl . '/analytics/overview?timeFilter=all';
echo "Testing analytics overview route:\n";
echo "URL: $analyticsUrl\n";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $analyticsUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "📊 HTTP Status: $httpCode\n";

if ($httpCode == 401) {
    echo "🔐 AUTHENTICATION REQUIRED - Route exists but needs auth token\n";
    echo "✅ This means the route is now working!\n";
} elseif ($httpCode == 404) {
    echo "❌ STILL NOT FOUND - Route registration issue persists\n";
} elseif ($httpCode == 200) {
    echo "✅ SUCCESS - Route working without auth (unexpected)\n";
} else {
    echo "⚠️ UNEXPECTED STATUS: $httpCode\n";
}

echo "📋 Response: $response\n";

echo "\n=== Test Complete ===\n";
?>