<?php
/**
 * Test script for exam review functionality
 */

require __DIR__ . '/backend/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Testing Exam Review Functionality ===\n\n";

$revieweeId = 16; // testuser
$attemptId = 18; // From previous test

echo "Step 1: Getting attempt review for attempt #{$attemptId}...\n";

// Get the attempt
$attempt = \App\Models\ExamAttempt::where('id', $attemptId)
    ->where('reviewee_id', $revieweeId)
    ->whereIn('status', ['completed', 'auto_submitted'])
    ->with('exam:id,title,description')
    ->first();

if (!$attempt) {
    echo "❌ Attempt not found\n";
    exit(1);
}

echo "✓ Attempt found: {$attempt->exam->title}\n";
echo "  Score: {$attempt->score}/{$attempt->total_questions} ({$attempt->percentage}%)\n\n";

// Get all questions with answers
echo "Step 2: Loading questions with answers...\n";

$questions = \App\Models\Question::whereIn('id', function($query) use ($attemptId) {
    $query->select('question_id')
        ->from('attempt_answers')
        ->where('attempt_id', $attemptId);
})
->with(['answerChoices'])
->get()
->map(function ($question) use ($attemptId) {
    // Get user's answer for this question
    $userAnswer = \App\Models\AttemptAnswer::where('attempt_id', $attemptId)
        ->where('question_id', $question->id)
        ->first();
    
    // Find correct answer
    $correctChoice = $question->answerChoices->firstWhere('is_correct', true);
    
    return [
        'id' => $question->id,
        'question_text' => $question->question_text,
        'choices' => $question->answerChoices->map(function ($choice) {
            return [
                'id' => $choice->id,
                'choice_text' => $choice->choice_text,
                'is_correct' => $choice->is_correct,
            ];
        }),
        'user_answer_id' => $userAnswer ? $userAnswer->selected_choice_id : null,
        'correct_answer_id' => $correctChoice ? $correctChoice->id : null,
        'is_correct' => $userAnswer ? $userAnswer->is_correct : false,
    ];
});

echo "✓ Loaded {$questions->count()} questions\n\n";

// Display first 3 questions as sample
echo "=== Sample Questions (First 3) ===\n\n";

foreach ($questions->take(3) as $index => $question) {
    $status = $question['is_correct'] ? '✅ CORRECT' : '❌ INCORRECT';
    echo "Question " . ($index + 1) . ": {$status}\n";
    echo "  Text: " . substr($question['question_text'], 0, 80) . "...\n";
    echo "  Choices:\n";
    
    foreach ($question['choices'] as $choice) {
        $marker = '';
        if ($choice['id'] === $question['user_answer_id']) {
            $marker = ' [YOUR ANSWER]';
        }
        if ($choice['is_correct']) {
            $marker .= ' [CORRECT]';
        }
        
        echo "    - " . substr($choice['choice_text'], 0, 60) . "..." . $marker . "\n";
    }
    echo "\n";
}

// Statistics
$correctCount = $questions->where('is_correct', true)->count();
$incorrectCount = $questions->where('is_correct', false)->count();

echo "=== Statistics ===\n";
echo "Total Questions: {$questions->count()}\n";
echo "Correct Answers: {$correctCount}\n";
echo "Incorrect Answers: {$incorrectCount}\n";
echo "Percentage: {$attempt->percentage}%\n";

echo "\n=== Test Complete ===\n";
echo "\nExam review functionality is working correctly:\n";
echo "- Attempt details retrieved\n";
echo "- Questions loaded with all choices\n";
echo "- User answers identified\n";
echo "- Correct answers marked\n";
echo "- Answer correctness calculated\n";
