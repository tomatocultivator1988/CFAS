<?php
/**
 * Test Analytics Exam Click API
 * Tests if clicking an exam fetches data from database
 */

// Test configuration
$baseUrl = 'http://192.168.11.40/exam-backend/public/api';
$examId = 1; // Test with exam ID 1
$timeFilter = 'all';

echo "=== ANALYTICS EXAM CLICK API TEST ===\n\n";

// Test 1: Get exam list first
echo "Test 1: Fetching exam performance list...\n";
$examListUrl = "$baseUrl/analytics/exams?timeFilter=$timeFilter";
echo "URL: $examListUrl\n";

$ch = curl_init($examListUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Content-Type: application/json'
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
        }
    } else {
        echo "❌ FAILED: " . $data['message'] . "\n";
    }
} else {
    echo "❌ FAILED: HTTP $httpCode\n";
    echo "Response: $response\n";
}

echo "\n";

// Test 2: Get exam details (this is what happens when you click an exam)
echo "Test 2: Fetching exam details (simulating exam click)...\n";
$examDetailsUrl = "$baseUrl/analytics/exams/$examId?timeFilter=$timeFilter";
echo "URL: $examDetailsUrl\n";

$ch = curl_init($examDetailsUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Content-Type: application/json'
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
if ($httpCode === 200) {
    $data = json_decode($response, true);
    if ($data['success']) {
        echo "✅ SUCCESS: Got exam details\n";
        echo "Exam Title: {$data['data']['examTitle']}\n";
        echo "Total Attempts: {$data['data']['totalAttempts']}\n";
        echo "Average Score: {$data['data']['averageScore']}%\n";
        echo "Pass Rate: {$data['data']['passRate']}%\n";
        
        if (!empty($data['data']['scoreDistribution'])) {
            echo "\nScore Distribution:\n";
            foreach ($data['data']['scoreDistribution'] as $range) {
                echo "  {$range['range']}: {$range['count']} students\n";
            }
        } else {
            echo "\n⚠️ WARNING: No score distribution data\n";
        }
    } else {
        echo "❌ FAILED: " . $data['message'] . "\n";
    }
} else {
    echo "❌ FAILED: HTTP $httpCode\n";
    echo "Response: $response\n";
}

echo "\n=== TEST COMPLETE ===\n";
