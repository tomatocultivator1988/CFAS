<?php

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Question;
use App\Services\ExamManagementService;

echo "Testing Question Update...\n\n";

try {
    // Get a question to test
    $question = Question::with('answerChoices')->first();
    
    if (!$question) {
        echo "No questions found in database!\n";
        exit(1);
    }
    
    echo "Found question ID: {$question->id}\n";
    echo "Question text: {$question->question_text}\n";
    echo "Answer choices count: " . $question->answerChoices->count() . "\n";
    echo "Existing choices:\n";
    foreach ($question->answerChoices as $choice) {
        echo "  - {$choice->choice_text} (correct: " . ($choice->is_correct ? 'yes' : 'no') . ")\n";
    }
    echo "\n";
    
    // Test update data (similar to what frontend sends)
    $updateData = [
        'question_text' => $question->question_text,
        'topic' => $question->topic,
        'answer_choices' => [
            ['choice_text' => 'bidbid', 'is_correct' => false],
            ['choice_text' => 'bulan-bulan', 'is_correct' => false],
            ['choice_text' => 'kawag kawag', 'is_correct' => true],
            ['choice_text' => 'tiki tiki', 'is_correct' => false]
        ]
    ];
    
    echo "Attempting to update question using ExamManagementService...\n";
    
    $service = new ExamManagementService();
    $updated = $service->updateQuestion($question->id, $updateData);
    
    echo "\n✓ Update completed successfully!\n";
    
    // Verify the update
    echo "\nVerification:\n";
    echo "Answer choices count: " . $updated->answerChoices->count() . "\n";
    foreach ($updated->answerChoices as $choice) {
        echo "  - {$choice->choice_text} (correct: " . ($choice->is_correct ? 'yes' : 'no') . ")\n";
    }
    
} catch (\Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    echo "File: " . $e->getFile() . "\n";
    echo "Line: " . $e->getLine() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
}
