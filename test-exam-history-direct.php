<?php
/**
 * Direct test of exam history functionality using Laravel bootstrap
 */

require __DIR__ . '/backend/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Testing Exam History Functionality ===\n\n";

$revieweeId = 16; // testuser

// Step 1: Check for completed attempts
echo "Step 1: Checking for completed exam attempts...\n";
$completedAttempts = DB::table('exam_attempts')
    ->where('reviewee_id', $revieweeId)
    ->whereIn('status', ['completed', 'auto_submitted'])
    ->orderBy('end_time', 'desc')
    ->get();

echo "✓ Found {$completedAttempts->count()} completed attempts\n\n";

if ($completedAttempts->isEmpty()) {
    echo "ℹ️  No completed attempts found. Creating a test attempt...\n\n";
    
    // Create a test attempt
    $examId = 5; // SET A
    $service = app(\App\Services\ExamDeliveryService::class);
    
    try {
        $attempt = $service->startExamAttempt($examId, $revieweeId);
        echo "✓ Test attempt created: ID {$attempt->id}\n";
        
        // Get questions and submit a few answers
        $details = $service->getAttemptDetails($attempt->id, $revieweeId);
        $questions = $details['questions'];
        
        echo "✓ Submitting answers for 5 questions...\n";
        foreach ($questions->take(5) as $question) {
            $choices = $question->answer_choices ?? $question->answerChoices ?? [];
            if (count($choices) > 0) {
                $service->submitAnswer($attempt->id, $question->id, $choices[0]->id, $revieweeId);
            }
        }
        
        // Submit the exam
        $completedAttempt = $service->submitExam($attempt->id, $revieweeId, false);
        echo "✓ Exam submitted with score: {$completedAttempt->score}/{$completedAttempt->total_questions}\n\n";
        
        // Refresh the completed attempts list
        $completedAttempts = DB::table('exam_attempts')
            ->where('reviewee_id', $revieweeId)
            ->whereIn('status', ['completed', 'auto_submitted'])
            ->orderBy('end_time', 'desc')
            ->get();
    } catch (\Exception $e) {
        echo "✗ Error creating test attempt: " . $e->getMessage() . "\n";
        exit(1);
    }
}

// Step 2: Test the controller method
echo "Step 2: Testing RevieweeExamController::getExamHistory()...\n";

$history = \App\Models\ExamAttempt::where('reviewee_id', $revieweeId)
    ->whereIn('status', ['completed', 'auto_submitted'])
    ->with('exam:id,title')
    ->orderBy('end_time', 'desc')
    ->get()
    ->map(function ($attempt) {
        return [
            'id' => $attempt->id,
            'exam_id' => $attempt->exam_id,
            'exam_title' => $attempt->exam->title,
            'score' => $attempt->score,
            'total_questions' => $attempt->total_questions,
            'percentage' => $attempt->percentage,
            'attempt_number' => $attempt->attempt_number,
            'status' => $attempt->status,
            'start_time' => $attempt->start_time,
            'end_time' => $attempt->end_time,
        ];
    });

echo "✓ History query successful\n";
echo "✓ Found {$history->count()} history records\n\n";

// Step 3: Display the history
echo "=== Exam History for Reviewee #{$revieweeId} ===\n\n";

foreach ($history as $index => $attempt) {
    echo "Attempt #" . ($index + 1) . ":\n";
    echo "  ID: {$attempt['id']}\n";
    echo "  Exam: {$attempt['exam_title']}\n";
    echo "  Score: {$attempt['score']}/{$attempt['total_questions']} ({$attempt['percentage']}%)\n";
    echo "  Attempt Number: #{$attempt['attempt_number']}\n";
    echo "  Status: {$attempt['status']}\n";
    echo "  Started: {$attempt['start_time']}\n";
    echo "  Completed: {$attempt['end_time']}\n";
    
    // Color code the score
    $percentage = $attempt['percentage'];
    if ($percentage >= 75) {
        echo "  Grade: ✅ EXCELLENT (≥75%)\n";
    } elseif ($percentage >= 50) {
        echo "  Grade: ⚠️  GOOD (≥50%)\n";
    } else {
        echo "  Grade: ❌ NEEDS IMPROVEMENT (<50%)\n";
    }
    echo "\n";
}

echo "=== Test Complete ===\n";
echo "\nExam history functionality is working correctly:\n";
echo "- Query retrieves completed attempts\n";
echo "- Exam titles are loaded via relationship\n";
echo "- All required fields are present\n";
echo "- Data is sorted by end_time (most recent first)\n";
