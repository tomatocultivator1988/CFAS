<?php

echo "========================================\n";
echo "SHELLCHECK FILE UPLOAD TEST\n";
echo "========================================\n\n";

// First, login to get token
echo "Step 1: Logging in as admin...\n";
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
    die("ERROR: Failed to login. Response: " . $loginResponse . "\n");
}

$token = $loginData['data']['token'];
echo "✓ Login successful! Token obtained.\n\n";

$examId = 91; // test 1000 exam
$docxFile = __DIR__ . '/Aquaculture_Reviewer-1_Shellcheck-Full.docx';

if (!file_exists($docxFile)) {
    die("ERROR: File not found: $docxFile\n");
}

$fileSize = filesize($docxFile);
echo "File: Aquaculture_Reviewer-1_Shellcheck-Full.docx\n";
echo "Size: " . round($fileSize / 1024, 2) . " KB\n";
echo "Exam ID: $examId (test 1000)\n";
echo "Target: http://192.168.11.40/exam-backend/public/api/admin/questions/import-docx\n\n";

echo "Starting upload...\n";
echo "NOTE: This will take 70-90 minutes for ~1255 questions!\n";
echo "Progress will be stuck at 1% for first 30 seconds (normal!)\n";
echo "Timeout set to 2 hours (7200 seconds) - sureball!\n\n";

// Prepare file upload
$cfile = new CURLFile($docxFile, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'document.docx');

$postData = [
    'file' => $cfile,
    'exam_id' => $examId
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://192.168.11.40/exam-backend/public/api/admin/questions/import-docx");
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 7200); // 2 hours timeout
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Authorization: Bearer ' . $token,
]);

// Show progress
$startTime = time();
echo "[" . date('H:i:s') . "] Upload started...\n";

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);

$endTime = time();
$duration = $endTime - $startTime;

curl_close($ch);

echo "\n========================================\n";
echo "UPLOAD COMPLETE\n";
echo "========================================\n\n";

echo "Duration: " . gmdate("H:i:s", $duration) . " (" . $duration . " seconds)\n";
echo "HTTP Code: $httpCode\n";

if ($error) {
    echo "CURL Error: $error\n";
}

if ($response) {
    $data = json_decode($response, true);
    
    if ($data) {
        echo "\nResponse:\n";
        echo "Success: " . ($data['success'] ? 'YES' : 'NO') . "\n";
        
        if (isset($data['message'])) {
            echo "Message: " . $data['message'] . "\n";
        }
        
        if (isset($data['questions_imported'])) {
            echo "Questions Imported: " . $data['questions_imported'] . "\n";
        }
        
        if (isset($data['error'])) {
            echo "Error: " . $data['error'] . "\n";
        }
        
        echo "\nFull Response:\n";
        echo json_encode($data, JSON_PRETTY_PRINT) . "\n";
    } else {
        echo "\nRaw Response:\n";
        echo $response . "\n";
    }
} else {
    echo "\nNo response received\n";
}

echo "\n========================================\n";
echo "To check imported questions:\n";
echo "Visit: http://192.168.11.40/exam-frontend\n";
echo "Go to: Exam Management -> test 1000\n";
echo "========================================\n";
