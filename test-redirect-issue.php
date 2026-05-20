<?php
/**
 * Test to verify exam submission and check attempts
 */

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Checking Recent Exam Attempts ===\n\n";

$revieweeId = 16; // testuser

$attempts = DB::table('exam_attempts')
    ->where('reviewee_id', $revieweeId)
    ->orderBy('id', 'desc')
    ->limit(5)
    ->get(['id', 'exam_id', 'status', 'score', 'percentage', 'end_time']);

echo "Found " . $attempts->count() . " attempts for reviewee #{$revieweeId}\n\n";

foreach ($attempts as $attempt) {
    echo "Attempt ID: {$attempt->id}\n";
    echo "  Exam ID: {$attempt->exam_id}\n";
    echo "  Status: {$attempt->status}\n";
    echo "  Score: {$attempt->score}\n";
    echo "  Percentage: {$attempt->percentage}%\n";
    echo "  Ended: {$attempt->end_time}\n";
    echo "\n";
}

// Check if there are any in-progress attempts
$inProgress = DB::table('exam_attempts')
    ->where('reviewee_id', $revieweeId)
    ->where('status', 'in_progress')
    ->count();

echo "In-progress attempts: {$inProgress}\n";

if ($inProgress > 0) {
    echo "\n⚠️  WARNING: There are still in-progress attempts!\n";
    echo "This might cause issues with taking new exams.\n";
}

echo "\n=== Test Complete ===\n";
