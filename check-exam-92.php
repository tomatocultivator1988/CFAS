<?php

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

// Check exam 92
$exam92 = \App\Models\Exam::find(92);
if ($exam92) {
    echo "Exam 92 exists:\n";
    echo "  Title: {$exam92->title}\n";
    echo "  Questions: " . DB::table('exam_questions')->where('exam_id', 92)->count() . "\n";
} else {
    echo "Exam 92 does not exist\n";
}

echo "\n";

// Check exam 91
$exam91 = \App\Models\Exam::find(91);
if ($exam91) {
    echo "Exam 91 exists:\n";
    echo "  Title: {$exam91->title}\n";
    echo "  Questions: " . DB::table('exam_questions')->where('exam_id', 91)->count() . "\n";
} else {
    echo "Exam 91 does not exist\n";
}

echo "\n";

// Check latest exams
echo "Latest 5 exams:\n";
$exams = \App\Models\Exam::orderBy('id', 'desc')->take(5)->get();
foreach ($exams as $exam) {
    $qCount = DB::table('exam_questions')->where('exam_id', $exam->id)->count();
    echo "  ID: {$exam->id} | {$exam->title} | Questions: $qCount\n";
}
