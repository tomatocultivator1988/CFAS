<?php

require __DIR__ . '/backend/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Checking Answer-Related Tables ===\n\n";

echo "EXAM_QUESTIONS TABLE:\n";
$columns = DB::select("DESCRIBE exam_questions");
foreach ($columns as $col) {
    echo "  - {$col->Field} ({$col->Type})\n";
}

echo "\nANSWER_CHOICES TABLE:\n";
$columns = DB::select("DESCRIBE answer_choices");
foreach ($columns as $col) {
    echo "  - {$col->Field} ({$col->Type})\n";
}

echo "\nATTEMPT_ANSWERS TABLE:\n";
$columns = DB::select("DESCRIBE attempt_answers");
foreach ($columns as $col) {
    echo "  - {$col->Field} ({$col->Type})\n";
}

// Check if there are any exams with questions
echo "\n=== Sample Data Check ===\n";
$examCount = DB::table('exams')->where('status', 'active')->where('is_deleted', 0)->count();
echo "Active Exams: {$examCount}\n";

if ($examCount > 0) {
    $exam = DB::table('exams')->where('status', 'active')->where('is_deleted', 0)->first();
    echo "Sample Exam: {$exam->title} (ID: {$exam->id})\n";
    
    $questionCount = DB::table('exam_questions')->where('exam_id', $exam->id)->count();
    echo "Questions in this exam: {$questionCount}\n";
    
    if ($questionCount > 0) {
        $question = DB::table('exam_questions')->where('exam_id', $exam->id)->first();
        echo "Sample Question ID: {$question->question_id}\n";
        
        $choiceCount = DB::table('answer_choices')->where('question_id', $question->question_id)->count();
        echo "Choices for this question: {$choiceCount}\n";
    }
}
