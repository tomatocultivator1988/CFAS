<?php

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

// Get latest 10 questions
$questions = \App\Models\Question::orderBy('id', 'desc')->take(10)->get();

echo "Latest 10 questions:\n";
echo str_repeat("=", 80) . "\n";

foreach ($questions as $q) {
    echo "ID: {$q->id} | Exam ID: {$q->exam_id} | " . substr($q->question_text, 0, 50) . "...\n";
}

echo "\n";
echo "Exam 91 question count: " . \App\Models\Exam::find(91)->questions()->count() . "\n";

// Check if there are any questions with exam_id 91
$exam91Questions = \App\Models\Question::where('exam_id', 91)->count();
echo "Questions with exam_id 91: $exam91Questions\n";
