<?php

require __DIR__ . '/backend/vendor/autoload.php';

$app = require_once __DIR__ . '/backend/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== ALL EXAMS (Active) ===" . PHP_EOL . PHP_EOL;

// Check all active exams
$allExams = DB::table('exams')
    ->select('id', 'title', 'category', 'status')
    ->where('status', 'active')
    ->where('is_deleted', 0)
    ->get();

foreach ($allExams as $exam) {
    echo "Exam ID: {$exam->id}" . PHP_EOL;
    echo "  Title: {$exam->title}" . PHP_EOL;
    echo "  Category: {$exam->category}" . PHP_EOL;
    echo "  Status: {$exam->status}" . PHP_EOL . PHP_EOL;
}

echo "=== CATEGORY BREAKDOWN (Current Implementation) ===" . PHP_EOL . PHP_EOL;

// Current implementation - shows categories
$categoryBreakdown = DB::table('exam_attempts as ea')
    ->join('exams as e', 'ea.exam_id', '=', 'e.id')
    ->select(
        'e.category',
        DB::raw('COUNT(ea.id) as total_attempts'),
        DB::raw('AVG(ea.percentage) as average_score')
    )
    ->where('ea.status', 'completed')
    ->where('e.status', 'active')
    ->where('e.is_deleted', 0)
    ->whereNotNull('e.category')
    ->groupBy('e.category')
    ->having('total_attempts', '>', 0)
    ->get();

foreach ($categoryBreakdown as $cat) {
    echo "Category: {$cat->category}" . PHP_EOL;
    echo "  Attempts: {$cat->total_attempts}" . PHP_EOL;
    echo "  Avg Score: " . round($cat->average_score, 2) . "%" . PHP_EOL . PHP_EOL;
}

echo PHP_EOL . "=== INDIVIDUAL EXAMS WITH ATTEMPTS ===" . PHP_EOL . PHP_EOL;

// What you want - individual exams with attempts
$examsWithAttempts = DB::table('exams as e')
    ->leftJoin('exam_attempts as ea', function($join) {
        $join->on('e.id', '=', 'ea.exam_id')
             ->where('ea.status', '=', 'completed');
    })
    ->select(
        'e.id',
        'e.title',
        'e.category',
        DB::raw('COUNT(ea.id) as total_attempts'),
        DB::raw('COALESCE(AVG(ea.percentage), 0) as average_score')
    )
    ->where('e.status', 'active')
    ->where('e.is_deleted', 0)
    ->groupBy('e.id', 'e.title', 'e.category')
    ->having('total_attempts', '>', 0)
    ->orderBy('total_attempts', 'DESC')
    ->get();

foreach ($examsWithAttempts as $exam) {
    echo "Exam: {$exam->title}" . PHP_EOL;
    echo "  Category: {$exam->category}" . PHP_EOL;
    echo "  Attempts: {$exam->total_attempts}" . PHP_EOL;
    echo "  Avg Score: " . round($exam->average_score, 2) . "%" . PHP_EOL . PHP_EOL;
}

echo "Total exams with attempts: " . count($examsWithAttempts) . PHP_EOL;
