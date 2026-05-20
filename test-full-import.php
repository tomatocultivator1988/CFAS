<?php

// Test full import with question count
$apiUrl = 'http://192.168.11.40/exam-backend/public/api';
$docxFile = $argv[1] ?? 'Aquaculture_set B.docx';

echo "========================================\n";
echo "  FULL IMPORT TEST\n";
echo "========================================\n\n";

// Login
echo "[1/3] Logging in...\n";
$loginResponse = file_get_contents($apiUrl . '/auth/login', false, stream_context_create([
    'http' => [
        'method' => 'POST',
        'header' => 'Content-Type: application/json',
        'content' => json_encode(['username' => 'admin', 'password' => 'admin123'])
    ]
]));
$loginData = json_decode($loginResponse, true);
$token = $loginData['token'];
echo "      SUCCESS - Token: " . substr($token, 0, 20) . "...\n\n";

// Get exam
echo "[2/3] Getting exam...\n";
$examResponse = file_get_contents($apiUrl . '/admin/exams', false, stream_context_create([
    'http' => [
        'header' => "Authorization: Bearer $token"
    ]
]));
$examData = json_decode($examResponse, true);
$examId = $examData['exams'][0]['id'];
echo "      SUCCESS - Exam ID: $examId\n\n";

// Upload DOCX
echo "[3/3] Uploading and parsing DOCX...\n";
echo "      File: $docxFile\n";
echo "      This may take 30-60 seconds for 100 questions...\n\n";

$boundary = '----WebKitFormBoundary' . uniqid();
$fileContent = file_get_contents($docxFile);
$fileName = basename($docxFile);

$body = "--$boundary\r\n";
$body .= "Content-Disposition: form-data; name=\"file\"; filename=\"$fileName\"\r\n";
$body .= "Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document\r\n\r\n";
$body .= $fileContent . "\r\n";
$body .= "--$boundary\r\n";
$body .= "Content-Disposition: form-data; name=\"exam_id\"\r\n\r\n";
$body .= "$examId\r\n";
$body .= "--$boundary--\r\n";

$context = stream_context_create([
    'http' => [
        'method' => 'POST',
        'header' => [
            "Authorization: Bearer $token",
            "Content-Type: multipart/form-data; boundary=$boundary",
            "Content-Length: " . strlen($body)
        ],
        'content' => $body,
        'timeout' => 120  // 2 minutes timeout
    ]
]);

$importResponse = @file_get_contents($apiUrl . '/admin/questions/import-docx', false, $context);

if ($importResponse === false) {
    echo "========================================\n";
    echo "  FAILED!\n";
    echo "========================================\n\n";
    echo "Error: " . error_get_last()['message'] . "\n";
    exit(1);
}

$importData = json_decode($importResponse, true);

if ($importData['success']) {
    echo "========================================\n";
    echo "  SUCCESS!\n";
    echo "========================================\n\n";
    echo "Questions parsed: " . $importData['count'] . "\n";
    echo "Message: " . $importData['message'] . "\n\n";
    
    if ($importData['count'] > 0) {
        $firstQ = $importData['questions'][0];
        echo "First question:\n";
        echo "  #" . $firstQ['number'] . ": " . substr($firstQ['question_text'], 0, 50) . "...\n";
        echo "  Choices: " . count($firstQ['choices']) . "\n";
        echo "  Answer: " . $firstQ['correct_answer'] . "\n\n";
        
        if ($importData['count'] > 1) {
            $lastQ = $importData['questions'][$importData['count'] - 1];
            echo "Last question:\n";
            echo "  #" . $lastQ['number'] . ": " . substr($lastQ['question_text'], 0, 50) . "...\n";
            echo "  Choices: " . count($lastQ['choices']) . "\n";
            echo "  Answer: " . $lastQ['correct_answer'] . "\n";
        }
    }
} else {
    echo "========================================\n";
    echo "  FAILED!\n";
    echo "========================================\n\n";
    echo "Error: " . $importData['message'] . "\n";
    if (isset($importData['errors'])) {
        print_r($importData['errors']);
    }
}
