<?php
// Direct test of category-exam-data endpoint
echo "Testing category-exam-data endpoint...\n\n";

// Test 1: Direct file access
echo "1. Testing direct backend access:\n";
$url1 = "http://192.168.11.40/exam-backend/public/index.php";
$ch1 = curl_init($url1);
curl_setopt($ch1, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch1, CURLOPT_HEADER, true);
$response1 = curl_exec($ch1);
$httpCode1 = curl_getinfo($ch1, CURLINFO_HTTP_CODE);
curl_close($ch1);
echo "   Status: $httpCode1\n";
echo "   Backend accessible: " . ($httpCode1 == 200 ? "YES" : "NO") . "\n\n";

// Test 2: API health check
echo "2. Testing API health:\n";
$url2 = "http://192.168.11.40/exam-backend/public/api/health";
$ch2 = curl_init($url2);
curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
$response2 = curl_exec($ch2);
$httpCode2 = curl_getinfo($ch2, CURLINFO_HTTP_CODE);
curl_close($ch2);
echo "   Status: $httpCode2\n";
echo "   Response: $response2\n\n";

// Test 3: Category endpoint without auth
echo "3. Testing category-exam-data (no auth):\n";
$url3 = "http://192.168.11.40/exam-backend/public/api/admin/export/category-exam-data";
$ch3 = curl_init($url3);
curl_setopt($ch3, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch3, CURLOPT_HTTPHEADER, ['Accept: application/json']);
$response3 = curl_exec($ch3);
$httpCode3 = curl_getinfo($ch3, CURLINFO_HTTP_CODE);
curl_close($ch3);
echo "   Status: $httpCode3\n";
echo "   Response: " . substr($response3, 0, 200) . "\n\n";

// Test 4: Check .htaccess
echo "4. Checking .htaccess:\n";
$htaccessPath = __DIR__ . '/backend/public/.htaccess';
if (file_exists($htaccessPath)) {
    echo "   .htaccess exists: YES\n";
    $content = file_get_contents($htaccessPath);
    echo "   RewriteEngine: " . (strpos($content, 'RewriteEngine On') !== false ? "ON" : "OFF") . "\n";
} else {
    echo "   .htaccess exists: NO\n";
}

echo "\n5. Checking Apache mod_rewrite:\n";
if (function_exists('apache_get_modules')) {
    $modules = apache_get_modules();
    echo "   mod_rewrite: " . (in_array('mod_rewrite', $modules) ? "ENABLED" : "DISABLED") . "\n";
} else {
    echo "   Cannot check (not running as Apache module)\n";
}

echo "\nDone!\n";
