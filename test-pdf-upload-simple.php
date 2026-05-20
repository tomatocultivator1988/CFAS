<?php
/**
 * Simple PDF Upload Test
 * Tests if PDF import is working
 */

$baseUrl = 'http://192.168.11.40/exam-backend/public/api';
$examId = 91; // Change this to your exam ID

echo "===========================================\n";
echo "PDF Import Test\n";
echo "===========================================\n\n";

// Check if PDF file is provided
if ($argc < 2) {
    echo "Usage: php test-pdf-upload-simple.php <pdf-file>\n";
    echo "Example: php test-pdf-upload-simple.php sample.pdf\n\n";
    
    // List available PDF files
    echo "Available PDF files in current directory:\n";
    $pdfFiles = glob("*.pdf");
    if (empty($pdfFiles)) {
        echo "  (No PDF files found)\n";
    } else {
        foreach ($pdfFiles as $file) {
            $size = filesize($file);
            $sizeMB = round($size / 1024 / 1024, 2);
            echo "  - $file ($sizeMB MB)\n";
        }
    }
    exit(1);
}

$pdfFile = $argv[1];

if (!file_exists($pdfFile)) {
    echo "ERROR: File not found: $pdfFile\n";
    exit(1);
}

$fileSize = filesize($pdfFile);
$sizeMB = round($fileSize / 1024 / 1024, 2);

echo "File: $pdfFile\n";
echo "Size: $sizeMB MB\n";
echo "Exam ID: $examId\n\n";

// Step 1: Login
echo "Step 1: Logging in...\n";
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
curl_close($ch);

if ($httpCode !== 200) {
    echo "ERROR: Login failed (HTTP $httpCode)\n";
    echo "Response: $response\n";
    exit(1);
}

$loginData = json_decode($response, true);
if (!isset($loginData['data']['token'])) {
    echo "ERROR: No token in response\n";
    echo "Response: $response\n";
    exit(1);
}

$token = $loginData['data']['token'];
echo "✓ Login successful\n\n";

// Step 2: Upload PDF
echo "Step 2: Uploading PDF file...\n";
echo "This may take several minutes for large files...\n\n";

$startTime = time();

$ch = curl_init("$baseUrl/admin/questions/import-docx");
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, [
    'exam_id' => $examId,
    'file' => new CURLFile($pdfFile, 'application/pdf', basename($pdfFile))
]);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Authorization: Bearer $token"
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 7200); // 2 hour timeout

// Show progress
echo "Uploading";
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

$duration = time() - $startTime;
$minutes = floor($duration / 60);
$seconds = $duration % 60;

echo "\n\n";
echo "Duration: {$minutes}m {$seconds}s\n";
echo "HTTP Code: $httpCode\n\n";

if ($httpCode !== 200) {
    echo "ERROR: Upload failed\n";
    echo "Response: $response\n";
    exit(1);
}

$result = json_decode($response, true);

echo "===========================================\n";
echo "RESULT\n";
echo "===========================================\n";
echo json_encode($result, JSON_PRETTY_PRINT) . "\n\n";

// Step 3: Verify in database
echo "Step 3: Verifying in database...\n";
$mysqli = new mysqli('localhost', 'root', '', 'review_center_exam');

if ($mysqli->connect_error) {
    echo "WARNING: Could not connect to database\n";
} else {
    $stmt = $mysqli->prepare("SELECT COUNT(*) as count FROM exam_questions WHERE exam_id = ?");
    $stmt->bind_param("i", $examId);
    $stmt->execute();
    $row = $stmt->get_result()->fetch_assoc();
    
    echo "✓ Questions in database: " . $row['count'] . "\n";
    $stmt->close();
    $mysqli->close();
}

echo "\n===========================================\n";
if (isset($result['success']) && $result['success']) {
    echo "✓ PDF IMPORT SUCCESSFUL!\n";
    echo "✓ Imported " . ($result['count'] ?? 0) . " questions\n";
} else {
    echo "✗ PDF IMPORT FAILED\n";
    echo "Message: " . ($result['message'] ?? 'Unknown error') . "\n";
}
echo "===========================================\n";
