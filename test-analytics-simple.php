<?php
/**
 * Simple test to check if AnalyticsController can be instantiated
 */

// Test if we can access the deployed backend directly
$testUrl = 'http://192.168.11.40/exam-backend/public/api/analytics/overview?timeFilter=all';

echo "Testing analytics endpoint with proper headers...\n";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $testUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Content-Type: application/json',
    'User-Agent: Analytics-Test/1.0'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
if ($error) {
    echo "CURL Error: $error\n";
} else {
    echo "Response: $response\n";
}

// Also test a known working admin endpoint for comparison
echo "\n" . str_repeat("-", 50) . "\n";
echo "Testing known admin endpoint for comparison...\n";

$adminUrl = 'http://192.168.11.40/exam-backend/public/api/admin/exams';

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $adminUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Content-Type: application/json',
    'User-Agent: Analytics-Test/1.0'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
if ($error) {
    echo "CURL Error: $error\n";
} else {
    echo "Response: $response\n";
}