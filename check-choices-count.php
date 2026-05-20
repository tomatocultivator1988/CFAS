<?php

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Question;
use App\Models\AnswerChoice;

$question = Question::find(1);
$choices = AnswerChoice::where('question_id', 1)->get();

echo "Question ID: 1\n";
echo "Total choices in database: " . $choices->count() . "\n\n";

echo "All choices (unordered):\n";
foreach ($choices as $choice) {
    echo "ID: {$choice->id}, Order: {$choice->display_order}, Text: {$choice->choice_text}, Correct: " . ($choice->is_correct ? 'yes' : 'no') . "\n";
}

echo "\n\nOrdered choices:\n";
$orderedChoices = AnswerChoice::where('question_id', 1)->orderBy('display_order')->get();
foreach ($orderedChoices as $choice) {
    echo "ID: {$choice->id}, Order: {$choice->display_order}, Text: {$choice->choice_text}, Correct: " . ($choice->is_correct ? 'yes' : 'no') . "\n";
}
