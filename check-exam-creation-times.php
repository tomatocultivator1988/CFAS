<?php

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$exam92 = \App\Models\Exam::find(92);
$exam91 = \App\Models\Exam::find(91);

echo "Exam 92 (Capture Fisheries Reviewer-2 ShellCheck):\n";
echo "  Created: {$exam92->created_at}\n";
echo "  Updated: {$exam92->updated_at}\n";
echo "\n";

echo "Exam 91 (test 1000):\n";
echo "  Created: {$exam91->created_at}\n";
echo "  Updated: {$exam91->updated_at}\n";
echo "\n";

// Check when the latest questions were added to exam 92
$latestQuestion = DB::table('exam_questions')
    ->where('exam_id', 92)
    ->orderBy('display_order', 'desc')
    ->first();

if ($latestQuestion) {
    $question = \App\Models\Question::find($latestQuestion->question_id);
    echo "Latest question in Exam 92:\n";
    echo "  Question ID: {$question->id}\n";
    echo "  Created: {$question->created_at}\n";
    echo "  Text: " . substr($question->question_text, 0, 50) . "...\n";
}
