<?php

require __DIR__ . '/backend/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Checking Exam Attempts ===\n\n";

$attempts = DB::table('exam_attempts')
    ->where('reviewee_id', 16) // testuser
    ->orderBy('id', 'desc')
    ->get();

echo "Total attempts for testuser: " . $attempts->count() . "\n\n";

foreach ($attempts as $attempt) {
    echo "Attempt ID: {$attempt->id}\n";
    echo "Exam ID: {$attempt->exam_id}\n";
    echo "Attempt Number: {$attempt->attempt_number}\n";
    echo "Status: {$attempt->status}\n";
    echo "Score: {$attempt->score}\n";
    echo "Start: {$attempt->start_time}\n";
    echo "End: {$attempt->end_time}\n";
    echo "---\n";
}

// Check exam max_attempts
$exam = DB::table('exams')->where('id', 5)->first();
echo "\nExam 'SET A' max_attempts: {$exam->max_attempts}\n";
