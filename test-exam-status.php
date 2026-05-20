<?php
/**
 * Test to verify exam status is correct after submission
 */

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Testing Exam Status After Submission ===\n\n";

$revieweeId = 16; // testuser
$examId = 5; // SET A

// Check all attempts for this exam
$allAttempts = DB::table('exam_attempts')
    ->where('reviewee_id', $revieweeId)
    ->where('exam_id', $examId)
    ->get(['id', 'status', 'score', 'percentage']);

echo "All attempts for Exam #{$examId}:\n";
foreach ($allAttempts as $attempt) {
    echo "  Attempt #{$attempt->id}: {$attempt->status} - Score: {$attempt->score} ({$attempt->percentage}%)\n";
}
echo "\n";

// Count completed attempts only
$completedCount = DB::table('exam_attempts')
    ->where('reviewee_id', $revieweeId)
    ->where('exam_id', $examId)
    ->whereIn('status', ['completed', 'auto_submitted'])
    ->count();

echo "Completed attempts: {$completedCount}\n";

// Count all attempts (including in-progress)
$totalCount = DB::table('exam_attempts')
    ->where('reviewee_id', $revieweeId)
    ->where('exam_id', $examId)
    ->count();

echo "Total attempts (including in-progress): {$totalCount}\n\n";

// Get exam max attempts
$exam = DB::table('exams')->where('id', $examId)->first(['max_attempts']);
echo "Max attempts allowed: {$exam->max_attempts}\n";
echo "Attempts remaining: " . ($exam->max_attempts - $completedCount) . "\n\n";

// Check what the API would return
echo "Expected status:\n";
if ($completedCount === 0) {
    echo "  Status: NEW\n";
    echo "  Button: Start Exam\n";
} elseif ($completedCount < $exam->max_attempts) {
    echo "  Status: IN PROGRESS (has completed attempts)\n";
    echo "  Button: Retake Exam\n";
} else {
    echo "  Status: EXHAUSTED\n";
    echo "  Button: No Attempts Left\n";
}

echo "\n=== Test Complete ===\n";
