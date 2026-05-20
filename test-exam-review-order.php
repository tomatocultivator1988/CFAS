<?php
/**
 * Test Exam Review Order
 * Verifies that review shows same order as during exam (randomized or not)
 */

require 'backend/vendor/autoload.php';
$app = require_once 'backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\ExamAttempt;
use App\Models\Question;
use App\Services\RandomizationService;

echo "===========================================\n";
echo "Testing Exam Review Order\n";
echo "===========================================\n\n";

// Get a completed attempt (you can change this ID)
$attemptId = readline("Enter attempt ID to test (or press Enter for latest): ");

if (empty($attemptId)) {
    $attempt = ExamAttempt::whereIn('status', ['completed', 'auto_submitted'])
        ->orderBy('id', 'desc')
        ->first();
    
    if (!$attempt) {
        die("No completed attempts found!\n");
    }
    $attemptId = $attempt->id;
    echo "Using latest attempt: #$attemptId\n\n";
} else {
    $attempt = ExamAttempt::find($attemptId);
    if (!$attempt) {
        die("Attempt #$attemptId not found!\n");
    }
}

// Load attempt with exam details
$attempt->load('exam');

echo "Attempt Details:\n";
echo "- Attempt ID: {$attempt->id}\n";
echo "- Exam: {$attempt->exam->title}\n";
echo "- Reviewee ID: {$attempt->reviewee_id}\n";
echo "- Randomization Seed: {$attempt->randomization_seed}\n";
echo "- Randomize Questions: " . ($attempt->exam->randomize_questions ? 'YES' : 'NO') . "\n";
echo "- Randomize Choices: " . ($attempt->exam->randomize_choices ? 'YES' : 'NO') . "\n";
echo "- Total Questions: {$attempt->total_questions}\n\n";

// Get questions that were answered
$answeredQuestionIds = DB::table('attempt_answers')
    ->where('attempt_id', $attemptId)
    ->pluck('question_id')
    ->toArray();

echo "Questions answered: " . count($answeredQuestionIds) . "\n\n";

// Get questions from database
$questions = Question::whereIn('id', $answeredQuestionIds)
    ->with('answerChoices')
    ->get();

echo "Step 1: Database Order (before randomization)\n";
echo "----------------------------------------------\n";
foreach ($questions as $index => $question) {
    $dbOrder = DB::table('exam_questions')
        ->where('exam_id', $attempt->exam_id)
        ->where('question_id', $question->id)
        ->value('display_order');
    
    echo sprintf(
        "DB Order: %3d | Question ID: %4d | Text: %s\n",
        $dbOrder,
        $question->id,
        substr($question->question_text, 0, 50)
    );
}

echo "\n";

// Apply randomization using the SAME seed
$randomizationService = app(RandomizationService::class);
$seed = (string)$attempt->randomization_seed;

$randomizedQuestions = $randomizationService->randomizeExamContent(
    $questions,
    $seed,
    $attempt->exam->randomize_questions,
    $attempt->exam->randomize_choices
);

echo "Step 2: Randomized Order (what student saw during exam)\n";
echo "--------------------------------------------------------\n";
foreach ($randomizedQuestions as $index => $question) {
    $displayOrder = $index + 1;
    echo sprintf(
        "Display Order: %3d | Question ID: %4d | Text: %s\n",
        $displayOrder,
        $question->id,
        substr($question->question_text, 0, 50)
    );
}

echo "\n";

// Test the API endpoint
echo "Step 3: Testing API Endpoint\n";
echo "-----------------------------\n";

// Simulate API call
$baseUrl = 'http://192.168.11.40/exam-backend/public/api';

// Get reviewee credentials (you may need to adjust this)
$revieweeId = $attempt->reviewee_id;
$reviewee = DB::table('users')->where('id', $revieweeId)->first();

if (!$reviewee) {
    echo "WARNING: Could not find reviewee user\n";
    echo "Skipping API test\n\n";
} else {
    echo "Calling API: GET /reviewee/attempts/{$attemptId}/review\n";
    
    // Create a test token (simplified - in production use proper auth)
    $token = DB::table('personal_access_tokens')
        ->where('tokenable_id', $revieweeId)
        ->where('tokenable_type', 'App\\Models\\User')
        ->orderBy('created_at', 'desc')
        ->value('token');
    
    if (!$token) {
        echo "WARNING: No auth token found for reviewee\n";
        echo "Skipping API test\n\n";
    } else {
        $ch = curl_init("$baseUrl/reviewee/attempts/{$attemptId}/review");
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            "Authorization: Bearer $token",
            "Accept: application/json"
        ]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        echo "HTTP Code: $httpCode\n";
        
        if ($httpCode === 200) {
            $data = json_decode($response, true);
            
            echo "\nAPI Response - Question Order:\n";
            foreach ($data['questions'] as $question) {
                echo sprintf(
                    "Order: %3d | Question ID: %4d | Text: %s\n",
                    $question['order'],
                    $question['id'],
                    substr($question['question_text'], 0, 50)
                );
            }
            
            echo "\n✓ API test successful!\n";
        } else {
            echo "✗ API test failed\n";
            echo "Response: $response\n";
        }
    }
}

echo "\n===========================================\n";
echo "Verification:\n";
echo "===========================================\n";
echo "1. Compare 'Database Order' vs 'Randomized Order'\n";
echo "2. If randomization is ON, they should be DIFFERENT\n";
echo "3. If randomization is OFF, they should be SAME\n";
echo "4. API response should match 'Randomized Order'\n";
echo "5. This ensures review shows what student saw!\n";
echo "===========================================\n";
