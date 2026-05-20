<?php

require __DIR__ . '/backend/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Checking Exam Questions ===\n\n";

$exams = DB::table('exams')->where('status', 'active')->get();

foreach ($exams as $exam) {
    $questionCount = DB::table('exam_questions')->where('exam_id', $exam->id)->count();
    echo "Exam: {$exam->title} (ID: {$exam->id})\n";
    echo "Questions: {$questionCount}\n";
    echo "---\n";
}
