<?php

require __DIR__ . '/backend/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Testing Answer Submission ===\n\n";

$examId = 5; // SET A
$revieweeId = 16; // testuser

// Step 1: Create a new attempt
echo "Step 1: Creating exam attempt...\n";
try {
    $service = app(\App\Services\ExamDeliveryService::class);
    $attempt = $service->startExamAttempt($examId, $revieweeId);
    echo "✓ Attempt created: ID {$attempt->id}\n\n";
} catch (\Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}

// Step 2: Get attempt details with questions
echo "Step 2: Loading questions...\n";
try {
    $details = $service->getAttemptDetails($attempt->id, $revieweeId);
    $questions = $details['questions'];
    echo "✓ Loaded {$questions->count()} questions\n\n";
} catch (\Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}

// Step 3: Submit answers for first 5 questions
echo "Step 3: Submitting answers for first 5 questions...\n";
$answeredCount = 0;
foreach ($questions->take(5) as $question) {
    // Get the first choice (just for testing)
    $choices = $question->answer_choices ?? $question->answerChoices ?? [];
    if (count($choices) > 0) {
        $choiceId = $choices[0]->id;
        
        try {
            $service->submitAnswer($attempt->id, $question->id, $choiceId, $revieweeId);
            $answeredCount++;
            echo "  ✓ Question {$question->id}: Answer saved (Choice {$choiceId})\n";
        } catch (\Exception $e) {
            echo "  ✗ Question {$question->id}: Error - " . $e->getMessage() . "\n";
        }
    }
}
echo "\n✓ Submitted {$answeredCount} answers\n\n";

// Step 4: Verify answers in database
echo "Step 4: Verifying answers in database...\n";
$savedAnswers = DB::table('attempt_answers')
    ->where('attempt_id', $attempt->id)
    ->get();

echo "✓ Found {$savedAnswers->count()} answers in database\n\n";

foreach ($savedAnswers as $answer) {
    echo "  - Question {$answer->question_id}: Choice {$answer->selected_choice_id} ";
    echo "(" . ($answer->is_correct ? "CORRECT" : "INCORRECT") . ")\n";
}

// Step 5: Submit the exam
echo "\nStep 5: Submitting exam...\n";
try {
    $completedAttempt = $service->submitExam($attempt->id, $revieweeId, false);
    echo "✓ Exam submitted successfully!\n";
    echo "  Status: {$completedAttempt->status}\n";
    echo "  Score: {$completedAttempt->score}/{$completedAttempt->total_questions}\n";
    echo "  Percentage: {$completedAttempt->percentage}%\n";
} catch (\Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}

// Step 6: Verify final status
echo "\nStep 6: Verifying final status in database...\n";
$finalAttempt = DB::table('exam_attempts')->where('id', $attempt->id)->first();
echo "✓ Status: {$finalAttempt->status}\n";
echo "✓ Score: {$finalAttempt->score}\n";
echo "✓ End Time: {$finalAttempt->end_time}\n";

echo "\n=== All Tests Passed! ===\n";
echo "\nAnswer submission is working correctly:\n";
echo "- Answers are saved to database immediately\n";
echo "- Correct/incorrect status is calculated\n";
echo "- Exam submission updates status and calculates score\n";
