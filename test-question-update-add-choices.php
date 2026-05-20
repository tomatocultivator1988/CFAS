<?php

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Question;
use App\Services\ExamManagementService;

echo "Testing Question Update - Adding More Choices...\n\n";

try {
    $question = Question::with('answerChoices')->first();
    
    echo "Found question ID: {$question->id}\n";
    echo "Current answer choices count: " . $question->answerChoices->count() . "\n";
    echo "Existing choices:\n";
    foreach ($question->answerChoices as $choice) {
        echo "  - {$choice->choice_text} (correct: " . ($choice->is_correct ? 'yes' : 'no') . ")\n";
    }
    echo "\n";
    
    // Add 2 more choices (from 4 to 6)
    $updateData = [
        'question_text' => $question->question_text,
        'topic' => $question->topic,
        'answer_choices' => [
            ['choice_text' => 'Choice A', 'is_correct' => false],
            ['choice_text' => 'Choice B', 'is_correct' => true],
            ['choice_text' => 'Choice C', 'is_correct' => false],
            ['choice_text' => 'Choice D', 'is_correct' => false],
            ['choice_text' => 'Choice E', 'is_correct' => false],
            ['choice_text' => 'Choice F', 'is_correct' => false]
        ]
    ];
    
    echo "Updating to 6 choices...\n";
    
    $service = new ExamManagementService();
    $updated = $service->updateQuestion($question->id, $updateData);
    
    echo "\n✓ Update completed successfully!\n";
    echo "\nNew answer choices count: " . $updated->answerChoices->count() . "\n";
    foreach ($updated->answerChoices as $choice) {
        echo "  - {$choice->choice_text} (correct: " . ($choice->is_correct ? 'yes' : 'no') . ")\n";
    }
    
} catch (\Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
}
