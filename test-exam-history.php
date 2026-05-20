<?php
/**
 * Test script to verify exam history API endpoint
 * 
 * This script:
 * 1. Logs in as a reviewee
 * 2. Fetches exam history
 * 3. Displays the results
 */

$baseUrl = 'http://localhost/Exam-Main/backend/public/api';

echo "=== Testing Exam History API ===\n\n";

// Step 1: Login as reviewee
echo "Step 1: Logging in as reviewee...\n";
$loginData = [
    'username' => 'reviewee1',
    'password' => 'password123'
];

$ch = curl_init("$baseUrl/auth/login");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($loginData));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($httpCode !== 200) {
    echo "❌ Login failed with status $httpCode\n";
    echo "Response: $response\n";
    exit(1);
}

$loginResult = json_decode($response, true);
$token = $loginResult['token'] ?? null;

if (!$token) {
    echo "❌ No token received\n";
    exit(1);
}

echo "✅ Login successful\n";
echo "Token: " . substr($token, 0, 20) . "...\n\n";

// Step 2: Fetch exam history
echo "Step 2: Fetching exam history...\n";
$ch = curl_init("$baseUrl/reviewee/exam-history");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    "Authorization: Bearer $token"
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($httpCode !== 200) {
    echo "❌ Failed to fetch history with status $httpCode\n";
    echo "Response: $response\n";
    exit(1);
}

$historyResult = json_decode($response, true);
$history = $historyResult['history'] ?? [];

echo "✅ History fetched successfully\n";
echo "Total attempts: " . count($history) . "\n\n";

// Step 3: Display results
if (empty($history)) {
    echo "ℹ️  No exam history found for this reviewee\n";
} else {
    echo "=== Exam History ===\n\n";
    foreach ($history as $index => $attempt) {
        echo "Attempt #" . ($index + 1) . ":\n";
        echo "  Exam: {$attempt['exam_title']}\n";
        echo "  Score: {$attempt['score']}/{$attempt['total_questions']} ({$attempt['percentage']}%)\n";
        echo "  Attempt Number: #{$attempt['attempt_number']}\n";
        echo "  Status: {$attempt['status']}\n";
        echo "  Completed: {$attempt['end_time']}\n";
        echo "\n";
    }
}

echo "=== Test Complete ===\n";
