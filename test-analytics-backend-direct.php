<?php
/**
 * Direct test of analytics backend endpoints
 * This script tests the analytics API endpoints directly
 */

echo "=== Analytics Backend Direct Test ===\n\n";

// Test URLs
$baseUrl = 'http://192.168.11.40/exam-backend/public/api';
$endpoints = [
    'health' => '/health',
    'analytics_overview' => '/analytics/overview?timeFilter=all',
    'analytics_exams' => '/analytics/exams?timeFilter=all',
    'analytics_students' => '/analytics/students?timeFilter=all',
    'analytics_trends' => '/analytics/trends?timeFilter=all'
];

echo "Testing backend at: $baseUrl\n\n";

foreach ($endpoints as $name => $endpoint) {
    $url = $baseUrl . $endpoint;
    echo "Testing $name:\n";
    echo "URL: $url\n";
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Accept: application/json',
        'Content-Type: application/json'
    ]);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);
    
    if ($error) {
        echo "❌ CURL Error: $error\n";
    } else {
        echo "📊 HTTP Status: $httpCode\n";
        
        if ($httpCode == 200) {
            echo "✅ SUCCESS\n";
            $data = json_decode($response, true);
            if ($data) {
                echo "📋 Response: " . json_encode($data, JSON_PRETTY_PRINT) . "\n";
            } else {
                echo "📋 Response: $response\n";
            }
        } elseif ($httpCode == 401) {
            echo "🔐 AUTHENTICATION REQUIRED\n";
            echo "📋 Response: $response\n";
        } elseif ($httpCode == 404) {
            echo "❌ NOT FOUND - Endpoint may not exist or route not configured\n";
            echo "📋 Response: $response\n";
        } else {
            echo "⚠️ UNEXPECTED STATUS\n";
            echo "📋 Response: $response\n";
        }
    }
    
    echo "\n" . str_repeat("-", 50) . "\n\n";
}

echo "=== Summary ===\n";
echo "✅ If health endpoint works: Backend is running\n";
echo "🔐 If analytics endpoints return 401: Authentication required\n";
echo "❌ If analytics endpoints return 404: Routes not configured\n";
echo "⚠️ If analytics endpoints return 500: Server error\n\n";

echo "Next steps based on results:\n";
echo "- 401 errors: Need to add authentication token\n";
echo "- 404 errors: Check if analytics routes are properly deployed\n";
echo "- 500 errors: Check server logs for PHP errors\n";
?>