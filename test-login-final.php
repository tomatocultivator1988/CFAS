<?php
// Test login API endpoint
$serverIP = "192.168.11.40";
$apiUrl = "http://$serverIP/exam-backend/api/auth/login";

echo "Testing login API at: $apiUrl\n\n";

// Test credentials
$credentials = [
    ['username' => 'admin', 'password' => 'password'],
    ['email' => 'admin@example.com', 'password' => 'password']
];

foreach ($credentials as $index => $cred) {
    echo "Test " . ($index + 1) . ": ";
    $field = isset($cred['username']) ? 'username' : 'email';
    $value = $cred[$field];
    echo "Login with $field: $value\n";
    
    $postData = json_encode($cred);
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $apiUrl);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);
    
    if ($error) {
        echo "   ❌ CURL Error: $error\n";
    } else {
        echo "   HTTP Code: $httpCode\n";
        if ($httpCode == 200) {
            $data = json_decode($response, true);
            if ($data && isset($data['token'])) {
                echo "   ✅ Login successful! Token: " . substr($data['token'], 0, 20) . "...\n";
            } else {
                echo "   ❌ Login failed: " . $response . "\n";
            }
        } else {
            echo "   ❌ Login failed: " . $response . "\n";
        }
    }
    echo "\n";
}

echo "Frontend URL: http://$serverIP/exam-frontend\n";
echo "Backend API: http://$serverIP/exam-backend/api\n";
?>