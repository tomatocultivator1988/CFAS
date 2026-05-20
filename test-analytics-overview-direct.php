<?php
/**
 * Test the analytics overview route directly
 */

echo "=== Analytics Overview Direct Test ===\n\n";

$baseUrl = 'http://192.168.11.40/exam-backend/public/api';

// Test the new test analytics overview route (no auth)
$testUrl = $baseUrl . '/test-analytics-overview?timeFilter=all';
echo "Testing analytics overview (no auth):\n";
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
        echo "✅ SUCCESS - Analytics overview working!\n";
        $data = json_decode($response, true);
        if ($data) {
            echo "📋 Response: " . json_encode($data, JSON_PRETTY_PRINT) . "\n";
        }
    } elseif ($httpCode == 500) {
        echo "⚠️ SERVER ERROR - Check for database or service issues\n";
        echo "📋 Response: $response\n";
    } else {
        echo "❌ FAILED\n";
        echo "📋 Response: $response\n";
    }
}

echo "\n=== Test Complete ===\n";
?>