<?php
require 'backend/vendor/autoload.php';
$app = require_once 'backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$attempt = \App\Models\ExamAttempt::whereIn('status', ['completed', 'auto_submitted'])
    ->whereHas('exam', function($q) {
        $q->where('randomize_questions', true);
    })
    ->orderBy('id', 'desc')
    ->first();

if ($attempt) {
    $attempt->load('exam');
    echo "Found randomized attempt: #{$attempt->id}\n";
    echo "Exam: {$attempt->exam->title}\n";
    echo "Randomize Questions: " . ($attempt->exam->randomize_questions ? 'YES' : 'NO') . "\n";
    echo "\nRun: php test-exam-review-order.php\n";
    echo "Then enter: {$attempt->id}\n";
} else {
    echo "No randomized exam attempts found\n";
    echo "The current test with attempt #613 is sufficient (non-randomized with skipped questions)\n";
}
