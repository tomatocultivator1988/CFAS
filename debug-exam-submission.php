<?php
/**
 * Debug Script: Test exam submission flow
 * This will help us identify where the issue is occurring
 */

require __DIR__ . '/backend/vendor/autoload.php';

// Load environment
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/backend');
$dotenv->load();

// Bootstrap Laravel
$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "========================================\n";
echo "  DEBUG EXAM SUBMISSION FLOW\n";
echo "========================================\n\n";

// Step 1: Check if we have any active attempts
echo "[STEP 1] Checking active exam attempts...\n";
$activeAttempts = \App\Models\ExamAttempt::where('status', 'in_progress')->get();
echo "Active attempts found: " . $activeAttempts->count() . "\n\n";

if ($activeAttempts->count() > 0) {
    foreach ($activeAttempts as $attempt) {
        echo "Attempt ID: {$attempt->id}\n";
        echo "Reviewee ID: {$attempt->reviewee_id}\n";
        echo "Exam ID: {$attempt->exam_id}\n";
        echo "Status: {$attempt->status}\n";
        echo "Start Time: {$attempt->start_time}\n";
        echo "Answers Count: " . $attempt->answers()->count() . "\n";
        echo "---\n";
    }
} else {
    echo "No active attempts found. Let's create a test attempt...\n\n";
    
    // Step 2: Create a test attempt
    echo "[STEP 2] Creating test attempt...\n";
    
    // Find a reviewee
    $reviewee = \App\Models\User::where('role', 'reviewee')->first();
    if (!$reviewee) {
        echo "❌ No reviewee found! Please create reviewee accounts first.\n";
        exit(1);
    }
    
    // Find an exam
    $exam = \App\Models\Exam::where('status', 'active')->first();
    if (!$exam) {
        echo "❌ No active exam found! Please create an exam first.\n";
        exit(1);
    }
    
    echo "Using reviewee: {$reviewee->username} (ID: {$reviewee->id})\n";
    echo "Using exam: {$exam->title} (ID: {$exam->id})\n";
    
    try {
        $attempt = \App\Models\ExamAttempt::create([
            'reviewee_id' => $reviewee->id,
            'exam_id' => $exam->id,
            'start_time' => now(),
            'status' => 'in_progress',
            'total_questions' => $exam->questions()->count()
        ]);
        
        echo "✓ Test attempt created: ID {$attempt->id}\n\n";
        
        // Add some test answers
        $questions = $exam->questions()->take(3)->get();
        foreach ($questions as $question) {
            $choice = $question->answerChoices()->first();
            if ($choice) {
                \App\Models\AttemptAnswer::create([
                    'attempt_id' => $attempt->id,
                    'question_id' => $question->id,
                    'choice_id' => $choice->id,
                    'is_correct' => $choice->is_correct
                ]);
                echo "✓ Added answer for question {$question->id}\n";
            }
        }
        
    } catch (\Exception $e) {
        echo "❌ Failed to create test attempt: " . $e->getMessage() . "\n";
        exit(1);
    }
}

// Step 3: Test the submission endpoint
echo "\n[STEP 3] Testing submission endpoint...\n";

$testAttempt = \App\Models\ExamAttempt::where('status', 'in_progress')->first();
if (!$testAttempt) {
    echo "❌ No in-progress attempt found for testing\n";
    exit(1);
}

echo "Testing with attempt ID: {$testAttempt->id}\n";

try {
    // Simulate the submission service call
    $examService = app(\App\Services\ExamDeliveryService::class);
    $result = $examService->submitExam($testAttempt->id, $testAttempt->reviewee_id, false);
    
    echo "✓ Submission successful!\n";
    echo "Final status: {$result->status}\n";
    echo "Score: {$result->score}\n";
    echo "Percentage: {$result->percentage}%\n";
    echo "Total questions: {$result->total_questions}\n";
    
    // Test the API response format
    echo "\n[STEP 4] Testing API response format...\n";
    $apiResponse = [
        'message' => 'Exam submitted successfully.',
        'attempt' => $result->toArray()
    ];
    
    echo "API Response structure:\n";
    echo json_encode($apiResponse, JSON_PRETTY_PRINT) . "\n";
    
} catch (\Exception $e) {
    echo "❌ Submission failed: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}

echo "\n========================================\n";
echo "  DEBUGGING COMPLETE\n";
echo "========================================\n\n";

echo "Next steps:\n";
echo "1. Check browser console for JavaScript errors\n";
echo "2. Check network tab for failed API requests\n";
echo "3. Check Laravel logs for backend errors\n";
echo "4. Verify frontend is making the correct API call\n\n";