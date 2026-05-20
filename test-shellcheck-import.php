<?php
// Test importing the large Shellcheck file

$baseUrl = 'http://192.168.11.40/exam-backend/public/api';
$examId = 91;
$filePath = 'Aquaculture_Reviewer-1_Shellcheck-Full.docx';

echo "Testing large Shellcheck file import...\n";
echo "File: $filePath\n";
echo "Size: " . round(filesize($filePath) / 1024 / 1024, 2) . " MB\n\n";

// Login
$ch = curl_init("$baseUrl/auth/login");
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'username' => 'admin',
    'password' => 'admin123'
]));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$loginData = json_decode($response, true);
curl_close($ch);

if (!isset($loginData['data']['token'])) {
    echo "Login failed. HTTP Code: $httpCode\n";
    echo "Response: " . json_encode($loginData, JSON_PRETTY_PRINT) . "\n";
    die();
}

echo "✓ Login successful\n";
$token = $loginData['data']['token'];

// Upload file
echo "Uploading to exam $examId...\n";
$startTime = time();

$ch = curl_init("$baseUrl/admin/questions/import-docx");
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, [
    'exam_id' => $examId,
    'file' => new CURLFile($filePath, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', basename($filePath))
]);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Authorization: Bearer $token"
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 3600); // 1 hour timeout

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$duration = time() - $startTime;
curl_close($ch);

echo "Duration: $duration seconds\n";
echo "HTTP Code: $httpCode\n";
echo "Response:\n";
echo json_encode(json_decode($response), JSON_PRETTY_PRINT) . "\n";

// Check database
echo "\n========================================\n";
echo "Checking database...\n";

$mysqli = new mysqli('localhost', 'root', '', 'review_center_exam');
$result = $mysqli->query("SELECT COUNT(*) as count FROM exam_questions WHERE exam_id = $examId");
$row = $result->fetch_assoc();
echo "Exam $examId questions: " . $row['count'] . "\n";
$mysqli->close();

echo "========================================\n";
