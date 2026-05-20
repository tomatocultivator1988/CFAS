<?php

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

// Check exam_questions pivot table for exam 91
$pivotCount = DB::table('exam_questions')->where('exam_id', 91)->count();
echo "Exam 91 questions in pivot table: $pivotCount\n";

// Get latest questions
$latestQuestions = DB::table('questions')->orderBy('id', 'desc')->take(5)->get();
echo "\nLatest 5 questions:\n";
foreach ($latestQuestions as $q) {
    echo "ID: {$q->id} | " . substr($q->question_text, 0, 50) . "...\n";
    
    // Check if this question is in any exam
    $exams = DB::table('exam_questions')->where('question_id', $q->id)->get();
    if ($exams->count() > 0) {
        foreach ($exams as $eq) {
            echo "  -> In exam {$eq->exam_id}\n";
        }
    } else {
        echo "  -> NOT in any exam!\n";
    }
}
