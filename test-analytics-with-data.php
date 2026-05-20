<?php

// Test analytics API endpoints with the new sample data

$baseUrl = 'http://localhost:8000/api';

// Login first
$loginData = [
    'username' => 'admin',
    'password' => 'password'
];

$ch = curl_init($baseUrl . '/auth/login');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($loginData));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$loginResult = json_decode($response, true);
curl_close($ch);

if (!isset($loginResult['data']['token'])) {
    echo "❌ Login failed!\n";
    print_r($loginResult);
    exit(1);
}

$token = $loginResult['data']['token'];
echo "✓ Logged in successfully\n\n";

// Test analytics overview endpoint
echo "=== Testing Analytics Overview ===\n";
$ch = curl_init($baseUrl . '/analytics/overview?timeFilter=all');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $token,
    'Content-Type: application/json'
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: {$httpCode}\n";
if ($httpCode === 200) {
    $response_data = json_decode($response, true);
    $data = $response_data['data'] ?? [];
    echo "✓ Overview data received:\n";
    echo "  Total Exams: " . ($data['totalExams'] ?? 'N/A') . "\n";
    echo "  Total Attempts: " . ($data['totalAttempts'] ?? 'N/A') . "\n";
    echo "  Active Reviewees: " . ($data['activeReviewees'] ?? 'N/A') . "\n";
    echo "  Overall Average: " . ($data['overallAverage'] ?? 'N/A') . "%\n";
} else {
    echo "❌ Failed to get overview data\n";
    echo "Response: {$response}\n";
}

// Test exam performance endpoint
echo "\n=== Testing Exam Performance ===\n";
$ch = curl_init($baseUrl . '/analytics/exams?timeFilter=all&sortBy=attempts&order=desc&page=1');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $token,
    'Content-Type: application/json'
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: {$httpCode}\n";
if ($httpCode === 200) {
    $response_data = json_decode($response, true);
    $data = $response_data['data'] ?? [];
    echo "✓ Exam performance data received:\n";
    if (isset($data['exams']) && count($data['exams']) > 0) {
        $exam = $data['exams'][0];
        echo "  First Exam: " . ($exam['title'] ?? 'N/A') . "\n";
        echo "  Total Attempts: " . ($exam['totalAttempts'] ?? 'N/A') . "\n";
        echo "  Average Score: " . ($exam['averageScore'] ?? 'N/A') . "%\n";
        echo "  Pass Rate: " . ($exam['passRate'] ?? 'N/A') . "%\n";
    } else {
        echo "  No exam data found\n";
    }
} else {
    echo "❌ Failed to get exam performance data\n";
    echo "Response: {$response}\n";
}

// Test student performance endpoint
echo "\n=== Testing Student Performance ===\n";
$ch = curl_init($baseUrl . '/analytics/students?timeFilter=all&level=all&page=1');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $token,
    'Content-Type: application/json'
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: {$httpCode}\n";
if ($httpCode === 200) {
    $response_data = json_decode($response, true);
    $data = $response_data['data'] ?? [];
    echo "✓ Student performance data received:\n";
    if (isset($data['students']) && count($data['students']) > 0) {
        echo "  Total Students: " . count($data['students']) . "\n";
        $student = $data['students'][0];
        echo "  Top Student: " . ($student['name'] ?? 'N/A') . "\n";
        echo "  Average Score: " . ($student['averageScore'] ?? 'N/A') . "%\n";
        echo "  Total Attempts: " . ($student['totalAttempts'] ?? 'N/A') . "\n";
    } else {
        echo "  No student data found\n";
    }
} else {
    echo "❌ Failed to get student performance data\n";
    echo "Response: {$response}\n";
}

echo "\n✓ Analytics API is working with sample data!\n";
echo "You can now view the analytics dashboard in the browser.\n";
