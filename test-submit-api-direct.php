<?php
/**
 * Direct API Test: Test the submit exam endpoint
 */

require __DIR__ . '/backend/vendor/autoload.php';

// Load environment
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/backend');
$dotenv->load();

// Bootstrap Laravel
$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "========================================\n";
echo "  DIRECT API SUBMIT TEST\n";
echo "========================================\n\n";

// Step 1: Find a reviewee and create/find an attempt
$reviewee = \App\Models\User::where('role', 'reviewee')->first();
if (!$reviewee) {
    echo "❌ No reviewee found!\n";
    exit(1);
}

$exam = \App\Models\Exam::where('status', 'active')->first();
if (!$exam) {
    echo "❌ No active exam found!\n";
    exit(1);
}

echo "Using reviewee: {$reviewee->username} (ID: {$reviewee->id})\n";
echo "Using exam: {$exam->title} (ID: {$exam->id})\n\n";

// Find or create an in-progress attempt
$attempt = \App\Models\ExamAttempt::where('reviewee_id', $reviewee->id)
    ->where('status', 'in_progress')
    ->first();

if (!$attempt) {
    echo "Creating new attempt...\n";
    $attempt = \App\Models\ExamAttempt::create([
        'reviewee_id' => $reviewee->id,
        'exam_id' => $exam->id,
        'start_time' => now(),
        'status' => 'in_progress',
        'total_questions' => $exam->questions()->count()
    ]);
    
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
        }
    }
}

echo "Using attempt ID: {$attempt->id}\n\n";

// Step 2: Test the API endpoint directly
echo "[TESTING API ENDPOINT]\n";

try {
    // Create a mock request
    $request = new \Illuminate\Http\Request();
    $request->setUserResolver(function () use ($reviewee) {
        return $reviewee;
    });
    
    // Create controller instance with dependencies
    $examService = app(\App\Services\ExamDeliveryService::class);
    $violationService = app(\App\Services\ViolationTrackingService::class);
    $controller = new \App\Http\Controllers\RevieweeExamController($examService, $violationService);
    
    // Call the submit method
    echo "Calling submitExam({$attempt->id})...\n";
    $response = $controller->submitExam($request, $attempt->id);
    
    echo "Response status: " . $response->getStatusCode() . "\n";
    echo "Response content:\n";
    echo json_encode($response->getData(), JSON_PRETTY_PRINT) . "\n\n";
    
    if ($response->getStatusCode() === 200) {
        echo "✅ API ENDPOINT WORKING CORRECTLY!\n";
        echo "The issue is likely in the frontend JavaScript.\n\n";
        
        echo "DEBUGGING STEPS:\n";
        echo "1. Open browser console and look for debug logs starting with '🔧'\n";
        echo "2. Check Network tab for the API call to /api/reviewee/attempts/{$attempt->id}/submit\n";
        echo "3. Look for any JavaScript errors\n";
        echo "4. Check if the success modal appears with debug info\n\n";
        
        echo "TEST URL: http://localhost/exam-frontend\n";
        echo "Login: {$reviewee->username} / password123\n";
        
    } else {
        echo "❌ API ENDPOINT FAILED!\n";
        echo "Fix the backend issue first.\n";
    }
    
} catch (\Exception $e) {
    echo "❌ Exception: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}

echo "\n";