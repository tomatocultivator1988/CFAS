<?php
/**
 * Test API response format
 */

$loginUrl = 'http://192.168.11.40/exam-backend/public/api/auth/login';
$loginData = [
    'username' => 'admin',
    'password' => 'password'
];

$ch = curl_init($loginUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($loginData));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
echo "Raw Response:\n";
echo $response . "\n\n";

$data = json_decode($response, true);
echo "Parsed Response:\n";
print_r($data);