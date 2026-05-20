<?php

// Test AI DOCX Import on XAMPP
echo "========================================\n";
echo "  AI DOCX IMPORT TEST (XAMPP)\n";
echo "========================================\n\n";

$baseUrl = "http://192.168.11.40/exam-backend/public/api";

// Step 1: Login
echo "[1/3] Logging in...\n";
$ch = curl_init("$baseUrl/auth/login");
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'username' => 'admin',
    'password' => 'admin123'
]));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);

$loginData = json_decode($response, true);
if (!isset($loginData['data']['token'])) {
    die("      FAILED - Cannot login\n");
}
$token = $loginData['data']['token'];
echo "      SUCCESS - Token: " . substr($token, 0, 20) . "...\n\n";

// Step 2: Get exam
echo "[2/3] Getting exam...\n";
$ch = curl_init("$baseUrl/admin/exams");
curl_setopt($ch, CURLOPT_HTTPHEADER, ["Authorization: Bearer $token"]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);

$examsData = json_decode($response, true);
if (empty($examsData['exams'])) {
    die("      FAILED - No exams found\n");
}
$examId = $examsData['exams'][0]['id'];
echo "      SUCCESS - Exam ID: $examId\n\n";

// Step 3: Upload DOCX
echo "[3/3] Uploading and parsing DOCX (Set B - 100 questions)...\n";
echo "      This may take 2-3 minutes for batch processing...\n";

$docxPath = __DIR__ . '/Aquaculture_set B.docx';
if (!file_exists($docxPath)) {
    die("      FAILED - Aquaculture_set B.docx not found\n");
}

$ch = curl_init("$baseUrl/admin/questions/import-docx");
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, [
    'file' => new CURLFile($docxPath, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'Aquaculture_set B.docx'),
    'exam_id' => (string)$examId
]);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Authorization: Bearer $token"
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 180);  // 3 minutes for 100 questions
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "\n";
if ($httpCode == 200) {
    $data = json_decode($response, true);
    echo "========================================\n";
    echo "  SUCCESS!\n";
    echo "========================================\n\n";
    echo "Questions parsed: " . $data['count'] . "\n";
    echo "Message: " . $data['message'] . "\n\n";
    
    if (!empty($data['questions'])) {
        $q = $data['questions'][0];
        echo "First question:\n";
        echo "  #" . $q['number'] . ": " . substr($q['question_text'], 0, 60) . "...\n";
        echo "  Choices: " . count($q['choices']) . "\n";
        echo "  Answer: " . $q['correct_answer'] . "\n";
    }
} else {
    echo "FAILED! HTTP Code: $httpCode\n";
    $data = json_decode($response, true);
    echo "Response: " . print_r($data, true) . "\n";
}
