<?php
/**
 * Test Analytics API with Authentication
 * Tests the exam click functionality with proper admin login
 */

// Test configuration
$baseUrl = 'http://192.168.11.40/exam-backend/public/api';
$adminUsername = 'admin';
$adminPassword = 'password';

echo "=== ANALYTICS API WITH AUTH TEST ===\n\n";

// Step 1: Login as admin to get auth token
echo "Step 1: Logging in as admin...\n";
$loginUrl = "$baseUrl/auth/login";
$loginData = [
    'username' => $adminUsername,
    'password' => $adminPassword
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

echo "Login HTTP Status: $httpCode\n";
if ($httpCode !== 200) {
    echo "❌ LOGIN FAILED: HTTP $httpCode\n";
    echo "Response: $response\n";
    exit(1);
}

$loginResult = json_decode($response, true);
if (!isset($loginResult['data']['token'])) {
    echo "❌ LOGIN FAILED: No token in response\n";
    print_r($loginResult);
    exit(1);
}

$authToken = $loginResult['data']['token'];
echo "✅ LOGIN SUCCESS: Got auth token\n";
echo "Token: " . substr($authToken, 0, 20) . "...\n\n";

// Step 2: Test exam performance list
echo "Step 2: Fetching exam performance list...\n";
$examListUrl = "$baseUrl/analytics/exams?timeFilter=all";
echo "URL: $examListUrl\n";

$ch = curl_init($examListUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Content-Type: application/json',
    'Authorization: Bearer ' . $authToken
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
if ($httpCode === 200) {
    $data = json_decode($response, true);
    if ($data['success']) {
        echo "✅ SUCCESS: Got " . count($data['data']['exams']) . " exams\n";
        if (!empty($data['data']['exams'])) {
            $firstExam = $data['data']['exams'][0];
            $examId = $firstExam['id'];
            echo "First exam: ID={$firstExam['id']}, Title={$firstExam['title']}\n";
            echo "Total Attempts: {$firstExam['totalAttempts']}\n";
            echo "Average Score: {$firstExam['averageScore']}%\n";
            echo "Pass Rate: {$firstExam['passRate']}%\n";
        } else {
            echo "⚠️ WARNING: No exams found\n";
            exit(0);
        }
    } else {
        echo "❌ FAILED: " . $data['message'] . "\n";
        exit(1);
    }
} else {
    echo "❌ FAILED: HTTP $httpCode\n";
    echo "Response: $response\n";
    exit(1);
}

echo "\n";

// Step 3: Test exam details (this is what happens when you click an exam)
echo "Step 3: Fetching exam details (simulating exam click)...\n";
$examDetailsUrl = "$baseUrl/analytics/exams/$examId/details?timeFilter=all";
echo "URL: $examDetailsUrl\n";

$ch = curl_init($examDetailsUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Content-Type: application/json',
    'Authorization: Bearer ' . $authToken
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
if ($httpCode === 200) {
    $data = json_decode($response, true);
    if ($data['success']) {
        echo "✅ SUCCESS: Got exam details for exam click!\n";
        echo "Exam Title: {$data['data']['examTitle']}\n";
        echo "Total Attempts: {$data['data']['totalAttempts']}\n";
        echo "Average Score: {$data['data']['averageScore']}%\n";
        echo "Pass Rate: {$data['data']['passRate']}%\n";
        
        if (!empty($data['data']['scoreDistribution'])) {
            echo "\n📊 Score Distribution (this is what shows in the chart):\n";
            foreach ($data['data']['scoreDistribution'] as $range) {
                echo "  {$range['range']}: {$range['count']} students\n";
            }
            echo "\n🎉 EXAM CLICK FIX IS WORKING! Score distribution data is available!\n";
        } else {
            echo "\n⚠️ WARNING: No score distribution data (chart will be empty)\n";
        }
    } else {
        echo "❌ FAILED: " . $data['message'] . "\n";
    }
} else {
    echo "❌ FAILED: HTTP $httpCode\n";
    echo "Response: $response\n";
}

echo "\n=== TEST COMPLETE ===\n";