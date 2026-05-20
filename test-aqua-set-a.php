<?php

echo "Testing with Aquaculture_set A.docx...\n\n";

// Login first
$loginData = [
    'username' => 'admin',
    'password' => 'admin123'
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://192.168.11.40/exam-backend/public/api/auth/login");
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($loginData));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json',
]);

$loginResponse = curl_exec($ch);
$loginData = json_decode($loginResponse, true);
curl_close($ch);

if (!isset($loginData['data']['token'])) {
    die("ERROR: Failed to login\n");
}

$token = $loginData['data']['token'];
echo "✓ Login successful\n\n";

// Try to upload Aquaculture set A
$testFile = __DIR__ . '/Aquaculture_set A.docx';

if (!file_exists($testFile)) {
    die("ERROR: Test file not found: $testFile\n");
}

echo "Uploading to exam 91...\n";
echo "File: Aquaculture_set A.docx\n";
echo "Size: " . round(filesize($testFile) / 1024, 2) . " KB\n\n";

$cfile = new CURLFile($testFile, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'document.docx');

$postData = [
    'file' => $cfile,
    'exam_id' => 91
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://192.168.11.40/exam-backend/public/api/admin/questions/import-docx");
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 600); // 10 minutes
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Authorization: Bearer ' . $token,
]);

echo "Sending request...\n";
$startTime = time();
$response = curl_exec($ch);
$duration = time() - $startTime;
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "\nDuration: $duration seconds\n";
echo "HTTP Code: $httpCode\n";

if ($error) {
    echo "CURL Error: $error\n";
}

if ($response) {
    $data = json_decode($response, true);
    echo "\nResponse:\n";
    echo json_encode($data, JSON_PRETTY_PRINT) . "\n";
} else {
    echo "\nNo response received\n";
}

// Check database
echo "\n========================================\n";
require __DIR__ . '/backend/vendor/autoload.php';
$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$count91 = DB::table('exam_questions')->where('exam_id', 91)->count();
echo "Exam 91 questions: $count91\n";
echo "========================================\n";
