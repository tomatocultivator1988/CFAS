<?php
// Test the ViewScores API endpoint
require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "=== TESTING /admin/export/all-attempts ===\n\n";

try {
    $controller = new \App\Http\Controllers\ExportController();
    $response = $controller->getAllAttempts();
    
    $data = json_decode($response->getContent(), true);
    
    echo "Success: " . ($data['success'] ? 'YES' : 'NO') . "\n";
    echo "Count: " . ($data['count'] ?? 0) . "\n\n";
    
    if (!empty($data['data'])) {
        echo "=== FIRST 3 ATTEMPTS ===\n\n";
        foreach (array_slice($data['data'], 0, 3) as $attempt) {
            echo "Student: {$attempt['student_name']} (@{$attempt['username']})\n";
            echo "Exam: {$attempt['exam_title']} ({$attempt['category']})\n";
            echo "Attempt #{$attempt['attempt_number']}\n";
            echo "Score: {$attempt['score']}/{$attempt['total_questions']} ({$attempt['percentage']}%)\n";
            echo "Date: {$attempt['end_time']}\n";
            echo "---\n";
        }
    } else {
        echo "NO DATA RETURNED!\n";
    }
} catch (\Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "File: " . $e->getFile() . ":" . $e->getLine() . "\n";
}
