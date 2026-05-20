<?php

require 'C:/xampp/htdocs/exam-backend/vendor/autoload.php';

$app = require_once 'C:/xampp/htdocs/exam-backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$examId = 11;
$count = DB::table('questions')->where('exam_id', $examId)->count();

echo "========================================\n";
echo "  QUESTIONS COUNT CHECK\n";
echo "========================================\n\n";
echo "Exam ID: $examId\n";
echo "Total Questions: $count\n\n";

if ($count > 0) {
    $latest = DB::table('questions')
        ->where('exam_id', $examId)
        ->orderBy('created_at', 'desc')
        ->limit(3)
        ->get(['id', 'question_text', 'created_at']);
    
    echo "Latest 3 questions:\n";
    foreach ($latest as $q) {
        echo "  - ID {$q->id}: " . substr($q->question_text, 0, 60) . "... ({$q->created_at})\n";
    }
}

echo "\n";
